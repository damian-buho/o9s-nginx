<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

# Pregeneración de parámetros DH

- Un archivo de parámetros DH de 2048 bits se genera en tiempo de compilación si no existe ya, evitando el costoso cálculo en la primera petición en producción.
- El tamaño de los parámetros DH es configurable mediante `B19_CA_DHPARAMS_SIZE`; la ruta de salida es `${O9S_NGINX_TLS_PATH}/dhparams.pem`.
- El archivo generado lo consume automáticamente el bloque de configuración TLS (`ssl_dhparam`).
