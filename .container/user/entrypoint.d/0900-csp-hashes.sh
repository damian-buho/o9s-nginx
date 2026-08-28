#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
#
# SPDX-License-Identifier: MIT

# Append CSP directive values from /app/.csp/<directive>.txt files to the
# corresponding O9S_NGINX_CSP_<DIRECTIVE> env vars. Each file contains
# space-separated tokens (hashes, sources) to append. Directories with a
# leading dot or underscore are skipped.

CSP_DIR="${O9S_NGINX_CSP_DIR:-/app/.csp}"

if [ ! -d "$CSP_DIR" ]; then
  return 0
fi

for file in "$CSP_DIR"/*.txt; do
  [ -f "$file" ] || continue

  directive="$(basename "$file" .txt)"
  var_name="O9S_NGINX_CSP_$(echo "$directive" | tr '[:lower:]-' '[:upper:]_')"

  tokens="$(cat "$file")"
  if [ -n "$tokens" ]; then
    eval "export ${var_name}=\"\${${var_name}:-} ${tokens}\""
  fi
done
