<?php
/** eelKit Framework. Copyright (c) 2026 James Elstone. BSD-3-Clause. */
declare(strict_types=1);

/** SQLite connection policy and compatibility with the schema's utf8mb4_unicode_ci. */
final class SqliteDB
{
    public const MIN_VERSION = '3.51.3';
    private static ?array $weights = null;

    public static function prerequisites(): void
    {
        if (!in_array('sqlite', PDO::getAvailableDrivers(), true)) {
            throw new RuntimeException('SQLite requires the PHP pdo_sqlite extension.');
        }
        if (!extension_loaded('intl')) {
            throw new RuntimeException('SQLite requires the PHP intl extension.');
        }
        $probe = new PDO('sqlite::memory:');
        $version = (string)$probe->query('SELECT sqlite_version()')->fetchColumn();
        if (version_compare($version, self::MIN_VERSION, '<')) {
            throw new RuntimeException('SQLite ' . self::MIN_VERSION . ' or newer is required; PHP is linked to ' . $version . '.');
        }
    }

    public static function normaliseDsn(string $dsn): string
    {
        $path = substr($dsn, 7);
        if ($path === ':memory:') return $dsn;
        if ($path === '' || str_starts_with($path, 'file:') || str_starts_with($path, '//') || str_starts_with($path, '\\\\')) {
            throw new RuntimeException('SQLite requires an explicit local database file path.');
        }
        $path = str_replace(['/', '\\'], DIRECTORY_SEPARATOR, $path);
        if (!preg_match('~^(?:[A-Za-z]:[\\\\/]|/)~', $path)) {
            $path = dirname(__DIR__, 3) . DIRECTORY_SEPARATOR . $path;
        }
        $parent = realpath(dirname($path));
        if ($parent === false) throw new RuntimeException('SQLite database directory does not exist: ' . dirname($path));
        $path = $parent . DIRECTORY_SEPARATOR . basename($path);
        $resolved = realpath($path) ?: $path;
        $webRoot = realpath(dirname(__DIR__, 2));
        $comparePath = PHP_OS_FAMILY === 'Windows' ? strtolower($resolved) : $resolved;
        $compareRoot = PHP_OS_FAMILY === 'Windows' ? strtolower((string)$webRoot) : (string)$webRoot;
        if ($comparePath === $compareRoot || str_starts_with($comparePath, $compareRoot . DIRECTORY_SEPARATOR)) {
            throw new RuntimeException('SQLite database must be outside web_root.');
        }
        return 'sqlite:' . $resolved;
    }

    /** Explicitly create a file only from the setup command, after checking prerequisites. */
    public static function createDatabase(string $dsn): void
    {
        self::prerequisites();
        $dsn = self::normaliseDsn($dsn);
        $path = substr($dsn, 7);
        if ($path === ':memory:') throw new RuntimeException('Setup requires a persistent SQLite database file.');
        if (!is_file($path)) {
            $file = @fopen($path, 'x');
            if ($file === false && !is_file($path)) throw new RuntimeException('Could not create SQLite database: ' . $path);
            if (is_resource($file)) { fclose($file); chmod($path, 0600); }
        }
        $pdo = new PDO($dsn, null, null, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
        $pdo->exec('PRAGMA busy_timeout=5000');
        if (strtolower((string)$pdo->query('PRAGMA journal_mode=WAL')->fetchColumn()) !== 'wal') {
            throw new RuntimeException('SQLite WAL mode could not be enabled. Use local writable storage.');
        }
    }

    public static function configure(PDO $pdo, array $config = []): void
    {
        $timeout = $config['sqlite_busy_timeout_ms'] ?? 5000;
        if (!is_int($timeout) || $timeout < 0 || $timeout > 60000) {
            throw new RuntimeException('db.sqlite_busy_timeout_ms must be an integer between 0 and 60000.');
        }
        $pdo->exec('PRAGMA busy_timeout=' . $timeout);
        $pdo->exec('PRAGMA foreign_keys=ON');
        if ((int)$pdo->query('PRAGMA foreign_keys')->fetchColumn() !== 1) throw new RuntimeException('SQLite foreign-key enforcement could not be enabled.');
        $pdo->exec('PRAGMA synchronous=FULL');
        $flags = defined('Pdo\\Sqlite::DETERMINISTIC') ? constant('Pdo\\Sqlite::DETERMINISTIC') : constant('PDO::SQLITE_DETERMINISTIC');
        if ($pdo instanceof \Pdo\Sqlite) $pdo->createCollation('eelkit_unicode_ci', self::compare(...));
        else @$pdo->sqliteCreateCollation('eelkit_unicode_ci', self::compare(...));
        $register = static function (string $name, callable $callback, int $arguments, bool $deterministic = true) use ($pdo, $flags): void {
            if ($pdo instanceof \Pdo\Sqlite) $pdo->createFunction($name, $callback, $arguments, $deterministic ? $flags : 0);
            else @$pdo->sqliteCreateFunction($name, $callback, $arguments, $deterministic ? $flags : 0);
        };
        // Keep naive framework timestamps in PHP's configured timezone on every backend.
        $register('current_timestamp', static fn(): string => (new DateTimeImmutable('now'))->format('Y-m-d H:i:s'), 0, false);
        $register('eelkit_char_length', static fn(?string $s): ?int => $s === null ? null : count(self::characters($s)), 1);
        $register('eelkit_ascii', static fn(?string $s): int => (int)($s === null || !preg_match('/[^\x00-\x7f]/', $s)), 1);
        $register('eelkit_valid_utf8', static fn(?string $s): int => (int)($s === null || preg_match('//u', $s) === 1), 1);
        // MySQL LIKE compares individual characters, unlike equality with expansions (ß = ss).
        $register('like', self::like(...), 2);
        $register('like', self::like(...), 3);
    }

    public static function compare(string $left, string $right): int
    {
        return strcmp(self::key(rtrim($left, ' ')), self::key(rtrim($right, ' ')));
    }

    public static function characters(string $value): array
    {
        $characters = preg_split('//u', $value, -1, PREG_SPLIT_NO_EMPTY);
        if ($characters === false) throw new RuntimeException('Invalid UTF-8 database text.');
        return $characters;
    }

    /** Fixed Unicode 4 primary weights: modern ICU changes ordering and uniqueness. */
    public static function key(string $value): string
    {
        if (self::$weights === null) {
            self::$weights = json_decode((string)file_get_contents(__DIR__ . '/unicode/uca4-primary.json'), true, flags: JSON_THROW_ON_ERROR);
        }
        $key = '';
        foreach (self::characters($value) as $character) {
            $code = IntlChar::ord($character);
            if ($code > 0xffff) { $key .= pack('n', 0xfffd); continue; }
            if (isset(self::$weights[$code])) { $key .= hex2bin(self::$weights[$code]); continue; }
            $base = ($code >= 0x4e00 && $code <= 0x9fa5) ? 0xfb40
                : (($code >= 0x3400 && $code <= 0x4db5) ? 0xfb80 : 0xfbc0);
            $key .= pack('nn', $base + ($code >> 15), ($code & 0x7fff) | 0x8000);
        }
        return $key;
    }

    public static function like(?string $pattern, ?string $value, string $escape = '\\'): ?int
    {
        if ($pattern === null || $value === null) return null;
        if (count(self::characters($escape)) !== 1) throw new RuntimeException('LIKE escape must be one character.');
        $tokens = [];
        $chars = self::characters($pattern);
        for ($i = 0; $i < count($chars); $i++) {
            $char = $chars[$i];
            if ($char === $escape && isset($chars[$i + 1])) $tokens[] = ['literal', self::key($chars[++$i])];
            elseif ($char === '%') { if (($tokens[count($tokens) - 1][0] ?? '') !== '%') $tokens[] = ['%', '']; }
            elseif ($char === '_') $tokens[] = ['_', ''];
            else $tokens[] = ['literal', self::key($char)];
        }
        // Iterative glob matching; bounded memory and no exponential recursion.
        $chars = self::characters($value);
        $i = $j = 0; $star = -1; $retry = 0;
        while ($i < count($chars)) {
            if (isset($tokens[$j]) && ($tokens[$j][0] === '_' || ($tokens[$j][0] === 'literal' && $tokens[$j][1] === self::key($chars[$i])))) { $i++; $j++; }
            elseif (($tokens[$j][0] ?? '') === '%') { $star = $j++; $retry = $i; }
            elseif ($star >= 0) { $j = $star + 1; $i = ++$retry; }
            else return 0;
        }
        while (($tokens[$j][0] ?? '') === '%') $j++;
        return (int)($j === count($tokens));
    }
}
