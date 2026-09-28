<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

<!-- textlint-disable terminology,common-misspellings -->

# Valores TLS reforzados por defecto

- Solo TLS 1.2 y 1.3, con cifrados AEAD con secreto perfecto hacia adelante y renegociación desactivada.
- Los parámetros Diffie-Hellman se generan en la compilación, así el primer handshake nunca los espera.
- La versión de nginx se oculta en las cabeceras de respuesta y en las páginas de error.

<!-- textlint-enable -->
