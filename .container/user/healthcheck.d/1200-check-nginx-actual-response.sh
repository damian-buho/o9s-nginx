#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
#
# SPDX-License-Identifier: MIT

set -o pipefail

# shellcheck disable=SC1091

# Test actual Nginx HTTP response
# This checks real operational health, not just if nginx is installed
if ! curl -I -s "http://localhost:${O9S_NGINX_HTTP_PORT}/${O9S_NGINX_STATUS_URL}" >/dev/null 2>&1; then
  b19-log bad "HEALTH.D" "$(_p "HTTP server (O9S_NGINX_HTTP_PORT: %s) not responding" "${O9S_NGINX_HTTP_PORT}")"
  exit 1
fi

b19-log good "HEALTH.D" "$(_p "HTTP server (O9S_NGINX_HTTP_PORT: %s) is responding" "${O9S_NGINX_HTTP_PORT}")"
exit 0
