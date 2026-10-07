#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
#
# SPDX-License-Identifier: MIT

# Lock the document scope: CSP and COEP values come from maps keyed on the content type, so a PDF maps to empty and gets neither header.

set -eou pipefail

WORKDIR="$(mktemp --directory)"
trap 'rm --recursive --force "${WORKDIR}"' EXIT

INCLUDES="${XDG_CONFIG_HOME}/includes"

export O9S_NGINX_DOCUMENT_TYPES="text/html|image/svg[+]xml"
export O9S_NGINX_COEP_POLICY="credentialless"
export O9S_NGINX_COEP_REPORT_TO=""

for TEMPLATE in "http/176-document-headers.nginx.j2" "opt/enable-csp.nginx.j2" "opt/enable-coep.nginx.j2"
do
  cp "${INCLUDES}/${TEMPLATE}" "${WORKDIR}/"
  minijinja-cli --autoescape none --env "${WORKDIR}/$(basename "${TEMPLATE}")" -o "${WORKDIR}/$(basename "${TEMPLATE}" .j2)"
done

# shellcheck disable=SC2016 # nginx variables, not shell expansions
for EXPECTED in '"~^(text/html|image/svg[+]xml)" 1;' 'map $o9s_nginx_document $o9s_nginx_csp {' 'map $o9s_nginx_document $o9s_nginx_coep {' 'default "";'
do
  if ! grep --quiet --fixed-strings "${EXPECTED}" "${WORKDIR}/176-document-headers.nginx"
  then
    echo "FATAL: 176-document-headers.nginx is missing ${EXPECTED}" >&2
    exit 1
  fi
done

# shellcheck disable=SC2016 # nginx variable, not a shell expansion
if ! grep --quiet --fixed-strings 'add_header Content-Security-Policy $o9s_nginx_csp always;' "${WORKDIR}/enable-csp.nginx"
then
  echo "FATAL: enable-csp.nginx does not emit the mapped CSP value" >&2
  exit 1
fi

# shellcheck disable=SC2016 # nginx variable, not a shell expansion
if ! grep --quiet --fixed-strings 'add_header Cross-Origin-Embedder-Policy $o9s_nginx_coep always;' "${WORKDIR}/enable-coep.nginx"
then
  echo "FATAL: enable-coep.nginx does not emit the mapped COEP value" >&2
  exit 1
fi

echo "CSP and COEP are scoped to document types"
