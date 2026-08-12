# Estado consolidado de limpieza — laptop RedMotors (11 de agosto de 2026)

Resumen breve. El detalle completo de cada acción está en su propio documento dentro de esta misma carpeta
(`AUDITORIA_ALMACENAMIENTO_LAPTOP_20260811.md`, `PLAN_LIMPIEZA_LAPTOP_20260811.md`,
`EJECUCION_FASE_A_LIMPIEZA_20260811.md`, `EJECUCION_LIMPIEZA_FASE_B1_WORKTREES_20260811.md`,
`PRECHECK_FASE_C_LIMPIEZA_20260811.md`, `EJECUCION_RETIRO_NEXT8_RECONCILE_20260811.md`,
`ANALISIS_STASH_VN_RQ106_20260811.md`, `MATRIZ_STASH_VN_RQ106_20260811.csv`) — no se repite ese detalle aquí.

## Discrepancia sobre `RedMotors-Empresa-Marcas-Chinas` — resuelta

Codex reportó haberla retirado; una verificación de Code, en paralelo, la encontró todavía presente poco después.
Verificado ahora, en el momento de este documento: **la carpeta ya no existe**. Era una diferencia de momento de
ejecución entre ambas verificaciones, no una discrepancia real de resultado.

**`WORKTREE_ROTO_RETIRO_CONFIRMADO`.**

## Acciones de limpieza ejecutadas hasta ahora

| Acción | Espacio recuperado | Estado |
|---|---:|---|
| 18 worktrees históricos de RedMotors (retiro con `git worktree remove`) | 888.04 MiB (medido) | Completado |
| Fase A: duplicados VN-RQ106 en Drive, DOCX de Downloads, ZIP de auditoría | 858.519 MiB (medido) | Completado |
| `RedMotors-Sprint1-Next8-Reconcile` (retiro con `git worktree remove --force`, tras verificar que no había información única) | ≈43.2 MiB | Completado |
| `RedMotors-Empresa-Marcas-Chinas` (worktree roto, sin información única confirmada) | 44.108 MiB | Completado (confirmado en este documento) |
| **Total acumulado aproximado** | **≈1,833.87 MiB ≈ 1.79 GiB** | |

## Qué NO debe tocarse todavía

- `RedMotorsPartial-Sandbox` — repositorio/base común; solo consultas Git de solo lectura.
- `stash@{0}` de VN-RQ106 — confirmado intacto en este documento; sigue sin aplicar/pop/drop.
- `force-app/main/default/lwc/jsconfig.json` (en `RedMotorsPartial-Sandbox`) — confirmado con el mismo cambio de
  siempre (1 línea, no funcional); decisión de negocio pendiente, no de esta limpieza.
- Archivos recuperados (`Documents\Archivos perdidos (65660)`) — revisión humana pendiente, fuera de este alcance.
- Cachés (`.cache\codex-runtimes`, `.codex\.tmp`, etc.) — requieren aplicaciones cerradas y aprobación específica.
- Google Drive y OneDrive — no tocados, no se tocarán en este flujo de limpieza.
- Evidencia local de Marcas Chinas Sprint 3 (`Documents\Evidencias\RedMotors\Marcas Chinas\Sprint 3`) — se
  conserva localmente durante Sprint 4 por conveniencia operativa, aunque ya está respaldada en Drive.

## Estado Git verificado en este documento

- `git worktree list`: solo `RedMotorsPartial-Sandbox` y `RedMotors-Sprint2-Flows-Components` (worktree activo).
- Repo activo: limpio, HEAD `c248cee6f7622f4b440eb3ad2359444defeb61a6`, sincronización `0 0`.
