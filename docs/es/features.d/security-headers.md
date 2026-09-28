<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

<!-- textlint-disable terminology,common-misspellings -->

# Cabeceras de seguridad

- Content-Security-Policy, HSTS, Permissions-Policy, Cross-Origin-Embedder-Policy, Reporting-Endpoints, `nosniff` y la protección contra enmarcado se activan con un interruptor cada una, con valores restrictivos por defecto.
- Las imágenes hijas añaden a la política los hashes de sus propios scripts en línea, así una CSP estricta no necesita `'unsafe-inline'`.
- Las cabeceras también se envían en las respuestas de error, así una página 404 o 502 queda tan protegida como el sitio.
- nginx responde directamente a las peticiones CORS preliminares, sin llegar al backend.
- La redirección de HTTP a HTTPS está disponible por sitio.

<!-- textlint-enable -->
