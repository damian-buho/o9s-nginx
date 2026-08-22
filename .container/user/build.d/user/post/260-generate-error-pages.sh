#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
#
# SPDX-License-Identifier: MIT

# Render the localized error pages from the shared template. Subshell so the
# per-language LANGUAGE exports never leak into the sourced build stage.

  (
    set -euo pipefail

    ERRORS_DIR="${B19_HOME}/errors"
    TEMPLATE="/templates/error-page.html.j2"
    LANGS_DATA="${XDG_CONFIG_HOME}/includes/http/175-error-pages.nginx.data.json"

    CODES=(400 401 402 403 404 429 500 502 503 504)

    # English plus every language this image carries a .po catalog for.
    LANGS=(en)
    while IFS= read -r PO_FILE; do
        LANGS+=("$(basename --suffix=.po "${PO_FILE}")")
    done < <(fd --hidden --extension po . "/usr/share/locale/b19/${M6E_PROJECT}" | sort --unique)

    # What we are trying to do with this: one msgid per string so the normal
    # .pot/.po workflow owns every translation.
    title_for() {
        case "$1" in
            400) printf '%s' "$(_ "Bad Request")" ;;
            401) printf '%s' "$(_ "Unauthorized")" ;;
            402) printf '%s' "$(_ "Payment Required")" ;;
            403) printf '%s' "$(_ "Forbidden")" ;;
            404) printf '%s' "$(_ "Not Found")" ;;
            429) printf '%s' "$(_ "Too Many Requests")" ;;
            500) printf '%s' "$(_ "Internal Server Error")" ;;
            502) printf '%s' "$(_ "Bad Gateway")" ;;
            503) printf '%s' "$(_ "Service Unavailable")" ;;
            504) printf '%s' "$(_ "Gateway Timeout")" ;;
        esac
    }

    desc_for() {
        case "$1" in
            400) printf '%s' "$(_ "The server could not understand the request.")" ;;
            401) printf '%s' "$(_ "Authentication is required to access this resource.")" ;;
            402) printf '%s' "$(_ "Payment is required to access this resource.")" ;;
            403) printf '%s' "$(_ "You do not have permission to access this resource.")" ;;
            404) printf '%s' "$(_ "The requested resource could not be found.")" ;;
            429) printf '%s' "$(_ "Too many requests were sent in a short time. Please wait a moment and try again.")" ;;
            500) printf '%s' "$(_ "Something went wrong on the server side. Please try again later.")" ;;
            502) printf '%s' "$(_ "The server received an invalid response from an upstream service.")" ;;
            503) printf '%s' "$(_ "The service is temporarily unavailable. Please try again later.")" ;;
            504) printf '%s' "$(_ "The server did not receive a timely response from an upstream service.")" ;;
        esac
    }

    for ERR_LANG in "${LANGS[@]}"; do
        export LANGUAGE="${ERR_LANG}"
        # glibc ignores LANGUAGE while a C-family locale is active, so point
        # LC_MESSAGES at any generated locale of the same language.
        ERR_LOC="$(locale -a 2>/dev/null | grep -ix "${ERR_LANG}[-_].*utf.*8" | head --lines=1 || true)"
        if [ -n "${ERR_LOC}" ]; then
            export LC_MESSAGES="${ERR_LOC}"
        else
            unset LC_MESSAGES
            b19-log warn "ERRORS" "$(_p "No generated locale for %s — rendering in English" "${ERR_LANG}")"
        fi
        CTA="$(_ "Go to the home page")"
        rm -rf -- "${ERRORS_DIR:?}/${ERR_LANG}"
        mkdir -p "${ERRORS_DIR}/${ERR_LANG}"
        for CODE in "${CODES[@]}"; do
            minijinja-cli --autoescape none \
                -D "lang=${ERR_LANG}" \
                -D "code=${CODE}" \
                -D "title=$(title_for "${CODE}")" \
                -D "desc=$(desc_for "${CODE}")" \
                -D "cta=${CTA}" \
                "${TEMPLATE}" -o "${ERRORS_DIR}/${ERR_LANG}/${CODE}.html"
        done
        b19-log good "ERRORS" "$(_p "Rendered %s error pages for %s" "${#CODES[@]}" "${ERR_LANG}")"
    done

    # Language list consumed by the 175-error-pages.nginx.j2 Accept-Language map.
    LANGS_JSON="$(printf '"%s",' "${LANGS[@]}")"
    printf '{"langs": [%s]}\n' "${LANGS_JSON%,}" > "${LANGS_DATA}"
    b19-log info "ERRORS" "$(_p "Negotiable languages: %s" "${LANGS_JSON%,}")"
  )
