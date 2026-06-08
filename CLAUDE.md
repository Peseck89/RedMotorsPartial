# RedMotors - AI Working Context

## Purpose

This repository contains Salesforce metadata and code for RedMotors.

This file is the shared working context for AI tools such as Cowork, Codex, Claude Code and ChatGPT.

The goal is to let any AI tool understand the repo workflow without requiring the user to explain the same context repeatedly.

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

## SEGURIDAD BLOQUEANTE - AUTENTICACION HELIOS/SOFTLAND

RedMotorsSandbox contiene temporalmente autenticacion sensible en codigo para Helios/Softland.

Antes de hacer retrieve, modificar, agregar a staging, commit o push de cualquiera de estos componentes, detenerse y revisar/sanitizar el codigo:

- `ExternalAuthService`
- `SoftlandEndpointService`
- `SolicitudAprobacionTesoreria`

Reglas obligatorias:

- Nunca versionar `clientId`, `clientSecret`, `password`, `access_token` ni valores equivalentes.
- Nunca imprimir tokens en `System.debug` o logs.
- La implementacion sensible completa solo debe consultarse directamente en RedMotorsSandbox por usuarios autorizados.
- No recuperar estas clases desde Sandbox y agregarlas automaticamente a Git.
- Si un retrieve modifica estas clases, detenerse y revisar antes de continuar.

Pendiente recomendado:

- Habilitar endpoint HTTPS.
- Migrar a Named Credential/External Credential.
- Rotar la credencial actual.
- Despues versionar una implementacion segura.

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
