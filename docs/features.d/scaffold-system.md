<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

# Scaffold system for downstream nginx-based images

- A `scaffold/` directory provides a Dockerfile template and `stack.conf` for bootstrapping new nginx-derived projects.
- Uses m6e stack integration (`STACK_ROOT_STAGE=base`, `STACK_EXTENSIONS=nginx`) so new projects inherit the full build pipeline automatically.
- Downstream projects only need to override specific `ENV` values and optionally add custom `includes/` files — the base Dockerfile, entrypoint, healthcheck, and template hierarchy are all inherited.
