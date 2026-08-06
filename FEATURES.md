<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
SPDX-License-Identifier: MIT
-->

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

- Every nginx directive is controlled through 200+ `O9S_NGINX_*` environment variables with sensible defaults baked into the Dockerfile — the image is fully functional with `docker run` and no mounted config files.
- Downstream images and compose files tune nginx via `environment:` or `ENV` overrides only; no `/etc/nginx/` volume mounts or `.conf` files are needed.
- All templates are rendered at startup by the standard Jinja2 rendering hook, with every container ENV variable available as `ENV.VAR_NAME`.
- Variable categories cover ports, HTTP/2+3, compression, proxy, FastCGI, TLS, logging, caching, CSP, CORS, Permissions-Policy, real IP, OpenTelemetry, and socket options.

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

### Feature toggle includes (opt/ system)

- Self-contained nginx snippets in `includes/opt/` are conditionally included per server block via `O9S_NGINX_INCLUDE_OPTIONAL` (space-delimited list of names).
- Available toggles: CORS (`enable-cors`, 6 vars), Content-Security-Policy (`enable-csp`, 18 vars), HSTS (`enable-hsts`), Permissions-Policy (`enable-permissions-policy`, 12 vars), stub status (`enable-status`), ACME cert (`enable-acme`), OTel per-server (`enable-otel`), cache-control (`enable-cache`), favicon (`enable-favicon`), certbot paths (`enable-certbot`), X-Frame-Options DENY (`enable-sameorigin`), X-Content-Type-Options nosniff (`enable-nosniff`), HTTP-to-HTTPS redirect (`redirect-to-https`).
- Each toggle is entirely ENV-driven — no editing of nginx config files required.
- Downstream images can add new opt/ snippets by dropping a `.nginx` or `.nginx.j2` file into `includes/opt/`.

### HTTP/3 (QUIC) support

- nginx is compiled from source with full HTTP/3 (QUIC) support, enabled by default (`O9S_NGINX_HTTP3=on`).
- The `Alt-Svc` header is emitted automatically, advertising the QUIC port so compatible browsers upgrade to HTTP/3 transparently.
- QUIC transport options are ENV-tunable: GSO (`O9S_NGINX_QUIC_GSO`), retry (`O9S_NGINX_QUIC_RETRY`), BPF (`O9S_NGINX_QUIC_BPF`), max concurrent streams, and stream buffer size.
- HTTP/2 and HTTP/3 listen on the same port (separate `listen` directives for `ssl` and `quic`), with all socket options independently configurable.

### Immutable mode for hardened deployments

- Setting `B19_IMMUTABLE=Y` skips all runtime config generation, CDN IP fetching, asset scanning, and certificate/DH parameter generation.
- The image must contain pre-rendered configs — intended for read-only, hardened, or rootless deployments where no filesystem writes are permitted at runtime.
- All Jinja2 templates must be rendered at build time in this mode.

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

- A `scaffold/` directory provides a Dockerfile template and `stack.conf` for bootstrapping new nginx-derived projects.
- Uses m6e stack integration (`STACK_ROOT_STAGE=base`, `STACK_EXTENSIONS=nginx`) so new projects inherit the full build pipeline automatically.
- Downstream projects only need to override specific `ENV` values and optionally add custom `includes/` files — the base Dockerfile, entrypoint, healthcheck, and template hierarchy are all inherited.

### Pre-compression of static assets

- Static files are pre-compressed in three formats (gzip via pigz, brotli, zstd) so nginx serves pre-built `.gz`/`.br`/`.zst` siblings directly — no per-request CPU cost.
- Compression runs at build time by default (inheritable `.i.sh` hook propagates to downstream images) and optionally again at container start.
- File extensions to compress are configurable (`O9S_NGINX_PRECOMPRESS_EXTENSIONS`); Jinja2 template outputs are excluded automatically.
- Each algorithm has independent on/off toggles and compression levels (pre-compression uses maximum levels: gzip 9, brotli 11, zstd 19).
- A standalone `compress-static-assets` command is available for manual invocation on any directory.

### Jinja2 include-based template hierarchy

- The entire nginx config tree lives as Jinja2 (`.j2`) templates under `${XDG_CONFIG_HOME}/`, composed via `include` directives — no monolithic config file.
- The `http {}` block pulls in 24 numbered snippets (`includes/http/*.nginx`) sorted by prefix: core, AIO, DNS, compression, ACME, client/IO, HTTP/2+3, keepalive, proxy, caching, TLS, logging, real IP, and OpenTelemetry.
- Server blocks compose from modular includes: `listen/` (socket config), `server/` (error pages, ETag, DNS prefetch, preload hints), `index/` (content handler), `opt/` (feature toggles), and `realip/` (CDN-aware IP resolution).
- Templates needing conditional logic use Jinja2 `{% if %}` blocks; non-conditional snippets are plain `.nginx` files rendered as-is.
- New behaviors can be added by dropping a file into the appropriate `includes/` directory — no editing of existing templates required.

## Inherited from B19/Ubuntu 1.0.0

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
