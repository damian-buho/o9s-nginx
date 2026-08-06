<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

# Content-Signal and robots.txt directives

- A `robots.txt` file is generated at startup from environment variables — no static file needs to be mounted.
- Default crawl policy is configurable via `O9S_NGINX_ROBOTS_TXT_DEFAULT_POLICY`: `disallow` (default), `allow`, or `none` (omit the default block entirely).
- Content-Signal directives per contentsignals.org are emitted: `CONTENT_SIGNALS_SEARCH`, `CONTENT_SIGNALS_TRAIN`, `CONTENT_SIGNALS_INPUT` control whether search indexing, AI training, and AI input are permitted (`yes`/`no`).
- A sitemap URL can be declared via `O9S_NGINX_ROBOTS_TXT_SITEMAP`.
