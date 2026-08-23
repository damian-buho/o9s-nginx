<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
SPDX-License-Identifier: MIT
-->

<!-- textlint-disable terminology,common-misspellings -->

[English](../../ROADMAP.md) · [Українська](../uk/ROADMAP.md)

# Hoja de ruta

## Hoja de ruta del proyecto

### Recarga en vivo sin cortar conexiones

- **Problema.** La configuración minijinja se renderiza solo al arrancar, así que cambiar cualquier valor `O9S_NGINX_*` o archivo de include significa reiniciar el contenedor y cortar las peticiones en vuelo.
- **En estudio.** Reenviar SIGHUP (y una vigilancia inotify opcional del árbol de includes) para re-renderizar las plantillas `.j2` y correr `nginx -s reload`, actualizando escuchadores y bloques server sin reiniciar el proceso.
- **Depende de.** La señal de recarga nativa de nginx; el paso de render ya invocado al arrancar; el reenvío de señal de grupo de tini.

### Identificador de petición y contexto de traza en los registros de acceso

- **Problema.** El módulo OTel emite trazas y hay un formato de registro JSON definido, pero los registros de acceso usan un formato de texto fijo sin identificador de petición ni traza, así que una línea de registro no puede atarse a su traza al depurar.
- **En estudio.** Generar un `X-Request-Id` por petición (u honrar uno entrante), devolverlo en una cabecera de respuesta e inyectarlo junto con el `trace_id`/`span_id` de OTel en un registro de acceso JSON seleccionable.
- **Depende de.** La variable `$request_id` de nginx y las variables de contexto de traza del módulo OTel compilado; el formato `json_combined` ya definido.

### Certificados TLS montados con respaldo de desarrollo

- **Problema.** La única fuente de certificados es el módulo ACME incorporado, que necesita un dominio real y validación DNS o HTTP; un operador con certificados existentes, una CA interna o una simple necesidad de HTTPS en localhost no tiene ruta de entorno y debe escribir includes a mano.
- **En estudio.** Un par de certificados gobernado por entorno (`O9S_NGINX_SSL_CERT` / `_KEY`) que cablee `ssl_certificate` y `ssl_certificate_key` a través de la compuerta existente de bloque server TLS, más un generador autofirmado de un solo interruptor para desarrollo local.
- **Depende de.** Las directivas `ssl_certificate` de nginx y la compuerta `O9S_NGINX_SSL_ENABLED` existente; la autocarga de secretos Docker de b19 para el material de claves.
<!-- textlint-enable -->
