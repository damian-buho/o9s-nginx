<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

# Jinja2 include-based template hierarchy

- Configuration templates layer predictably — base, includes, and per-project overrides merge in a clear order.
- The http block pulls in numbered snippets covering core settings, compression, proxy, TLS, logging, and telemetry.
- Server blocks compose from modular includes for socket config, error pages, content handlers, and feature toggles.
- New behaviors are added by placing a file into the appropriate includes directory — no editing of existing templates required.
