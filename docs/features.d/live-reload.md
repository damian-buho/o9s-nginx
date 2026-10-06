<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

# Live config reload

- Template edits under the config tree re-render and reload nginx with no restart and no dropped connections.
- A filesystem watch reacts to saved templates; a reload signal re-renders first, then reloads.
- A failing config test keeps the old config serving; the watch re-arms itself after an overflow.
- Off by default; one switch turns it on.
