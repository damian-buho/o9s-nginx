# SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
#
# SPDX-License-Identifier: MIT

export O9S_NGINX_UPSTREAM_VERSION=$(shell .makefile/container/scripts/decomment.sh .container/compile-gcc/deps/nginx/version.deps)
M6E_DOCKER_BUILDX_OPTIONS += --build-arg O9S_NGINX_UPSTREAM_VERSION