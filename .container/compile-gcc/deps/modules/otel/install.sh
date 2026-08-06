#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
#
# SPDX-License-Identifier: MIT

    OTEL_URL=$(decomment < "${MODULE_DIR}/url") || exit 1
    OTEL_COMMIT=$(decomment < "${MODULE_DIR}/commit") || exit 1

    b19-run "OTEL" "$(_p "Clone %s" "${OTEL_URL}")" --      \
        git clone --recurse-submodules "${OTEL_URL}" nginx-otel

    b19-run "OTEL" "$(_p "Checkout %s" "${OTEL_COMMIT}")" --      \
        git -C nginx-otel checkout "${OTEL_COMMIT}"

    b19-run "OTEL" "$(_ "Remove .git folder")" --     \
        rm -rf nginx-otel/.git
