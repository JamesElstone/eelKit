<?php
/** Explicit test-only database initialization; production never loads this helper. */
declare(strict_types=1);

function eel_test_database_fixture(?PDO $pdo = null): PDO
{
    $pdo ??= new PDO('sqlite::memory:', null, null, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION, PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC]);
    SqliteDB::prerequisites();
    SqliteDB::configure($pdo);
    $pdo->exec((string)file_get_contents(dirname(__DIR__, 3) . '/db_schema/sqlite/eelKit.schema.sql'));
    $connection = new ReflectionProperty(InterfaceDB::class, 'connection');
    $connection->setValue(null, $pdo);
    InterfaceDB::clearMetadataCache();
    return $pdo;
}

function eel_test_database_connection(): PDO
{
    $file = getenv('EELKIT_TEST_CONNECTION_FILE');
    $database = (string)getenv('EELKIT_TEST_DATABASE');
    if ($database === '') return eel_test_database_fixture();
    if (is_string($file) && $file !== '') {
        $backends = require $file;
        $config = $backends[(string)getenv('EELKIT_TEST_BACKEND_NAME')];
    } elseif (getenv('EELKIT_TEST_ODBC_DSN')) {
        $config = ['dsn' => 'odbc:' . getenv('EELKIT_TEST_ODBC_DSN')];
    } else {
        $port = (string)getenv('EELKIT_TEST_MYSQL_PORT');
        if (!ctype_digit($port)) throw new RuntimeException('Invalid isolated test server port.');
        $config = ['dsn' => 'mysql:host=127.0.0.1;port=' . $port . ';charset=utf8mb4', 'user' => 'root'];
    }
    if (!preg_match('/^eelkit_test_[a-f0-9]{16}$/D', $database)) {
        throw new RuntimeException('Database tests require a disposable eelkit_test_ database.');
    }
    $dsn = eel_test_connection_dsn($config['dsn']);
    $pdo = new PDO($dsn, $config['user'] ?? null, $config['pass'] ?? null, PdoDB::connectionOptions($dsn));
    PdoDB::configureServerClock($pdo);
    $pdo->exec('USE `' . $database . '`');
    (new ReflectionProperty(InterfaceDB::class, 'connection'))->setValue(null, $pdo);
    InterfaceDB::clearMetadataCache();
    return $pdo;
}

/** Configure the disposable session through the driver; do not modify the saved DSN. */
function eel_test_connection_dsn(string $dsn): string
{
    if (!str_starts_with($dsn, 'odbc:')) return $dsn;
    $settings = substr($dsn, 5);
    if (!str_contains($settings, '=')) $settings = 'DSN=' . $settings;
    if (preg_match('/(?:^|;)CHARSET=/i', $settings)) {
        $settings = preg_replace('/(^|;)CHARSET=[^;]*/i', '$1CHARSET=utf8mb4', $settings);
    } else $settings .= ';CHARSET=utf8mb4';
    return 'odbc:' . $settings;
}
