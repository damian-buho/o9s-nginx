<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

<!-- textlint-disable terminology,common-misspellings -->

# Resolución de IP real consciente de CDN

- Los rangos de IP de proxies de confianza de los principales CDN se obtienen en vivo en cada arranque del contenedor, garantizando que las listas `set_real_ip_from` estén siempre actualizadas.
- Modos de CDN admitidos (`O9S_NGINX_REALIP_MODE`): `cloudflare` (cabecera CF-Connecting-IP), `akamai` (True-Client-IP), `aws` (rangos de CloudFront + ELB, X-Forwarded-For), `fastly` (Fastly-Client-IP).
- También hay modos sin CDN: `docker` (rangos estáticos de la RFC 1918), `custom` (subred especificada por el usuario mediante `O9S_NGINX_REALIP_NETWORK`), `localhost`.
- El `real_ip_header` apropiado se establece automáticamente según el modo de CDN.
- La obtención de IP se omite en modo inmutable (`B19_IMMUTABLE=Y`).

<!-- textlint-enable -->
