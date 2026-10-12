<?php
/** Run the same application tests against disposable MySQL/MariaDB databases. */
declare(strict_types=1);

if (PHP_SAPI !== 'cli') { http_response_code(403); return; }
require_once dirname(__DIR__, 2) . '/web_root/tests/testFramework/TestBootstrap.php';
require_once __DIR__ . '/migrateDb.php';

/** Compare every BMP scalar's legacy primary weights, plus multi-character LIKE semantics. */
function eel_test_unicode_parity(PDO $pdo): void
{
    for ($start = 0; $start <= 0xffff; $start += 128) {
        $queries = []; $params = [];
        for ($code = $start; $code < $start + 128 && $code <= 0xffff; $code++) {
            if ($code >= 0xd800 && $code <= 0xdfff) continue;
            $queries[] = 'SELECT ' . $code . ' AS code, HEX(WEIGHT_STRING(CONVERT(:c' . $code . ' USING utf8mb4) COLLATE utf8mb4_unicode_ci)) AS weight';
            $params['c' . $code] = IntlChar::chr($code);
        }
        if ($queries === []) continue;
        foreach (PdoDB::prepareExecuteOn($pdo, implode(' UNION ALL ', $queries), $params)->fetchAll(PDO::FETCH_ASSOC) as $row) {
            $actual = strtoupper(bin2hex(SqliteDB::key(IntlChar::chr((int)$row['code']))));
            if ($actual !== strtoupper((string)$row['weight'])) {
                throw new RuntimeException(sprintf('Unicode primary weight mismatch at U+%04X: SQLite %s, server %s.', $row['code'], $actual, $row['weight']));
            }
        }
    }
    $samples = ['', 'a', 'A', 'á', 'á', 'ss', 'ß', 'ﬃ', 'ffi', 'Ω', 'ω', '中文', '한', '😀', '😁', 'a ', 'a\0', '%', '_', '\\'];
    $patterns = ['%', '_', 'a', 'a%', '%a%', 'á', 'ss', 'ß', 's_', 'a ', '\\%', '\\_', '\\\\'];
    foreach ($samples as $value) foreach ($patterns as $pattern) {
        $stmt = PdoDB::prepareExecuteOn($pdo, 'SELECT CONVERT(:value USING utf8mb4) COLLATE utf8mb4_unicode_ci LIKE CONVERT(:pattern USING utf8mb4) AS matched', ['value' => $value, 'pattern' => $pattern]);
        if ((int)$stmt->fetchColumn() !== SqliteDB::like($pattern, $value)) throw new RuntimeException('Unicode LIKE parity mismatch: ' . json_encode([$value, $pattern]));
    }
    foreach ($samples as $left) foreach ($samples as $right) {
        $stmt = PdoDB::prepareExecuteOn($pdo, 'SELECT STRCMP(CONVERT(:left USING utf8mb4) COLLATE utf8mb4_unicode_ci, CONVERT(:right USING utf8mb4) COLLATE utf8mb4_unicode_ci)', ['left' => $left, 'right' => $right]);
        if (((int)$stmt->fetchColumn() <=> 0) !== (SqliteDB::compare($left, $right) <=> 0)) throw new RuntimeException('Unicode comparison parity mismatch: ' . json_encode([$left, $right]));
    }
}

function eel_test_database_backends(array $backends, ?string $configFile = null): int
{
    if (!is_array($backends) || $backends === []) throw new RuntimeException('Supply named test connection configurations.');
    foreach ($backends as $name => $config) {
        $database = 'eelkit_test_' . bin2hex(random_bytes(8));
        $dsn = eel_test_connection_dsn($config['dsn']);
        $pdo = new PDO($dsn, $config['user'] ?? null, $config['pass'] ?? null, PdoDB::connectionOptions($dsn));
        PdoDB::configureServerClock($pdo);
        $pdo->exec('CREATE DATABASE `' . $database . '` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci');
        try {
            $pdo->exec('USE `' . $database . '`');
            (new ReflectionProperty(InterfaceDB::class, 'connection'))->setValue(null, $pdo);
            InterfaceDB::clearMetadataCache();
            if (eel_run_migration_tool(dirname(__DIR__, 2) . '/db_schema/eelKit.schema.sql', dirname(__DIR__, 2) . '/db_schema/migrations') !== 0) throw new RuntimeException('Test database initialization failed.');
            eel_test_historical_database($pdo, $database);
            echo $name . ': checking Unicode comparison, sorting weights, and searches.' . PHP_EOL;
            eel_test_unicode_parity($pdo);
            $environment = getenv();
            $environment['EELKIT_TEST_DATABASE'] = $database;
            $environment['EELKIT_TEST_BACKEND_NAME'] = $name;
            $environment['EELKIT_TEST_CONNECTION_FILE'] = $configFile ?? '';
            $environment['EELKIT_TEST_ODBC_DSN'] = str_starts_with($config['dsn'], 'odbc:') ? substr($config['dsn'], 5) : '';
            $environment['EELKIT_TEST_MYSQL_PORT'] = (string)($config['isolated_port'] ?? '');
            $process = proc_open([PHP_BINARY, dirname(__DIR__, 2) . '/web_root/tests/index.php', '--strict-skips'], [0 => ['pipe','r'], 1 => ['pipe','w'], 2 => ['pipe','w']], $pipes, null, $environment);
            if (!is_resource($process)) throw new RuntimeException('Could not launch the application test suite.');
            fclose($pipes[0]);
            $output = stream_get_contents($pipes[1]); fclose($pipes[1]);
            $errors = stream_get_contents($pipes[2]); fclose($pipes[2]);
            $code = proc_close($process);
            $result = json_decode($output, true);
            if ($code !== 0 || !is_array($result) || ($result['all']['result'] ?? '') !== 'pass') {
                echo $output;
                if ($errors !== '') fwrite(STDERR, $errors);
                throw new RuntimeException($name . ' application test suite failed.');
            }
            echo $name . ': ' . json_encode($result['all']['summary']) . PHP_EOL;
        } finally {
            $pdo->exec('DROP DATABASE `' . $database . '`');
        }
    }
    return 0;
}

/** Exercise shared historical SQL, including MySQL ALTER compatibility, with preserved data. */
function eel_test_historical_database(PDO $pdo, string $freshDatabase): void
{
    $database = 'eelkit_test_' . bin2hex(random_bytes(8));
    $pdo->exec('CREATE DATABASE `' . $database . '` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci');
    try {
        $pdo->exec('USE `' . $database . '`'); InterfaceDB::clearMetadataCache();
        $fixture = (string)file_get_contents(dirname(__DIR__, 2) . '/web_root/tests/fixtures/db/mysql-initial.sql');
        foreach (splitMigrationSql($fixture) as $sql) InterfaceDB::execute($sql);
        InterfaceDB::execute("INSERT INTO users (id,display_name,email_address,password_hash) VALUES (41,'Preserved','preserved@example.test','fixture hash')");
        foreach (migrationFiles(dirname(__DIR__, 2) . '/db_schema/migrations') as $file) {
            if (!isset(appliedMigrations()[basename($file)])) applyMigration($file);
            if (InterfaceDB::fetchColumn('SELECT display_name FROM users WHERE id=41') !== 'Preserved') throw new RuntimeException('Historical upgrade lost application data.');
        }
        $versions = count(migrationFiles(dirname(__DIR__, 2) . '/db_schema/migrations'));
        if ((int)InterfaceDB::fetchColumn('SELECT COUNT(*) FROM schema_migrations') !== $versions) throw new RuntimeException('Historical migration tracking differs from fresh setup.');
        $schemas = [];
        foreach ([$freshDatabase, $database] as $schema) {
            $schemas[] = PdoDB::prepareExecuteOn($pdo, 'SELECT table_name,column_name,column_type,is_nullable,column_default,extra FROM information_schema.columns WHERE table_schema=:schema ORDER BY table_name,ordinal_position', ['schema' => $schema])->fetchAll(PDO::FETCH_ASSOC);
        }
        if ($schemas[0] !== $schemas[1]) throw new RuntimeException('Historical and fresh MySQL/MariaDB column definitions differ.');
        echo 'Historical server migrations preserve data and match the fresh schema.' . PHP_EOL;
    } finally {
        $pdo->exec('USE `' . $freshDatabase . '`'); InterfaceDB::clearMetadataCache();
        $pdo->exec('DROP DATABASE `' . $database . '`');
    }
}

if (realpath((string)($_SERVER['SCRIPT_FILENAME'] ?? '')) === __FILE__) {
    try {
        $backends = []; $configFile = null;
        foreach (array_slice($argv, 1) as $argument) {
            if (str_starts_with($argument, '--config=')) { $configFile = realpath(substr($argument, 9)); $backends = require $configFile; }
            elseif (str_starts_with($argument, '--odbc=')) $backends['mariadb_odbc'] = ['dsn' => 'odbc:' . substr($argument, 7)];
            elseif (str_starts_with($argument, '--mysql-isolated-port=')) {
                $port = substr($argument, 22);
                if (!ctype_digit($port) || (int)$port < 1024 || (int)$port > 65535) throw new RuntimeException('Invalid isolated test server port.');
                $backends['mysql'] = ['dsn' => 'mysql:host=127.0.0.1;port=' . $port . ';charset=utf8mb4', 'user' => 'root', 'isolated_port' => $port];
            } else throw new RuntimeException('Usage: php tools/php/testDatabaseBackends.php --odbc=<saved DSN> [--mysql-isolated-port=<port>] or --config=<existing local PHP configuration file>');
        }
        exit(eel_test_database_backends($backends, $configFile));
    } catch (Throwable $exception) {
        fwrite(STDERR, $exception->getMessage() . PHP_EOL);
        exit(1);
    }
}
