#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
#
# SPDX-License-Identifier: MIT

  set -eou pipefail

# shellcheck source=/dev/null
  . b19-i18n

  MODULES=(
    ngx_http_brotli_filter_module.so
    ngx_http_brotli_static_module.so
    ngx_http_zstd_filter_module.so
    ngx_http_zstd_static_module.so
    ngx_otel_module.so
    ngx_http_acme_module.so
  )

  for MODULE in "${MODULES[@]}"
  do
    if [ -f "${O9S_NGINX_MODULES_PATH:-}/${MODULE}" ]
    then
      b19-log good "NGINX" "$(_p "Found: %s" "${MODULE}")"
    else
      b19-log bad "NGINX" "$(_p "not found: %s" "${MODULE}")"
      exit 1
    fi
  done
