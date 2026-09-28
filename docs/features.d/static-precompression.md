<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

# Static asset pre-compression

- Static files are compressed once, at maximum ratio, in gzip, brotli and zstd; nginx serves the ready file with no per-request CPU cost.
- Runs at build time and is inherited by child images; it can also run at container start for content mounted from a volume.
- Can watch a mounted release directory and recompress on its own when a new release is swapped in.
- A standalone command compresses any directory by hand.
