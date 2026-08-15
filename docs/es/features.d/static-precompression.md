<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

# Precompresión de recursos estáticos

- Los archivos estáticos se precomprimen en tres formatos (gzip con pigz, brotli, zstd) para que nginx sirva directamente los hermanos preconstruidos `.gz`/`.br`/`.zst` — sin coste de CPU por petición.
- La compresión se ejecuta por defecto en tiempo de compilación (el hook heredable `.i.sh` se propaga a las imágenes descendentes) y, opcionalmente, otra vez al arrancar el contenedor.
- Las extensiones de archivo a comprimir son configurables (`O9S_NGINX_PRECOMPRESS_EXTENSIONS`); las salidas de plantillas Jinja2 se excluyen automáticamente.
- Cada algoritmo tiene conmutadores de activación/desactivación y niveles de compresión independientes (la precompresión usa niveles máximos: gzip 9, brotli 11, zstd 19).
- La orden autónoma `compress-static-assets` está disponible para invocarse manualmente sobre cualquier directorio.
