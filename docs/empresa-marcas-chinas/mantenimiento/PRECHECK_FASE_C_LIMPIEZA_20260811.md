# Precheck Fase C — candidatos restantes de limpieza (Next8-Reconcile y worktree roto)

**Fecha:** 11 de agosto de 2026.
**Naturaleza:** análisis de solo lectura. No se aplicó, hizo `pop` ni `drop` del stash de VN-RQ106; no se modificó, borró ni
comprometió ningún archivo en `RedMotors-Sprint1-Next8-Reconcile` ni en `RedMotors-Empresa-Marcas-Chinas`; no se
retiró ningún worktree en este bloque; no se modificó Salesforce.

---

## 1. `RedMotors-Sprint1-Next8-Reconcile`

**Archivo no rastreado:** `docs/empresa-marcas-chinas/CIERRE_TECNICO_SPRINT1_33_CLASES_3_TRIGGERS_DRAFT.md`.

**Comparación realizada:** contenido completo del archivo no rastreado contra la versión final ya versionada en el
repo activo (`docs/empresa-marcas-chinas/CIERRE_TECNICO_SPRINT1_33_CLASES_3_TRIGGERS_DRAFT.md`, incorporada en el
commit `bf1e260`).

**Hallazgo:** el archivo no rastreado es una **iteración muy anterior e incompleta** del mismo documento:
- Misma lista de 32 clases candidatas, en el mismo orden — **sin ninguna clase adicional ni distinta**.
- Mismos 3 triggers (`ChanceAccountBavarian`, `ChanceAccountContado`, `WorkOrderTrigger`).
- **Sin ninguna verificación real completada** — cada fila de la tabla dice literalmente "Snapshot removido —
  pendiente"; el propio documento se autodeclara "no hacer commit hasta validar".
- No contiene el Test Run de evidencia (`707AK00000HB6UY`), ni el análisis de las 4 candidatas a clase 33, ni la
  reconciliación de los 7 `BatchGet*Softland`/`WorkOrderTrigger`, ni la nota de "diferencia cosmética" de
  `productJSON` — todo esto **sí existe** en la versión final ya versionada, con muchísimo más detalle y evidencia
  real de ejecución.

**Conclusión:** no se encontró ningún hecho, decisión o evidencia en el archivo no rastreado que no esté ya
preservado (y ampliado) en la documentación final. Está completamente superado.

### `NEXT8_RECONCILE: SEGURO_PARA_RETIRAR`

El worktree completo podrá retirarse en un lote posterior con el mismo mecanismo (`git worktree remove`), sin
necesidad de preservar nada adicional del archivo no rastreado. No se retiró en este bloque, por instrucción
explícita de esta fase.

---

## 2. `RedMotors-Empresa-Marcas-Chinas` (worktree roto)

**Estado del enlace:** confirmado roto — el archivo `.git` apunta a
`/sessions/pensive-brave-fermat/mnt/RedMotorsPartial-Sandbox/.git/worktrees/RedMotors-Empresa-Marcas-Chinas`, una
ruta de otra sesión/entorno inexistente en esta máquina. No se ejecutó ningún comando Git dentro de esta carpeta;
la comparación se hizo por sistema de archivos.

**43 rutas ausentes del repo activo, verificadas una por una:**

- **5 archivos `describe-*.json`** (`Bodega`, `Empresa`, `Opportunity`, `Product2`, `Quote`): salidas de
  `sf sobject describe` de un momento anterior. Reconstruibles en cualquier momento con el mismo comando contra el
  org Partial — no se ejecutó ningún `describe` nuevo en este bloque, se clasifican por su naturaleza (una
  descripción de schema siempre es regenerable, no es un dato que solo exista en esa carpeta).
- **2 archivos de `tmp-partial-check/`** (`RM_VN_QuoteController_Test.cls` + `.cls-meta.xml`).
- **36 archivos de `tmp-partial/classes/`** (18 clases Apex + su `.cls-meta.xml`).

**Comparación de contenido realizada (hash SHA-256 y diff normalizando fin de línea) de las 19 clases Apex contra
sus equivalentes actuales en `force-app/main/default/classes/` del repo activo:**

| Resultado | Cantidad de clases | Detalle |
|---|---:|---|
| Idénticas byte a byte | 3 | `QuoteSoftlandPedidoService`, `QuoteSoftlandQueryService`, `TestServiciosQuote` |
| Idénticas tras normalizar CRLF/LF | 14 | `OpportunityServiceInvoker`, `OpportunityServiceInvokerTest`, `QuoteService`, `QuoteServiceControllerTest`, `RegistrarAnticipoCasillasTst`, `Registrar_Anticipo_Controller`, `Registrar_Anticipo_Controller_Test`, `servicioEliminarReserva`, `servicioEliminarReservaMock`, `servicioEliminarReservaTest`, `servicioReservas`, `servicioReservasMock`, `servicioReservasTest`, `RM_VN_QuoteController_Test` |
| Con diferencia real de contenido | 2 | `productJSON` y `productJSONTest` — únicamente diferencias de espacios en blanco/tabulador sin ningún efecto funcional, **ya documentadas y descartadas explícitamente** en la versión final (`CIERRE_TECNICO_SPRINT1_33_CLASES_3_TRIGGERS_DRAFT.md`, sección "`productJSON` — diferencia cosmética": "diferencia de un solo carácter... sin ningún efecto funcional... no se justifica un commit únicamente por esto") |

**Conclusión:** las 19 clases Apex del worktree roto **ya están en Git** en el repo activo, con contenido
funcionalmente idéntico en los 19 casos. No se encontró ninguna clase, decisión o dato que exista solo en esa
carpeta. Las 5 descripciones de schema son reconstruibles bajo demanda.

### `WORKTREE_ROTO: SEGURO_PARA_RETIRAR_MANUALMENTE`

No se retiró en este bloque. Al retirarse (fuera de esta fase, dado que el enlace Git está roto y no puede usarse
`git worktree remove` — requerirá borrado manual de carpeta tras aprobación explícita separada), no se pierde
ninguna información única.

---

## 3. VN-RQ106 (`RedMotorsPartial-Sandbox`) — solo confirmación, sin tocar

Confirmado por consulta de solo lectura (`git stash list`, `git diff --stat`):

- `stash@{0}` sigue presente, sin aplicar, sin `pop`, sin `drop` — intacto byte a byte respecto al estado anterior.
- La modificación local de `force-app/main/default/lwc/jsconfig.json` sigue siendo exactamente 1 línea (pérdida del
  salto de línea final, no funcional) — sin cambios.

No se ejecutó `git stash apply`, `git stash pop`, `git stash drop`, `git checkout` ni `git restore` en ningún
momento de este bloque.

---

## 4. Qué puede limpiarse después (siguiente lote, no ejecutado en este bloque)

- **`RedMotors-Sprint1-Next8-Reconcile`**: retirar con `git worktree remove` — sin preservar nada adicional del
  archivo no rastreado, que ya está superado (sección 1).
- **`RedMotors-Empresa-Marcas-Chinas`**: retirar manualmente la carpeta (el enlace roto impide usar
  `git worktree remove`) — sin preservar nada, ninguno de los 43 archivos contiene información única (sección 2).

## 5. Qué necesita preservación antes de cualquier limpieza posterior

- El stash de VN-RQ106 (69 archivos, ≈2.42 MiB, ya inventariado en `ANALISIS_STASH_VN_RQ106_20260811.md` /
  `MATRIZ_STASH_VN_RQ106_20260811.csv`) — sigue sin respaldo fuera del stash local; no se resuelve en este bloque.
- La modificación de `jsconfig.json` en `RedMotorsPartial-Sandbox` — decisión pendiente de si es útil o
  descartable, fuera del alcance de este bloque (corresponde al responsable de VN-RQ106).

---

## 6. Estado Git final (repo activo)

Verificado al cierre de este bloque, antes del commit de esta documentación:

```
git status -sb   → limpio (antes de agregar este documento)
git rev-parse HEAD → b3d8e1a...
git rev-list --left-right --count HEAD...@{upstream} → 0  0
```
