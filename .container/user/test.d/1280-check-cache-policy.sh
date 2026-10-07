#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
#
# SPDX-License-Identifier: MIT

# Lock the cache-policy split: content-addressed assets keep the long immutable window, while a type a publish regenerates under a stable URL revalidates instead of pinning the previous file for a year.

set -eou pipefail

WORKDIR="$(mktemp --directory)"
trap 'rm --recursive --force "${WORKDIR}"' EXIT

cp "${XDG_CONFIG_HOME}/includes/http/170-cache.nginx.j2" "${WORKDIR}/"

export O9S_NGINX_CACHE_POLICY="public, max-age=31536000, immutable"
export O9S_NGINX_REVALIDATE_CACHE_POLICY="public, max-age=300, must-revalidate"

minijinja-cli --autoescape none --env "${WORKDIR}/170-cache.nginx.j2" -o "${WORKDIR}/170-cache.nginx"

policy_of() {
  local TYPE="$1"
  local KEY="\"~^${TYPE}\""
  local LINE POLICY=""

  while read -r LINE
  do
    if [[ "${LINE}" == *"${KEY}"* ]]
    then
      POLICY="${LINE#*"${KEY}"}"
      POLICY="${POLICY%%;*}"
      POLICY="${POLICY#"${POLICY%%[![:space:]]*}"}"
      POLICY="${POLICY%"${POLICY##*[![:space:]]}"}"
      POLICY="${POLICY#\"}"
      POLICY="${POLICY%\"}"
    fi
  done < "${WORKDIR}/170-cache.nginx"

  if [ -z "${POLICY}" ]
  then
    echo "FATAL: 170-cache.nginx has no entry for ${TYPE}" >&2
    exit 1
  fi

  printf '%s' "${POLICY}"
}

# Content-addressed assets: the URL changes with the bytes, so a long immutable window is safe
for TYPE in "application/javascript" "text/css" "font/woff2" "image/png" 'image/svg\+xml' "audio/mpeg" "video/mp4" "application/wasm" "model/gltf-binary" 'model/gltf\+json'
do
  if [ "$(policy_of "${TYPE}")" != "${O9S_NGINX_CACHE_POLICY}" ]
  then
    echo "FATAL: ${TYPE} must keep the immutable policy" >&2
    exit 1
  fi
done

# Fixed-URL documents and data: a publish overwrites the file behind the same URL
for TYPE in "application/pdf" "application/vnd.openxmlformats-officedocument.wordprocessingml.document" 'application/epub\+zip' "application/x-subrip" "text/calendar" "text/csv" "text/markdown" "text/plain" "text/vtt" "text/xsl" 'application/geo\+json' "application/json" 'application/ld\+json' 'application/manifest\+json' "application/toml" "application/yaml" 'application/atom\+xml' 'application/dash\+xml' 'application/rss\+xml' "application/xml" "application/gzip" "application/vnd.rar" "application/x-7z-compressed" "application/x-bzip2" "application/x-tar" "application/zip" "application/zstd"
do
  if [ "$(policy_of "${TYPE}")" != "${O9S_NGINX_REVALIDATE_CACHE_POLICY}" ]
  then
    echo "FATAL: ${TYPE} must revalidate instead of pinning the previous file" >&2
    exit 1
  fi
done

# A type the map never listed stays uncached, so HTML cannot fall into either window
if ! grep --quiet --extended-regexp '^[[:space:]]*default[[:space:]]+"no-cache";' "${WORKDIR}/170-cache.nginx"
then
  echo "FATAL: 170-cache.nginx no longer defaults to no-cache" >&2
  exit 1
fi

echo "Content-addressed assets keep the immutable policy and regenerated documents revalidate"