<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

# CDN-aware real IP resolution

- Trusted proxy IP ranges for major CDNs are fetched live at every container start, ensuring `set_real_ip_from` lists are always current.
- Supported CDN modes (`O9S_NGINX_REALIP_MODE`): `cloudflare` (CF-Connecting-IP header), `akamai` (True-Client-IP), `aws` (CloudFront + ELB ranges, X-Forwarded-For), `fastly` (Fastly-Client-IP).
- Non-CDN modes are also available: `docker` (static RFC 1918 ranges), `custom` (user-specified subnet via `O9S_NGINX_REALIP_NETWORK`), `localhost`.
- The appropriate `real_ip_header` is set automatically per CDN mode.
- IP fetching is skipped in immutable mode (`B19_IMMUTABLE=Y`).
