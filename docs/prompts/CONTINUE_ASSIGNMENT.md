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
→ 2. Continuar asignación activa
→ RedMotors

DevLaunchpad will read `docs/asignaciones/ACTIVE_ASSIGNMENT.md` when it exists. If it can extract `Expected branch`, option 2 allows that expected feature branch when Git is clean and synchronized. If it cannot extract the branch, it runs continuation mode without `ExpectedBranch`, which allows `feature/*` or `main` only with a warning to validate the branch in ChatGPT before touching code.

DevLaunchpad must only continue to energy/app startup after `start-work.ps1` reports `LISTO PARA RECIBIR ASIGNACION` or `LISTO - CONTINUAR ASIGNACION`. If it reports `NO COMENZAR TODAVIA`, or if the status is unclear, treat the environment as not validated. Energy mode does not mean the environment is validated.

Then ask them to paste the launcher result only if:
- it does not say LISTO
- it shows Git dirty
- it shows ahead/behind
- Salesforce target-org is wrong
- Salesforce auth is expired
- context files are missing
- it shows warnings that need branch or org confirmation

If launcher says LISTO, continue with the assignment after reviewing any warnings.

## Workspace shortcuts

After RedMotors is validated as LISTO, DevLaunchpad can open a Windows workspace from a `.lnk` desktop shortcut instead of opening individual apps one by one.

On PC, use the `Salesforce Dev PC` workspace. DevLaunchpad must look for `Salesforce Dev PC.lnk` in:
- `[Environment]::GetFolderPath("Desktop")`
- `$env:USERPROFILE\OneDrive\Escritorio`
- `$env:PUBLIC\Desktop`

On Laptop, use only the `Salesforce Dev Laptop con Monitores` workspace. DevLaunchpad must look for `Salesforce Dev Laptop con Monitores.lnk` in:
- `[Environment]::GetFolderPath("Desktop")`
- `$env:USERPROFILE\OneDrive\Escritorio`
- `$env:PUBLIC\Desktop`

DevLaunchpad must not open `Dev Launchpad.lnk` or `Iniciar Trabajo.lnk` from inside DevLaunchpad, because those shortcuts belong to the launcher itself.

If the selected workspace shortcut does not exist, DevLaunchpad should show a clear warning and continue without blocking the flow.

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

## Energy mode guidance

DevLaunchpad applies energy mode automatically when starting or continuing RedMotors work:

- Laptop connected to power or charging: WorkPlugged.
- Laptop on battery: MobileBattery.

On PC, DevLaunchpad does not apply automatic energy changes. It leaves the manual energy menu available.

If the user says they are connected to power for Codex, Claude, deploys or long-running processes, ChatGPT can remind them that DevLaunchpad will apply the connected-work energy mode automatically when they start or continue work.

The manual menu remains available for review or manual changes:

DevLaunchpad
→ Modo energia

If the user wants to verify current energy settings, use:

DevLaunchpad
→ Modo energia
→ Ver estado de energia

If the user specifically asks to apply a mode manually, use the same menu and choose Trabajo conectado a corriente or Movil / bateria as appropriate.

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

## Pause / switch device

When the user says:
- “voy a salir”
- “sigo en la laptop”
- “cambio de equipo”
- “pausamos y continuo luego”

Do not treat it as end-of-day close. Do not ask for weekly report data, assignment/activity/description, or start time.

Tell the user to run:

DevLaunchpad
→ 3. Pausar / cambiar de equipo
→ RedMotors

After the repo is ready on this machine, tell them to continue on the other machine with:

DevLaunchpad
→ 2. Continuar asignación activa
→ RedMotors

## End-of-day reminder

When the user says:
- “cerramos por hoy”
- “continuamos mañana”
- “dejamos aquí”

Do not ask the user to run manual `git add`, `git commit`, or `git push` for log closure if the automatic close is available.

Ask the user to run:

DevLaunchpad
→ Cerrar día / trabajo
→ RedMotors
→ Cierre automático seguro

The safe automatic close reads `docs/asignaciones/ACTIVE_ASSIGNMENT.md`, uses Git diagnostics and logs as defaults, updates `WORK_LOG.md` and `WEEKLY_REPORT_LOG.md`, then commits and pushes only those log files when the repo has no non-log pending changes.

If the automatic close blocks, ask the user to paste the summary in ChatGPT/Codex before closing VS Code, PowerShell or Salesforce.
