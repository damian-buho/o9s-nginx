#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
#
# SPDX-License-Identifier: MIT

    export NGINX_SOURCE_DIR="/app/nginx-src"
    export NGINX_BUILD_DIR="/app/nginx-src/objs"

    b19-run "ACME" "$(_ "Cargo build")" --      \
        cargo build --release --manifest-path nginx-acme/Cargo.toml

    mkdir -p "/export${O9S_NGINX_MODULES_PATH}"

    b19-run "ACME" "$(_p "Export %s" "ngx_http_acme_module.so")" --     \
        cp nginx-acme/target/release/libnginx_acme.so "/export${O9S_NGINX_MODULES_PATH}/ngx_http_acme_module.so"
