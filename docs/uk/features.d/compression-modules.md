<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

<!-- textlint-disable terminology,common-misspellings -->

# Стиснення Brotli, zstd і gzip

- Brotli і zstd постачаються поряд із gzip, тож кожен сучасний браузер отримує найкраще для нього кодування.
- Усі три використовують один список типів для стиснення, а вже стиснені медіа й архіви не чіпаються.
- Рівні стиснення «на льоту» тримаються низькими, щоб заощадити CPU; файли, стиснені під час збірки, віддаються з максимальним ступенем (див. попереднє стиснення статики).

<!-- textlint-enable -->
