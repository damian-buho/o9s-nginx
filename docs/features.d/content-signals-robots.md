<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

# robots.txt with AI Content Signals

- `robots.txt` is generated at startup — no file to mount or maintain per environment.
- Crawling is disallowed by default, so a staging deployment is never indexed by accident.
- Emits Content Signals (contentsignals.org) to declare whether search indexing, AI training and AI input are permitted.
- A sitemap reference is added when one is declared.
