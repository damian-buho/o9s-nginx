<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

# Correct content types and caching

- Text is served as UTF-8, so accented characters display correctly in plain text, Markdown and CSV.
- Modern file types missing from stock nginx get the right type: JavaScript modules, subtitles, web manifests, JPEG XL and HEIC images, Opus/FLAC audio, YAML and TOML — browsers render them instead of downloading.
- Static assets get long-lived browser caching by content type, while HTML stays revalidated.
