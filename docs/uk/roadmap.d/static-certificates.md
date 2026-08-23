<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

<!-- textlint-disable terminology,common-misspellings -->

# Змонтовані TLS-сертифікати з dev-запасом

- **Проблема.** Єдине джерело сертифікатів — вбудований ACME-модуль, якому потрібні справжній домен і DNS- чи HTTP-валідація; оператор із наявними сертифікатами, внутрішньою CA чи простою потребою HTTPS на localhost не має шляху через середовище й мусить писати include вручну.
- **Розглядається.** Пара сертифікатів зі середовища (`O9S_NGINX_SSL_CERT` / `_KEY`), що підключає `ssl_certificate` і `ssl_certificate_key` крізь наявну TLS-комірку server-блоку, плюс одно-прапорцевий генератор самопідписаних сертифікатів для локальної розробки.
- **Спирається на.** Директиви `ssl_certificate` nginx і наявна комірка `O9S_NGINX_SSL_ENABLED`; автозавантаження Docker-секретів b19 для ключового матеріалу.

<!-- textlint-enable -->
