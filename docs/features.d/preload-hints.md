<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

# Preload hint scanning

- At container startup, the document root is scanned for CSS, JavaScript, image, and font assets, generating `<Link>` preload headers automatically.
- Scanning is opt-in via `O9S_NGINX_PH_SCAN_ENABLED=Y`; individual asset types (style, script, image, font) can be toggled independently.
- The scan path is configurable via `O9S_NGINX_PH_SCAN_PATH` (default `assets`).
- Discovered assets are written to a JSON sidecar consumed by the Jinja2 template, producing `Link: <...>; rel=preload; as=...` headers on HTML responses.
