#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
#
# SPDX-License-Identifier: MIT

  if [ "${O9S_NGINX_PRECOMPRESS_ENABLED:-N}" = "Y" ] && [ "${O9S_NGINX_PRECOMPRESS_ENTRYPOINT_ENABLED:-N}" = "Y" ] && [ "${O9S_NGINX_PRECOMPRESS_WATCH_ENABLED:-N}" = "Y" ]
  then
    # shellcheck source=/dev/null
    . b19-i18n

    precompress_watch() {
      local dir="${O9S_NGINX_PRECOMPRESS_DIR:-${B19_HOME}}"
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

    precompress_watch &
    b19-log info "ASSETS" "$(_p "Watching %s for changes every %ss" "${O9S_NGINX_PRECOMPRESS_DIR:-${B19_HOME}}" "${O9S_NGINX_PRECOMPRESS_WATCH_INTERVAL:-30}")"
  fi
