<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
SPDX-License-Identifier: MIT
pf-cli-managed: yes
-->

<!-- textlint-disable terminology,common-misspellings -->

[English](../../README.md) · [Español](../es/README.md)

# O9S / Nginx

Дистрибуція Nginx з підтримкою спільноти, зібрана на основі B19/GCC. Цей репозиторій містить лише пакування — Dockerfile, скрипти збирання та конфігурацію, усе під ліцензією MIT; вихідний код Nginx отримують під час збирання, і він зберігає власну ліцензію.

[![Stand with Ukraine](https://raw.githubusercontent.com/vshymanskyy/StandWithUkraine/main/badges/StandWithUkraine.svg)](https://damian-buho.github.io/support-ukraine/) [![Projectfile inside](https://badges.kiota.ch/static/v1?label=projectfile&message=inside&labelColor=0d0d0d&color=8c6723&style=flat-square)](https://projectfile.org) [![License](https://badges.kiota.ch/static/v1?label=license&message=MIT&color=1e5913&style=flat-square)](LICENSE) [![PRs welcome](https://badges.kiota.ch/static/v1?label=PRs&message=welcome&color=1e5913&style=flat-square)](CONTRIBUTING.md) [![REUSE compliance](https://api.reuse.software/badge/github.com/damian-buho/o9s-nginx)](https://api.reuse.software/info/github.com/damian-buho/o9s-nginx)

![Project status](https://badges.kiota.ch/static/v1?label=status&message=maintained&color=1d63ed&style=flat-square) [![Last commit on GitHub](https://badges.kiota.ch/github/last-commit/damian-buho/o9s-nginx?label=last%20commit%20on%20GitHub&style=flat-square)](https://github.com/damian-buho/o9s-nginx) [![Last commit on kiota.ch](https://badges.kiota.ch/gitea/last-commit/o9s/nginx?gitea_url=https://kiota.ch&label=last%20commit%20on%20kiota.ch&style=flat-square)](https://kiota.ch/o9s/nginx)

[![Publish pipeline on GitHub](https://github.com/damian-buho/o9s-nginx/actions/workflows/published.yaml/badge.svg?style=flat-square)](https://github.com/damian-buho/o9s-nginx/actions) [![Vulnerability audit on GitHub](https://github.com/damian-buho/o9s-nginx/actions/workflows/audited.yaml/badge.svg?style=flat-square)](https://github.com/damian-buho/o9s-nginx/actions) [![Dependency freshness on GitHub](https://github.com/damian-buho/o9s-nginx/actions/workflows/check-outdated.yaml/badge.svg?style=flat-square)](https://github.com/damian-buho/o9s-nginx/actions) [![Analysis sweep on GitHub](https://github.com/damian-buho/o9s-nginx/actions/workflows/analyzed.yaml/badge.svg?style=flat-square)](https://github.com/damian-buho/o9s-nginx/actions)

[![Publish pipeline on kiota.ch](https://kiota.ch/o9s/nginx/badges/workflows/published.yaml/badge.svg?style=flat-square)](https://kiota.ch/o9s/nginx/actions) [![Vulnerability audit on kiota.ch](https://kiota.ch/o9s/nginx/badges/workflows/audited.yaml/badge.svg?style=flat-square)](https://kiota.ch/o9s/nginx/actions) [![Dependency freshness on kiota.ch](https://kiota.ch/o9s/nginx/badges/workflows/check-outdated.yaml/badge.svg?style=flat-square)](https://kiota.ch/o9s/nginx/actions) [![Analysis sweep on kiota.ch](https://kiota.ch/o9s/nginx/badges/workflows/analyzed.yaml/badge.svg?style=flat-square)](https://kiota.ch/o9s/nginx/actions)

## Можливості

- Вбудована автоматизація сертифікатів ACME
- Справжня IP-адреса клієнта за CDN
- Стиснення Brotli, zstd і gzip
- Налаштування лише через змінні оточення
- robots.txt із Content Signals для ШІ
- Основа для образів на базі nginx
- Локалізовані самодостатні сторінки помилок
- HTTP/3 (QUIC)
- Правильні типи вмісту й кешування
- Трасування OpenTelemetry і журнали доступу в JSON
- Автоматичні підказки ресурсів
- Заголовки безпеки
- Перевірка конфігурації та перевірки стану з урахуванням nginx
- Готові режими обслуговування
- Попереднє стиснення статичних ресурсів
- Посилені налаштування TLS за замовчуванням

Також успадковує можливості B19 / Ubuntu — повний перелік див. у [Можливості](FEATURES.md).

## Швидкий старт

Збережіть це як `compose.yaml`:

```yaml
---
services:
  nginx:
    image: docker.io/damianbuho/o9s-nginx:latest
    ports:
      - "8080:8080"
    cap_drop: [ALL]
    security_opt: [no-new-privileges:true]
    restart: unless-stopped
```

Потім запустіть його командою `docker compose up --detach`.

## Що надає цей проєкт

- **Образ контейнера** `ghcr.io/damian-buho/o9s/nginx:latest`
- **Образ контейнера** `damianbuho/o9s-nginx:latest`
- **Служба** `nginx` — слухає на `8080 (http)` — Вебсервер nginx

## Встановлення

Завантажте опублікований образ контейнера:

### Завантажити з GHCR — linux/amd64, linux/arm64

```sh
docker pull ghcr.io/damian-buho/o9s/nginx:latest
```

### Завантажити з DockerHub — linux/amd64

```sh
docker pull damianbuho/o9s-nginx:latest
```

Стабільні випуски також публікують теґи `X.Y.Z`, `X.Y` і `X` — завантажте той рівень точності, який хочете зафіксувати.

Якщо наведені вище реєстри недоступні, завантажте з джерела:

### Завантажити з Kiota — linux/amd64

```sh
docker pull kiota.ch/o9s/nginx:latest
```

## Використання

Запустіть сервіс у фоновому режимі, опублікувавши його порти:

### З GHCR

```sh
docker run --detach --publish 8080:8080/tcp ghcr.io/damian-buho/o9s/nginx:latest
```

### З DockerHub

```sh
docker run --detach --publish 8080:8080/tcp damianbuho/o9s-nginx:latest
```

Потім перевірте, що він відповідає:

```sh
curl http://localhost:8080/
```

## Збирання

Клонуйте репозиторій разом із підмодулями:

```sh
git clone --recurse-submodules https://github.com/damian-buho/o9s-nginx nginx && cd nginx
```

Зберіть образ контейнера локально:

```sh
make container-build
```

- [Довідник із Makefile](../how-to/MAKEFILE.md)

Виконайте `make` без аргументів для типової цілі; виконайте `make help`, щоб переглянути всі цілі.

Для локального циклу розробки `make dev-container` піднімає dev-container.

Точки входу конвеєра:

- `make analyzed` — Запускає важкий аналіз (мутаційне тестування, бенчмарки)
- `make audited` — Повторно сканує закріплені залежності й опубліковані артефакти на нові вразливості
- `make check-outdated` — Звітує про кожну закріплену залежність, що відстає від upstream
- `make ready-to-publish` — Запускає псевдо-CI локально — збирає, тестує й сканує без публікації

## Дорожня карта

Див. [Дорожня карта](../ROADMAP.md), щоб дізнатися про заплановане.

## Політики

- [Як зробити внесок](CONTRIBUTING.md)
- [Політика безпеки](SECURITY.md)
- [Як отримати підтримку](SUPPORT.md)
- [Кодекс поведінки](CODE_OF_CONDUCT.md)
- [Політика щодо ШІ та LLM](AI_POLICY.md)

## Посилання

- [Специфікація Projectfile](https://projectfile.org)

## Ліцензія

Цей проєкт ліцензовано на умовах MIT — див. файл [LICENSE](LICENSE) для подробиць.

<!-- textlint-enable -->
