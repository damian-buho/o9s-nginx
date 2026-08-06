#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
#
# SPDX-License-Identifier: MIT


  if [ ! -f "${B19_CA_DHPARAMS_PATH}" ]; then
    b19-log good "DHPARAMS" "$(_p "not found: %s" "${B19_CA_DHPARAMS_PATH}")"
    b19-run "DHPARAMS" "$(_p "Generate with %s size" "${B19_CA_DHPARAMS_SIZE}")" --     \
      openssl dhparam -out "${B19_CA_DHPARAMS_PATH}" "${B19_CA_DHPARAMS_SIZE}"
  else
    b19-log good "DHPARAMS" "$(_p "Found: %s" "${B19_CA_DHPARAMS_PATH}")"
  fi
