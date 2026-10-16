#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
#
# SPDX-License-Identifier: MIT

# Lock the idempotent CSP merge: re-apply never duplicates, removal restores base.
set -eou pipefail

WORKDIR="$(mktemp --directory)"
trap 'rm --recursive --force "${WORKDIR}"' EXIT
mkdir -p "${WORKDIR}/csp"

b19-log() { printf '%s %s %s\n' "$1" "$2" "${3:-}"; }
# shellcheck disable=SC2059 # stub replays the gettext format contract
_p() { printf -- "$1" "${@:2}"; }

export B19_HOME="${WORKDIR}"
export O9S_NGINX_CSP_SCRIPT_SRC="'self' 'wasm-unsafe-eval'"
export O9S_NGINX_CSP_STYLE_SRC="'self' 'unsafe-inline'"
export O9S_NGINX_CSP_DIR="${WORKDIR}/csp"

echo "'sha256-AAA='" > "${WORKDIR}/csp/script-src.txt"

# shellcheck source=/dev/null
. /entrypoint.d/0900-csp-hashes.sh

if [ "${O9S_NGINX_CSP_SCRIPT_SRC}" != "'self' 'wasm-unsafe-eval' 'sha256-AAA='" ]; then
  echo "FATAL: startup merge wrong: ${O9S_NGINX_CSP_SCRIPT_SRC}" >&2
  exit 1
fi

o9s_nginx_csp_apply "test rerun"
if [ "${O9S_NGINX_CSP_SCRIPT_SRC}" != "'self' 'wasm-unsafe-eval' 'sha256-AAA='" ]; then
  echo "FATAL: re-apply duplicated tokens: ${O9S_NGINX_CSP_SCRIPT_SRC}" >&2
  exit 1
fi

echo "'sha256-BBB=' 'sha256-CCC='" > "${WORKDIR}/csp/script-src.txt"
o9s_nginx_csp_apply "test changed"
if [ "${O9S_NGINX_CSP_SCRIPT_SRC}" != "'self' 'wasm-unsafe-eval' 'sha256-BBB=' 'sha256-CCC='" ]; then
  echo "FATAL: changed tokens not served: ${O9S_NGINX_CSP_SCRIPT_SRC}" >&2
  exit 1
fi

rm "${WORKDIR}/csp/script-src.txt"
o9s_nginx_csp_apply "test removed"
if [ "${O9S_NGINX_CSP_SCRIPT_SRC}" != "'self' 'wasm-unsafe-eval'" ]; then
  echo "FATAL: removed file left stale tokens: ${O9S_NGINX_CSP_SCRIPT_SRC}" >&2
  exit 1
fi

echo "'self'" > "${WORKDIR}/csp/bogus-directive.txt"
o9s_nginx_csp_apply "test bogus" 2>"${WORKDIR}/bogus.log" || true
if grep --quiet "O9S_NGINX_CSP_BOGUS_DIRECTIVE" <<<"$(compgen -v 'O9S_NGINX_CSP_')"; then
  echo "FATAL: unknown directive created a variable" >&2
  exit 1
fi
rm "${WORKDIR}/csp/bogus-directive.txt"

: > "${WORKDIR}/csp/script-src.txt"
o9s_nginx_csp_apply "test empty"
if [ "${O9S_NGINX_CSP_SCRIPT_SRC}" != "'self' 'wasm-unsafe-eval'" ]; then
  echo "FATAL: empty file changed the directive: ${O9S_NGINX_CSP_SCRIPT_SRC}" >&2
  exit 1
fi
rm "${WORKDIR}/csp/script-src.txt"
