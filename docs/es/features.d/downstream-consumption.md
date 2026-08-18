<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

<!-- textlint-disable terminology,common-misspellings -->

# Patrón de consumo descendente

- Las imágenes hijas heredan los más de 200 valores ENV predeterminados, la jerarquía de plantillas, los hooks del entrypoint, las comprobaciones de estado y la lógica de precompresión desde una sola línea `FROM`.
- La personalización se hace sobrescribiendo valores `ENV` concretos en el Dockerfile hijo (p. ej. `O9S_NGINX_INDEX_TYPE=cache`, duraciones de caché, host/puerto del backend).
- Se pueden añadir nuevos gestores de contenido colocando un archivo `.nginx.j2` en `includes/index/` y estableciendo `O9S_NGINX_INDEX_TYPE` — la ruta de include es dinámica.
- Se pueden añadir nuevos conmutadores de características colocando un archivo en `includes/opt/` y listando su nombre en `O9S_NGINX_INCLUDE_OPTIONAL`.
- Nunca se requieren montajes de archivos de configuración: el patrón es solo ENV desde la imagen base hasta todos los derivados descendentes.

<!-- textlint-enable -->
