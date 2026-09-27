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
$withUrlConfig = static function (array $changes, callable $test): void {
    $original = AppConfigurationStore::config();
    $property = new ReflectionProperty(AppConfigurationStore::class, 'config');
    $property->setValue(null, array_replace_recursive($original, $changes));
    $session = $_SESSION ?? [];
    try {
        $test();
    } finally {
        $property->setValue(null, $original);
        $_SESSION = $session;
    }
};

$harness->check(ApplicationUrlFramework::class, 'defaults an existing configuration without web settings to root', function () use ($harness): void {
    $property = new ReflectionProperty(AppConfigurationStore::class, 'config');
    $original = AppConfigurationStore::config();
    $legacy = $original;
    unset($legacy['web']);
    try {
        $property->setValue(null, $legacy);
        $harness->assertSame('/', ApplicationUrlFramework::basePath());
        $harness->assertSame('ELL_ID', ApplicationUrlFramework::scopedName('ELL_ID'));
        $harness->assertSame('/?page=users', ApplicationUrlFramework::page('users'));
    } finally {
        $property->setValue(null, $original);
    }
});

$harness->check(ApplicationUrlFramework::class, 'normalises local deployment paths and rejects ambiguous values', function () use ($harness): void {
    foreach (['' => '/', '/' => '/', '/reports' => '/reports/', '/reports/' => '/reports/', '/internal/reports' => '/internal/reports/', '/A_1-~.x/' => '/A_1-~.x/'] as $input => $expected) {
        $harness->assertSame($expected, ApplicationUrlFramework::normaliseBasePath($input));
    }
    foreach (['reports', '//example.test/reports', 'https://example.test', '/a//b', '/a/../b', '/./', '/%2e%2e/', '/a%2fb/', '/a%252fb/', '/a\\b', '/a?b', '/a#b', '/a b', "/a\n", null, []] as $input) {
        try {
            ApplicationUrlFramework::normaliseBasePath($input);
            throw new RuntimeException('Accepted unsafe path: ' . json_encode($input));
        } catch (InvalidArgumentException) {
        }
    }
});

foreach (['/', '/reports', '/reports/', '/internal/reports/'] as $configuredPath) {
    $harness->check(ApplicationUrlFramework::class, 'builds navigation, assets, forms and request URLs at ' . $configuredPath, function () use ($harness, $withUrlConfig, $configuredPath): void {
        $withUrlConfig(['web' => ['base_path' => $configuredPath]], function () use ($harness, $configuredPath): void {
            $base = ApplicationUrlFramework::normaliseBasePath($configuredPath);
            $asset = ApplicationUrlFramework::asset('svg/Some Icon.svg');
            $harness->assertSame($base . 'svg/Some%20Icon.svg', $asset);
            $harness->assertSame($asset, ApplicationUrlFramework::asset($asset));
            $harness->assertSame($base . '?page=users&filter=a%26b#some%20card', ApplicationUrlFramework::page('users', ['filter' => 'a&b'], 'some card'));
            $harness->assertSame($base . 'reports_old/', ApplicationUrlFramework::path('/reports_old/'));
            $request = new RequestFramework(['page' => 'users', 'filter' => 'a&b', 'remove' => 'yes'], [], [], [], []);
            $harness->assertSame(($base === '/' ? '' : $base) . '?page=users&filter=a%26b&sort=name', $request->pageUrl(['remove' => null, 'sort' => 'name']));
            $items = (new NavigationFramework(APP_PAGES, 'users'))->build();
            $harness->assertTrue($items !== []);
            foreach ($items as $item) {
                $harness->assertTrue(str_starts_with($item['url'], $base . '?page='));
                if ($item['icon_path'] !== null) $harness->assertTrue(str_starts_with($item['icon_path'], $base));
            }
            $custom = (new NavigationFramework(APP_PAGES, 'users', '/reports_old/?page='))->build();
            $harness->assertTrue(str_starts_with($custom[0]['url'], '/reports_old/?page='));
            $session = new SessionAuthenticationService();
            $auth = (new AuthPageRenderer('Test', 'Test'))->loginPage($session);
            $signup = (new SignupPageRenderer('Test', 'Test'))->verificationPage($session);
            foreach ([$auth, $signup] as $html) {
                foreach (['css/auth.css', 'js/index.js', 'favicon.ico'] as $path) {
                    $harness->assertTrue(str_contains($html, '"' . $base . $path . '"'));
                }
                $harness->assertTrue(str_contains($html, 'data-eel-base-path="' . $base . '"'));
            }
            $harness->assertTrue(str_contains($auth, 'action="' . $base . '"'));
            $harness->assertTrue(str_contains($signup, 'action="' . $base . 'signup/index.php"'));
            $html = (new _web_environmentCard())->render([]);
            $harness->assertTrue(str_contains($html, 'action="' . $base . '?page=settings"'));
            $harness->assertTrue(str_contains($html, '<code>' . $base . '</code>'));
            $formAction = new ReflectionMethod(SiteContextRendererFramework::class, 'formAction');
            $harness->assertSame($base . '?page=dashboard', $formAction->invoke(new SiteContextRendererFramework(), $request, new _dashboard()));
        });
    });
}

$harness->check(ApplicationUrlFramework::class, 'public URLs contain the application path exactly once', function () use ($harness, $withUrlConfig): void {
    foreach (['/', '/reports/', '/internal/reports/'] as $base) {
        $withUrlConfig(['web' => ['base_path' => $base], 'invitation' => ['base_url_override' => ''], 'reverse_proxy' => ['trusted_proxy_ips' => ['198.51.100.1']]], function () use ($harness, $base): void {
            foreach (['https://example.test', 'https://example.test' . $base] as $url) {
                $harness->assertSame('https://example.test' . rtrim($base, '/'), ApplicationUrlFramework::normalisePublicBaseUrl($url));
            }
            $request = new RequestFramework([], [], ['REMOTE_ADDR' => '198.51.100.1', 'HTTP_HOST' => 'internal.test', 'HTTP_X_FORWARDED_PROTO' => 'https', 'HTTP_X_FORWARDED_HOST' => 'example.test'], [], []);
            $harness->assertSame('https://example.test' . $base . 'signup/?token=a%26b', ApplicationUrlFramework::absolute($request, 'signup/', ['token' => 'a&b']));
            $harness->assertSame('https://example.test' . rtrim($base, '/'), (new AccountInviteService())->buildBaseUrl($request));
            $untrusted = new RequestFramework([], [], ['REMOTE_ADDR' => '198.51.100.2', 'HTTP_HOST' => 'example.test', 'HTTP_X_FORWARDED_PROTO' => 'https', 'HTTP_X_FORWARDED_HOST' => 'evil.test'], [], []);
            $harness->assertSame('http://example.test' . rtrim($base, '/'), ApplicationUrlFramework::publicBaseUrl($untrusted));
            try {
                ApplicationUrlFramework::publicBaseUrl(new RequestFramework([], [], ['HTTP_HOST' => 'example.test/unexpected'], [], []));
                throw new RuntimeException('Accepted a URL path inside the Host header.');
            } catch (InvalidArgumentException) {
            }
            foreach (['https://user:pass@example.test', 'https://example.test?a=b', 'https://example.test#frag', 'https://example.test/%2e%2e/', 'javascript:alert(1)', "https://example.test/\n"] as $url) {
                try {
                    ApplicationUrlFramework::normalisePublicBaseUrl($url);
                    throw new RuntimeException('Accepted unsafe public URL: ' . $url);
                } catch (InvalidArgumentException) {
                }
            }
            if ($base === '/') {
                $harness->assertSame('https://example.test/legacy', ApplicationUrlFramework::normalisePublicBaseUrl('https://example.test/legacy/'));
                $harness->assertSame('https://example.test/legacy%20app', ApplicationUrlFramework::normalisePublicBaseUrl('https://example.test/legacy%20app/'));
            } else {
                try {
                    ApplicationUrlFramework::normalisePublicBaseUrl('https://example.test/legacy/');
                    throw new RuntimeException('Accepted a conflicting public path.');
                } catch (InvalidArgumentException) {
                }
            }
        });
    }
});

$harness->check(ApplicationHtmlFramework::class, 'decorates documents once and preserves explicit external links', function () use ($harness, $withUrlConfig): void {
    $paths = [APP_ROOT . 'css/project.css', APP_ROOT . 'js/project.js'];
    $originals = [];
    foreach ($paths as $path) {
        $originals[$path] = is_file($path) ? file_get_contents($path) : null;
        file_put_contents($path, '/* URL regression fixture */');
    }
    try {
        foreach (['/', '/reports/', '/internal/reports/'] as $base) {
            $withUrlConfig(['web' => ['base_path' => $base]], function () use ($harness, $base): void {
                $html = '<!DOCTYPE html><html><head></head><body><a href="https://other.test/a">External</a><a href="/reports_old/">Old</a></body></html>';
                $html = ApplicationHtmlFramework::prepare($html);
                $harness->assertSame($html, ApplicationHtmlFramework::prepare($html));
                $harness->assertSame(1, substr_count($html, 'href="' . $base . 'css/project.css"'));
                $harness->assertSame(1, substr_count($html, 'src="' . $base . 'js/project.js"'));
                $harness->assertTrue(str_contains($html, 'href="https://other.test/a"'));
                $harness->assertTrue(str_contains($html, 'href="/reports_old/"'));
                $signup = (new SignupPageRenderer('Test', 'Test'))->errorPage(new SessionAuthenticationService(), ['Invalid invite']);
                $harness->assertTrue(str_contains($signup, $base . 'css/project.css'));
                $harness->assertTrue(str_contains($signup, $base . 'js/project.js'));
                $legacy = '<html><head><link rel="stylesheet" href="css/project.css"></head><body><script src="/js/project.js"></script></body></html>';
                $rewritten = ApplicationHtmlFramework::prepare($legacy);
                $harness->assertSame(1, substr_count($rewritten, 'href="' . $base . 'css/project.css"'));
                $harness->assertSame(1, substr_count($rewritten, 'src="' . $base . 'js/project.js"'));
            });
        }
    } finally {
        foreach ($originals as $path => $original) {
            if ($original === null) unlink($path); else file_put_contents($path, $original);
        }
    }
});

$harness->check(ApplicationUrlFramework::class, 'preserves deployment configuration when web settings are saved', function () use ($harness): void {
    $path = AppConfigurationStore::configPath();
    $contents = file_get_contents($path);
    try {
        $config = AppConfigurationStore::config();
        $config['web']['base_path'] = '/reports/';
        file_put_contents($path, '<?php return ' . var_export($config, true) . ';');
        AppConfigurationStore::config(true);
        AppConfigurationStore::setWebEnvironmentSettings(['base_url_override' => 'https://example.test/reports/']);
        $harness->assertSame('/reports/', AppConfigurationStore::get('web.base_path'));
        $saved = file_get_contents($path);
        try {
            AppConfigurationStore::setWebEnvironmentSettings(['base_url_override' => 'https://example.test/other/']);
            throw new RuntimeException('Saved a conflicting external URL path.');
        } catch (InvalidArgumentException) {
        }
        $harness->assertSame($saved, file_get_contents($path));
    } finally {
        file_put_contents($path, $contents);
        AppConfigurationStore::config(true);
    }
});

$harness->check(ApplicationUrlFramework::class, 'namespaces anti-fraud cookies while preserving root headers and names', function () use ($harness, $withUrlConfig): void {
    foreach (['/', '/reports/', '/reports/child/'] as $base) {
        $withUrlConfig(['web' => ['base_path' => $base]], function () use ($harness, $base): void {
            $name = ApplicationUrlFramework::scopedName('af_client_device_id');
            $harness->assertSame($base === '/', $name === 'af_client_device_id');
            $request = new RequestFramework([], [], [], [], [], null, [$name => 'this-app', 'af_client_device_id' => 'root-app']);
            $harness->assertSame($base === '/' ? 'root-app' : 'this-app', (new AntiFraudService($request))->requestValue('Client-Device-ID'));
        });
    }
});
