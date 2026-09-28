<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

<!-- textlint-disable terminology,common-misspellings -->

# Заголовки безпеки

- Content-Security-Policy, HSTS, Permissions-Policy, Cross-Origin-Embedder-Policy, Reporting-Endpoints, `nosniff` і захист від вбудовування у фрейми вмикаються кожен одним перемикачем, із суворими значеннями за замовчуванням.
- Дочірні образи додають до політики хеші власних вбудованих скриптів, тож сувора CSP не потребує `'unsafe-inline'`.
- Заголовки надсилаються й у відповідях з помилками, тож сторінка 404 чи 502 захищена так само, як сайт.
- На попередні запити CORS nginx відповідає сам, не звертаючись до бекенду.
- Перенаправлення з HTTP на HTTPS доступне для кожного сайту.

<!-- textlint-enable -->
