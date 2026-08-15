<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

# Soporte de HTTP/3 (QUIC)

- nginx se compila desde el código fuente con soporte completo de HTTP/3 (QUIC), activado por defecto (`O9S_NGINX_HTTP3=on`).
- La cabecera `Alt-Svc` se emite automáticamente, anunciando el puerto QUIC para que los navegadores compatibles pasen a HTTP/3 de forma transparente.
- Las opciones de transporte de QUIC son ajustables por ENV: GSO (`O9S_NGINX_QUIC_GSO`), retry (`O9S_NGINX_QUIC_RETRY`), BPF (`O9S_NGINX_QUIC_BPF`), flujos concurrentes máximos y tamaño del búfer de flujo.
- HTTP/2 y HTTP/3 escuchan en el mismo puerto (directivas `listen` separadas para `ssl` y `quic`), con todas las opciones de socket configurables de forma independiente.
