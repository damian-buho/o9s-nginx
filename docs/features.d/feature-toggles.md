<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

# Feature toggle includes (opt/ system)

- HTTP/3, Brotli compression, real-IP extraction, and other features are toggleable without rebuilding.
- Each feature is enabled or disabled entirely through environment variables — no config file edits required.
- Downstream images can add new features by dropping a snippet into the opt/ directory.
- Available toggles include CORS, Content-Security-Policy, HSTS, Permissions-Policy, ACME certificates, and OpenTelemetry tracing.
