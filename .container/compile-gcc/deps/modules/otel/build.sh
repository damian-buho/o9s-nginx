#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
#
# SPDX-License-Identifier: MIT

    OTEL_BUILD_DIR="${B19_TEMP_PATH}/nginx-otel-build"

    mkdir -p "${OTEL_BUILD_DIR}"

    b19-run "OTEL" "$(_ "CMake configure")" --      \
        cmake -B "${OTEL_BUILD_DIR}"                \
            -S nginx-otel                           \
            -DCMAKE_POLICY_VERSION_MINIMUM=3.5      \
            -DNGX_OTEL_NGINX_BUILD_DIR="$(pwd)/objs"

    b19-run "OTEL" "$(_ "CMake build")" --      \
        cmake --build "${OTEL_BUILD_DIR}" --target ngx_otel_module

    b19-run "OTEL" "$(_p "Export %s" "ngx_otel_module.so")" --      \
        cp "${OTEL_BUILD_DIR}/ngx_otel_module.so" "/export${O9S_NGINX_MODULES_PATH}"
