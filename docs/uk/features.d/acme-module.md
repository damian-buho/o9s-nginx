<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

<!-- textlint-disable terminology,common-misspellings -->

# Вбудований модуль автоматизації сертифікатів ACME

- Модуль клієнта ACME (скомпільований із Rust) входить як динамічний модуль nginx, уможливлюючи автоматичне отримання TLS-сертифікатів без зовнішнього агента.
- Активація — через `O9S_NGINX_MODULE_ACME=Y`; блок ACME-емітента автоматично вписується в HTTP-конфігурацію.
- URL сервера ACME (`O9S_NGINX_ACME_SERVER`) та назва емісента (`O9S_NGINX_ACME_ISSUER_NAME`) налаштовуються, що підтримує будь-яку ACME-сумісну CA.
- Налаштування сертифікатів для окремого сервера доступне через opt/-включення `enable-acme`.

<!-- textlint-enable -->
