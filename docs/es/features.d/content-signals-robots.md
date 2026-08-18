<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

<!-- textlint-disable terminology,common-misspellings -->

# Directivas Content-Signal y robots.txt

- Un archivo `robots.txt` se genera al arrancar desde variables de entorno — no hay que montar ningún archivo estático.
- La política de rastreo predeterminada se configura con `O9S_NGINX_ROBOTS_TXT_DEFAULT_POLICY`: `disallow` (predeterminado), `allow` o `none` (omite el bloque predeterminado por completo).
- Se emiten directivas Content-Signal según contentsignals.org: `CONTENT_SIGNALS_SEARCH`, `CONTENT_SIGNALS_TRAIN`, `CONTENT_SIGNALS_INPUT` controlan si se permiten la indexación para búsqueda, el entrenamiento de IA y la entrada a la IA (`yes`/`no`).
- Puede declararse una URL de sitemap mediante `O9S_NGINX_ROBOTS_TXT_SITEMAP`.

<!-- textlint-enable -->
