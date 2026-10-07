<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

<!-- textlint-disable terminology,common-misspellings -->

# Tipos de contenido y caché correctos

- El texto se sirve como UTF-8, así los caracteres acentuados se muestran bien en texto plano, Markdown y CSV.
- Los tipos de archivo modernos que faltan en nginx de serie reciben el tipo correcto: módulos de JavaScript, subtítulos, manifiestos web, imágenes JPEG XL y HEIC, audio Opus/FLAC, YAML y TOML; el navegador los muestra en lugar de descargarlos.
- Los recursos estáticos reciben caché de navegador de larga duración, mientras que el HTML se revalida.
- Los archivos que un sitio reescribe tras una URL fija —un PDF de CV, un feed, una página Markdown, un endpoint JSON— se revalidan en lugar de cachearse un año, de modo que se recoge la siguiente publicación en vez de una copia obsoleta.
- Las fuentes se sirven como `application/xml` en vez del `application/rss+xml` de serie, para que el navegador aplique la vista previa XSL del sitio en lugar del XML sin formato.

<!-- textlint-enable -->
