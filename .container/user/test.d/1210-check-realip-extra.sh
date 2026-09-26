#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
#
# SPDX-License-Identifier: MIT

# Lock the extra real-IP trust rendering: named CIDRs stack onto the mode's own set, an empty list emits nothing, and an unknown provider name refuses to start.

set -eou pipefail

WORKDIR="$(mktemp --directory)"
trap 'rm --recursive --force "${WORKDIR}"' EXIT

cp "${XDG_CONFIG_HOME}/includes/http/230-realip.nginx.j2" "${WORKDIR}/"

export O9S_NGINX_REALIP_RECURSIVE="on"
export O9S_NGINX_REALIP_HEADER="X-Forwarded-For"
export O9S_NGINX_REALIP_MODE="docker"
export O9S_NGINX_REALIP_EXTRA_CIDRS="173.245.48.0/20, 2400:cb00::/32"

minijinja-cli --autoescape none --env "${WORKDIR}/230-realip.nginx.j2" -o "${WORKDIR}/extra.nginx"

for EXPECTED in 'set_real_ip_from 173.245.48.0/20;' 'set_real_ip_from 2400:cb00::/32;'
do
  if ! grep --quiet --fixed-strings "${EXPECTED}" "${WORKDIR}/extra.nginx"
  then
    echo "FATAL: extra.nginx is missing ${EXPECTED}" >&2
    exit 1
  fi
done

export O9S_NGINX_REALIP_EXTRA_CIDRS=""

minijinja-cli --autoescape none --env "${WORKDIR}/230-realip.nginx.j2" -o "${WORKDIR}/direct.nginx"

if grep --quiet --fixed-strings 'set_real_ip_from' "${WORKDIR}/direct.nginx"
then
  echo "FATAL: direct.nginx still contains an extra trusted peer" >&2
  exit 1
fi

export O9S_NGINX_REALIP_EXTRA_PROVIDERS="bogus"

# shellcheck source=/dev/null
if ( . /entrypoint.d/0810-realip-extra.sh ) 2>/dev/null
then
  echo "FATAL: unknown provider name was accepted" >&2
  exit 1
fi

echo "Extra real-IP trust renders onto the mode, vanishes when unset, and unknown providers refuse to start"
