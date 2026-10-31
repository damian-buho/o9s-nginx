#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
#
# SPDX-License-Identifier: MIT

# Idempotent CSP token merge, safe to call on every reload, not just at startup.
o9s_nginx_csp_apply() {
  local reason="${1:-unknown}"
  local csp_dir="${O9S_NGINX_CSP_DIR:-${B19_HOME:-/app}/.csp}"
  local csp_name csp_base csp_file csp_directive csp_variable
  local -a csp_names csp_tokens
  mapfile -t csp_names < <(compgen -v 'O9S_NGINX_CSP_' || true) || true
  for csp_name in "${csp_names[@]}"; do
    case "${csp_name}" in
      O9S_NGINX_CSP_BASE_*|O9S_NGINX_CSP_WATCH_*|O9S_NGINX_CSP_DIR) continue ;;
    esac
    csp_base="O9S_NGINX_CSP_BASE_${csp_name#O9S_NGINX_CSP_}"
    if [[ ! -v ${csp_base} ]]; then
      declare -g "${csp_base}=${!csp_name}"
      export "${csp_base?}"
    fi
    printf -v "${csp_name}" '%s' "${!csp_base}"
  done
  if [ ! -d "${csp_dir}" ]; then
    b19-log info "CSP" "$(_p "No token directory at %s, serving the configured directives unchanged (%s)" "${csp_dir}" "${reason}")"
    return 0
  fi
  for csp_file in "${csp_dir}"/*.txt; do
    [ -f "${csp_file}" ] || continue
    csp_directive="$(basename "${csp_file}" .txt)"
    csp_variable="O9S_NGINX_CSP_$(echo "${csp_directive}" | tr '[:lower:]-' '[:upper:]_')"
    if [[ ! -v ${csp_variable} ]]; then
      b19-log warn "CSP" "$(_p "Ignoring %s: %s is not a directive this image renders (%s)" "${csp_file}" "${csp_variable}" "${reason}")"
      continue
    fi
    read -ra csp_tokens <<< "$(tr '\n' ' ' < "${csp_file}")"
    if [ "${#csp_tokens[@]}" -eq 0 ]; then
      b19-log warn "CSP" "$(_p "Skipping %s: it carries no tokens (%s)" "${csp_file}" "${reason}")"
      continue
    fi
    declare -n csp_value="${csp_variable}"
    csp_value="${csp_value:+${csp_value} }${csp_tokens[*]}"
    unset -n csp_value
    export "${csp_variable?}"
    b19-log good "CSP" "$(_p "Serving %s token(s) from %s in %s (%s)" "${#csp_tokens[@]}" "${csp_file}" "${csp_variable}" "${reason}")"
  done
}

export -f o9s_nginx_csp_apply
o9s_nginx_csp_apply "startup"
