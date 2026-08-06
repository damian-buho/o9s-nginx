#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
#
# SPDX-License-Identifier: MIT

    ZSTD_URL=$(decomment < "${MODULE_DIR}/url") || exit 1
    ZSTD_COMMIT=$(decomment < "${MODULE_DIR}/commit") || exit 1

    b19-run "ZSTD" "$(_p "Clone %s" "${ZSTD_URL}")" --      \
        git clone "${ZSTD_URL}"

    b19-run "ZSTD" "$(_p "Checkout %s" "${ZSTD_COMMIT}")" --      \
        git -C zstd-nginx-module checkout "${ZSTD_COMMIT}"

    b19-run "ZSTD" "$(_ "Remove .git folder")" --     \
        rm -rf zstd-nginx-module/.git
