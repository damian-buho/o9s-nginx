<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

<!-- textlint-disable terminology,common-misspellings -->

# Configuración solo mediante variables de entorno

- Cada ajuste de nginx tiene un valor por defecto sensato y una variable de entorno que lo sobrescribe: la imagen funciona sin montar archivos de configuración.
- Puertos, TLS, compresión, proxy, caché, registros, cabeceras de seguridad y trazas se ajustan desde `docker run` o compose.
- Los comportamientos opcionales (CORS, cabeceras de seguridad, redirección a HTTPS, certificados, trazas) se activan por sitio listándolos, sin editar la configuración.

<!-- textlint-enable -->
