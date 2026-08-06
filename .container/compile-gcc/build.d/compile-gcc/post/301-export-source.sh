#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
#
# SPDX-License-Identifier: MIT

  mkdir -p /export/src /export/objs

  b19-run "NGINX" "$(_p "Export %s" "src/")" --   cp -a src/. /export/src/
  b19-run "NGINX" "$(_p "Export %s" "objs/")" --  cp -a objs/. /export/objs/
