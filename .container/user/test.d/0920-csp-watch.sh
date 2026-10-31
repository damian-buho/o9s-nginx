#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
#
# SPDX-License-Identifier: MIT

# Lock the policy watch: arming never reloads, a staged swap reloads once, a
# token edit alone never reloads ahead of the swap, a flat token edit reloads.
set -eou pipefail

WORKDIR="$(mktemp --directory)"
trap 'rm --recursive --force "${WORKDIR}"' EXIT

mkdir -p "${WORKDIR}/bin" "${WORKDIR}/state" "${WORKDIR}/parent/real1" "${WORKDIR}/parent/real2" "${WORKDIR}/csp" "${WORKDIR}/flat"
export PATH="${WORKDIR}/bin:${PATH}"
export MARKER="${WORKDIR}/calls.txt"
export B19_HOME="${WORKDIR}"
export XDG_STATE_HOME="${WORKDIR}/state"
export B19_RUNTIME_PATH="${WORKDIR}/run-staged"  # own b19-exec claims: the container's csp-watch keeps its name

cat > "${WORKDIR}/bin/parallel-j2" <<'EOF'
#!/usr/bin/env bash
echo "render $1" >> "${MARKER}"
EOF
cat > "${WORKDIR}/bin/nginx" <<'EOF'
#!/usr/bin/env bash
echo "nginx $*" >> "${MARKER}"
if [ "${1}" = "-t" ]; then
  if [ "${NGINX_TEST_OK:-Y}" = "Y" ]; then
    echo "nginx: configuration file test is successful"
    exit 0
  fi
  echo "nginx: configuration file test failed" >&2
  exit 1
fi
if [ "${1}" = "-s" ]; then
  echo "policy ${O9S_NGINX_CSP_SCRIPT_SRC:-}" >> "${MARKER}"
fi
exit 0
EOF
chmod +x "${WORKDIR}/bin/parallel-j2" "${WORKDIR}/bin/nginx"

b19-log() { printf '%s %s %s\n' "$1" "$2" "${3:-}"; }
# shellcheck disable=SC2059 # stub replays the gettext format contract
_p() { printf -- "$1" "${@:2}"; }

echo "$$" > "${XDG_STATE_HOME}/nginx.pid"

ln -s "real1" "${WORKDIR}/parent/link"
echo "one" > "${WORKDIR}/parent/real1/page.html"
echo "'sha256-AAA='" > "${WORKDIR}/csp/script-src.txt"

export O9S_NGINX_CSP_SCRIPT_SRC="'self'"
export O9S_NGINX_CSP_DIR="${WORKDIR}/csp"
export O9S_NGINX_PUBLIC_PATH="${WORKDIR}/parent/link"
export O9S_NGINX_CSP_WATCH_ENABLED=Y
export O9S_NGINX_CSP_WATCH_INTERVAL=1
export O9S_NGINX_CSP_WATCH_DEBOUNCE=1

# shellcheck source=/dev/null
. /entrypoint.d/0900-csp-hashes.sh
# shellcheck source=/dev/null
. /entrypoint.d/0920-csp-watch.sh
WATCHER=$!

trap 'kill -TERM "${WATCHER:-}" 2>/dev/null; trap - HUP; rm --recursive --force "${WORKDIR}"' EXIT

sleep 3
if [ -f "${MARKER}" ]; then
  echo "FATAL: watcher reloaded at arm time instead of baselining" >&2
  exit 1
fi

echo "'sha256-BBB='" > "${WORKDIR}/csp/script-src.txt"
sleep 3
if [ -f "${MARKER}" ]; then
  echo "FATAL: token edit reloaded ahead of the staged swap" >&2
  exit 1
fi

ln -s "real2" "${WORKDIR}/parent/link.new"
mv -T "${WORKDIR}/parent/link.new" "${WORKDIR}/parent/link"

deadline=$((SECONDS + 15))
while ! grep --quiet --fixed-strings "nginx -s reload" "${MARKER}" 2>/dev/null && [ "${SECONDS}" -lt "${deadline}" ]; do
  sleep 1
done
if ! grep --quiet --fixed-strings "nginx -s reload" "${MARKER}" 2>/dev/null; then
  echo "FATAL: staged swap did not trigger a reload" >&2
  exit 1
fi
if ! grep --quiet --fixed-strings "policy 'self' 'sha256-BBB='" "${MARKER}" 2>/dev/null; then
  echo "FATAL: reload served stale tokens" >&2
  exit 1
fi

reloads="$(grep --count --fixed-strings "nginx -s reload" "${MARKER}" || true)"
sleep 3
if [ "$(grep --count --fixed-strings "nginx -s reload" "${MARKER}" || true)" != "${reloads}" ]; then
  echo "FATAL: settled state kept reloading" >&2
  exit 1
fi

kill -TERM "${WATCHER}" 2>/dev/null || true
wait "${WATCHER}" 2>/dev/null || true
trap - HUP

rm -f "${MARKER}"
export O9S_NGINX_PUBLIC_PATH="${WORKDIR}/flat"
export B19_RUNTIME_PATH="${WORKDIR}/run-flat"  # the staged watcher still holds its csp-watch claim

# shellcheck source=/dev/null
. /entrypoint.d/0920-csp-watch.sh
WATCHER=$!
trap 'kill -TERM "${WATCHER:-}" 2>/dev/null; trap - HUP; rm --recursive --force "${WORKDIR}"' EXIT

sleep 2
if [ -f "${MARKER}" ]; then
  echo "FATAL: flat watcher reloaded at arm time" >&2
  exit 1
fi

echo "'sha256-CCC='" > "${WORKDIR}/csp/script-src.txt"

deadline=$((SECONDS + 15))
while ! grep --quiet --fixed-strings "nginx -s reload" "${MARKER}" 2>/dev/null && [ "${SECONDS}" -lt "${deadline}" ]; do
  sleep 1
done
if ! grep --quiet --fixed-strings "nginx -s reload" "${MARKER}" 2>/dev/null; then
  echo "FATAL: flat token edit did not trigger a reload" >&2
  exit 1
fi
if ! grep --quiet --fixed-strings "policy 'self' 'sha256-CCC='" "${MARKER}" 2>/dev/null; then
  echo "FATAL: flat reload served stale tokens" >&2
  exit 1
fi
