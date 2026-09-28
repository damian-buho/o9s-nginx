<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

# Security headers

- Content-Security-Policy, HSTS, Permissions-Policy, Cross-Origin-Embedder-Policy, Reporting-Endpoints, `nosniff` and frame protection are each one switch away, with restrictive defaults.
- Child images add hashes for their own inline scripts to the policy, so a strict CSP needs no `'unsafe-inline'`.
- Headers are sent on error responses too, so a 404 or 502 page is as protected as the site.
- CORS preflight is answered by nginx directly, without reaching the backend.
- HTTP-to-HTTPS redirect is available per site.
