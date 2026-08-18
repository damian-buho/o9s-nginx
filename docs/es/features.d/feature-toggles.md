<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

<!-- textlint-disable terminology,common-misspellings -->

# Includes de conmutadores de características (sistema opt/)

- Fragmentos de nginx autocontenidos en `includes/opt/` se incluyen condicionalmente por bloque de servidor mediante `O9S_NGINX_INCLUDE_OPTIONAL` (lista de nombres separados por espacios).
- Conmutadores disponibles: CORS (`enable-cors`, 6 variables), Content-Security-Policy (`enable-csp`, 18 variables), HSTS (`enable-hsts`), Permissions-Policy (`enable-permissions-policy`, 12 variables), stub status (`enable-status`), certificado ACME (`enable-acme`), OTel por servidor (`enable-otel`), cache-control (`enable-cache`), favicon (`enable-favicon`), rutas de certbot (`enable-certbot`), X-Frame-Options DENY (`enable-sameorigin`), X-Content-Type-Options nosniff (`enable-nosniff`), redirección de HTTP a HTTPS (`redirect-to-https`).
- Cada conmutador se gobierna por completo mediante ENV — no hay que editar archivos de configuración de nginx.
- Las imágenes descendentes pueden añadir nuevos fragmentos opt/ depositando un archivo `.nginx` o `.nginx.j2` en `includes/opt/`.

<!-- textlint-enable -->
