<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

# Brotli, zstd and gzip compression

- Brotli and zstd ship alongside gzip, so every modern browser gets its best encoding.
- All three share one list of compressible types, and already-compressed media and archives are left alone.
- On-the-fly levels stay low to save CPU; files pre-compressed at build time are served at maximum ratio instead (see static pre-compression).
