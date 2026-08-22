#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
#
# SPDX-License-Identifier: MIT

  set -eou pipefail

# shellcheck source=/dev/null
  . b19-i18n

  CODES=(400 401 402 403 404 429 500 502 503 504)

  for LANG_DIR in "${B19_HOME}"/errors/*/; do
    for CODE in "${CODES[@]}"; do
      PAGE="${LANG_DIR}${CODE}.html"
      if [ -f "${PAGE}" ]; then
        b19-log good "ERRORS" "$(_p "Found: %s" "${PAGE}")"
      else
        b19-log bad "ERRORS" "$(_p "not found: %s" "${PAGE}")"
        exit 1
      fi
    done
  done
