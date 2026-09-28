<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

<!-- textlint-disable terminology,common-misspellings -->

# Modos de servicio listos para usar

- Un solo ajuste elige cómo se sirve un sitio: archivos estáticos, una aplicación PHP mediante FastCGI, archivos estáticos con respaldo en un backend de aplicación, o un listado de directorio.
- Los backends se resuelven cuando llega la petición, así nginx arranca aunque la aplicación aún no esté disponible.
- Las actualizaciones a WebSocket y las cabeceras de reenvío funcionan a través del proxy sin configuración adicional.
- Las imágenes hijas añaden sus propios modos con un archivo de plantilla.

<!-- textlint-enable -->
