#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
#
# SPDX-License-Identifier: MIT

# Lock the security log shape: a missing file stays out of the error log unless asked, json_combined carries every field.

set -eou pipefail

WORKDIR="$(mktemp --directory)"
PORT=18215

# shellcheck disable=SC2329 # cleanup invoked via EXIT trap
cleanup() {
  if [[ -s "${WORKDIR}/nginx.pid" ]]; then
    kill "$(<"${WORKDIR}/nginx.pid")" || true
  fi
  rm --recursive --force "${WORKDIR}"
}
trap cleanup EXIT

# The default access log follows B19_VERBOSITY and B19_LOG_FORMAT
for CASE in 'warn:json:off' 'info:text:/dev/stdout default' 'info:json:/dev/stdout json_combined' 'debug:json:/dev/stdout json_combined'
do
  IFS=: read -r VERBOSITY FORMAT WANT <<<"${CASE}"
  GOT="$(O9S_NGINX_ACCESS_LOG='' B19_VERBOSITY="${VERBOSITY}" B19_LOG_FORMAT="${FORMAT}" minijinja-cli --autoescape none --env "${XDG_CONFIG_HOME}/includes/http/210-access_log.nginx.j2" | grep '^access_log')"
  b19-assert matches "ACCESS-LOG" "^access_log +${WANT};$" "${GOT}"
done

# The startup config test writes nothing but JSON objects under B19_LOG_FORMAT=json
GOT="$(B19_LOG_FORMAT=json B19_VERBOSITY=debug bash -c '. /entrypoint.d/4900-test-config.sh' 2>&1)"
if [[ -z "${GOT}" ]] || ! jq --exit-status --slurp 'all(type == "object")' <<<"${GOT}" >/dev/null 2>&1; then
  echo "FATAL: config test printed a non-JSON line under B19_LOG_FORMAT=json: ${GOT}" >&2
  exit 1
fi
echo "Config test output is JSON only: $(wc --lines <<<"${GOT}") lines"

cp "${XDG_CONFIG_HOME}/includes/http/200-json_log_format.nginx" "${XDG_CONFIG_HOME}/includes/http/210-access_log.nginx.j2" "${WORKDIR}/"
mkdir "${WORKDIR}/www"
export O9S_NGINX_ACCESS_LOG="${WORKDIR}/access.log json_combined"

cat > "${WORKDIR}/nginx.conf" <<EOF
pid ${WORKDIR}/nginx.pid;
error_log ${WORKDIR}/error.log warn;
events {}
http {
  client_body_temp_path ${WORKDIR};
  proxy_temp_path ${WORKDIR};
  fastcgi_temp_path ${WORKDIR};
  uwsgi_temp_path ${WORKDIR};
  scgi_temp_path ${WORKDIR};
  include ${WORKDIR}/200-json_log_format.nginx;
  include ${WORKDIR}/210-access_log.nginx;
  server {
    listen 127.0.0.1:${PORT};
    root ${WORKDIR}/www;
  }
}
EOF

for CASE in ':0' 'off:0' 'on:1'
do
  VALUE="${CASE%%:*}"
  WANT="${CASE##*:}"
  rm --force "${WORKDIR}/access.log" "${WORKDIR}/error.log"
  O9S_NGINX_LOG_NOT_FOUND="${VALUE}" minijinja-cli --autoescape none --env "${WORKDIR}/210-access_log.nginx.j2" -o "${WORKDIR}/210-access_log.nginx"
  nginx -p "${WORKDIR}" -c "${WORKDIR}/nginx.conf"
  STATUS="$(curl --silent --max-time 5 --retry 3 --retry-connrefused --output /dev/null --write-out '%{http_code}' --header 'X-Forwarded-For: 203.0.113.7' "http://127.0.0.1:${PORT}/.env?probe=1")"
  kill "$(<"${WORKDIR}/nginx.pid")"
  for _ in $(seq 50); do [[ -e "${WORKDIR}/nginx.pid" ]] || break; sleep 0.1; done
  GOT="$(grep --count 'open()' "${WORKDIR}/error.log" || true)"
  if [[ "${STATUS}" != 404 || "${GOT}" != "${WANT}" ]]; then
    echo "FATAL: O9S_NGINX_LOG_NOT_FOUND='${VALUE}' gave status ${STATUS} and ${GOT} open() error lines, want 404 and ${WANT}" >&2
    exit 1
  fi
  echo "O9S_NGINX_LOG_NOT_FOUND='${VALUE}': ${GOT} open() error lines for a missing file"
done

LINE="$(<"${WORKDIR}/access.log")"
FILTER='.status == 404 and .request_method == "GET" and .request_uri == "/.env?probe=1" and .host == "127.0.0.1"
  and .server_protocol == "HTTP/1.1" and .http_x_forwarded_for == "203.0.113.7" and (.request_id | test("^[0-9a-f]{32}$"))
  and (.request_time | type) == "number" and .upstream_response_time == ""'
if ! jq --exit-status "${FILTER}" <<<"${LINE}" >/dev/null; then
  echo "FATAL: json_combined line misses a field: ${LINE}" >&2
  exit 1
fi
echo "json_combined carries method, URI, host, protocol, timing, request id and forwarded-for: ${LINE}"
