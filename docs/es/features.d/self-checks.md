<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

<!-- textlint-disable terminology,common-misspellings -->

# Validación de la configuración y healthchecks propios de nginx

- La configuración generada se prueba antes de arrancar nginx; si falla, se registra cada archivo generado, de modo que la línea errónea aparece en el registro del contenedor.
- Los healthchecks consultan a nginx y hacen una petición HTTP real, no solo comprueban que el proceso exista.
- Hay un endpoint de disponibilidad para balanceadores de carga y orquestadores.
- Un comando de depuración muestra la configuración efectiva completa con cada include expandido.

<!-- textlint-enable -->
