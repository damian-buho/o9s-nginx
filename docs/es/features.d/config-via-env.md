<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

# Configuración dirigida por el entorno (cero montajes de configuración)

- Cada directiva de nginx se controla mediante más de 200 variables de entorno `O9S_NGINX_*` con valores predeterminados razonables integrados en el Dockerfile — la imagen funciona por completo con `docker run` y sin archivos de configuración montados.
- Las imágenes descendentes y los archivos compose ajustan nginx solo con sobrescrituras de `environment:` o `ENV`; no hacen falta montajes de volumen en `/etc/nginx/` ni archivos `.conf`.
- Todas las plantillas se generan al arrancar mediante el hook estándar de renderizado Jinja2, con cada variable ENV del contenedor disponible como `ENV.VAR_NAME`.
- Las categorías de variables cubren puertos, HTTP/2+3, compresión, proxy, FastCGI, TLS, registro, caché, CSP, CORS, Permissions-Policy, IP real, OpenTelemetry y opciones de socket.
