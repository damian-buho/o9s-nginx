<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

# Localized, self-contained error pages

- Custom error pages for the ten standard status codes (400–504), generated at build time from a single template instead of nginx’s bare built-in pages.
- Visitors get their own language: the server negotiates `Accept-Language` per request (English, Spanish, Ukrainian) with automatic fallback to English — no JavaScript involved.
- Dark by default and follows the operating system’s light/dark preference through native CSS color-scheme switching.
- Fully self-contained: system fonts and no third-party requests, so pages render identically offline and under a strict Content-Security-Policy.
- Adding a language is one gettext `.po` file — pages and negotiation extend automatically on the next build.
