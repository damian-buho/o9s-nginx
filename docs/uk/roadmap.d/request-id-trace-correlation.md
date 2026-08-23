<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

<!-- textlint-disable terminology,common-misspellings -->

# Request-ID і трейс-контекст у access-логах

- **Проблема.** OTel-модуль видає трейси, і JSON-формат логів визначено, але access-логи користуються фіксованим текстовим форматом без ідентифікатора запиту чи трейса, тож рядок логу неможливо прив’язати до його трейса під час зневадження.
- **Розглядається.** Генерувати `X-Request-Id` на кожен запит (чи шанувати вхідний), відлунювати його в заголовку відповіді й упорснути його разом із `trace_id`/`span_id` OTel у вибірковий JSON access-лог.
- **Спирається на.** Змінна `$request_id` nginx і трейс-контекстні змінні скомпільованого OTel-модуля; вже визначений формат `json_combined`.

<!-- textlint-enable -->
