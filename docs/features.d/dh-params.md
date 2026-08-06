<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

# DH parameters pre-generation

- A 2048-bit DH parameters file is generated at build time if not already present, avoiding the expensive computation at first request in production.
- DH parameter size is configurable via `B19_CA_DHPARAMS_SIZE`; the output path is `${O9S_NGINX_TLS_PATH}/dhparams.pem`.
- The generated file is consumed by the TLS configuration block (`ssl_dhparam`) automatically.
