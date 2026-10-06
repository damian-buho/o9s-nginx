#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
#
# SPDX-License-Identifier: MIT

# Lock the reporting headers rendering: each header lands only when its var is set, and an empty default emits nothing.

set -eou pipefail

WORKDIR="$(mktemp --directory)"
trap 'rm --recursive --force "${WORKDIR}"' EXIT

cp "${XDG_CONFIG_HOME}/includes/opt/enable-reporting-endpoints.nginx.j2" "${WORKDIR}/"

export O9S_NGINX_REPORTING_ENDPOINTS='default="https://relay.example/"'
export O9S_NGINX_REPORT_TO='{"group":"default","max_age":60,"endpoints":[{"url":"https://relay.example/"}]}'
export O9S_NGINX_NEL='{"report_to":"default","max_age":60}'

minijinja-cli --autoescape none --env "${WORKDIR}/enable-reporting-endpoints.nginx.j2" -o "${WORKDIR}/reporting.nginx"

for EXPECTED in 'add_header Reporting-Endpoints default="https://relay.example/" always;' 'add_header Report-To {"group":"default","max_age":60,"endpoints":[{"url":"https://relay.example/"}]} always;' 'add_header NEL {"report_to":"default","max_age":60} always;'
do
  if ! grep --quiet --fixed-strings "${EXPECTED}" "${WORKDIR}/reporting.nginx"
  then
    echo "FATAL: reporting.nginx is missing ${EXPECTED}" >&2
    exit 1
  fi
done

export O9S_NGINX_REPORTING_ENDPOINTS=""
export O9S_NGINX_REPORT_TO=""
export O9S_NGINX_NEL=""

minijinja-cli --autoescape none --env "${WORKDIR}/enable-reporting-endpoints.nginx.j2" -o "${WORKDIR}/empty.nginx"

for ABSENT in 'Reporting-Endpoints' 'Report-To' 'NEL'
do
  if grep --quiet --fixed-strings "${ABSENT}" "${WORKDIR}/empty.nginx"
  then
    echo "FATAL: empty.nginx still contains ${ABSENT}" >&2
    exit 1
  fi
done

echo "Reporting headers render when set and vanish when unset"
