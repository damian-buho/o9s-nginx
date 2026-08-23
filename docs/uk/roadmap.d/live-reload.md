<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

<!-- textlint-disable terminology,common-misspellings -->

# Живе перезавантаження без розриву з’єднань

- **Проблема.** Конфігурацію minijinja відрендерено лише на старті, тож зміна будь-якого значення `O9S_NGINX_*` чи include-файла означає перезапуск контейнера й обрив виконуваних запитів.
- **Розглядається.** Переслати SIGHUP (і опційний inotify-нагляд за деревом include) для повторного рендеру шаблонів `.j2` і запуску `nginx -s reload`, оновлюючи слухачі й server-блоки без перезапуску процесу.
- **Спирається на.** Рідний сигнал reload nginx; крок рендеру, що вже викликається на старті; пересилання групових сигналів tini.

<!-- textlint-enable -->
