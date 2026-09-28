<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

<!-- textlint-disable terminology,common-misspellings -->

# Трасування OpenTelemetry і журнали доступу в JSON

- Кожен запит можна експортувати як span до будь-якого колектора OpenTelemetry, а контекст трасування можна передавати бекенду.
- Вимкнено за замовчуванням, тож накладних витрат немає, доки трасування не потрібне; кожен сайт підключається окремо.
- Вбудовано формат журналу доступу в JSON для конвеєрів, що розбирають структуровані рядки.

<!-- textlint-enable -->
