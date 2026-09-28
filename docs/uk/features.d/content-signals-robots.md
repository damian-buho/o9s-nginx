<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

<!-- textlint-disable terminology,common-misspellings -->

# robots.txt із Content Signals для ШІ

- `robots.txt` генерується під час запуску — жодного файлу, який треба монтувати чи підтримувати для кожного середовища.
- Сканування заборонене за замовчуванням, тож тестове розгортання ніколи не потрапить в індекс випадково.
- Видає Content Signals (contentsignals.org), щоб оголосити, чи дозволені пошукова індексація, навчання ШІ та використання як вхідних даних для ШІ.
- Посилання на sitemap додається, якщо його вказано.

<!-- textlint-enable -->
