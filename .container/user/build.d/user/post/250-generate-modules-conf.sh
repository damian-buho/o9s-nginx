#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
#
# SPDX-License-Identifier: MIT

  MODULES_CONF="${XDG_CONFIG_HOME}/modules.conf"

  b19-log info "NGINX" "$(_p "Generate %s" "modules.conf")"

  : > "${MODULES_CONF}"
  for SO_FILE in "${O9S_NGINX_MODULES_PATH}"/*.so; do
      echo "load_module ${SO_FILE};" >> "${MODULES_CONF}"
  done
