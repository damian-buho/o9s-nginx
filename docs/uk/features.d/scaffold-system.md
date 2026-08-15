<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

# Система каркаса для downstream-образів на основі nginx

- Каталог `scaffold/` надає шаблон Dockerfile і `stack.conf` для бутстрапу нових проєктів на основі nginx.
- Використовує інтеграцію стеку m6e (`STACK_ROOT_STAGE=base`, `STACK_EXTENSIONS=nginx`), тож нові проєкти автоматично успадковують повний конвеєр збірки.
- Downstream-проєктам достатньо перевизначити окремі значення `ENV` і за потреби додати власні файли `includes/` — базовий Dockerfile, entrypoint, перевірка стану та ієрархія шаблонів успадковуються повністю.
