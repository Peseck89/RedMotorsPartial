# Propuesta de limpieza documental — `docs/empresa-marcas-chinas`

## Estado del documento

**PROPUESTA. No ejecutada.** Ningún archivo fue movido, renombrado ni eliminado en esta sesión. Requiere revisión y aprobación antes de aplicarse.

## Resumen

38 documentos Markdown + 2 documentos originales (PDF, DOCX) inventariados. Ninguno se propone eliminar sin archivar primero. No se detectó ningún "análisis incorrecto" (contenido objetivamente erróneo) en esta revisión — la categoría se deja definida por si aparece en una revisión futura, pero no se usa aquí.

## Documentos que deben conservarse en su ubicación actual (activos, Sprint 1 en curso)

| Archivo | Razón concreta |
|---|---|
| `CIERRE_TECNICO_SPRINT1_33_CLASES_3_TRIGGERS_DRAFT.md` | Documento vigente del cierre 33x3 de Sprint 1, todavía en BORRADOR, clase 33 pendiente de Luis. Se sigue actualizando. |
| `BITACORA_IMPLEMENTACION.md` | Registro narrativo maestro de todos los bloques 1-21+ de Sprint 1, con IDs de commit, deploy y test run. Referenciado por múltiples documentos como fuente de evidencia. |
| `MATRIZ_TRAZABILIDAD_REQUERIMIENTOS_SPRINT1.md` | Matriz de trazabilidad de requerimientos, alto valor para auditoría de qué se completó y con qué evidencia. |
| `PLAN_IMPLEMENTACION_SPRINT1.md` | Documento de planificación original de los bloques de Sprint 1, todavía citado como fuente de las tablas de riesgo (p. ej. fila de `TrabajoQuoteController`). |
| `INVENTARIO_APEX_SPRINT1.md` | Inventario técnico de clases Apex de Sprint 1, base para el cierre 33x3. |
| `CIERRE_SPRINT1_44H.md` | Cierre técnico del presupuesto de 44 horas, con evidencia de bloques completados. |
| `DESFASE_GIT_PARTIAL_TEST_TRAFICO.md` | Documenta un desfase Git↔Partial todavía sin resolver (`RM_VN_CrearOportunidad_Ctrl` y su test) — activo mientras esa decisión siga pendiente. |
| `ANALISIS_QUOTE_EMPRESA_FACTURA.md` | Análisis de dependencia Quote↔empresa facturadora, referenciado desde el cierre de Bloque 10/19. |

## Documentos que deberían archivarse (siguen siendo evidencia técnica, pero su ciclo de trabajo activo terminó)

Se propone moverlos a una subcarpeta `docs/empresa-marcas-chinas/archivo-sprint1-bloques/` (no ejecutado, solo propuesta), conservando el historial de Git intacto (usar `git mv`, no borrar y recrear).

| Archivo | Razón concreta |
|---|---|
| `IMPLEMENTACION_BLOQUE1.md` … `IMPLEMENTACION_BLOQUE21_OPORTUNIDAD_UI.md` (21 archivos) | Cada uno documenta un bloque de Sprint 1 ya cerrado y desplegado según `BITACORA_IMPLEMENTACION.md`. Siguen siendo evidencia técnica válida, pero ya no son de consulta activa para el trabajo diario — su información resumida ya vive en `BITACORA_IMPLEMENTACION.md` y `MATRIZ_TRAZABILIDAD_REQUERIMIENTOS_SPRINT1.md`. |
| `IMPLEMENTACION_SIGUIENTE_LOTE_8_SPRINT1.md` | Evidencia del lote "next8" de reconciliación Apex, ya integrado en `feature/pc/redmotors-empresa-marcas-chinas-sprint1-20260724` (commit `c320138`). Ciclo de trabajo cerrado. |
| `IMPLEMENTACION_VALIDACION33_LOTE1_CAMBIO_UBICACION.md` … `LOTE5_CREAR_SC_QUOTE.md` (5 archivos) | Evidencia de los lotes de validación 33x3, ya consolidados en `CIERRE_TECNICO_SPRINT1_33_CLASES_3_TRIGGERS_DRAFT.md`, que los cita explícitamente como fuente. Mantener como respaldo, no como referencia primaria. |
| `LABORATORIO_COBERTURA_BLOQUE18.md` | Laboratorio de cobertura de un bloque ya cerrado (Bloque 18); su resultado ya está resumido en `BITACORA_IMPLEMENTACION.md`. |
| `PENDIENTES_DECISION_BLOQUE20.md` | Documento de 17 líneas sobre decisiones pendientes de un bloque ya cerrado; verificar si las preguntas siguen abiertas antes de archivar (ver nota abajo). |

**Nota sobre `PENDIENTES_DECISION_BLOQUE20.md`:** antes de archivar, confirmar con Luis/Diego si las preguntas que contiene ya se resolvieron. Si siguen abiertas, no archivar — moverlas como ítems pendientes al nuevo `PLAN_EJECUCION_SPRINT2.md` o a un documento de pendientes activo, y solo entonces archivar el original.

## Documentos generados todavía útiles como contexto general (no exclusivos de un bloque)

| Archivo | Razón concreta |
|---|---|
| `CONTEXTO_CODEX_EMPRESA_MARCAS_CHINAS.md` | Documento de contexto general del proyecto (58 líneas), fecha 2026-07-24 — el más antiguo de la carpeta. Sigue siendo útil como onboarding rápido, pero debe revisarse si algo quedó desactualizado tras 4 días de trabajo intenso de Sprint 1. No se detectó contenido incorrecto, solo posible desactualización parcial — no se propone archivar todavía. |

## Temporales que pueden eliminarse

Ninguno dentro de `docs/empresa-marcas-chinas` — todos los `.md` de esta carpeta son documentación sustantiva, no temporales. Los temporales reales de este proyecto (`tmp-partial-33x3/`, `tmp-partial-batch-helper/`, `test-results/`) viven **fuera** de `docs/` y se tratan en `ESTADO_GIT_INICIO_SPRINT2.md`, no aquí.

## Documentos incorrectos que deben marcarse como superados

Ninguno detectado en esta revisión. No se encontró contenido que contradiga hechos verificados o que haya sido invalidado por trabajo posterior — solo información que quedó *desactualizada por avance natural del proyecto* (tratada arriba como "archivar", no como "incorrecta").

## Duplicados

No se detectaron duplicados exactos. Existe **solapamiento parcial de contenido** (no duplicado) entre `BITACORA_IMPLEMENTACION.md` (narrativa cronológica de todos los bloques) y los 21 `IMPLEMENTACION_BLOQUEN_*.md` individuales (detalle técnico por bloque) — es una relación resumen↔detalle intencional, no una duplicación a resolver.

## Documentos originales (no Markdown, no se tocan)

| Archivo | Razón |
|---|---|
| `DEV Evaluación - Alcance - Inclusión de nueva Empresa- Marchas chinas Redmotors.docx.pdf` | Fuente autoritativa de rango 2. Se conserva intacta, sin conversión ni edición. |
| `Manual_Analisis_Empresa_RedMotors_2026-07-22.docx` | Fuente autoritativa de rango 3. Se conserva intacta, sin conversión ni edición. |

## No ejecutar hasta recibir revisión

Esta propuesta no se ejecuta en esta sesión. Ninguna de las acciones anteriores (archivar, mover, marcar como superado) se realizó. Se requiere confirmación explícita antes de aplicar cualquiera de ellas.
