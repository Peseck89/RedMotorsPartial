# Estado de Git — Empresa / Marcas Chinas

## Estado del documento

Actualizado 2026-07-28 tras la limpieza segura y controlada de worktrees y temporales. Reemplaza la fotografía inicial (misma fecha, antes de la limpieza) — esa versión anterior describía 20 worktrees; esta describe el estado final tras remover 9.

## HEAD autoritativo de Sprint 1

- **Rama:** `feature/pc/redmotors-empresa-marcas-chinas-sprint1-20260724`
- **Worktree:** `C:\Users\dokur\Documents\Repositorios\RedMotors-Sprint1-Integracion`
- **HEAD:** `bf1e260e020a2873ab5c1388ddfb05723cd99e47`
- **Sincronía con origin:** 0/0, limpio.

## HEAD autoritativo de Sprint 2

- **Rama:** `feature/pc/redmotors-empresa-marcas-chinas-sprint2-flows-components-20260728`
- **Worktree:** `C:\Users\dokur\Documents\Repositorios\RedMotors-Sprint2-Flows-Components`
- **HEAD tras el commit de guardrails:** `348c36279ffd1518a9b60317279f58f030abf9fe` (`docs(empresa): define authorized sprint2 pricebook flow gate`)
- **Sincronía con origin:** 0/0 antes de esta limpieza; pendiente el commit `chore(empresa): streamline active project context` de esta sesión.
- **Creada desde:** `bf1e260` (HEAD exacto de la rama autoritativa de Sprint 1, confirmado antes de crear la rama).

## Worktrees conservados (12, después de la limpieza)

| Worktree | Rama | HEAD corto | Rol |
|---|---|---|---|
| `RedMotors-Sprint1-Integracion` | `feature/pc/redmotors-empresa-marcas-chinas-sprint1-20260724` | `bf1e260` | **Autoritativo — Sprint 1** |
| `RedMotors-Sprint2-Flows-Components` | `feature/pc/redmotors-empresa-marcas-chinas-sprint2-flows-components-20260728` | `348c362` | **Autoritativo — Sprint 2** |
| `RedMotors-Sprint1-Reconciliacion33` | `analysis/pc/redmotors-sprint1-reconcile-33x3-20260727` | `8d9e958` | No fusionada, no autoritativa — no usar como fuente de código |
| `RedMotors-Sprint1-Validacion33` | `feature/pc/redmotors-sprint1-complete-33x3-20260727` | `27a2213` | No fusionada, no autoritativa — no usar como fuente de código |
| `RedMotors-Sprint1-Next8` | `feature/pc/redmotors-sprint1-next8-20260728` | `b4f5f47` | No fusionada — superada por el trabajo ya integrado en la rama autoritativa |
| `RedMotors-Sprint1-Next8-Reconcile` | `feature/pc/redmotors-sprint1-next8-reconcile-20260729` | `15c7033` | No fusionada, diverge (ahead 1 / behind 3 del origin de la rama autoritativa) — pendiente de revisión; **contiene además un archivo sin rastrear** (`docs/empresa-marcas-chinas/CIERRE_TECNICO_SPRINT1_33_CLASES_3_TRIGGERS_DRAFT.md`) que no es un temporal permitido por la Fase 4 de esta limpieza, no se tocó |
| `RedMotors-Sprint1-Pendientes` | `analysis/pc/redmotors-empresa-marcas-chinas-sprint1-pendientes-20260726` | `3fa1b2d` | No fusionada — análisis paralelo |
| `RedMotors-Sprint1-Trazabilidad` | `analysis/pc/redmotors-empresa-marcas-chinas-sprint1-trazabilidad-20260726` | `3a91e5f` | No fusionada — análisis paralelo |
| `RedMotors-Sprint1-Cierre44H` | `analysis/pc/redmotors-empresa-marcas-chinas-sprint1-cierre44h-20260726` | `cd96fd9` | No fusionada — análisis paralelo |
| `RedMotors-Bloque10-BusquedaDetallada` | `feature/pc/redmotors-empresa-marcas-chinas-bloque10-busqueda-detallada-20260726` | `5e195d4` | No fusionada — caracteriza un bloqueo externo de Bloque 10, todavía relevante para el Lote 5 congelado de Sprint 2 (`busquedaDetallada`) |
| `RedMotors-Hotfix-TestTrafico` | `fix/pc/redmotors-regression-traffic-test-20260726` | `5ecc127` | No fusionada deliberadamente — hotfix preservado sin integrar por decisión ya documentada (`DESFASE_GIT_PARTIAL_TEST_TRAFICO.md`). No fusionar sin resolver esa decisión |
| `RedMotorsPartial-Sandbox` | `feature/pc/redmotors-vn-rq106-anticipo-ui-20260527` | `3df187d` | **No tocado, fuera de alcance** — pertenece a VN-RQ106, proyecto distinto |

Los 9 worktrees no autoritativos permanecen porque cada uno tiene commits que **no** están contenidos en la rama autoritativa de Sprint 1 (verificado con `git merge-base --is-ancestor`), por lo que no cumplían el criterio 2 de remoción.

## Worktrees removidos en esta limpieza (9)

Todos verificados contra los 5 criterios antes de remover: (1) limpio tras eliminar temporales, (2) todos sus commits contenidos en la rama autoritativa de Sprint 1, (3) rama preservada en remoto, (4) sin trabajo de Sprint 2, (5) no autoritativo.

| Worktree removido | Rama | Evidencia de integración | Método |
|---|---|---|---|
| `RedMotors-Bloque10-Cierre` | `feature/pc/redmotors-empresa-marcas-chinas-bloque10-cierre-20260726` | `git merge-base --is-ancestor` = true; `origin/feature/pc/redmotors-empresa-marcas-chinas-bloque10-cierre-20260726` preservada | `git worktree remove` |
| `RedMotors-Bloque18-CoverageLab` | `analysis/pc/redmotors-block18-coverage-lab-20260726` | Igual, ancestro confirmado; upstream preservado | `git worktree remove` |
| `RedMotors-Bloque19-ModeloInteres` | `feature/pc/redmotors-empresa-marcas-chinas-bloque19-modelo-interes-20260726` | Igual | `git worktree remove` |
| `RedMotors-Bloque20-Discovery` | `analysis/pc/redmotors-empresa-marcas-chinas-bloque20-discovery-20260726` | Igual (upstream apuntaba directo a la rama autoritativa) | `git worktree remove` |
| `RedMotors-Bloque20-LeadPeking` | `feature/pc/redmotors-empresa-marcas-chinas-bloque20-lead-peking-20260726` | Igual | `git worktree remove` |
| `RedMotors-Bloque21-Oportunidad-UI` | `feature/pc/redmotors-empresa-marcas-chinas-bloque21-oportunidad-ui-20260726` | Igual | `git worktree remove` |
| `RedMotors-QuoteEmpresaFactura` | `feature/pc/redmotors-empresa-marcas-chinas-quote-empresa-factura-20260726` | Igual | `git worktree remove` |
| `RedMotors-Sprint1-Cierre-Autonomo` | `feature/pc/redmotors-sprint1-cierre-autonomo-20260728` | Igual (HEAD `bf1e260`, idéntico al de la rama autoritativa) | `git worktree remove` — **eliminación parcial**: Git desregistró el worktree correctamente, pero el sistema operativo bloqueó el borrado físico del directorio (`Permission denied`, probablemente un archivo con handle abierto). Queda una carpeta vacía en disco (`0 bytes`, sin contenido gestionado por Git) pendiente de borrado manual cuando ningún proceso la tenga abierta |
| *(worktree remoto, sesión previa)* `RedMotors-Empresa-Marcas-Chinas` | `wip/pc/redmotors-block18-product-searcher-coverage-20260726` | Ya estaba marcado `prunable` por Git (su `gitdir` apuntaba a una ubicación inexistente) | `git worktree prune` |

## Temporales eliminados

- `tmp-partial-33x3/`, `tmp-partial-batch-helper/`, `test-results/` — encontrados sin rastrear en `RedMotors-Sprint1-Cierre-Autonomo`. Verificado antes de eliminar: (a) sin rastrear, (b) sin evidencia única — el Test Run `707AK00000HB6UY` que contenían ya está citado 15 veces en `CIERRE_TECNICO_SPRINT1_33_CLASES_3_TRIGGERS_DRAFT.md` (commiteado), y el código reconciliado que documentaban ya está en los commits `6f8411d`/`bf1e260`, (c) el worktree no tenía cambios funcionales pendientes. Eliminados con `rm -rf`.
- No se encontraron `search_docs.txt`, resultados locales de comparación adicionales, ni archivos temporales de editor sin rastrear en ningún otro worktree revisado.
- No se eliminó ningún manifest, documento ni resultado versionado.

## Ramas candidatas a eliminación futura (no eliminadas — solo lista)

Las ramas de los 8 worktrees removidos por `git worktree remove` siguen existiendo localmente y en `origin`; no se borraron:

- `feature/pc/redmotors-empresa-marcas-chinas-bloque10-cierre-20260726`
- `analysis/pc/redmotors-block18-coverage-lab-20260726`
- `feature/pc/redmotors-empresa-marcas-chinas-bloque19-modelo-interes-20260726`
- `analysis/pc/redmotors-empresa-marcas-chinas-bloque20-discovery-20260726`
- `feature/pc/redmotors-empresa-marcas-chinas-bloque20-lead-peking-20260726`
- `feature/pc/redmotors-empresa-marcas-chinas-bloque21-oportunidad-ui-20260726`
- `feature/pc/redmotors-empresa-marcas-chinas-quote-empresa-factura-20260726`
- `feature/pc/redmotors-sprint1-cierre-autonomo-20260728`
- `wip/pc/redmotors-block18-product-searcher-coverage-20260726` (worktree remoto pruneado; la rama en sí no se tocó)

Todas están completamente contenidas en la rama autoritativa de Sprint 1 — son candidatas seguras a `git branch -d` (local) en el futuro, cuando se autorice explícitamente. **No se ejecutó ningún borrado de rama en esta sesión.**

## Ramas históricas (fuera de alcance de esta limpieza, no auditadas rama por rama)

- 12 ramas `backup/pc/redmotors-before-bloque*-20260725/20260726` — snapshots previos a cada bloque de Sprint 1.
- `backup/pc/redmotors-sprint1-blocks1-19-20260726`, `backup/pc/redmotors-sprint1-blocks1-20-20260726`, `backup/pc/redmotors-sprint1-final-44h-20260726` — checkpoints de cierre, algunos con tag.
- `wip/pc/redmotors-block7-plan-venta-20260725` — trabajo en progreso de un bloque ya cerrado.
- Ramas `backup/laptop/*`, `chore/laptop/*`, `chore/pc/*`, `cleanup/laptop/*`, `docs/laptop/*`, `main` — ajenas al proyecto Empresa/Marcas Chinas.

## Cuál es la rama autoritativa

**Sprint 1:** `feature/pc/redmotors-empresa-marcas-chinas-sprint1-20260724` (HEAD `bf1e260`). **Sprint 2:** `feature/pc/redmotors-empresa-marcas-chinas-sprint2-flows-components-20260728` (HEAD `348c362`, creada desde `bf1e260`). `main` no es la rama autoritativa de este proyecto.

## Elementos que no deben volver a utilizarse

- `RedMotors-Sprint1-Reconciliacion33` y `RedMotors-Sprint1-Validacion33` como fuente de código o decisiones — hilos de análisis paralelos, no fusionados; uno de ellos llegó a una conclusión sobre `BatchGetCatalogoSoftland` que la evidencia técnica directa contradijo (ver `CIERRE_TECNICO_SPRINT1_33_CLASES_3_TRIGGERS_DRAFT.md`).
- Cualquier carpeta `tmp-partial-*` o `test-results/` de sesiones anteriores — nunca copiarlas ni recrearlas manualmente; un retrieve nuevo debe hacerse expresamente cuando se autorice.
- `RedMotors-Hotfix-TestTrafico` no debe fusionarse hasta resolver la sincronización controlada documentada en `DESFASE_GIT_PARTIAL_TEST_TRAFICO.md`.
- Los 8 worktrees removidos en esta limpieza no deben recrearse para retomar trabajo — su contenido ya vive íntegro en la rama autoritativa de Sprint 1; retomar algo de ahí es leer la rama autoritativa, no recrear el worktree histórico.
