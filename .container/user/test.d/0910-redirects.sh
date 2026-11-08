#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
#
# SPDX-License-Identifier: MIT

# Lock the redirect map: each supported line answers its status and target, its slash twin follows, unsupported lines and duplicates never reach nginx.

set -eou pipefail

WORKDIR="$(mktemp --directory)"
PORT=18177

# shellcheck disable=SC2329 # cleanup invoked via EXIT trap
cleanup() {
  if [[ -s "${WORKDIR}/nginx.pid" ]]; then
    kill "$(<"${WORKDIR}/nginx.pid")" || true
  fi
  rm --recursive --force "${WORKDIR}"
}
trap cleanup EXIT

b19-log() { printf '%s %s %s\n' "$1" "$2" "${3:-}"; }
# shellcheck disable=SC2059 # stub replays the gettext format contract
_p() { printf -- "$1" "${@:2}"; }

export B19_RUNTIME_PATH="${WORKDIR}/run"
export O9S_NGINX_PUBLIC_PATH="${WORKDIR}/public"
export O9S_NGINX_REDIRECTS_FILE=""
export O9S_NGINX_INCLUDE_OPTIONAL="enable-cache,enable-redirects"
DATA="${B19_RUNTIME_PATH}${XDG_CONFIG_HOME}/includes/http/177-redirects.nginx.data.json"

mkdir --parents "${O9S_NGINX_PUBLIC_PATH}/kept"
echo "kept" > "${O9S_NGINX_PUBLIC_PATH}/kept/index.html"
cat > "${O9S_NGINX_PUBLIC_PATH}/_redirects" <<'EOF'
# comment
/post/old/      /post/new/
/moved          /elsewhere/     302
/forced.md      /new.md         308!
/away           https://example.org/x
/post/old       /ignored/
/splat/*        /x/
/:lang/x        /x/
/bad            /x/             200
/quote"         /x/
/one            /two            301 extra
EOF

# shellcheck source=/dev/null
. /entrypoint.d/0910-redirects.sh

b19-assert equals "REDIRECTS" 7 "$(gojq '.redirects | length' "${DATA}")"
b19-assert equals "REDIRECTS" '"/new.md"' "$(gojq '.redirects[] | select(.from == "/forced.md") | .to' "${DATA}")"
b19-assert equals "REDIRECTS" 0 "$(gojq '[.redirects[] | select(.from == "/forced.md/")] | length' "${DATA}")"

cp "${XDG_CONFIG_HOME}/includes/http/177-redirects.nginx.j2" "${WORKDIR}/"
minijinja-cli --autoescape none "${WORKDIR}/177-redirects.nginx.j2" "${DATA}" -o "${WORKDIR}/177-redirects.nginx"

cat > "${WORKDIR}/nginx.conf" <<EOF
pid ${WORKDIR}/nginx.pid;
error_log ${WORKDIR}/error.log warn;
events {}
http {
  access_log off;
  absolute_redirect off;
  client_body_temp_path ${WORKDIR};
  proxy_temp_path ${WORKDIR};
  fastcgi_temp_path ${WORKDIR};
  uwsgi_temp_path ${WORKDIR};
  scgi_temp_path ${WORKDIR};
  include ${WORKDIR}/177-redirects.nginx;
  server {
    listen 127.0.0.1:${PORT};
    root ${O9S_NGINX_PUBLIC_PATH};
    include ${XDG_CONFIG_HOME}/includes/opt/enable-redirects.nginx;
  }
}
EOF

nginx -p "${WORKDIR}" -c "${WORKDIR}/nginx.conf"

# answer PATH — prints "<status> <Location>" for one request
answer() {
  curl --silent --max-time 5 --retry 3 --retry-connrefused --output /dev/null --write-out '%{http_code} %header{location}' "http://127.0.0.1:${PORT}$1"
}

for CASE in "/post/old/|301 /post/new/" "/post/old|301 /post/new/" "/moved|302 /elsewhere/" "/moved/|302 /elsewhere/" \
  "/forced.md|308 /new.md" "/away|301 https://example.org/x" "/splat/a|404 " "/bad|404 " \
  "/post/old/?utm=x|301 /post/new/" "/kept/|200 " "/_redirects|404 "
do
  b19-assert equals "REDIRECTS" "${CASE#*|}" "$(answer "${CASE%%|*}")"
done

export O9S_NGINX_INCLUDE_OPTIONAL="enable-cache"
o9s_nginx_redirects_apply "opt off"
b19-assert equals "REDIRECTS" 0 "$(gojq '.redirects | length' "${DATA}")"

export O9S_NGINX_INCLUDE_OPTIONAL="enable-redirects"
rm "${O9S_NGINX_PUBLIC_PATH}/_redirects"
o9s_nginx_redirects_apply "file removed"
b19-assert equals "REDIRECTS" 0 "$(gojq '.redirects | length' "${DATA}")"

echo "Redirect map answers each supported line and drops the rest"
