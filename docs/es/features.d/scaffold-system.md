<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

<!-- textlint-disable terminology,common-misspellings -->

# Sistema de andamiaje para imágenes descendentes basadas en nginx

- Un directorio `scaffold/` aporta una plantilla de Dockerfile y `stack.conf` para arrancar nuevos proyectos derivados de nginx.
- Usa la integración de pila de m6e (`STACK_ROOT_STAGE=base`, `STACK_EXTENSIONS=nginx`) para que los nuevos proyectos hereden automáticamente la cadena de compilación completa.
- Los proyectos descendentes solo necesitan sobrescribir valores `ENV` concretos y, opcionalmente, añadir archivos `includes/` propios — el Dockerfile base, el entrypoint, la comprobación de estado y la jerarquía de plantillas se heredan por completo.

<!-- textlint-enable -->
