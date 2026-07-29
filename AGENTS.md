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
