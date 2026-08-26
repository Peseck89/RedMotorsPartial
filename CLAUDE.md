# RedMotors - AI Working Context

## Purpose

This repository contains Salesforce metadata and code for RedMotors.

This file is the shared working context for AI tools such as Cowork, Codex, Claude Code and ChatGPT.

The goal is to let any AI tool understand the repo workflow without requiring the user to explain the same context repeatedly.

## MANDATORY SCOPE RULE — Empresa / Marcas Chinas (effective 2026-07-28)

**Only work on a component that is explicitly authorized by Luis or Diego.** A component's presence in documents, the Manual, this repository, Partial, inventories, dependency scans, or prior analysis by Code/Codex does **not** make it in-scope. Do not expand scope from discovery, do not use approximate counts ("~20 Flows", "~16 components") to pick items freely, and never treat a documented candidate as authorized work.

Full rule, authority order between sources, and the current authorization gate table live in `docs/empresa-marcas-chinas/REGLAS_ALCANCE_AUTORIZADO.md` and `AGENTS.md`. Read them before analyzing, modifying, testing, or deploying anything in the Empresa / Marcas Chinas project. This rule applies across every Sprint and every worktree.

## MANDATORY CONTEXT-LOADING RULE (effective 2026-07-28)

Agents must not recursively read every document in `docs/empresa-marcas-chinas`. Start only with `docs/empresa-marcas-chinas/README_CONTEXTO_ACTIVO.md`, then open only the files it lists as active for the current Sprint. Historical Sprint 1 documents are reference-only for resolving a Sprint 1 dependency, never a starting point for new work. See `AGENTS.md` for the full active-context list and `docs/empresa-marcas-chinas/INDICE_DOCUMENTOS_HISTORICOS.md` for the historical index.

## Core rules

- Always confirm the repository before working: RedMotors or Altica.
- Always confirm the device before working: Laptop or PC.
- Always confirm date, start time, assignment name, objective and source of instruction.
- Do not run destructive commands without explicit authorization.
- Do not run git reset, git clean, git rm, deploys or destructive changes without confirmation.
- Do not use git add . when there are massive changes, unreviewed files or CRLF/LF noise.
- Keep real work, cleanup, documentation and EOL normalization in separate branches.
- Branch names should identify the device when relevant: laptop or pc.
- Do not assume GitHub, Sandbox and Production are synchronized without checking.

## Startup checklist

Before starting work, run or ask the user to run:

- git status -sb
- git branch --show-current
- git remote -v
- git fetch
- git status -uno
- sf config list
- sf org list

Before editing files, confirm:

- Current branch
- Whether the repo is clean
- Whether the branch is ahead or behind origin
- Whether there are local changes
- Whether there are untracked files
- Active Salesforce alias
- Target Salesforce org
- Risk of mixing previous unfinished work

## Closing checklist

Before ending a session, run or ask the user to run:

- git status -sb
- git diff --stat
- git diff --name-only
- git log --oneline --decorate -5

The final handoff must include:

- Branch used
- Files modified
- Summary of changes
- Validations performed
- Pending work
- Risks
- Commit status
- Push status
- Final repo status

## Branch naming

Use clear branch names:

- backup/laptop/...
- backup/pc/...
- feature/laptop/...
- feature/pc/...
- cleanup/laptop/...
- cleanup/pc/...
- chore/laptop/...
- chore/pc/...
- docs/laptop/...
- docs/pc/...

## Salesforce aliases

Expected RedMotors aliases on Laptop:

- RedMotorsSandbox
- RedMotorsProd

For this repo, the local target-org should normally be RedMotorsSandbox.

## Weekly report

Track work for Luis using:

- Date
- Project
- Assignment
- Activity
- Description
- Start time
- End time
- Total time
- Status
- Notes

## Known Laptop state as of 2026-05-25

- main is clean and up to date with origin/main.
- RedMotorsSandbox is configured as local target-org.
- Laptop cleanup work was preserved in branch backup/laptop/redmotors-limpieza-clases-20260525.
- EOL rules were prepared in branch chore/laptop/redmotors-eol-config-20260525.
- Root junk cleanup was prepared in branch cleanup/laptop/redmotors-root-junk-20260525.
- LWC backup.js cleanup was prepared in branch cleanup/laptop/redmotors-lwc-backupjs-20260525.
- No destructive Salesforce deployment was performed for backup.js.

## Revisión de seguridad — Go-Live RedMotors 29-08-2026

Antes de revisar o recomendar cualquier cambio del pase PEKING/Jerarquización, leer `docs/empresa-marcas-chinas/go-live-20260829/README_AUTORITATIVO.md`, `docs/empresa-marcas-chinas/go-live-20260829/FUENTES_Y_PRECEDENCIA.md`, `docs/empresa-marcas-chinas/go-live-20260829/REGLAS_PRODUCCION.md` y `docs/empresa-marcas-chinas/go-live-20260829/CONTRADICCIONES_Y_GATES.md`. Claude actúa como auditor independiente de alcance, impacto, dependencias y seguridad productiva; no debe aceptar como verdad un inventario o veredicto generado por otro agente sin reconciliarlo con las fuentes originales y el estado live.
