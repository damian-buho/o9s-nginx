<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

<!-- textlint-disable terminology,common-misspellings -->

# Trazas OpenTelemetry y registros de acceso en JSON

- Cada petición puede exportarse como span a cualquier colector OpenTelemetry, y el contexto de traza puede propagarse al backend.
- Desactivado por defecto, sin sobrecarga hasta que se necesiten trazas; cada sitio lo habilita por separado.
- Incluye un formato de registro de acceso en JSON para canalizaciones de registros que procesan líneas estructuradas.

<!-- textlint-enable -->
