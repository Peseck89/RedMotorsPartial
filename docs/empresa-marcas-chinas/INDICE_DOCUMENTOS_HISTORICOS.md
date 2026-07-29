# Índice de documentos históricos — Empresa / Marcas Chinas

## Propósito de este índice

Este documento existe para que ningún agente (Claude Code, Codex, Cowork, ChatGPT) necesite leer recursivamente `docs/empresa-marcas-chinas` para saber qué hay ahí. Es el mapa completo. La regla de carga de contexto (`README_CONTEXTO_ACTIVO.md`, `AGENTS.md`, `CLAUDE.md`) dice que el punto de partida es `README_CONTEXTO_ACTIVO.md`, no este índice — este índice se consulta **solo** cuando se necesita entender o citar una dependencia histórica puntual de Sprint 1.

**No se movió, renombró ni eliminó ningún documento rastreado para crear este índice.**

**Advertencia general, aplica a todo lo clasificado como histórico en este documento:** ningún documento histórico define alcance de Sprint 2. Ninguno debe usarse para agregar, quitar o reinterpretar componentes de Sprint 2. Ver `REGLAS_ALCANCE_AUTORIZADO.md`.

## Documentación activa (no histórica — fuera del alcance de este índice, ver `README_CONTEXTO_ACTIVO.md`)

`REGLAS_ALCANCE_AUTORIZADO.md`, `SPRINT2_FUENTES_AUTORITATIVAS.md`, `INVENTARIO_SPRINT2_FLOWS_COMPONENTES.md`, `PLAN_EJECUCION_SPRINT2.md`, `README_CONTEXTO_ACTIVO.md`, `ESTADO_GIT_INICIO_SPRINT2.md`, `PROPUESTA_LIMPIEZA_DOCUMENTAL.md`, `INDICE_DOCUMENTOS_HISTORICOS.md` (este archivo), y los dos documentos originales (`DEV Evaluación...pdf`, `Manual_Analisis_Empresa_RedMotors_2026-07-22.docx`).

## Categoría: Sprint 1 cerrado (cierre general, contexto y trazabilidad)

| Archivo | Propósito | Estado | ¿Se puede consultar? | Advertencia | Reemplazo activo |
|---|---|---|---|---|---|
| `CIERRE_TECNICO_SPRINT1_33_CLASES_3_TRIGGERS_DRAFT.md` | Cierre técnico del alcance 33 clases + 3 triggers de Sprint 1; clase 33 pendiente de Luis | Vigente como cierre de Sprint 1, no como fuente de Sprint 2 | Sí, para dependencias de Sprint 1 (p. ej. `WorkOrderTrigger`, `BatchGetCatalogoSoftland`) | No usar para definir alcance de Sprint 2 | Ninguno — es el cierre de Sprint 1 |
| `CIERRE_SPRINT1_44H.md` | Cierre del presupuesto de 44 horas de Sprint 1 | Cerrado | Sí, como evidencia histórica | No usar para definir alcance de Sprint 2 | Ninguno |
| `MATRIZ_TRAZABILIDAD_REQUERIMIENTOS_SPRINT1.md` | Matriz de trazabilidad de requerimientos de Sprint 1 | Cerrado | Sí, para auditoría de qué se completó en Sprint 1 | No usar para definir alcance de Sprint 2 | Ninguno |
| `PLAN_IMPLEMENTACION_SPRINT1.md` | Plan original de bloques de Sprint 1, incluye tablas de riesgo por clase | Cerrado | Sí, citado ocasionalmente (p. ej. fila de `TrabajoQuoteController`) | No usar para definir alcance de Sprint 2 | Ninguno |
| `BITACORA_IMPLEMENTACION.md` | Registro narrativo maestro de todos los bloques de Sprint 1, con IDs de commit/deploy/test | Cerrado, referenciado por otros documentos | Sí, como evidencia de qué se hizo y cuándo en Sprint 1 | No usar para definir alcance de Sprint 2 | Ninguno |
| `CONTEXTO_CODEX_EMPRESA_MARCAS_CHINAS.md` | Contexto general del proyecto, el documento más antiguo de la carpeta (2026-07-24) | Posiblemente desactualizado parcialmente, no marcado incorrecto | Sí, como contexto general de fondo | No usar para definir alcance de Sprint 2 | `README_CONTEXTO_ACTIVO.md` para el estado vigente |
| `ANALISIS_QUOTE_EMPRESA_FACTURA.md` | Análisis de dependencia Quote↔empresa facturadora (Sprint 1) | Cerrado | Sí, como evidencia técnica de Sprint 1 | No usar para definir alcance de Sprint 2 | Ninguno |
| `PENDIENTES_DECISION_BLOQUE20.md` | Preguntas pendientes de decisión del Bloque 20 (Sprint 1) | Verificar si sigue abierto antes de archivar (ver `PROPUESTA_LIMPIEZA_DOCUMENTAL.md`) | Sí | No usar para definir alcance de Sprint 2 | Ninguno |

## Categoría: Implementación por bloques (Sprint 1, 21 documentos)

Todos con el mismo propósito general (documentar la implementación técnica de un bloque específico de Sprint 1, ya cerrado según `BITACORA_IMPLEMENTACION.md`), el mismo estado, y la misma advertencia. Se listan juntos para no repetir 21 filas idénticas.

| Archivos | Propósito | Estado | ¿Se puede consultar? | Advertencia | Reemplazo activo |
|---|---|---|---|---|---|
| `IMPLEMENTACION_BLOQUE1.md`, `IMPLEMENTACION_BLOQUE2_PRICEBOOK.md`, `IMPLEMENTACION_BLOQUE3_SCHEDULER.md`, `IMPLEMENTACION_BLOQUE4_WORKORDER.md`, `IMPLEMENTACION_BLOQUE5_GARANTIA.md`, `IMPLEMENTACION_BLOQUE6_OPPORTUNITY_EMPRESA.md`, `IMPLEMENTACION_BLOQUE7_CREAR_PLAN_VENTA.md`, `IMPLEMENTACION_BLOQUE8_OPPORTUNITY_PERMISSIONS.md`, `IMPLEMENTACION_BLOQUE9_LINEA_PLANTILLA_EMPRESA.md`, `IMPLEMENTACION_BLOQUE10_BUSQUEDA_DETALLADA.md`, `IMPLEMENTACION_BLOQUE11_QUOTE_USD_PDF.md`, `IMPLEMENTACION_BLOQUE12_QUOTE_CRC_PDF.md`, `IMPLEMENTACION_BLOQUE13_TRABAJO_QUOTE.md`, `IMPLEMENTACION_BLOQUE14_TRABAJO_WORKORDER.md`, `IMPLEMENTACION_BLOQUE15_VIN_SCAN_TRABAJOS.md`, `IMPLEMENTACION_BLOQUE16_QUOTER.md`, `IMPLEMENTACION_BLOQUE17_PRODUCT2_RECORDTYPES.md`, `IMPLEMENTACION_BLOQUE18_PRODUCT_SEARCHER.md`, `IMPLEMENTACION_BLOQUE19_MODELO_INTERES.md`, `IMPLEMENTACION_BLOQUE20_LEAD_PEKING.md`, `IMPLEMENTACION_BLOQUE21_OPORTUNIDAD_UI.md` | Detalle técnico de implementación de un bloque específico de Sprint 1 (uno por archivo) | Cerrado, ya desplegado y documentado en `BITACORA_IMPLEMENTACION.md` | Sí, individualmente, solo cuando se necesite el detalle de ese bloque específico | No usar ninguno de estos para definir alcance de Sprint 2. **Excepción puntual:** `IMPLEMENTACION_BLOQUE10_BUSQUEDA_DETALLADA.md` es referencia directa para el Lote 5 (congelado) de `PLAN_EJECUCION_SPRINT2.md` porque `busquedaDetallada` fue parcialmente tocado en ese bloque (solo Apex, no JS) | `BITACORA_IMPLEMENTACION.md` (resumen) y `MATRIZ_TRAZABILIDAD_REQUERIMIENTOS_SPRINT1.md` (trazabilidad) |

## Categoría: Reconciliación 33x3 (Sprint 1, cierre de clases/triggers)

| Archivo | Propósito | Estado | ¿Se puede consultar? | Advertencia | Reemplazo activo |
|---|---|---|---|---|---|
| `IMPLEMENTACION_SIGUIENTE_LOTE_8_SPRINT1.md` | Evidencia del lote "next8" de reconciliación Apex contra Partial | Ya integrado en la rama autoritativa (commit `c320138`) | Sí, como evidencia de ese commit | No usar para definir alcance de Sprint 2 | `CIERRE_TECNICO_SPRINT1_33_CLASES_3_TRIGGERS_DRAFT.md` |
| `IMPLEMENTACION_VALIDACION33_LOTE1_CAMBIO_UBICACION.md` | Validación de `RM_VN_CambiarUbicacion_Ctrl` (33x3) | Consolidado | Sí | No usar para definir alcance de Sprint 2 | `CIERRE_TECNICO_SPRINT1_33_CLASES_3_TRIGGERS_DRAFT.md` |
| `IMPLEMENTACION_VALIDACION33_LOTE2_CONS_DISP_BODEGA_QUOLI.md` | Validación de `ServicioConsDispBodegaQuoli` (33x3) | Consolidado | Sí | No usar para definir alcance de Sprint 2 | `CIERRE_TECNICO_SPRINT1_33_CLASES_3_TRIGGERS_DRAFT.md` |
| `IMPLEMENTACION_VALIDACION33_LOTE3_ELIMINAR_RESERVA_QUOTE.md` | Validación de `servicioEliminarReserva`/`ServicioEliminarReservaArticuloQuote` (33x3) | Consolidado | Sí | No usar para definir alcance de Sprint 2 | `CIERRE_TECNICO_SPRINT1_33_CLASES_3_TRIGGERS_DRAFT.md` |
| `IMPLEMENTACION_VALIDACION33_LOTE4_RESERVA_APARTADO_QUOTE.md` | Validación de `ServicioReservaApartadoArticulosQuote`/`servicioReservas` (33x3) | Consolidado | Sí | No usar para definir alcance de Sprint 2 | `CIERRE_TECNICO_SPRINT1_33_CLASES_3_TRIGGERS_DRAFT.md` |
| `IMPLEMENTACION_VALIDACION33_LOTE5_CREAR_SC_QUOTE.md` | Validación de `ServicioCrearSCQuote` (33x3) | Consolidado | Sí | No usar para definir alcance de Sprint 2 | `CIERRE_TECNICO_SPRINT1_33_CLASES_3_TRIGGERS_DRAFT.md` |

## Categoría: Pruebas y deploys

| Archivo | Propósito | Estado | ¿Se puede consultar? | Advertencia | Reemplazo activo |
|---|---|---|---|---|---|
| `LABORATORIO_COBERTURA_BLOQUE18.md` | Laboratorio de cobertura de test del Bloque 18 (`ProductSearcherController`) | Cerrado | Sí | No usar para definir alcance de Sprint 2 | `BITACORA_IMPLEMENTACION.md` |
| `DESFASE_GIT_PARTIAL_TEST_TRAFICO.md` | Documenta un desfase Git↔Partial sin resolver en `RM_VN_CrearOportunidad_Ctrl_Test`, con decisión explícita de no integrarlo | Activo mientras esa decisión no cambie — no es un cierre, es un desfase preservado a propósito | Sí, es evidencia técnica vigente, no puramente histórica | No usar para definir alcance de Sprint 2; no integrar el hotfix asociado sin resolver la sincronización que este documento describe | Ninguno — sigue siendo la fuente vigente de esa decisión |

## Categoría: Análisis superado

**Ninguno.** La revisión documental de `PROPUESTA_LIMPIEZA_DOCUMENTAL.md` no encontró ningún documento con contenido objetivamente incorrecto o invalidado por trabajo posterior — solo documentos desactualizados por avance natural del proyecto, ya clasificados arriba en sus categorías correspondientes.

## Categoría: Inventarios antiguos

| Archivo | Propósito | Estado | ¿Se puede consultar? | Advertencia | Reemplazo activo |
|---|---|---|---|---|---|
| `INVENTARIO_APEX_SPRINT1.md` | Inventario técnico de clases Apex de Sprint 1 (619 líneas), base para el cierre 33x3 | Cerrado, específico de Apex de Sprint 1 | Sí, como evidencia de qué Apex se inventarió en Sprint 1 | No usar para definir alcance de Sprint 2 (Sprint 2 es Flows/LWC/Aura, no Apex) | `CIERRE_TECNICO_SPRINT1_33_CLASES_3_TRIGGERS_DRAFT.md` para el estado final de Apex de Sprint 1; `INVENTARIO_SPRINT2_FLOWS_COMPONENTES.md` para el inventario vigente de Sprint 2 |

## Resumen numérico

- Documentación activa: 8 archivos Markdown (incluido este índice) + 2 documentos originales.
- Sprint 1 cerrado (general): 8 archivos.
- Implementación por bloques: 21 archivos.
- Reconciliación 33x3: 6 archivos.
- Pruebas y deploys: 2 archivos.
- Análisis superado: 0 archivos.
- Inventarios antiguos: 1 archivo.
- **Total clasificado:** 46 archivos Markdown + 2 documentos originales = 48 — coincide con el total existente en `docs/empresa-marcas-chinas` verificado en esta sesión (después de crear este índice). Ninguno quedó sin clasificar.
