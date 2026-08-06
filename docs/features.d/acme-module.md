<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

# Built-in ACME certificate automation module

- An ACME client module (compiled from Rust) is included as a dynamic nginx module, enabling automatic TLS certificate provisioning without an external agent.
- Activation is via `O9S_NGINX_MODULE_ACME=Y`; the ACME issuer block is emitted automatically in the HTTP config.
- ACME server URL (`O9S_NGINX_ACME_SERVER`) and issuer name (`O9S_NGINX_ACME_ISSUER_NAME`) are configurable, supporting any ACME-compatible CA.
- Per-server certificate configuration is available through the `enable-acme` opt/ include.
