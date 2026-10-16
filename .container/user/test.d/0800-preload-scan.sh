#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
#
# SPDX-License-Identifier: MIT

# Lock the preload scan refactor: a rescan rewrites the data files, disabled stays silent.
set -eou pipefail

WORKDIR="$(mktemp --directory)"
trap 'rm --recursive --force "${WORKDIR}"' EXIT

mkdir -p "${WORKDIR}/config/includes/server" "${WORKDIR}/config/includes/http" "${WORKDIR}/assets"

b19-log() { printf '%s %s %s\n' "$1" "$2" "${3:-}"; }
# shellcheck disable=SC2059 # stub replays the gettext format contract
_p() { printf -- "$1" "${@:2}"; }

export XDG_CONFIG_HOME="${WORKDIR}/config"
export O9S_NGINX_PH_SCAN_ENABLED=Y
export O9S_NGINX_PH_SCAN_PATH="${WORKDIR}/assets"
export O9S_NGINX_PH_SCAN_ENABLED_STYLE=Y
export O9S_NGINX_PH_SCAN_ENABLED_SCRIPT=Y
export O9S_NGINX_PH_SCAN_ENABLED_IMAGE=N
export O9S_NGINX_PH_SCAN_ENABLED_FONT=N

echo "body{}" > "${WORKDIR}/assets/app.css"
echo "console.log(1)" > "${WORKDIR}/assets/app.js"

# shellcheck source=/dev/null
. /entrypoint.d/0800-scan-preload-assets.sh

DATA="${WORKDIR}/config/includes/server/preload_hints.nginx.data.json"
if ! grep --quiet --fixed-strings '"path":"app.css","type":"style"' "${DATA}"; then
  echo "FATAL: startup scan missed the stylesheet" >&2
  exit 1
fi

echo "console.log(2)" > "${WORKDIR}/assets/late.js"
o9s_nginx_ph_scan "test rescan"
if ! grep --quiet --fixed-strings '"path":"late.js","type":"script"' "${DATA}"; then
  echo "FATAL: rescan missed the new script" >&2
  exit 1
fi
if ! grep --quiet --fixed-strings '"assets"' "${WORKDIR}/config/includes/http/135-preload-hints-map.nginx.data.json"; then
  echo "FATAL: rescan did not mirror the map data file" >&2
  exit 1
fi

rm "${DATA}"
export O9S_NGINX_PH_SCAN_ENABLED=N
o9s_nginx_ph_scan "test disabled"
if [ -f "${DATA}" ]; then
  echo "FATAL: disabled scan wrote a data file" >&2
  exit 1
fi
