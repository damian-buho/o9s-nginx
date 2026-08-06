#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
#
# SPDX-License-Identifier: MIT

  mkdir -p /export

  for MODULE_DIR in /deps/modules/*/; do
      MODULE=$(basename "${MODULE_DIR}")
      b19-log info "MODULE" "$(_p "Install %s" "${MODULE}")"
      # shellcheck source=/dev/null
      . "${MODULE_DIR}/install.sh"
      # shellcheck source=/dev/null
      . "${MODULE_DIR}/build.sh"
  done
