<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

# Mounted TLS certificates with a dev fallback

- **Problem.** The only certificate source is the built-in ACME module, which needs a real domain and DNS or HTTP validation; an operator with existing certs, an internal CA, or a plain localhost HTTPS need has no env path and must hand-author includes.
- **Under consideration.** An env-driven cert pair (`O9S_NGINX_SSL_CERT` / `_KEY`) that wires `ssl_certificate` and `ssl_certificate_key` through the existing TLS server-block gate, plus a one-flag self-signed generator for local development.
- **Rests on.** nginx’s `ssl_certificate` directives and the existing `O9S_NGINX_SSL_ENABLED` gate; b19 Docker-secrets auto-loading for key material.
