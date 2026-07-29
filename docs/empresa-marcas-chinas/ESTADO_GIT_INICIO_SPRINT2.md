# Estado de Git al inicio de Sprint 2 — Empresa / Marcas Chinas

## Estado del documento

Fotografía del estado de Git al momento de crear el worktree de Sprint 2 (2026-07-28). No se eliminó ni se modificó ninguna rama ni worktree en esta sesión.

## Rama base y HEAD

- **Rama autoritativa de Sprint 1:** `feature/pc/redmotors-empresa-marcas-chinas-sprint1-20260724`
- **Worktree de esa rama:** `C:\Users\dokur\Documents\Repositorios\RedMotors-Sprint1-Integracion`
- **HEAD confirmado antes de crear el worktree de Sprint 2:** `bf1e260e020a2873ab5c1388ddfb05723cd99e47` — limpio, sincronizado 0/0 con `origin`, sin carpetas temporales.

## Worktree y rama nuevos de Sprint 2

- **Worktree:** `C:\Users\dokur\Documents\Repositorios\RedMotors-Sprint2-Flows-Components`
- **Rama:** `feature/pc/redmotors-empresa-marcas-chinas-sprint2-flows-components-20260728`
- **Creada desde:** `bf1e260e020a2873ab5c1388ddfb05723cd99e47` (HEAD exacto de la rama base, confirmado antes de crear la rama)
- **Estado:** working tree limpio, sin commits propios todavía, sin push realizado.

## Worktrees existentes (20 al momento de este inventario)

| Worktree | Rama | HEAD corto | Rol |
|---|---|---|---|
| `RedMotors-Sprint1-Integracion` | `feature/pc/redmotors-empresa-marcas-chinas-sprint1-20260724` | `bf1e260` | **Rama autoritativa de Sprint 1** |
| `RedMotors-Sprint2-Flows-Components` | `feature/pc/redmotors-empresa-marcas-chinas-sprint2-flows-components-20260728` | `bf1e260` | **Nuevo — Sprint 2, recién creado, sin commits propios** |
| `RedMotors-Sprint1-Cierre-Autonomo` | `feature/pc/redmotors-sprint1-cierre-autonomo-20260728` | `bf1e260` | Histórica — ya fusionada por fast-forward en la rama autoritativa. No requiere más trabajo. |
| `RedMotors-Sprint1-Reconciliacion33` | `analysis/pc/redmotors-sprint1-reconcile-33x3-20260727` | `8d9e958` | Hilo de análisis paralelo, **no fusionado**, no autoritativo — no usar como fuente de código. |
| `RedMotors-Sprint1-Validacion33` | `feature/pc/redmotors-sprint1-complete-33x3-20260727` | `27a2213` | Hilo paralelo, **no fusionado** — no usar como fuente de código. |
| `RedMotors-Sprint1-Next8` | `feature/pc/redmotors-sprint1-next8-20260728` | `b4f5f47` | Hilo paralelo, **no fusionado** — superado por el trabajo ya integrado en la rama autoritativa. |
| `RedMotors-Sprint1-Next8-Reconcile` | `feature/pc/redmotors-sprint1-next8-reconcile-20260729` | `15c7033` | Hilo paralelo, **no fusionado**, diverge (ahead 1 / behind 3 de origin de la rama autoritativa) — requiere revisión antes de decidir su destino. |
| `RedMotors-Sprint1-Pendientes` | `analysis/pc/redmotors-empresa-marcas-chinas-sprint1-pendientes-20260726` | `3fa1b2d` | Análisis paralelo, **no fusionado**. |
| `RedMotors-Sprint1-Trazabilidad` | `analysis/pc/redmotors-empresa-marcas-chinas-sprint1-trazabilidad-20260726` | `3a91e5f` | Análisis paralelo, **no fusionado**. |
| `RedMotors-Sprint1-Cierre44H` | `analysis/pc/redmotors-empresa-marcas-chinas-sprint1-cierre44h-20260726` | `cd96fd9` | Análisis paralelo, **no fusionado**. |
| `RedMotors-Bloque10-BusquedaDetallada` | `feature/pc/redmotors-empresa-marcas-chinas-bloque10-busqueda-detallada-20260726` | `5e195d4` | **No fusionada** — caracteriza un bloqueo externo de Bloque 10, todavía relevante (citado en `DESFASE...` / inventario Sprint 2, componente `busquedaDetallada`). |
| `RedMotors-Bloque10-Cierre` | `feature/pc/redmotors-empresa-marcas-chinas-bloque10-cierre-20260726` | `254c35f` | Ya fusionada en la rama autoritativa — histórica. |
| `RedMotors-Bloque18-CoverageLab` | `analysis/pc/redmotors-block18-coverage-lab-20260726` | `37af27a` | Análisis paralelo — no verificado si está fusionada; tratar como histórica de bajo riesgo. |
| `RedMotors-Bloque19-ModeloInteres` | `feature/pc/redmotors-empresa-marcas-chinas-bloque19-modelo-interes-20260726` | `a993eee` | Ya fusionada — histórica. |
| `RedMotors-Bloque20-Discovery` | `analysis/pc/redmotors-empresa-marcas-chinas-bloque20-discovery-20260726` | `2e1c733` | Ya fusionada — histórica. |
| `RedMotors-Bloque20-LeadPeking` | `feature/pc/redmotors-empresa-marcas-chinas-bloque20-lead-peking-20260726` | `1d83228` | Ya fusionada — histórica. |
| `RedMotors-Bloque21-Oportunidad-UI` | `feature/pc/redmotors-empresa-marcas-chinas-bloque21-oportunidad-ui-20260726` | `67c180b` | Ya fusionada — histórica. |
| `RedMotors-QuoteEmpresaFactura` | `feature/pc/redmotors-empresa-marcas-chinas-quote-empresa-factura-20260726` | `aee6b41` | Ya fusionada — histórica. |
| `RedMotors-Hotfix-TestTrafico` | `fix/pc/redmotors-regression-traffic-test-20260726` | `5ecc127` | **No fusionada deliberadamente** — hotfix de `RM_VN_CrearOportunidad_Ctrl_Test` preservado sin integrar por decisión ya documentada (`DESFASE_GIT_PARTIAL_TEST_TRAFICO.md`). **No usar ni integrar sin resolver esa decisión primero.** |
| `RedMotorsPartial-Sandbox` | `feature/pc/redmotors-vn-rq106-anticipo-ui-20260527` | `3df187d` | Ajeno a Empresa/Marcas Chinas — proyecto/feature distinto, ya cerrado según su propio commit ("record production deployment closure"). No relevante para Sprint 2. |
| *(remoto, prunable)* `RedMotors-Empresa-Marcas-Chinas` | `wip/pc/redmotors-block18-product-searcher-coverage-20260726` | `5c287ba` | Worktree remoto marcado `prunable` por Git — candidato a limpieza técnica (`git worktree prune`), no ejecutado en esta sesión. |

## Ramas relevantes sin worktree propio (verificadas con `git merge-base --is-ancestor`)

| Rama | Estado respecto a la rama autoritativa |
|---|---|
| `backup/pc/redmotors-before-bloque*-20260725/20260726` (12 ramas) | Snapshots históricos "antes de" cada bloque de Sprint 1. Ninguna se verificó individualmente en esta sesión — por convención de nombre y fecha, son puntos de respaldo, no ramas de trabajo activo. |
| `backup/pc/redmotors-sprint1-blocks1-19-20260726`, `backup/pc/redmotors-sprint1-blocks1-20-20260726`, `backup/pc/redmotors-sprint1-final-44h-20260726` | Checkpoints de cierre de Sprint 1 (algunos con tag asociado, ver `git tag`). Históricos. |
| `wip/pc/redmotors-block7-plan-venta-20260725` | Trabajo en progreso histórico de un bloque ya cerrado (Bloque 7 aparece completado en `BITACORA_IMPLEMENTACION.md`). |
| Ramas `backup/laptop/*`, `chore/laptop/*`, `chore/pc/*`, `cleanup/laptop/*`, `docs/laptop/*` | Mantenimiento de entorno/laptop, **ajenas al proyecto Empresa/Marcas Chinas**. No tocar desde este hilo de trabajo. |
| `main` | Rama principal del repositorio, muy por detrás de todo el trabajo de Empresa/Marcas Chinas (HEAD en un commit de mantenimiento de laptop). No es la rama autoritativa de este proyecto. |

## Cuál es la rama autoritativa

**`feature/pc/redmotors-empresa-marcas-chinas-sprint1-20260724`**, en el worktree `RedMotors-Sprint1-Integracion`, HEAD `bf1e260`. Es la única rama que:
- Integra el cierre 33x3 de Sprint 1 completo (commits `6f8411d` y `bf1e260`, vía fast-forward).
- Está sincronizada 0/0 con `origin`.
- Es la base desde la que se creó la rama de Sprint 2.

`main` **no** es la rama autoritativa de este proyecto — está desactualizada y pertenece al flujo general del repositorio, no al proyecto Empresa/Marcas Chinas.

## Archivos temporales revisados

- `tmp-partial-33x3/`, `tmp-partial-batch-helper/`, `test-results/`: existieron en el worktree `RedMotors-Sprint1-Cierre-Autonomo` durante el cierre de Sprint 1, **nunca se incluyeron en ningún commit**, y no se copiaron al crear el worktree de Sprint 2 (el worktree se creó desde un commit de Git, no desde una copia de carpeta — los archivos sin rastrear de otro worktree no se propagan). Confirmado: `RedMotors-Sprint2-Flows-Components` no contiene ninguna de estas carpetas.
- Manifests de Sprint 1 (`manifest/sprint1-33x3-reconcile.xml`, `manifest/sprint1-batch-catalogo-helper-reconcile.xml`) ya están commiteados en la rama autoritativa — no son temporales, son evidencia permanente de Sprint 1. No se tocan desde Sprint 2.
- No se detectaron cambios EOL pendientes ni archivos sin rastrear en el worktree de Sprint 2 al momento de este inventario (`git status` limpio tras la creación).

## Propuesta de limpieza segura (no ejecutada)

| Acción | Candidatos | Riesgo |
|---|---|---|
| Archivar (no eliminar) worktrees de ramas ya fusionadas | `RedMotors-Sprint1-Cierre-Autonomo`, `RedMotors-Bloque10-Cierre`, `RedMotors-Bloque19-ModeloInteres`, `RedMotors-Bloque20-Discovery`, `RedMotors-Bloque20-LeadPeking`, `RedMotors-Bloque21-Oportunidad-UI`, `RedMotors-QuoteEmpresaFactura` | Bajo — verificado con `git merge-base --is-ancestor` que su contenido ya vive en la rama autoritativa |
| `git worktree prune` | Worktree remoto ya marcado `prunable` por Git (`wip/pc/redmotors-block18-product-searcher-coverage-20260726`) | Bajo — es una operación de limpieza de metadata de Git, no borra la rama |
| Revisión previa a decidir (no archivar todavía) | `RedMotors-Sprint1-Next8-Reconcile` (diverge: ahead 1 / behind 3) | Medio — contiene trabajo no integrado que debe evaluarse antes de descartar |
| Mantener preservadas sin integrar (decisión ya tomada) | `RedMotors-Hotfix-TestTrafico` | — decisión ya documentada, no requiere acción nueva |
| No tocar desde este proyecto | Ramas `*/laptop/*`, `main`, `RedMotorsPartial-Sandbox` | Fuera de alcance de Empresa/Marcas Chinas |

**No se ejecuta ninguna de estas acciones en esta sesión.**

## Elementos que no deben volver a utilizarse

- `RedMotors-Sprint1-Reconciliacion33` y `RedMotors-Sprint1-Validacion33` como fuente de código o decisiones — son hilos de análisis paralelos, no fusionados, y ya se identificó en el cierre de Sprint 1 que uno de ellos llegó a una conclusión sobre `BatchGetCatalogoSoftland` que la evidencia técnica directa de esta sesión contradijo (ver `CIERRE_TECNICO_SPRINT1_33_CLASES_3_TRIGGERS_DRAFT.md`, Fase 2).
- Cualquier carpeta `tmp-partial-*` o `test-results/` de sesiones anteriores — nunca deben copiarse ni recrearse manualmente; cualquier retrieve nuevo debe hacerse expresamente cuando se autorice.
- `RedMotors-Hotfix-TestTrafico` no debe fusionarse hasta resolver la sincronización controlada documentada en `DESFASE_GIT_PARTIAL_TEST_TRAFICO.md`.
