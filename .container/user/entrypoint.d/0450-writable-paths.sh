#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
#
# SPDX-License-Identifier: MIT

  # nginx creates only the last path segment, and a tmpfs starts empty
  mkdir --parents "${O9S_NGINX_CACHE_PATH}" "${O9S_NGINX_TEMP_PATH}"
  b19-log debug "NGINX" "$(_p "Prepared %s and %s" "${O9S_NGINX_CACHE_PATH}" "${O9S_NGINX_TEMP_PATH}")"
