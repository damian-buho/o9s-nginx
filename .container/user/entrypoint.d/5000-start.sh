#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
#
# SPDX-License-Identifier: MIT

  if [ "${ENTRYPOINT_COMMAND_EXECUTED:-N}" == "N" ];
  then
    b19-log info "NGINX" "$(_ "Starting server")"
    b19-exec --stdout-level warn --stderr-level warn -- nginx
  fi
