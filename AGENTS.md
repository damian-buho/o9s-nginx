<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

# o9s/nginx

Docker image built on [b19/gcc](../../b19/gcc/AGENTS.md), [b19/rust](../../b19/rust/AGENTS.md), and [b19/Ubuntu](../../b19/ubuntu/AGENTS.md)

nginx compiled from source with HTTP/3 (QUIC), brotli, zstd, and optional ACME/OpenTelemetry modules.

## Key facts

- 3-stage Dockerfile: `b19/gcc-{series}` (nginx compile) + `b19/rust` (acme module) → `b19/ubuntu/${B19_UBUNTU_SERIES}` (final)
- Makefile includes: `m6e`, `gcc`, `rust`
- No series axis (single image)
- Arch: amd64, arm64

## ENV over config files — core design principle

**No nginx config files are mounted or volume-mapped at runtime.** Every single nginx directive is controlled through `O9S_NGINX_*` environment variables with sensible defaults baked into the Dockerfile `ENV` block (200+ vars). This means:

- Downstream images and compose files never need to mount `/etc/nginx/` or supply `.conf` files
- All tuning is done via `environment:` in compose or `ENV` in child Dockerfiles
- The image is fully functional with zero config mounts — just `docker run` and it works

### How it works — Jinja2 template rendering

The entire nginx config tree lives as Jinja2 (`.j2`) templates inside the image at `${XDG_CONFIG_HOME}/`:

```text
app/etc/
├── nginx.conf.j2          ← main config
├── modules.conf.j2        ← dynamic module loading
├── conf.d/
│   └── default.conf.j2    ← server block template
└── includes/
    ├── http/     (25 files, numbered 010–240)
    ├── listen/   (6 files)
    ├── server/   (8 files)
    ├── opt/      (14 files)
    ├── index/    (4 files — html, php, proxy, auto)
    ├── fastcgi/  (2 files)
    └── realip/   (7 files)
```

All `.j2` templates are rendered at startup by the standard b19 `parallel-j2` entrypoint hook (minijinja-cli with `--env` — all container ENV vars available as `ENV.VAR_NAME`).

- `nginx.conf.j2` references `{{ ENV.O9S_NGINX_* }}` for every directive value
- `conf.d/default.conf.j2` — server block template, rendered to `conf.d/default.conf`
- `modules.conf.j2` conditionally loads modules based on `O9S_NGINX_MODULE_{BROTLI,ZSTD,OTEL,ACME}`
- `includes/http/*.nginx.j2` — 25 numbered snippets injected via `include includes/http/*.nginx;` in the `http {}` block
- Templates that need conditional logic (module on/off, optional params) use Jinja `{% if %}` blocks
- Non-conditional snippets are plain `.nginx` files (no `.j2`)

### Include hierarchy

The main config `nginx.conf.j2` uses three `include` directives to pull in everything:

```nginx
include modules.conf;                # dynamic modules
include includes/http/*.nginx;       # 24 http-block snippets (sorted by prefix number)
include conf.d/*.conf;               # rendered server blocks
```

Each server block template (`conf.d/default.conf.j2`) then includes:

```nginx
include includes/listen/http.default.nginx;             # listen directives (ENV-controlled)
include includes/server/*.nginx;                        # error pages, etag, dns-prefetch, status, etc.
include includes/index/{{ ENV.O9S_NGINX_INDEX_TYPE }}.nginx;  # content handler
include includes/opt/{{ _opt }}.nginx;                  # per O9S_NGINX_INCLUDE_OPTIONAL (space-delimited names)
```

The realip include is itself dynamic — controlled by `O9S_NGINX_REALIP_MODE`:

```nginx
include includes/realip/{{ ENV.O9S_NGINX_REALIP_MODE }}.nginx;
# Resolves to: docker.nginx, cloudflare.nginx, akamai.nginx, aws.nginx, fastly.nginx, custom.nginx, localhost.nginx
```

### HTTP include file numbering

| Range   | Category              | Examples                                                           |
| ------- | --------------------- | ------------------------------------------------------------------ |
| 010–020 | Core, AIO             | `absolute_redirect`, `send_timeout`, `aio`, `worker_connections`   |
| 030     | DNS                   | `resolver`                                                         |
| 040–060 | Compression           | brotli, gzip, zstd (all conditional on `O9S_NGINX_MODULE_*`)       |
| 070     | ACME                  | `acme_issuer` block (conditional)                                  |
| 080–090 | Client/IO             | `client_max_body_size`, `sendfile`                                 |
| 100–110 | HTTP/2+3              | `http2`, `http3`, `quic_*`                                         |
| 120–130 | Keepalive, headers    | `keepalive_timeout`, `server_tokens off`                           |
| 140–150 | Proxy, WebSocket      | Full proxy config with cache paths, `map $http_upgrade`            |
| 160–170 | File cache, CDN cache | `open_file_cache`, `map $sent_http_content_type` for Cache-Control |
| 175     | Error pages           | `map $http_accept_language $error_lang` (Accept-Language)          |
| 180     | TLS                   | `ssl_protocols`, `ssl_ciphers`, `ssl_dhparam`, session settings    |
| 190–210 | Logging               | log formats (text + JSON), access_log                              |
| 220–240 | Root, realip, OTel    | `root`, `real_ip_recursive`, `otel_exporter`                       |

### opt/ includes — feature toggles

Files in `includes/opt/` are conditionally included by server-block templates in downstream images. Each is a self-contained feature:

- `enable-cors.nginx.j2` — CORS via `O9S_NGINX_CORS_*` (6 vars)
- `enable-csp.nginx.j2` — Content-Security-Policy via `O9S_NGINX_CSP_*` (18 vars)
- `enable-hsts.nginx.j2` — HSTS via `O9S_NGINX_HSTS_*`
- `enable-status.nginx.j2` — stub_status at `O9S_NGINX_STATUS_URL`
- `enable-permissions-policy.nginx.j2` — Permissions-Policy via `O9S_NGINX_PERMISSION_*` (12 vars)
- `enable-otel.nginx.j2` — per-server OTel tracing (conditional on module)
- `enable-acme.nginx.j2` — per-server ACME certificate (conditional)
- `enable-certbot.nginx.j2` — certbot certificate paths
- `enable-cache.nginx.j2` — `Cache-Control` from the `$cache_control_value` map
- `enable-favicon.nginx.j2` — favicon location
- `enable-nosniff.nginx` / `enable-sameorigin.nginx` — security headers (static, no ENV)
- `redirect-to-https.nginx` — HTTP→HTTPS redirect (static)

### index/ includes — content handlers

`O9S_NGINX_INDEX_TYPE` selects the content handler. The `include` path is dynamic:

```nginx
include includes/index/{{ ENV.O9S_NGINX_INDEX_TYPE }}.nginx;
```

| Type             | File                    | Purpose                                                                      |
| ---------------- | ----------------------- | ---------------------------------------------------------------------------- |
| `html` (default) | `html.nginx.j2`         | Static file serving with `index index.html`                                  |
| `php`            | `php.nginx.j2`          | PHP via FastCGI (`includes/fastcgi/common.nginx`)                            |
| `proxy`          | `proxy.nginx.j2`        | Reverse proxy to `O9S_NGINX_BACKEND_{SCHEME,HOST,PORT}`                      |
| `static-proxy`   | `static-proxy.nginx.j2` | Serve static files with `try_files`, fallback proxy to `O9S_NGINX_BACKEND_*` |
| `auto`           | `auto.nginx`            | Directory listing (`autoindex on`)                                           |
| `cache`          | `cache.nginx.j2`        | (downstream) HTTP caching proxy — see r8e/http-cache                         |

> **Warning — `fastcgi_intercept_errors on`.** `includes/fastcgi/common.nginx`
> enables interception, and every server block maps `400…504` to the localized
> static error pages. An upstream that answers `403 Forbidden` with its own HTML
> (Matomo’s deactivated-plugin page, a framework debug screen…) gets its body
> silently REPLACED by the o9s/nginx page — you debug the wrong thing. To see
> what the backend actually said, flip `fastcgi_intercept_errors off`
> temporarily in the rendered include (`show-config` finds the file) and reload.

Downstream images can add new index types by placing a `.nginx.j2` file in `includes/index/` and setting `O9S_NGINX_INDEX_TYPE`.

### listen/ includes — ENV-driven socket config

All listen directives are generated from a single complex Jinja expression per protocol:

```text
listen <port> [ssl] [quic] [default_server] [reuseport] [deferred] [backlog=N] [fastopen=N] [proxy_protocol] [so_keepalive=N] [rcvbuf=N] [sndbuf=N];
```

Every socket option is controlled by a `O9S_NGINX_LISTEN_*` env var. Empty vars are omitted. The `.default.nginx` variants add `default_server`.

### realip/ includes — CDN-aware IP resolution

`O9S_NGINX_REALIP_MODE` selects which set of trusted IPs to load:

| Mode               | File                  | Source                                            |
| ------------------ | --------------------- | ------------------------------------------------- |
| `docker` (default) | `docker.nginx`        | Static: 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 |
| `cloudflare`       | `cloudflare.nginx.j2` | Live fetch from cloudflare.com/ips-v4 + ips-v6    |
| `akamai`           | `akamai.nginx.j2`     | Live fetch from techdocs.akamai.com               |
| `aws`              | `aws.nginx.j2`        | Live fetch from ip-ranges.amazonaws.com           |
| `fastly`           | `fastly.nginx.j2`     | Live fetch from api.fastly.com/public-ip-list     |
| `custom`           | `custom.nginx.j2`     | Uses `O9S_NGINX_REALIP_NETWORK` subnet            |
| `localhost`        | `localhost.nginx`     | 127.0.0.1                                         |

CDN modes (`cloudflare`, `akamai`, `aws`, `fastly`) use `.j2` templates rendered at startup with live IP data fetched by `entrypoint.d/0800-update-realip-sources.sh`. Data is written to `.nginx.data.json` sidecar files.

### Downstream consumption pattern

Child images (e.g., `r8e/http-cache`) consume o9s/nginx by:

1. `FROM o9s/nginx` — inherit all 200+ ENV defaults
1. Override specific `ENV` in Dockerfile (e.g., `O9S_NGINX_INDEX_TYPE=cache`, cache durations)
1. Optionally add custom `includes/index/*.nginx.j2` or `includes/opt/*.nginx.j2` for new behaviors
1. Never mount or map config files — everything is ENV-driven
1. After `COPY`ing real content into `${O9S_NGINX_PUBLIC_PATH}`, set
   `O9S_NGINX_PRECOMPRESS_ENTRYPOINT_ENABLED=Y` in the child image: `COPY` only
   overwrites files the source carries, so the base’s precompressed placeholder
   siblings (`index.html.{br,gz,zst}`) survive, and nginx’s `*_static` modules
   serve them to every Accept-Encoding client — CDNs always send one. Stages
   that run `build-stage user` are covered by the inherited
   `900-static-compression.i.sh`; the entrypoint ENV is the bare-stage path.

Example (r8e/http-cache): overrides 15 proxy cache ENV defaults and adds a single `includes/index/cache.nginx.j2` file. No config mounts needed.

## scaffold/

`scaffold/` directory contains a Dockerfile template and `stack.conf` for creating new nginx-based projects. It uses `STACK_ROOT_STAGE=base` and `STACK_EXTENSIONS=nginx` for m6e stack integration.

## ENV reference

All 200+ `O9S_NGINX_*` env vars are declared with defaults in the Dockerfile `ENV` block (lines 107–318). Key categories:

| Prefix                          | Controls                                                          |
| ------------------------------- | ----------------------------------------------------------------- |
| `O9S_NGINX_{HTTP,HTTPS}_PORT`   | Listen ports                                                      |
| `O9S_NGINX_HTTP{2,3}*`          | HTTP/2 and HTTP/3 settings                                        |
| `O9S_NGINX_{GZIP,BROTLI,ZSTD}*` | Compression algorithms and levels                                 |
| `O9S_NGINX_PROXY_*`             | Reverse proxy buffer/cache/timeout settings                       |
| `O9S_NGINX_FASTCGI_*`           | FastCGI buffer/cache/timeout settings                             |
| `O9S_NGINX_CSP_*`               | Content-Security-Policy directives                                |
| `O9S_NGINX_CORS_*`              | CORS headers                                                      |
| `O9S_NGINX_PERMISSION_*`        | Permissions-Policy directives                                     |
| `O9S_NGINX_MODULE_*`            | Dynamic module on/off (brotli, zstd, otel, acme)                  |
| `O9S_NGINX_LISTEN_*`            | Socket options (reuseport, deferred, backlog, etc.)               |
| `O9S_NGINX_SSL_*`               | TLS protocols, ciphers, session settings                          |
| `O9S_NGINX_ACCESS_LOG`          | Full `access_log` value — `/dev/stdout default`; `off` disables   |
| `O9S_NGINX_PRECOMPRESS_*`       | Build-time and startup pre-compression                            |
| `O9S_NGINX_REALIP_*`            | Real-IP header and CDN mode                                       |
| `O9S_NGINX_OTEL_*`              | OpenTelemetry endpoint and tracing                                |
| `O9S_NGINX_PH_*`                | Preload hint scanning                                             |
| `O9S_NGINX_CACHE_*`             | Cache paths and policies                                          |
| `O9S_NGINX_INCLUDE_OPTIONAL`    | Space-delimited opt/ includes (e.g. `"enable-cache enable-cors"`) |
| `O9S_NGINX_OPEN_FILE_CACHE_*`   | File descriptor caching                                           |
| `CONTENT_SIGNALS_*`             | robots.txt Content-Signal directives                              |

## Version pin discrepancy

Dockerfile ARG `O9S_NGINX_UPSTREAM_VERSION` differs from `deps/nginx/version.deps` content — the deps file wins (used by `make fetch` and during build hook). Check the deps file for the actual pinned version.

## Reading deps/module data files

`url`, `commit`, `dir`, `version.deps`, etc. all carry SPDX license headers (REUSE). Reading them with plain `cat` leaks the comment lines into the value. The in-image `decomment` (`/tools.d/decomment`) is a **stdin-only filter** — it ignores file arguments, so `decomment FILE` silently reads whatever is on stdin. Always use the redirect form: `decomment < "${MODULE_DIR}/url"`. This applies to every `install.sh` / `build.sh` / configure hook that reads a deps file.

## CDN real-IP

`entrypoint.d/0800-update-realip-sources.sh` fetches live Cloudflare/Akamai/AWS/Fastly IP ranges at every container start. Skipped when `B19_IMMUTABLE=Y`.

## CSP tokens from downstream

`entrypoint.d/0900-csp-hashes.sh` reads `${O9S_NGINX_CSP_DIR}` (default
`/app/.csp`) and appends each `<directive>.txt`'s whitespace-separated tokens to
the matching `O9S_NGINX_CSP_<DIRECTIVE>` before the templates render. It is how a
consumer drops `'sha256-…'` for its own inline scripts into `script-src` without
`'unsafe-inline'` and without this image knowing anything about that site.

The tokens must hash the exact bytes between `>` and `</script>` — CSP does not
trim or normalise them, and a consumer that hashes a trimmed body ships a header
that blocks every script it meant to allow. Hashes never cover inline event
handlers (`onload="…"`); those need removing at the source, not `'unsafe-hashes'`.

Keep the directory OUT of the document root. The policy is already public in the
header, and a copy under `${O9S_NGINX_PUBLIC_PATH}` only invites drift.

## Entrypoint order

| Script                          | Purpose                                                                    |
| ------------------------------- | -------------------------------------------------------------------------- |
| `0800-scan-preload-assets.sh`   | Scan `${O9S_NGINX_ROOT}/${O9S_NGINX_PH_SCAN_PATH}` for CSS/JS/images/fonts |
| `0800-update-realip-sources.sh` | Fetch live CDN IP ranges                                                   |
| `0900-csp-hashes.sh`            | Append `${O9S_NGINX_CSP_DIR}/<directive>.txt` tokens to `O9S_NGINX_CSP_*`  |
| `1300-precompress-assets.sh`    | Pre-compress static assets if enabled                                      |
| `5000-start.sh`                 | `b19-exec --stdout-level warn --stderr-level warn -- nginx`                |

## Commands

- `compress-static-assets` — parallel gzip (pigz) + brotli + zstd pre-compression of static files
- `show-config` — recursively expands all nginx `include` directives for debugging
- `get-nginx-version` — extracts nginx version string

## robots.txt

Jinja template (`.container/user/app/public/robots.txt.j2`), rendered at startup:

- `O9S_NGINX_ROBOTS_TXT_DEFAULT_POLICY` — `disallow` (default), `allow`, `none` (omit default block)
- `CONTENT_SIGNALS_SEARCH=Y` / `CONTENT_SIGNALS_TRAIN=Y` / `CONTENT_SIGNALS_INPUT=Y` — emit `Content-Signal:` directive per contentsignals.org (`ai-train`, `search`, `ai-input` with `yes`/`no` values)
- `O9S_NGINX_ROBOTS_TXT_SITEMAP` — if set, adds `Sitemap:` line

## Pre-generated assets

`dhparams.pem` (2048-bit) generated at build time by `build.d/user/post/400-dhparams.sh` if not already present. Localized error pages (10 codes × every `.po` language) generated by `260-generate-error-pages.sh` into `${B19_HOME}/errors/<lang>/` — nothing committed under `app/errors/`. See [error pages](docs/error-pages.md).

## Build hooks

| Hook                                     | Stage | Purpose                                            |
| ---------------------------------------- | ----- | -------------------------------------------------- |
| `user/post/250-generate-modules-conf.sh` | user  | Writes `modules.conf` from compiled `.so` files    |
| `user/post/260-generate-error-pages.sh`  | user  | Renders localized error pages + language sidecar   |
| `user/post/400-dhparams.sh`              | user  | Generates DH params if missing                     |
| `user/post/900-static-compression.i.sh`  | user  | Pre-compresses static assets (inheritable — `.i.`) |

## Healthchecks

1. `1100-check-ping-status.sh` — cURL HTTP 200 on `${O9S_NGINX_HTTP_PORT}/${O9S_NGINX_STATUS_URL}`
1. `1200-check-nginx-actual-response.sh` — cURL HEAD on `${O9S_NGINX_HTTP_PORT}`

## Tests

1. `0300-apt-versions.sh` — verify brotli binary
1. `1100-nginx-version.sh` — verify nginx binary
1. `1200-nginx-test.sh` — `nginx -t`
1. `1300-nginx-modules.sh` — verify all 6 dynamic modules exist
1. `1400-error-pages.sh` — verify every language dir holds all 10 error pages

## Immutable mode

When `B19_IMMUTABLE=Y`, the entrypoint skips all config generation — the image must contain pre-rendered configs. Used for hardened/readonly deployments.

## Documentation

[Project goals and objectives](@docs/goal.md)
[Fitness criteria and acceptance](@docs/fit.md)
[Completed features and milestones](@docs/done.md)
[Known limitations and caveats](@docs/caveats.md)
[Future development plans](@docs/roadmap.md)
[Available make targets](@docs/MAKEFILE.md)
