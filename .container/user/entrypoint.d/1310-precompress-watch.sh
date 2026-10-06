#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
#
# SPDX-License-Identifier: MIT

  if [ "${O9S_NGINX_PRECOMPRESS_ENABLED:-N}" = "Y" ] && [ "${O9S_NGINX_PRECOMPRESS_ENTRYPOINT_ENABLED:-N}" = "Y" ] && [ "${O9S_NGINX_PRECOMPRESS_WATCH_ENABLED:-N}" = "Y" ]
  then
    # shellcheck source=/dev/null
    . b19-i18n

    precompress_watch_poll() {
      local dir="${O9S_NGINX_PRECOMPRESS_DIR:-${B19_HOME:-/app}}"
      local interval="${O9S_NGINX_PRECOMPRESS_WATCH_INTERVAL:-30}"
      local last current
      last="$(readlink -f "${dir}" 2>/dev/null || true)"
      trap 'exit 0' TERM INT  # tini -g forwards container stop here
      while sleep "${interval}"; do
        current="$(readlink -f "${dir}" 2>/dev/null || true)"
        [ "${current}" = "${last}" ] && continue  # unchanged since the last poll
        b19-log info "ASSETS" "$(_p "%s changed; recompressing" "${dir}")"
        compress-static-assets "${dir}"
        last="${current}"
      done
    }

    precompress_watch_inotify() {
      local dir="${O9S_NGINX_PRECOMPRESS_DIR:-${B19_HOME:-/app}}"
      local parent name last current event
      parent="$(dirname "${dir}")"
      name="$(basename "${dir}")"
      while [ ! -d "${parent}" ]; do  # volume may mount after the entrypoint starts
        b19-log warn "ASSETS" "$(_p "%s missing, waiting for mount" "${parent}")"
        sleep 5
      done
      last="$(readlink -f "${dir}" 2>/dev/null || true)"  # 1300 already compressed this target at boot
      trap 'exit 0' TERM INT  # tini -g forwards container stop here
      while true; do  # -m exits on overflow or error, so re-arm it and converge
        while IFS= read -r event; do
          [ "${event}" = "${name}" ] || continue  # sibling rename, not our symlink
          current="$(readlink -f "${dir}" 2>/dev/null || true)"
          [ -n "${current}" ] || continue  # target deleted, wait for its replacement
          [ "${current}" = "${last}" ] && continue  # rename unrelated to the served target
          b19-log info "ASSETS" "$(_p "%s changed; recompressing" "${dir}")"
          compress-static-assets "${dir}"
          last="${current}"
        done < <(inotifywait --monitor --event moved_to,create --format '%f' "${parent}" 2>/dev/null)
        b19-log warn "ASSETS" "$(_p "%s watch ended, re-arming" "${parent}")"
        current="$(readlink -f "${dir}" 2>/dev/null || true)"  # catch a swap missed while unwatched
        if [ -n "${current}" ] && [ "${current}" != "${last}" ]; then
          b19-log info "ASSETS" "$(_p "%s changed; recompressing" "${dir}")"
          compress-static-assets "${dir}"
          last="${current}"
        fi
        sleep 1
      done
    }

    if command -v inotifywait >/dev/null 2>&1
    then
      precompress_watch_inotify &
      b19-log info "ASSETS" "$(_p "Watching %s for moves of %s" "${O9S_NGINX_PRECOMPRESS_DIR:-${B19_HOME:-/app}}" "$(basename "${O9S_NGINX_PRECOMPRESS_DIR:-${B19_HOME:-/app}}")")"
    else
      precompress_watch_poll &
      b19-log info "ASSETS" "$(_p "Watching %s for changes every %ss (no inotifywait)" "${O9S_NGINX_PRECOMPRESS_DIR:-${B19_HOME:-/app}}" "${O9S_NGINX_PRECOMPRESS_WATCH_INTERVAL:-30}")"
    fi
  fi
