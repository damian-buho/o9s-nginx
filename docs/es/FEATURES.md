<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
SPDX-License-Identifier: MIT
-->

<!-- textlint-disable terminology,common-misspellings -->

[English](../../FEATURES.md) · [Українська](../uk/FEATURES.md)

# Características

## Características del proyecto

### Módulo integrado de automatización de certificados ACME

- Se incluye un módulo cliente de ACME (compilado desde Rust) como módulo dinámico de nginx, lo que permite el aprovisionamiento automático de certificados TLS sin un agente externo.
- Se activa con `O9S_NGINX_MODULE_ACME=Y`; el bloque del emisor ACME se emite automáticamente en la configuración HTTP.
- La URL del servidor ACME (`O9S_NGINX_ACME_SERVER`) y el nombre del emisor (`O9S_NGINX_ACME_ISSUER_NAME`) son configurables, con soporte para cualquier CA compatible con ACME.
- La configuración de certificados por servidor está disponible mediante el include opt/ `enable-acme`.

### Resolución de IP real consciente de CDN

- Los rangos de IP de proxies de confianza de los principales CDN se obtienen en vivo en cada arranque del contenedor, garantizando que las listas `set_real_ip_from` estén siempre actualizadas.
- Modos de CDN admitidos (`O9S_NGINX_REALIP_MODE`): `cloudflare` (cabecera CF-Connecting-IP), `akamai` (True-Client-IP), `aws` (rangos de CloudFront + ELB, X-Forwarded-For), `fastly` (Fastly-Client-IP).
- También hay modos sin CDN: `docker` (rangos estáticos de la RFC 1918), `custom` (subred especificada por el usuario mediante `O9S_NGINX_REALIP_NETWORK`), `localhost`.
- El `real_ip_header` apropiado se establece automáticamente según el modo de CDN.
- La obtención de IP se omite en modo inmutable (`B19_IMMUTABLE=Y`).

### Múltiples módulos de compresión (brotli, zstd, gzip)

- Tres algoritmos de compresión se compilan como módulos dinámicos y se cargan condicionalmente mediante `O9S_NGINX_MODULE_{BROTLI,ZSTD}` (ambos activados por defecto; gzip está integrado en el núcleo de nginx).
- Cada algoritmo tiene conmutadores de activación/desactivación y niveles de compresión independientes, controlables en tiempo de ejecución.
- Los niveles de compresión dinámica pueden diferir de los de precompresión: en tiempo de ejecución se usan niveles menores por eficiencia de CPU; la precompresión usa el máximo.
- Una lista compartida de tipos MIME (`O9S_NGINX_COMPRESS_TYPES`) controla qué tipos de contenido son aptos para compresión en los tres algoritmos.
- Los hermanos precomprimidos `.br`, `.zst` y `.gz` se sirven directamente mediante los módulos `*_static` correspondientes cuando existen (véase la precompresión estática).

### Configuración dirigida por el entorno (cero montajes de configuración)

- Cada directiva de nginx se controla mediante más de 200 variables de entorno `O9S_NGINX_*` con valores predeterminados razonables integrados en el Dockerfile — la imagen funciona por completo con `docker run` y sin archivos de configuración montados.
- Las imágenes descendentes y los archivos compose ajustan nginx solo con sobrescrituras de `environment:` o `ENV`; no hacen falta montajes de volumen en `/etc/nginx/` ni archivos `.conf`.
- Todas las plantillas se generan al arrancar mediante el hook estándar de renderizado Jinja2, con cada variable ENV del contenedor disponible como `ENV.VAR_NAME`.
- Las categorías de variables cubren puertos, HTTP/2+3, compresión, proxy, FastCGI, TLS, registro, caché, CSP, CORS, Permissions-Policy, IP real, OpenTelemetry y opciones de socket.

### Directivas Content-Signal y robots.txt

- Un archivo `robots.txt` se genera al arrancar desde variables de entorno — no hay que montar ningún archivo estático.
- La política de rastreo predeterminada se configura con `O9S_NGINX_ROBOTS_TXT_DEFAULT_POLICY`: `disallow` (predeterminado), `allow` o `none` (omite el bloque predeterminado por completo).
- Se emiten directivas Content-Signal según contentsignals.org: `CONTENT_SIGNALS_SEARCH`, `CONTENT_SIGNALS_TRAIN`, `CONTENT_SIGNALS_INPUT` controlan si se permiten la indexación para búsqueda, el entrenamiento de IA y la entrada a la IA (`yes`/`no`).
- Puede declararse una URL de sitemap mediante `O9S_NGINX_ROBOTS_TXT_SITEMAP`.

### Pregeneración de parámetros DH

- Un archivo de parámetros DH de 2048 bits se genera en tiempo de compilación si no existe ya, evitando el costoso cálculo en la primera petición en producción.
- El tamaño de los parámetros DH es configurable mediante `B19_CA_DHPARAMS_SIZE`; la ruta de salida es `${O9S_NGINX_TLS_PATH}/dhparams.pem`.
- El archivo generado lo consume automáticamente el bloque de configuración TLS (`ssl_dhparam`).

### Patrón de consumo descendente

- Las imágenes hijas heredan los más de 200 valores ENV predeterminados, la jerarquía de plantillas, los hooks del entrypoint, las comprobaciones de estado y la lógica de precompresión desde una sola línea `FROM`.
- La personalización se hace sobrescribiendo valores `ENV` concretos en el Dockerfile hijo (p. ej. `O9S_NGINX_INDEX_TYPE=cache`, duraciones de caché, host/puerto del backend).
- Se pueden añadir nuevos gestores de contenido colocando un archivo `.nginx.j2` en `includes/index/` y estableciendo `O9S_NGINX_INDEX_TYPE` — la ruta de include es dinámica.
- Se pueden añadir nuevos conmutadores de características colocando un archivo en `includes/opt/` y listando su nombre en `O9S_NGINX_INCLUDE_OPTIONAL`.
- Nunca se requieren montajes de archivos de configuración: el patrón es solo ENV desde la imagen base hasta todos los derivados descendentes.

### Includes de conmutadores de características (sistema opt/)

- Fragmentos de nginx autocontenidos en `includes/opt/` se incluyen condicionalmente por bloque de servidor mediante `O9S_NGINX_INCLUDE_OPTIONAL` (lista de nombres separados por espacios).
- Conmutadores disponibles: CORS (`enable-cors`, 6 variables), Content-Security-Policy (`enable-csp`, 18 variables), HSTS (`enable-hsts`), Permissions-Policy (`enable-permissions-policy`, 12 variables), stub status (`enable-status`), certificado ACME (`enable-acme`), OTel por servidor (`enable-otel`), cache-control (`enable-cache`), favicon (`enable-favicon`), rutas de certbot (`enable-certbot`), X-Frame-Options DENY (`enable-sameorigin`), X-Content-Type-Options nosniff (`enable-nosniff`), redirección de HTTP a HTTPS (`redirect-to-https`).
- Cada conmutador se gobierna por completo mediante ENV — no hay que editar archivos de configuración de nginx.
- Las imágenes descendentes pueden añadir nuevos fragmentos opt/ depositando un archivo `.nginx` o `.nginx.j2` en `includes/opt/`.

### Soporte de HTTP/3 (QUIC)

- nginx se compila desde el código fuente con soporte completo de HTTP/3 (QUIC), activado por defecto (`O9S_NGINX_HTTP3=on`).
- La cabecera `Alt-Svc` se emite automáticamente, anunciando el puerto QUIC para que los navegadores compatibles pasen a HTTP/3 de forma transparente.
- Las opciones de transporte de QUIC son ajustables por ENV: GSO (`O9S_NGINX_QUIC_GSO`), retry (`O9S_NGINX_QUIC_RETRY`), BPF (`O9S_NGINX_QUIC_BPF`), flujos concurrentes máximos y tamaño del búfer de flujo.
- HTTP/2 y HTTP/3 escuchan en el mismo puerto (directivas `listen` separadas para `ssl` y `quic`), con todas las opciones de socket configurables de forma independiente.

### Módulo de trazado OpenTelemetry

- Un módulo de OpenTelemetry se compila como módulo dinámico de nginx para la exportación de trazado distribuido vía OTLP/gRPC.
- Se activa con `O9S_NGINX_MODULE_OTEL=Y`; está desactivado por defecto para evitar sobrecarga cuando no se necesita trazado.
- El endpoint OTLP (`O9S_OTEL_ENDPOINT`), el nombre del servicio (`O9S_OTEL_SERVICE_NAME`) y la propagación de contexto de traza son configurables por ENV.
- Se admiten el ajuste del exportador (intervalo, tamaño y cantidad de lotes) y atributos de span personalizados.
- El trazado por servidor puede activarse mediante el include opt/ `enable-otel`.

### Escaneo de pistas de precarga

- Al arrancar el contenedor, la raíz de documentos se escanea en busca de recursos CSS, JavaScript, imágenes y fuentes, generando automáticamente cabeceras de precarga `<Link>`.
- El escaneo es opcional mediante `O9S_NGINX_PH_SCAN_ENABLED=Y`; los tipos de recurso individuales (style, script, image, font) pueden conmutarse de forma independiente.
- La ruta de escaneo es configurable mediante `O9S_NGINX_PH_SCAN_PATH` (predeterminado `assets`).
- Los recursos descubiertos se escriben en un sidecar JSON que consume la plantilla Jinja2, produciendo cabeceras `Link: <...>; rel=preload; as=...` en las respuestas HTML.

### Sistema de andamiaje para imágenes descendentes basadas en nginx

- Un directorio `scaffold/` aporta una plantilla de Dockerfile y `stack.conf` para arrancar nuevos proyectos derivados de nginx.
- Usa la integración de pila de m6e (`STACK_ROOT_STAGE=base`, `STACK_EXTENSIONS=nginx`) para que los nuevos proyectos hereden automáticamente la cadena de compilación completa.
- Los proyectos descendentes solo necesitan sobrescribir valores `ENV` concretos y, opcionalmente, añadir archivos `includes/` propios — el Dockerfile base, el entrypoint, la comprobación de estado y la jerarquía de plantillas se heredan por completo.

### Precompresión de recursos estáticos

- Los archivos estáticos se precomprimen en tres formatos (gzip con pigz, brotli, zstd) para que nginx sirva directamente los hermanos preconstruidos `.gz`/`.br`/`.zst` — sin coste de CPU por petición.
- La compresión se ejecuta por defecto en tiempo de compilación (el hook heredable `.i.sh` se propaga a las imágenes descendentes) y, opcionalmente, otra vez al arrancar el contenedor.
- Las extensiones de archivo a comprimir son configurables (`O9S_NGINX_PRECOMPRESS_EXTENSIONS`); las salidas de plantillas Jinja2 se excluyen automáticamente.
- Cada algoritmo tiene conmutadores de activación/desactivación y niveles de compresión independientes (la precompresión usa niveles máximos: gzip 9, brotli 11, zstd 19).
- La orden autónoma `compress-static-assets` está disponible para invocarse manualmente sobre cualquier directorio.

### Jerarquía de plantillas basada en includes Jinja2

- Todo el árbol de configuración de nginx vive como plantillas Jinja2 (`.j2`) bajo `${XDG_CONFIG_HOME}/`, compuesto mediante directivas `include` — sin un archivo de configuración monolítico.
- El bloque `http {}` incorpora 24 fragmentos numerados (`includes/http/*.nginx`) ordenados por prefijo: núcleo, AIO, DNS, compresión, ACME, cliente/ES, HTTP/2+3, keepalive, proxy, caché, TLS, registro, IP real y OpenTelemetry.
- Los bloques de servidor se componen de includes modulares: `listen/` (configuración de socket), `server/` (páginas de error, ETag, prefetch de DNS, pistas de precarga), `index/` (gestor de contenido), `opt/` (conmutadores de características) y `realip/` (resolución de IP consciente de CDN).
- Las plantillas que necesitan lógica condicional usan bloques Jinja2 `{% if %}`; los fragmentos sin condicionales son archivos `.nginx` planos renderizados tal cual.
- Se pueden añadir nuevos comportamientos depositando un archivo en el directorio `includes/` apropiado — sin editar las plantillas existentes.

## Heredado de B19/Ubuntu 1.0.0

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
