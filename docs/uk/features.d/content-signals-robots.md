<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

<!-- textlint-disable terminology,common-misspellings -->

# Директиви Content-Signal і robots.txt

- Файл `robots.txt` генерується при запуску зі змінних середовища — монтувати статичний файл не потрібно.
- Типову політику сканування налаштовує `O9S_NGINX_ROBOTS_TXT_DEFAULT_POLICY`: `disallow` (типово), `allow` або `none` (повністю пропустити типовий блок).
- Випускаються директиви Content-Signal згідно з contentsignals.org: `CONTENT_SIGNALS_SEARCH`, `CONTENT_SIGNALS_TRAIN`, `CONTENT_SIGNALS_INPUT` керують тим, чи дозволено індексацію пошуковиками, тренування ШІ та вхід для ШІ (`yes`/`no`).
- URL sitemap можна задати через `O9S_NGINX_ROBOTS_TXT_SITEMAP`.

<!-- textlint-enable -->
