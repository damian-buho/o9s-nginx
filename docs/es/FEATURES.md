<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
SPDX-License-Identifier: MIT
-->

<!-- textlint-disable terminology,common-misspellings -->

[English](../FEATURES.md) · [Українська](../uk/FEATURES.md)

# Características

## Características del proyecto

### Automatización integrada de certificados ACME

- nginx obtiene y renueva sus propios certificados TLS: sin contenedor de certbot, sin cron, sin script de recarga.
- Funciona con cualquier autoridad de certificación compatible con ACME, no solo Let’s Encrypt.
- Desactivado por defecto; un interruptor lo activa y cada sitio lo habilita por separado.

### IP real del cliente detrás de CDN

- Los registros, los límites de tasa y los backends ven la dirección del visitante, no el nodo de la CDN ni la pasarela de Docker.
- Los ajustes para Cloudflare, Akamai, AWS CloudFront y Fastly descargan los rangos vigentes del proveedor en cada arranque, así la lista de confianza nunca queda obsoleta; la cabecera de IP del cliente se elige según el proveedor.
- Los conjuntos de confianza se combinan: una CDN delante de otro proxy inverso resuelve el cliente real tanto en la ruta directa como en la proxificada.
- Los backends proxificados reciben exactamente una dirección de cliente resuelta, nunca la cadena de reenvío completa.
- Un proveedor mal escrito impide el arranque; una lista de proveedor inaccesible genera un aviso y conserva las demás fuentes.

### Compresión Brotli, zstd y gzip

- Brotli y zstd se incluyen junto a gzip, de modo que cada navegador moderno recibe su mejor codificación.
- Los tres comparten una única lista de tipos comprimibles, y los medios y archivos ya comprimidos se dejan intactos.
- Los niveles al vuelo se mantienen bajos para ahorrar CPU; los archivos precomprimidos en la compilación se sirven con la máxima compresión (ver precompresión estática).

### Configuración solo mediante variables de entorno

- Cada ajuste de nginx tiene un valor por defecto sensato y una variable de entorno que lo sobrescribe: la imagen funciona sin montar archivos de configuración.
- Puertos, TLS, compresión, proxy, caché, registros, cabeceras de seguridad y trazas se ajustan desde `docker run` o compose.
- Los comportamientos opcionales (CORS, cabeceras de seguridad, redirección a HTTPS, certificados, trazas) se activan por sitio listándolos, sin editar la configuración.

### robots.txt con Content Signals para IA

- `robots.txt` se genera al arrancar: no hay archivo que montar ni mantener por entorno.
- El rastreo está prohibido por defecto, así un despliegue de pruebas nunca se indexa por accidente.
- Emite Content Signals (contentsignals.org) para declarar si se permiten la indexación en buscadores, el entrenamiento de IA y el uso como entrada de IA.
- Se añade una referencia al sitemap cuando se declara uno.

### Base para imágenes basadas en nginx

- Un solo `FROM` hereda el proceso de compilación, los hooks de arranque, los healthchecks, las páginas de error y la precompresión.
- Las imágenes hijas se personalizan sobrescribiendo valores de entorno, nunca copiando ni parcheando archivos de configuración.
- Nuevos manejadores de peticiones y comportamientos opcionales se añaden colocando un archivo de plantilla en la imagen; la configuración existente queda intacta.
- Un scaffold inicia un nuevo proyecto basado en nginx con todo lo anterior ya conectado.

### Páginas de error localizadas y autosuficientes

- Páginas de error propias para los diez códigos de estado estándar (400–504), generadas en tiempo de construcción a partir de una única plantilla, en lugar de las páginas integradas de nginx.
- Cada visitante recibe su idioma: el servidor negocia `Accept-Language` por petición (inglés, español, ucraniano) con retorno automático al inglés — sin JavaScript.
- Oscuras por defecto y siguen la preferencia clara/oscura del sistema operativo mediante el cambio nativo de esquema de color de CSS.
- Completamente autosuficientes: tipografías del sistema y sin peticiones a terceros, así que se renderizan igual sin conexión y bajo una Content-Security-Policy estricta.
- Añadir un idioma es un solo archivo gettext `.po` — las páginas y la negociación se amplían automáticamente en la siguiente construcción.

### HTTP/3 (QUIC)

- HTTP/3 viene compilado y activado por defecto; los navegadores reciben el anuncio y lo adoptan por sí solos.
- HTTP/2 y HTTP/3 comparten un mismo puerto.
- Las opciones de transporte QUIC y de socket se ajustan en tiempo de ejecución para servidores con mucho tráfico.

### Tipos de contenido y caché correctos

- El texto se sirve como UTF-8, así los caracteres acentuados se muestran bien en texto plano, Markdown y CSV.
- Los tipos de archivo modernos que faltan en nginx de serie reciben el tipo correcto: módulos de JavaScript, subtítulos, manifiestos web, imágenes JPEG XL y HEIC, audio Opus/FLAC, YAML y TOML; el navegador los muestra en lugar de descargarlos.
- Los recursos estáticos reciben caché de navegador de larga duración según su tipo, mientras que el HTML se revalida.

### Trazas OpenTelemetry y registros de acceso en JSON

- Cada petición puede exportarse como span a cualquier colector OpenTelemetry, y el contexto de traza puede propagarse al backend.
- Desactivado por defecto, sin sobrecarga hasta que se necesiten trazas; cada sitio lo habilita por separado.
- Incluye un formato de registro de acceso en JSON para canalizaciones de registros que procesan líneas estructuradas.

### Indicaciones de recursos automáticas

- Al arrancar recorre las hojas de estilo, scripts, imágenes y fuentes del sitio y envía cabeceras de precarga, así el navegador empieza a descargarlos antes de analizar el HTML.
- Cada tipo de recurso se puede activar o desactivar; el escaneo es opcional.
- Las indicaciones de preconexión y de prerresolución DNS para orígenes de terceros se definen con una lista separada por comas.

### Cabeceras de seguridad

- Content-Security-Policy, HSTS, Permissions-Policy, Cross-Origin-Embedder-Policy, Reporting-Endpoints, `nosniff` y la protección contra enmarcado se activan con un interruptor cada una, con valores restrictivos por defecto.
- Las imágenes hijas añaden a la política los hashes de sus propios scripts en línea, así una CSP estricta no necesita `'unsafe-inline'`.
- Las cabeceras también se envían en las respuestas de error, así una página 404 o 502 queda tan protegida como el sitio.
- nginx responde directamente a las peticiones CORS preliminares, sin llegar al backend.
- La redirección de HTTP a HTTPS está disponible por sitio.

### Validación de la configuración y healthchecks propios de nginx

- La configuración generada se prueba antes de arrancar nginx; si falla, se registra cada archivo generado, de modo que la línea errónea aparece en el registro del contenedor.
- Los healthchecks consultan a nginx y hacen una petición HTTP real, no solo comprueban que el proceso exista.
- Hay un endpoint de disponibilidad para balanceadores de carga y orquestadores.
- Un comando de depuración muestra la configuración efectiva completa con cada include expandido.

### Modos de servicio listos para usar

- Un solo ajuste elige cómo se sirve un sitio: archivos estáticos, una aplicación PHP mediante FastCGI, archivos estáticos con respaldo en un backend de aplicación, o un listado de directorio.
- Los backends se resuelven cuando llega la petición, así nginx arranca aunque la aplicación aún no esté disponible.
- Las actualizaciones a WebSocket y las cabeceras de reenvío funcionan a través del proxy sin configuración adicional.
- Las imágenes hijas añaden sus propios modos con un archivo de plantilla.

### Precompresión de recursos estáticos

- Los archivos estáticos se comprimen una sola vez, con la máxima compresión, en gzip, brotli y zstd; nginx sirve el archivo listo sin coste de CPU por petición.
- Se ejecuta en la compilación y lo heredan las imágenes hijas; también puede ejecutarse al arrancar el contenedor para contenido montado desde un volumen.
- Puede vigilar un directorio de versiones montado y volver a comprimir por sí solo cuando se activa una nueva versión.
- Un comando independiente comprime cualquier directorio a mano.

### Valores TLS reforzados por defecto

- Solo TLS 1.2 y 1.3, con cifrados AEAD con secreto perfecto hacia adelante y renegociación desactivada.
- Los parámetros Diffie-Hellman se generan en la compilación, así el primer handshake nunca los espera.
- La versión de nginx se oculta en las cabeceras de respuesta y en las páginas de error.

## Heredado de B19 / Ubuntu

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

- Healthcheck nativo de Docker heredado por todas las imágenes derivadas sin configuración extra.
- Las comprobaciones de salida son opcionales: un contenedor que nunca llega a internet no lleva ninguna comprobación que un tercero pueda hacer fallar, mientras que uno cuyo trabajo es internet se marca como no disponible en cuanto el exterior desaparece.
- Funciona igual sin conexión que en línea: las comprobaciones de salida se retiran automáticamente en modo offgrid.
- Añadir una comprobación es dejar caer un script en un directorio, no escribir configuración de Docker.
- Las comprobaciones pesadas o con límite de peticiones se ejecutan cada hora en segundo plano, de modo que un escaneo lento nunca agota el tiempo del healthcheck ni consume un límite de peticiones.

Consulte [use-healthcheck.d](../how-to/use-healthcheck.d.md) para la lista de comprobaciones, la numeración de slots y la configuración.

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
- La identidad del usuario es configurable en tiempo de compilación, y un arranque opcional como root la reasigna al usuario del host para que los montajes bind conserven su propietario.

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
- Sin dependencia de ningún framework de tests: los tests son scripts de shell simples con códigos de salida, y una comprobación fallida indica qué esperaba y qué encontró.
- Admite plantillas Jinja2 en los tests, útil para afirmar en runtime valores fijados en compilación.
- Continúa ante fallos e informa del recuento total; nunca oculta resultados parciales.

### Nada se cuelga para siempre

- Cada paso de arranque, prueba y comando puntual tiene un límite de tiempo, así que una herramienta bloqueada falla de forma visible en lugar de detener un despliegue o una ejecución de CI.
- Las descargas estancadas se abortan, mientras que las lentas de cualquier tamaño se completan.
- Una llamada inestable puede reintentarse con espera progresiva con una sola opción, sin escribir un bucle a mano.
- Un reinicio opcional convierte un servicio atascado en estado no saludable en un contenedor que la política de reinicio recupera.

Consulta [use-timeouts](../how-to/use-timeouts.md) para las opciones, los valores por defecto y cómo cambiarlos.

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
