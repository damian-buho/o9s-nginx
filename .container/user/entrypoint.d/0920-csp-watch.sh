#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
#
# SPDX-License-Identifier: MIT

# Refresh the rendered policy when the token files or the served tree change.
o9s_nginx_csp_reload() {
  local reason="${1:-unknown}"
  local nginx_test_output
  if declare -F o9s_nginx_csp_apply >/dev/null 2>&1; then
    o9s_nginx_csp_apply "${reason}"
  fi
  if declare -F o9s_nginx_ph_scan >/dev/null 2>&1; then
    o9s_nginx_ph_scan "${reason}"
  fi
  b19-log info "NGINX" "$(_p "Re-rendering after %s" "${reason}")"
  parallel-j2 "${B19_HOME}"
  nginx_test_output="$(nginx -t 2>&1)" || true
  if grep --quiet "successful" <<<"${nginx_test_output}"; then
    if [ -f "${XDG_STATE_HOME}/nginx.pid" ] && kill -0 "$(cat "${XDG_STATE_HOME}/nginx.pid" 2>/dev/null)" 2>/dev/null; then
      nginx -s reload
      b19-log good "NGINX" "$(_p "Reloaded after %s" "${reason}")"
    else
      b19-log warn "NGINX" "$(_p "Config tested, nginx not running yet after %s" "${reason}")"
    fi
  else
    b19-log error "NGINX" <<<"${nginx_test_output}"
    b19-log error "NGINX" "$(_p "Config test failed after %s, keeping the old config" "${reason}")"
  fi
}

# Snapshot what the served policy derives from: the symlink target plus the token bytes.
o9s_nginx_csp_snapshot() {
  O9S_CSPW_PUBLIC_PATH="${O9S_NGINX_PUBLIC_PATH:-${O9S_NGINX_ROOT:-${B19_HOME:-/app}}/public}"
  O9S_CSPW_CSP_DIR="${O9S_NGINX_CSP_DIR:-${B19_HOME:-/app}/.csp}"
  O9S_CSPW_NOW_TARGET="$(readlink -f "${O9S_CSPW_PUBLIC_PATH}" 2>/dev/null || true)"
  if [ -d "${O9S_CSPW_CSP_DIR}" ]; then
    O9S_CSPW_NOW_DIGEST="$(cat -- "${O9S_CSPW_CSP_DIR}"/*.txt 2>/dev/null | sha256sum | cut --delimiter=' ' --fields=1 || true)"
  else
    O9S_CSPW_NOW_DIGEST="missing"
  fi
}

# A staged tree (PUBLIC_PATH is a symlink) swaps atomically, so only the swap
# itself reloads; the token files land before it and must not reload early.
o9s_nginx_csp_due() {
  local staged="N"
  if [ -L "${O9S_CSPW_PUBLIC_PATH}" ]; then
    staged="Y"
  fi
  if [ "${O9S_CSPW_NOW_TARGET}" != "${O9S_CSPW_LAST_TARGET}" ]; then
    return 0
  fi
  if [ "${staged}" = "N" ] && [ "${O9S_CSPW_NOW_DIGEST}" != "${O9S_CSPW_LAST_DIGEST}" ]; then
    return 0
  fi
  return 1
}

o9s_nginx_csp_remember() {
  O9S_CSPW_LAST_TARGET="${O9S_CSPW_NOW_TARGET}"
  O9S_CSPW_LAST_DIGEST="${O9S_CSPW_NOW_DIGEST}"
}

o9s_nginx_csp_converge() {
  local reason="${1:-unknown}"
  o9s_nginx_csp_snapshot
  if o9s_nginx_csp_due; then
    b19-log info "CSP" "$(_p "%s changed; refreshing the policy (%s)" "${O9S_CSPW_PUBLIC_PATH}" "${reason}")"
    o9s_nginx_csp_reload "${reason}"
    o9s_nginx_csp_snapshot
  fi
  o9s_nginx_csp_remember
}

o9s_nginx_csp_poll() {
  local interval="${O9S_NGINX_CSP_WATCH_INTERVAL:-30}"
  o9s_nginx_csp_snapshot
  o9s_nginx_csp_remember
  trap 'exit 0' TERM INT
  while sleep "${interval}"; do
    o9s_nginx_csp_converge "poll"
  done
}

o9s_nginx_csp_inotify() {
  local debounce="${O9S_NGINX_CSP_WATCH_DEBOUNCE:-2}"
  local parent resync="N"
  local -a watch_dirs
  o9s_nginx_csp_snapshot
  o9s_nginx_csp_remember
  trap 'exit 0' TERM INT
  while true; do
    watch_dirs=()
    if [ -d "${O9S_CSPW_CSP_DIR}" ]; then
      watch_dirs+=("${O9S_CSPW_CSP_DIR}")
    fi
    parent="$(dirname "${O9S_CSPW_PUBLIC_PATH}")"
    if [ -d "${parent}" ]; then
      watch_dirs+=("${parent}")
    fi
    if [ "${#watch_dirs[@]}" -eq 0 ]; then
      b19-log warn "CSP" "$(_p "%s missing, waiting for mount" "${O9S_CSPW_PUBLIC_PATH}")"
      resync="Y"
      sleep 5
      continue
    fi
    if [ "${resync}" = "Y" ]; then
      resync="N"
      o9s_nginx_csp_converge "watch start"
    fi
    while IFS= read -r; do
      while IFS= read -r -t "${debounce}"; do :; done
      o9s_nginx_csp_converge "content change"
    done < <(inotifywait --monitor --event close_write,moved_to,create,delete --format '%w%f' "${watch_dirs[@]}" 2>/dev/null)
    b19-log warn "CSP" "$(_p "Policy watch ended, re-arming (%s)" "${O9S_CSPW_PUBLIC_PATH}")"
    o9s_nginx_csp_converge "watch restart"
    sleep 1
  done
}

o9s_nginx_csp_on_hup() {
  o9s_nginx_csp_reload "SIGHUP"
}

if [ "${O9S_NGINX_CSP_WATCH_ENABLED:-Y}" = "Y" ]; then
  # shellcheck source=/dev/null
  . b19-i18n
  if [ "${B19_IMMUTABLE:-N}" = "Y" ]; then
    b19-log warn "CSP" "$(_ "CSP watch disabled: immutable image never re-renders")"
  else
    trap 'o9s_nginx_csp_on_hup' HUP
    b19-log info "CSP" "$(_ "SIGHUP refreshes the policy before reloading")"
    export -f _p o9s_nginx_csp_reload o9s_nginx_csp_snapshot o9s_nginx_csp_due o9s_nginx_csp_remember o9s_nginx_csp_converge o9s_nginx_csp_poll o9s_nginx_csp_inotify o9s_nginx_csp_on_hup
    if command -v inotifywait >/dev/null 2>&1; then
      b19-exec --background --optional --name csp-watch -- bash -c 'o9s_nginx_csp_inotify'
      b19-log info "CSP" "$(_p "Watching %s for policy changes" "${O9S_NGINX_PUBLIC_PATH:-${O9S_NGINX_ROOT:-${B19_HOME:-/app}}/public}")"
    else
      b19-exec --background --optional --name csp-watch -- bash -c 'o9s_nginx_csp_poll'
      b19-log info "CSP" "$(_p "Polling %s for policy changes every %ss (no inotifywait)" "${O9S_NGINX_PUBLIC_PATH:-${O9S_NGINX_ROOT:-${B19_HOME:-/app}}/public}" "${O9S_NGINX_CSP_WATCH_INTERVAL:-30}")"
    fi
  fi
fi
