#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
#
# SPDX-License-Identifier: MIT

# Lock the read-only root contract: nginx writes only below the runtime and temp paths.
set -eou pipefail

BUILD_FLAGS="$(nginx -V 2>&1)"

# World-writable and sticky; the base may add setgid
b19-assert equals "PATHS" "${B19_RUNTIME_PATH}" "$(find "${B19_RUNTIME_PATH}" -maxdepth 0 -perm -1777)"
b19-assert matches "PATHS" "--error-log-path=stderr" "${BUILD_FLAGS}"
b19-assert matches "PATHS" "--pid-path=${B19_RUNTIME_PATH}/nginx.pid" "${BUILD_FLAGS}"
b19-assert matches "PATHS" "--http-client-body-temp-path=${O9S_NGINX_TEMP_PATH}/client" "${BUILD_FLAGS}"
b19-assert equals "PATHS" "${B19_RUNTIME_PATH}/nginx.pid" "$(sed --quiet 's/^pid  *\(.*\);$/\1/p' "${XDG_CONFIG_HOME}/nginx.conf")"
