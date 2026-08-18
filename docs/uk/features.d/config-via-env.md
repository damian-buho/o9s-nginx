<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

<!-- textlint-disable terminology,common-misspellings -->

# Керування налаштуваннями через середовище (нуль монтувань конфігурації)

- Кожною директивою nginx керують понад 200 змінних середовища `O9S_NGINX_*` із розумними типовими значеннями, вбудованими в Dockerfile — образ повністю працездатний із `docker run` і без змонтованих файлів конфігурації.
- Downstream-образи та compose-файли тюнять nginx лише перевизначеннями `environment:` або `ENV`; монтування томів у `/etc/nginx/` і файли `.conf` не потрібні.
- Усі шаблони рендеряться при запуску стандартним hook-ом рендерингу Jinja2; кожна змінна ENV контейнера доступна як `ENV.VAR_NAME`.
- Категорії змінних охоплюють порти, HTTP/2+3, стиснення, проксі, FastCGI, TLS, журналювання, кешування, CSP, CORS, Permissions-Policy, реальну IP, OpenTelemetry та параметри сокетів.

<!-- textlint-enable -->
