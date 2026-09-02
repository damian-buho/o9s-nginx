<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

# Scaffold system for downstream nginx-based images

- Configuration is assembled from composable templates — base config, includes, and overrides merge automatically at startup.
- New projects inherit the full build pipeline, entrypoint, healthcheck, and template hierarchy without manual setup.
- Downstream projects only need to override specific environment values and optionally add custom includes.
