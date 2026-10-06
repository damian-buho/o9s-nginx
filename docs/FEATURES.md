<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
SPDX-License-Identifier: MIT
-->

[Español](es/FEATURES.md) · [Українська](uk/FEATURES.md)

# Features

## Project Features

### Built-in ACME certificate automation

- nginx obtains and renews its own TLS certificates — no certbot sidecar, no cron job, no reload script.
- Works with any ACME-compatible certificate authority, not only Let’s Encrypt.
- Off by default; one switch turns it on, and each site opts in separately.

### CDN-aware real client IP

- Logs, rate limits and backends see the visitor’s address, not the CDN edge or the Docker gateway.
- Presets for Cloudflare, Akamai, AWS CloudFront and Fastly fetch the provider’s current ranges at every start, so the trust list never goes stale; the right client-IP header is chosen per provider.
- Trust sets stack: a CDN in front of another reverse proxy resolves the real client on both the direct and the proxied path.
- Proxied backends receive exactly one resolved client address, never the raw forwarding chain.
- A mistyped provider refuses to start; an unreachable provider list warns and keeps the other sources.

### Brotli, zstd and gzip compression

- Brotli and zstd ship alongside gzip, so every modern browser gets its best encoding.
- All three share one list of compressible types, and already-compressed media and archives are left alone.
- On-the-fly levels stay low to save CPU; files pre-compressed at build time are served at maximum ratio instead (see static pre-compression).

### Configuration through environment variables only

- Every nginx setting has a sane default and an environment override — the image runs with no mounted config files.
- Ports, TLS, compression, proxying, caching, logging, security headers and tracing are all tuned from `docker run` or compose.
- Optional behaviors (CORS, security headers, HTTPS redirect, certificates, tracing) are switched on per site by listing them, not by editing config.

### Live config reload

- Template edits under the config tree re-render and reload nginx with no restart and no dropped connections.
- A filesystem watch reacts to saved templates; a reload signal re-renders first, then reloads.
- A failing config test keeps the old config serving; the watch re-arms itself after an overflow.
- Off by default; one switch turns it on.

### robots.txt with AI Content Signals

- `robots.txt` is generated at startup — no file to mount or maintain per environment.
- Crawling is disallowed by default, so a staging deployment is never indexed by accident.
- Emits Content Signals (contentsignals.org) to declare whether search indexing, AI training and AI input are permitted.
- A sitemap reference is added when one is declared.

### Base for nginx-based images

- A single `FROM` inherits the build pipeline, startup hooks, healthchecks, error pages and pre-compression.
- Child images customize by overriding environment defaults, never by copying or patching config files.
- New request handlers and optional behaviors are added by dropping one template file into the image; the existing config stays untouched.
- A scaffold starts a new nginx-based project with all of the above already wired.

### Localized, self-contained error pages

- Custom error pages for the ten standard status codes (400–504), generated at build time from a single template instead of nginx’s bare built-in pages.
- Visitors get their own language: the server negotiates `Accept-Language` per request (English, Spanish, Ukrainian) with automatic fallback to English — no JavaScript involved.
- Dark by default and follows the operating system’s light/dark preference through native CSS color-scheme switching.
- Fully self-contained: system fonts and no third-party requests, so pages render identically offline and under a strict Content-Security-Policy.
- Adding a language is one gettext `.po` file — pages and negotiation extend automatically on the next build.

### HTTP/3 (QUIC)

- HTTP/3 is compiled in and on by default; browsers are told about it and upgrade on their own.
- HTTP/2 and HTTP/3 share one port.
- QUIC transport and socket options are tunable at runtime for high-traffic hosts.

### Correct content types and caching

- Text is served as UTF-8, so accented characters display correctly in plain text, Markdown and CSV.
- Modern file types missing from stock nginx get the right type: JavaScript modules, subtitles, web manifests, JPEG XL and HEIC images, Opus/FLAC audio, YAML and TOML — browsers render them instead of downloading.
- Static assets get long-lived browser caching by content type, while HTML stays revalidated.
- Feeds ship as `application/xml` instead of stock `application/rss+xml`, so browsers apply the site’s XSL preview instead of raw XML.

### OpenTelemetry tracing and JSON access logs

- Each request can be exported as a trace span to any OpenTelemetry collector, and trace context can be propagated to the backend.
- Off by default, so there is no overhead until tracing is wanted; each site opts in separately.
- A JSON access log format ships ready for log pipelines that parse structured lines.

### Automatic resource hints

- Scans the site’s style sheets, scripts, images and fonts at startup and sends preload headers, so browsers start fetching them before parsing HTML.
- Each asset type can be switched on or off; scanning is opt-in.
- Preconnect and DNS-prefetch hints for third-party origins are set from a comma list.

### Security headers

- Content-Security-Policy, HSTS, Permissions-Policy, Cross-Origin-Embedder-Policy, Reporting-Endpoints, `nosniff` and frame protection are each one switch away, with restrictive defaults.
- Child images add hashes for their own inline scripts to the policy, so a strict CSP needs no `'unsafe-inline'`.
- Headers are sent on error responses too, so a 404 or 502 page is as protected as the site.
- CORS preflight is answered by nginx directly, without reaching the backend.
- HTTP-to-HTTPS redirect is available per site.

### Config validation and nginx-aware healthchecks

- The rendered config is tested before nginx starts; on failure every rendered file is logged, so the broken line is visible in the container log.
- Healthchecks query nginx itself and a real HTTP request, not only whether the process exists.
- A readiness endpoint is available for load balancers and orchestrators.
- A debug command prints the full effective config with every include expanded.

### Ready-made serving modes

- One setting chooses how a site is served: static files, a PHP application over FastCGI, static files with fallback to an application backend, or a directory listing.
- Backends are looked up when a request arrives, so nginx starts even if the application is not up yet.
- WebSocket upgrades and forwarding headers work through the proxy with no extra config.
- Child images add their own modes with one template file.

### Static asset pre-compression

- Static files are compressed once, at maximum ratio, in gzip, brotli and zstd; nginx serves the ready file with no per-request CPU cost.
- Runs at build time and is inherited by child images; it can also run at container start for content mounted from a volume.
- Watches the parent directory for an atomic symlink swap and recompresses at once, with no polling to tune.
- A standalone command compresses any directory by hand.

### Hardened TLS defaults

- TLS 1.2 and 1.3 only, with forward-secret AEAD ciphers and renegotiation disabled.
- Diffie-Hellman parameters are generated at build time, so the first handshake never waits on them.
- The nginx version is hidden from response headers and error pages.

## Inherited from B19 / Ubuntu

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
- Heavy or rate-limited checks run hourly in the background, so a slow scan never times out the probe or burns a rate limit.

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
- User identity is configurable at build time, and an opt-in root start remaps it to the host user so bind mounts keep their ownership.

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
- No test framework dependency — tests are plain shell scripts with exit codes, and a failed check names what it expected and what it found.
- Supports Jinja2 templates in tests, useful for asserting build-time values at runtime.
- Continues on failure and reports the total count; never hides partial results.

### Nothing hangs forever

- Every startup, test and one-shot step has a time bound, so a wedged tool fails loudly instead of blocking a deploy or a CI run.
- Stalled downloads are aborted, while slow ones of any size still complete.
- A flaky call can be retried with backoff in one flag, without a hand-written loop.
- An opt-in restart turns a service stuck unhealthy into a container the restart policy recovers.

See [use-timeouts](../how-to/use-timeouts.md) for the options, defaults and overrides.

### Pre-installed utility tools

- `mold` as default linker (opt-out available).
- `fd` for file finding, `minijinja-cli` for template rendering.
- `aria2c` for multi-connection downloads, `tini` as PID 1 for zombie reaping.
- Parallel compression tools: `pbzip2`, `pigz`, `pixz`.
- gettext tools for i18n compilation, `cURL` for network operations.

### XDG Base Directory paths

- Standard XDG paths (`XDG_CACHE_HOME`, `XDG_CONFIG_HOME`, `XDG_DATA_HOME`, `XDG_STATE_HOME`) are set under the app home directory.
- All paths are writable by the non-root user without privilege escalation.
