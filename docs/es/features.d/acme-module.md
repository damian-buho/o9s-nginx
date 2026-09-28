<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

<!-- textlint-disable terminology,common-misspellings -->

# Automatización integrada de certificados ACME

- nginx obtiene y renueva sus propios certificados TLS: sin contenedor de certbot, sin cron, sin script de recarga.
- Funciona con cualquier autoridad de certificación compatible con ACME, no solo Let’s Encrypt.
- Desactivado por defecto; un interruptor lo activa y cada sitio lo habilita por separado.

<!-- textlint-enable -->
