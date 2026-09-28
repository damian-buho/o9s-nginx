<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

# Config validation and nginx-aware healthchecks

- The rendered config is tested before nginx starts; on failure every rendered file is logged, so the broken line is visible in the container log.
- Healthchecks query nginx itself and a real HTTP request, not only whether the process exists.
- A readiness endpoint is available for load balancers and orchestrators.
- A debug command prints the full effective config with every include expanded.
