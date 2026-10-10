#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
#
# SPDX-License-Identifier: MIT

# Lock WebSocket proxying: Connection comes from the $connection_upgrade map, so only a real Upgrade request is switched.

set -eou pipefail

# shellcheck source=/dev/null
. b19-i18n

HTTP_DIR="${XDG_CONFIG_HOME}/includes/http"

if ! grep --quiet --extended-regexp "^proxy_set_header\s+Connection\s+\\\$connection_upgrade;" "${HTTP_DIR}/140-proxy.nginx.j2"
then
  echo "FATAL: 140-proxy must set Connection from \$connection_upgrade" >&2
  exit 1
fi

if ! grep --quiet --fixed-strings "map \$http_upgrade \$connection_upgrade" "${HTTP_DIR}/150-ws.nginx.j2"
then
  echo "FATAL: 150-ws must define the \$connection_upgrade map" >&2
  exit 1
fi

if ! grep --quiet --extended-regexp "^\s+''\s+close;" "${HTTP_DIR}/150-ws.nginx.j2"
then
  echo "FATAL: 150-ws must close the connection when no Upgrade header is sent" >&2
  exit 1
fi

echo "Connection follows the Upgrade header through the \$connection_upgrade map"
