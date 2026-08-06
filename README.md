<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
SPDX-License-Identifier: MIT
-->

<!-- pf-cli-managed: yes -->
# O9S / Nginx

O9S custom distribution of Nginx compiled with HTTP3 brotli zstd and ACME

[![License](https://img.shields.io/badge/license-MIT-4c1?style=flat-square)](LICENSE) [![PRs welcome](https://img.shields.io/badge/PRs-welcome-4c1?style=flat-square)](CONTRIBUTING.md) [![REUSE compliance](https://api.reuse.software/badge/codeberg.org/o9s/nginx)](https://api.reuse.software/info/codeberg.org/o9s/nginx)

![Project status](https://img.shields.io/badge/status-maintained-1d63ed?style=flat-square) [![Last commit](https://img.shields.io/gitea/last-commit/o9s/nginx?gitea_url=https://codeberg.org&style=flat-square)](https://codeberg.org/o9s/nginx)

[![Build status on kiota.ch](https://kiota.ch/o9s/nginx/badges/workflows/published.yaml/badge.svg)](https://kiota.ch/o9s/nginx/actions)

## Features

- Built-in ACME certificate automation module
- CDN-aware real IP resolution
- Multiple compression modules (brotli, zstd, gzip)
- Environment-driven configuration (zero config mounts)
- Content-Signal and robots.txt directives
- DH parameters pre-generation
- Downstream consumption pattern
- Feature toggle includes (opt/ system)
- HTTP/3 (QUIC) support
- Immutable mode for hardened deployments
- OpenTelemetry tracing module
- Preload hint scanning
- Scaffold system for downstream nginx-based images
- Pre-compression of static assets
- Jinja2 include-based template hierarchy
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

See [Features](FEATURES.md) for the full list.

## What this provides

- **Container image** `kiota.ch/o9s/nginx:latest`

## Installation

Pull the published container image:

```sh
docker pull kiota.ch/o9s/nginx:latest
```

## Building

- [Makefile reference](docs/MAKEFILE.md)

Pipeline entry points:

- `make analyze` — Run the heavy analysis sweep (mutation testing, benchmarks)
- `make audited` — Re-scan the pinned dependencies and published artifacts for new vulnerabilities
- `make check-outdated` — Report every pinned dependency that lags upstream
- `make published` — Build, test, scan and publish the release artifacts

## Policies

- [How to contribute](CONTRIBUTING.md)
- [Security policy](SECURITY.md)
- [Getting support](SUPPORT.md)
- [Code of Conduct](CODE_OF_CONDUCT.md)

## Links

### Project

- [O9S / Nginx on Codeberg](https://codeberg.org/o9s/nginx)
- [O9S / Nginx on GitHub](https://github.com/damian-buho/o9s-nginx)
- [O9S / Nginx on kiota.ch](https://kiota.ch/o9s/nginx)
- [Issues on Codeberg](https://codeberg.org/o9s/nginx/issues)
- [Issues on GitHub](https://github.com/damian-buho/o9s-nginx/issues)
- [Packages on crates.io](https://crates.io/crates/nginx)

## License

This project is licensed under MIT — see the [LICENSE](LICENSE) file for details.
