<?php
/**
 * eelKit Framework
 * Copyright (c) 2026 James Elstone
 * Licensed under the BSD 3-Clause License
 * See LICENSE file for details.
 */
declare(strict_types=1);

require_once __DIR__ . DIRECTORY_SEPARATOR . 'testFramework' . DIRECTORY_SEPARATOR . 'ServiceClassTestHarness.php';

$harness = new GeneratedServiceClassTestHarness();

$resetTableExportSession = static function (): void {
    $_SESSION['table_export_tokens'] = [];
    $_SESSION['table_export_token_failures'] = [];
};

$harness->check(TableExportTokenStoreFramework::class, 'creates and consumes one-time export tokens', function () use ($harness, $resetTableExportSession): void {
    $resetTableExportSession();
    $store = new TableExportTokenStoreFramework(ttlSeconds: 60, maxPendingTokens: 3);
    $token = $store->create(12, 'device-a', [
        'table_key' => 'demo',
        'format' => 'csv',
        'query' => ['page' => 'test'],
        'post' => ['status' => 'active'],
    ], 1000);

    $export = $store->consume($token, 12, 'device-a', 1001);
    $harness->assertTrue(is_array($export));
    $harness->assertSame('demo', $export['table_key']);
    $harness->assertSame('active', $export['post']['status']);
    $harness->assertSame(null, $store->consume($token, 12, 'device-a', 1002));
});

$harness->check(TableExportTokenStoreFramework::class, 'rejects expired or differently bound tokens', function () use ($harness, $resetTableExportSession): void {
    $resetTableExportSession();
    $store = new TableExportTokenStoreFramework(ttlSeconds: 5, maxPendingTokens: 3);
    $facts = ['table_key' => 'demo', 'format' => 'csv'];
    $expired = $store->create(12, 'device-a', $facts, 1000);
    $wrongDevice = $store->create(12, 'device-a', $facts, 1000);
    $wrongUser = $store->create(12, 'device-a', $facts, 1000);

    $harness->assertSame(null, $store->consume($expired, 12, 'device-a', 1006));
    $harness->assertSame(null, $store->consume($wrongDevice, 12, 'device-b', 1001));
    $harness->assertSame(null, $store->consume($wrongUser, 13, 'device-a', 1001));
});

$harness->check(TableExportTokenStoreFramework::class, 'caps pending tokens and throttles failed attempts', function () use ($harness, $resetTableExportSession): void {
    $resetTableExportSession();
    $store = new TableExportTokenStoreFramework(ttlSeconds: 60, maxPendingTokens: 2, failureWindowSeconds: 60, maxFailures: 2);
    $first = $store->create(12, 'device-a', ['table_key' => 'first', 'format' => 'csv'], 1000);
    $second = $store->create(12, 'device-a', ['table_key' => 'second', 'format' => 'csv'], 1001);
    $third = $store->create(12, 'device-a', ['table_key' => 'third', 'format' => 'csv'], 1002);

    $harness->assertSame(2, $store->pendingCount());
    $harness->assertSame(null, $store->consume($first, 12, 'device-a', 1003));
    $harness->assertTrue(is_array($store->consume($second, 12, 'device-a', 1004)));
    $harness->assertTrue(is_array($store->consume($third, 12, 'device-a', 1005)));

    $resetTableExportSession();
    $store = new TableExportTokenStoreFramework(ttlSeconds: 60, maxPendingTokens: 2, failureWindowSeconds: 60, maxFailures: 2);
    $harness->assertSame(null, $store->consume('missing-a', 12, 'device-a', 1000));
    $harness->assertSame(null, $store->consume('missing-b', 12, 'device-a', 1001));
    $harness->assertTrue($store->tooManyFailures(1002));
});
