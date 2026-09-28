<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

<!-- textlint-disable terminology,common-misspellings -->

# Вбудована автоматизація сертифікатів ACME

- nginx сам отримує й оновлює свої TLS-сертифікати — без контейнера certbot, без cron, без скрипту перезавантаження.
- Працює з будь-яким центром сертифікації, сумісним з ACME, а не лише з Let’s Encrypt.
- Вимкнено за замовчуванням; один перемикач вмикає його, і кожен сайт підключається окремо.

<!-- textlint-enable -->
