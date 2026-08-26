# AGENTS.md — RedMotors

This file provides working instructions for AI coding agents (Claude Code, Codex, Cowork, ChatGPT, or any other agent) operating in this repository. See `CLAUDE.md` for the general Git/branch/environment workflow. This file adds a scope rule that overrides default agent behavior for the Empresa / Marcas Chinas project.

## MANDATORY SCOPE RULE — Empresa / Marcas Chinas (effective 2026-07-28)

**Only work on a component that is explicitly authorized by Luis or Diego.** A component's presence in documents, the Manual, this repository, Partial, inventories, dependency scans, or prior analysis by Code/Codex does **not** make it in-scope.

Full rule, the authorization gate table, and the current authorized list live in:

`docs/empresa-marcas-chinas/REGLAS_ALCANCE_AUTORIZADO.md`

Every agent working on Empresa / Marcas Chinas must read that file before analyzing, modifying, testing, or deploying any component. Key points:

- Discovering more components than requested is not a reason to expand scope — log them as "candidatos fuera del alcance confirmado" and stop.
- Approximate counts from Luis/Diego (e.g. "~20 Flows") never authorize picking repository items to fill the number.
- Every component must be classified as one of: **AUTORIZADO**, **PENDIENTE DE CONFIRMACIÓN**, **FUERA DE ALCANCE**, or **DEPENDENCIA TÉCNICA**. Only AUTORIZADO may reach implementation.
- Never infer that a related component, a whole documentation section, or a Partial implementation defines the requirement.
- Before touching any component, a gate table must exist with: exact API name, authorizing source, exact requirement text, Sprint, AUTORIZADO status, and requested change. Missing any field means the component stays PENDIENTE DE CONFIRMACIÓN.
- Authority order on conflicting sources: (1) latest direct instruction from Luis/Diego, (2) Luis's scope table, (3) client's original scope document, (4) development Manual, (5) Partial metadata, (6) internal Code/Codex documents. A lower-ranked source never expands or overrides a higher one.
- Agents (Code/Codex included) may search, compare, detect dependencies, and propose questions — they may never add Sprint elements, change quantities, pick ambiguous components, reinterpret estimates, or convert a candidate into authorized work.
- When scope is inconclusive for a given element: keep working on already-authorized elements, document the doubt, prepare a concrete question, and do not implement the doubtful element.

This rule applies to the whole Empresa / Marcas Chinas project, across every Sprint and every worktree, starting 2026-07-28.

## MANDATORY CONTEXT-LOADING RULE (effective 2026-07-28)

**Agents must not recursively read every document in `docs/empresa-marcas-chinas`.** Start only with `docs/empresa-marcas-chinas/README_CONTEXTO_ACTIVO.md`, then open only the files it explicitly lists as active for the current Sprint. Do not open historical Sprint 1 block-by-block documents, closure reports, or old inventories unless a currently-active document explicitly points to one to resolve a dependency.

Active context for Sprint 2 (nothing else, unless a listed file points to it):

1. `docs/empresa-marcas-chinas/REGLAS_ALCANCE_AUTORIZADO.md`
2. `docs/empresa-marcas-chinas/SPRINT2_FUENTES_AUTORITATIVAS.md`
3. `docs/empresa-marcas-chinas/INVENTARIO_SPRINT2_FLOWS_COMPONENTES.md`
4. `docs/empresa-marcas-chinas/PLAN_EJECUCION_SPRINT2.md`
5. The client's original scope document (PDF).
6. The development Manual (DOCX) — only the sections already cited by the active documents above, not read wholesale.
7. Direct answers from Luis and Diego.

Sprint 1's closure documentation stays available strictly as a reference when resolving a Sprint 1 dependency — never as a starting point for Sprint 2 work. See `docs/empresa-marcas-chinas/INDICE_DOCUMENTOS_HISTORICOS.md` for the full historical document index and its usage warnings.

## RedMotors Go-Live 29-08-2026 — obligatorio

Para cualquier tarea relacionada con PEKING/OMODA/JAECOO, Jerarquización, Copado, QA o Producción del pase del 29-08-2026, leer primero `docs/empresa-marcas-chinas/go-live-20260829/README_AUTORITATIVO.md` y seguir `docs/empresa-marcas-chinas/go-live-20260829/AGENT_PRECHECK.md`. No modificar Producción basándose en memoria del agente. Si una fuente no está disponible o hay contradicción que afecte el pase, detener la mutación y reportarla. No des-fusionar componentes compartidos entre Marcas Chinas y Jerarquización.
