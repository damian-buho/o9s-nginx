<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

# Redirects for moved pages

- A site keeps its old addresses alive after a rename: each moved page answers with a permanent redirect to its new address, so search engines carry the ranking over.
- The redirects ship as a `_redirects` file inside the published site, in the same format Netlify and Cloudflare Pages read, so they change together with the pages they point to.
- A publish that swaps the site in picks up its new redirects with no restart.
- A malformed line is skipped and named in the log; it never takes the rest of the site down.
