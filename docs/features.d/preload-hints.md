<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

# Automatic resource hints

- Scans the site’s style sheets, scripts, images and fonts at startup and sends preload headers, so browsers start fetching them before parsing HTML.
- Each asset type can be switched on or off; scanning is opt-in.
- Preconnect and DNS-prefetch hints for third-party origins are set from a comma list.
