<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

<!-- textlint-disable terminology,common-misspellings -->

# Redirecciones para páginas movidas

- Un sitio conserva sus direcciones antiguas tras un cambio de nombre: cada página movida responde con una redirección permanente a su nueva dirección, y los buscadores trasladan su posicionamiento.
- Las redirecciones viajan como un archivo `_redirects` dentro del sitio publicado, en el mismo formato que leen Netlify y Cloudflare Pages, y cambian junto con las páginas a las que apuntan.
- Una publicación que cambia el sitio aplica sus nuevas redirecciones sin reiniciar.
- Una línea mal formada se omite y se nombra en el registro; nunca deja caído el resto del sitio.

<!-- textlint-enable -->
