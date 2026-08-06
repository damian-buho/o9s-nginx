#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
#
# SPDX-License-Identifier: MIT

  DATA_FILE="${XDG_CONFIG_HOME}/includes/server/preload_hints.nginx.data.json"
  HTTP_MAP_DATA_FILE="${XDG_CONFIG_HOME}/includes/http/135-preload-hints-map.nginx.data.json"

  if [ "${O9S_NGINX_PH_SCAN_ENABLED:-N}" == "Y" ]
  then
    b19-log good "HINTS" "$(_p "Scanning for preload-hints assets in %s" "${O9S_NGINX_PH_SCAN_PATH}")"

    if [[ -d "${O9S_NGINX_PH_SCAN_PATH}" ]]; then
      ASSETS=()

      # Scan for CSS
      if [ "${O9S_NGINX_PH_SCAN_ENABLED_STYLE:-N}" = "Y" ]
      then
        while read -r file; do
          relative_path="${file#"${O9S_NGINX_PH_SCAN_PATH}"/}"
          ASSETS+=("{\"path\":\"${relative_path}\",\"type\":\"style\"}")
        done < <(find "${O9S_NGINX_PH_SCAN_PATH}" -maxdepth 1 -type f -name "*.css")
      fi

      # Scan for JS
      if [ "${O9S_NGINX_PH_SCAN_ENABLED_SCRIPT:-N}" = "Y" ]
      then
        while read -r file; do
          relative_path="${file#"${O9S_NGINX_PH_SCAN_PATH}"/}"
          ASSETS+=("{\"path\":\"${relative_path}\",\"type\":\"script\"}")
        done < <(find "${O9S_NGINX_PH_SCAN_PATH}" -maxdepth 1 -type f -name "*.js")
      fi

      # Scan for images
      if [ "${O9S_NGINX_PH_SCAN_ENABLED_IMAGE:-N}" = "Y" ]
      then
        while read -r file; do
          relative_path="${file#"${O9S_NGINX_PH_SCAN_PATH}"/}"
          ASSETS+=("{\"path\":\"${relative_path}\",\"type\":\"image\"}")
        done < <(find "${O9S_NGINX_PH_SCAN_PATH}" -maxdepth 1 -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" -o -name "*.gif" \))
      fi

      # Scan for fonts
      if [ "${O9S_NGINX_PH_SCAN_ENABLED_FONT:-N}" = "Y" ]
      then
        while read -r file; do
          relative_path="${file#"${O9S_NGINX_PH_SCAN_PATH}"/}"
          ASSETS+=("{\"path\":\"${relative_path}\",\"type\":\"font\"}")
        done < <(find "${O9S_NGINX_PH_SCAN_PATH}" -maxdepth 1 -type f \( -name "*.woff" -o -name "*.woff2" -o -name "*.ttf" \))
      fi

      # Write JSON data file
      echo -n '{"assets":[' > "${DATA_FILE}"
      FIRST=true
      for asset in "${ASSETS[@]}"; do
        [ "$FIRST" = true ] && FIRST=false || echo -n "," >> "${DATA_FILE}"
        echo -n "$asset" >> "${DATA_FILE}"
      done
      echo ']}' >> "${DATA_FILE}"
      cp "${DATA_FILE}" "${HTTP_MAP_DATA_FILE}"

      b19-log good "HINTS" "$(_p "Found %s assets, saved to %s" "${#ASSETS[@]}" "${DATA_FILE}")"
    else
      b19-log error "HINTS" "$(_p "%s does not exist." "${O9S_NGINX_PH_SCAN_PATH}")"
    fi
  fi
