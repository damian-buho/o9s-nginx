<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

# Immutable mode for hardened deployments

- Setting `B19_IMMUTABLE=Y` skips all runtime config generation, CDN IP fetching, asset scanning, and certificate/DH parameter generation.
- The image must contain pre-rendered configs — intended for read-only, hardened, or rootless deployments where no filesystem writes are permitted at runtime.
- All Jinja2 templates must be rendered at build time in this mode.
