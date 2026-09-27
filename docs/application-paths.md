# Hosting eelKit beneath a URL path

eelKit can serve an application at `/`, `/reports/`, or `/internal/reports/`.
Set the public application path in `secure/app.php`:

```php
'web' => [
    'base_path' => '/reports/',
],
```

An omitted or empty setting means `/`. `/reports` is normalized to `/reports/`.
Paths are case-sensitive and must start with `/`. Use unreserved URL characters
(letters, digits, hyphens, underscores, dots, and tildes) in non-empty segments.
Full URLs, protocol-relative URLs, whitespace, backslashes, dot traversal
segments, percent encoding, queries, and fragments are rejected. The settings
screen displays the effective value; change it in deployment configuration,
alongside the web-server mapping.

This setting is a URL path, not a filesystem directory. Keep this structure:

```text
/srv/company-website/          existing public company website
/srv/reports-app/
    web_root/                 public eelKit directory
    secure/                   private configuration, keys and database files
    db_schema/
    tools/
    file_logs/
```

`APP_ROOT`, `APP_CONFIG`, and other filesystem constants retain their meanings.
No directory relocation or database migration is needed.

## PHP and JavaScript helpers

Build application-owned URLs through `ApplicationUrlFramework`:

```php
ApplicationUrlFramework::basePath();
// /reports/
ApplicationUrlFramework::page('users', ['filter' => 'a&b']);
// /reports/?page=users&filter=a%26b
ApplicationUrlFramework::asset('css/project.css');
// /reports/css/project.css
ApplicationUrlFramework::path('signup/', ['token' => $token]);
ApplicationUrlFramework::absolute($request, 'signup/', ['token' => $token]);
// https://example.com/reports/signup/?token=...

$action = HelperFramework::escape(ApplicationUrlFramework::page('users'));
echo '<form method="post" action="' . $action . '">...</form>';
```

Pass queries as arrays and fragments as the optional final argument to `path`,
`page`, or `absolute`. Escape the returned URL when inserting it into HTML.
Asset/path helpers accept application-relative paths, leading-slash asset paths,
and already-prefixed application paths without adding the prefix twice. They
reject external URLs and traversal. Filesystem paths do not belong in these APIs.

`RequestFramework::pageUrl()` retains its existing query merging and query-only
output for root installations. For subpaths it returns a path-prefixed URL.
Explicitly supplied `NavigationFramework` URL prefixes remain authoritative.

Full framework HTML documents expose the base path and cookie/storage namespace
as data attributes on `<html>`. After `js/index.js` loads, project JavaScript can use:

```javascript
eelKit.urls.basePath;
eelKit.urls.page('users', { filter: 'active' });
eelKit.urls.asset('images/logo.png');
eelKit.urls.path('signup/', { token: 'example' });
eelKit.urls.isApplicationUrl(url);
```

JavaScript query values are scalar values or `URLSearchParams`-compatible values;
use bracketed parameter names when building PHP array queries. The PHP helper
uses normal PHP query-array encoding.

Do not pass intentional external links or links to another application through
the local-path helpers. For example, `/reports_old/` and the company website `/`
must remain explicitly configured destinations. Use ordinary links/forms for
these destinations. If a custom element also carries framework enhancement
attributes, mark it `data-eel-external="true"` to opt out. A root application
cannot infer that another application owns a child path merely from the URL.

Keep forms inside individual cards. Existing query-based page routing continues
to work; no new route definitions are required. Downstream custom code that uses
hard-coded root URLs should adopt these helpers when opting into subpath hosting.

Optional `web_root/css/project.css` and `web_root/js/project.js` are loaded after
the framework assets on application, login, OTP/password, and signup screens.
Their existence is checked on disk; their public URLs use the configured path.
CSS font references are relative to their stylesheet location.

## Invitations and proxies

Continue using `invitation.base_url_override` (the External Base Web URL setting).
For `web.base_path = /reports/`, either of these yields the same invitation base:

```text
https://example.com
https://example.com/reports/
```

A different override path is rejected for non-root applications. HTTP(S) URLs
must not contain credentials, query strings, fragments, or unsafe paths. The
same rules apply to explicit base URLs supplied to invitation service methods.
Existing root installations may continue using valid path-bearing overrides.

With no override, the framework uses the request's scheme and hostname, or
forwarded scheme/hostname from a configured trusted proxy. The application path
always comes from configuration; forwarded-prefix headers are not used. Configure
an explicit public URL when generating links without a request hostname.

## Cookies and compatibility

Root installations retain `ELL_ID`, cookie path `/`, existing device-cookie and
browser-storage names, and valid pre-upgrade root sessions. Non-root applications
use a stable namespace derived from the normalized base path and cookies scoped
to that path. PHP and JavaScript use matching device-cookie names. Session data
also records its application scope so another application's session ID is not
adopted, even with shared PHP session storage. Rejecting a foreign session must
not delete that application's session.

Changing the base path changes the application namespace: users sign in again
and browser preferences start afresh. Existing Secure, HttpOnly and SameSite
settings continue to apply. Cookie paths prevent accidental overlap; applications
on the same hostname still share a browser origin. Use separate hostnames when
separate browser security origins are required.

## Apache 2.4 example

Add the following to the appropriate virtual host, adapting the filesystem paths.
Keep the existing company website's configuration and PHP handler. The eelKit
alias must use the site's PHP handler too (for example its configured PHP-FPM
handler); never expose PHP source as static files.

```apache
DocumentRoot "/srv/company-website"

RewriteEngine On
# VirtualHost context: exact match, preserve query and POST method/body.
RewriteRule ^/reports$ /reports/ [R=308,L]
# Put this before any existing VirtualHost website catch-all rewrite.
RewriteRule ^/reports/ - [L]

Alias "/reports/" "/srv/reports-app/web_root/"
<Directory "/srv/reports-app/web_root">
    DirectoryIndex index.php
    DirectorySlash On
    Options -Indexes
    AllowOverride Options AuthConfig
    Require all granted
</Directory>
```

The trailing slash is canonical. An Alias ending in `/` does not match the bare
`/reports` path, hence the explicit redirect. No catch-all rewrite is needed for
`/reports/?page=dashboard` or `/reports/signup/`. The alias maps URLs to the
existing public directory; it does not move directories or expose the project
root. Keep `secure`, schemas, tools, uploads containing private data, and logs
outside the company document root and outside all public aliases.

`AllowOverride Options AuthConfig` preserves the repository's `.htaccess` rules:
no directory listings, direct access denied to classes/content, and restricted
test-file access. If an operator disables overrides, reproduce those restrictions
explicitly in the virtual host. Keep developer options off in production.

The rewrite patterns above are for VirtualHost context. In a root `.htaccess`,
patterns do not begin with `/`; any website catch-all must exclude `reports/`.
Do not add a second rewrite that sends application traffic to the company site's
front controller. For nested mounts, substitute the full path everywhere and
place more-specific aliases before their parents.

References: [Apache Alias](https://httpd.apache.org/docs/2.4/mod/mod_alias.html#alias),
[rewrite flags](https://httpd.apache.org/docs/2.4/rewrite/flags.html),
[DirectorySlash](https://httpd.apache.org/docs/2.4/mod/mod_dir.html#directoryslash).

### Isolated Apache smoke test

Use a disposable Apache 2.4 virtual host and a throwaway eelKit database/config,
never a production site. Enable its PHP handler, mod_alias, mod_dir, mod_rewrite,
and authorization modules. Validate the example with `apachectl -t` before
starting the test instance. Repeat with `/internal/reports/` and with a separate
root-install virtual host.

1. Put a recognizable static page in the company document root; confirm `/`
   still returns it and `/reports_old/` is not captured by the new alias.
2. Inspect `/reports?page=users&filter=a%26b` with redirects disabled: expect 308
   and `/reports/?page=users&filter=a%26b`. Verify a test POST follows 308 without
   changing method or losing its body.
3. Visit `/reports/`, log in, navigate, submit a card action, refresh a card, and
   download a table. Inspect network requests for missing/doubled prefixes.
4. Check signup from a generated invitation and its completion redirect.
5. Verify framework/project CSS and JavaScript, icons, branding and fonts load
   with correct content types beneath the mount.
6. Verify `/reports/classes/`, `/reports/content/`, and non-entrypoint test files
   return 403; private project directories must not be served. Confirm the test
   runner is denied when developer options are off.
7. With root and subpath eelKit fixtures on one hostname, sign into both, log out
   of one, and confirm the other remains signed in.

The repository's regression tests remain PHP-only and run through
`php web_root/tests/index.php`. Browser automation used during framework
verification is external tooling, not an eelKit dependency or distribution
component. Browser checks using a portable development server do not validate
Apache directive processing. Record actual Apache smoke-test results separately.
