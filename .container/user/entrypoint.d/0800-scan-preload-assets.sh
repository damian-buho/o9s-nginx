#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
#
# SPDX-License-Identifier: MIT

# Rescan the preload-hint source tree; idempotent, safe to call on every reload.
o9s_nginx_ph_scan() {
  local reason="${1:-unknown}"
  local data_file="${XDG_CONFIG_HOME}/includes/server/preload_hints.nginx.data.json"
  local http_map_data_file="${XDG_CONFIG_HOME}/includes/http/135-preload-hints-map.nginx.data.json"
  local file relative_path first=true
  local -a assets=()
  if [ "${O9S_NGINX_PH_SCAN_ENABLED:-N}" != "Y" ]; then
    return 0
  fi
  b19-log good "HINTS" "$(_p "Scanning for preload-hints assets in %s (%s)" "${O9S_NGINX_PH_SCAN_PATH}" "${reason}")"
  if [[ -d "${O9S_NGINX_PH_SCAN_PATH}" ]]; then
    if [ "${O9S_NGINX_PH_SCAN_ENABLED_STYLE:-N}" = "Y" ]; then
      while read -r file; do
        relative_path="${file#"${O9S_NGINX_PH_SCAN_PATH}"/}"
        assets+=("{\"path\":\"${relative_path}\",\"type\":\"style\"}")
      done < <(find "${O9S_NGINX_PH_SCAN_PATH}" -maxdepth 1 -type f -name "*.css" || true)
    fi
    if [ "${O9S_NGINX_PH_SCAN_ENABLED_SCRIPT:-N}" = "Y" ]; then
      while read -r file; do
        relative_path="${file#"${O9S_NGINX_PH_SCAN_PATH}"/}"
        assets+=("{\"path\":\"${relative_path}\",\"type\":\"script\"}")
      done < <(find "${O9S_NGINX_PH_SCAN_PATH}" -maxdepth 1 -type f -name "*.js" || true)
    fi
    if [ "${O9S_NGINX_PH_SCAN_ENABLED_IMAGE:-N}" = "Y" ]; then
      while read -r file; do
        relative_path="${file#"${O9S_NGINX_PH_SCAN_PATH}"/}"
        assets+=("{\"path\":\"${relative_path}\",\"type\":\"image\"}")
      done < <(find "${O9S_NGINX_PH_SCAN_PATH}" -maxdepth 1 -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" -o -name "*.gif" \) || true)
    fi
    if [ "${O9S_NGINX_PH_SCAN_ENABLED_FONT:-N}" = "Y" ]; then
      while read -r file; do
        relative_path="${file#"${O9S_NGINX_PH_SCAN_PATH}"/}"
        assets+=("{\"path\":\"${relative_path}\",\"type\":\"font\"}")
      done < <(find "${O9S_NGINX_PH_SCAN_PATH}" -maxdepth 1 -type f \( -name "*.woff" -o -name "*.woff2" -o -name "*.ttf" \) || true)
    fi
    echo -n '{"assets":[' > "${data_file}"
    for file in ${assets[@]+"${assets[@]}"}; do
      [ "${first}" = "true" ] && first=false || echo -n "," >> "${data_file}"
      echo -n "${file}" >> "${data_file}"
    done
    echo ']}' >> "${data_file}"
    cp "${data_file}" "${http_map_data_file}"
    b19-log good "HINTS" "$(_p "Found %s assets, saved to %s (%s)" "${#assets[@]}" "${data_file}" "${reason}")"
  else
    b19-log error "HINTS" "$(_p "%s does not exist (%s)" "${O9S_NGINX_PH_SCAN_PATH}" "${reason}")"
  fi
}

o9s_nginx_ph_scan "startup"
