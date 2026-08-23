<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

<!-- textlint-disable terminology,common-misspellings -->

# Certificados TLS montados con respaldo de desarrollo

- **Problema.** La única fuente de certificados es el módulo ACME incorporado, que necesita un dominio real y validación DNS o HTTP; un operador con certificados existentes, una CA interna o una simple necesidad de HTTPS en localhost no tiene ruta de entorno y debe escribir includes a mano.
- **En estudio.** Un par de certificados gobernado por entorno (`O9S_NGINX_SSL_CERT` / `_KEY`) que cablee `ssl_certificate` y `ssl_certificate_key` a través de la compuerta existente de bloque server TLS, más un generador autofirmado de un solo interruptor para desarrollo local.
- **Depende de.** Las directivas `ssl_certificate` de nginx y la compuerta `O9S_NGINX_SSL_ENABLED` existente; la autocarga de secretos Docker de b19 para el material de claves.

<!-- textlint-enable -->
