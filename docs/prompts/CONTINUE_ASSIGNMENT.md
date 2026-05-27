# Continue Assignment Protocol - RedMotors

## Purpose

Use this protocol when the user says:
- “vamos a continuar la asignación”
- “continuemos donde nos quedamos”
- “seguimos con RedMotors”
- “retomemos lo de ayer”

## Tool routing

Use:
- PowerShell for environment checks and launcher output.
- ChatGPT for assignment reasoning, decision making, summaries and messages.
- Codex for repo edits, diffs, scripts, commits and controlled implementation.
- Claude/Cowork for second opinion, long-code review or architecture risk review.

## First action

Ask the user to run from the desktop shortcut:

Iniciar Trabajo
→ 1. Trabajar en una asignación
→ RedMotors

Then ask them to paste the launcher result only if:
- it does not say LISTO PARA RECIBIR ASIGNACION
- it shows Git dirty
- it shows ahead/behind
- Salesforce target-org is wrong
- Salesforce auth is expired
- context files are missing

If launcher says LISTO PARA RECIBIR ASIGNACION, continue with the assignment.

## Context files to review

Before making a plan, read or ask Codex/ChatGPT to review:

1. AI_HANDOFF.md
2. WORK_LOG.md
3. WEEKLY_REPORT_LOG.md
4. docs/asignaciones/ if there is an assignment-specific file
5. CLAUDE.md if protocol rules are unclear

## Questions to answer before continuing

Determine:

- What assignment is active?
- What was completed last session?
- What is pending?
- Is there any blocker from Luis/business?
- Is implementation authorized or still discovery-only?
- What repo/branch should be used?
- Does the task require Sandbox only, Production, or no Salesforce action?
- Does the work require Codex, ChatGPT, Claude/Cowork or PowerShell?

## Safety checks

Do not continue if:

- repo is dirty and changes are not understood
- branch is not expected
- local branch is ahead/behind without review
- target-org is not RedMotorsSandbox for development
- there are force-app changes not reviewed
- user has not authorized code changes
- Production deploy/retrieve/destructive action is being considered without explicit confirmation

## Standard continuation response

When ready, provide:

1. Current assignment
2. Last known status
3. Pending items
4. Recommended next safe step
5. Where to do it:
   - ChatGPT
   - PowerShell
   - Codex
   - Claude/Cowork

## End-of-day reminder

When the user says:
- “cerramos por hoy”
- “continuamos mañana”
- “dejamos aquí”

Prepare:
- daily summary
- activity description for Luis
- status
- pending items
- recommended log entry

Then remind the user to run:

Iniciar Trabajo
→ 2. Cerrar trabajo / asignación
→ RedMotors

So WORK_LOG.md and WEEKLY_REPORT_LOG.md can be updated safely.
