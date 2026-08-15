<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

# Múltiples módulos de compresión (brotli, zstd, gzip)

- Tres algoritmos de compresión se compilan como módulos dinámicos y se cargan condicionalmente mediante `O9S_NGINX_MODULE_{BROTLI,ZSTD}` (ambos activados por defecto; gzip está integrado en el núcleo de nginx).
- Cada algoritmo tiene conmutadores de activación/desactivación y niveles de compresión independientes, controlables en tiempo de ejecución.
- Los niveles de compresión dinámica pueden diferir de los de precompresión: en tiempo de ejecución se usan niveles menores por eficiencia de CPU; la precompresión usa el máximo.
- Una lista compartida de tipos MIME (`O9S_NGINX_COMPRESS_TYPES`) controla qué tipos de contenido son aptos para compresión en los tres algoritmos.
- Los hermanos precomprimidos `.br`, `.zst` y `.gz` se sirven directamente mediante los módulos `*_static` correspondientes cuando existen (véase la precompresión estática).
