<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

# Environment-driven configuration (zero config mounts)

- Every nginx directive is environment-driven — the image is fully functional with no mounted config files.
- Configuration is generated from environment variables at startup — no manual config editing.
- Downstream images tune nginx through environment overrides only; no volume mounts needed.
- Categories cover ports, compression, proxy, TLS, logging, caching, CORS, CSP, real IP, and OpenTelemetry.
