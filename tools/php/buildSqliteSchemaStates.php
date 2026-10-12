<?php
/** Rebuild migration shape manifests in an isolated in-memory database; no application config. */
declare(strict_types=1);
if (PHP_SAPI !== 'cli') { http_response_code(403); return; }
require_once dirname(__DIR__, 2) . '/web_root/classes/db/SqliteDB.php';
try {
    SqliteDB::prerequisites();
    $pdo = new PDO('sqlite::memory:', null, null, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION, PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC]);
    SqliteDB::configure($pdo);
    $pdo->exec('PRAGMA foreign_keys=OFF');
    $root = dirname(__DIR__, 2) . '/db_schema/sqlite';
    $files = glob($root . '/migrations/*.sql'); sort($files);
    $states = [];
    foreach ($files as $file) {
        $pdo->exec((string)file_get_contents($file));
        if ($pdo->query('PRAGMA foreign_key_check')->fetchAll() !== []) throw new RuntimeException('Foreign key violation after ' . basename($file));
        $state = ['tables' => [], 'objects' => []];
        foreach ($pdo->query("SELECT name,type,sql FROM sqlite_master WHERE sql IS NOT NULL AND name NOT LIKE 'sqlite_%'") as $row) {
            if ($row['type'] === 'table') $state['tables'][$row['name']] = $row['sql'];
            else $state['objects'][$row['name']] = ['type' => $row['type'], 'sql' => $row['sql']];
        }
        $states[basename($file)] = $state;
    }
    $json = json_encode($states, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES | JSON_THROW_ON_ERROR) . PHP_EOL;
    if (($argv[1] ?? '') === '--write') {
        if (file_put_contents($root . '/schema-states.json', $json) === false) throw new RuntimeException('Could not save SQLite schema states.');
        echo 'Updated SQLite schema states.' . PHP_EOL;
    } elseif (count($argv) === 1) echo $json;
    else throw new RuntimeException('Usage: php tools/php/buildSqliteSchemaStates.php [--write]');
} catch (Throwable $exception) {
    fwrite(STDERR, $exception->getMessage() . PHP_EOL); exit(1);
}
