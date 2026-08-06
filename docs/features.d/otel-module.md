<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

# OpenTelemetry tracing module

- An OpenTelemetry module is compiled as a dynamic nginx module for distributed tracing export via OTLP/gRPC.
- Activation is via `O9S_NGINX_MODULE_OTEL=Y`; disabled by default to avoid overhead when tracing is not needed.
- The OTLP endpoint (`O9S_OTEL_ENDPOINT`), service name (`O9S_OTEL_SERVICE_NAME`), and trace context propagation are all ENV-configurable.
- Exporter tuning (interval, batch size, batch count) and custom span attributes are supported.
- Per-server tracing can be enabled via the `enable-otel` opt/ include.
