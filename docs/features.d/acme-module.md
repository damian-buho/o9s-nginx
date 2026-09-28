<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

# Built-in ACME certificate automation

- nginx obtains and renews its own TLS certificates — no certbot sidecar, no cron job, no reload script.
- Works with any ACME-compatible certificate authority, not only Let’s Encrypt.
- Off by default; one switch turns it on, and each site opts in separately.
