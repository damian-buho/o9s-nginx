#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
#
# SPDX-License-Identifier: MIT

  if [ "${B19_IMMUTABLE:-}" != "Y" ]; then

    REALIP_DIR="${XDG_CONFIG_HOME}/includes/realip"

    case "${O9S_NGINX_REALIP_MODE:-docker}" in
      cloudflare)
        b19-log info "REALIP" "$(_ "Fetching Cloudflare IPs...")"
        DATA_FILE="${REALIP_DIR}/cloudflare.nginx.data.json"

        # Fetch IPv4 and IPv6 addresses
        IPV4=$(curl -s https://www.cloudflare.com/ips-v4)
        IPV6=$(curl -s https://www.cloudflare.com/ips-v6)

        # Write JSON data file for j2 template
        {
          echo -n '{"header":"CF-Connecting-IP","ips":['
          FIRST=true
          while read -r ip; do
            [ -z "$ip" ] && continue
            [ "$FIRST" = true ] && FIRST=false || echo -n ","
            echo -n "\"$ip\""
          done <<< "$IPV4"
          while read -r ip; do
            [ -z "$ip" ] && continue
            [ "$FIRST" = true ] && FIRST=false || echo -n ","
            echo -n "\"$ip\""
          done <<< "$IPV6"
          echo ']}'
        } > "${DATA_FILE}"
        ;;

      akamai)
        b19-log info "REALIP" "$(_ "Fetching Akamai IPs...")"
        DATA_FILE="${REALIP_DIR}/akamai.nginx.data.json"

        IPV4=$(curl -s https://techdocs.akamai.com/property-manager/pdfs/akamai_ipv4_CIDRs.txt)
        IPV6=$(curl -s https://techdocs.akamai.com/property-manager/pdfs/akamai_ipv6_CIDRs.txt)

        {
          echo -n '{"header":"True-Client-IP","ips":['
          FIRST=true
          while read -r ip; do
            [ -z "$ip" ] && continue
            [ "$FIRST" = true ] && FIRST=false || echo -n ","
            echo -n "\"$ip\""
          done <<< "$IPV4"
          while read -r ip; do
            [ -z "$ip" ] && continue
            [ "$FIRST" = true ] && FIRST=false || echo -n ","
            echo -n "\"$ip\""
          done <<< "$IPV6"
          echo ']}'
        } > "${DATA_FILE}"
        ;;

      aws)
        b19-log info "REALIP" "$(_ "Fetching AWS IPs...")"
        DATA_FILE="${REALIP_DIR}/aws.nginx.data.json"

        IPS=$(curl -s https://ip-ranges.amazonaws.com/ip-ranges.json | jq -r '.prefixes[] | select(.service == "CLOUDFRONT" or .service == "ELB") | .ip_prefix' 2>/dev/null)

        {
          echo -n '{"header":"X-Forwarded-For","ips":['
          FIRST=true
          while read -r ip; do
            [ -z "$ip" ] && continue
            [ "$FIRST" = true ] && FIRST=false || echo -n ","
            echo -n "\"$ip\""
          done <<< "$IPS"
          echo ']}'
        } > "${DATA_FILE}"
        ;;

      fastly)
        b19-log info "REALIP" "$(_ "Fetching Fastly IPs...")"
        DATA_FILE="${REALIP_DIR}/fastly.nginx.data.json"

        IPV4=$(curl -s https://api.fastly.com/public-ip-list | jq -r '.addresses[]' 2>/dev/null)
        IPV6=$(curl -s https://api.fastly.com/public-ip-list | jq -r '.ipv6_addresses[]' 2>/dev/null)

        {
          echo -n '{"header":"Fastly-Client-IP","ips":['
          FIRST=true
          while read -r ip; do
            [ -z "$ip" ] && continue
            [ "$FIRST" = true ] && FIRST=false || echo -n ","
            echo -n "\"$ip\""
          done <<< "$IPV4"
          while read -r ip; do
            [ -z "$ip" ] && continue
            [ "$FIRST" = true ] && FIRST=false || echo -n ","
            echo -n "\"$ip\""
          done <<< "$IPV6"
          echo ']}'
        } > "${DATA_FILE}"
        ;;

      internal|local|direct)
        b19-log info "REALIP" "$(_p "Non-CDN mode '%s' selected. Skipping IP fetching." "${O9S_NGINX_REALIP_MODE:-docker}")"
        ;;

    esac

    if [ -f "${DATA_FILE:-}" ]; then
      b19-log good "REALIP" "$(_p "CDN IPs for %s saved to %s" "${O9S_NGINX_REALIP_MODE:-docker}" "${DATA_FILE}")"
    fi

  else
    b19-log warn "REALIP" "$(_ "B19_IMMUTABLE=Y, skipping configuration generation")"
  fi
