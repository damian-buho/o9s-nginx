#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
#
# SPDX-License-Identifier: MIT

  live_reload_render() {
    local reason="${1:-unknown}"
    local nginx_test_output
    b19-log info "NGINX" "$(_p "Re-rendering after %s" "${reason}")"
    parallel-j2 "${B19_HOME}"  # same render step the startup hook runs
    nginx_test_output="$(nginx -t 2>&1)" || true
    printf '%s\n' "${nginx_test_output}" >&2
    if grep -q "successful" <<<"${nginx_test_output}"
    then
      if [ -f "${XDG_STATE_HOME}/nginx.pid" ] && kill -0 "$(cat "${XDG_STATE_HOME}/nginx.pid" 2>/dev/null)" 2>/dev/null
      then
        nginx -s reload  # zero-downtime: old workers drain, new config takes over
        b19-log good "NGINX" "$(_p "Reloaded after %s" "${reason}")"
      else
        b19-log warn "NGINX" "$(_p "Config tested, nginx not running yet after %s" "${reason}")"
      fi
    else
      b19-log error "NGINX" "$(_p "Config test failed after %s, keeping the old config" "${reason}")"
    fi
  }

  live_reload_on_hup() {
    live_reload_render "SIGHUP"  # replaces the 0000 forward so the render runs before the reload
  }

  live_reload_watch() {
    local dir="${O9S_NGINX_LIVE_RELOAD_DIR:-${XDG_CONFIG_HOME:-${B19_HOME:-/app}/.config}}"
    local debounce="${O9S_NGINX_LIVE_RELOAD_DEBOUNCE:-2}"
    local changed
    while [ ! -d "${dir}" ]; do  # config tree may mount after the entrypoint starts
      b19-log warn "NGINX" "$(_p "%s missing, waiting for mount" "${dir}")"
      sleep 5
    done
    trap 'exit 0' TERM INT  # tini -g forwards container stop here
    while true; do  # -m exits on overflow or error, so re-arm it and converge
      while IFS= read -r changed; do
        while IFS= read -r -t "${debounce}"; do :; done  # batch a save burst into one render
        live_reload_render "${changed}"
      done < <(inotifywait --monitor --recursive --event close_write,moved_to,create,delete --include '.*\.j2$' --format '%w%f' "${dir}" 2>/dev/null)
      b19-log warn "NGINX" "$(_p "%s watch ended, re-arming" "${dir}")"
      live_reload_render "watch restart"  # converge in case an edit landed while unwatched
      sleep 5
    done
  }

  if [ "${O9S_NGINX_LIVE_RELOAD_ENABLED:-N}" = "Y" ]
  then
    # shellcheck source=/dev/null
    . b19-i18n
    if [ "${B19_IMMUTABLE:-N}" = "Y" ]; then
      b19-log warn "NGINX" "$(_ "Live reload disabled: immutable image never re-renders")"
    else
      if [ "${O9S_NGINX_LIVE_RELOAD_ON_HUP:-Y}" = "Y" ]; then
        trap 'live_reload_on_hup' HUP  # render first, then reload; replaces the 0000 forward for HUP only
        b19-log info "NGINX" "$(_ "SIGHUP re-renders before reloading")"
      fi
      if command -v inotifywait >/dev/null 2>&1
      then
        live_reload_watch &
        b19-log info "NGINX" "$(_p "Watching %s for template changes" "${O9S_NGINX_LIVE_RELOAD_DIR:-${XDG_CONFIG_HOME:-${B19_HOME:-/app}/.config}}")"
      else
        b19-log error "NGINX" "$(_ "Live reload watch needs inotifywait, HUP re-render still active")"
      fi
    fi
  fi
