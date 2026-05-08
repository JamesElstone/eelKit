# Database Schema

The `db_schema` directory contains the canonical database structure for eelKit and the incremental SQL migrations used to keep existing installations up to date.

## Directory Structure

```text
db_schema/
  eelKit.schema.sql   Baseline schema used to hydrate a new empty database
  migrations/         Ordered incremental SQL migrations
  README.md           This guide
```

## Baseline Schema

`eelKit.schema.sql` is the full baseline schema for a fresh eelKit database. The migration tool uses it when the configured database has no application tables yet.

The baseline includes the `schema_migrations` table and marks the initial migration as applied, so a newly hydrated database does not try to replay the baseline marker migration.

## Migrations

`migrations/` contains one SQL file per schema change. Files are applied in filename order, and each applied filename is recorded in `schema_migrations`.

Current naming style:

```text
YYYY_MM_DD_NNN_short_description.sql
```

Examples:

```text
2026_05_08_001_schema_integrity.sql
2026_05_08_002_force_password_change.sql
2026_05_08_003_user_otp_optional.sql
```

When adding a migration:

- Use the next sequence number for that date.
- Keep each migration focused on one schema change.
- Write SQL that can run once and leave the database in the expected final shape.
- Do not rename an already-applied migration file, because the filename is the migration identity.
- Update `eelKit.schema.sql` when the baseline schema should include the same final structure for new installs.

## Running Migrations

Use the tools in `tools/` from the project root.

Set up a new database and apply pending migrations:

```sh
tools/bin/setupDb.sh
```

Windows Command Prompt:

```bat
tools\bat\setupDb.bat
```

Apply pending migrations only:

```sh
tools/bin/migrateDb.sh
```

Windows Command Prompt:

```bat
tools\bat\migrateDb.bat
```

Direct PHP equivalents:

```sh
php tools/php/setupDb.php
php tools/php/migrateDb.php
```

## Runtime Configuration

The migration tools use the database settings from `secure/app.php`. If the database connection has not been configured yet, run:

```sh
tools/bin/setDbConfig.sh
```

Windows Command Prompt:

```bat
tools\bat\setDbConfig.bat
```
