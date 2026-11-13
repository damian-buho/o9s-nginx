<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

# Hardened TLS defaults

- TLS 1.2 and 1.3 only, with forward-secret AEAD ciphers and renegotiation disabled.
- Post-quantum key exchange (X25519MLKEM768) is offered first, so modern browsers get a hybrid handshake; older clients fall back to classical curves.
- Diffie-Hellman parameters are generated at build time, so the first handshake never waits on them.
- The nginx version is hidden from response headers and error pages.
