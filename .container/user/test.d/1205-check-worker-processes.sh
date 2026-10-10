#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
#
# SPDX-License-Identifier: MIT

# Lock worker_processes: auto follows the cgroup-aware NUMPROCS, an explicit value wins.

set -eou pipefail

WORKDIR="$(mktemp --directory)"
trap 'rm --recursive --force "${WORKDIR}"' EXIT

cp "${XDG_CONFIG_HOME}/nginx.conf.j2" "${WORKDIR}/"

for CASE in 'auto 3 3' '5 3 5' 'auto - auto'
do
  read -r WORKERS PROCS EXPECTED <<<"${CASE}"
  if [[ "${PROCS}" == "-" ]]
  then
    unset NUMPROCS
  else
    export NUMPROCS="${PROCS}"
  fi
  O9S_NGINX_WORKER_PROCESSES="${WORKERS}" minijinja-cli --autoescape none --env "${WORKDIR}/nginx.conf.j2" -o "${WORKDIR}/nginx.conf"
  if ! grep --quiet --extended-regexp "^worker_processes +${EXPECTED};$" "${WORKDIR}/nginx.conf"
  then
    echo "FATAL: O9S_NGINX_WORKER_PROCESSES=${WORKERS} NUMPROCS=${PROCS} did not render worker_processes ${EXPECTED}" >&2
    exit 1
  fi
  echo "O9S_NGINX_WORKER_PROCESSES=${WORKERS} NUMPROCS=${PROCS} renders worker_processes ${EXPECTED}"
done
