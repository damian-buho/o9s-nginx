<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

<!-- textlint-disable terminology,common-misspellings -->

# Правильні типи вмісту й кешування

- Текст віддається як UTF-8, тож символи з діакритикою коректно відображаються у звичайному тексті, Markdown і CSV.
- Сучасні типи файлів, яких бракує у стандартному nginx, отримують правильний тип: модулі JavaScript, субтитри, вебманіфести, зображення JPEG XL і HEIC, аудіо Opus/FLAC, YAML і TOML — браузер показує їх, а не завантажує.
- Статичні ресурси отримують довготривале кешування в браузері за типом вмісту, а HTML щоразу перевіряється повторно.

<!-- textlint-enable -->
