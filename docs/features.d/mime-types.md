<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

# Correct content types and caching

- Text is served as UTF-8, so accented characters display correctly in plain text, Markdown and CSV.
- Modern file types missing from stock nginx get the right type: JavaScript modules, subtitles, web manifests, JPEG XL and HEIC images, Opus/FLAC audio, YAML and TOML — browsers render them instead of downloading.
- Static assets get long-lived browser caching, while HTML stays revalidated.
- Files a site rewrites behind a fixed URL — a CV PDF, a feed, a Markdown page, a JSON endpoint — are revalidated instead of cached for a year, so the next publish is picked up instead of a stale copy.
- Feeds ship as `application/xml` instead of stock `application/rss+xml`, so browsers apply the site’s XSL preview instead of raw XML.
