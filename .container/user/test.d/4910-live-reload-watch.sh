#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
#
# SPDX-License-Identifier: MIT

# Lock live reload: a .j2 edit re-renders, tests and reloads; a non-template
# edit is ignored; a failed test keeps the old config; HUP re-renders first.

set -eou pipefail

# shellcheck source=/dev/null
. b19-i18n

WORKDIR="$(mktemp --directory)"
trap 'rm --recursive --force "${WORKDIR}"' EXIT

mkdir -p "${WORKDIR}/bin" "${WORKDIR}/state" "${WORKDIR}/config/includes"
export PATH="${WORKDIR}/bin:${PATH}"
export MARKER="${WORKDIR}/calls.txt"
export B19_HOME="${WORKDIR}"
export XDG_STATE_HOME="${WORKDIR}/state"

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
exit 0
EOF
chmod +x "${WORKDIR}/bin/parallel-j2" "${WORKDIR}/bin/nginx"

mkdir -p "${WORKDIR}/hupbin"  # HUP assertions need the gate to run, not a real watch
cat > "${WORKDIR}/hupbin/inotifywait" <<'EOF'
#!/usr/bin/env bash
sleep infinity  # idle placeholder: the subshell exits at once, the container reaps it
EOF
chmod +x "${WORKDIR}/hupbin/inotifywait"

# Functions are defined at source time, so load them without enabling the watcher.
# shellcheck source=/dev/null
. /entrypoint.d/4910-live-reload-watch.sh

echo "$$" > "${XDG_STATE_HOME}/nginx.pid"  # nginx running: this shell is alive

live_reload_render "test running"
if ! grep --quiet --fixed-strings "render ${WORKDIR}" "${MARKER}"; then
  echo "FATAL: running nginx was not re-rendered" >&2
  exit 1
fi
if ! grep --quiet --fixed-strings "nginx -s reload" "${MARKER}"; then
  echo "FATAL: running nginx was not reloaded" >&2
  exit 1
fi

rm -f "${MARKER}" "${XDG_STATE_HOME}/nginx.pid"  # nginx stopped: nothing to signal

live_reload_render "test stopped"
if ! grep --quiet --fixed-strings "render ${WORKDIR}" "${MARKER}"; then
  echo "FATAL: stopped nginx was not re-rendered" >&2
  exit 1
fi
if grep --quiet --fixed-strings "nginx -s reload" "${MARKER}"; then
  echo "FATAL: stopped nginx was signalled" >&2
  exit 1
fi

rm -f "${MARKER}"
export NGINX_TEST_OK=N  # broken template: test fails, old config keeps serving

live_reload_render "test broken" 2>/dev/null
if grep --quiet --fixed-strings "nginx -s reload" "${MARKER}" 2>/dev/null; then
  echo "FATAL: broken config was reloaded" >&2
  exit 1
fi
unset NGINX_TEST_OK

# env, not a subshell, keeps each gate run isolated without tripping SC2030.
env O9S_NGINX_LIVE_RELOAD_ENABLED=Y O9S_NGINX_LIVE_RELOAD_ON_HUP=Y \
  O9S_NGINX_LIVE_RELOAD_DIR="${WORKDIR}/state" PATH="${WORKDIR}/hupbin:${PATH}" \
  bash -c '. /entrypoint.d/4910-live-reload-watch.sh; trap -p HUP' >"${WORKDIR}/hup-on.txt" 2>/dev/null  # file, not pipe: orphans must not hold it
if ! grep --quiet "live_reload_on_hup" "${WORKDIR}/hup-on.txt"; then
  echo "FATAL: SIGHUP does not re-render before reloading" >&2
  exit 1
fi

env O9S_NGINX_LIVE_RELOAD_ENABLED=Y O9S_NGINX_LIVE_RELOAD_ON_HUP=N \
  O9S_NGINX_LIVE_RELOAD_DIR="${WORKDIR}/state" PATH="${WORKDIR}/hupbin:${PATH}" \
  bash -c '. /entrypoint.d/4910-live-reload-watch.sh; trap -p HUP' >"${WORKDIR}/hup-off.txt" 2>/dev/null
if grep --quiet "live_reload_on_hup" "${WORKDIR}/hup-off.txt"; then
  echo "FATAL: SIGHUP trap installed despite ON_HUP=N" >&2
  exit 1
fi

if ! command -v inotifywait >/dev/null 2>&1; then
  echo "SKIP: inotifywait not installed, watcher loop untested" >&2
  exit 0
fi

echo "x" > "${WORKDIR}/config/site.nginx.j2"
echo "y" > "${WORKDIR}/config/site.nginx"
rm -f "${MARKER}"
echo "$$" > "${XDG_STATE_HOME}/nginx.pid"

export O9S_NGINX_LIVE_RELOAD_ENABLED=Y
export O9S_NGINX_LIVE_RELOAD_DIR="${WORKDIR}/config"
export O9S_NGINX_LIVE_RELOAD_DEBOUNCE=1

setsid bash -c '. /entrypoint.d/4910-live-reload-watch.sh; sleep 30' &
WATCHER=$!
trap 'kill -TERM -- -"${WATCHER}" 2>/dev/null; rm --recursive --force "${WORKDIR}"' EXIT

sleep 2  # let the watcher arm its inotifywait
echo "changed" >> "${WORKDIR}/config/site.nginx.j2"  # template edit: must re-render

deadline=$((SECONDS + 10))
while ! grep --quiet "render" "${MARKER}" 2>/dev/null && [ "${SECONDS}" -lt "${deadline}" ]; do
  sleep 1
done
if ! grep --quiet "render" "${MARKER}" 2>/dev/null; then
  echo "FATAL: template edit did not trigger a re-render" >&2
  exit 1
fi
if ! grep --quiet --fixed-strings "nginx -s reload" "${MARKER}"; then
  echo "FATAL: template edit did not trigger a reload" >&2
  exit 1
fi

renders="$(grep --count "render" "${MARKER}")"
echo "changed" >> "${WORKDIR}/config/site.nginx"  # rendered output edit: must be ignored
sleep 3
if [ "$(grep --count "render" "${MARKER}")" != "${renders}" ]; then
  echo "FATAL: non-template edit triggered a re-render" >&2
  exit 1
fi
