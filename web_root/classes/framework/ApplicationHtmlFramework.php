<?php
/**
 * eelKit Framework
 * Copyright (c) 2026 James Elstone
 * Licensed under the BSD 3-Clause License
 * See LICENSE file for details.
 */
declare(strict_types=1);

/** Shared decoration for full HTML documents, including authentication and signup. */
final class ApplicationHtmlFramework
{
    public const COPYRIGHT = '<!-- eelKit Framework - Copyright (c) 2026 James Elstone - Licensed under the BSD 3-Clause License - See LICENSE file for details. -->';

    public static function prepare(string $html): string
    {
        $base = ApplicationUrlFramework::basePath();
        $html = preg_replace_callback('/<html\b([^>]*)>/i', static function (array $match) use ($base): string {
            $attributes = preg_replace('/\sdata-eel-(?:base-path|scope)=("[^"]*"|\x27[^\x27]*\x27)/i', '', $match[1]);
            return '<html' . $attributes . ' data-eel-base-path="' . HelperFramework::escape($base)
                . '" data-eel-scope="' . HelperFramework::escape(ApplicationUrlFramework::scopeKey()) . '">';
        }, $html, 1) ?? $html;
        return self::withProjectScript(self::withProjectStylesheet(self::withCopyright($html)));
    }

    public static function withCopyright(string $html): string
    {
        if (str_contains($html, self::COPYRIGHT)) {
            return $html;
        }
        $decorated = preg_replace('/(<!DOCTYPE html>)/i', '$1' . PHP_EOL . self::COPYRIGHT, $html, 1);
        return is_string($decorated) && $decorated !== $html ? $decorated : self::COPYRIGHT . PHP_EOL . $html;
    }

    public static function withProjectStylesheet(string $html): string
    {
        return self::withExtension($html, 'css/project.css', 'link', 'href', '</head>',
            '<link rel="stylesheet" href="%s">');
    }

    public static function withProjectScript(string $html): string
    {
        return self::withExtension($html, 'js/project.js', 'script', 'src', '</body>',
            '<script src="%s"></script>');
    }

    private static function withExtension(string $html, string $path, string $tag, string $attribute, string $before, string $template): string
    {
        if (!is_file(APP_ROOT . str_replace('/', DIRECTORY_SEPARATOR, $path))) {
            return $html;
        }
        $url = ApplicationUrlFramework::asset($path);
        $found = false;
        $html = preg_replace_callback('/(<' . $tag . '\b[^>]*\b' . $attribute . '=)("|\x27)(.*?)\2/i',
            static function (array $match) use ($path, $url, &$found): string {
                $existing = html_entity_decode($match[3], ENT_QUOTES | ENT_HTML5, 'UTF-8');
                if (!in_array($existing, [$path, '/' . $path, $url], true)) return $match[0];
                $found = true;
                return $match[1] . $match[2] . HelperFramework::escape($url) . $match[2];
            }, $html) ?? $html;
        if ($found) {
            return $html;
        }
        return preg_replace_callback('~' . preg_quote($before, '~') . '~i',
            static fn(): string => sprintf($template, HelperFramework::escape($url)) . PHP_EOL . $before,
            $html, 1) ?? $html;
    }
}
