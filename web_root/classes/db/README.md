# Database Classes

This folder contains the small database layer used by eelKit.

- `InterfaceDB.php` is the public static interface used by application code.
- `PdoDB.php` owns PDO connection setup, SQL logging, and ODBC compatibility helpers.
- `SqliteDB.php` applies SQLite connection policy and legacy Unicode compatibility.
- `SqliteMigrationDB.php` installs and upgrades native SQLite schemas through the CLI tools.
- `PdoStatementDB.php` wraps `PDOStatement` so named parameters can be rewritten for ODBC drivers that expect positional placeholders.

`InterfaceDB::tableExists()` and `InterfaceDB::columnExists()` cache definitive metadata results for the current PDO connection and request. Call `InterfaceDB::clearMetadataCache()` after in-process schema changes or at the start of a long-running worker request. Successful schema-changing statements issued through `InterfaceDB` clear the cache automatically.

SQL logging is buffered by `LogStore` and flushed in batches and during normal shutdown instead of calling `fflush()` for every query. Long-running workers can call `PdoDB::flushSqlLogs()` explicitly. SQL log timestamps use `Y-m-d H:i:s.u`; the CSV field shape remains unchanged.

Database settings are read from `secure/app.php` under the `db` key. For MariaDB via ODBC, use an ODBC DSN such as `odbc:example_dsn`, configure that DSN with `CHARSET=utf8mb4`, and keep real credentials out of version control.

## SQLite

SQLite supports the same application services and cards as MySQL/MariaDB. PHP
must have `pdo_sqlite` and `intl`, and be linked to SQLite 3.51.3 or newer.
Check the SQLite library version through PHP, not a separate sqlite CLI binary:

```sh
php -r 'echo (new PDO("sqlite::memory:"))->query("SELECT sqlite_version()")->fetchColumn(), PHP_EOL;'
php tools/php/setupDb.php --driver=sqlite --sqlite-path=secure/eelkit.sqlite --skip-external-ip
php tools/php/setupDb.php --migrate-only
```

Create the parent directory first. Relative paths resolve against the project
root; configuration stores an absolute path. The database must be outside
`web_root`, and PHP must be able to write its file and directory, including WAL
and shared-memory sidecars. Use local storage on one host, not a network share.
Filesystem permissions replace database usernames/passwords; none are needed
for SQLite. Normal application connections do not create files or hydrate
schemas. The retired `db.sqlite_schema` option is rejected in production.

Setup enables WAL. Connections require WAL, enable foreign keys and FULL
durability, and set `db.sqlite_busy_timeout_ms` to 5000 unless configured
otherwise (integer, 0–60000). Lock failures propagate through normal error
handling; writes and external deliveries are never automatically replayed.

`InterfaceDB::writeTransaction()` acquires the SQLite writer lock before reads
and uses savepoints for nested calls. `beginTransaction()` also acquires that
lock on SQLite. Use short transactions and send email/SMS after committing.
`lastInsertId()` returns the connection's generated ID, including MariaDB ODBC.
SQL defaults and expiry comparisons use PHP's configured timezone on every
backend, matching the framework's existing naive timestamp format. Keep the
deployment timezone stable; reconnect long-running workers across offset changes.

Unicode comparisons and searches reproduce the schema's legacy
`utf8mb4_unicode_ci` behavior, including its supplementary-character weights;
binary tokens remain exact. Details and the data license are in `unicode/`.

Take upgrades in a maintenance window. Upgrade runs are serialized and atomic;
unrecognized partial schemas or missing integrity indexes/triggers fail before
changes are applied. Do not change migration filenames or manually mark them
applied. Back up before upgrading. With all application workers stopped and
connections closed, checkpoint the database and copy it; never copy just a live
database file while its WAL may contain committed records. For online backups,
use SQLite's backup API through a client that registers eelKit's collation and
functions. Restore with workers stopped, retain restrictive permissions, and
run setup/migrations and `PRAGMA integrity_check`/`foreign_key_check` through an
eelKit-configured connection before restarting.

## Unicode diagnostic

Run the CLI diagnostic after configuring a MariaDB ODBC connection:

```sh
tools/bin/dbUnicodeDiagnostic.sh
# Windows Command Prompt: tools\bat\dbUnicodeDiagnostic.bat
```

It reports the PDO driver, OS family, effective MariaDB server/connection character sets, and a byte-exact parameterised Unicode and JSON round trip. A named ODBC DSN cannot expose its `CHARSET` value through PDO, so the tool reports that as not directly verifiable; a successful round trip is the authoritative check. The configured database user needs `CREATE TEMPORARY TABLES`; the diagnostic removes its temporary table before it exits.

## FreeBSD MariaDB ODBC Setup

Tested with MariaDB 11.8, MariaDB Connector/ODBC 3.2.8, PHP 8.4, unixODBC, and `PDO_ODBC`.

### 1. MariaDB client/server

Install MariaDB from packages or ports. Do not install `databases/mariadb-connector-c` when `mariadb118-client` is already installed, because both provide `mariadb_config`.

Useful checks:

```sh
pkg info | grep maria
find /usr/local -name 'libmariadb.so*' -print
ldconfig -r | grep -i mariadb
```

Expected client library:

```text
/usr/local/lib/mysql/libmariadb.so.3
```

### 2. MariaDB Connector/ODBC

Build the ODBC connector against the MariaDB client library path:

```sh
cd /usr/ports/databases/mariadb-connector-odbc
make clean
make LDFLAGS="-L/usr/local/lib/mysql" CPPFLAGS="-I/usr/local/include/mysql"
make install
```

Verify the driver and linkage:

```sh
find /usr/local -name 'libmaodbc.so*' -print
ldd /usr/local/lib/mariadb/libmaodbc.so
```

Expected driver path:

```text
/usr/local/lib/mariadb/libmaodbc.so
```

### 3. Register the unixODBC Driver

```sh
cat > /tmp/mariadb-odbc-driver.template <<'EOF'
[MariaDB]
Description=MariaDB ODBC Driver
Driver=/usr/local/lib/mariadb/libmaodbc.so
Setup=/usr/local/lib/mariadb/libmaodbc.so
FileUsage=1
EOF

odbcinst -i -d -f /tmp/mariadb-odbc-driver.template
odbcinst -q -d
odbcinst -q -d -n MariaDB
```

### 4. Create a DSN

Check unixODBC paths:

```sh
odbcinst -j
```

Create or edit `/usr/local/etc/odbc.ini`:

```ini
[example_dsn]
Driver=MariaDB
Description=Example application database
SERVER=127.0.0.1
PORT=3306
DATABASE=example_database
USER=local
PASSWORD=replace_with_real_password
CHARSET=utf8mb4
```

Windows MariaDB Connector/ODBC DSNs must also include `CHARSET=utf8mb4` in the ODBC Data Source Administrator (or the equivalent DSN configuration). On Windows, eelKit enables the PDO ODBC UTF-8 assumption only when the installed PHP PDO ODBC extension exposes that option.

Use `SERVER=localhost` for local socket style access, or `SERVER=127.0.0.1` to force TCP loopback.

Test the DSN:

```sh
odbcinst -q -s
isql -v example_dsn
isql -v example_dsn local 'replace_with_real_password'
```

### 5. MariaDB Grants

MariaDB matches both user and host, so `local` at `localhost` and `local` at `127.0.0.1` are separate accounts.

```sql
CREATE USER IF NOT EXISTS 'local'@'localhost'
IDENTIFIED BY 'replace_with_real_password';

GRANT SELECT, INSERT, UPDATE, DELETE
ON example_database.*
TO 'local'@'localhost';

CREATE USER IF NOT EXISTS 'local'@'127.0.0.1'
IDENTIFIED BY 'replace_with_real_password';

GRANT SELECT, INSERT, UPDATE, DELETE
ON example_database.*
TO 'local'@'127.0.0.1';

FLUSH PRIVILEGES;
```

For development or migrations, add schema permissions:

```sql
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, ALTER, INDEX, DROP
ON example_database.*
TO 'local'@'localhost';

GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, ALTER, INDEX, DROP
ON example_database.*
TO 'local'@'127.0.0.1';

FLUSH PRIVILEGES;
```

Check grants:

```sql
SHOW GRANTS FOR 'local'@'localhost';
SHOW GRANTS FOR 'local'@'127.0.0.1';
```

### 6. PHP PDO ODBC

```sh
pkg install php84-pdo_odbc
php -m | grep -Ei 'PDO|ODBC'
php -r 'print_r(PDO::getAvailableDrivers());'
```

Expected PDO driver list should include `odbc`.

Restart services after extension or DSN changes:

```sh
service php_fpm restart
service apache24 restart
```

### 7. PHP Connection Test

```sh
php -r '$pdo = new PDO("odbc:example_dsn", "local", "replace_with_real_password"); echo "Connected\n";'
```

Example config value:

```php
'db' => [
    'dsn' => 'odbc:example_dsn',
    'user' => 'local',
    'pass' => 'replace_with_real_password',
],
```

## Troubleshooting

- If `isql` works but PHP says `could not find driver`, install or enable `php84-pdo_odbc`.
- If PHP CLI works but the web app fails, restart `php_fpm` and `apache24`.
- If ODBC reports access denied for `local` at `localhost`, create or fix that exact MariaDB user.
- If using `SERVER=127.0.0.1`, ensure `local` at `127.0.0.1` exists.
- Do not rely on `PDO::lastInsertId()` with MariaDB through PDO ODBC in this project.
- Keep database and text columns on `utf8mb4`. Audit legacy `latin1` data before repair; do not blindly reinterpret non-ASCII values without evidence of the intended text.
- Do not commit real DSN passwords or production credentials.
