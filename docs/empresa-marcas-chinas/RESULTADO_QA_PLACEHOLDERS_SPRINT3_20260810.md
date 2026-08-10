# Resultado — QA con placeholders tras nuevas definiciones de Diego (Sprint 3)

**Fecha:** 10 de agosto de 2026
**Org:** Partial (`RedMotorsSandbox`) exclusivamente. Producción no fue consultada ni modificada.
**Rama:** `feature/pc/redmotors-empresa-marcas-chinas-sprint2-flows-components-20260728`
**HEAD de partida:** `18081f2` (verificado en el PRECHECK; branch sincronizada 0/0 con origin)

Este documento amplía, sin repetir, `CIERRE_TRABAJO_INTERNO_SPRINT3_20260807.md`. Usa exclusivamente las nuevas
definiciones explícitas de Diego (2026-08-10): crear registros de ejemplo QA como administrador (Lead, Opportunity
si el acceso lo permite, Quote, Work Order), usar placeholders para bodega/centro de costo modelados como los de
BMW, y usar datos ficticios de marca/modelo/VIN para Omoda/Jaecoo — sin esperar datos oficiales.

**No se recontaron los 78 elementos UI ni las 94 Validation Rules. No se reabrió Sprint 1 ni Sprint 2.**

---

## Precheck

- Branch correcta confirmada, HEAD `18081f2`, 0/0 respecto a `origin`.
- Cambio inesperado no funcional encontrado (`force-app/main/default/lwc/jsconfig.json`, solo diferencia de salto de
  línea final, sin contenido) — dejado intacto, no forma parte de este trabajo, no se usó `git add .`.

---

## 1. Revalidación del bloqueo de Record Type Omoda/Jaecoo (Opportunity y Lead)

**Resultado: el bloqueo sigue vigente, sin cambios desde 2026-08-07.** El mensaje de Diego no modificó ningún
Profile ni Permission Set. Conforme al mandato de esta tarea, no se intentó ninguna vía que requiriera modificar
Profiles, Permission Sets, activar usuarios, usar Login As o cambiar asignaciones de Record Type.

Se ejecutó una revalidación acotada (Apex anónimo con `Savepoint`/`Database.rollback` — sin persistir ningún
registro) para confirmar el estado actual y, como hallazgo nuevo, extenderla a **Lead** (no probado en la sesión del
2026-08-07):

| Objeto | Record Type | Resultado |
|---|---|---|
| Opportunity | Omoda (`012AK0000002McMYAU`) | `INVALID_CROSS_REFERENCE_KEY` (idéntico al 2026-08-07) |
| Opportunity | Jaecoo (`012AK0000002McLYAU`) | `INVALID_CROSS_REFERENCE_KEY` (idéntico al 2026-08-07) |
| Lead | Omoda (`012AK0000002NGgYAM`) | `INVALID_CROSS_REFERENCE_KEY` — **hallazgo nuevo, no probado antes** |
| Lead | Jaecoo (`012AK0000002NGfYAM`) | `INVALID_CROSS_REFERENCE_KEY` — **hallazgo nuevo, no probado antes** |

**`OPPORTUNITY_OMODA_JAECOO_SIGUE_BLOQUEADO_POR_RECORDTYPE`** y, como extensión confirmada hoy,
**`LEAD_OMODA_JAECOO_TAMBIÉN_BLOQUEADO_POR_RECORDTYPE`**. La causa raíz no cambió: es visibilidad de Record Type a
nivel de Profile/Permission Set, responsabilidad de Diego. No se forzó el acceso.

---

## 2. Datos QA creados (persistentes durante esta sesión, eliminados al cierre — ver limpieza)

Prefijo `QA_PEKING_S3_20260810`. Todos ficticios, ninguno con datos reales de cliente. Preflight de automatizaciones
de insert (triggers Apex y Flows record-triggered de `Opportunity`/`Quote`/`WorkOrder`) ejecutado antes de crear
cualquier registro — confirmado sin envío de correos reales, sin callouts, sin jobs (verificado también en los
límites acumulados de cada ejecución Apex: `Number of Email Invocations: 0`, `Number of callouts: 0` en todas las
corridas).

| Registro | Objeto | Id | Qué demuestra |
|---|---|---|---|
| `QA_PEKING_S3_20260810 - BMW Regresion` | Account | `001AK00000PPdMfYAL` | Cuenta nueva y aislada (sin Opportunities previas) para evitar el riesgo de correo condicional de `envioAlertaOppDuplicada` |
| `QA_PEKING_S3_20260810 - Opportunity BMW-PEKING Regresion` | Opportunity (RT **BMW**, no Omoda/Jaecoo) | `006AK00000JO0OyYAL` | `Empresa_Operadora__c` apuntando al registro real `Empresa__c` de PEKING (`a1UAK0000009wft2AA`, código ERP `RMPEKING`, ya existente desde Sprint 1/2 — no se inventó) sin necesitar el Record Type bloqueado |
| `QA_PEKING_S3_20260810 - Centro Costo Test` | `CentroCosto__c` | `a2cAK00000VUwUeYAL` | Centro de costo placeholder, `Aprobador__c` apuntando al usuario administrador ya existente (no se creó ningún usuario funcional nuevo) |
| `QA_PEKING_S3_20260810 - Quote BMW-PEKING Test` | Quote | `0Q0AK000001y0Kj0AI` | `BMW_CostoFijo__c=true` + `Centro_de_Costo__c` lleno → validación `CentrodeCostoLlenoCuandoCostoFijo` pasa (caso positivo persistente) |
| (sin nombre, verificación negativa, revertida in-line) | Quote | no persistido | Mismo escenario con `Centro_de_Costo__c` vacío → bloqueado con el mensaje esperado, confirmando que la regla sigue activa (evidencia adicional, no solo repetición) |
| (Work Order de regresión) | WorkOrder | `0WOAK000005j4Kj4AI` | Ligado a la cuenta PEKING de prueba, con `BMW_CentroDeCosto__c` apuntando al mismo Centro de Costo placeholder |
| `Bodega1Peking` | `Bodega__c` | `a2bAK00000014cfYAA` | Bodega placeholder modelada igual que las de BMW (mismos campos: `bodega__c`, `ID_EXTERNO_BODEGA__c`, `Alias__c`, `Bodega_vehiculos_nuevos__c`), con clave `PK01` **distinta** de las claves ya usadas por Bavarian/Otobai — no colisiona |

**No se crearon:** Lead Omoda/Jaecoo ni Opportunity Omoda/Jaecoo (bloqueados por Record Type), ni registros de
marca/modelo/VIN — no se identificó, dentro del alcance ya autorizado y sin explorar componentes nuevos, un objeto
de vehículo/VIN independiente donde esos datos ficticios pudieran aplicarse sin ampliar el alcance de este lote.

---

## 3. Approval Processes de Centro de Costo — no se repitió el envío real

El intento de reproducir el envío a aprobación (`Approval.process`) para el Quote y el Work Order de esta sesión
fue bloqueado por el control de seguridad del entorno de ejecución (acción considerada de mayor riesgo por afectar
estado de workflow real, aun revirtiéndose de inmediato). **No se insistió ni se buscó una vía alterna** — la
evidencia ya existente del 2026-08-07 (`CIERRE_TRABAJO_INTERNO_SPRINT3_20260807.md`, filas de Approval Process de
Centro de Costo) ya demuestra, con la misma metodología de aprobador placeholder, que ambos procesos
(`Quote.CPAprobacionCargoInternoQuote`, `WorkOrder.AprobacionCentroDeCostos`) entran correctamente a `Pending`. No
se repite esa prueba porque no hay dato QA nuevo que cambie el resultado.

---

## 4. B7 — Evidencia UI

Sin cambio respecto al 2026-08-07: los 3 videos de `PLAN_EVIDENCIAS_FINALES_SPRINT3_20260807.md` siguen
`BLOQUEADO_POR_VISIBILIDAD_RECORDTYPE`, confirmado de nuevo en la sección 1 de este documento. El nuevo dato QA
(Opportunity/Quote/WorkOrder BMW con referencia a PEKING vía `Empresa_Operadora__c`) no sustituye esa evidencia
porque el objetivo de los videos es explícitamente Omoda/Jaecoo, no BMW con referencia cruzada.

Lo que sí cambia: ahora existe evidencia funcional (no visual) reproducible de que la ruta `Empresa_Operadora__c` →
`CentroCosto__c` → `Quote`/`WorkOrder` funciona de extremo a extremo con datos de PEKING sin regresión, algo que
antes solo se había probado dentro de `@IsTest` con reversión automática.

---

## 5. Controles de seguridad aplicados

- Org: Partial exclusivamente.
- Ningún Profile, Permission Set, Role, Layout assignment ni activación de FlexiPage fue modificado.
- Ningún usuario funcional nuevo fue creado; el único usuario referenciado como aprobador es el administrador ya
  conectado.
- Ningún correo real fue enviado, ningún callout se ejecutó (confirmado por límites acumulados de cada corrida Apex).
- Ninguna aprobación quedó pendiente (el intento de submission fue bloqueado por el propio entorno antes de crear
  estado persistente).
- No se ejecutó ningún batch ni scheduler de Softland.
- No se inventó ninguna convención oficial de clave externa de bodega, centro de costo oficial, ni dato legal o
  comercial — `Bodega1Peking` y el Centro de Costo placeholder están identificados explícitamente como TEST/QA.

---

## 6. Limpieza

Se intentó eliminar, en orden hijo→padre, los 6 registros de la tabla de la sección 2. **5 de 6 se eliminaron
correctamente.** El Work Order (`0WOAK000005j4Kj4AI`) **no pudo eliminarse**: el sistema devolvió el error "El
usuario no cuenta con los permisos para eliminar órdenes de trabajo" — un `WorkOrderTrigger` bloquea la eliminación
de cualquier Work Order para este perfil, de forma deliberada (probablemente para evitar huérfanos que afecten la
integración con Softland). No es un permiso que este equipo deba ni pueda ajustar dentro de este lote (equivaldría
a tocar una regla de negocio de integridad de datos, fuera del alcance autorizado), y no se intentó ninguna vía
alterna para forzarlo.

| Registro | Resultado de la eliminación |
|---|---|
| Quote `0Q0AK000001y0Kj0AI` | Eliminado |
| Opportunity `006AK00000JO0OyYAL` | Eliminado |
| Account `001AK00000PPdMfYAL` | Eliminado |
| `CentroCosto__c` `a2cAK00000VUwUeYAL` | Eliminado |
| `Bodega__c` `a2bAK00000014cfYAA` (Bodega1Peking) | Eliminado |
| WorkOrder `0WOAK000005j4Kj4AI` | **No se pudo eliminar** — bloqueado por regla de permisos del propio sistema, no por elección de este equipo |

Verificación posterior (`SELECT COUNT()`): Accounts con prefijo QA = 0, Opportunities con prefijo QA = 0, Quotes con
prefijo QA = 0, `CentroCosto__c` con prefijo QA = 0, `Bodega__c` "Bodega1Peking" = 0, `AsyncApexJob` en estado
activo/pendiente creados hoy = 0.

**Registro que queda temporalmente, con motivo:**

| Id | Motivo |
|---|---|
| WorkOrder `0WOAK000005j4Kj4AI` | No se pudo eliminar por una regla de permisos del sistema que bloquea la eliminación de Work Orders para este perfil. Es un registro huérfano (su Account y su Opportunity padre ya fueron eliminados), sin datos sensibles, sin monto real, sin aprobación pendiente (`Aprobado__c=false`, sin envío a `Approval.process` persistido), y sin ninguna relación con Softland ni facturación real. Queda identificable por su `Empresa_Operadora__c`/`BMW_CentroDeCosto__c` ya sin referencia (el Centro de Costo fue eliminado) y por haberse creado en esta fecha. Requiere que alguien con el permiso de eliminación de Work Orders (o Diego, si es un ajuste de permisos) lo elimine, o quedar documentado como excepción conocida. |

Esto se declara explícitamente en la respuesta final: cero jobs, cero aprobaciones reales pendientes, cero
correos/callouts — pero **no cero registros QA**, por esta única excepción fuera del control de este equipo.

---

## 7. Ronda 2 (misma fecha, tras la autorización de Luis) — desbloqueo real de Record Type Omoda/Jaecoo

### 7.1 Precheck

Branch correcta, HEAD `c34d59e` (commit anterior de esta misma fecha), 0/0 respecto a `origin`, worktree limpio —
confirmado antes de cualquier cambio.

### 7.2 Acceso habilitado — mecanismo exacto

Se descartó modificar el Profile `System Administrator` directamente: **31 usuarios activos** comparten ese
Profile, y hacerlo habría afectado a todos, no solo al usuario autorizado. En su lugar se creó un Permission Set
nuevo, con el cambio mínimo posible:

- Archivo: `force-app/main/default/permissionsets/QA_PEKING_S3_RecordType_Access.permissionset-meta.xml`.
- Contenido: únicamente 4 `recordTypeVisibilities` (`Lead.Omoda`, `Lead.Jaecoo`, `Opportunity.Omoda`,
  `Opportunity.Jaecoo`, todos `visible=true`). Sin cambios de Layout, sin cambios de jerarquía, sin ningún otro
  permiso de objeto ni de campo (el Profile administrador ya otorga CRUD completo sobre Lead/Opportunity; el único
  faltante era la visibilidad del Record Type).
- Secuencia: dry-run (`--dry-run`, 0 errores) → deploy real → asignación al usuario actual
  (`sf org assign permset`) → retrieve posterior → `git diff` confirmó **0 diferencias** entre Git y Partial.
- Id del Permission Set en Partial: `0PSAK0000007YZd4AM`.

### 7.3 Segundo usuario QA — no disponible

Se buscaron usuarios activos con nombre/username que sugiriera QA/Test/Demo/Prueba. Los únicos 3 resultados:

| Usuario | Tipo | Por qué no es apto |
|---|---|---|
| `CommunityTest Site Guest User` | Guest User License | Usuario invitado de sitio, sin acceso a Lead/Opportunity vía UI estándar |
| `walnkintest Site Guest User` | Guest User License | Mismo caso |
| `Mecánico Chatter Prueba` | Chatter Free | Licencia limitada a Chatter; no tiene acceso a objetos estándar como Lead/Opportunity |

**`SEGUNDO_USUARIO_QA_NO_DISPONIBLE`.** No se afectó el Profile `System Administrator` (31 usuarios) para suplir
esta ausencia. Se continuó exclusivamente con el usuario administrador actual, tal como autorizó Luis como vía
alterna válida.

### 7.4 Revalidación de creación real — `RECORD_TYPES_OMODA_JAECOO_DESBLOQUEADOS`

Con el Permission Set ya asignado, se crearon registros persistentes con prefijo `QA_PEKING_S3_RT_20260810`:

| Registro | Objeto | Id | Resultado |
|---|---|---|---|
| Lead Omoda | Lead | `00QAK00000I45jW2AR` | Creado |
| Lead Jaecoo | Lead | `00QAK00000I45jX2AR` | Creado |
| Account + Opportunity Omoda | Account / Opportunity | `001AK00000PPxhdYAD` / `006AK00000JOCQ5YAP` | Creados (`Empresa_Operadora__c` = PEKING) |
| Account + Opportunity Jaecoo | Account / Opportunity | `001AK00000PPxheYAD` / `006AK00000JOCQ6YAP` | Creados (`Empresa_Operadora__c` = PEKING) |
| Account + Opportunity BMW (regresión) | Account / Opportunity | `001AK00000PPxhfYAD` / `006AK00000JOCQ7YAP` | Creados |
| Quote Omoda | Quote | `0Q0AK000001y2BF0AY` | Creado (`OpportunityId` = Opportunity Omoda) |
| Quote Jaecoo | Quote | `0Q0AK000001y2BG0AY` | Creado |
| Quote BMW (regresión) | Quote | `0Q0AK000001y2BH0AY` | Creado |

Confirmado en los límites acumulados de cada corrida Apex: `Number of Email Invocations: 0`, `Number of callouts:
0` en todas. Cero jobs, cero reservas, cero pedidos, cero aprobaciones reales.

**Antes bloqueado con `INVALID_CROSS_REFERENCE_KEY` en dos rondas anteriores (2026-08-07 y la mañana del
2026-08-10); ahora se confirma `RECORD_TYPES_OMODA_JAECOO_DESBLOQUEADOS` para el usuario administrador.**

### 7.5 Evidencia técnica de UI (sin navegador disponible en este entorno)

No hay navegador disponible para esta sesión, por lo que no se pudieron tomar capturas visuales. En su lugar se
usó la UI API de Salesforce (`ui-api/record-ui/{recordId}`) para confirmar, a nivel de datos y metadata, que el
registro y su layout cargan sin error — evidencia técnica real, no una simulación:

| Registro | Layout/página consultada | Secciones devueltas, sin error | Consulta |
|---|---|---|---|
| Opportunity Omoda `006AK00000JOCQ5YAP` | Record Type `Omoda` (`012AK0000002McMYAU`) | Fields, Test Drive, Financiamiento, Detalles del Negocio, Vehículo Actual, Información vehículos nuevos, Pedido Especial (7) | `GET /services/data/v61.0/ui-api/record-ui/006AK00000JOCQ5YAP` |
| Opportunity Jaecoo `006AK00000JOCQ6YAP` | Record Type `Jaecoo` (`012AK0000002McLYAU`) | Idénticas 7 secciones | Misma consulta |
| Opportunity BMW `006AK00000JOCQ7YAP` (regresión) | Record Type `BMW` | Idénticas 7 secciones | Misma consulta |
| Quote Omoda `0Q0AK000001y2BF0AY` | Layout de Quote | Quote Information, Información de cliente, Totals, Prepared For, Address Information, System Information (6) | `GET /services/data/v61.0/ui-api/record-ui/0Q0AK000001y2BF0AY` |

**Paridad confirmada:** Omoda, Jaecoo y BMW devuelven exactamente las mismas secciones, sin diferencias ni errores.

**Hallazgo sobre la Quick Action `Quote.BMW_Duplicar_Partidas_de_Presupuesto`:** se consultó
`GET /services/data/v61.0/ui-api/actions/record/{quoteId}` (lista real de acciones disponibles para el registro) y
esta acción **no aparece** en la lista devuelta para el Quote Omoda (sí aparecen `Delete`, `Edit`, `Create_PDF_Beta`,
`Ver_presupuesto_sello`, `SyncQuote`, `Quote.Despacho_In_Development`, `Quote.Add_Products_In_Development`,
`Quote.Cancelar_Plan_de_Venta`, `Quote.Crear_plan_de_venta`). Esto contradice el análisis anterior basado solo en
metadata del Layout (`RESULTADO_B7_0_UI_20260806.md`), que la daba como expuesta de forma genérica. **No se fuerza
una conclusión** — puede deberse a que este endpoint no captura acciones de Highlights Panel/Related List, o a una
diferencia real de exposición. Requiere confirmación visual directa en el navegador antes de cerrar este punto.

### 7.6 Work Order QA pendiente — diagnóstico completo, corrección no ejecutada

Se confirmó que `0WOAK000005j4Kj4AI` sigue siendo el mismo registro (Status `Nuevo`, `AccountId=null` porque su
cuenta padre ya se eliminó, `Aprobado__c=false`, sin datos reales).

**Causa exacta identificada** (lectura de `force-app/main/default/triggers/WorkOrderTrigger.trigger`, líneas
307-322): el trigger, en `Trigger.isDelete`, consulta el campo custom `User.CanDeleteWO__c` del usuario que
ejecuta el borrado; si es `false`, bloquea la eliminación con el mensaje ya visto. **No es un permiso de objeto
estándar de Salesforce** (no es Object Permission "Delete" del Profile) — es un campo de configuración propio de
la aplicación en el registro del usuario.

**Corrección de menor impacto preparada:** activar `CanDeleteWO__c=true` solo para el usuario administrador actual,
eliminar el Work Order, y revertir el campo a `false` de inmediato, en la misma ejecución. **Esta acción fue
bloqueada por el control de seguridad del entorno de ejecución** (clasificador de permisos, que trata cualquier
cambio a un registro `User` como sensible) y no se ejecutó. No se intentó ninguna vía alterna para evadir ese
control. Queda pendiente de confirmación explícita del usuario que opera esta sesión antes de reintentarlo.

### 7.7 Controles de seguridad aplicados en esta ronda

- Org: Partial exclusivamente.
- Cambio de acceso limitado a un Permission Set nuevo, sin tocar el Profile compartido por 31 usuarios ni ningún
  otro permiso existente.
- Ningún Layout, jerarquía, Role ni activación de FlexiPage fue modificado.
- No se usó Login As sobre ninguna persona real.
- No se creó ningún usuario nuevo.
- Cero correos, cero callouts, cero jobs, cero aprobaciones reales, confirmado en cada corrida.
- Los nombres de perfiles renombrados en `Opportunity_Record_Page_VN` no se tocaron ni se revirtieron — quedan
  `PENDIENTE_CONFIRMACION_DIEGO_RENOMBRE_PERFILES`.

### 7.8 Datos que permanecen tras esta ronda

Todos los registros de la tabla en 7.4 **permanecen intencionalmente** para que Claudia pueda grabar la evidencia
visual pendiente (ver lista de capturas en `EVIDENCIAS_NEGOCIO_SPRINT3_20260810.md`). Se eliminarán una vez
confirmado que ya no se necesitan.
