#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
#
# SPDX-License-Identifier: MIT

# Compile the `_redirects` file into the redirect map data; idempotent, safe to call on every reload.
o9s_nginx_redirects_apply() {
  local reason="${1:-unknown}"
  local source="${O9S_NGINX_REDIRECTS_FILE:-}"
  local data_file="${B19_RUNTIME_PATH%/}${XDG_CONFIG_HOME}/includes/http/177-redirects.nginx.data.json"
  local line from to code extra key twin last joined
  local unsafe='[[:space:][:cntrl:]"\\$;]'
  local -a entries=() lines=()
  local -A seen=()
  [ -n "${source}" ] || source="${O9S_NGINX_PUBLIC_PATH:-${O9S_NGINX_ROOT:-${B19_HOME:-/app}}/public}/_redirects"
  mkdir --parents "$(dirname "${data_file}")"
  if [[ ",${O9S_NGINX_INCLUDE_OPTIONAL//[\"\' ]/}," != *",enable-redirects,"* ]]; then
    echo '{"redirects":[]}' > "${data_file}"
    b19-log debug "REDIRECTS" "$(_p "enable-redirects not in O9S_NGINX_INCLUDE_OPTIONAL, map left empty (%s)" "${reason}")"
    return 0
  fi
  if [ ! -f "${source}" ]; then
    echo '{"redirects":[]}' > "${data_file}"
    b19-log info "REDIRECTS" "$(_p "No redirects file at %s, map left empty (%s)" "${source}" "${reason}")"
    return 0
  fi
  mapfile -t lines < "${source}"
  for line in ${lines[@]+"${lines[@]}"}; do
    read -r from to code extra <<<"${line}" || true
    [ -n "${from}" ] && [[ "${from}" != \#* ]] || continue
    code="${code%!}"
    code="${code:-301}"
    if [ -z "${to}" ] || [ -n "${extra}" ] || [[ "${from}" != /* ]] || [[ "${from}" =~ [*:] ]] || [[ ! "${to}" =~ ^(/|https?://) ]] || [[ "${from}${to}" =~ ${unsafe} ]]; then
      b19-log warn "REDIRECTS" "$(_p "Skipping unsupported line in %s: %s (%s)" "${source}" "${line}" "${reason}")"
      continue
    fi
    if [[ ! "${code}" =~ ^30[1278]$ ]]; then
      b19-log warn "REDIRECTS" "$(_p "Skipping %s: status %s is not 301, 302, 307 or 308 (%s)" "${from}" "${code}" "${reason}")"
      continue
    fi
    last="${from##*/}"
    twin=""
    if [ "${from}" != "/" ] && [[ "${last}" != *.* ]]; then
      if [[ "${from}" == */ ]]; then twin="${from%/}"; else twin="${from}/"; fi
    fi
    for key in "${from}" ${twin:+"${twin}"}; do
      if [ -n "${seen[${key}]:-}" ]; then
        b19-log warn "REDIRECTS" "$(_p "Skipping duplicate %s → %s, already sent to %s (%s)" "${key}" "${to}" "${seen[${key}]}" "${reason}")"
        continue
      fi
      seen[${key}]="${to}"
      entries+=("$(printf '{"from":"%s","to":"%s","code":%s}' "${key}" "${to}" "${code}")")
    done
done
  joined="$(IFS=,; echo "${entries[*]}")"
  echo "{\"redirects\":[${joined}]}" > "${data_file}.tmp"
  mv --force "${data_file}.tmp" "${data_file}"
  b19-log good "REDIRECTS" "$(_p "Serving %s redirect(s) from %s (%s)" "${#entries[@]}" "${source}" "${reason}")"
}

export -f o9s_nginx_redirects_apply
o9s_nginx_redirects_apply "startup"
