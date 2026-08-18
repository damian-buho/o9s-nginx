<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

<!-- textlint-disable terminology,common-misspellings -->

# Сканування preload-підказок

- При запуску контейнера кореневий каталог документів сканується на ресурси CSS, JavaScript, зображення та шрифти, автоматично генеруючи заголовки попереднього завантаження `<Link>`.
- Сканування вмикається за бажанням через `O9S_NGINX_PH_SCAN_ENABLED=Y`; окремі типи ресурсів (style, script, image, font) перемикаються незалежно.
- Шлях сканування налаштовується через `O9S_NGINX_PH_SCAN_PATH` (типово `assets`).
- Знайдені ресурси записуються в JSON-сайдкар, який споживає шаблон Jinja2, утворюючи заголовки `Link: <...>; rel=preload; as=...` у HTML-відповідях.

<!-- textlint-enable -->
