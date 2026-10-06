#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
#
# SPDX-License-Identifier: MIT

# Lock the php entry-point allowlist: named entries render exact-match FastCGI locations with every other .php denied, and an empty list renders the old catch-all .php location with no deny.

set -eou pipefail

WORKDIR="$(mktemp --directory)"
trap 'rm --recursive --force "${WORKDIR}"' EXIT

cp "${XDG_CONFIG_HOME}/includes/index/php.nginx.j2" "${WORKDIR}/"

export O9S_NGINX_PUBLIC_PATH="/matomo"
export O9S_NGINX_FASTCGI_BACKEND_HOST="backend"
export O9S_NGINX_FASTCGI_BACKEND_PORT="9000"
export O9S_NGINX_PHP_ENTRY_POINTS="index,matomo,js/index"

minijinja-cli --autoescape none --env "${WORKDIR}/php.nginx.j2" -o "${WORKDIR}/allow.nginx"

for EXPECTED in 'location = /index.php {' 'location = /matomo.php {' 'location = /js/index.php {'
do
  if ! grep --quiet --fixed-strings "${EXPECTED}" "${WORKDIR}/allow.nginx"
  then
    echo "FATAL: allow.nginx is missing ${EXPECTED}" >&2
    exit 1
  fi
done

for EXPECTED in 'location ~ \.php$ {' 'deny all;'
do
  if ! grep --quiet --fixed-strings "${EXPECTED}" "${WORKDIR}/allow.nginx"
  then
    echo "FATAL: allow.nginx is missing ${EXPECTED}" >&2
    exit 1
  fi
done

export O9S_NGINX_PHP_ENTRY_POINTS=""

minijinja-cli --autoescape none --env "${WORKDIR}/php.nginx.j2" -o "${WORKDIR}/open.nginx"

if grep --quiet --fixed-strings 'deny all' "${WORKDIR}/open.nginx"
then
  echo "FATAL: open.nginx denies .php with no PHP_ENTRY_POINTS" >&2
  exit 1
fi

if ! grep --quiet --fixed-strings 'location ~ \.php$ {' "${WORKDIR}/open.nginx"
then
  echo "FATAL: open.nginx is missing the catch-all .php location" >&2
  exit 1
fi

echo "PHP entry points render exact-match locations with deny-all fallback, and stay open when unset"
