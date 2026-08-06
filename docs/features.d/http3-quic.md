<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

# HTTP/3 (QUIC) support

- nginx is compiled from source with full HTTP/3 (QUIC) support, enabled by default (`O9S_NGINX_HTTP3=on`).
- The `Alt-Svc` header is emitted automatically, advertising the QUIC port so compatible browsers upgrade to HTTP/3 transparently.
- QUIC transport options are ENV-tunable: GSO (`O9S_NGINX_QUIC_GSO`), retry (`O9S_NGINX_QUIC_RETRY`), BPF (`O9S_NGINX_QUIC_BPF`), max concurrent streams, and stream buffer size.
- HTTP/2 and HTTP/3 listen on the same port (separate `listen` directives for `ssl` and `quic`), with all socket options independently configurable.
