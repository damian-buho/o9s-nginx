<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

<!-- textlint-disable terminology,common-misspellings -->

# Compresión Brotli, zstd y gzip

- Brotli y zstd se incluyen junto a gzip, de modo que cada navegador moderno recibe su mejor codificación.
- Los tres comparten una única lista de tipos comprimibles, y los medios y archivos ya comprimidos se dejan intactos.
- Los niveles al vuelo se mantienen bajos para ahorrar CPU; los archivos precomprimidos en la compilación se sirven con la máxima compresión (ver precompresión estática).

<!-- textlint-enable -->
