<?php
/** Dedicated subprocess for real file-backed SQLite concurrency tests. */
declare(strict_types=1);
if (PHP_SAPI !== 'cli') { http_response_code(403); return; }
require_once __DIR__ . '/TestBootstrap.php';
$pdo = new PDO('sqlite:' . $argv[1], null, null, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION, PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC]);
SqliteDB::configure($pdo, ['sqlite_busy_timeout_ms' => ($argv[2] ?? '') === 'timeout' ? 50 : 5000]);
(new ReflectionProperty(InterfaceDB::class, 'connection'))->setValue(null, $pdo);
InterfaceDB::clearMetadataCache();
if (($argv[2] ?? '') === 'complete') {
    $session = new AccountCompletionSessionService();
    $session->begin((int)$argv[3], (int)$argv[4]); $session->markVerified();
    $service = new AccountCompletionService(new AccountInviteService(), new UserAuthenticationService($argv[1] . '.keys', ['memory_cost' => 1024, 'time_cost' => 1, 'threads' => 1]));
    $result = $service->completeAccount($session, 'Completed once', 'once@example.test', '+44', '07700 900123', 'New Strong Password 1!', 'New Strong Password 1!');
    echo (int)!empty($result['success']);
    if (session_status() === PHP_SESSION_ACTIVE) session_destroy();
    exit(0);
}
if (($argv[2] ?? '') === 'timeout') {
    try { InterfaceDB::writeTransaction(static fn() => InterfaceDB::execute("INSERT INTO roles (display_name) VALUES ('locked')")); }
    catch (PDOException $exception) { if (($exception->errorInfo[1] ?? null) === 5) { echo 'busy'; exit(0); } throw $exception; }
    exit(1);
}
$request = new RequestFramework([], [], ['REMOTE_ADDR' => '203.0.113.231'], [], []);
$service = new SignupTokenRateLimitService();
for ($i = 0; $i < 3; $i++) $service->recordFailedToken($request);
InterfaceDB::writeTransaction(static function (): void {
    InterfaceDB::execute("INSERT INTO users (display_name,email_address,password_hash) VALUES ('Concurrent',:email,'hash')", ['email' => 'worker-' . getmypid() . '@example.test']);
    echo InterfaceDB::lastInsertId();
});
