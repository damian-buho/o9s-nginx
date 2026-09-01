<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
SPDX-License-Identifier: MIT
-->

<!-- textlint-disable terminology,common-misspellings -->

[English](../../FEATURES.md) · [Українська](../uk/FEATURES.md)

# Características

## Características del proyecto

### Módulo integrado de automatización de certificados ACME

- Se incluye un módulo cliente de ACME (compilado desde Rust) como módulo dinámico de nginx, lo que permite el aprovisionamiento automático de certificados TLS sin un agente externo.
- Se activa con `O9S_NGINX_MODULE_ACME=Y`; el bloque del emisor ACME se emite automáticamente en la configuración HTTP.
- La URL del servidor ACME (`O9S_NGINX_ACME_SERVER`) y el nombre del emisor (`O9S_NGINX_ACME_ISSUER_NAME`) son configurables, con soporte para cualquier CA compatible con ACME.
- La configuración de certificados por servidor está disponible mediante el include opt/ `enable-acme`.

### Resolución de IP real consciente de CDN

- Los rangos de IP de proxies de confianza de los principales CDN se obtienen en vivo en cada arranque del contenedor, garantizando que las listas `set_real_ip_from` estén siempre actualizadas.
- Modos de CDN admitidos (`O9S_NGINX_REALIP_MODE`): `cloudflare` (cabecera CF-Connecting-IP), `akamai` (True-Client-IP), `aws` (rangos de CloudFront + ELB, X-Forwarded-For), `fastly` (Fastly-Client-IP).
- También hay modos sin CDN: `docker` (rangos estáticos de la RFC 1918), `custom` (subred especificada por el usuario mediante `O9S_NGINX_REALIP_NETWORK`), `localhost`.
- El `real_ip_header` apropiado se establece automáticamente según el modo de CDN.
- La obtención de IP se omite en modo inmutable (`B19_IMMUTABLE=Y`).

### Múltiples módulos de compresión (brotli, zstd, gzip)

- Tres algoritmos de compresión se compilan como módulos dinámicos y se cargan condicionalmente mediante `O9S_NGINX_MODULE_{BROTLI,ZSTD}` (ambos activados por defecto; gzip está integrado en el núcleo de nginx).
- Cada algoritmo tiene conmutadores de activación/desactivación y niveles de compresión independientes, controlables en tiempo de ejecución.
- Los niveles de compresión dinámica pueden diferir de los de precompresión: en tiempo de ejecución se usan niveles menores por eficiencia de CPU; la precompresión usa el máximo.
- Una lista compartida de tipos MIME (`O9S_NGINX_COMPRESS_TYPES`) controla qué tipos de contenido son aptos para compresión en los tres algoritmos.
- Los hermanos precomprimidos `.br`, `.zst` y `.gz` se sirven directamente mediante los módulos `*_static` correspondientes cuando existen (véase la precompresión estática).

### Configuración dirigida por el entorno (cero montajes de configuración)

- Cada directiva de nginx se controla mediante más de 200 variables de entorno `O9S_NGINX_*` con valores predeterminados razonables integrados en el Dockerfile — la imagen funciona por completo con `docker run` y sin archivos de configuración montados.
- Las imágenes descendentes y los archivos compose ajustan nginx solo con sobrescrituras de `environment:` o `ENV`; no hacen falta montajes de volumen en `/etc/nginx/` ni archivos `.conf`.
- Todas las plantillas se generan al arrancar mediante el hook estándar de renderizado Jinja2, con cada variable ENV del contenedor disponible como `ENV.VAR_NAME`.
- Las categorías de variables cubren puertos, HTTP/2+3, compresión, proxy, FastCGI, TLS, registro, caché, CSP, CORS, Permissions-Policy, IP real, OpenTelemetry y opciones de socket.

### Directivas Content-Signal y robots.txt

- Un archivo `robots.txt` se genera al arrancar desde variables de entorno — no hay que montar ningún archivo estático.
- La política de rastreo predeterminada se configura con `O9S_NGINX_ROBOTS_TXT_DEFAULT_POLICY`: `disallow` (predeterminado), `allow` o `none` (omite el bloque predeterminado por completo).
- Se emiten directivas Content-Signal según contentsignals.org: `CONTENT_SIGNALS_SEARCH`, `CONTENT_SIGNALS_TRAIN`, `CONTENT_SIGNALS_INPUT` controlan si se permiten la indexación para búsqueda, el entrenamiento de IA y la entrada a la IA (`yes`/`no`).
- Puede declararse una URL de sitemap mediante `O9S_NGINX_ROBOTS_TXT_SITEMAP`.

### Pregeneración de parámetros DH

- Un archivo de parámetros DH de 2048 bits se genera en tiempo de compilación si no existe ya, evitando el costoso cálculo en la primera petición en producción.
- El tamaño de los parámetros DH es configurable mediante `B19_CA_DHPARAMS_SIZE`; la ruta de salida es `${O9S_NGINX_TLS_PATH}/dhparams.pem`.
- El archivo generado lo consume automáticamente el bloque de configuración TLS (`ssl_dhparam`).

### Patrón de consumo descendente

- Las imágenes hijas heredan los más de 200 valores ENV predeterminados, la jerarquía de plantillas, los hooks del entrypoint, las comprobaciones de estado y la lógica de precompresión desde una sola línea `FROM`.
- La personalización se hace sobrescribiendo valores `ENV` concretos en el Dockerfile hijo (p. ej. `O9S_NGINX_INDEX_TYPE=cache`, duraciones de caché, host/puerto del backend).
- Se pueden añadir nuevos gestores de contenido colocando un archivo `.nginx.j2` en `includes/index/` y estableciendo `O9S_NGINX_INDEX_TYPE` — la ruta de include es dinámica.
- Se pueden añadir nuevos conmutadores de características colocando un archivo en `includes/opt/` y listando su nombre en `O9S_NGINX_INCLUDE_OPTIONAL`.
- Nunca se requieren montajes de archivos de configuración: el patrón es solo ENV desde la imagen base hasta todos los derivados descendentes.

### Páginas de error localizadas y autosuficientes

- Páginas de error propias para los diez códigos de estado estándar (400–504), generadas en tiempo de construcción a partir de una única plantilla, en lugar de las páginas integradas de nginx.
- Cada visitante recibe su idioma: el servidor negocia `Accept-Language` por petición (inglés, español, ucraniano) con retorno automático al inglés — sin JavaScript.
- Oscuras por defecto y siguen la preferencia clara/oscura del sistema operativo mediante el cambio nativo de esquema de color de CSS.
- Completamente autosuficientes: tipografías del sistema y sin peticiones a terceros, así que se renderizan igual sin conexión y bajo una Content-Security-Policy estricta.
- Añadir un idioma es un solo archivo gettext `.po` — las páginas y la negociación se amplían automáticamente en la siguiente construcción.

### Includes de conmutadores de características (sistema opt/)

- Fragmentos de nginx autocontenidos en `includes/opt/` se incluyen condicionalmente por bloque de servidor mediante `O9S_NGINX_INCLUDE_OPTIONAL` (lista de nombres separados por comas).
- Conmutadores disponibles: CORS (`enable-cors`, 6 variables), Content-Security-Policy (`enable-csp`, 18 variables), HSTS (`enable-hsts`), Permissions-Policy (`enable-permissions-policy`, 12 variables), stub status (`enable-status`), certificado ACME (`enable-acme`), OTel por servidor (`enable-otel`), cache-control (`enable-cache`), favicon (`enable-favicon`), rutas de certbot (`enable-certbot`), X-Frame-Options DENY (`enable-sameorigin`), X-Content-Type-Options nosniff (`enable-nosniff`), redirección de HTTP a HTTPS (`redirect-to-https`).
- Cada conmutador se gobierna por completo mediante ENV — no hay que editar archivos de configuración de nginx.
- Las imágenes descendentes pueden añadir nuevos fragmentos opt/ depositando un archivo `.nginx` o `.nginx.j2` en `includes/opt/`.

### Soporte de HTTP/3 (QUIC)

- nginx se compila desde el código fuente con soporte completo de HTTP/3 (QUIC), activado por defecto (`O9S_NGINX_HTTP3=on`).
- La cabecera `Alt-Svc` se emite automáticamente, anunciando el puerto QUIC para que los navegadores compatibles pasen a HTTP/3 de forma transparente.
- Las opciones de transporte de QUIC son ajustables por ENV: GSO (`O9S_NGINX_QUIC_GSO`), retry (`O9S_NGINX_QUIC_RETRY`), BPF (`O9S_NGINX_QUIC_BPF`), flujos concurrentes máximos y tamaño del búfer de flujo.
- HTTP/2 y HTTP/3 escuchan en el mismo puerto (directivas `listen` separadas para `ssl` y `quic`), con todas las opciones de socket configurables de forma independiente.

### Módulo de trazado OpenTelemetry

- Un módulo de OpenTelemetry se compila como módulo dinámico de nginx para la exportación de trazado distribuido vía OTLP/gRPC.
- Se activa con `O9S_NGINX_MODULE_OTEL=Y`; está desactivado por defecto para evitar sobrecarga cuando no se necesita trazado.
- El endpoint OTLP (`O9S_OTEL_ENDPOINT`), el nombre del servicio (`O9S_OTEL_SERVICE_NAME`) y la propagación de contexto de traza son configurables por ENV.
- Se admiten el ajuste del exportador (intervalo, tamaño y cantidad de lotes) y atributos de span personalizados.
- El trazado por servidor puede activarse mediante el include opt/ `enable-otel`.

### Escaneo de pistas de precarga

- Al arrancar el contenedor, la raíz de documentos se escanea en busca de recursos CSS, JavaScript, imágenes y fuentes, generando automáticamente cabeceras de precarga `<Link>`.
- El escaneo es opcional mediante `O9S_NGINX_PH_SCAN_ENABLED=Y`; los tipos de recurso individuales (style, script, image, font) pueden conmutarse de forma independiente.
- La ruta de escaneo es configurable mediante `O9S_NGINX_PH_SCAN_PATH` (predeterminado `assets`).
- Los recursos descubiertos se escriben en un sidecar JSON que consume la plantilla Jinja2, produciendo cabeceras `Link: <...>; rel=preload; as=...` en las respuestas HTML.

### Sistema de andamiaje para imágenes descendentes basadas en nginx

- Un directorio `scaffold/` aporta una plantilla de Dockerfile y `stack.conf` para arrancar nuevos proyectos derivados de nginx.
- Usa la integración de pila de m6e (`STACK_ROOT_STAGE=base`, `STACK_EXTENSIONS=nginx`) para que los nuevos proyectos hereden automáticamente la cadena de compilación completa.
- Los proyectos descendentes solo necesitan sobrescribir valores `ENV` concretos y, opcionalmente, añadir archivos `includes/` propios — el Dockerfile base, el entrypoint, la comprobación de estado y la jerarquía de plantillas se heredan por completo.

### Precompresión de recursos estáticos

- Los archivos estáticos se precomprimen en tres formatos (gzip con pigz, brotli, zstd) para que nginx sirva directamente los hermanos preconstruidos `.gz`/`.br`/`.zst` — sin coste de CPU por petición.
- La compresión se ejecuta por defecto en tiempo de compilación (el hook heredable `.i.sh` se propaga a las imágenes descendentes) y, opcionalmente, otra vez al arrancar el contenedor.
- Las extensiones de archivo a comprimir son configurables (`O9S_NGINX_PRECOMPRESS_EXTENSIONS`); las salidas de plantillas Jinja2 se excluyen automáticamente.
- Cada algoritmo tiene conmutadores de activación/desactivación y niveles de compresión independientes (la precompresión usa niveles máximos: gzip 9, brotli 11, zstd 19).
- La orden autónoma `compress-static-assets` está disponible para invocarse manualmente sobre cualquier directorio.

### Jerarquía de plantillas basada en includes Jinja2

- Todo el árbol de configuración de nginx vive como plantillas Jinja2 (`.j2`) bajo `${XDG_CONFIG_HOME}/`, compuesto mediante directivas `include` — sin un archivo de configuración monolítico.
- El bloque `http {}` incorpora 24 fragmentos numerados (`includes/http/*.nginx`) ordenados por prefijo: núcleo, AIO, DNS, compresión, ACME, cliente/ES, HTTP/2+3, keepalive, proxy, caché, TLS, registro, IP real y OpenTelemetry.
- Los bloques de servidor se componen de includes modulares: `listen/` (configuración de socket), `server/` (páginas de error, ETag, prefetch de DNS, pistas de precarga), `index/` (gestor de contenido), `opt/` (conmutadores de características) y `realip/` (resolución de IP consciente de CDN).
- Las plantillas que necesitan lógica condicional usan bloques Jinja2 `{% if %}`; los fragmentos sin condicionales son archivos `.nginx` planos renderizados tal cual.
- Se pueden añadir nuevos comportamientos depositando un archivo en el directorio `includes/` apropiado — sin editar las plantillas existentes.

## Heredado de B19/Ubuntu

### Caché APT persistente entre compilaciones

- Las cachés de paquetes e índices de APT sobreviven entre compilaciones mediante montajes de caché de BuildKit, con clave por serie de Ubuntu y arquitectura.
- Las compilaciones repetidas reutilizan los paquetes descargados en lugar de volver a descargarlos.
- Proxy opcional de caché APT en LAN, se activa con `M6E_APT_CACHE_HOST`.

### Gestión de procesos de servicio con enrutado de logs (b19-exec)

- Los procesos de larga duración (demonios, servidores) tienen stdout y stderr enrutados automáticamente a través del logger estructurado.
- Se hace seguimiento del PID del servicio para el reenvío de señales: Docker stop termina de forma elegante el proceso principal.
- Los niveles de log de los flujos stdout y stderr se configuran de forma independiente.
- El código de salida del servicio se captura y queda disponible para los hooks posteriores.

### Descargas de artefactos con caché y verificación de integridad (b19-fetch)

- Todas las descargas externas pasan por una caché de tres niveles: directorio local `.fetch/`, caché persistente de BuildKit y luego upstream vía aria2c con hasta 16 conexiones.
- Verificación SHA-512 opcional en cada nivel; un hash que no coincide provoca caída al siguiente nivel en lugar de fallo.
- El modo offgrid bloquea todas las descargas por completo, fallando rápido con un error claro si se produce un fallo de caché.
- Admite un proxy de near-cache para compilaciones solo-LAN que pasan por un proxy de caché.

### Ejecución de comandos temporizada con informe de fallos (b19-run)

- Cualquier comando puede envolverse para obtener medición automática del tiempo transcurrido e informe de éxito o fallo.
- La salida correcta solo es visible en niveles de verbosidad mayores; la salida de fallo siempre se muestra.
- En modo debug, la salida del comando se transmite en vivo en lugar de almacenarse en búfer.

### Inicialización de una sola vez (bootstrap.d)

- Las tareas de configuración únicas (migraciones de base de datos, creación del usuario administrador, init de directorios) se ejecutan solo en el primer arranque del contenedor.
- Idempotencia automática: los scripts completados no vuelven a ejecutarse jamás, ni siquiera entre reinicios del contenedor.
- Los scripts fallidos se reintentan en el siguiente arranque; los exitosos quedan bloqueados.
- El estado puede resetearse limpiando un volumen, lo que dispara un re-bootstrap completo.
- Las imágenes derivadas añaden sus propios scripts de init dejándolos caer en un directorio.

### Hooks de compilación modulares (build.d)

- Toda la lógica de compilación de la imagen vive en scripts de shell numerados en lugar de comandos `RUN` inline en el Dockerfile.
- Los hooks se organizan en fases `pre/on/post` y se autodescubren por el nombre de etapa pasado a `build-stage`.
- El ámbito reservado `always/{pre,post}` enmarca cada etapa, se llame como se llame, de modo que la configuración transversal se escribe una vez en lugar de por etapa.
- Los hooks heredables se propagan a las imágenes derivadas automáticamente vía superposición de capas de Docker: las derivadas obtienen gratis la lógica de compilación del padre.
- Los hooks no heredables se limpian tras su ejecución para evitar que se filtren en etapas posteriores.

### Detección automática del número de CPUs (NUMPROCS)

- Las CPUs disponibles se detectan automáticamente con la downward API de Kubernetes, cgroups v2 o `nproc` como respaldo.
- El recuento detectado está disponible como `NUMPROCS` durante toda la compilación y el runtime, y se usa para compilación paralela, renderizado de plantillas y ejecución de tests.
- Elimina los recuentos de jobs hardcodeados y garantiza un paralelismo consistente entre Docker, Kubernetes y CI.

### Gestión declarativa de dependencias (b19-deps)

- Los metadatos de dependencias externas (URL, versión, hash SHA-512) se guardan como archivos de texto plano, completamente separados de los scripts de compilación.
- Admite descargas específicas por arquitectura, series multiversión y rutas de componentes anidadas.
- Las dependencias se autodescubren al parsear el Makefile: añade archivos al directorio correcto y la compilación los recoge sin declaraciones manuales.
- `make fetch` predescarga todo para compilaciones offline; los cambios de versión disparan un re-fetch y una actualización de hashes automáticos.

### Sistema de arranque conectable (entrypoint.d)

- Cada arranque de contenedor pasa por una secuencia de hooks numerados: configuración de señales, carga de secretos, detección de CPU, validación de puertos, renderizado de plantillas, bootstrap y arranque del servicio.
- Los comandos ad hoc (`docker run img command`) saltan automáticamente parte de la cadena de arranque y se ejecutan directamente.
- Tanto los hooks individuales como el entrypoint completo pueden omitirse en runtime mediante variables de entorno, sin reconstruir la imagen.
- Las imágenes derivadas sobrescriben un único hook (slot 5000) para lanzar su servicio; todo lo demás se hereda.

### Conmutadores de funcionalidades para todos los subsistemas

- Cada subsistema mayor (entrypoint, healthchecks, bootstrap, tests, secrets, validación de puertos, i18n, shell hooks) puede desactivarse en runtime mediante variables de entorno.
- Los hooks individuales del entrypoint, del bootstrap y de las comprobaciones de salud pueden omitirse por nombre sin desactivar el subsistema entero.
- No hace falta reconstruir la imagen: los conmutadores son solo de runtime.

### Monitorización de estado integrada (healthcheck.d)

- Healthcheck nativo de Docker declarado en la imagen base y heredado por todas las imágenes derivadas sin configuración extra.
- Ocho comprobaciones por defecto en la imagen base: el espacio en disco, la escribibilidad del sistema de archivos y una prueba TCP de escucha se ejecutan siempre; la conectividad HTTPS, la resolución DNS y el alcance TCP solo se ejecutan donde `B19_HEALTH_EGRESS=true`, de modo que un contenedor que nunca llega a internet no lleva ninguna comprobación que un tercero pueda hacer fallar.
- Las comprobaciones de salida son tolerantes a fallos: el éxito en cualquier objetivo cuenta como aprobado.
- Todas las comprobaciones de salida se omiten automáticamente en modo offgrid; todas pueden desactivarse en runtime.
- Las imágenes derivadas añaden comprobaciones específicas del servicio (endpoints HTTP, conexiones a base de datos, vida del proceso) dejando caer scripts en un directorio.

### Salida de shell multilingüe (b19-i18n)

- Todos los mensajes de log y la salida de scripts orientados al usuario son traducibles vía GNU gettext.
- Trae de fábrica inglés, español (`es_CL`) y ucraniano (`uk_UA`).
- Las imágenes derivadas heredan automáticamente todas las traducciones del padre; solo las cadenas nuevas o sobrescritas necesitan traducción.
- Las traducciones se compilan en tiempo de compilación sin coste en runtime.

### Seguimiento del linaje de la imagen

- Cada imagen registra sus metadatos de compilación (namespace, proyecto, versión, imagen base) en un archivo de linaje durante la compilación.
- Las imágenes derivadas encadenan el linaje de su padre, produciendo una cadena de procedencia completa desde la base hasta la actual.
- Toda la cadena de linaje se registra al arrancar (verbosidad debug) y puede leerse del archivo en cualquier momento, lo que facilita rastrear a partir de qué se construyó un contenedor en ejecución.

### Logging estructurado con filtro por nivel (b19-log)

- Toda la salida del contenedor pasa por un logger con niveles y cuatro umbrales: error, warn, info, debug.
- Los mensajes por debajo de la verbosidad configurada se descartan silenciosamente, manteniendo limpios los logs de producción.
- Los colores autodetectan el soporte del terminal y respetan `NO_COLOR=1`.
- Encauzable: la salida de comandos puede enrutarse a través del logger para aplicar filtrado por nivel y tags.

### Contenedor sin privilegios de root por defecto

- El contenedor se ejecuta como usuario sin privilegios de root (`ubuntu`, UID/GID 1000) con todos los archivos de runtime en propiedad de ese usuario.
- Una compilación en dos etapas separa la instalación del sistema a nivel root de la configuración del runtime a nivel de usuario.
- La identidad del usuario es configurable en tiempo de compilación.

### Soporte de compilación y runtime aislados de internet (air-gapped/offline)

- Una única variable de entorno (`B19_OFFGRID_MODE=Y`) corta todo acceso a internet en tiempo de compilación y en runtime.
- En compilación: se bloquean las descargas, se saltan las actualizaciones de APT y se saltan los keyscans de SSH. Todos los artefactos deben provenir de los niveles de caché.
- En runtime: las comprobaciones de estado de red se saltan automáticamente con resultado saludable, así los contenedores permanecen en verde en redes aisladas.
- Las listas de paquetes APT pueden capturarse como snapshot e inyectarse para compilaciones de imagen totalmente offline.
- Los servicios de LAN (proxies de caché, registros) siguen siendo accesibles: offgrid bloquea internet, no toda la red.

### Inyección de overlays en runtime

- Se pueden inyectar archivos de configuración o datos al arrancar el contenedor estableciendo en `B19_OVERLAY` el nombre de un directorio.
- El contenido del overlay se copia recursivamente a la raíz del contenedor, sobrescribiendo los archivos existentes; no hace falta reconstruir la imagen.
- Se omite en modo inmutable, impidiendo la modificación en runtime de imágenes bloqueadas para producción.

### Imagen base reproducible (fijada por digest)

- La imagen base de Ubuntu está fijada por digest SHA-256, no por tag, lo que garantiza compilaciones deterministas.
- Admite varias series de Ubuntu (resolute, noble, jammy) seleccionables en tiempo de compilación.
- Los mirrors de APT son configurables por arquitectura para mirrors de LAN o entornos aislados.

### Validación de puertos

- Todas las variables de entorno `*PORT*` se validan al arrancar contra la lista de puertos prohibidos de WHATWG y contra los puertos privilegiados (\<1024).
- Detecta temprano configuraciones erróneas como `HTTP_PORT=22`, antes de que el servicio falle en silencio.
- Puede desactivarse en runtime sin reconstruir la imagen.

### Familia unificada de runners del ciclo de vida

- Ocho runners de hooks numerados cubren el ciclo de vida completo del contenedor: arranque, healthchecks, tests, bootstrap, hooks de compilación, benchmarks, reports y sesiones de shell.
- Todos los runners comparten el mismo patrón: deja caer un script numerado en un directorio y se autodescubre y ejecuta.
- Los scripts de distintas capas de imagen se mezclan: los hooks upstream y los derivados coexisten sin conflicto.
- Cada runner tiene semántica de fallo a medida: abortar ante error (entrypoint, bootstrap), continuar y contar fallos (healthchecks, tests), tener siempre éxito (reports).

### Autocarga de secretos de Docker (secrets)

- Los archivos de secretos de Docker se autodescubren y convierten en variables de entorno al arrancar.
- Los nombres de archivo en notación de puntos se mapean a variables de entorno en mayúsculas (`b19.npm.registry_host` se convierte en `B19_NPM_REGISTRY_HOST`).
- Los secretos requeridos pueden declararse por nombre; el contenedor se niega a arrancar si falta alguno.
- Las variables de entorno existentes tienen precedencia sobre los valores derivados de secretos.
- Los secretos también están disponibles en sesiones de shell interactivas y en healthchecks.
- Los secretos no UTF-8/binarios (claves, blobs DER, tarballs comprimidos con gzip) **no** se exportan como variables de entorno: Bash los trunca en el primer NUL y los bytes sueltos hacen fallar a cualquier herramienta que lea el entorno como UTF-8 (p. ej., `minijinja --env`, usado para plantillar configuraciones). Permanecen en disco en `/run/secrets/<name>` para lecturas basadas en archivo — que, de todos modos, es la única forma correcta de consumir un secreto binario.

### Hooks de shell interactivo (shell.d)

- Las sesiones `docker exec bash` cargan automáticamente los secretos de Docker y cualquier hook personalizado añadido por las imágenes derivadas.
- Los hooks se mezclan vía superposición de capas de Docker, así que la configuración de shell heredada y la específica del proyecto coexisten.

### Gestión elegante de señales

- El PID 1 es `tini -g`, que recoge los procesos zombi y reenvía señales a todo el grupo de procesos.
- Un conjunto configurable de señales Unix (TERM, INT, HUP, USR1, USR2, etc.) se captura y reenvía al proceso principal del servicio.
- `docker stop` termina limpiamente el servicio sin procesos huérfanos ni pérdida de señales.

### Plantillas de configuración Jinja2 (minijinja-cli)

- Renderizado de plantillas compatible con Jinja2 tanto en tiempo de compilación como al arrancar el contenedor.
- Deja caer un archivo `.j2` en cualquier parte del directorio de la aplicación; se descubre en tiempo de compilación y se renderiza en cada arranque con todas las variables de entorno disponibles.
- El renderizado en runtime es paralelo y automático: las imágenes derivadas lo obtienen sin configuración alguna.
- El modo inmutable (`B19_IMMUTABLE=Y`) congela el sistema de archivos en el estado de compilación, saltándose todo renderizado en runtime.

### Framework de tests integrado (test.d)

- Los tests se ejecutan dentro del contenedor en marcha vía `make test` o `docker exec`.
- Espera automáticamente a que pasen los healthchecks antes de ejecutar.
- Sin dependencia de ningún framework de tests: los tests son scripts de shell simples con códigos de salida.
- Admite plantillas Jinja2 en los tests, útil para afirmar en runtime valores fijados en compilación.
- Continúa ante fallos e informa del recuento total; nunca oculta resultados parciales.

### Herramientas de utilidad preinstaladas

- `mold` como enlazador por defecto (con opción de desactivarlo).
- `fd` para búsqueda de archivos, `minijinja-cli` para renderizado de plantillas.
- `aria2c` para descargas multiconexión, `tini` como PID 1 para recoger zombis.
- Herramientas de compresión paralela: `pbzip2`, `pigz`, `pixz`.
- Herramientas gettext para la compilación de i18n, `cURL` para operaciones de red.

### Rutas XDG Base Directory

- Las rutas XDG estándar (`XDG_CACHE_HOME`, `XDG_CONFIG_HOME`, `XDG_DATA_HOME`, `XDG_STATE_HOME`) se establecen bajo el directorio home de la aplicación.
- Todas las rutas son escribibles por el usuario sin privilegios de root, sin escalada de privilegios.
<!-- textlint-enable -->
