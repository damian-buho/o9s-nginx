#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
#
# SPDX-License-Identifier: MIT

  # Phase 1: cmake modules (before make modules, needs objs/ from configure)
  mkdir -p "/export${O9S_NGINX_MODULES_PATH}"
  for MODULE_DIR in /deps/modules/*/; do
      [ -f "${MODULE_DIR}/build.sh" ] || continue
      MODULE=$(basename "${MODULE_DIR}")
      b19-log info "MODULE" "$(_p "Build %s" "${MODULE}")"
      # shellcheck source=/dev/null
      . "${MODULE_DIR}/build.sh"
  done

  # Phase 2: --add-dynamic-module modules
  b19-run "NGINX" "$(_ "Build")" --     make modules
  b19-run "NGINX" "$(_ "Install")" --   make install DESTDIR=/export

  # Phase 3: copy --add-dynamic-module .so to /export${O9S_NGINX_MODULES_PATH}/
  for MODULE_DIR in /deps/modules/*/; do
      [ -f "${MODULE_DIR}/so-files.txt" ] || continue
      while IFS= read -r SO_FILE; do
          [ -z "${SO_FILE}" ] && continue
          b19-run "NGINX" "$(_p "Export %s" "${SO_FILE}")" --     \
              cp "objs/${SO_FILE}" "/export${O9S_NGINX_MODULES_PATH}/"
      done < "${MODULE_DIR}/so-files.txt"
  done
