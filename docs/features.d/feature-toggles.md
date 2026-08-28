<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

# Feature toggle includes (opt/ system)

- Self-contained nginx snippets in `includes/opt/` are conditionally included per server block via `O9S_NGINX_INCLUDE_OPTIONAL` (comma-separated list of names).
- Available toggles: CORS (`enable-cors`, 6 vars), Content-Security-Policy (`enable-csp`, 18 vars), HSTS (`enable-hsts`), Permissions-Policy (`enable-permissions-policy`, 12 vars), stub status (`enable-status`), ACME cert (`enable-acme`), OTel per-server (`enable-otel`), cache-control (`enable-cache`), favicon (`enable-favicon`), certbot paths (`enable-certbot`), X-Frame-Options DENY (`enable-sameorigin`), X-Content-Type-Options nosniff (`enable-nosniff`), HTTP-to-HTTPS redirect (`redirect-to-https`).
- Each toggle is entirely ENV-driven — no editing of nginx config files required.
- Downstream images can add new opt/ snippets by dropping a `.nginx` or `.nginx.j2` file into `includes/opt/`.
