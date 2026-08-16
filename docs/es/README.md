<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
SPDX-License-Identifier: MIT
pf-cli-managed: yes
-->

<!-- textlint-disable terminology,common-misspellings -->

[English](../../README.md) · [Українська](../uk/README.md)

# O9S / Nginx

Distribución de Nginx mantenida por la comunidad, basada en B19/GCC

[![Stand with Ukraine](https://raw.githubusercontent.com/vshymanskyy/StandWithUkraine/main/badges/StandWithUkraine.svg)](https://damian-buho.github.io/support-ukraine/) [![License](https://img.shields.io/static/v1?label=license&message=MIT&color=4c1&style=flat-square)](LICENSE) ![Commit style](https://img.shields.io/static/v1?label=commits&message=conventional&color=blue&style=flat-square) ![Workflow](https://img.shields.io/static/v1?label=workflow&message=git-flow&color=blue&style=flat-square) ![Versioning](https://img.shields.io/static/v1?label=versioning&message=semantic&color=blue&style=flat-square) [![PRs welcome](https://img.shields.io/static/v1?label=PRs&message=welcome&color=4c1&style=flat-square)](CONTRIBUTING.md) [![Citation](https://img.shields.io/static/v1?label=citation&message=cff&color=blue&style=flat-square)](CITATION.cff) [![REUSE compliance](https://api.reuse.software/badge/codeberg.org/o9s/nginx)](https://api.reuse.software/info/codeberg.org/o9s/nginx)

![Project status](https://img.shields.io/static/v1?label=status&message=maintained&color=1d63ed&style=flat-square) [![Last commit](https://img.shields.io/gitea/last-commit/o9s/nginx?gitea_url=https://codeberg.org&style=flat-square)](https://codeberg.org/o9s/nginx)

[![Build status on kiota.ch](https://kiota.ch/o9s/nginx/badges/workflows/published.yaml/badge.svg)](https://kiota.ch/o9s/nginx/actions)

## Características

- Módulo integrado de automatización de certificados ACME
- Resolución de IP real consciente de CDN
- Múltiples módulos de compresión (brotli, zstd, gzip)
- Configuración dirigida por el entorno (cero montajes de configuración)
- Directivas Content-Signal y robots.txt
- Pregeneración de parámetros DH
- Patrón de consumo descendente
- Includes de conmutadores de características (sistema opt/)
- Soporte de HTTP/3 (QUIC)
- Módulo de trazado OpenTelemetry
- Escaneo de pistas de precarga
- Sistema de andamiaje para imágenes descendentes basadas en nginx
- Precompresión de recursos estáticos
- Jerarquía de plantillas basada en includes Jinja2
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

Consulta [FEATURES.md](FEATURES.md) para ver la lista completa.

## Qué entrega este proyecto

- **Imagen de contenedor** `ghcr.io/damian-buho/o9s/nginx:latest`
- **Imagen de contenedor** `docker.io/damianbuho/o9s-nginx:latest`

## Instalación

Descarga la imagen de contenedor publicada:

```sh
docker pull ghcr.io/damian-buho/o9s/nginx:latest
docker pull docker.io/damianbuho/o9s-nginx:latest
```

Si los registros anteriores no están disponibles, descarga desde el origen:

```sh
docker pull kiota.ch/o9s/nginx:latest
```

## Uso

Levanta la pila localmente:

```sh
make dc-up
make dc-logs
make dc-down
```

## Compilación

- [Referencia del Makefile](../MAKEFILE.md)

Puntos de entrada de la canalización:

- `make analyze` — Run the heavy analysis sweep (mutation testing, benchmarks)
- `make audited` — Re-scan the pinned dependencies and published artifacts for new vulnerabilities
- `make check-outdated` — Report every pinned dependency that lags upstream
- `make ready-to-publish` — Run the pseudo-CI pipeline locally — build, test and scan, without publishing

Ejecuta `make` sin argumentos para el destino predeterminado; ejecuta `make help` para listar todos los destinos.

Para el bucle de desarrollo local, `make dev-container` levanta el dev-container.

## Hoja de ruta

Consulta la [ROADMAP.md](../../ROADMAP.md) para ver lo que viene.

## Políticas

- [Cómo contribuir](CONTRIBUTING.md)
- [Política de seguridad](SECURITY.md)
- [Cómo obtener ayuda](SUPPORT.md)
- [Código de conducta](CODE_OF_CONDUCT.md)

## Enlaces

### Proyecto

- [Especificación de Projectfile](https://projectfile.org)
- [O9S / Nginx en Codeberg](https://codeberg.org/o9s/nginx)
- [O9S / Nginx en GitHub](https://github.com/damian-buho/o9s-nginx)
- [O9S / Nginx en kiota.ch](https://kiota.ch/o9s/nginx)
- [Incidencias en Codeberg](https://codeberg.org/o9s/nginx/issues)
- [Incidencias en GitHub](https://github.com/damian-buho/o9s-nginx/issues)
- [Packages on crates.io](https://crates.io/crates/nginx)

### Otros

- [Del autor](https://dbuho.me)

## Licencia

Este proyecto se publica bajo la licencia MIT — consulta el archivo [LICENSE](LICENSE) para más detalles.

*Generado desde projectfile ([saber cómo](https://projectfile.org/how-to/readme))*
<!-- textlint-enable -->
