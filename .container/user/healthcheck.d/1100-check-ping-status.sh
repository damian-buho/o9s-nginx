#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
#
# SPDX-License-Identifier: MIT

set -o pipefail

# shellcheck disable=SC1091

# Check if nginx is responding with HTTP 200
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:${O9S_NGINX_HTTP_PORT}/${O9S_NGINX_STATUS_URL}")
if [ "$RESPONSE" -eq 200 ]; then
  b19-log good "HEALTH.D" "$(_p "NGINX (O9S_NGINX_HTTP_PORT: %s, O9S_NGINX_STATUS_URL: %s) is responding with HTTP 200" "${O9S_NGINX_HTTP_PORT}" "${O9S_NGINX_STATUS_URL}")"
  exit 0
else
  b19-log bad "HEALTH.D" "$(_p "NGINX (O9S_NGINX_HTTP_PORT: %s, O9S_NGINX_STATUS_URL: %s) is not responding (HTTP %s)" "${O9S_NGINX_HTTP_PORT}" "${O9S_NGINX_STATUS_URL}" "${RESPONSE}")"
  exit 1
fi
