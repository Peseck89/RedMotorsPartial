# Contexto activo — Empresa / Marcas Chinas

**ALCANCE PRIMERO: ningún componente se trabaja solo por aparecer en documentos, Git o Partial. Requiere autorización explícita de Luis o Diego.**

Ver la regla completa, el orden de autoridad entre fuentes y la tabla de autorización vigente en [`REGLAS_ALCANCE_AUTORIZADO.md`](REGLAS_ALCANCE_AUTORIZADO.md). Esa regla es obligatoria para cualquier agente (Claude Code, Codex, Cowork, ChatGPT) que trabaje en este proyecto, en cualquier Sprint o worktree.

## REGLA DE CARGA DE CONTEXTO (obligatoria, vigente desde 2026-07-28)

**Los agentes no deben leer recursivamente todos los documentos de `docs/empresa-marcas-chinas`.** Deben comenzar únicamente por este archivo (`README_CONTEXTO_ACTIVO.md`) y abrir después solo los archivos expresamente listados abajo como contexto activo del Sprint en curso. No abrir documentos históricos de Sprint 1 (bloques, reconciliación 33x3, cierres, inventarios antiguos) salvo que un documento activo remita expresamente a uno de ellos para resolver una dependencia puntual.

## Contexto activo del Sprint 2 (única lista válida — nada más)

1. [`REGLAS_ALCANCE_AUTORIZADO.md`](REGLAS_ALCANCE_AUTORIZADO.md)
2. [`SPRINT2_FUENTES_AUTORITATIVAS.md`](SPRINT2_FUENTES_AUTORITATIVAS.md)
3. [`INVENTARIO_SPRINT2_FLOWS_COMPONENTES.md`](INVENTARIO_SPRINT2_FLOWS_COMPONENTES.md)
4. [`PLAN_EJECUCION_SPRINT2.md`](PLAN_EJECUCION_SPRINT2.md)
5. El documento original de alcance del cliente (`DEV Evaluación - Alcance - Inclusión de nueva Empresa- Marchas chinas Redmotors.docx.pdf`).
6. El Manual de desarrollo (`Manual_Analisis_Empresa_RedMotors_2026-07-22.docx`) — **solo las secciones ya citadas** por los documentos activos de arriba, no lectura completa.
7. Respuestas directas de Luis y Diego (no son un archivo — viven en la conversación de trabajo activa).

El cierre de Sprint 1 (`CIERRE_TECNICO_SPRINT1_33_CLASES_3_TRIGGERS_DRAFT.md` y todo lo indexado en [`INDICE_DOCUMENTOS_HISTORICOS.md`](INDICE_DOCUMENTOS_HISTORICOS.md)) queda disponible **solo como referencia** cuando se consulte una dependencia de ese Sprint — nunca como punto de partida para trabajo de Sprint 2.

## Estado actual (2026-07-28)

- **Sprint 1 (33x3):** cerrado técnicamente en `feature/pc/redmotors-empresa-marcas-chinas-sprint1-20260724` (HEAD `bf1e260`). Clase 33 pendiente de confirmación de Luis.
- **Sprint 2 (Flows/LWC/Aura):** worktree `RedMotors-Sprint2-Flows-Components`, rama `feature/pc/redmotors-empresa-marcas-chinas-sprint2-flows-components-20260728`. Ningún componente funcional modificado todavía.
- **Alcance de Sprint 2 al día de hoy:** `Opportunity_Flow`, `Opp_flow_v4`, `BMW_ImportarPlantilla` → **AUTORIZADO PARA IMPLEMENTACIÓN** (bloqueados por dato de negocio faltante, ver tabla-puerta). `rm_vu_inventario` → **AUTORIZADO EN ALCANCE / CAMBIO FUNCIONAL PENDIENTE**. `BMW_Gestiona_Listas_de_Precios`, `Obtener_PricebookEntry_en_Linea_de_Plantilla_de_Presupuesto` → **PENDIENTE DE CONFIRMACIÓN**. Detalle completo en `REGLAS_ALCANCE_AUTORIZADO.md`.

## Documentos de control (no forman parte del contexto activo de lectura por defecto)

- `ESTADO_GIT_INICIO_SPRINT2.md` — estado de ramas y worktrees.
- `PROPUESTA_LIMPIEZA_DOCUMENTAL.md` — propuesta de limpieza de Sprint 1, no ejecutada.
- `INDICE_DOCUMENTOS_HISTORICOS.md` — índice y advertencias de uso de todo lo histórico de Sprint 1.

## Reglas generales del repositorio

Ver `CLAUDE.md` (raíz del repositorio) para el flujo de trabajo Git/rama/entorno, y `AGENTS.md` (raíz del repositorio) para el resumen de la regla de alcance obligatoria y la regla de carga de contexto orientadas a agentes de IA.
