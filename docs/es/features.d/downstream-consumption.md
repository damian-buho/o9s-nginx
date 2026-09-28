<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

<!-- textlint-disable terminology,common-misspellings -->

# Base para imágenes basadas en nginx

- Un solo `FROM` hereda el proceso de compilación, los hooks de arranque, los healthchecks, las páginas de error y la precompresión.
- Las imágenes hijas se personalizan sobrescribiendo valores de entorno, nunca copiando ni parcheando archivos de configuración.
- Nuevos manejadores de peticiones y comportamientos opcionales se añaden colocando un archivo de plantilla en la imagen; la configuración existente queda intacta.
- Un scaffold inicia un nuevo proyecto basado en nginx con todo lo anterior ya conectado.

<!-- textlint-enable -->
