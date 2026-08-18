<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

<!-- textlint-disable terminology,common-misspellings -->

# Jerarquía de plantillas basada en includes Jinja2

- Todo el árbol de configuración de nginx vive como plantillas Jinja2 (`.j2`) bajo `${XDG_CONFIG_HOME}/`, compuesto mediante directivas `include` — sin un archivo de configuración monolítico.
- El bloque `http {}` incorpora 24 fragmentos numerados (`includes/http/*.nginx`) ordenados por prefijo: núcleo, AIO, DNS, compresión, ACME, cliente/ES, HTTP/2+3, keepalive, proxy, caché, TLS, registro, IP real y OpenTelemetry.
- Los bloques de servidor se componen de includes modulares: `listen/` (configuración de socket), `server/` (páginas de error, ETag, prefetch de DNS, pistas de precarga), `index/` (gestor de contenido), `opt/` (conmutadores de características) y `realip/` (resolución de IP consciente de CDN).
- Las plantillas que necesitan lógica condicional usan bloques Jinja2 `{% if %}`; los fragmentos sin condicionales son archivos `.nginx` planos renderizados tal cual.
- Se pueden añadir nuevos comportamientos depositando un archivo en el directorio `includes/` apropiado — sin editar las plantillas existentes.

<!-- textlint-enable -->
