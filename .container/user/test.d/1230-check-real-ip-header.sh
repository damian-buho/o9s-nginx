#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
#
# SPDX-License-Identifier: MIT

# Lock X-Real-IP onto the resolved client: the raw incoming chain parses as no single IP anywhere downstream.

set -eou pipefail

TEMPLATE="${XDG_CONFIG_HOME}/includes/http/140-proxy.nginx.j2"
WANT='X-Real-IP'
RAW_CHAIN='http_x_forwarded_for'
RESOLVED="\$remote_addr;"

if grep --fixed-strings "${WANT}" "${TEMPLATE}" | grep --quiet --fixed-strings "${RAW_CHAIN}"; then
  echo "FATAL: X-Real-IP still reads the raw chain" >&2
  exit 1
fi

if ! grep --fixed-strings "${WANT}" "${TEMPLATE}" | grep --quiet --fixed-strings "${RESOLVED}"; then
  echo "FATAL: X-Real-IP must come from \$remote_addr" >&2
  exit 1
fi

echo "X-Real-IP carries the resolved client address"
