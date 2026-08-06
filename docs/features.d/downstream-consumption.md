<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

# Downstream consumption pattern

- Child images inherit all 200+ ENV defaults, the template hierarchy, entrypoint hooks, healthchecks, and pre-compression logic from a single `FROM` line.
- Customization is done by overriding specific `ENV` values in the child Dockerfile (e.g. `O9S_NGINX_INDEX_TYPE=cache`, cache durations, backend host/port).
- New content handlers can be added by placing a `.nginx.j2` file in `includes/index/` and setting `O9S_NGINX_INDEX_TYPE` — the include path is dynamic.
- New feature toggles can be added by placing a file in `includes/opt/` and listing its name in `O9S_NGINX_INCLUDE_OPTIONAL`.
- No config file mounts are ever required — the pattern is ENV-only from base image through all downstream derivatives.
