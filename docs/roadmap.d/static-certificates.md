<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

# Mounted TLS certificates with a dev fallback

- **Problem.** The only certificate source is the built-in ACME module, which needs a real domain and DNS or HTTP validation; an operator with existing certs, an internal CA, or a plain localhost HTTPS need has no env path and must hand-author includes.
- **Under consideration.** An env-driven cert pair that wires the certificate and key through the existing TLS server-block gate, plus a one-flag self-signed generator for local development.
- **Rests on.** nginx’s certificate directives and the existing TLS-enabled gate; b19 Docker-secrets auto-loading for key material.
