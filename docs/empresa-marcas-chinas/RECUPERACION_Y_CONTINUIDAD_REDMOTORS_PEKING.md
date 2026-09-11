# Recuperación y Continuidad — RedMotors PEKING / Empresa / Marcas Chinas

**Fecha de generación:** 2026-09-11
**Generado por:** sesión de reconciliación y cierre autónomo (continuación de la auditoría read-only y la reconciliación del commit set de esta misma serie de sesiones).
**Estado:** documento operativo, para que cualquier persona o sesión de IA pueda retomar el proyecto sin reconstruir el contexto desde cero.

---

## 1. Repo autoritativo PEKING

| Campo | Valor |
|---|---|
| Ruta | `C:\Users\dokur\Documents\Repositorios\RedMotors-PEKING-Rebuild-20260901` |
| Remote | `origin` → `https://github.com/Peseck89/RedMotorsPartial.git` |
| Branch | `fix/pc/redmotors-peking-rebuild-20260901` |
| HEAD base histórico | `2b97a7788cb7a5534c196be819a2b970248e15ce` |
| Commit(s) de cierre PEKING | Ver sección 3 — **pendientes de creación**, preparados pero no ejecutados por bloqueo de permisos del entorno (ver sección 8) |

**IMPORTANTE:** al momento de escribir este documento, la rama remota `fix/pc/redmotors-peking-rebuild-20260901` **no existe en GitHub**. Publicarla requiere un `git push` normal (nunca `--force`) una vez creados los commits de la sección 3.

## 2. Separación PEKING / VN-RQ106

Son dos proyectos distintos que **no deben mezclarse nunca**:

| | PEKING / Empresa / Marcas Chinas | VN-RQ106 / Reserva y Anticipo |
|---|---|---|
| Ruta | `RedMotors-PEKING-Rebuild-20260901` | `RedMotorsPartial-Sandbox` |
| Branch | `fix/pc/redmotors-peking-rebuild-20260901` | `feature/pc/redmotors-vn-rq106-anticipo-ui-20260527` |
| Commit autoritativo | (pendiente, sección 3) | `cb02bb9c4e4b034881651cfc026682e6eb17c739` (pusheado, local=remoto, 0/0, working tree limpio — verificado 2026-09-11 sin modificar nada) |
| Componente característico | `HttpCalloutCreateKit`, `RM_VN_*`, `OpportunityDetalleProductosService`, `PEKING_Presupuesto_Estandar` | `VN_RQ106_Notificaciones_Anticipo` (Flow), `Registrar_Anticipo_*` |

Dentro del repo PEKING existen artefactos de una auditoría/hotfix de VN-RQ106 (`hotfix-visual-VN_RQ106/`, `readonly-audit-email-flow/`, `readonly-audit-email-flow-package.xml`) generados en una sesión anterior de esta misma serie. **Son contaminación cruzada** — no pertenecen al cierre PEKING, no se incluyeron en ningún commit ni en Drive "Marcas Chinas", y quedan marcados para retiro (ver sección 6).

## 3. Commit set PEKING — preparado, pendiente de ejecución manual

El entorno de esta sesión **bloqueó `git add`** con el motivo "Modify Shared Resources" (clasificador de permisos de Claude Code, no una decisión de esta sesión). No se pudo ejecutar ningún `git add`/`commit`/`push`. La reconciliación completa (matriz de todos los archivos categoría A) ya está hecha; lo único pendiente es que una persona (o una sesión con permisos de escritura Git) ejecute los comandos siguientes **tal cual**, desde `C:\Users\dokur\Documents\Repositorios\RedMotors-PEKING-Rebuild-20260901`:

```bash
git add -- \
  "force-app/main/default/classes/HttpCalloutCreateKit.cls" \
  "force-app/main/default/classes/HttpCalloutCreateKitTest.cls" \
  "force-app/main/default/classes/RM_VN_CambiarUbicacion_Ctrl.cls" \
  "force-app/main/default/classes/RM_VN_CambiarUbicacion_Ctrl_Test.cls" \
  "force-app/main/default/classes/OpportunityLineItemTriggerHandler.cls" \
  "force-app/main/default/classes/OpportunityDetalleProductosService.cls" \
  "force-app/main/default/classes/OpportunityDetalleProductosService.cls-meta.xml" \
  "force-app/main/default/lwc/rm_vn_crear_opp_general/rm_vn_crear_opp_general.html" \
  "force-app/main/default/lwc/rm_vn_crear_opp_general/rm_vn_crear_opp_general.js" \
  "force-app/main/default/lwc/rm_vn_crear_opp_home_movil/rm_vn_crear_opp_home_movil.html" \
  "force-app/main/default/lwc/rm_vn_crear_opp_home_movil/rm_vn_crear_opp_home_movil.js" \
  "force-app/main/default/layouts/Lead-Lead Layout.layout-meta.xml" \
  "force-app/main/default/permissionsets/PEKING_Presupuesto_Estandar.permissionset-meta.xml" \
  "force-app/main/default/flows/BMW_Gestiona_Listas_de_Precios.flow-meta.xml"

git commit -m "fix(peking): cierre técnico Go-Live PEKING — Empresa dinámica en Softland/Reserva/Inventario/CrearOpp

Componentes verificados byte a byte contra sus paquetes realmente desplegados
a RedMotorsProd (backup-prod-before-*, check-only-package-*-peking,
deploy_*_result.json — 7 deploys reales, Sept 2026):

- HttpCalloutCreateKit(+Test) — paquete C1, Deploy 0AfPH000001ydsL0AQ
- RM_VN_CambiarUbicacion_Ctrl(+Test) — paquete C2, Deploy 0AfPH000001ydvZ0AQ
- OpportunityLineItemTriggerHandler.cls — paquete B1, Deploy 0AfPH000001yddp0AA
- OpportunityDetalleProductosService(+meta) — paquete B1, mismo deploy
- rm_vn_crear_opp_general, rm_vn_crear_opp_home_movil — paquete D1, Deploy 0AfPH000001ye3d0AA
- Lead-Lead Layout (Ano1__c) — paquete A-safe, Deploy 0AfPH000001ydHF0AY
- PEKING_Presupuesto_Estandar — paquete A-safe, mismo deploy
- BMW_Gestiona_Listas_de_Precios — paquete A2, Deploy 0AfPH000001ydVl0AI

Excluidos deliberadamente de este commit (ver
docs/empresa-marcas-chinas/BITACORA_MAESTRA_PEKING_20260902.md addendum
2026-09-11 y RECUPERACION_Y_CONTINUIDAD_REDMOTORS_PEKING.md):
OpportunityLineItemTriggerHandlerTest3.cls y
OpportunityDetalleProductosServiceTest.cls (divergen del artefacto real
desplegado en B1), RM_VN_Inventario_Ctrl(+Test)+LWC y
RM_VN_CrearOportunidad_Ctrl.cls (copias locales no representan LIVE)."

git add -- \
  "docs/empresa-marcas-chinas/BITACORA_MAESTRA_PEKING_20260902.md" \
  "docs/empresa-marcas-chinas/RECUPERACION_Y_CONTINUIDAD_REDMOTORS_PEKING.md"

git commit -m "docs(peking): Bitácora Maestra del cierre Go-Live + documento de recuperación y continuidad"

git push -u origin fix/pc/redmotors-peking-rebuild-20260901
```

Después de ejecutar, verificar:
```bash
git rev-parse HEAD
git rev-parse origin/fix/pc/redmotors-peking-rebuild-20260901
git status -sb
```
Debe quedar `ahead 0, behind 0` y el working tree con únicamente los archivos NO incluidos (ver sección 5) como pendientes.

## 4. Qué NO incluir en el commit PEKING (y por qué)

| Archivo/componente | Motivo |
|---|---|
| `OpportunityLineItemTriggerHandlerTest3.cls` | Working tree tiene `Sucursal__c = 'Escazú'` (hardcode); el paquete B1 realmente desplegado tiene `Sucursal__c = suc.Name` (dinámico). Regresión local no explicada. |
| `OpportunityDetalleProductosServiceTest.cls` | Le falta el helper `recalcularDetalle()` y sus 4 usos presentes en el paquete B1 realmente desplegado. |
| `RM_VN_Inventario_Ctrl.cls` + `_Test.cls` + LWC `rm_vn_inventario`/`_movil` | Working tree: 1248 líneas, 698 ocurrencias de `testss`/`dummy` + lógica CU-07 nunca desplegada. El paquete CU-10 real (desplegado, `Deploy 0AfPH000001ydnV0AQ`) tiene 508 líneas, limpio. |
| `RM_VN_CrearOportunidad_Ctrl.cls` | Ningún paquete de esta sesión lo incluye. Producción además cambió después (ver Bitácora, addendum §16). |
| `RM_VN_GetOppRecordTypes_Ctrl.cls`, `RM_VN_Service.cls` | Bitácora afirma que ya coinciden con Prod, pero no hay artefacto local (paquete/backup) que lo demuestre — no reverificable sin Salesforce. |
| `WsProcesosAprobacion(+Test)`, `solicitarAprobacionDescuento`, `Opportunity.Solicitar_Aprobacion_Descuento_Lightning` | Bloqueado por decisión de negocio pendiente (conflicto con `Solicitud_de_descuento_BETA`, ya vivo en Prod). |
| `Opportunity_Record_Page_VN.flexipage-meta.xml` | Prod tiene config viva (botón BETA, roles) que el working tree no tiene — requiere merge manual, no deploy directo. |
| `Quote_Record_Page6.flexipage-meta.xml`, `Quote-Vehiculos Nuevos V1.2.layout-meta.xml` | Bloque de otro proyecto (RQ329) vivo en Prod. Fuera de la autoridad de este cierre. |
| `RM_VN_CambiarMoneda_Ctrl(+Test)`, `rm_vn_cambiar_moneda`, `envioAprobacionCentroCostosQuoteAura`, `RM_VN_CrearOportunidad_Ctrl_CU07_Test.cls`, `RM_VN_GetOppRecordTypes_CtrlTest.cls`, `Opportunity.Cambiar_Moneda_VN`, `Quote.CPEnvioDeAprobacionAura` | Nunca existieron en ningún org LIVE (ni Partial ni Prod) — solo en el working tree local. |
| `hotfix-visual-VN_RQ106/`, `readonly-audit-email-flow*` | Contaminación de VN-RQ106, proyecto separado (ver sección 2). |
| `lwc/jsconfig.json` | Config de tooling IDE, no es metadata desplegable. |

## 5. Qué representa Producción hoy (RedMotorsProd)

Confirmado LIVE en auditorías de esta sesión (solo lectura):
- Los 7 paquetes de la sección 3 (A-safe, A2, B1, C1, C2, CU10, D1) están desplegados y verificados byte a byte.
- `Empresa__c` "PEKING": `Codigo__c = 'PEKING'`, `Codigo_ERP__c = 'PEKING'` (no `'RMPEKING'`) — vigente.
- `RM_VN_CrearOportunidad_Ctrl` en Prod **cambió después** de este cierre (Deploy `0AfPH000001ylmf0AA`, 2026-09-04T06:35 UTC) a una arquitectura `EmpresaResolver`/`EmpresaContext` — **ninguna copia local de este repo representa correctamente ese estado actual.**
- `EmpresaResolver.cls` en Prod es una versión expandida (con `resolveByLegacyValue`, validación relajada de `Nombre_Legal__c`) vigente desde 2026-08-29, distinta de la copia en el working tree local de PEKING-Rebuild.

## 6. Archivos locales antiguos que NO usar

- El working tree actual de `RM_VN_Inventario_Ctrl.cls`, `RM_VN_Inventario_Ctrl_Test.cls`, `RM_VN_CrearOportunidad_Ctrl.cls`, `EmpresaResolver.cls` — ninguno representa lo LIVE actual.
- `hotfix-visual-VN_RQ106/`, `readonly-audit-email-flow/`, `readonly-audit-email-flow-package.xml` — pertenecen a VN-RQ106, no a PEKING.
- Los worktrees `RedMotors-CU10-Prod-Final`, `RedMotors-CU11-Prod-Final`, `RedMotors-CU16-Partial-Final`, `RedMotors-Auditoria-Prod-Partial-20260831`, `RedMotors-GoLive-20260829`, `RedMotors-Horas-Adicionales` tienen `OpportunityLineItemTriggerHandler.cls` idéntico al HEAD baseline (con el código `dummy`/`testss` todavía presente) — **no son fuente para nada nuevo**, son snapshots de auditoría de otras tareas.

## 7. Cómo reconstruir el entorno / retomar PEKING

1. `cd C:\Users\dokur\Documents\Repositorios\RedMotors-PEKING-Rebuild-20260901`
2. `git status -sb` — confirmar branch y estado.
3. Leer este documento completo antes de tocar nada.
4. Leer `docs/empresa-marcas-chinas/BITACORA_MAESTRA_PEKING_20260902.md` (incluye el addendum §16).
5. Si el commit de la sección 3 ya se ejecutó, verificar `git log --oneline -5` y `git ls-remote --heads origin fix/pc/redmotors-peking-rebuild-20260901`.
6. Para cualquier trabajo nuevo sobre `RM_VN_CrearOportunidad_Ctrl`, `RM_VN_Inventario_Ctrl` o `EmpresaResolver`: **partir de un retrieve fresco de RedMotorsProd**, nunca del working tree actual de este repo.
7. Para VN-RQ106: usar exclusivamente `RedMotorsPartial-Sandbox`, nunca esta ruta.

## 8. Bloqueos técnicos de esta sesión

- El entorno de ejecución bloqueó `git add` (clasificador "Modify Shared Resources"). Ningún commit ni push fue creado por esta sesión — todo quedó preparado en la sección 3 para ejecución manual o por una sesión con permisos de escritura Git habilitados.
- Salesforce: **no se realizó ninguna escritura** — todas las consultas de esta sesión y de las anteriores fueron de solo lectura (SOQL, Tooling API, `sf project retrieve`, `sf project deploy --dry-run`/check-only). Confirmado explícitamente en el informe ejecutivo.

## 9. Pendientes funcionales / de negocio (heredados de la Bitácora, sección 14)

- Decidir cuál mecanismo de aprobación de descuento es el vigente (`Solicitud_de_descuento_BETA` vs `Solicitar_Aprobacion_Descuento_Lightning`).
- Merge manual de `Opportunity_Record_Page_VN` y `Quote_Record_Page6` (coordinación con dueño de RQ329).
- Auditoría/smoke test funcional post-Go-Live en Producción — pendiente, mencionado como a cargo de Codex.
- Reconfirmar el comportamiento del límite SOQL 101 ahora que B1 y CU-10 están LIVE (la Bitácora documenta que era preexistente, pero no reafirma que siga igual tras estos 7 deploys).

## 10. Worktrees históricos — conservados y motivo

Ver informe ejecutivo (sección "Worktrees conservados") para el detalle completo de los ~13 worktrees RedMotors auditados. Ninguno fue eliminado ni se recomienda eliminar sin verificación adicional de commits únicos.

## 11. Tratamiento del stash

Existe `stash@{0}: backup untracked laptop before sync`, compartido entre worktrees. **No fue tocado**: no se hizo `apply`, `pop`, `drop`, `clear`, ni se volvió a inspeccionar su contenido. Solo se registra su existencia.

## 12. Tratamiento de `bkdasteh1.txt`

Ubicación real: `C:\Users\dokur\.claude\projects\c--Users-dokur-Documents-Repositorios-RedMotorsPartial-Sandbox\a084049f-c9fe-4333-b0af-6281df4a6470\tool-results\bkdasteh1.txt` (~2 MB, fuera de cualquier repo Git). **No fue abierto, copiado ni incluido en ningún informe.** Clasificación permanente: **SEGURIDAD — SANEAMIENTO FINAL PENDIENTE** (requiere revisión humana directa, fuera del alcance de cualquier sesión de IA).

## 13. Ubicaciones de preservación

- **Bitácora Maestra:** `docs/empresa-marcas-chinas/BITACORA_MAESTRA_PEKING_20260902.md` (este mismo repo, pendiente de commit — sección 3).
- **Este documento:** `docs/empresa-marcas-chinas/RECUPERACION_Y_CONTINUIDAD_REDMOTORS_PEKING.md`.
- **Backups PRE-deploy (7 carpetas) y paquetes check-only (8 carpetas):** ver informe ejecutivo para su destino final (Drive / cuarentena local).
- **Drive:** carpeta `Marcas Chinas Sprint Agosto` (propiedad de la usuaria) — ver informe ejecutivo para la subcarpeta exacta usada en este cierre.
