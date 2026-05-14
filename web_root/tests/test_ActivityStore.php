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
$harness->run(ActivityStore::class, function (GeneratedServiceClassTestHarness $harness, object $instance): void {
    if (!$instance instanceof ActivityStore) {
        $harness->skip('Activity store did not instantiate.');
    }

    $normaliseFlashMessages = new ReflectionMethod(ActivityStore::class, 'normaliseFlashMessages');
    $normaliseFlashMessages->setAccessible(true);
    $requestMetadata = new ReflectionMethod(ActivityStore::class, 'requestMetadata');
    $requestMetadata->setAccessible(true);

    $harness->check(ActivityStore::class, 'normalises scalar, plain, and HTML flash messages', function () use ($harness, $instance, $normaliseFlashMessages): void {
        $messages = $normaliseFlashMessages->invoke($instance, [
            'Saved successfully.',
            [
                'type' => 'error',
                'message' => 'Unable to save.',
            ],
            [
                'type' => 'success',
                'message_html' => '<strong>Created</strong> &amp; queued',
            ],
            [
                'type' => 'ignored',
                'message' => '',
            ],
        ]);

        $harness->assertSame([
            [
                'type' => 'success',
                'text' => 'Saved successfully.',
                'html_text' => null,
            ],
            [
                'type' => 'error',
                'text' => 'Unable to save.',
                'html_text' => null,
            ],
            [
                'type' => 'success',
                'text' => 'Created & queued',
                'html_text' => 'Created & queued',
            ],
        ], $messages);
    });

    $harness->check(ActivityStore::class, 'captures bounded request metadata', function () use ($harness, $instance, $requestMetadata): void {
        $request = new RequestFramework(
            ['page' => 'dashboard'],
            [],
            [
                'REQUEST_METHOD' => 'POST',
                'REMOTE_ADDR' => '203.0.113.10',
                'REQUEST_URI' => '/?page=dashboard&action=save',
                'HTTP_USER_AGENT' => str_repeat('a', 1200),
            ],
            [],
            [],
        );

        $metadata = $requestMetadata->invoke($instance, $request);

        $harness->assertSame('203.0.113.10', $metadata['ip_address']);
        $harness->assertSame('/?page=dashboard&action=save', $metadata['request_uri']);
        $harness->assertSame(1000, mb_strlen((string)$metadata['user_agent']));
    });
});
