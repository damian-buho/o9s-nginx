<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

# Pre-compression of static assets

- Static files are pre-compressed in three formats (gzip via pigz, brotli, zstd) so nginx serves pre-built `.gz`/`.br`/`.zst` siblings directly — no per-request CPU cost.
- Compression runs at build time by default (inheritable `.i.sh` hook propagates to downstream images) and optionally again at container start.
- File extensions to compress are configurable (`O9S_NGINX_PRECOMPRESS_EXTENSIONS`); Jinja2 template outputs are excluded automatically.
- Each algorithm has independent on/off toggles and compression levels (pre-compression uses maximum levels: gzip 9, brotli 11, zstd 19).
- A standalone `compress-static-assets` command is available for manual invocation on any directory.
