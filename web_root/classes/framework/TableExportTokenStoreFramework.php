<?php
/**
 * eelKit Framework
 * Copyright (c) 2026 James Elstone
 * Licensed under the BSD 3-Clause License
 * See LICENSE file for details.
 */
declare(strict_types=1);

final class TableExportTokenStoreFramework
{
    private const EXPORTS_KEY = 'table_export_tokens';
    private const FAILURES_KEY = 'table_export_token_failures';

    public function __construct(
        private readonly int $ttlSeconds = 60,
        private readonly int $maxPendingTokens = 3,
        private readonly int $failureWindowSeconds = 60,
        private readonly int $maxFailures = 8,
    ) {
    }

    public function create(
        int $userId,
        string $deviceId,
        array $facts,
        ?int $now = null
    ): string {
        $now = $now ?? time();
        $this->prune($now);

        $exports = $this->exports();
        while (count($exports) >= max(1, $this->maxPendingTokens)) {
            array_shift($exports);
        }

        $token = bin2hex(random_bytes(32));
        $exports[$token] = [
            'created_at' => $now,
            'expires_at' => $now + max(1, $this->ttlSeconds),
            'user_id' => max(0, $userId),
            'device_id' => trim($deviceId),
            'facts' => $facts,
        ];

        $_SESSION[self::EXPORTS_KEY] = $exports;

        return $token;
    }

    public function consume(string $token, int $userId, string $deviceId, ?int $now = null): ?array
    {
        $now = $now ?? time();
        $token = trim($token);
        $deviceId = trim($deviceId);
        $this->prune($now);

        if ($this->tooManyFailures($now)) {
            $this->recordFailure($now);
            return null;
        }

        $exports = $this->exports();
        $export = $exports[$token] ?? null;
        unset($exports[$token]);
        $_SESSION[self::EXPORTS_KEY] = $exports;

        if (!is_array($export)
            || (int)($export['expires_at'] ?? 0) < $now
            || max(0, $userId) !== (int)($export['user_id'] ?? 0)
            || $deviceId === ''
            || !hash_equals($deviceId, (string)($export['device_id'] ?? ''))
        ) {
            $this->recordFailure($now);
            return null;
        }

        $facts = $export['facts'] ?? null;
        if (!is_array($facts)) {
            $this->recordFailure($now);
            return null;
        }

        return $facts + [
            'created_at' => (int)($export['created_at'] ?? $now),
            'expires_at' => (int)($export['expires_at'] ?? $now),
        ];
    }

    public function prune(?int $now = null): void
    {
        $now = $now ?? time();
        $_SESSION[self::EXPORTS_KEY] = array_filter(
            $this->exports(),
            static fn(array $export): bool => (int)($export['expires_at'] ?? 0) >= $now
        );
        $_SESSION[self::FAILURES_KEY] = array_values(array_filter(
            $this->failures(),
            fn(int $failureAt): bool => $failureAt >= ($now - max(1, $this->failureWindowSeconds))
        ));
    }

    public function pendingCount(): int
    {
        return count($this->exports());
    }

    public function failureCount(?int $now = null): int
    {
        $this->prune($now);

        return count($this->failures());
    }

    public function tooManyFailures(?int $now = null): bool
    {
        $this->prune($now);

        return count($this->failures()) >= max(1, $this->maxFailures);
    }

    private function recordFailure(int $now): void
    {
        $failures = $this->failures();
        $failures[] = $now;
        $_SESSION[self::FAILURES_KEY] = $failures;
    }

    private function exports(): array
    {
        $exports = $_SESSION[self::EXPORTS_KEY] ?? [];

        return is_array($exports) ? $exports : [];
    }

    private function failures(): array
    {
        $failures = $_SESSION[self::FAILURES_KEY] ?? [];

        if (!is_array($failures)) {
            return [];
        }

        return array_values(array_map('intval', $failures));
    }
}
