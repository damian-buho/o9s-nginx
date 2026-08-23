<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
SPDX-License-Identifier: MIT
-->

[Español](docs/es/ROADMAP.md) · [Українська](docs/uk/ROADMAP.md)

# Roadmap

## Project Roadmap

### Live reload without dropping connections

- **Problem.** The minijinja config renders only at startup, so changing any `O9S_NGINX_*` value or include file means restarting the container and cutting in-flight requests.
- **Under consideration.** Forward SIGHUP (and an optional inotify watch on the include tree) to re-render the `.j2` templates and run `nginx -s reload`, updating listeners and server blocks without a process restart.
- **Rests on.** nginx’s native reload signal; the render step already invoked at startup; tini’s group signal forwarding.

### Request-ID and trace context in access logs

- **Problem.** The OTel module emits traces and a JSON log format is defined, but access logs use a fixed text format with no request or trace identifier, so a log line cannot be tied to its trace when debugging.
- **Under consideration.** Generate an `X-Request-Id` per request (or honor an inbound one), echo it in a response header, and inject it plus the OTel `trace_id`/`span_id` into a selectable JSON access log.
- **Rests on.** nginx’s `$request_id` variable and the compiled OTel module’s trace-context variables; the already-defined `json_combined` log format.

### Mounted TLS certificates with a dev fallback

- **Problem.** The only certificate source is the built-in ACME module, which needs a real domain and DNS or HTTP validation; an operator with existing certs, an internal CA, or a plain localhost HTTPS need has no env path and must hand-author includes.
- **Under consideration.** An env-driven cert pair (`O9S_NGINX_SSL_CERT` / `_KEY`) that wires `ssl_certificate` and `ssl_certificate_key` through the existing TLS server-block gate, plus a one-flag self-signed generator for local development.
- **Rests on.** nginx’s `ssl_certificate` directives and the existing `O9S_NGINX_SSL_ENABLED` gate; b19 Docker-secrets auto-loading for key material.
