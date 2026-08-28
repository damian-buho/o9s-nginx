#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
#
# SPDX-License-Identifier: MIT

# Append CSP tokens supplied by the downstream image to the directive they
# belong to. Each ${O9S_NGINX_CSP_DIR}/<directive>.txt holds whitespace-separated
# sources or hashes destined for O9S_NGINX_CSP_<DIRECTIVE>, so a site ships the
# hashes of its own inline scripts without baking them into this image or
# widening the policy with 'unsafe-inline'.

  CSP_DIR="${O9S_NGINX_CSP_DIR:-/app/.csp}"

  if [ ! -d "${CSP_DIR}" ]
  then
    b19-log info "CSP" "$(_p "No token directory at %s, serving the configured directives unchanged" "${CSP_DIR}")"
    return 0
  fi

  for csp_file in "${CSP_DIR}"/*.txt
  do
    [ -f "${csp_file}" ] || continue

    csp_directive="$(basename "${csp_file}" .txt)"
    csp_variable="O9S_NGINX_CSP_$(echo "${csp_directive}" | tr '[:lower:]-' '[:upper:]_')"

    if [[ ! -v ${csp_variable} ]]
    then
      b19-log warn "CSP" "$(_p "Ignoring %s: %s is not a directive this image renders" "${csp_file}" "${csp_variable}")"
      continue
    fi

    # Flatten first: read splits on IFS runs but stops at the first newline.
    read -ra csp_tokens <<< "$(tr '\n' ' ' < "${csp_file}")"

    if [ "${#csp_tokens[@]}" -eq 0 ]
    then
      b19-log warn "CSP" "$(_p "Skipping %s: it carries no tokens" "${csp_file}")"
      continue
    fi

    declare -n csp_value="${csp_variable}"
    csp_value="${csp_value:+${csp_value} }${csp_tokens[*]}"
    unset -n csp_value
    export "${csp_variable?}"

    b19-log good "CSP" "$(_p "Appended %s token(s) from %s to %s" "${#csp_tokens[@]}" "${csp_file}" "${csp_variable}")"
  done
