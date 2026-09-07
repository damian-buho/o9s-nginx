#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
#
# SPDX-License-Identifier: MIT

  if [ "${O9S_NGINX_PRECOMPRESS_ENABLED:-N}" = "Y" ] && [ "${O9S_NGINX_PRECOMPRESS_ENTRYPOINT_ENABLED:-N}" = "Y" ]
  then
    compress-static-assets "${O9S_NGINX_PRECOMPRESS_DIR:-${B19_HOME}}"
  fi
