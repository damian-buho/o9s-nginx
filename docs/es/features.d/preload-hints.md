<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

<!-- textlint-disable terminology,common-misspellings -->

# Escaneo de pistas de precarga

- Al arrancar el contenedor, la raíz de documentos se escanea en busca de recursos CSS, JavaScript, imágenes y fuentes, generando automáticamente cabeceras de precarga `<Link>`.
- El escaneo es opcional mediante `O9S_NGINX_PH_SCAN_ENABLED=Y`; los tipos de recurso individuales (style, script, image, font) pueden conmutarse de forma independiente.
- La ruta de escaneo es configurable mediante `O9S_NGINX_PH_SCAN_PATH` (predeterminado `assets`).
- Los recursos descubiertos se escriben en un sidecar JSON que consume la plantilla Jinja2, produciendo cabeceras `Link: <...>; rel=preload; as=...` en las respuestas HTML.

<!-- textlint-enable -->
