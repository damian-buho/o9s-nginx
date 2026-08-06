#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
#
# SPDX-License-Identifier: MIT

    BROTLI_URL=$(decomment < "${MODULE_DIR}/url") || exit 1
    BROTLI_COMMIT=$(decomment < "${MODULE_DIR}/commit") || exit 1

    b19-run "BROTLI" "$(_p "Clone %s" "${BROTLI_URL}")" --      \
        git clone --recurse-submodules "${BROTLI_URL}"

    b19-run "BROTLI" "$(_p "Checkout %s" "${BROTLI_COMMIT}")" --      \
        git -C ngx_brotli checkout "${BROTLI_COMMIT}"

    b19-run "BROTLI" "$(_ "Remove .git folder")" --     \
        rm -rf ngx_brotli/.git
