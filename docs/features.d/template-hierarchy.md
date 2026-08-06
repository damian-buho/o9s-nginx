<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

# Jinja2 include-based template hierarchy

- The entire nginx config tree lives as Jinja2 (`.j2`) templates under `${XDG_CONFIG_HOME}/`, composed via `include` directives — no monolithic config file.
- The `http {}` block pulls in 24 numbered snippets (`includes/http/*.nginx`) sorted by prefix: core, AIO, DNS, compression, ACME, client/IO, HTTP/2+3, keepalive, proxy, caching, TLS, logging, real IP, and OpenTelemetry.
- Server blocks compose from modular includes: `listen/` (socket config), `server/` (error pages, ETag, DNS prefetch, preload hints), `index/` (content handler), `opt/` (feature toggles), and `realip/` (CDN-aware IP resolution).
- Templates needing conditional logic use Jinja2 `{% if %}` blocks; non-conditional snippets are plain `.nginx` files rendered as-is.
- New behaviors can be added by dropping a file into the appropriate `includes/` directory — no editing of existing templates required.
