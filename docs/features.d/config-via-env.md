<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

# Configuration through environment variables only

- Every nginx setting has a sane default and an environment override — the image runs with no mounted config files.
- Ports, TLS, compression, proxying, caching, logging, security headers and tracing are all tuned from `docker run` or compose.
- Optional behaviors (CORS, security headers, HTTPS redirect, certificates, tracing) are switched on per site by listing them, not by editing config.
