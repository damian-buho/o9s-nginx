#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
#
# SPDX-License-Identifier: MIT

# Lock upgrade-insecure-requests to https pages: a plain-http origin (a Tor or I2P mirror) must not get it.

set -eou pipefail

WORKDIR="$(mktemp --directory)"
PORT=18176
DIRECTIVE="upgrade-insecure-requests;"

# shellcheck disable=SC2329 # cleanup invoked via EXIT trap
cleanup() {
  if [[ -s "${WORKDIR}/nginx.pid" ]]; then
    kill "$(<"${WORKDIR}/nginx.pid")" || true
  fi
  rm --recursive --force "${WORKDIR}"
}
trap cleanup EXIT

export O9S_NGINX_DOCUMENT_TYPES="text/html"
export O9S_NGINX_CSP_UPGRADE_INSECURE_REQUESTS="${DIRECTIVE}"

cp "${XDG_CONFIG_HOME}/includes/http/176-document-headers.nginx.j2" "${WORKDIR}/"
minijinja-cli --autoescape none --env "${WORKDIR}/176-document-headers.nginx.j2" -o "${WORKDIR}/176-document-headers.nginx"

cat > "${WORKDIR}/nginx.conf" <<EOF
pid ${WORKDIR}/nginx.pid;
error_log ${WORKDIR}/error.log warn;
events {}
http {
  access_log off;
  client_body_temp_path ${WORKDIR};
  proxy_temp_path ${WORKDIR};
  fastcgi_temp_path ${WORKDIR};
  uwsgi_temp_path ${WORKDIR};
  scgi_temp_path ${WORKDIR};
  include ${WORKDIR}/176-document-headers.nginx;
  server {
    listen 127.0.0.1:${PORT};
    default_type text/html;
    location / {
      add_header Content-Security-Policy \$o9s_nginx_csp always;
      return 200 "ok";
    }
  }
}
EOF

nginx -p "${WORKDIR}" -c "${WORKDIR}/nginx.conf"

# csp_for PROTO — prints the CSP for a request carrying X-Forwarded-Proto PROTO (empty = no header)
csp_for() {
  local _proto="$1"
  local _headers=(--header "X-Forwarded-Proto: ${_proto}")
  [[ -z "${_proto}" ]] && _headers=()
  curl --silent --max-time 5 --retry 3 --retry-connrefused --dump-header - --output /dev/null "${_headers[@]}" "http://127.0.0.1:${PORT}/" | tr --delete '\r' | sed --quiet 's/^Content-Security-Policy: //Ip'
}

for CASE in "https:yes" "HTTPS:yes" "http:no" ":no" "ftp:no"
do
  PROTO="${CASE%%:*}"
  WANT="${CASE##*:}"
  CSP="$(csp_for "${PROTO}")"
  if [[ -z "${CSP}" ]]; then
    echo "FATAL: no CSP at all for X-Forwarded-Proto '${PROTO}'" >&2
    exit 1
  fi
  if [[ "${WANT}" == yes && "${CSP}" != *"${DIRECTIVE}"* ]]; then
    echo "FATAL: X-Forwarded-Proto '${PROTO}' lost ${DIRECTIVE} (CSP: ${CSP})" >&2
    exit 1
  fi
  if [[ "${WANT}" == no && "${CSP}" == *"${DIRECTIVE}"* ]]; then
    echo "FATAL: X-Forwarded-Proto '${PROTO}' still carries ${DIRECTIVE} (CSP: ${CSP})" >&2
    exit 1
  fi
  echo "X-Forwarded-Proto '${PROTO}': ${DIRECTIVE} expected=${WANT}, ok"
done

echo "upgrade-insecure-requests follows the client-facing scheme"
