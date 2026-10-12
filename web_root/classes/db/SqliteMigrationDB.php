<?php
/** eelKit Framework. Copyright (c) 2026 James Elstone. BSD-3-Clause. */
declare(strict_types=1);

/** Native, serialized SQLite schema installation and upgrades. */
final class SqliteMigrationDB
{
    public static function run(string $schemaFile, string $directory): void
    {
        if (InterfaceDB::inTransaction()) throw new RuntimeException('A transaction is already open before migration.');
        $states = json_decode(self::read(dirname($directory) . '/schema-states.json'), true, flags: JSON_THROW_ON_ERROR);
        $files = migrationFiles($directory);
        $names = array_map('basename', $files);
        if (array_keys($states) !== $names) throw new RuntimeException('SQLite migration files and schema states do not match.');
        InterfaceDB::execute('PRAGMA foreign_keys=OFF');
        try {
            InterfaceDB::beginWriteTransaction();
            $tables = InterfaceDB::prepareExecute("SELECT name FROM sqlite_master WHERE type='table' AND name NOT GLOB 'sqlite_*'")->fetchAll();
            if ($tables === []) {
                InterfaceDB::executeScript(self::read($schemaFile));
                self::validate($states[$names[count($names) - 1]]);
                echo 'Loaded SQLite baseline schema.' . PHP_EOL;
            } else {
                if (!InterfaceDB::tableExists('schema_migrations')) {
                    throw new RuntimeException('Unrecognized partial SQLite schema: schema_migrations is missing.');
                }
                $applied = array_keys(appliedMigrations());
                sort($applied);
                if ($applied === [] || $applied !== array_slice($names, 0, count($applied))) {
                    throw new RuntimeException('Unrecognized SQLite migration history; expected a contiguous known migration prefix.');
                }
                self::validate($states[$applied[count($applied) - 1]]);
                foreach (array_slice($files, count($applied)) as $file) {
                    $name = basename($file);
                    $sequences = InterfaceDB::prepareExecute('SELECT name, seq FROM sqlite_sequence')->fetchAll();
                    $extras = InterfaceDB::prepareExecute("SELECT name, type, sql FROM sqlite_master WHERE type IN ('index','trigger') AND sql IS NOT NULL")->fetchAll();
                    try {
                        InterfaceDB::executeScript(self::read($file));
                        // Rebuilds must never reuse IDs previously issued for deleted rows.
                        foreach ($sequences as $sequence) {
                            InterfaceDB::execute('UPDATE sqlite_sequence SET seq = MAX(seq, :seq) WHERE name = :name', $sequence);
                        }
                        // Preserve downstream indexes and triggers on rebuilt framework tables.
                        foreach ($extras as $extra) {
                            if (!InterfaceDB::fetchColumn('SELECT COUNT(*) FROM sqlite_master WHERE name=:name AND type=:type', ['name' => $extra['name'], 'type' => $extra['type']])) {
                                InterfaceDB::executeScript((string)$extra['sql']);
                            }
                        }
                        self::validate($states[$name]);
                        self::checkForeignKeys();
                        InterfaceDB::execute('INSERT INTO schema_migrations (migration) VALUES (:migration)', ['migration' => $name]);
                    } catch (Throwable $exception) {
                        throw new RuntimeException('SQLite migration ' . $name . ' failed: ' . $exception->getMessage(), 0, $exception);
                    }
                    echo 'Applied ' . $name . PHP_EOL;
                }
            }
            self::checkForeignKeys();
            InterfaceDB::commit();
        } catch (Throwable $exception) {
            if (InterfaceDB::inTransaction()) InterfaceDB::rollBack();
            throw $exception;
        } finally {
            InterfaceDB::execute('PRAGMA foreign_keys=ON');
            InterfaceDB::clearMetadataCache();
        }
        echo 'SQLite schema is up to date.' . PHP_EOL;
    }

    private static function read(string $file): string
    {
        $sql = @file_get_contents($file);
        if (!is_string($sql) || trim($sql) === '') throw new RuntimeException('Schema resource could not be read: ' . $file);
        return $sql;
    }

    private static function normalise(string $sql): string
    {
        // SQLite quotes a table name during ALTER TABLE RENAME.
        $parts = preg_split("/('(?:''|[^'])*')/", rtrim(trim($sql), ';'), -1, PREG_SPLIT_DELIM_CAPTURE);
        foreach ($parts as $index => $part) {
            if ($index % 2 === 0) $parts[$index] = preg_replace('/\s+/', '', str_replace(['`', '"'], '', $part));
        }
        return implode('', $parts);
    }

    private static function validate(array $expected): void
    {
        foreach ($expected['tables'] as $table => $sql) {
            $actual = InterfaceDB::fetchColumn("SELECT sql FROM sqlite_master WHERE type='table' AND name=:name", ['name' => $table]);
            if (!is_string($actual) || self::normalise($actual) !== self::normalise($sql)) {
                throw new RuntimeException('Unrecognized partial SQLite schema: table ' . $table . ' differs from its recorded migration state.');
            }
        }
        foreach ($expected['objects'] as $name => $object) {
            $actual = InterfaceDB::fetchColumn('SELECT sql FROM sqlite_master WHERE name=:name AND type=:type', ['name' => $name, 'type' => $object['type']]);
            if (!is_string($actual) || self::normalise($actual) !== self::normalise($object['sql'])) {
                throw new RuntimeException('Unrecognized partial SQLite schema: index or trigger ' . $name . ' differs from its recorded migration state.');
            }
        }
        // Known future tables without matching history indicate a partial migration.
        foreach (eel_migration_application_tables() as $table) {
            if (!isset($expected['tables'][$table]) && InterfaceDB::tableExists($table)) {
                throw new RuntimeException('Unrecognized partial SQLite schema: unexpected framework table ' . $table . '.');
            }
        }
    }

    private static function checkForeignKeys(): void
    {
        if (InterfaceDB::prepareExecute('PRAGMA foreign_key_check')->fetchAll() !== []) {
            throw new RuntimeException('SQLite foreign-key integrity check failed.');
        }
    }
}
