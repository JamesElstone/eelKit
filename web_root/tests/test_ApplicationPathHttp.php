<?php
/**
 * eelKit Framework
 * Copyright (c) 2026 James Elstone
 * Licensed under the BSD 3-Clause License
 * See LICENSE file for details.
 */
declare(strict_types=1);
require_once __DIR__ . '/testFramework/ServiceClassTestHarness.php';

$harness = new GeneratedServiceClassTestHarness();
$harness->check('ApplicationPathHttp', 'serves real entrypoints at root and subpaths with isolated authentication and signup', function () use ($harness): void {
    if (PHP_SAPI !== 'cli' || !function_exists('proc_open') || !extension_loaded('curl') || !extension_loaded('pdo_sqlite')) {
        $harness->skip('HTTP fixture requires CLI, proc_open, curl and PDO SQLite.', 'environment');
    }
    $temporary = sys_get_temp_dir() . '/eelkit-http-' . bin2hex(random_bytes(8));
    mkdir($temporary);
    $copyTree = static function (string $source, string $target) use (&$copyTree): void {
        mkdir($target, 0777, true);
        foreach (new DirectoryIterator($source) as $entry) {
            if ($entry->isDot() || $entry->getFilename() === 'tests' || $entry->getFilename() === 'tryit') continue;
            $destination = $target . '/' . $entry->getFilename();
            if ($entry->isDir()) $copyTree($entry->getPathname(), $destination);
            else copy($entry->getPathname(), $destination);
        }
    };
    $removeTree = static function (string $directory) use (&$removeTree, $temporary): void {
        $resolved = str_replace('\\', '/', (string)realpath($directory));
        $allowed = str_replace('\\', '/', (string)realpath($temporary));
        if ($resolved !== $allowed && !str_starts_with($resolved, $allowed . '/')) {
            throw new RuntimeException('Refusing to remove a path outside the HTTP fixture.');
        }
        foreach (new DirectoryIterator($directory) as $entry) {
            if ($entry->isDot()) continue;
            if ($entry->isDir() && !$entry->isLink()) $removeTree($entry->getPathname());
            else unlink($entry->getPathname());
        }
        rmdir($directory);
    };
    $listener = stream_socket_server('tcp://127.0.0.1:0', $error, $message);
    if ($listener === false) throw new RuntimeException('Unable to reserve a local test port: ' . $message);
    $address = stream_socket_get_name($listener, false);
    fclose($listener);
    $origin = 'http://' . $address;
    $fixture = __DIR__ . '/testFramework/ApplicationPathHttpFixture.php';
    $server = null;
    $cookies = [];
    $send = static function (string $path, ?array $post = null) use ($origin, &$cookies): array {
        $curl = curl_init($origin . $path);
        $headers = [];
        $cookieValues = [];
        foreach ($cookies as $name => $cookie) {
            if (str_starts_with($path, $cookie['path'])) $cookieValues[] = $name . '=' . $cookie['value'];
        }
        curl_setopt_array($curl, [CURLOPT_RETURNTRANSFER => true, CURLOPT_TIMEOUT => 20, CURLOPT_COOKIE => implode('; ', $cookieValues), CURLOPT_HEADERFUNCTION => static function ($curl, string $line) use (&$headers, &$cookies): int {
            if (str_contains($line, ':')) {
                [$key, $value] = explode(':', $line, 2);
                $headers[strtolower($key)] = trim($value);
                if (strtolower($key) === 'set-cookie' && preg_match('/^([^=]+)=([^;]*);.*?path=([^;]*)/i', trim($value), $match)) {
                    $cookies[$match[1]] = ['value' => $match[2], 'path' => $match[3]];
                }
            }
            return strlen($line);
        }]);
        if ($post !== null) curl_setopt_array($curl, [CURLOPT_POST => true, CURLOPT_POSTFIELDS => http_build_query($post)]);
        $body = curl_exec($curl);
        $status = curl_getinfo($curl, CURLINFO_RESPONSE_CODE);
        if ($body === false) throw new RuntimeException(curl_error($curl));
        return ['status' => $status, 'headers' => $headers, 'body' => $body];
    };
    $csrf = static function (string $html): string {
        if (!preg_match('/name="csrf_token" value="([^"]+)"/', $html, $matches)) throw new RuntimeException('Missing CSRF token in HTTP response: ' . substr($html, 0, 600));
        return $matches[1];
    };
    try {
        $mounts = [];
        $invitations = [];
        foreach (['/' => 'omitted', '/reports/' => '/reports', '/internal/reports/' => '/internal/reports/', '/reports/child/' => '/reports/child/'] as $base => $configured) {
            $directory = $temporary . '/app-' . count($mounts);
            $copyTree(APP_ROOT, $directory . '/web_root');
            $copyTree(PROJECT_ROOT . 'db_schema', $directory . '/db_schema');
            mkdir($directory . '/secure');
            mkdir($directory . '/file_logs');
            file_put_contents($directory . '/web_root/css/project.css', '/* project stylesheet fixture */');
            file_put_contents($directory . '/web_root/js/project.js', '/* project script fixture */');
            $seed = proc_open([PHP_BINARY, $fixture, 'seed', $directory, $configured, $origin], [1 => ['pipe', 'w'], 2 => ['pipe', 'w']], $pipes);
            $output = stream_get_contents($pipes[1]); $errors = stream_get_contents($pipes[2]);
            fclose($pipes[1]); fclose($pipes[2]);
            if (proc_close($seed) !== 0 || $errors !== '') throw new RuntimeException('HTTP fixture seed failed: ' . $errors . $output);
            $invitations[$base] = json_decode($output, true, flags: JSON_THROW_ON_ERROR);
            $mounts[$base] = $directory;
        }
        mkdir($temporary . '/sessions');
        $environment = getenv();
        $mountsFile = $temporary . '/mounts.json';
        file_put_contents($mountsFile, json_encode($mounts));
        $environment['EEL_HTTP_FIXTURE_MOUNTS_FILE'] = $mountsFile;
        $server = proc_open([PHP_BINARY, '-d', 'session.save_path=' . $temporary . '/sessions', '-S', $address, $fixture], [0 => ['pipe', 'r'], 1 => ['file', $temporary . '/server.log', 'a'], 2 => ['file', $temporary . '/server.log', 'a']], $pipes, $temporary, $environment);
        if (!is_resource($server)) throw new RuntimeException('Unable to start PHP HTTP fixture.');
        fclose($pipes[0]);
        $connected = false;
        for ($i = 0; $i < 100; $i++) {
            $socket = @stream_socket_client('tcp://' . $address, $error, $message, 0.1);
            if ($socket !== false) { fclose($socket); $connected = true; break; }
            usleep(50000);
        }
        if (!$connected) throw new RuntimeException('PHP HTTP fixture failed to listen.');
        $tokens = [];
        foreach ($mounts as $base => $directory) {
            $response = $send($base . '?page=users&filter=a%26b');
            $harness->assertSame(200, $response['status']);
            $token = $csrf($response['body']);
            foreach (['css/auth.css', 'js/index.js', 'css/project.css', 'js/project.js', 'favicon.ico'] as $asset) {
                $harness->assertTrue(str_contains($response['body'], '"' . $base . $asset . '"'));
                $harness->assertSame(200, $send($base . $asset)['status']);
            }
            $scope = $base === '/' ? '' : '_' . substr(hash('sha256', $base), 0, 24);
            $cookies['af_client_device_id' . $scope] = ['value' => 'device' . $scope, 'path' => $base];
            $login = $send($base, ['auth_action' => 'login', 'csrf_token' => $token, 'email_address' => 'tester@example.test', 'password' => 'HTTP Test Password 123!']);
            $harness->assertSame(302, $login['status']);
            $harness->assertSame($base, $login['headers']['location']);
            $home = $send($base . '?page=users');
            $harness->assertTrue(str_contains($home['body'], 'value="logout"'));
            $tokens[$base] = $csrf($home['body']);
            $harness->assertTrue(str_contains($home['body'], $base . '?page=users'));
            $harness->assertSame($base, $cookies['ELL_ID' . $scope]['path']);
            $demo = $send($base . '?page=test&filter=a%26b');
            if (!preg_match('/data-nonce-payload="([^"]+)"/', $demo['body'], $nonceMatch)) throw new RuntimeException('Missing AJAX security bootstrap.');
            $nonces = json_decode(html_entity_decode($nonceMatch[1], ENT_QUOTES | ENT_HTML5), true)['nonce_pool'];
            $ajax = $send($base . '?page=test&filter=a%26b', ['_ajax' => '1', 'action' => 'set-test-context', 'preset' => 'beta', 'note' => 'query & symbols', 'cards' => ['test_source', 'test_target'], 'csrf_token' => $tokens[$base], 'ajax_nonce' => $nonces[0]]);
            $payload = json_decode($ajax['body'], true, flags: JSON_THROW_ON_ERROR);
            $harness->assertSame(200, $ajax['status']);
            $harness->assertSame(true, $payload['success']);
            $harness->assertTrue(str_contains(json_encode($payload['cards']), 'Beta handoff'));
            $harness->assertTrue(str_contains($payload['url'], 'filter=a%26b'));
            $harness->assertTrue(str_starts_with($payload['url'], $base === '/' ? '?' : $base . '?'));
            $harness->assertTrue(is_string($payload['ajax_nonce']) && $payload['ajax_nonce'] !== $nonces[0]);
            $refresh = $send($base . '?page=test', ['_ajax' => '1', '_card_refresh' => '1', 'cards' => ['test_target']]);
            $harness->assertSame(200, $refresh['status']);
            $harness->assertTrue(!empty(json_decode($refresh['body'], true)['cards']));
            $filter = $send($base . '?page=test&_ajax=1&_pagination=1&_invalidate_fact=test.context&preset=gamma&cards%5B%5D=test_target');
            $harness->assertTrue(str_contains(json_encode(json_decode($filter['body'], true)['cards']), 'Gamma handoff'));
            $export = $send($base . '?page=test', ['_ajax' => '1', '_table_export_prepare' => 'csv', 'table_key' => 'test_table_export_demo', 'cards' => ['table_export_demo'], 'csrf_token' => $tokens[$base], 'ajax_nonce' => $payload['ajax_nonce']]);
            $downloadUrl = json_decode($export['body'], true, flags: JSON_THROW_ON_ERROR)['download_url'];
            $harness->assertTrue(str_starts_with($downloadUrl, $base === '/' ? '?' : $base . '?'));
            $download = $send(str_starts_with($downloadUrl, '?') ? $base . $downloadUrl : $downloadUrl);
            $harness->assertSame(200, $download['status']);
            $harness->assertTrue(str_contains($download['headers']['content-disposition'], '.csv'));
            $invite = $invitations[$base];
            foreach ($invite as $link) $harness->assertTrue(str_starts_with($link, $origin . $base . 'signup/?token='));
            $signup = $send(substr($invite['link'], strlen($origin)));
            $harness->assertTrue(str_contains($signup['body'], 'Verify your details'));
            $verify = $send($base . 'signup/index.php', ['signup_action' => 'verify_identity', 'csrf_token' => $csrf($signup['body']), 'email_address' => 'invite@example.test']);
            $harness->assertTrue(str_contains($verify['body'], 'Set up your account'));
            $complete = $send($base . 'signup/index.php', ['signup_action' => 'complete_account', 'csrf_token' => $csrf($verify['body']), 'display_name' => 'Invite Tester', 'email_address' => 'invite@example.test', 'mobile_country_code' => '+44', 'mobile_number' => '07700900123', 'password' => 'Completed Password 123!', 'password_confirm' => 'Completed Password 123!']);
            $harness->assertSame(302, $complete['status']);
            $harness->assertSame($base . 'index.php', $complete['headers']['location']);
        }
        $harness->assertSame(4, count(array_unique(array_values($tokens))));
        $logout = $send('/reports/', ['auth_action' => 'logout', 'csrf_token' => $tokens['/reports/']]);
        $harness->assertTrue(str_contains($logout['body'], 'value="login"'));
        foreach (['/', '/reports/child/', '/internal/reports/'] as $base) {
            $harness->assertTrue(str_contains($send($base)['body'], 'value="logout"'));
        }
        $redirect = $send('/reports?page=users&filter=a%26b');
        $harness->assertSame(308, $redirect['status']);
        $harness->assertSame('/reports/?page=users&filter=a%26b', $redirect['headers']['location']);
        // An explicit root configuration must continue the session created with the setting omitted.
        $rootConfig = require $mounts['/'] . '/secure/app.php';
        $rootConfig['web']['base_path'] = '/';
        file_put_contents($mounts['/'] . '/secure/app.php', '<?php return ' . var_export($rootConfig, true) . ';');
        $harness->assertTrue(str_contains($send('/')['body'], 'value="logout"'));
        // Replace the root fixture with a company site, retaining the same application mounts.
        unset($mounts['/']);
        file_put_contents($mountsFile, json_encode($mounts));
        $harness->assertTrue(str_contains($send('/')['body'], 'Company website'));
        $harness->assertTrue(str_contains($send('/reports_old/')['body'], 'Company website'));
        $harness->assertTrue(str_contains($send('/reports/')['body'], 'value="login"'));
    } finally {
        if (is_resource($server)) { proc_terminate($server); proc_close($server); }
        $removeTree($temporary);
    }
});
