#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
#
# SPDX-License-Identifier: MIT

    ACME_URL=$(decomment < "${MODULE_DIR}/url") || exit 1
    ACME_COMMIT=$(decomment < "${MODULE_DIR}/commit") || exit 1

    b19-run "ACME" "$(_p "Clone %s" "${ACME_URL}")" --      \
        git clone "${ACME_URL}" nginx-acme

    b19-run "ACME" "$(_p "Checkout %s" "${ACME_COMMIT}")" --      \
        git -C nginx-acme checkout "${ACME_COMMIT}"

    b19-run "ACME" "$(_ "Remove .git folder")" --     \
        rm -rf nginx-acme/.git
