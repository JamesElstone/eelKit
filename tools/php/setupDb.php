<?php
/**
 * eelKit Framework
 * Copyright (c) 2026 James Elstone
 * Licensed under the BSD 3-Clause License
 * See LICENSE file for details.
 */
declare(strict_types=1);

require_once __DIR__ . DIRECTORY_SEPARATOR . 'setDbConfig.php';
require_once __DIR__ . DIRECTORY_SEPARATOR . 'migrateDb.php';

function eel_database_setup_usage(): string
{
    return implode(PHP_EOL, [
        'Usage:',
        '  php tools/php/setupDb.php [database options]',
        '  php tools/php/setupDb.php --migrate-only',
        '  php tools/php/setupDb.php --configure-db',
        '',
        'Database options are the same as setDbConfig.php:',
        '  --dsn=<dsn> [--user=<user>] [--password=<password>]',
        '  --driver=odbc --odbc-name=<name> [--user=<user>] [--password=<password>]',
        '  --driver=mysql --host=<host> --database=<database> [--port=<port>] [--user=<user>] [--password=<password>]',
        '  --driver=sqlite --sqlite-path=<path>',
        '',
        'By default the tool creates secure/app.php if needed, asks for database settings only when db.dsn is empty,',
        'loads the baseline schema for an empty database, applies pending migrations, then runs setExternalIP.sh.',
        '',
        'Options:',
        '  --configure-db      Ask for or apply database settings even when db.dsn already exists.',
        '  --migrate-only      Apply schema setup/migrations without changing database settings or external IP.',
        '  --skip-external-ip  Do not run tools/bin/setExternalIP.sh after database setup.',
        '  --help, -h          Show this help.',
    ]);
}

function eel_database_setup_arguments(array $argv): array
{
    $setup = [
        'help' => false,
        'configure_db' => false,
        'migrate_only' => false,
        'skip_external_ip' => false,
        'db_argv' => [$argv[0] ?? 'setupDb.php'],
    ];

    foreach (array_slice($argv, 1) as $argument) {
        if ($argument === '--help' || $argument === '-h') {
            $setup['help'] = true;
            continue;
        }

        if ($argument === '--configure-db') {
            $setup['configure_db'] = true;
            continue;
        }

        if ($argument === '--migrate-only') {
            $setup['migrate_only'] = true;
            $setup['skip_external_ip'] = true;
            continue;
        }

        if ($argument === '--skip-external-ip') {
            $setup['skip_external_ip'] = true;
            continue;
        }

        $setup['db_argv'][] = $argument;
    }

    $setup['db_arguments'] = eel_set_db_config_arguments($setup['db_argv']);

    return $setup;
}

function eel_database_setup_has_database_options(array $arguments): bool
{
    foreach ([
        'dsn',
        'driver',
        'odbc_name',
        'host',
        'port',
        'database',
        'sqlite_path',
        'user',
        'password',
    ] as $key) {
        if (($arguments[$key] ?? null) !== null) {
            return true;
        }
    }

    return false;
}

function eel_database_setup_has_database_dsn(): bool
{
    return trim((string)AppConfigurationStore::get('db.dsn', '', true)) !== '';
}

function eel_database_setup_configure_database_if_needed(array $setupArguments): int
{
    if ($setupArguments['migrate_only'] === true) {
        return 0;
    }

    $dbArguments = $setupArguments['db_arguments'];
    $shouldConfigure = $setupArguments['configure_db'] === true
        || eel_database_setup_has_database_options($dbArguments)
        || !eel_database_setup_has_database_dsn();

    if (!$shouldConfigure) {
        echo 'Database config already present in secure/app.php.' . PHP_EOL;
        return 0;
    }

    return eel_set_db_config_run_tool($setupArguments['db_argv']);
}

function eel_database_setup_run_external_ip_script(): int
{
    $script = dirname(__DIR__) . DIRECTORY_SEPARATOR . 'bin' . DIRECTORY_SEPARATOR . 'setExternalIP.sh';

    if (!is_file($script)) {
        fwrite(STDERR, 'External IP script was not found: ' . $script . PHP_EOL);
        return 1;
    }

    $command = 'sh ' . escapeshellarg($script);
    passthru($command, $exitCode);

    return is_int($exitCode) ? $exitCode : 1;
}

function eel_run_database_setup_tool(string $schemaFile, string $migrationsDirectory, array $argv = []): int
{
    if (PHP_SAPI !== 'cli') {
        fwrite(STDERR, "This database setup tool must be run from the command line.\n");
        return 1;
    }

    if ($argv === []) {
        $argv = $_SERVER['argv'] ?? ['setupDb.php'];
    }

    try {
        $setupArguments = eel_database_setup_arguments($argv);

        if ($setupArguments['help'] === true) {
            echo eel_database_setup_usage() . PHP_EOL;
            return 0;
        }

        $configPath = AppConfigurationStore::ensureStoredConfig();
        echo 'Application config ready at ' . $configPath . PHP_EOL;

        $configExitCode = eel_database_setup_configure_database_if_needed($setupArguments);
        if ($configExitCode !== 0) {
            return $configExitCode;
        }
    } catch (Throwable $exception) {
        fwrite(STDERR, 'Configuration setup failed: ' . $exception->getMessage() . PHP_EOL);
        return 1;
    }

    $migrationExitCode = eel_run_migration_tool($schemaFile, $migrationsDirectory);
    if ($migrationExitCode !== 0) {
        return $migrationExitCode;
    }

    if (($setupArguments['skip_external_ip'] ?? false) === true) {
        return 0;
    }

    return eel_database_setup_run_external_ip_script();
}

if (realpath((string)($_SERVER['SCRIPT_FILENAME'] ?? '')) === __FILE__) {
    exit(eel_run_database_setup_tool($schemaFile, $migrationsDirectory, $argv));
}
