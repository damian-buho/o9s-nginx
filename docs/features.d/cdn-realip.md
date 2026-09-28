<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

# CDN-aware real client IP

- Logs, rate limits and backends see the visitor’s address, not the CDN edge or the Docker gateway.
- Presets for Cloudflare, Akamai, AWS CloudFront and Fastly fetch the provider’s current ranges at every start, so the trust list never goes stale; the right client-IP header is chosen per provider.
- Trust sets stack: a CDN in front of another reverse proxy resolves the real client on both the direct and the proxied path.
- Proxied backends receive exactly one resolved client address, never the raw forwarding chain.
- A mistyped provider refuses to start; an unreachable provider list warns and keeps the other sources.
