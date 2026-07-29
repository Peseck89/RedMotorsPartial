# Sprint 2 — Fuentes autoritativas (Empresa / Marcas Chinas)

## Estado del documento

Este documento es un **inventario de fuentes**, no un inventario de componentes. Clasifica cada documento disponible en `docs/empresa-marcas-chinas` según el orden de autoridad definido por Luis, y registra las contradicciones detectadas entre fuentes. El inventario de componentes (Flows/LWC/Aura) vive en `INVENTARIO_SPRINT2_FLOWS_COMPONENTES.md`.

## Orden de autoridad (definido por Luis, usado en todo este documento)

1. Tabla e instrucciones directas de Luis.
2. Documento original de alcance entregado por el cliente.
3. Manual de desarrollo.
4. Respuestas explícitas de Diego o María José.
5. Metadata real de RedMotorsSandbox / Partial.
6. Documentos internos generados por Code o Codex — evidencia secundaria únicamente.

Un documento interno (rango 6) nunca cambia cantidades, agrega componentes, mueve elementos entre Sprints, reemplaza una decisión de Luis/Diego, ni convierte una inferencia en requerimiento.

## Fuentes de rango 1 — Instrucciones directas de Luis

| Fuente | Fecha | Contenido aplicable a Sprint 2 |
|---|---|---|
| Comunicación directa de Luis en esta sesión de trabajo (mensaje de autorización de Sprint 2) | 2026-07-28 | Autoriza continuar con: ~20 Flows (incluidos 5 relacionados con Pricebooks) y ~16 LWC/Aura (incluido `rm_vu_inventario.js`), en paralelo a los pendientes de Sprint 1. No existe como archivo en el repositorio — es texto de la conversación, no reproducible por otra vía. |

**Nota:** esta es la única fuente de rango 1 disponible para Sprint 2. No hay una "tabla" de Luis en formato archivo dentro de `docs/empresa-marcas-chinas` — el mensaje de esta sesión es la fuente completa de rango 1 conocida hasta ahora.

## Fuentes de rango 2 — Documento original de alcance del cliente

| Archivo | Fecha | Autoridad | Secciones aplicables a Sprint 2 |
|---|---|---|---|
| `DEV Evaluación - Alcance - Inclusión de nueva Empresa- Marchas chinas Redmotors.docx.pdf` | Documento original (fecha de evaluación no fechada explícitamente en el cuerpo; recibido antes del inicio de Sprint 1) | **Fuente autoritativa (rango 2)** | Sección "4. Flows": 8 flows analizados individualmente con patrón técnico exacto + ejemplos de un universo de "38 flows con coincidencias" no inspeccionados línea por línea. Sección "5. LWC / Aura": ~22 componentes nombrados individualmente con patrón técnico. Sección "10. Inventario": lista específica de 4 LWC de inventario (`cT_Estadisticas_Inventario_lwc`, `rm_vu_crear_opp`, `productSearcher`, `rm_vn_inventario(_movil)`) y confirma que `BatchGetBodegaSoftland`/`BatchGetCatalogoSoftland` deben revisarse contra la compañía nueva (ya reconciliados en Sprint 1). |

**Extracción técnica:** este archivo es un PDF; se extrajo su texto con `pdftotext -layout` en esta sesión (herramienta disponible localmente) para poder citarlo. No se modificó el archivo original.

## Fuentes de rango 3 — Manual de desarrollo

| Archivo | Fecha | Autoridad | Secciones aplicables a Sprint 2 |
|---|---|---|---|
| `Manual_Analisis_Empresa_RedMotors_2026-07-22.docx` | 2026-07-22 | **Fuente autoritativa (rango 3)** | "Anexo A. Inventario técnico completo de candidatos": **A.3 Flows candidatos (47)**, cada uno con estado local (Active/Obsolete/Draft) y comparación contra RedPartial (identical/different/missing_in_compare) al 2026-07-22. **A.4 LWC y Aura (28 archivos / 22 componentes distintos)**, incluye explícitamente `rm_vu_inventario`. El propio Manual advierte: *"Una coincidencia es un punto de revisión, no una orden automática de editar. La clasificación final debe realizarse sobre la versión activa y el contenido funcional."* — es decir, el propio documento se autodefine como universo de candidatos, no como alcance confirmado. |

**Extracción técnica:** este archivo es un `.docx` (contenedor ZIP con XML). Se extrajo su texto leyendo `word/document.xml` y despojando las etiquetas XML en esta sesión. No se modificó el archivo original.

## Fuentes de rango 4 — Respuestas explícitas de Diego o María José

No existe ningún documento independiente de este rango en `docs/empresa-marcas-chinas`. Las únicas referencias a decisiones de Diego están **incrustadas** dentro de documentos de rango 6 (por ejemplo, `BITACORA_IMPLEMENTACION.md` cita "Luis confirmó..." o "Diego autorizó..." en varios hitos de Sprint 1). Esas citas son válidas como registro de una decisión ya tomada **para Sprint 1**, pero no constituyen una fuente de rango 4 independiente para Sprint 2 — para Sprint 2 no hay ninguna respuesta de Diego o María José documentada todavía.

## Fuentes de rango 5 — Metadata real de RedMotorsSandbox / Partial

No se ejecutó ningún retrieve de Partial para Flows/LWC/Aura en esta sesión (instrucción explícita: "no recuperar metadata todavía"). La única evidencia de comparación contra Partial disponible es la que el propio Manual (rango 3) capturó el 2026-07-22 en su Anexo A (columna "RedPartial"). Esa comparación tiene **19 días de antigüedad** respecto a hoy (2026-07-28) y debe tratarse como referencia histórica, no como estado actual confirmado.

## Fuentes de rango 6 — Documentos internos (evidencia secundaria)

Los 37 documentos Markdown restantes en `docs/empresa-marcas-chinas` (excluyendo este archivo y los otros documentos nuevos de Sprint 2). Ninguno contiene una lista de Flows/LWC de Sprint 2 — todos pertenecen al dominio de Sprint 1 (33x3, bloques 1-21, cierre 44h, trazabilidad). Ver clasificación completa por archivo en `PROPUESTA_LIMPIEZA_DOCUMENTAL.md`.

**Único documento de rango 6 con mención tangencial a Sprint 2:** ninguno. Se verificó con búsqueda de texto (`Sprint 2`, `Sprint2`, `rm_vu_inventario`, `LWC`, `Aura`, `Pricebook`+`Flow`) en los 37 archivos — el único hallazgo es que varios documentos de cierre de Sprint 1 mencionan "no se toca Sprint 2" como restricción, sin detallar su contenido.

## Contradicciones detectadas

| # | Contradicción | Fuentes en conflicto | Fuente que prevalece | Resolución |
|---|---|---|---|---|
| 1 | El documento original (rango 2) nombra `rm_vn_inventario`, `rm_vn_inventario_movil` y `rm_vu_crear_opp` en el contexto de inventario; Luis (rango 1) nombra `rm_vu_inventario.js`. Son **tres componentes reales y distintos** en Git (`rm_vn_inventario`, `rm_vu_crear_opp`, `rm_vu_inventario`), no un error de tipeo resoluble automáticamente. | Luis (rango 1) vs. documento original (rango 2) | Luis (rango 1) confirma `rm_vu_inventario` como incluido; el documento original (rango 2) sigue respaldando `rm_vn_inventario`, `rm_vn_inventario_movil` y `rm_vu_crear_opp` como candidatos independientes | Ninguno de los cuatro se descarta. Se documentan los cuatro en el inventario y se marca como pendiente que Luis confirme si los cuatro entran a Sprint 2 o solo `rm_vu_inventario` |
| 2 | El documento original (rango 2) señala `PlanDeMantenimientoV2` con el mismo patrón de riesgo de Pricebook que `BMW_ImportarPlantilla`; el Manual (rango 3), en su lista sistemática de 47 candidatos, **no incluye** `PlanDeMantenimientoV2`. | Documento original (rango 2) vs. Manual (rango 3) | Ninguna prevalece automáticamente — es una discrepancia entre dos fuentes de distinto rango que apuntan a información distinta, no una sola fuente corrigiendo a la otra | Se documenta `PlanDeMantenimientoV2` como candidato adicional del documento original, fuera de los 47 del Manual, y se marca para confirmación |
| 3 | El documento original (rango 2) reporta "el grep marcó 38 flows con coincidencias" (fecha de evaluación anterior a Sprint 1); el Manual (rango 3, 2026-07-22) reporta 47 candidatos con comparación contra Partial. Son conteos de candidatos de dos análisis distintos, no la misma lista. | Documento original (rango 2) vs. Manual (rango 3) | Manual (rango 3) prevalece por ser más reciente y más sistemático (incluye comparación local/Partial por componente) | El universo de trabajo para Sprint 2 debe partir de los 47 candidatos del Manual, complementado con los nombres explícitos del documento original que no aparezcan en esa lista (ver hallazgo #2) |
| 4 | Ni el documento original (rango 2) ni el Manual (rango 3) contienen en ningún punto la cifra "~20 Flows" ni "~16 LWC/Aura" de forma literal. | Luis (rango 1) vs. documento original (rango 2) y Manual (rango 3) | Luis (rango 1) prevalece por definición — es la fuente de mayor rango | No es un error ni una contradicción resoluble por sustitución: es información que **solo existe en la comunicación directa de Luis** y no puede verificarse contra ningún documento del repositorio. Debe tratarse como una estimación/curación propia de Luis sobre el universo de candidatos de rango 2/3, no como una cifra documentada en otra parte |

## Información que no debe utilizarse

- El conteo "38 flows" del documento original (rango 2) **no debe tratarse como lista cerrada** — el propio documento aclara que son solo ejemplos de un grupo mayor no inspeccionado.
- Los conteos "(47)" y "(28 archivos / 22 componentes)" del Manual (rango 3) **no deben tratarse como alcance confirmado de Sprint 2** — el propio Manual los define como "candidatos", con clasificación final pendiente.
- La comparación "RedPartial: identical/different/missing_in_compare" del Manual tiene fecha 2026-07-22 y **no debe tratarse como estado actual** de Partial — han pasado 6 días y hubo actividad de Sprint 1 en ese lapso.
- Ningún documento de rango 6 (interno, generado por Code/Codex) debe usarse para agregar, quitar o mover componentes de Sprint 2 — todos son evidencia secundaria.
- No existe ningún documento en este repositorio que autorice fecha de inicio, deploy o ejecución de Sprint 2 — todo lo encontrado es inventario técnico, no autorización de trabajo.
