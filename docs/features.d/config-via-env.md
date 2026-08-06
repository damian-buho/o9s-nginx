<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

# Environment-driven configuration (zero config mounts)

- Every nginx directive is controlled through 200+ `O9S_NGINX_*` environment variables with sensible defaults baked into the Dockerfile — the image is fully functional with `docker run` and no mounted config files.
- Downstream images and compose files tune nginx via `environment:` or `ENV` overrides only; no `/etc/nginx/` volume mounts or `.conf` files are needed.
- All templates are rendered at startup by the standard Jinja2 rendering hook, with every container ENV variable available as `ENV.VAR_NAME`.
- Variable categories cover ports, HTTP/2+3, compression, proxy, FastCGI, TLS, logging, caching, CSP, CORS, Permissions-Policy, real IP, OpenTelemetry, and socket options.
