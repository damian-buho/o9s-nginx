<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

# Módulo integrado de automatización de certificados ACME

- Se incluye un módulo cliente de ACME (compilado desde Rust) como módulo dinámico de nginx, lo que permite el aprovisionamiento automático de certificados TLS sin un agente externo.
- Se activa con `O9S_NGINX_MODULE_ACME=Y`; el bloque del emisor ACME se emite automáticamente en la configuración HTTP.
- La URL del servidor ACME (`O9S_NGINX_ACME_SERVER`) y el nombre del emisor (`O9S_NGINX_ACME_ISSUER_NAME`) son configurables, con soporte para cualquier CA compatible con ACME.
- La configuración de certificados por servidor está disponible mediante el include opt/ `enable-acme`.
