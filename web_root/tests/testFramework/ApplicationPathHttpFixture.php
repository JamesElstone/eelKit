<?php
/**
 * eelKit Framework
 * Copyright (c) 2026 James Elstone
 * Licensed under the BSD 3-Clause License
 * See LICENSE file for details.
 */
/** Local HTTP fixture runner; never uses production configuration or credentials. */
declare(strict_types=1);

if (PHP_SAPI === 'cli' && ($argv[1] ?? '') === 'seed') {
    [$script, $command, $directory, $configuredBase, $origin] = $argv;
    $config = [
        'app_name' => 'HTTP path fixture', 'developer_options' => true,
        'db' => ['dsn' => 'sqlite:' . $directory . '/secure/test.sqlite', 'sqlite_schema' => '../db_schema/eelKit.schema.sql'],
        'session' => ['cookie_secure' => false],
        'smtp' => ['enabled' => true, 'development_mode' => true],
        'sms' => ['enabled' => true, 'development_mode' => true],
        'user_defaults' => ['new_user_otp_required' => false],
    ];
    if ($configuredBase !== 'omitted') $config['web']['base_path'] = $configuredBase;
    file_put_contents($directory . '/secure/app.php', '<?php return ' . var_export($config, true) . ';');
    require $directory . '/web_root/classes/bootstrap.php';
    $auth = new UserAuthenticationService();
    $user = $auth->createUser('Path Tester', 'tester@example.test', 'HTTP Test Password 123!', true, '', false);
    if (empty($user['success'])) throw new RuntimeException(json_encode($user));
    InterfaceDB::prepareExecute('UPDATE users SET role_id = :role WHERE id = :id', ['role' => RoleAssignmentService::ADMIN_ROLE_ID, 'id' => $user['user_id']]);
    InterfaceDB::prepareExecute("INSERT INTO users (display_name,email_address,mobile_number,password_hash,is_active,account_status,role_id,otp_required) VALUES ('Invite Tester','invite@example.test','+447700900123',NULL,0,'pending_invitation',:role,0)", ['role' => RoleAssignmentService::ADMIN_ROLE_ID]);
    $id = (int)InterfaceDB::fetchColumn('SELECT MAX(id) FROM users');
    $service = new AccountInviteService();
    $invite = $service->createInviteLink((int)$user['user_id'], $id, 'email', $origin);
    $email = $service->sendEmailInvite((int)$user['user_id'], $id, $origin);
    $sms = $service->sendSmsInvite((int)$user['user_id'], $id, $origin);
    foreach ([$invite, $email, $sms] as $delivery) {
        if (empty($delivery['success'])) throw new RuntimeException(json_encode($delivery));
    }
    // The existing SQLite schema fixture recreates tables; seed it once, not on each HTTP request.
    unset($config['db']['sqlite_schema']);
    file_put_contents($directory . '/secure/app.php', '<?php return ' . var_export($config, true) . ';');
    echo json_encode(['link' => $invite['link'], 'email' => $email['link'], 'sms' => $sms['link']]);
    return;
}

if (PHP_SAPI !== 'cli-server') return;
$mounts = json_decode(file_get_contents((string)getenv('EEL_HTTP_FIXTURE_MOUNTS_FILE')), true, flags: JSON_THROW_ON_ERROR);
uksort($mounts, static fn(string $a, string $b): int => strlen($b) <=> strlen($a));
$path = (string)parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
foreach ($mounts as $base => $directory) {
    if ($base !== '/' && $path === rtrim($base, '/')) {
        $query = (string)parse_url($_SERVER['REQUEST_URI'], PHP_URL_QUERY);
        header('Location: ' . $base . ($query !== '' ? '?' . $query : ''), true, 308);
        return;
    }
    if (!str_starts_with($path, $base)) continue;
    $relative = rawurldecode(substr($path, strlen($base)));
    if (str_contains($relative, '..') || str_contains($relative, '\\') || preg_match('#^(classes|content|tests)(/|$)#', $relative)) {
        http_response_code(403); return;
    }
    $file = $directory . '/web_root/' . $relative;
    if (is_dir($file)) $file = rtrim($file, '/') . '/index.php';
    if (!is_file($file)) { http_response_code(404); return; }
    if (str_ends_with($file, '.php')) {
        chdir($directory . '/web_root');
        $_SERVER['SCRIPT_FILENAME'] = $file;
        require $file;
    } else {
        $types = ['css' => 'text/css', 'js' => 'application/javascript', 'svg' => 'image/svg+xml', 'ttf' => 'font/ttf', 'ico' => 'image/x-icon'];
        header('Content-Type: ' . ($types[pathinfo($file, PATHINFO_EXTENSION)] ?? 'application/octet-stream'));
        readfile($file);
    }
    return;
}
header('Content-Type: text/html');
echo '<!doctype html><h1>Company website</h1>';
