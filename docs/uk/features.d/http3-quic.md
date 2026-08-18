<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

<!-- textlint-disable terminology,common-misspellings -->

# Підтримка HTTP/3 (QUIC)

- nginx компілюється з вихідного коду з повною підтримкою HTTP/3 (QUIC), типово увімкненою (`O9S_NGINX_HTTP3=on`).
- Заголовок `Alt-Svc` випускається автоматично, оголошуючи порт QUIC, щоб сумісні браузери прозоро переходили на HTTP/3.
- Параметри транспорту QUIC налаштовуються через ENV: GSO (`O9S_NGINX_QUIC_GSO`), retry (`O9S_NGINX_QUIC_RETRY`), BPF (`O9S_NGINX_QUIC_BPF`), максимальна кількість паралельних потоків і розмір буфера потоку.
- HTTP/2 і HTTP/3 слухають той самий порт (окремі директиви `listen` для `ssl` і `quic`), усі параметри сокетів налаштовуються незалежно.

<!-- textlint-enable -->
