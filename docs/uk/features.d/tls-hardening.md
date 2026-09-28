<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

<!-- textlint-disable terminology,common-misspellings -->

# Посилені налаштування TLS за замовчуванням

- Лише TLS 1.2 і 1.3, з AEAD-шифрами з прямою секретністю та вимкненим повторним узгодженням.
- Параметри Діффі — Геллмана генеруються під час збірки, тож перше рукостискання ніколи на них не чекає.
- Версія nginx прихована в заголовках відповідей і на сторінках помилок.

<!-- textlint-enable -->
