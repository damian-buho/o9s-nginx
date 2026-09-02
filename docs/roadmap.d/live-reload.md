<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

# Live reload without dropping connections

- **Problem.** The minijinja config renders only at startup, so changing any env value or include file means restarting the container and cutting in-flight requests.
- **Under consideration.** Forward a reload signal (and an optional inotify watch on the include tree) to re-render the templates and reload, updating listeners and server blocks without a process restart.
- **Rests on.** nginx’s native reload signal; the render step already invoked at startup; tini’s group signal forwarding.
