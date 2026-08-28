#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
#
# SPDX-License-Identifier: MIT

# Validate the rendered nginx config before starting. If it fails, dump every
# rendered .nginx file so the error is visible in container logs without exec,
# then sleep to prevent restart loops.

  b19-log info "NGINX" "Testing rendered configuration"

  if nginx -t 2>&1 | tee /dev/stderr | grep -q "successful"
  then
    b19-log good "NGINX" "Configuration test passed"
    return 0
  fi

  b19-log error "NGINX" "Configuration test failed — dumping all rendered .nginx files"

  while IFS= read -r -d '' nginx_file
  do
    b19-log error "NGINX" "--- ${nginx_file} ---"
    cat "${nginx_file}" >&2
  done < <(find /app/.config -name '*.nginx' -print0 | sort -z)

  sleep infinity
