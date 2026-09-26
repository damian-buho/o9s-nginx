#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
#
# SPDX-License-Identifier: MIT

# Lock the single real_ip_header emission: nginx refuses a duplicate with emerg, so exactly one template (230) may carry the directive and a CDN mode lends its header through the environment instead.

set -eou pipefail

# shellcheck source=/dev/null
. b19-i18n

REALIP_DIR="${XDG_CONFIG_HOME}/includes/realip"

MODE_HEADERS="$(grep --count 'real_ip_header' "${XDG_CONFIG_HOME}/includes/http/230-realip.nginx.j2")"

if [ "${MODE_HEADERS}" -ne 1 ]
then
  echo "FATAL: 230-realip must emit exactly one real_ip_header, found ${MODE_HEADERS}" >&2
  exit 1
fi

STRAY_HEADERS="$(grep --files-with-matches 'real_ip_header' "${REALIP_DIR}"/*.nginx.j2 || true)"

if [ -n "${STRAY_HEADERS}" ]
then
  echo "FATAL: a mode template emits its own real_ip_header:" >&2
  echo "${STRAY_HEADERS}" >&2
  exit 1
fi

curl() {
  printf '173.245.48.0/20\n'
}

SAVED_HEADER="${O9S_NGINX_REALIP_HEADER:-}"
export O9S_NGINX_REALIP_MODE="cloudflare"

# shellcheck source=/dev/null
. /entrypoint.d/0800-update-realip-sources.sh

if [ "${O9S_NGINX_REALIP_HEADER:-}" != "CF-Connecting-IP" ]
then
  echo "FATAL: cloudflare mode left header at ${O9S_NGINX_REALIP_HEADER:-<unset>}, want CF-Connecting-IP" >&2
  exit 1
fi

if [ -n "${SAVED_HEADER}" ]
then
  export O9S_NGINX_REALIP_HEADER="${SAVED_HEADER}"
else
  unset O9S_NGINX_REALIP_HEADER
fi

echo "real_ip_header is emitted exactly once and cloudflare mode lends CF-Connecting-IP"
