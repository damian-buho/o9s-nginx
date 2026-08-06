<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

# Multiple compression modules (brotli, zstd, gzip)

- Three compression algorithms are compiled as dynamic modules and loaded conditionally via `O9S_NGINX_MODULE_{BROTLI,ZSTD}` (both on by default; gzip is built into nginx core).
- Each algorithm has independent on/off toggles and compression levels controllable at runtime.
- Dynamic compression levels can differ from pre-compression levels — runtime uses lower levels for CPU efficiency, pre-compression uses maximum.
- A shared MIME-type list (`O9S_NGINX_COMPRESS_TYPES`) controls which content types are eligible for compression across all three algorithms.
- Pre-compressed `.br`, `.zst`, and `.gz` siblings are served directly via the corresponding `*_static` modules when present (see static pre-compression).
