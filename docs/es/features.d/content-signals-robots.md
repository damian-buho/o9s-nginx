<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

<!-- textlint-disable terminology,common-misspellings -->

# robots.txt con Content Signals para IA

- `robots.txt` se genera al arrancar: no hay archivo que montar ni mantener por entorno.
- El rastreo está prohibido por defecto, así un despliegue de pruebas nunca se indexa por accidente.
- Emite Content Signals (contentsignals.org) para declarar si se permiten la indexación en buscadores, el entrenamiento de IA y el uso como entrada de IA.
- Se añade una referencia al sitemap cuando se declara uno.

<!-- textlint-enable -->
