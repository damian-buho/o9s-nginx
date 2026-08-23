<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

<!-- textlint-disable terminology,common-misspellings -->

# Recarga en vivo sin cortar conexiones

- **Problema.** La configuración minijinja se renderiza solo al arrancar, así que cambiar cualquier valor `O9S_NGINX_*` o archivo de include significa reiniciar el contenedor y cortar las peticiones en vuelo.
- **En estudio.** Reenviar SIGHUP (y una vigilancia inotify opcional del árbol de includes) para re-renderizar las plantillas `.j2` y correr `nginx -s reload`, actualizando escuchadores y bloques server sin reiniciar el proceso.
- **Depende de.** La señal de recarga nativa de nginx; el paso de render ya invocado al arrancar; el reenvío de señal de grupo de tini.

<!-- textlint-enable -->
