<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

<!-- textlint-disable terminology,common-misspellings -->

# Precompresión de recursos estáticos

- Los archivos estáticos se comprimen una sola vez, con la máxima compresión, en gzip, brotli y zstd; nginx sirve el archivo listo sin coste de CPU por petición.
- Se ejecuta en la compilación y lo heredan las imágenes hijas; también puede ejecutarse al arrancar el contenedor para contenido montado desde un volumen.
- Puede vigilar un directorio de versiones montado y volver a comprimir por sí solo cuando se activa una nueva versión.
- Un comando independiente comprime cualquier directorio a mano.

<!-- textlint-enable -->
