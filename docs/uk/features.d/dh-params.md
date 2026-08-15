<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

# Попередня генерація параметрів DH

- Файл параметрів DH на 2048 бітів генерується під час збірки, якщо його ще немає, — це усуває дорогі обчислення при першому запиті в продакшені.
- Розмір параметрів DH налаштовується через `B19_CA_DHPARAMS_SIZE`; шлях виводу — `${O9S_NGINX_TLS_PATH}/dhparams.pem`.
- Згенерований файл автоматично споживається блоком конфігурації TLS (`ssl_dhparam`).
