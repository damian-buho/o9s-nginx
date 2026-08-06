#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
#
# SPDX-License-Identifier: MIT


  cd "${B19_TEMP_PATH}" || exit

  eval "$(b19-resolve-dep nginx)"

  b19-fetch "NGINX" "${M6E_UPSTREAM__URL}" "${M6E_UPSTREAM__FILE}" "${M6E_UPSTREAM__HASH}"

  b19-run "NGINX" "$(_p "Extract %s" "${B19_TEMP_PATH}/${M6E_UPSTREAM__FILE}")" --      \
    tar --extract                                                                       \
        --file "${B19_TEMP_PATH}/${M6E_UPSTREAM__FILE}"                                 \
        --strip-components 1                                                            \
        --use-compress-program pigz
