<?php
/**
 * eelKit Framework
 * Copyright (c) 2026 James Elstone
 * Licensed under the BSD 3-Clause License
 * See LICENSE file for details.
 */
declare(strict_types=1);

/** Public URL paths only; filesystem locations continue to use APP_ROOT and APP_CONFIG. */
final class ApplicationUrlFramework
{
    public static function basePath(): string
    {
        return self::normaliseBasePath(AppConfigurationStore::get('web.base_path', '/'));
    }

    public static function normaliseBasePath(mixed $path): string
    {
        if (!is_string($path)) {
            throw new InvalidArgumentException('web.base_path must be a local URL path such as / or /reports/.');
        }
        if ($path === '' || $path === '/') {
            return '/';
        }
        if (!preg_match('#^/(?:[A-Za-z0-9._~-]+/)*[A-Za-z0-9._~-]+/?$#D', $path)) {
            throw new InvalidArgumentException('web.base_path must be a local URL path with safe, non-empty path segments.');
        }
        foreach (explode('/', trim($path, '/')) as $segment) {
            if ($segment === '.' || $segment === '..') {
                throw new InvalidArgumentException('web.base_path must not contain traversal segments.');
            }
        }
        return rtrim($path, '/') . '/';
    }

    /** Build an application-owned URL; do not use this to rewrite configured external links. */
    public static function path(string $path = '', array $query = [], string $fragment = ''): string
    {
        $base = self::basePath();
        $path = self::safePath($path);
        if ($base !== '/' && ($path === rtrim($base, '/') || str_starts_with($path, $base))) {
            $url = $path === rtrim($base, '/') ? $base : $path;
        } else {
            $url = $base . ltrim($path, '/');
        }
        return $url . ($query !== [] ? '?' . http_build_query($query) : '')
            . ($fragment !== '' ? '#' . rawurlencode($fragment) : '');
    }

    public static function page(string $page, array $query = [], string $fragment = ''): string
    {
        return self::path('', ['page' => $page] + $query, $fragment);
    }

    public static function asset(string $path): string
    {
        return self::path($path);
    }

    /** Empty for root installations to preserve existing cookies and localStorage keys. */
    public static function scopeKey(): string
    {
        $base = self::basePath();
        return $base === '/' ? '' : substr(hash('sha256', $base), 0, 24);
    }

    public static function scopedName(string $legacyName): string
    {
        $scope = self::scopeKey();
        return $legacyName . ($scope === '' ? '' : '_' . $scope);
    }

    /** Absolute application base without a trailing slash, preserving the invitation API. */
    public static function publicBaseUrl(RequestFramework $request): string
    {
        $override = (string)AppConfigurationStore::get('invitation.base_url_override', '');
        if ($override !== '') {
            return self::normalisePublicBaseUrl($override);
        }
        $proxy = new ReverseProxyService();
        $scheme = $proxy->forwardedScheme($request);
        if ($scheme === '') {
            $scheme = $request->isSecure() ? 'https' : 'http';
        }
        $host = $proxy->forwardedHost($request);
        if ($host === '') {
            $host = trim((string)$request->header('Host', ''));
        }
        if (preg_match('/[\s\/\\\\@?#]/', $host)) {
            throw new InvalidArgumentException('Request host must contain only a hostname and optional port.');
        }
        return $host === '' ? '' : self::normalisePublicBaseUrl($scheme . '://' . $host);
    }

    public static function normalisePublicBaseUrl(string $url): string
    {
        if (preg_match('/[\x00-\x1f\x7f]/', $url)) {
            throw new InvalidArgumentException('External base URL must not contain control characters.');
        }
        $url = trim($url);
        $parts = parse_url($url);
        if ($parts === false || !in_array(strtolower((string)($parts['scheme'] ?? '')), ['http', 'https'], true)
            || empty($parts['host']) || filter_var($url, FILTER_VALIDATE_URL) === false
            || preg_match('/[\x00-\x20\x7f\\\\]/', $url)
            || isset($parts['user']) || isset($parts['pass']) || isset($parts['query']) || isset($parts['fragment'])) {
            throw new InvalidArgumentException('External base URL must be an HTTP(S) URL without credentials, a query, or a fragment.');
        }
        $path = rtrim(self::safePath((string)($parts['path'] ?? '/')), '/') . '/';
        $base = self::basePath();
        if ($base !== '/' && $path !== '/' && $path !== $base) {
            throw new InvalidArgumentException('External base URL path must match web.base_path (' . $base . ').');
        }
        $origin = strtolower($parts['scheme']) . '://' . $parts['host']
            . (isset($parts['port']) ? ':' . $parts['port'] : '');
        return $origin . rtrim($base === '/' ? $path : $base, '/');
    }

    public static function absolute(RequestFramework $request, string $path = '', array $query = [], string $fragment = ''): string
    {
        $publicBase = self::publicBaseUrl($request);
        if ($publicBase === '') {
            throw new InvalidArgumentException('Application base URL could not be resolved.');
        }
        $local = self::path($path, $query, $fragment);
        return $publicBase . '/' . substr($local, strlen(self::basePath()));
    }

    private static function safePath(string $path): string
    {
        if (str_starts_with($path, '//') || preg_match('/[\x00-\x1f\x7f\\\\?#:]/', $path)
            || preg_match('/%(?![0-9a-f]{2})/i', $path)) {
            throw new InvalidArgumentException('Expected a safe application-local path; pass queries and fragments separately.');
        }
        $segments = explode('/', $path);
        foreach ($segments as &$segment) {
            $segment = rawurldecode($segment);
            if ($segment === '.' || $segment === '..' || preg_match('/[\x00-\x1f\x7f\\\\\/?#:%]/', $segment)) {
                throw new InvalidArgumentException('Application paths must not contain traversal or encoded separators.');
            }
            $segment = rawurlencode($segment);
        }
        unset($segment);
        $path = implode('/', $segments);
        if (str_contains($path, '//')) {
            throw new InvalidArgumentException('Application paths must not contain empty interior segments.');
        }
        return $path;
    }
}
