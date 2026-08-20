<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

# Request-ID and trace context in access logs

- **Problem.** The OTel module emits traces and a JSON log format is defined, but access logs use a fixed text format with no request or trace identifier, so a log line cannot be tied to its trace when debugging.
- **Under consideration.** Generate an `X-Request-Id` per request (or honor an inbound one), echo it in a response header, and inject it plus the OTel `trace_id`/`span_id` into a selectable JSON access log.
- **Rests on.** nginx’s `$request_id` variable and the compiled OTel module’s trace-context variables; the already-defined `json_combined` log format.
