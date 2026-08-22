<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

# Error pages

Custom error pages for ten status codes (400, 401, 402, 403, 404, 429, 500, 502,
503, 504), rendered per language at image build from a single template, and
served to each visitor in their own language with zero JavaScript.

## Layout

| Path (source tree)                                                   | Role                                                          |
| -------------------------------------------------------------------- | ------------------------------------------------------------- |
| `.container/user/templates/error-page.html.j2`                       | the one template every page renders from                      |
| `.container/user/app/public/errors/error.css`                        | shared style sheet, served publicly at `/errors/error.css`    |
| `.container/user/build.d/user/post/260-generate-error-pages.sh`      | build hook: renders `${B19_HOME}/errors/<lang>/<code>.html`   |
| `.container/user/app/.config/includes/http/175-error-pages.nginx.j2` | `Accept-Language → $error_lang` map                           |
| `.container/user/app/.config/includes/server/error_page.nginx.j2`    | `error_page` redirects + internal resolver location           |
| `.container/base/locale/{nginx.pot,es.po,uk.po}`                     | every page string, in the normal gettext workflow             |

The rendered pages live only inside the image — nothing under
`app/errors/` is committed. `test.d/1400-error-pages.sh` fails the image test
when any language directory is missing a page.

## Language negotiation

1. `error_page 404 /__error/404;` (and the other nine) redirects every error to
   the internal location `~ ^/__error/(?<error_code>\d{3})$`.
2. The `175-error-pages` map resolves `$error_lang` from the request’s
   `Accept-Language` header — **first-position match only** (`~*^es([;-]|$)`),
   so a browser that lists English before Spanish gets English, not Spanish.
3. `try_files /errors/$error_lang/$error_code.html /errors/en/$error_code.html`
   serves the negotiated language and falls back to English; a completely
   missing page degrades to nginx’s built-in error page.
4. The location is `internal`, so pages cannot be fetched directly — only
   through a real error. `/__error/*` is a reserved path; keep downstream
   proxy_pass locations from colliding with it.

The map’s language list is not configured anywhere: the build hook discovers
every `.po` catalog in the image’s gettext slot, renders a page set for each,
and writes the list to `175-error-pages.nginx.data.json`, which the map
template reads at config-render time (same companion-data pattern as the CDN
real-IP includes). **Adding a language is one `.po` file** — run
`make i18n-init M6E_I18N_LOCALE=fr`, translate, rebuild; pages and map extend
themselves. A catalog whose locale is not in `B19_LOCALES` logs a warning and
renders English (glibc needs a generated locale for `LANGUAGE` to resolve).

## Design

- Dark by default: `color-scheme: dark light` renders dark when the client
  expresses no preference, and `light-dark()` flips every color when the OS
  preference says otherwise. Browsers without `light-dark()` support keep the
  dark palette via plain-value fallbacks.
- System font stack, no webfont, script, or image requests — the page is one
  HTML file plus the shared style sheet, so it renders identically offline and
  under the strictest CSP the image can emit (`enable-csp`).
- `text-wrap: balance`/`pretty`, `svh` mobile sizing, a `prefers-reduced-motion`
  guard on the entrance animation, and a visible focus ring on the call to
  action.

## Extending

- **New status code**: add a `title_for`/`desc_for` case in the build hook, an
  `error_page` line in the server include, and the code in
  `test.d/1400-error-pages.sh` — the three lists must stay in sync.
- **New wording**: edit the msgid in the hook, then
  `make i18n-extract && make i18n-update`, translate, rebuild.
- **New design**: edit the template and `error.css`; every language picks it up
  on the next build.
