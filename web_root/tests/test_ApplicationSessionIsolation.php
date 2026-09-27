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
$harness->check(SessionAuthenticationService::class, 'isolates root, sibling and nested sessions in a shared PHP session store', function () use ($harness): void {
    $bootstrap = __DIR__ . '/testFramework/ServiceClassTestHarness.php';
    $script = 'require ' . var_export($bootstrap, true) . ';' . <<<'PHP'
    $directory = sys_get_temp_dir() . '/eelkit-session-' . bin2hex(random_bytes(8));
    mkdir($directory);
    session_save_path($directory);
    $config = AppConfigurationStore::config();
    $property = new ReflectionProperty(AppConfigurationStore::class, 'config');
    $open = static function (string $base, array $cookies = []) use ($config, $property): SessionAuthenticationService {
        if (session_status() === PHP_SESSION_ACTIVE) session_write_close();
        session_id('');
        $_SESSION = [];
        $_COOKIE = $cookies;
        $next = $config;
        $next['web']['base_path'] = $base;
        $property->setValue(null, $next);
        // CLI has no HTTP cookie parser; supply the ID that the web SAPI would select.
        $cookieName = ApplicationUrlFramework::scopedName('ELL_ID');
        if (isset($cookies[$cookieName])) session_id($cookies[$cookieName]);
        $service = new SessionAuthenticationService();
        $service->startSession();
        return $service;
    };
    $assert = static function (bool $condition, string $message): void {
        if (!$condition) throw new RuntimeException($message);
    };
    try {
        $sessions = [];
        foreach (['/', '/reports/', '/reports/child/', '/reports_old/'] as $base) {
            $service = $open($base);
            $assert(!isset($_SESSION['auth.user_id']), 'New app adopted authentication.');
            $_SESSION['auth.user_id'] = count($sessions) + 1;
            $_SESSION['auth.device_id'] = 'device-' . $base;
            $sessions[$base] = ['name' => session_name(), 'id' => session_id(), 'csrf' => $service->csrfToken(), 'user' => $_SESSION['auth.user_id']];
            $assert(session_get_cookie_params()['path'] === $base, 'Incorrect cookie path.');
        }
        $assert($sessions['/']['name'] === 'ELL_ID', 'Root session name changed.');
        $assert(count(array_unique(array_column($sessions, 'name'))) === 4, 'Cookie names collide.');
        $assert(count(array_unique(array_column($sessions, 'csrf'))) === 4, 'CSRF tokens shared.');
        foreach ($sessions as $base => $saved) {
            $cookies = array_combine(array_column($sessions, 'name'), array_column($sessions, 'id'));
            $service = $open($base, $cookies);
            $assert($_SESSION['auth.user_id'] === $saved['user'], 'Another app replaced authentication.');
            $assert($service->csrfToken() === $saved['csrf'], 'Session was not resumed.');
        }
        // A foreign ID under this application's cookie name must not adopt or delete its session.
        $root = $sessions['/'];
        $reports = $sessions['/reports/'];
        $open('/reports/', [$reports['name'] => $root['id']]);
        $assert(!isset($_SESSION['auth.user_id']), 'Foreign root session was adopted.');
        $open('/', [$root['name'] => $root['id']]);
        $assert($_SESSION['auth.user_id'] === $root['user'], 'Foreign session was destroyed.');
        // Existing unmarked root sessions survive the framework upgrade.
        unset($_SESSION['eelkit.application_scope']);
        $open('/', [$root['name'] => $root['id']]);
        $assert($_SESSION['auth.user_id'] === $root['user'], 'Legacy root session was lost.');
        unset($_SESSION['eelkit.application_scope']);
        $open('/reports/', [$reports['name'] => $root['id']]);
        $assert(!isset($_SESSION['auth.user_id']), 'Legacy session was adopted by a subpath.');
        $service = $open('/reports/', [$reports['name'] => $reports['id']]);
        $service->logout();
        $assert(!isset($_SESSION['auth.user_id']), 'Logout retained authentication.');
        $open('/', [$root['name'] => $root['id']]);
        $assert($_SESSION['auth.user_id'] === $root['user'], 'Logout affected the root app.');
        $property->setValue(null, array_replace_recursive($config, ['web' => ['base_path' => '//bad']]));
        try {
            (new SessionAuthenticationService())->startSession();
            throw new RuntimeException('Invalid base path accepted for an active session.');
        } catch (InvalidArgumentException) {}
        echo json_encode(['passed' => true]);
    } finally {
        if (session_status() === PHP_SESSION_ACTIVE) session_write_close();
        foreach (glob($directory . '/sess_*') ?: [] as $file) unlink($file);
        rmdir($directory);
    }
    PHP;
    $process = proc_open([PHP_BINARY, '-r', $script], [1 => ['pipe', 'w'], 2 => ['pipe', 'w']], $pipes, PROJECT_ROOT);
    if (!is_resource($process)) throw new RuntimeException('Unable to start isolated session test.');
    $output = stream_get_contents($pipes[1]);
    $errors = stream_get_contents($pipes[2]);
    fclose($pipes[1]);
    fclose($pipes[2]);
    $exit = proc_close($process);
    if ($exit !== 0 || $errors !== '') throw new RuntimeException('Session isolation failed: ' . $errors . $output);
    $harness->assertSame(['passed' => true], json_decode($output, true));
});
