<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

<!-- textlint-disable terminology,common-misspellings -->

# IP real del cliente detrás de CDN

- Los registros, los límites de tasa y los backends ven la dirección del visitante, no el nodo de la CDN ni la pasarela de Docker.
- Los ajustes para Cloudflare, Akamai, AWS CloudFront y Fastly descargan los rangos vigentes del proveedor en cada arranque, así la lista de confianza nunca queda obsoleta; la cabecera de IP del cliente se elige según el proveedor.
- Los conjuntos de confianza se combinan: una CDN delante de otro proxy inverso resuelve el cliente real tanto en la ruta directa como en la proxificada.
- Los backends proxificados reciben exactamente una dirección de cliente resuelta, nunca la cadena de reenvío completa.
- Un proveedor mal escrito impide el arranque; una lista de proveedor inaccesible genera un aviso y conserva las demás fuentes.

<!-- textlint-enable -->
