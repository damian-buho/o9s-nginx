<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

# Визначення реальної IP з урахуванням CDN

- Діапазони IP довірених проксі великих CDN отримуються наживо при кожному запуску контейнера, тож списки `set_real_ip_from` завжди актуальні.
- Підтримувані режими CDN (`O9S_NGINX_REALIP_MODE`): `cloudflare` (заголовок CF-Connecting-IP), `akamai` (True-Client-IP), `aws` (діапазони CloudFront + ELB, X-Forwarded-For), `fastly` (Fastly-Client-IP).
- Доступні й режими без CDN: `docker` (статичні діапазони RFC 1918), `custom` (підмережа користувача через `O9S_NGINX_REALIP_NETWORK`), `localhost`.
- Відповідний `real_ip_header` встановлюється автоматично під кожен режим CDN.
- У незмінному режимі (`B19_IMMUTABLE=Y`) отримання IP пропускається.
