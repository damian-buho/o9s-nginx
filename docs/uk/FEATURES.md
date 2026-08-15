<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
SPDX-License-Identifier: MIT
-->

<!-- textlint-disable terminology,common-misspellings -->

[English](../../FEATURES.md) · [Español](../es/FEATURES.md)

# Можливості

## Можливості проєкту

### Вбудований модуль автоматизації сертифікатів ACME

- Модуль клієнта ACME (скомпільований із Rust) входить як динамічний модуль nginx, уможливлюючи автоматичне отримання TLS-сертифікатів без зовнішнього агента.
- Активація — через `O9S_NGINX_MODULE_ACME=Y`; блок ACME-емітента автоматично вписується в HTTP-конфігурацію.
- URL сервера ACME (`O9S_NGINX_ACME_SERVER`) та назва емісента (`O9S_NGINX_ACME_ISSUER_NAME`) налаштовуються, що підтримує будь-яку ACME-сумісну CA.
- Налаштування сертифікатів для окремого сервера доступне через opt/-включення `enable-acme`.

### Визначення реальної IP з урахуванням CDN

- Діапазони IP довірених проксі великих CDN отримуються наживо при кожному запуску контейнера, тож списки `set_real_ip_from` завжди актуальні.
- Підтримувані режими CDN (`O9S_NGINX_REALIP_MODE`): `cloudflare` (заголовок CF-Connecting-IP), `akamai` (True-Client-IP), `aws` (діапазони CloudFront + ELB, X-Forwarded-For), `fastly` (Fastly-Client-IP).
- Доступні й режими без CDN: `docker` (статичні діапазони RFC 1918), `custom` (підмережа користувача через `O9S_NGINX_REALIP_NETWORK`), `localhost`.
- Відповідний `real_ip_header` встановлюється автоматично під кожен режим CDN.
- У незмінному режимі (`B19_IMMUTABLE=Y`) отримання IP пропускається.

### Кілька модулів стиснення (brotli, zstd, gzip)

- Три алгоритми стиснення скомпільовані як динамічні модулі та завантажуються умовно через `O9S_NGINX_MODULE_{BROTLI,ZSTD}` (обидва типово увімкнені; gzip вбудований у ядро nginx).
- Для кожного алгоритму є незалежні перемикачі вмикання/вимикання та рівні стиснення, якими можна керувати під час виконання.
- Рівні динамічного стиснення можуть відрізнятися від рівнів передстиснення: у рантаймі застосовуються нижчі рівні для економії CPU, передстиснення використовує максимальний.
- Спільний список MIME-типів (`O9S_NGINX_COMPRESS_TYPES`) визначає, які типи вмісту підлягають стисненню в усіх трьох алгоритмах.
- Передстиснуті файли `.br`, `.zst` і `.gz` віддаються напряму відповідними модулями `*_static`, якщо наявні (див. статичне передстиснення).

### Керування налаштуваннями через середовище (нуль монтувань конфігурації)

- Кожною директивою nginx керують понад 200 змінних середовища `O9S_NGINX_*` із розумними типовими значеннями, вбудованими в Dockerfile — образ повністю працездатний із `docker run` і без змонтованих файлів конфігурації.
- Downstream-образи та compose-файли тюнять nginx лише перевизначеннями `environment:` або `ENV`; монтування томів у `/etc/nginx/` і файли `.conf` не потрібні.
- Усі шаблони рендеряться при запуску стандартним hook-ом рендерингу Jinja2; кожна змінна ENV контейнера доступна як `ENV.VAR_NAME`.
- Категорії змінних охоплюють порти, HTTP/2+3, стиснення, проксі, FastCGI, TLS, журналювання, кешування, CSP, CORS, Permissions-Policy, реальну IP, OpenTelemetry та параметри сокетів.

### Директиви Content-Signal і robots.txt

- Файл `robots.txt` генерується при запуску зі змінних середовища — монтувати статичний файл не потрібно.
- Типову політику сканування налаштовує `O9S_NGINX_ROBOTS_TXT_DEFAULT_POLICY`: `disallow` (типово), `allow` або `none` (повністю пропустити типовий блок).
- Випускаються директиви Content-Signal згідно з contentsignals.org: `CONTENT_SIGNALS_SEARCH`, `CONTENT_SIGNALS_TRAIN`, `CONTENT_SIGNALS_INPUT` керують тим, чи дозволено індексацію пошуковиками, тренування ШІ та вхід для ШІ (`yes`/`no`).
- URL sitemap можна задати через `O9S_NGINX_ROBOTS_TXT_SITEMAP`.

### Попередня генерація параметрів DH

- Файл параметрів DH на 2048 бітів генерується під час збірки, якщо його ще немає, — це усуває дорогі обчислення при першому запиті в продакшені.
- Розмір параметрів DH налаштовується через `B19_CA_DHPARAMS_SIZE`; шлях виводу — `${O9S_NGINX_TLS_PATH}/dhparams.pem`.
- Згенерований файл автоматично споживається блоком конфігурації TLS (`ssl_dhparam`).

### Модель споживання downstream-образами

- Дочірні образи успадковують усі понад 200 типових ENV, ієрархію шаблонів, entrypoint-хуки, перевірки стану та логіку передстиснення з єдиного рядка `FROM`.
- Налаштування зводиться до перевизначення окремих значень `ENV` у дочірньому Dockerfile (наприклад, `O9S_NGINX_INDEX_TYPE=cache`, тривалості кешування, хост/порт backend).
- Нові обробники вмісту додаються розміщенням файлу `.nginx.j2` у `includes/index/` із заданням `O9S_NGINX_INDEX_TYPE` — шлях включення динамічний.
- Нові перемикачі функцій додаються розміщенням файлу в `includes/opt/` і зазначенням його назви в `O9S_NGINX_INCLUDE_OPTIONAL`.
- Монтування файлів конфігурації ніколи не потрібні — модель суто ENV від базового образу до всіх downstream-похідних.

### Включення-перемикачі функцій (система opt/)

- Самодостатні фрагменти nginx у `includes/opt/` умовно включаються для кожного серверного блоку через `O9S_NGINX_INCLUDE_OPTIONAL` (список назв, розділених пробілами).
- Доступні перемикачі: CORS (`enable-cors`, 6 змінних), Content-Security-Policy (`enable-csp`, 18 змінних), HSTS (`enable-hsts`), Permissions-Policy (`enable-permissions-policy`, 12 змінних), stub status (`enable-status`), сертифікат ACME (`enable-acme`), OTel на сервер (`enable-otel`), cache-control (`enable-cache`), favicon (`enable-favicon`), шляхи certbot (`enable-certbot`), X-Frame-Options DENY (`enable-sameorigin`), X-Content-Type-Options nosniff (`enable-nosniff`), перенаправлення HTTP на HTTPS (`redirect-to-https`).
- Кожен перемикач керується виключно через ENV — редагувати файли конфігурації nginx не потрібно.
- Downstream-образи можуть додавати нові opt/-фрагменти, поклавши файл `.nginx` або `.nginx.j2` у `includes/opt/`.

### Підтримка HTTP/3 (QUIC)

- nginx компілюється з вихідного коду з повною підтримкою HTTP/3 (QUIC), типово увімкненою (`O9S_NGINX_HTTP3=on`).
- Заголовок `Alt-Svc` випускається автоматично, оголошуючи порт QUIC, щоб сумісні браузери прозоро переходили на HTTP/3.
- Параметри транспорту QUIC налаштовуються через ENV: GSO (`O9S_NGINX_QUIC_GSO`), retry (`O9S_NGINX_QUIC_RETRY`), BPF (`O9S_NGINX_QUIC_BPF`), максимальна кількість паралельних потоків і розмір буфера потоку.
- HTTP/2 і HTTP/3 слухають той самий порт (окремі директиви `listen` для `ssl` і `quic`), усі параметри сокетів налаштовуються незалежно.

### Модуль трасування OpenTelemetry

- Модуль OpenTelemetry скомпільований як динамічний модуль nginx для експорту розподіленого трасування через OTLP/gRPC.
- Активація — через `O9S_NGINX_MODULE_OTEL=Y`; типово вимкнено, щоб уникати накладних витрат, коли трасування не потрібне.
- Ендпоінт OTLP (`O9S_OTEL_ENDPOINT`), назва служби (`O9S_OTEL_SERVICE_NAME`) і поширення контексту трасування налаштовуються через ENV.
- Підтримуються тюнінг експортера (інтервал, розмір і кількість пакетів) та власні атрибути span.
- Трасування для окремого сервера вмикається через opt/-включення `enable-otel`.

### Сканування preload-підказок

- При запуску контейнера кореневий каталог документів сканується на ресурси CSS, JavaScript, зображення та шрифти, автоматично генеруючи заголовки попереднього завантаження `<Link>`.
- Сканування вмикається за бажанням через `O9S_NGINX_PH_SCAN_ENABLED=Y`; окремі типи ресурсів (style, script, image, font) перемикаються незалежно.
- Шлях сканування налаштовується через `O9S_NGINX_PH_SCAN_PATH` (типово `assets`).
- Знайдені ресурси записуються в JSON-сайдкар, який споживає шаблон Jinja2, утворюючи заголовки `Link: <...>; rel=preload; as=...` у HTML-відповідях.

### Система каркаса для downstream-образів на основі nginx

- Каталог `scaffold/` надає шаблон Dockerfile і `stack.conf` для бутстрапу нових проєктів на основі nginx.
- Використовує інтеграцію стеку m6e (`STACK_ROOT_STAGE=base`, `STACK_EXTENSIONS=nginx`), тож нові проєкти автоматично успадковують повний конвеєр збірки.
- Downstream-проєктам достатньо перевизначити окремі значення `ENV` і за потреби додати власні файли `includes/` — базовий Dockerfile, entrypoint, перевірка стану та ієрархія шаблонів успадковуються повністю.

### Передстиснення статичних ресурсів

- Статичні файли передстискаються у трьох форматах (gzip через pigz, brotli, zstd), тож nginx віддає готові `.gz`/`.br`/`.zst` файли напряму — без витрат CPU на кожен запит.
- Стиснення типово виконується під час збірки (успадковуваний hook `.i.sh` поширюється на downstream-образи) і за бажанням ще раз при старті контейнера.
- Розширення файлів для стиснення налаштовуються (`O9S_NGINX_PRECOMPRESS_EXTENSIONS`); вихідні файли шаблонів Jinja2 виключаються автоматично.
- Для кожного алгоритму є незалежні перемикачі та рівні стиснення (передстиснення використовує максимальні рівні: gzip 9, brotli 11, zstd 19).
- Окрема команда `compress-static-assets` доступна для ручного запуску на будь-якому каталозі.

### Ієрархія шаблонів на основі включень Jinja2

- Усе дерево конфігурації nginx існує як шаблони Jinja2 (`.j2`) у `${XDG_CONFIG_HOME}/`, скомпоновані директивами `include` — без монолітного файлу конфігурації.
- Блок `http {}` підтягує 24 пронумеровані фрагменти (`includes/http/*.nginx`), відсортовані за префіксом: ядро, AIO, DNS, стиснення, ACME, клієнт/введення-виведення, HTTP/2+3, keepalive, проксі, кешування, TLS, журналювання, реальна IP та OpenTelemetry.
- Серверні блоки компонуються з модульних включень: `listen/` (конфігурація сокета), `server/` (сторінки помилок, ETag, DNS-prefetch, preload-підказки), `index/` (обробник вмісту), `opt/` (перемикачі функцій) і `realip/` (визначення IP з урахуванням CDN).
- Шаблони з умовною логікою використовують блоки Jinja2 `{% if %}`; безумовні фрагменти — звичайні файли `.nginx`, що рендеряться як є.
- Нові поведінки додаються розміщенням файлу у відповідному каталозі `includes/` — редагувати наявні шаблони не потрібно.

## Успадковано від B19/Ubuntu 1.0.0

### Persistent APT cache across builds

- APT package and index caches survive across builds via BuildKit cache mounts, keyed by Ubuntu series and architecture.
- Repeated builds reuse downloaded packages instead of re-downloading.
- Optional LAN APT cacher proxy auto-detection for environments with a caching proxy.

### Service process management with log routing (b19-exec)

- Long-running processes (daemons, servers) have stdout and stderr automatically routed through the structured logger.
- The service PID is tracked for signal forwarding -- Docker stop gracefully terminates the main process.
- Log levels for stdout and stderr streams are independently configurable.
- Exit code of the service is captured and available to downstream hooks.

### Cached artifact downloads with integrity verification (b19-fetch)

- All external downloads go through a three-tier cache: local `.fetch/` directory, BuildKit persistent cache, then upstream via aria2c with up to 16 connections.
- Optional SHA-512 verification at every tier; hash mismatch causes fallthrough to the next tier rather than failure.
- Offgrid mode blocks all downloads entirely, failing fast with a clear error if a cache miss occurs.
- Supports a near-cache proxy for LAN-only builds that route through a caching proxy.

### Timed command execution with failure reporting (b19-run)

- Any command can be wrapped to get automatic elapsed-time measurement and success/failure reporting.
- Success output is visible only at higher verbosity levels; failure output is always shown.
- In debug mode, command output streams live instead of being buffered.

### Run-once initialization (bootstrap.d)

- One-time setup tasks (database migrations, admin user creation, directory init) run on first container start only.
- Automatic idempotency: completed scripts are never re-run, even across container restarts.
- Failed scripts are retried on next start; successful ones stay locked.
- State can be reset by clearing a volume, triggering a full re-bootstrap.
- Downstream images add their own init scripts by dropping them into a directory.

### Modular build hooks (build.d)

- All image build logic lives in numbered shell scripts instead of inline Dockerfile `RUN` commands.
- Hooks are organized in `pre/on/post` phases and auto-discovered by the stage name passed to `build-stage`.
- The reserved `always/{pre,post}` scope brackets every stage, whatever it is named, so cross-cutting setup is written once instead of per stage.
- Inheritable hooks propagate to downstream images automatically via Docker layer overlay -- downstream gets parent’s build logic for free.
- Non-inheritable hooks are cleaned up after execution to prevent leaking into later stages.

### Automatic CPU count detection (NUMPROCS)

- Available CPUs are detected automatically with Kubernetes downward API, cgroups v2, or `nproc` fallback.
- The detected count is available as `NUMPROCS` throughout the build and runtime, used for parallel compilation, template rendering, and test execution.
- Eliminates hardcoded job counts and ensures consistent parallelism across Docker, Kubernetes, and CI.

### Declarative dependency management (b19-deps)

- External dependency metadata (URL, version, SHA-512 hash) stored as plain text files, completely separate from build scripts.
- Supports architecture-specific downloads, multi-version series, and nested component paths.
- Dependencies are auto-discovered at Makefile parse time -- add files to the right directory and the build picks them up without manual declarations.
- `make fetch` pre-downloads everything for offline builds; version bumps trigger automatic re-fetch and hash updates.

### Pluggable startup system (entrypoint.d)

- Every container startup runs through a sequence of numbered hooks: signal setup, secrets loading, CPU detection, port validation, template rendering, bootstrap, service start.
- Ad-hoc commands (`docker run img command`) automatically bypass part of the startup chain and execute directly.
- Individual hooks or the entire entrypoint can be skipped at runtime via environment variables, no image rebuild needed.
- Downstream images override a single hook (slot 5000) to launch their service; everything else is inherited.

### Feature toggles for all subsystems

- Every major subsystem (entrypoint, healthchecks, bootstrap, tests, secrets, port validation, i18n, shell hooks) can be disabled at runtime via environment variables.
- Individual entrypoint and bootstrap hooks can be skipped by name without disabling the whole subsystem.
- No image rebuild required -- toggles are runtime-only.

### Built-in health monitoring (healthcheck.d)

- Docker-native healthcheck declared in the base image and inherited by all downstream images with no extra configuration.
- Seven default checks: disk space on home, cache, and temp directories; HTTPS connectivity, DNS resolution, ICMP ping; and filesystem writability.
- Network checks are fault-tolerant -- success on any target counts as pass.
- All network checks automatically skip in offgrid mode; all checks can be disabled at runtime.
- Downstream images add service-specific checks (HTTP endpoints, database connections, process liveness) by dropping scripts into a directory.

### Multilingual shell output (b19-i18n)

- All user-facing log messages and script output are translatable via GNU gettext.
- Ships with English, Spanish (`es_CL`), and Ukrainian (`uk_UA`) out of the box.
- Downstream images inherit all parent translations automatically; only new or overridden strings need translating.
- Translations are compiled at build time with no runtime overhead.

### Image lineage tracking

- Every image records its build metadata (namespace, project, version, base image) into a lineage file during build.
- Downstream images chain lineage from their parent, producing a full base-to-current provenance chain.
- At container startup, the full lineage chain is logged, making it easy to trace what a running container was built from.

### Structured, level-filtered logging (b19-log)

- All container output goes through a leveled logger with four thresholds: error, warn, info, debug.
- Messages below the configured verbosity are silently discarded, keeping production logs clean.
- Colors auto-detect terminal support and respect `NO_COLOR=1`.
- Pipable: command output can be routed through the logger to apply level filtering and tags.

### Non-root container by default

- The container runs as a non-root user (`ubuntu`, UID/GID 1000) with all runtime files owned by that user.
- A two-stage build separates root-level system installation from user-level runtime setup.
- User identity is configurable at build time.

### Air-gapped / offline build and runtime support

- A single environment variable (`B19_OFFGRID_MODE=Y`) cuts all internet access at build time and runtime.
- Build-time: downloads are blocked, APT updates are skipped, SSH keyscans are skipped. All artifacts must come from cache tiers.
- Runtime: network healthchecks automatically skip with a healthy result, so containers stay green on isolated networks.
- APT package lists can be snapshotted and injected for fully offline image builds.
- LAN services (caching proxies, registries) remain reachable -- offgrid blocks internet, not all networking.

### Runtime overlay injection

- Configuration or data files can be injected at container startup by setting `B19_OVERLAY` to a directory name.
- Overlay contents are recursively copied to the container root, overwriting existing files -- no image rebuild needed.
- Skipped in immutable mode, preventing runtime modification of production-locked images.

### Reproducible base image (pinned by digest)

- The Ubuntu base image is pinned by SHA-256 digest, not by tag, ensuring deterministic builds.
- Supports multiple Ubuntu series (resolute, noble, optional: jammy, questing) selectable at build time.
- APT mirrors are configurable per architecture for LAN mirrors or air-gapped environments.

### Port validation

- All `*PORT*` environment variables are validated at startup against the WHATWG blocklist of forbidden ports and privileged ports (\<1024).
- Catches misconfigurations like `PORT=0` or `PORT=22` early, before the service fails silently.
- Can be disabled at runtime without rebuilding the image.

### Unified lifecycle runner family

- Eight numbered-hook runners cover the full container lifecycle: startup, healthchecks, tests, bootstrap, build hooks, benchmarks, reports, and shell sessions.
- All runners share the same pattern: drop a numbered script into a directory, it is auto-discovered and executed.
- Scripts from different image layers merge seamlessly -- upstream and downstream hooks coexist without conflict.
- Each runner has tailored failure semantics: abort on error (entrypoint, bootstrap), continue and count failures (healthchecks, tests), always succeed (reports).

### Docker secrets auto-loading (secrets)

- Docker secrets files are automatically discovered and converted to environment variables at startup.
- Dot-notation filenames map to uppercase env vars (`b19.npm.registry_host` becomes `B19_NPM_REGISTRY_HOST`).
- Required secrets can be declared by name; the container refuses to start if any are missing.
- Existing environment variables take precedence over secret-derived values.
- Secrets are also available in interactive shell sessions and healthchecks.
- Non-UTF-8/binary secrets (keys, DER blobs, gzipped tarballs) are **not** exported as env vars: Bash truncates them at the first NUL and the stray bytes panic any tool that reads the environment as UTF-8 (e.g. `minijinja --env`, used to template configs). They remain on disk at `/run/secrets/<name>` for file-based reads — which is the only correct way to consume a binary secret anyway.

### Interactive shell hooks (shell.d)

- `docker exec bash` sessions automatically load Docker secrets and any custom hooks added by downstream images.
- Hooks merge via Docker layer overlay, so inherited and project-specific shell setup coexist.

### Graceful signal handling

- PID 1 is `tini -g`, which reaps zombie processes and forwards signals to the full process group.
- A configurable set of Unix signals (TERM, INT, HUP, USR1, USR2, etc.) is trapped and forwarded to the main service process.
- `docker stop` cleanly terminates the service without orphan processes or signal loss.

### Jinja2 configuration templates (minijinja-cli)

- Jinja2-compatible template rendering at both build time and container startup.
- Drop a `.j2` file anywhere in the app directory; it is discovered at build time and rendered at every startup with all environment variables available.
- Runtime rendering is parallel and automatic -- downstream images get it with zero configuration.
- Immutable mode (`B19_IMMUTABLE=Y`) locks the filesystem to build-time state, skipping all runtime rendering.

### Built-in test framework (test.d)

- Tests run inside the running container via `make test` or `docker exec`.
- Automatically waits for healthchecks to pass before executing.
- No test framework dependency -- tests are plain shell scripts with exit codes.
- Supports Jinja2 templates in tests, useful for asserting build-time values at runtime.
- Continues on failure and reports the total count; never hides partial results.

### Pre-installed utility tools

- `mold` as default linker for faster linking (opt-out available).
- `fd` for fast file finding, `minijinja-cli` for template rendering.
- `aria2c` for multi-connection downloads, `tini` as PID 1 for zombie reaping.
- Parallel compression tools: `pbzip2`, `pigz`, `pixz`.
- gettext tools for i18n compilation, `cURL` for network operations.

### XDG Base Directory paths

- Standard XDG paths (`XDG_CACHE_HOME`, `XDG_CONFIG_HOME`, `XDG_DATA_HOME`, `XDG_STATE_HOME`) are set under the app home directory.
- All paths are writable by the non-root user without privilege escalation.
<!-- textlint-enable -->
