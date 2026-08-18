<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

<!-- textlint-disable terminology,common-misspellings -->

# Módulo de trazado OpenTelemetry

- Un módulo de OpenTelemetry se compila como módulo dinámico de nginx para la exportación de trazado distribuido vía OTLP/gRPC.
- Se activa con `O9S_NGINX_MODULE_OTEL=Y`; está desactivado por defecto para evitar sobrecarga cuando no se necesita trazado.
- El endpoint OTLP (`O9S_OTEL_ENDPOINT`), el nombre del servicio (`O9S_OTEL_SERVICE_NAME`) y la propagación de contexto de traza son configurables por ENV.
- Se admiten el ajuste del exportador (intervalo, tamaño y cantidad de lotes) y atributos de span personalizados.
- El trazado por servidor puede activarse mediante el include opt/ `enable-otel`.

<!-- textlint-enable -->
