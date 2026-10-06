#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
#
# SPDX-License-Identifier: MIT

# Lock the deny-prefix static carve-out: a prefix named in DENY_STATIC_PREFIXES serves static extensions from a nested allow-all location while denying everything else, and an empty carve-out renders the old plain deny for every prefix.

set -eou pipefail

WORKDIR="$(mktemp --directory)"
trap 'rm --recursive --force "${WORKDIR}"' EXIT

cp "${XDG_CONFIG_HOME}/conf.d/default.conf.j2" "${WORKDIR}/"

export O9S_NGINX_HOST="localhost"
export O9S_NGINX_INDEX_TYPE="php"
export O9S_NGINX_SSL_ENABLED="N"
export O9S_NGINX_INCLUDE_OPTIONAL=""
export O9S_NGINX_DENY_PREFIXES="/config,/plugins"
export O9S_NGINX_DENY_STATIC_PREFIXES="/plugins"
export O9S_NGINX_DENY_STATIC_EXTENSIONS="png|js|css"

minijinja-cli --autoescape none --env "${WORKDIR}/default.conf.j2" -o "${WORKDIR}/carve.nginx"

for EXPECTED in 'location ^~ /plugins {' 'location ~* \.(png|js|css)$ { allow all; }' 'location ^~ /config { deny all; }'
do
  if ! grep --quiet --fixed-strings "${EXPECTED}" "${WORKDIR}/carve.nginx"
  then
    echo "FATAL: carve.nginx is missing ${EXPECTED}" >&2
    exit 1
  fi
done

export O9S_NGINX_DENY_STATIC_PREFIXES=""

minijinja-cli --autoescape none --env "${WORKDIR}/default.conf.j2" -o "${WORKDIR}/plain.nginx"

if grep --quiet --fixed-strings 'allow all' "${WORKDIR}/plain.nginx"
then
  echo "FATAL: plain.nginx carves a static exception with no DENY_STATIC_PREFIXES" >&2
  exit 1
fi

for EXPECTED in 'location ^~ /config { deny all; }' 'location ^~ /plugins { deny all; }'
do
  if ! grep --quiet --fixed-strings "${EXPECTED}" "${WORKDIR}/plain.nginx"
  then
    echo "FATAL: plain.nginx is missing ${EXPECTED}" >&2
    exit 1
  fi
done

echo "Deny prefixes carve static assets only for named prefixes, and deny plainly otherwise"
