<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

# Ready-made serving modes

- One setting chooses how a site is served: static files, a PHP application over FastCGI, static files with fallback to an application backend, or a directory listing.
- Backends are looked up when a request arrives, so nginx starts even if the application is not up yet.
- WebSocket upgrades and forwarding headers work through the proxy with no extra config.
- Child images add their own modes with one template file.
