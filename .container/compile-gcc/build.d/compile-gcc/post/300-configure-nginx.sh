#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
#
# SPDX-License-Identifier: MIT

  DYNAMIC_MODULES=""
  for MODULE_DIR in /deps/modules/*/; do
      [ -f "${MODULE_DIR}/dir" ] || continue
      DYNAMIC_MODULES="${DYNAMIC_MODULES} --add-dynamic-module=./$(decomment < "${MODULE_DIR}/dir")"
  done

  # shellcheck disable=SC2086
  b19-run "NGINX" "$(_ "Configure")" --                                                                                                                                                                           \
    ./configure                                                                                                                                                                                                   \
      ${DYNAMIC_MODULES}                                                                                                                                                                                          \
      --conf-path="${XDG_CONFIG_HOME}/nginx.conf"                                                                                                                                                                 \
      --error-log-path="${O9S_NGINX_LOG_PATH}/error.log"                                                                                                                                                          \
      --group=nginx                                                                                                                                                                                               \
      --http-client-body-temp-path="${O9S_NGINX_TEMP_PATH}/client"                                                                                                                                                \
      --http-fastcgi-temp-path="${O9S_NGINX_TEMP_PATH}/fastcgi"                                                                                                                                                   \
      --http-log-path="${O9S_NGINX_LOG_PATH}/access.log"                                                                                                                                                          \
      --http-proxy-temp-path="${O9S_NGINX_TEMP_PATH}/proxy"                                                                                                                                                       \
      --http-scgi-temp-path="${O9S_NGINX_TEMP_PATH}/scgi"                                                                                                                                                         \
      --http-uwsgi-temp-path="${O9S_NGINX_TEMP_PATH}/uwsgi"                                                                                                                                                       \
      --lock-path="${XDG_STATE_HOME}/nginx.lock"                                                                                                                                                                  \
      --modules-path="${O9S_NGINX_MODULES_PATH}"                                                                                                                                                                  \
      --pid-path="${XDG_STATE_HOME}/nginx.pid"                                                                                                                                                                    \
      --prefix="${XDG_CONFIG_HOME}"                                                                                                                                                                               \
      --sbin-path="/usr/local/bin/nginx"                                                                                                                                                                          \
      --user="${B19_USER}"                                                                                                                                                                                        \
      --with-cc-opt="${CFLAGS} -ffile-prefix-map=/data/builder/debuild/nginx-${O9S_NGINX_UPSTREAM_VERSION}/debian/debuild-base/nginx-${O9S_NGINX_UPSTREAM_VERSION}=. -fstack-protector-strong -Wformat -fPIC"     \
      --with-compat                                                                                                                                                                                               \
      --with-file-aio                                                                                                                                                                                             \
      --with-http_auth_request_module                                                                                                                                                                             \
      --with-http_gunzip_module                                                                                                                                                                                   \
      --with-http_gzip_static_module                                                                                                                                                                              \
      --with-http_realip_module                                                                                                                                                                                   \
      --with-http_slice_module                                                                                                                                                                                    \
      --with-http_ssl_module                                                                                                                                                                                      \
      --with-http_stub_status_module                                                                                                                                                                              \
      --with-http_sub_module                                                                                                                                                                                      \
      --with-http_v2_module                                                                                                                                                                                       \
      --with-http_v3_module                                                                                                                                                                                       \
      --with-pcre                                                                                                                                                                                                 \
      --with-pcre-jit                                                                                                                                                                                             \
      --with-threads
