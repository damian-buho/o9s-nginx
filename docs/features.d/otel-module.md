<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

# OpenTelemetry tracing and JSON access logs

- Each request can be exported as a trace span to any OpenTelemetry collector, and trace context can be propagated to the backend.
- Off by default, so there is no overhead until tracing is wanted; each site opts in separately.
- A JSON access log format ships ready for log pipelines that parse structured lines.
