#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
#
# SPDX-License-Identifier: MIT

set -eou pipefail

# Appends the live edge ranges of the named extra providers to O9S_NGINX_REALIP_EXTRA_CIDRS, so a second proxy hop (a CDN in front of Traefik) joins the mode's own trust set instead of replacing it.
EXTRA_PROVIDERS="${O9S_NGINX_REALIP_EXTRA_PROVIDERS:-}"

if [ -z "${EXTRA_PROVIDERS}" ]
then
  return 0
fi

if [ "${B19_IMMUTABLE:-N}" = "Y" ]
then
  b19-log warn "REALIP" "$(_p "B19_IMMUTABLE=Y, skipping extra edge range fetch")"
  return 0
fi

IFS=',' read -ra PROVIDER_NAMES <<<"${EXTRA_PROVIDERS}"

fetch_provider() {
  case "$1" in
    cloudflare)
      curl -fsS --max-time 15 --retry 2 https://www.cloudflare.com/ips-v4 2>/dev/null
      printf '\n'
      curl -fsS --max-time 15 --retry 2 https://www.cloudflare.com/ips-v6 2>/dev/null
      ;;
    akamai)
      curl -fsS --max-time 15 --retry 2 https://techdocs.akamai.com/property-manager/pdfs/akamai_ipv4_CIDRs.txt 2>/dev/null
      printf '\n'
      curl -fsS --max-time 15 --retry 2 https://techdocs.akamai.com/property-manager/pdfs/akamai_ipv6_CIDRs.txt 2>/dev/null
      ;;
    fastly)
      curl -fsS --max-time 15 --retry 2 https://api.fastly.com/public-ip-list 2>/dev/null | jq -r '.addresses[], .ipv6_addresses[]'
      ;;
    aws)
      curl -fsS --max-time 15 --retry 2 https://ip-ranges.amazonaws.com/ip-ranges.json 2>/dev/null | jq -r '.prefixes[] | select(.service == "CLOUDFRONT" or .service == "ELB") | .ip_prefix'
      ;;
  esac
}

# Names are validated in the main shell because an exit inside the fetch substitution below would only end the subshell, silently downgrading a typo to a skipped provider.
for PROVIDER in "${PROVIDER_NAMES[@]}"
do
  PROVIDER="$(printf '%s' "${PROVIDER}" | tr -d '[:space:]')"

  case "${PROVIDER}" in
    cloudflare|akamai|fastly|aws)
      ;;
    *)
      b19-log error "REALIP" "$(_p "Refusing to start: unknown provider %s, want cloudflare, akamai, fastly or aws" "${PROVIDER}")"
      exit 1
      ;;
  esac
done

EXTRA_LIST=""

for PROVIDER in "${PROVIDER_NAMES[@]}"
do
  PROVIDER="$(printf '%s' "${PROVIDER}" | tr -d '[:space:]')"
  PROVIDER_RANGES="$(fetch_provider "${PROVIDER}" || true)"
  PROVIDER_LIST="$(printf '%s\n' "${PROVIDER_RANGES}" | grep -E '^[0-9a-fA-F.:/]+$' | paste -sd ',' - || true)"

  if [ -z "${PROVIDER_LIST}" ]
  then
    b19-log warn "REALIP" "$(_p "Extra edge range fetch failed for %s, keeping the remaining sources only" "${PROVIDER}")"
    continue
  fi

  if [ -n "${EXTRA_LIST}" ]
  then
    EXTRA_LIST="${EXTRA_LIST},${PROVIDER_LIST}"
  else
    EXTRA_LIST="${PROVIDER_LIST}"
  fi
done

if [ -n "${EXTRA_LIST}" ]
then
  if [ -n "${O9S_NGINX_REALIP_EXTRA_CIDRS:-}" ]
  then
    export O9S_NGINX_REALIP_EXTRA_CIDRS="${O9S_NGINX_REALIP_EXTRA_CIDRS},${EXTRA_LIST}"
  else
    export O9S_NGINX_REALIP_EXTRA_CIDRS="${EXTRA_LIST}"
  fi
  b19-log info "REALIP" "$(_p "Extra trusted real-IP peers: %s" "${O9S_NGINX_REALIP_EXTRA_CIDRS}")"
fi

unset EXTRA_PROVIDERS PROVIDER_NAMES PROVIDER PROVIDER_RANGES PROVIDER_LIST EXTRA_LIST
