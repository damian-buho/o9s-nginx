<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
SPDX-License-Identifier: MIT
-->

[Español](docs/es/FEATURES.md) · [Українська](docs/uk/FEATURES.md)

# Features

## Project Features

### Built-in ACME certificate automation module

- An ACME client module (compiled from Rust) is included as a dynamic nginx module, enabling automatic TLS certificate provisioning without an external agent.
- Activation is via `O9S_NGINX_MODULE_ACME=Y`; the ACME issuer block is emitted automatically in the HTTP config.
- ACME server URL (`O9S_NGINX_ACME_SERVER`) and issuer name (`O9S_NGINX_ACME_ISSUER_NAME`) are configurable, supporting any ACME-compatible CA.
- Per-server certificate configuration is available through the `enable-acme` opt/ include.

### CDN-aware real IP resolution

- Trusted proxy IP ranges for major CDNs are fetched live at every container start, ensuring `set_real_ip_from` lists are always current.
- Supported CDN modes (`O9S_NGINX_REALIP_MODE`): `cloudflare` (CF-Connecting-IP header), `akamai` (True-Client-IP), `aws` (CloudFront + ELB ranges, X-Forwarded-For), `fastly` (Fastly-Client-IP).
- Non-CDN modes are also available: `docker` (static RFC 1918 ranges), `custom` (user-specified subnet via `O9S_NGINX_REALIP_NETWORK`), `localhost`.
- The appropriate `real_ip_header` is set automatically per CDN mode.
- IP fetching is skipped in immutable mode (`B19_IMMUTABLE=Y`).

### Multiple compression modules (brotli, zstd, gzip)

- Three compression algorithms are compiled as dynamic modules and loaded conditionally via `O9S_NGINX_MODULE_{BROTLI,ZSTD}` (both on by default; gzip is built into nginx core).
- Each algorithm has independent on/off toggles and compression levels controllable at runtime.
- Dynamic compression levels can differ from pre-compression levels — runtime uses lower levels for CPU efficiency, pre-compression uses maximum.
- A shared MIME-type list (`O9S_NGINX_COMPRESS_TYPES`) controls which content types are eligible for compression across all three algorithms.
- Pre-compressed `.br`, `.zst`, and `.gz` siblings are served directly via the corresponding `*_static` modules when present (see static pre-compression).

### Environment-driven configuration (zero config mounts)

- Every nginx directive is environment-driven — the image is fully functional with no mounted config files.
- Configuration is generated from environment variables at startup — no manual config editing.
- Downstream images tune nginx through environment overrides only; no volume mounts needed.
- Categories cover ports, compression, proxy, TLS, logging, caching, CORS, CSP, real IP, and OpenTelemetry.

### Content-Signal and robots.txt directives

- A `robots.txt` file is generated at startup from environment variables — no static file needs to be mounted.
- Default crawl policy is configurable via `O9S_NGINX_ROBOTS_TXT_DEFAULT_POLICY`: `disallow` (default), `allow`, or `none` (omit the default block entirely).
- Content-Signal directives per contentsignals.org are emitted: `CONTENT_SIGNALS_SEARCH`, `CONTENT_SIGNALS_TRAIN`, `CONTENT_SIGNALS_INPUT` control whether search indexing, AI training, and AI input are permitted (`yes`/`no`).
- A sitemap URL can be declared via `O9S_NGINX_ROBOTS_TXT_SITEMAP`.

### DH parameters pre-generation

- A 2048-bit DH parameters file is generated at build time if not already present, avoiding the expensive computation at first request in production.
- DH parameter size is configurable via `B19_CA_DHPARAMS_SIZE`; the output path is `${O9S_NGINX_TLS_PATH}/dhparams.pem`.
- The generated file is consumed by the TLS configuration block (`ssl_dhparam`) automatically.

### Downstream consumption pattern

- Child images inherit all 200+ ENV defaults, the template hierarchy, entrypoint hooks, healthchecks, and pre-compression logic from a single `FROM` line.
- Customization is done by overriding specific `ENV` values in the child Dockerfile (e.g. `O9S_NGINX_INDEX_TYPE=cache`, cache durations, backend host/port).
- New content handlers can be added by placing a `.nginx.j2` file in `includes/index/` and setting `O9S_NGINX_INDEX_TYPE` — the include path is dynamic.
- New feature toggles can be added by placing a file in `includes/opt/` and listing its name in `O9S_NGINX_INCLUDE_OPTIONAL`.
- No config file mounts are ever required — the pattern is ENV-only from base image through all downstream derivatives.

### Localized, self-contained error pages

- Custom error pages for the ten standard status codes (400–504), generated at build time from a single template instead of nginx’s bare built-in pages.
- Visitors get their own language: the server negotiates `Accept-Language` per request (English, Spanish, Ukrainian) with automatic fallback to English — no JavaScript involved.
- Dark by default and follows the operating system’s light/dark preference through native CSS color-scheme switching.
- Fully self-contained: system fonts and no third-party requests, so pages render identically offline and under a strict Content-Security-Policy.
- Adding a language is one gettext `.po` file — pages and negotiation extend automatically on the next build.

### Feature toggle includes (opt/ system)

- HTTP/3, Brotli compression, real-IP extraction, and other features are toggleable without rebuilding.
- Each feature is enabled or disabled entirely through environment variables — no config file edits required.
- Downstream images can add new features by dropping a snippet into the opt/ directory.
- Available toggles include CORS, Content-Security-Policy, HSTS, Permissions-Policy, ACME certificates, and OpenTelemetry tracing.

### HTTP/3 (QUIC) support

- nginx is compiled from source with full HTTP/3 (QUIC) support, enabled by default (`O9S_NGINX_HTTP3=on`).
- The `Alt-Svc` header is emitted automatically, advertising the QUIC port so compatible browsers upgrade to HTTP/3 transparently.
- QUIC transport options are ENV-tunable: GSO (`O9S_NGINX_QUIC_GSO`), retry (`O9S_NGINX_QUIC_RETRY`), BPF (`O9S_NGINX_QUIC_BPF`), max concurrent streams, and stream buffer size.
- HTTP/2 and HTTP/3 listen on the same port (separate `listen` directives for `ssl` and `quic`), with all socket options independently configurable.

### OpenTelemetry tracing module

- An OpenTelemetry module is compiled as a dynamic nginx module for distributed tracing export via OTLP/gRPC.
- Activation is via `O9S_NGINX_MODULE_OTEL=Y`; disabled by default to avoid overhead when tracing is not needed.
- The OTLP endpoint (`O9S_OTEL_ENDPOINT`), service name (`O9S_OTEL_SERVICE_NAME`), and trace context propagation are all ENV-configurable.
- Exporter tuning (interval, batch size, batch count) and custom span attributes are supported.
- Per-server tracing can be enabled via the `enable-otel` opt/ include.

### Preload hint scanning

- At container startup, the document root is scanned for CSS, JavaScript, image, and font assets, generating `<Link>` preload headers automatically.
- Scanning is opt-in via `O9S_NGINX_PH_SCAN_ENABLED=Y`; individual asset types (style, script, image, font) can be toggled independently.
- The scan path is configurable via `O9S_NGINX_PH_SCAN_PATH` (default `assets`).
- Discovered assets are written to a JSON sidecar consumed by the Jinja2 template, producing `Link: <...>; rel=preload; as=...` headers on HTML responses.

### Scaffold system for downstream nginx-based images

- Configuration is assembled from composable templates — base config, includes, and overrides merge automatically at startup.
- New projects inherit the full build pipeline, entrypoint, healthcheck, and template hierarchy without manual setup.
- Downstream projects only need to override specific environment values and optionally add custom includes.

### Pre-compression of static assets

- Static files are pre-compressed in three formats (gzip via pigz, brotli, zstd) so nginx serves pre-built `.gz`/`.br`/`.zst` siblings directly — no per-request CPU cost.
- Compression runs at build time by default (inheritable `.i.sh` hook propagates to downstream images) and optionally again at container start.
- File extensions to compress are configurable (`O9S_NGINX_PRECOMPRESS_EXTENSIONS`); Jinja2 template outputs are excluded automatically.
- Each algorithm has independent on/off toggles and compression levels (pre-compression uses maximum levels: gzip 9, brotli 11, zstd 19).
- A standalone `compress-static-assets` command is available for manual invocation on any directory.

### Jinja2 include-based template hierarchy

- Configuration templates layer predictably — base, includes, and per-project overrides merge in a clear order.
- The http block pulls in numbered snippets covering core settings, compression, proxy, TLS, logging, and telemetry.
- Server blocks compose from modular includes for socket config, error pages, content handlers, and feature toggles.
- New behaviors are added by placing a file into the appropriate includes directory — no editing of existing templates required.

## Inherited from B19/Ubuntu

### Persistent APT cache across builds

- Package downloads and index caches persist across builds, so repeated builds skip redundant downloads.
- Cache is keyed by Ubuntu series and architecture, avoiding cross-contamination.
- Optional LAN APT cacher proxy can be enabled for faster local builds.

### Service process management with log routing (b19-exec)

- Long-running processes (daemons, servers) have stdout and stderr automatically routed through the structured logger.
- The service PID is tracked for signal forwarding — Docker stop gracefully terminates the main process.
- Log levels for stdout and stderr streams are independently configurable.
- Exit code of the service is captured and available to downstream hooks.

### Cached artifact downloads with integrity verification

- Downloads are cached locally and in BuildKit persistent storage, so repeated fetches are served from cache.
- SHA-512 hash verification runs at every tier; mismatches fall through to the next source rather than failing.
- Offgrid mode blocks all downloads entirely, failing fast with a clear error on cache miss.
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

- Build logic lives in composable hook scripts instead of inline Dockerfile commands, making it easy to read, test, and reuse.
- Cross-cutting setup (CA trust, locale, shared installs) is written once and runs on every stage automatically.
- Downstream images inherit parent build logic through the layer overlay — no duplication needed.
- Non-inheritable one-off setup is cleaned up after execution to avoid leaking into later stages.

### Automatic CPU count detection

- CPU count is detected automatically across Docker, Kubernetes, and CI environments without manual configuration.
- Eliminates hardcoded job counts — parallel compilation, template rendering, and tests use the right parallelism everywhere.
- The detected count is available throughout build and runtime for any tool that needs it.

### Declarative dependency management (b19-deps)

- External dependency metadata (URL, version, SHA-512 hash) stored as plain text files, completely separate from build scripts.
- Supports architecture-specific downloads, multi-version series, and nested component paths.
- Dependencies are auto-discovered at Makefile parse time — add files to the right directory and the build picks them up without manual declarations.
- `make fetch` pre-downloads everything for offline builds; version bumps trigger automatic re-fetch and hash updates.

### Pluggable startup system (entrypoint.d)

- Composable hook chain handles signal setup, secrets loading, CPU detection, port validation, template rendering, bootstrap, and service start in order.
- Ad-hoc commands bypass the startup chain automatically and execute directly.
- Individual hooks or the entire entrypoint can be skipped at runtime via environment variables, no image rebuild needed.
- Downstream images override a single hook to launch their service; everything else is inherited.

### Feature toggles for all subsystems

- Every major subsystem (entrypoint, healthchecks, bootstrap, tests, secrets, port validation, i18n, shell hooks) can be disabled at runtime via environment variables.
- Individual entrypoint, bootstrap and health-check hooks can be skipped by name without disabling the whole subsystem.
- No image rebuild required — toggles are runtime-only.

### Built-in health monitoring (healthcheck.d)

- Docker-native healthcheck inherited by every downstream image with no extra configuration.
- Egress checks are opt-in: a container that never reaches the internet carries no check a third party can fail, while one whose job is the internet reports unhealthy the moment the outside is gone.
- Works the same offline as online — egress checks stand down automatically under offgrid mode.
- Adding a check is dropping a script in a directory, not writing Docker plumbing.

See [use-healthcheck.d](../how-to/use-healthcheck.d.md) for the check list, slot numbering, and configuration.

### Multilingual shell output (b19-i18n)

- All user-facing log messages and script output are translatable via GNU gettext.
- Ships with English, Spanish (`es_CL`), and Ukrainian (`uk_UA`) out of the box.
- Downstream images inherit all parent translations automatically; only new or overridden strings need translating.
- Translations are compiled at build time with no runtime overhead.

### Image lineage tracking

- Every image records its build metadata (namespace, project, version, base image) into a lineage file during build.
- Downstream images chain lineage from their parent, producing a full base-to-current provenance chain.
- The full lineage chain is logged at startup (debug verbosity) and readable from the file at any time, making it easy to trace what a running container was built from.

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
- LAN services (caching proxies, registries) remain reachable — offgrid blocks internet, not all networking.

### Runtime overlay injection

- Configuration or data files can be injected at container startup by setting `B19_OVERLAY` to a directory name.
- Overlay contents are recursively copied to the container root, overwriting existing files — no image rebuild needed.
- Skipped in immutable mode, preventing runtime modification of production-locked images.

### Reproducible base image (pinned by digest)

- The Ubuntu base image is pinned by SHA-256 digest, not by tag, ensuring deterministic builds.
- Supports multiple Ubuntu series (resolute, noble, jammy) selectable at build time.
- APT mirrors are configurable per architecture for LAN mirrors or air-gapped environments.

### Port validation

- Every environment variable whose name ends in `PORT` is validated at startup against the WHATWG blocklist of forbidden ports and privileged ports (\<1024).
- Catches misconfigurations like `HTTP_PORT=22` early, before the service fails silently.
- Can be disabled at runtime without rebuilding the image.

### Unified lifecycle runner family

- Every lifecycle concern — startup, healthchecks, tests, bootstrap, build, benchmarks, reports, and shell — follows the same discoverable hook pattern.
- Drop a numbered script into a directory and it is auto-discovered and executed, no wiring required.
- Scripts from different image layers merge, so upstream and downstream hooks coexist without conflict.
- Each runner has tailored failure semantics: abort on error, continue and count failures, or always succeed as appropriate.

### Docker secrets auto-loading

- Docker secrets translate to environment variables automatically at container startup, requiring no code changes.
- Dot-notation filenames map to uppercase env vars, keeping naming consistent and predictable.
- Required secrets can be declared by name; the container refuses to start if any are missing.
- Existing environment variables take precedence over secret-derived values, so overrides are straightforward.
- Binary secrets (keys, DER blobs) stay on disk for file-based reads, avoiding Bash truncation issues.

### Interactive shell hooks

- Shell sessions automatically load Docker secrets and any custom hooks added by downstream images.
- Hooks merge via Docker layer overlay, so inherited and project-specific shell setup coexist without conflict.

### Graceful signal handling

- PID 1 is `tini -g`, which reaps zombie processes and forwards signals to the full process group.
- A configurable set of Unix signals (TERM, INT, HUP, USR1, USR2, etc.) is trapped and forwarded to the main service process.
- `docker stop` cleanly terminates the service without orphan processes or signal loss.

### Jinja2 configuration templates (minijinja-cli)

- Jinja2-compatible template rendering at both build time and container startup.
- Drop a `.j2` file anywhere in the app directory; it is discovered at build time and rendered at every startup with all environment variables available.
- Runtime rendering is parallel and automatic — downstream images get it with zero configuration.
- Skip specific templates at runtime with `B19_J2_SKIP_FILES` (comma-separated basenames).
- Immutable mode (`B19_IMMUTABLE=Y`) locks the filesystem to build-time state, skipping all runtime rendering.

### Built-in test framework (test.d)

- Tests run inside the running container via `make test` or `docker exec`.
- Automatically waits for healthchecks to pass before executing.
- No test framework dependency — tests are plain shell scripts with exit codes.
- Supports Jinja2 templates in tests, useful for asserting build-time values at runtime.
- Continues on failure and reports the total count; never hides partial results.

### Pre-installed utility tools

- `mold` as default linker (opt-out available).
- `fd` for file finding, `minijinja-cli` for template rendering.
- `aria2c` for multi-connection downloads, `tini` as PID 1 for zombie reaping.
- Parallel compression tools: `pbzip2`, `pigz`, `pixz`.
- gettext tools for i18n compilation, `cURL` for network operations.

### XDG Base Directory paths

- Standard XDG paths (`XDG_CACHE_HOME`, `XDG_CONFIG_HOME`, `XDG_DATA_HOME`, `XDG_STATE_HOME`) are set under the app home directory.
- All paths are writable by the non-root user without privilege escalation.
