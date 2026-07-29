# Contexto activo — Empresa / Marcas Chinas

**ALCANCE PRIMERO: ningún componente se trabaja solo por aparecer en documentos, Git o Partial. Requiere autorización explícita de Luis o Diego.**

Ver la regla completa, el orden de autoridad entre fuentes y la tabla de autorización vigente en [`REGLAS_ALCANCE_AUTORIZADO.md`](REGLAS_ALCANCE_AUTORIZADO.md). Esa regla es obligatoria para cualquier agente (Claude Code, Codex, Cowork, ChatGPT) que trabaje en este proyecto, en cualquier Sprint o worktree.

## Estado actual (2026-07-28)

- **Sprint 1 (33x3):** cerrado técnicamente en `feature/pc/redmotors-empresa-marcas-chinas-sprint1-20260724` (HEAD `bf1e260`). Clase 33 pendiente de confirmación de Luis. Ver `CIERRE_TECNICO_SPRINT1_33_CLASES_3_TRIGGERS_DRAFT.md`.
- **Sprint 2 (Flows/LWC/Aura):** en fase de inventario y control de alcance, worktree `RedMotors-Sprint2-Flows-Components`, rama `feature/pc/redmotors-empresa-marcas-chinas-sprint2-flows-components-20260728`. Ningún componente funcional modificado todavía.
- **Alcance de Sprint 2 al día de hoy (corregido 2026-07-28):** `rm_vu_inventario` (LWC) está **autorizado por nombre** por Luis, pero falta el cambio funcional exacto. La categoría "5 Flows de Pricebook" está autorizada por Luis, pero los 5 nombres propuestos (`Opportunity_Flow`, `Opp_flow_v4`, `BMW_ImportarPlantilla`, `BMW_Gestiona_Listas_de_Precios`, `Obtener_PricebookEntry_en_Linea_de_Plantilla_de_Presupuesto`) siguen **PENDIENTES DE VALIDACIÓN DOCUMENTAL nombre por nombre** (3 con vínculo explícito, 2 solo con coincidencia de nombre). Ningún componente está todavía "AUTORIZADO PARA IMPLEMENTACIÓN" en la tabla-puerta. Ver el detalle completo en `REGLAS_ALCANCE_AUTORIZADO.md`.

## Documentos clave de Sprint 2 (en orden de lectura recomendado)

1. `REGLAS_ALCANCE_AUTORIZADO.md` — regla de alcance obligatoria y tabla de autorización vigente.
2. `SPRINT2_FUENTES_AUTORITATIVAS.md` — clasificación de fuentes y orden de autoridad.
3. `INVENTARIO_SPRINT2_FLOWS_COMPONENTES.md` — inventario completo de candidatos documentados (no es alcance confirmado, ver regla de alcance).
4. `ESTADO_GIT_INICIO_SPRINT2.md` — estado de ramas y worktrees al inicio de Sprint 2.
5. `PLAN_EJECUCION_SPRINT2.md` — plan de lotes por patrón funcional (su vigencia operativa quedó sustituida por la tabla de autorización de `REGLAS_ALCANCE_AUTORIZADO.md`).
6. `PROPUESTA_LIMPIEZA_DOCUMENTAL.md` — propuesta de limpieza de la documentación de Sprint 1, no ejecutada.

## Reglas generales del repositorio

Ver `CLAUDE.md` (raíz del repositorio) para el flujo de trabajo Git/rama/entorno, y `AGENTS.md` (raíz del repositorio) para el resumen de la regla de alcance obligatoria orientado a agentes de IA.
