<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

# Live reload without dropping connections

- **Problem.** The minijinja config renders only at startup, so changing any `O9S_NGINX_*` value or include file means restarting the container and cutting in-flight requests.
- **Under consideration.** Forward SIGHUP (and an optional inotify watch on the include tree) to re-render the `.j2` templates and run `nginx -s reload`, updating listeners and server blocks without a process restart.
- **Rests on.** nginx’s native reload signal; the render step already invoked at startup; tini’s group signal forwarding.
