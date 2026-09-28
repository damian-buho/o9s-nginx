<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

# Base for nginx-based images

- A single `FROM` inherits the build pipeline, startup hooks, healthchecks, error pages and pre-compression.
- Child images customize by overriding environment defaults, never by copying or patching config files.
- New request handlers and optional behaviors are added by dropping one template file into the image; the existing config stays untouched.
- A scaffold starts a new nginx-based project with all of the above already wired.
