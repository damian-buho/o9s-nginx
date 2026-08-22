<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

<!-- textlint-disable terminology,common-misspellings -->

# Páginas de error localizadas y autosuficientes

- Páginas de error propias para los diez códigos de estado estándar (400–504), generadas en tiempo de construcción a partir de una única plantilla, en lugar de las páginas integradas de nginx.
- Cada visitante recibe su idioma: el servidor negocia `Accept-Language` por petición (inglés, español, ucraniano) con retorno automático al inglés — sin JavaScript.
- Oscuras por defecto y siguen la preferencia clara/oscura del sistema operativo mediante el cambio nativo de esquema de color de CSS.
- Completamente autosuficientes: tipografías del sistema y sin peticiones a terceros, así que se renderizan igual sin conexión y bajo una Content-Security-Policy estricta.
- Añadir un idioma es un solo archivo gettext `.po` — las páginas y la negociación se amplían automáticamente en la siguiente construcción.

<!-- textlint-enable -->
