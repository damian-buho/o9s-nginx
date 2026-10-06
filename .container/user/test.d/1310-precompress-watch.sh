#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
#
# SPDX-License-Identifier: MIT

# Lock the inotify precompress watch: swapping the served symlink recompresses,
# sibling renames and same-target rewrites do not, and arming never recompresses.

set -eou pipefail

if ! command -v inotifywait >/dev/null 2>&1; then
  echo "SKIP: inotifywait not installed" >&2
  exit 0
fi

WORKDIR="$(mktemp --directory)"
trap 'rm --recursive --force "${WORKDIR}"' EXIT

mkdir -p "${WORKDIR}/bin" "${WORKDIR}/parent/real1" "${WORKDIR}/parent/real2"
ln -s "real1" "${WORKDIR}/parent/link"
echo "one" > "${WORKDIR}/parent/real1/page.html"
echo "two" > "${WORKDIR}/parent/real2/page.html"

cat > "${WORKDIR}/bin/compress-static-assets" <<'EOF'
#!/usr/bin/env bash
echo "$1" >> "${WATCH_CALLS}"
EOF
chmod +x "${WORKDIR}/bin/compress-static-assets"

export PATH="${WORKDIR}/bin:${PATH}"
export WATCH_CALLS="${WORKDIR}/calls.txt"
export B19_HOME="${WORKDIR}"
export O9S_NGINX_PRECOMPRESS_ENABLED=Y
export O9S_NGINX_PRECOMPRESS_ENTRYPOINT_ENABLED=Y
export O9S_NGINX_PRECOMPRESS_WATCH_ENABLED=Y
export O9S_NGINX_PRECOMPRESS_DIR="${WORKDIR}/parent/link"

setsid bash -c '. /entrypoint.d/1310-precompress-watch.sh' &
WATCHER=$!
trap 'kill -TERM -- -"${WATCHER}" 2>/dev/null; rm --recursive --force "${WORKDIR}"' EXIT

sleep 2  # let the watcher arm its inotifywait

if [ -f "${WATCH_CALLS}" ]; then
  echo "FATAL: watcher recompressed at arm time instead of baselining" >&2
  exit 1
fi

ln -s "real2" "${WORKDIR}/parent/link.new"
mv -T "${WORKDIR}/parent/link.new" "${WORKDIR}/parent/link"  # atomic rename swap

deadline=$((SECONDS + 10))
while [ ! -f "${WATCH_CALLS}" ] && [ "${SECONDS}" -lt "${deadline}" ]; do
  sleep 1
done

if [ ! -f "${WATCH_CALLS}" ]; then
  echo "FATAL: symlink swap did not trigger a recompress" >&2
  exit 1
fi

if [ "$(cat "${WATCH_CALLS}")" != "${O9S_NGINX_PRECOMPRESS_DIR}" ]; then
  echo "FATAL: recompress ran on the wrong directory" >&2
  exit 1
fi

touch "${WORKDIR}/parent/sibling"
mv "${WORKDIR}/parent/sibling" "${WORKDIR}/parent/sibling2"  # sibling rename, not our symlink
ln -sfn "real2" "${WORKDIR}/parent/link"  # same-target rewrite, nothing new to serve
sleep 3

if [ "$(wc -l < "${WATCH_CALLS}")" != "1" ]; then
  echo "FATAL: sibling rename or same-target rewrite triggered a recompress" >&2
  exit 1
fi

ln -s "real1" "${WORKDIR}/parent/link.new"
mv -T "${WORKDIR}/parent/link.new" "${WORKDIR}/parent/link"  # swap back

deadline=$((SECONDS + 10))
while [ "$(wc -l < "${WATCH_CALLS}")" -lt "2" ] && [ "${SECONDS}" -lt "${deadline}" ]; do
  sleep 1
done

if [ "$(wc -l < "${WATCH_CALLS}")" != "2" ]; then
  echo "FATAL: second symlink swap did not trigger a recompress" >&2
  exit 1
fi
