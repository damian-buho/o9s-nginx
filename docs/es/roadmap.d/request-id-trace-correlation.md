<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

<!-- textlint-disable terminology,common-misspellings -->

# Identificador de petición y contexto de traza en los registros de acceso

- **Problema.** El módulo OTel emite trazas y hay un formato de registro JSON definido, pero los registros de acceso usan un formato de texto fijo sin identificador de petición ni traza, así que una línea de registro no puede atarse a su traza al depurar.
- **En estudio.** Generar un `X-Request-Id` por petición (u honrar uno entrante), devolverlo en una cabecera de respuesta e inyectarlo junto con el `trace_id`/`span_id` de OTel en un registro de acceso JSON seleccionable.
- **Depende de.** La variable `$request_id` de nginx y las variables de contexto de traza del módulo OTel compilado; el formato `json_combined` ya definido.

<!-- textlint-enable -->
