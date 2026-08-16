<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
SPDX-License-Identifier: MIT
pf-cli-managed: yes
-->

<!-- textlint-disable terminology,common-misspellings -->

[English](../../README.md) · [Español](../es/README.md)

# O9S / Nginx

Дистрибуція Nginx з підтримкою спільноти на основі B19/GCC

[![Stand with Ukraine](https://raw.githubusercontent.com/vshymanskyy/StandWithUkraine/main/badges/StandWithUkraine.svg)](https://damian-buho.github.io/support-ukraine/) [![License](https://img.shields.io/static/v1?label=license&message=MIT&color=4c1&style=flat-square)](LICENSE) ![Commit style](https://img.shields.io/static/v1?label=commits&message=conventional&color=blue&style=flat-square) ![Workflow](https://img.shields.io/static/v1?label=workflow&message=git-flow&color=blue&style=flat-square) ![Versioning](https://img.shields.io/static/v1?label=versioning&message=semantic&color=blue&style=flat-square) [![PRs welcome](https://img.shields.io/static/v1?label=PRs&message=welcome&color=4c1&style=flat-square)](CONTRIBUTING.md) [![Citation](https://img.shields.io/static/v1?label=citation&message=cff&color=blue&style=flat-square)](CITATION.cff) [![REUSE compliance](https://api.reuse.software/badge/codeberg.org/o9s/nginx)](https://api.reuse.software/info/codeberg.org/o9s/nginx)

![Project status](https://img.shields.io/static/v1?label=status&message=maintained&color=1d63ed&style=flat-square) [![Last commit](https://img.shields.io/gitea/last-commit/o9s/nginx?gitea_url=https://codeberg.org&style=flat-square)](https://codeberg.org/o9s/nginx)

[![Build status on kiota.ch](https://kiota.ch/o9s/nginx/badges/workflows/published.yaml/badge.svg)](https://kiota.ch/o9s/nginx/actions)

## Можливості

- Вбудований модуль автоматизації сертифікатів ACME
- Визначення реальної IP з урахуванням CDN
- Кілька модулів стиснення (brotli, zstd, gzip)
- Керування налаштуваннями через середовище (нуль монтувань конфігурації)
- Директиви Content-Signal і robots.txt
- Попередня генерація параметрів DH
- Модель споживання downstream-образами
- Включення-перемикачі функцій (система opt/)
- Підтримка HTTP/3 (QUIC)
- Модуль трасування OpenTelemetry
- Сканування preload-підказок
- Система каркаса для downstream-образів на основі nginx
- Передстиснення статичних ресурсів
- Ієрархія шаблонів на основі включень Jinja2
- Persistent APT cache across builds
- Service process management with log routing (b19-exec)
- Cached artifact downloads with integrity verification (b19-fetch)
- Timed command execution with failure reporting (b19-run)
- Run-once initialization (bootstrap.d)
- Modular build hooks (build.d)
- Automatic CPU count detection (NUMPROCS)
- Declarative dependency management (b19-deps)
- Pluggable startup system (entrypoint.d)
- Feature toggles for all subsystems
- Built-in health monitoring (healthcheck.d)
- Multilingual shell output (b19-i18n)
- Image lineage tracking
- Structured, level-filtered logging (b19-log)
- Non-root container by default
- Air-gapped / offline build and runtime support
- Runtime overlay injection
- Reproducible base image (pinned by digest)
- Port validation
- Unified lifecycle runner family
- Docker secrets auto-loading (secrets)
- Interactive shell hooks (shell.d)
- Graceful signal handling
- Jinja2 configuration templates (minijinja-cli)
- Built-in test framework (test.d)
- Pre-installed utility tools
- XDG Base Directory paths

Див. [FEATURES.md](FEATURES.md), щоб переглянути повний перелік.

## Що надає цей проєкт

- **Образ контейнера** `ghcr.io/damian-buho/o9s/nginx:latest`
- **Образ контейнера** `docker.io/damianbuho/o9s-nginx:latest`

## Встановлення

Завантажте опублікований образ контейнера:

```sh
docker pull ghcr.io/damian-buho/o9s/nginx:latest
docker pull docker.io/damianbuho/o9s-nginx:latest
```

Якщо наведені вище реєстри недоступні, завантажте з джерела:

```sh
docker pull kiota.ch/o9s/nginx:latest
```

## Використання

Запустіть стек локально:

```sh
make dc-up
make dc-logs
make dc-down
```

## Збирання

- [Довідник із Makefile](../MAKEFILE.md)

Точки входу конвеєра:

- `make analyze` — Run the heavy analysis sweep (mutation testing, benchmarks)
- `make audited` — Re-scan the pinned dependencies and published artifacts for new vulnerabilities
- `make check-outdated` — Report every pinned dependency that lags upstream
- `make ready-to-publish` — Run the pseudo-CI pipeline locally — build, test and scan, without publishing

Виконайте `make` без аргументів для типової цілі; виконайте `make help`, щоб переглянути всі цілі.

Для локального циклу розробки `make dev-container` піднімає dev-container.

## Дорожня карта

Див. [ROADMAP.md](../../ROADMAP.md), щоб дізнатися про заплановане.

## Політики

- [Як зробити внесок](CONTRIBUTING.md)
- [Політика безпеки](SECURITY.md)
- [Як отримати підтримку](SUPPORT.md)
- [Кодекс поведінки](CODE_OF_CONDUCT.md)

## Посилання

### Проєкт

- [Специфікація Projectfile](https://projectfile.org)
- [O9S / Nginx на Codeberg](https://codeberg.org/o9s/nginx)
- [O9S / Nginx на GitHub](https://github.com/damian-buho/o9s-nginx)
- [O9S / Nginx на kiota.ch](https://kiota.ch/o9s/nginx)
- [Issues на Codeberg](https://codeberg.org/o9s/nginx/issues)
- [Issues на GitHub](https://github.com/damian-buho/o9s-nginx/issues)
- [Packages on crates.io](https://crates.io/crates/nginx)

### Інше

- [Від автора](https://dbuho.me)

## Ліцензія

Цей проєкт ліцензовано на умовах MIT — див. файл [LICENSE](LICENSE) для подробиць.

*Згенеровано з projectfile ([дізнатися як](https://projectfile.org/how-to/readme))*
<!-- textlint-enable -->
