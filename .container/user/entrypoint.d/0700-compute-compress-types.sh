#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
#
# SPDX-License-Identifier: MIT

# Compute O9S_NGINX_COMPRESS_TYPES from category variables
# Runs before template rendering (1000-parallel-j2.sh)

set -euo pipefail

# shellcheck source=/dev/null
. b19-i18n
b19-log debug "COMPRESS_TYPES" "computing from category variables"

# Category variables with defaults matching Dockerfile
COMPRESS_TYPES_TEXT="${O9S_NGINX_COMPRESS_TYPES_TEXT:-text/css text/plain text/xml text/x-component text/markdown}"
COMPRESS_TYPES_JAVASCRIPT="${O9S_NGINX_COMPRESS_TYPES_JAVASCRIPT:-application/javascript application/x-javascript text/javascript}"
COMPRESS_TYPES_JSON="${O9S_NGINX_COMPRESS_TYPES_JSON:-application/json application/manifest+json application/vnd.api+json}"
COMPRESS_TYPES_XML="${O9S_NGINX_COMPRESS_TYPES_XML:-application/atom+xml application/rss+xml application/xml+rss application/xhtml+xml application/xml}"
COMPRESS_TYPES_FONTS="${O9S_NGINX_COMPRESS_TYPES_FONTS:-application/vnd.ms-fontobject application/x-font-opentype application/x-font-truetype application/x-font-ttf font/eot font/opentype font/otf font/ttf}"
COMPRESS_TYPES_IMAGES="${O9S_NGINX_COMPRESS_TYPES_IMAGES:-image/svg+xml image/vnd.microsoft.icon image/x-icon}"

# Combine all categories
COMPRESS_TYPES="${COMPRESS_TYPES_TEXT} ${COMPRESS_TYPES_JAVASCRIPT} ${COMPRESS_TYPES_JSON} ${COMPRESS_TYPES_XML} ${COMPRESS_TYPES_FONTS} ${COMPRESS_TYPES_IMAGES}"

# Export for template rendering
export O9S_NGINX_COMPRESS_TYPES="${COMPRESS_TYPES}"

b19-log debug "COMPRESS_TYPES" "computed: ${O9S_NGINX_COMPRESS_TYPES}"