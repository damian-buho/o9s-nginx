<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

# Включення-перемикачі функцій (система opt/)

- Самодостатні фрагменти nginx у `includes/opt/` умовно включаються для кожного серверного блоку через `O9S_NGINX_INCLUDE_OPTIONAL` (список назв, розділених пробілами).
- Доступні перемикачі: CORS (`enable-cors`, 6 змінних), Content-Security-Policy (`enable-csp`, 18 змінних), HSTS (`enable-hsts`), Permissions-Policy (`enable-permissions-policy`, 12 змінних), stub status (`enable-status`), сертифікат ACME (`enable-acme`), OTel на сервер (`enable-otel`), cache-control (`enable-cache`), favicon (`enable-favicon`), шляхи certbot (`enable-certbot`), X-Frame-Options DENY (`enable-sameorigin`), X-Content-Type-Options nosniff (`enable-nosniff`), перенаправлення HTTP на HTTPS (`redirect-to-https`).
- Кожен перемикач керується виключно через ENV — редагувати файли конфігурації nginx не потрібно.
- Downstream-образи можуть додавати нові opt/-фрагменти, поклавши файл `.nginx` або `.nginx.j2` у `includes/opt/`.
