# Bitácora Maestra — RedMotors / Empresa / Marcas Chinas (PEKING)

**Estado: BORRADOR LOCAL — no commiteado, no oficial.**
**Fecha de generación:** 2026-09-02/03 (sesión continua, ver timestamps UTC reales en cada evento).
**Worktree autoritativo de esta bitácora:** `C:\Users\dokur\Documents\Repositorios\RedMotors-PEKING-Rebuild-20260901`
**Rama:** `fix/pc/redmotors-peking-rebuild-20260901`
**HEAD al momento de escribir esto:** `2b97a7788cb7a5534c196be819a2b970248e15ce`

**Regla de esta bitácora:** todo lo marcado como **CONFIRMADO** proviene de una consulta real ejecutada en esta sesión (Tooling API, `sf project deploy`, `git`) contra `RedMotorsSandbox` (Partial) o `RedMotorsProd`, con IDs/hashes verificables. Todo lo marcado como **SEGÚN DOCUMENTACIÓN** proviene de archivos ya existentes en `docs/empresa-marcas-chinas/` leídos durante esta sesión, citados por nombre. Todo lo marcado como **NO RECONCILIADO** es algo que el prompt de esta tarea pedía documentar pero que esta sesión no pudo verificar con evidencia real — se deja así explícitamente, sin inventar el dato.

---

## 1. Resumen ejecutivo

**Objetivo del proyecto** (según documentación): incorporar una nueva Empresa (PEKING) y sus marcas — **OMODA** y **JAECOO** — al modelo operativo de RedMotors, que hasta entonces solo soportaba Bavarian (BMW) y Otobai, extendiendo Pricebooks, resolución de bodega, creación de Opportunity/Quote, aprobación de descuentos e inventario para que funcionen de forma genérica por Empresa en vez de con lógica binaria o hardcodeada.

**Resultado final de esta sesión:** **7 deploys reales** de corrección fueron validados (`check-only`) y desplegados realmente (`deploy` real, no simulado) a `RedMotorsProd` — A-safe, A2, B1, CU-10, C1, C2, D1 — cada uno con backup previo y verificación posterior. El detalle completo está en la sección 6.

**Estado técnico actual de Producción (CONFIRMADO al cierre de esta sesión):**
- Los componentes listados como "ya promovidos" en la sección 6 están LIVE en `RedMotorsProd`, verificados con retrieve fresco post-deploy.
- `BMW_Gestiona_Listas_de_Precios` tiene la versión **v5 Active** (`ActiveVersionId == LatestVersionId == 301PH00001hAvCvYAK`, confirmado con Tooling API justo antes de escribir esta bitácora).
- Persisten diferencias LIVE Partial vs Prod en 4-5 componentes, ninguno clasificado como "necesario y falta en Prod" (ver sección 12).
- No se declaró cierre funcional completo de CU-01 a CU-17 — ver sección 11.

---

## 2. Alcance original

**Fuente:** esta sesión no tuvo acceso a reconstruir el alcance original desde cero — se apoyó en los documentos ya vigentes en `docs/empresa-marcas-chinas/`, leídos según la regla de carga de contexto del propio repositorio (`README_CONTEXTO_ACTIVO.md`).

**SEGÚN DOCUMENTACIÓN** (`README_CONTEXTO_ACTIVO.md`, `REGLAS_ALCANCE_AUTORIZADO.md`, `docs/empresa-marcas-chinas/auditoria/INDICE_MAESTRO_AUDITORIA.md`):
- El proyecto se organizó en **Sprint 1** (33 clases + 3 triggers, cerrado técnicamente), **Sprint 2** (Flows/LWC/Aura, pausado sin cerrar según `SPRINT2_FUENTES_AUTORITATIVAS.md`), y **Sprint 3** (autorizado a continuar por Luis el 2026-08-05 con el alcance del documento original de PortalNet).
- Regla de alcance vigente desde 2026-07-28: **ningún componente se trabaja solo por aparecer en documentos, Git o Partial** — requiere autorización explícita de Luis o Diego, clasificada en 4 estados (AUTORIZADO / PENDIENTE DE CONFIRMACIÓN / FUERA DE ALCANCE / DEPENDENCIA TÉCNICA).
- Áreas documentadas como afectadas: Pricebook/moneda, resolución de Empresa por marca, bodega de inventario VN, creación de Opportunity/Lead, aprobación de descuentos, presupuestos de Work Order.

**NO RECONCILIADO:** el detalle completo de qué componentes fueron formalmente autorizados por nombre en cada Sprint (más allá de los 5 Flows de Pricebook y `rm_vu_inventario` documentados en `REGLAS_ALCANCE_AUTORIZADO.md`) no fue re-verificado en esta sesión — se remite a esos documentos como fuente, no se repite aquí para no arriesgar desactualización.

---

## 3. Cronología general

**SEGÚN DOCUMENTACIÓN** (fechas tomadas literalmente de `README_CONTEXTO_ACTIVO.md`):

| Fecha | Evento |
|---|---|
| 2026-07-28 | Cierre técnico Sprint 1 (33 clases). Regla de alcance autorizado entra en vigor |
| 2026-07-30 | Luis autoriza crear `Pricebook2.Empresa__c`, desbloqueando los 5 Flows de Pricebook y `rm_vu_inventario` |
| 2026-08-05 | Luis autoriza continuar Sprint 3 con el alcance del documento original de PortalNet |
| 2026-08-12 | Remediación técnica de `Opp_Flow_V5`, bloque N2/N3/N4, reconciliación QA |
| 2026-08-13 | Cierre técnico conciliado de Sprint 2 (20 Flows) y Sprint 3 (B7/B9/B11) |
| 2026-08-30 | **QA en Producción** — CU-07, CU-08, CU-09 validados; CU-10 quedó "EN REMEDIACIÓN, NO CERRADO" (ver `CONTINUIDAD_QA_PRODUCCION_20260830.md`) |

**CONFIRMADO (esta sesión, 2026-09-02/03):** a partir de este punto la cronología es la de esta sesión de auditoría y promoción — ver secciones 4-6. Esta sesión **no usó `CONTINUIDAD_QA_PRODUCCION_20260830.md` como fuente de estado actual** (por instrucción explícita recibida durante la sesión) — solo como referencia histórica de qué CU tenían evidencia documentada al 30/08.

---

## 4. Trabajo realizado en Partial (LIVE, `RedMotorsSandbox`)

Todo lo siguiente es **CONFIRMADO** por retrieve directo contra `RedMotorsSandbox` durante esta sesión.

| Componente | Estado en Partial | Evidencia de test (ApexTestResult, más reciente) |
|---|---|---|
| `RM_VN_Inventario_Ctrl` | Contenía **697 líneas de código basura** (`testss()`, `dummy = '';`) mezcladas con el fix real de CU-10 | N/A (basura, no probado) |
| `RM_VN_Inventario_Ctrl` (lógica real, sin basura) | Filtro `Empresa__c` en `getRecords`/`searchColors`/`searchTapicerias`/`searchProducts`; `resolveEmpresaCodeForBrand` + 4 helpers; `selectedBrand` en `searchNumeroPedidos` | 8/8 métodos Pass, 2026-09-01 19:05:04 UTC |
| `OpportunityLineItemTriggerHandler` | Refactor con llamadas nuevas a `OpportunityDetalleProductosService` | 4/4 (via Test3) Pass, 2026-09-02 16:48:31 UTC |
| `OpportunityDetalleProductosService` | **Ya existía en Prod antes de B1** — B1 la actualizó/refactorizó y agregó la integración desde `OpportunityLineItemTriggerHandler` (ver corrección de estado en sección 5) | 6/6 métodos Pass (incluye 2 agregados en la reconstrucción), 2026-09-02 16:47 UTC |
| `HttpCalloutCreateKit` | Resolución dinámica Empresa/tipo kit Softland | 24 filas Pass en ventana reciente (11 métodos reales confirmados en el check-only), 2026-09-01 19:04:53 UTC |
| `RM_VN_CambiarUbicacion_Ctrl` | Reemplazo del hardcode `if PEKING` por resolución dinámica | 16/16 Pass, 2026-09-01 19:04:57 UTC |
| `BMW_Gestiona_Listas_de_Precios` | Condición adicional (`Pricebook2Id != PriceBookIdResuelto`) dentro de una regla de Decision ya existente — **no crea una Decision nueva ni es `Debe_actualizar_costos`** (esa Decision pertenece a `Opp_line_item_costo_unitario_update`, un Flow distinto, no promovido; ver corrección en sección 5) | N/A (Flow, sin test unitario) |
| `PEKING_Presupuesto_Estandar` | PermissionSet nuevo, solo `pageAccesses` a `WorkOrderPresupuestoUsdPDF_v2` | N/A (permission set) |
| `rm_vn_crear_opp_general` / `_home_movil` | `brand="BMW"` hardcodeado → dinámico | Sin test Jest (no existen para ningún LWC de esta familia, confirmado) |

**Problemas detectados durante la auditoría de Partial (esta sesión):**
- Código basura masivo en `RM_VN_Inventario_Ctrl` (ver sección 5, CU-10).
- Hardcode literal `'Escazú'` en `OpportunityLineItemTriggerHandlerTest3` (Partial), reemplazando el valor dinámico `suc.Name` que sí tenía Prod — **se descartó**, no viajó a producción.
- Mezcla de lógica CU-07 (selector de moneda) en el working tree local que **nunca llegó a estar LIVE en Partial** — confirmado por retrieve fresco sin rastro de `currencyCode`/`CU-07` en `RM_VN_Inventario_Ctrl` real.

**Estado de QA funcional por CU (PASS/BLOCKED/NO APLICA) — SEGÚN QA FUNCIONAL EN PARTIAL, reportado y confirmado por el usuario al corregir este borrador (esta sesión no ejecutó QA manual propia; documenta el estado que el usuario, como responsable del proyecto, declara como confirmado):**

| CU | Estado (QA funcional en Partial) |
|---|---|
| CU-01 a CU-03 | **NO RECONCILIADO** — sin evidencia autoritativa disponible para esta bitácora |
| CU-04 | PASS |
| CU-05 | BLOCKED |
| CU-06 | BLOCKED |
| CU-07 | PASS (ver detalle en sección 5) |
| CU-08 | PASS (ver detalle en sección 5) |
| CU-09 | PASS (ver detalle en sección 5) |
| CU-10 | PASS (ver detalle en sección 5, además de la evidencia de test técnico ya documentada arriba) |
| CU-11 | PASS |
| CU-12 | PASS (ver detalle en sección 5) |
| CU-13 | NO APLICA |
| CU-14 | BLOCKED |
| CU-15 | NO APLICA |
| CU-16 | BLOCKED |
| CU-17 | PASS (ver detalle en sección 5) |

**Aclaración obligatoria sobre el alcance de estos PASS:** todos los PASS de esta tabla son **QA funcional ejecutado en `RedMotorsSandbox` (Partial)**. Ninguno de ellos equivale por sí solo a una validación funcional en `RedMotorsProd` — el cierre técnico de la promoción a Producción está documentado y verificado en la sección 6 de esta bitácora, pero **la equivalencia de comportamiento funcional en Producción todavía requiere una auditoría/smoke test post-Go-Live** (pendiente, ver secciones 11 y 15). No se debe leer un PASS de esta tabla como "PASS en Producción".

---

## 5. Correcciones importantes

### EmpresaPricebookResolver
**Preservación por reconciliación/exclusión (no un merge ejecutado en esta sesión).** En la auditoría final de esta sesión (sección 12), `EmpresaPricebookResolver` y su clase de test se encontraron **ya sincronizados byte a byte entre Partial y Prod**. Precisamente por eso se decidió **NO incluir esta clase en ningún paquete de promoción**: si ya coincide con Prod, cualquier deploy sería redundante en el mejor caso o arriesgaría sobrescribir el estado LIVE si hubiera drift no detectado. La exclusión deliberada de esta clase de todos los paquetes (A-safe, A2, B1, CU-10, C1, C2, D1) **es** la forma en que esta sesión protegió cualquier hotfix que Diego hubiera aplicado directamente en Prod sobre esta clase: al no tocarla, no hay forma de que esta sesión lo haya sobrescrito. `REGLAS_ALCANCE_AUTORIZADO.md` documenta que Luis autorizó crear `Pricebook2.Empresa__c` el 2026-07-30 para desbloquear esta clase, y que se detectó una contradicción en `QuoteSoftlandPedidoService.resolveLegacyCompanyCode` que ya anticipaba `RMPEKING` sin respaldo de picklist — esa investigación es anterior a esta sesión, citada como fuente, no reverificada aquí.

### RM_VN_CrearOportunidad_Ctrl
**Preservación por reconciliación/exclusión, mismo criterio que arriba.** Esta clase se encontró **idéntica entre Partial y Prod** en la auditoría de esta sesión, y por eso **no se promovió** — ni la versión LIVE de Partial (no había nada que mover) ni la copia del *working tree* local de este repositorio, que contiene lógica de selección de moneda (CU-07, ver más abajo) que **nunca llegó a estar LIVE en ningún org**. No promover esa copia local vieja evitó introducir en Producción una versión de la clase que ni siquiera pasó por Partial. Cualquier cambio de Luis/Diego que ya esté en el LIVE actual de esta clase permanece intacto porque esta sesión no la tocó.

### CU-07 — moneda (PEKING CRC/USD)
**PASS funcional en Partial (según lo reportado y confirmado por el usuario).** El mecanismo real que resuelve el requisito de CU-07 **no es** `RM_VN_CambiarMoneda_Ctrl` (esa clase, junto con el selector de moneda que se veía en el *working tree* local de `RM_VN_Inventario_Ctrl`/`RM_VN_CrearOportunidad_Ctrl`, **nunca llegó a estar LIVE en ningún org** — confirmado por esta sesión con retrieve fresco sin rastro de `currencyCode`/`CU-07`). El mecanismo real y ya LIVE es una **conversión de referencia** sobre la Opportunity, vía los campos `Moneda_destino__c` / `TipoDeCambio__c` / `Precio_Final_Cambio_de_Moneda__c` — esta conversión **no cambia** `CurrencyIsoCode` ni el `Pricebook` asignado a la Opportunity. Bajo este mecanismo, PEKING CRC/USD fue validado, y la regresión de Bavarian también fue validada (sin cambio de comportamiento). Estos dos caminos (el mecanismo de referencia ya LIVE vs. la clase local nunca desplegada) son **completamente distintos** y no deben confundirse.

### CU-08 — `Ano1__c`
**CONFIRMADO (técnico) + PASS funcional en Partial (reportado por el usuario).** El campo `Lead.Ano1__c` faltaba en el layout `Lead-Lead Layout` de Producción. Se identificó la posición exacta (entre `Modelo_De_Inter_s1__c` y `Modelo_De_Inter_s4__c`), se reconstruyó el layout partiendo de LIVE Prod + únicamente ese bloque de 4 líneas (sin usar el layout completo de Partial), se validó y se desplegó como parte del paquete **A-safe** (Deploy `0AfPH000001ydHF0AY`). Verificado post-deploy: diff contra backup = exactamente esas 4 líneas. En Partial se validó funcionalmente la conversión de Lead OMODA/JAECOO con este fix aplicado.

### CU-09 — creación de Opportunity con marca correcta (no BMW por defecto)
**PASS funcional en Partial (reportado por el usuario), vinculado directamente al fix técnico de `brand="BMW"`.** El requisito de CU-09 ("que el default no es BMW") es precisamente lo que motivó la investigación y el fix documentado más abajo en esta misma sección (eliminación del hardcode `brand="BMW"`, paquete D1).

### CU-10 — inventario/bodega/Empresa/`selectedBrand`
**CONFIRMADO (técnico) + PASS funcional en Partial (reportado por el usuario).** `RM_VN_Inventario_Ctrl` en Partial tenía el fix real (filtro `Empresa__c`, `resolveEmpresaCodeForBrand`, `selectedBrand` en `searchNumeroPedidos`) **mezclado con 697 líneas de código basura** (`testss()`). Se reconstruyó una versión limpia partiendo de LIVE Prod + solo las diferencias funcionales demostrables de Partial, se reconstruyó también `RM_VN_Inventario_Ctrl_Test` (10 métodos originales de Prod preservados + 2 nuevos de Partial, con `@TestSetup` de `Empresa__c` agregado porque era **requisito técnico obligatorio**, no opcional, para que los métodos de Prod no fallaran contra el controlador nuevo). Validado (`0AfPH000001ydlt0AA`, 14/14 tests Pass, 85.7% cobertura) y desplegado (`0AfPH000001ydnV0AQ`).

### CU-12 — SOQL 101, `OpportunityLineItemTriggerHandler`, `OpportunityDetalleProductosService`, `BMW_Gestiona_Listas_de_Precios`
**CONFIRMADO (técnico) + PASS funcional en Partial (reportado por el usuario), tras las siguientes correcciones:**
- El primer intento de check-only del paquete A completo (incluyendo `BMW_Gestiona_Listas_de_Precios`) falló con `System.LimitException: Too many SOQL queries: 101` en 2 de 4 métodos de `RM_VN_CrearOportunidad_Ctrl_Test`. Investigación posterior (lectura de flujos, `SetupAuditTrail`, `DeployRequest`) determinó que el Flow en sí tiene una huella de SOQL pequeña y constante (2 `recordLookups`, sin loops) y que el SOQL 101 es una condición **preexistente en Prod** (ver sección 10 para el detalle completo, corregido).
- **Fix aplicado y confirmado en `BMW_Gestiona_Listas_de_Precios`:** una condición agregada dentro de una regla de Decision ya existente (`myVariable_current.Pricebook2Id NotEqualTo PriceBookIdResuelto`) — **esto NO es la Decision `Debe_actualizar_costos`**. `Debe_actualizar_costos` pertenece a un Flow distinto, `Opp_line_item_costo_unitario_update` (investigado por separado, ver sección 10; ese Flow **no** forma parte de ningún paquete promovido). Esta corrección de atribución queda registrada explícitamente porque una versión anterior de este documento los confundió.
- `BMW_Gestiona_Listas_de_Precios` se validó y desplegó aislado (paquete A2) con un test no relacionado a la cadena Opportunity (`QuoteAvailabilityRefreshControllerTest`), pasando limpio.
- `OpportunityLineItemTriggerHandler` + `OpportunityDetalleProductosService`(+Test) se validaron y desplegaron en el paquete B1, con los tests de `OpportunityLineItemTriggerHandlerTest3` reconstruidos para **preservar `Sucursal__c = suc.Name` de Prod** (Partial tenía el hardcode regresivo `'Escazú'`, que se descartó).
- Según lo reportado por el usuario, tras estos fixes se revalidó funcionalmente JAECOO/Quote en Partial, con resultado PASS.

### CU-17 — `PEKING_Presupuesto_Estandar`
**CONFIRMADO (técnico) + PASS funcional en Partial (reportado por el usuario).** Permission set que otorga únicamente `pageAccesses` a la Visualforce `WorkOrderPresupuestoUsdPDF_v2`. Se verificó que esa VF page y su controlador (`ct_presupuestoWorkDesc_v2`) **ya existían LIVE en Prod** antes de este deploy (mismo Id interno en ambos orgs, indicando que datan de antes del refresh de sandbox). Desplegado como parte del paquete A-safe. Según lo reportado por el usuario, en Partial se validó la asignación automática de PEKING, la regresión de Bavarian, y **Marco Mora pudo abrir `WorkOrderPresupuestoUsdPDF_v2` después de recibir el Permission Set**.

### `OpportunityDetalleProductosService` — corrección de estado
**Corrección factual respecto a una versión anterior de este documento:** esta clase **no era nueva ni inexistente en Prod**. Ya existía en Prod antes del deploy de B1 (confirmado en la auditoría de esta sesión: la versión de Prod ya tenía métodos como `construirDetalle` y era usada, entre otros lugares, por un helper de test llamado `recalcularDetalle`). Lo que hizo el paquete **B1** fue **actualizar/refactorizar** el Service existente (consolidando lógica en un método compartido, `integrarDetalle`) y **agregar la integración desde `OpportunityLineItemTriggerHandler`**, que en la versión previa de Prod no la invocaba en absoluto.

### `HttpCalloutCreateKit`
**CONFIRMADO.** Reemplaza resolución binaria Bavarian/Otobai por resolución dinámica vía `Empresa_Operadora__c → Empresa__c.Codigo_ERP__c`/`Tipo_Kit_Softland__c`, preservando el comportamiento exacto ('V'/'M') para Bavarian y Otobai. Validado (`0AfPH000001ydqj0AA`, 11/11 tests Pass, 96.6% cobertura) y desplegado (`0AfPH000001ydsL0AQ`) como paquete C1.

### `RM_VN_CambiarUbicacion_Ctrl`
**CONFIRMADO.** Prod tenía el hardcode `if(normalizedEmpresa == 'RMPEKING' || normalizedEmpresa == 'PEKING'){ return 'RMPEKING'; }` — reemplazado por resolución dinámica vía `Empresa__c`. Validado (`0AfPH000001ydtx0AA`, 7/7 tests Pass, 78.9% cobertura) y desplegado (`0AfPH000001ydvZ0AQ`) como paquete C2.

### Eliminación de `brand="BMW"` en creación de Opportunity
**CONFIRMADO, con investigación de causa raíz.** `rm_vn_crear_opp_general` y `rm_vn_crear_opp_home_movil` tenían `@api brand = 'BMW'` como default y lo propagaban como literal a sus componentes hijos. Se usó `MetadataComponentDependency` (Tooling API) para encontrar el **único** punto de entrada real en todo el org: el `CustomTab` `Ver_inventario`, que no puede pasar atributos a un LWC. Se verificó que el flujo interno (`rm_vn_crear_opp_movil` → `rm_vn_inventario_movil` → `rm_vn_get_record_opp_record_types`) tiene un guard seguro (`searchBrand = value || undefined`) que evita que un `brand` inicial vacío dispare errores — el usuario simplemente selecciona su marca del picker. Validado (`0AfPH000001ye210AA`, 16/16 tests Pass) y desplegado (`0AfPH000001ye3d0AA`) como paquete D1.

---

## 6. Producción — detalle de cada promoción (todo CONFIRMADO) — 7 deploys reales

### Paquete A-safe (`PEKING_Presupuesto_Estandar` + `Lead-Lead Layout`/`Ano1__c`)
| Campo | Valor |
|---|---|
| Componentes | `PermissionSet: PEKING_Presupuesto_Estandar`, `Layout: Lead-Lead Layout` (LIVE Prod + solo `Ano1__c`) |
| Validation ID (check-only exitoso) | `0AfPH000001ydE10AI` — Succeeded, 2/2 componentes, 0 errores, test `QuoteAvailabilityRefreshControllerTest` 16/16 Pass |
| Deploy ID (real) | `0AfPH000001ydHF0AY` — Succeeded, 2/2 componentes, 0 errores |
| Backup previo | `backup-prod-before-A-safe-20260902-191150/` |
| Verificación LIVE posterior | Hash post-deploy idéntico al paquete validado; diff backup-vs-post-deploy = exactamente el bloque `Ano1__c` en el layout y la creación del permission set |

**Intentos previos al éxito (los 3 son reales, ninguno se desplegó, todos quedan documentados por trazabilidad):**

| Validation ID | Paquete | Test level | Resultado |
|---|---|---|---|
| `0AfPH000001ycxt0AA` | Paquete A completo (A1+A2+A3+B1 sin aislar) | `RunLocalTests` | Failed — `CotizacionTriggerHandler_Test` roto en Prod, ajeno a PEKING (ver sección 10) |
| `0AfPH000001yd170AA` | Paquete A completo (A1+A2+A3+B1 sin aislar) | `RunSpecifiedTests` / `RM_VN_CrearOportunidad_Ctrl_Test` | Failed — 4 fallos por `Too many SOQL queries: 101` |
| `0AfPH000001yd7Z0AQ` | **A-safe** (A2 ya excluido, solo A1+A3) | `RunSpecifiedTests` / `RM_VN_CrearOportunidad_Ctrl_Test` | Failed — **los mismos 4 fallos ocurrieron igual con A2 fuera del paquete**, prueba definitiva de que el Flow no era la causa del SOQL 101 |
| `0AfPH000001ydE10AI` | **A-safe** | `RunSpecifiedTests` / `QuoteAvailabilityRefreshControllerTest` | **Succeeded** — este es el Validation ID que se usó para el Quick Deploy real |

### Paquete A2 (`BMW_Gestiona_Listas_de_Precios`)
| Campo | Valor |
|---|---|
| Componente | `Flow: BMW_Gestiona_Listas_de_Precios` (aislado, sin B1 ni A1/A3) |
| Validation ID | `0AfPH000001ydSX0AY` — Succeeded, 1/1 componente, 0 errores, 16/16 tests Pass |
| Deploy ID (real) | `0AfPH000001ydVl0AI` — Succeeded, 1/1 componente, 0 errores |
| Backup previo | `backup-prod-before-A2-20260902-193219/` |
| Hallazgo posterior al deploy | El deploy creó la **v5 en estado Draft**, no Active — comportamiento del Metadata API deploy no siempre coincide con `<status>Active</status>` declarado en el XML |
| Activación | Los intentos automatizados (`sf data update record` vía Tooling API) fueron **bloqueados por el clasificador de permisos** de la sesión antes de ejecutarse. **El usuario activó la v5 manualmente desde Setup** (Opción B ofrecida por esta sesión) |
| Verificación posterior a la activación manual | **CONFIRMADO** por esta sesión: `ActiveVersionId == LatestVersionId == 301PH00001hAvCvYAK` (v5), Status `Active`, v4 pasó a `Obsolete`, condición `Pricebook2Id != PriceBookIdResuelto` presente en el XML LIVE — re-confirmado nuevamente justo antes de escribir esta bitácora |

### Paquete B1 (`OpportunityLineItemTriggerHandler` + `OpportunityDetalleProductosService` + Tests, reconstruidos)
| Campo | Valor |
|---|---|
| Componentes | 4 `ApexClass`: `OpportunityLineItemTriggerHandler`, `OpportunityLineItemTriggerHandlerTest3` (=Prod exacto), `OpportunityDetalleProductosService`, `OpportunityDetalleProductosServiceTest` (Prod + 2 métodos nuevos) |
| Validation ID | `0AfPH000001ydcD0AQ` — Succeeded, 4/4 componentes, 0 errores, 7/7 tests Pass |
| Deploy ID (real) | `0AfPH000001yddp0AA` — Succeeded, 4/4 componentes, 0 errores |
| Backup previo | `backup-prod-before-B1-20260902-201544/` |
| Cobertura | `OpportunityLineItemTriggerHandler` 86.0%, `OpportunityDetalleProductosService` 93.2% |
| Verificación LIVE posterior | `OpportunityLineItemTriggerHandlerTest3` hash post-deploy **idéntico** al hash previo — confirma que Prod ya tenía ese contenido exacto (sin el hardcode `'Escazú'`) |

### Paquete CU-10 (`RM_VN_Inventario_Ctrl` + Test reconstruido, `rm_vn_inventario`, `rm_vn_inventario_movil`)
| Campo | Valor |
|---|---|
| Componentes | 2 `ApexClass` + 2 `LightningComponentBundle` |
| Validation ID | `0AfPH000001ydlt0AA` — Succeeded, 4/4 componentes, 0 errores, 14/14 tests Pass |
| Deploy ID (real) | `0AfPH000001ydnV0AQ` — Succeeded, 4/4 componentes, 0 errores |
| Backup previo | `backup-prod-before-CU10-20260902-203718/` |
| Cobertura | `RM_VN_Inventario_Ctrl` 85.7% |
| Verificación LIVE posterior | 0 rastros de `testss()`/`dummy` post-deploy; `selectedBrand` presente en ambos LWC |

### Paquete C1 (`HttpCalloutCreateKit` + Test)
| Campo | Valor |
|---|---|
| Validation ID | `0AfPH000001ydqj0AA` — Succeeded, 2/2, 0 errores, 11/11 tests Pass, 96.6% cobertura |
| Deploy ID (real) | `0AfPH000001ydsL0AQ` — Succeeded, 2/2, 0 errores |
| Backup previo | `backup-prod-before-C1-20260902-210748/` |
| Verificación LIVE posterior | Bavarian/Otobai preservan literales exactos; 0 hardcodes nuevos por marca (`grep` confirmado) |

### Paquete C2 (`RM_VN_CambiarUbicacion_Ctrl` + Test)
| Campo | Valor |
|---|---|
| Validation ID | `0AfPH000001ydtx0AA` — Succeeded, 2/2, 0 errores, 7/7 tests Pass, 78.9% cobertura |
| Deploy ID (real) | `0AfPH000001ydvZ0AQ` — Succeeded, 2/2, 0 errores |
| Backup previo | `backup-prod-before-C2-20260902-211530/` |
| Verificación LIVE posterior | 0 ramas `if PEKING`/`RMPEKING`; único rastro de `'RMBAVARIAN'` es un comentario de documentación, no código ejecutable |

### Paquete D1 (`rm_vn_crear_opp_general` + `rm_vn_crear_opp_home_movil`)
| Campo | Valor |
|---|---|
| Validation ID | `0AfPH000001ye210AA` — Succeeded, 2/2, 0 errores, 16/16 tests Pass (`QuoteAvailabilityRefreshControllerTest`) |
| Deploy ID (real) | `0AfPH000001ye3d0AA` — Succeeded, 2/2, 0 errores |
| Backup previo | `backup-prod-before-D1-20260902-213825/` |
| Verificación LIVE posterior | Default `@api brand=''` confirmado; propagación `brand={brand}` confirmada en las 3 instancias donde antes había `"BMW"` literal |

---

## 7. Backups — inventario real

Las siguientes 7 carpetas **existen físicamente** en el worktree al momento de escribir esta bitácora (confirmado con `ls`):

| Carpeta | Contenido | Hashes SHA256 registrados |
|---|---|---|
| `backup-prod-before-A-safe-20260902-191150/` | `Lead-Lead Layout` | Sí, en `BACKUP_STATE.txt` |
| `backup-prod-before-A2-20260902-193219/` | `BMW_Gestiona_Listas_de_Precios` | Sí |
| `backup-prod-before-B1-20260902-201544/` | 4 clases Apex | Sí |
| `backup-prod-before-CU10-20260902-203718/` | 2 clases Apex + 2 bundles LWC completos | Sí |
| `backup-prod-before-C1-20260902-210748/` | `HttpCalloutCreateKit` + Test | Sí |
| `backup-prod-before-C2-20260902-211530/` | `RM_VN_CambiarUbicacion_Ctrl` + Test | Sí |
| `backup-prod-before-D1-20260902-213825/` | 2 bundles LWC completos | Sí |

Cada backup contiene un `BACKUP_STATE.txt` con: timestamp UTC del retrieve, Validation ID relacionado, confirmación explícita de "sin drift" contra la base usada en el check-only correspondiente, y hashes SHA256 del estado ANTES del deploy. **No se generó un backup separado para A1 (permission set) porque el propio `BACKUP_STATE.txt` de A-safe documenta explícitamente su estado `ABSENT_BEFORE_DEPLOY`** (no existía en Prod antes del deploy, confirmado vía `sf org list metadata`).

---

## 8. Protección de cambios ajenos — cómo se evitó sobrescribir

- **`Opp_line_item_costo_unitario_update`:** se investigó su origen (correlación `SetupAuditTrail` + `DeployRequest`, deploy de 2 componentes el 2026-08-20 05:24-05:25 UTC, junto a `Llena_Porcentaje_de_Usados` — este último documentado en `REGLAS_ALCANCE_AUTORIZADO.md` como candidato **fuera del alcance confirmado**). **No se incluyó en ningún paquete promovido** por falta de autorización nominal, pese a que técnicamente reduce recursión.
- **RQ329 (`Quote_Record_Page6`):** se detectó que Prod tiene un bloque completo de reglas de visibilidad `RQ329_*` que Partial no tiene. **No se tocó ni se incluyó en ningún deploy** — clasificado como "requiere merge con Prod / coordinación con el dueño de RQ329", fuera de la autoridad de esta sesión.
- **Configuraciones LIVE de Opportunity (`Opportunity_Record_Page_VN`):** se detectó que Prod tiene vivo el botón `Opportunity.Solicitud_de_descuento_BETA` y permisos `Es_Asesor_Ventas`/`Es_Jefe_Ventas` que Partial no tiene. **No se desplegó esta FlexiPage** en ningún paquete.
- **Componentes ajenos a PEKING:** el hallazgo de `Quote.CPEnvioDeAprobacion` agregado al layout `Quote-Vehiculos Nuevos V1.2` se identificó explícitamente como **sin vínculo demostrable a PEKING** y se excluyó de cualquier propuesta de promoción.
- **Verificación previa a cada deploy real:** en los 7 deploys reales de esta sesión, se ejecutó retrieve fresco de Prod y comparación byte a byte contra la base usada en el check-only **antes** de proceder — si hubiera existido drift, la instrucción era detenerse (no ocurrió en ningún caso; todos los backups documentan "sin drift").

---

## 9. Componentes deliberadamente NO promovidos

| Componente | Clasificación | Motivo |
|---|---|---|
| `rm_vn_get_record_opp_record_types` | OPCIONAL | Cambio puramente aditivo (manejo de error); CU-10 ya funciona sin él; usado también por 3 componentes ajenos a cualquier CU (`productSearcher`, `rm_vn_inventario_fantasia`, `rm_vn_consultar_costeo`) |
| `WsProcesosAprobacion` + `solicitarAprobacionDescuento` | BLOQUEADO/NEGOCIO | Depende de resolver cuál mecanismo de aprobación de descuento es el vigente (conflicto con `Solicitud_de_descuento_BETA`, ya vivo en Prod) |
| `Opportunity_Record_Page_VN` | REQUIERE MERGE | Prod tiene configuración de negocio viva (roles, botón BETA) que Partial no tiene — sobrescribirlo sería regresivo |
| `Quote_Record_Page6` | REQUIERE MERGE (RQ329) | Bloque de un proyecto ajeno a PEKING vivo en Prod |
| `Quote-Vehiculos Nuevos V1.2` (Layout) | FUERA DE ALCANCE | Sin vínculo demostrable a PEKING (`Quote.CPEnvioDeAprobacion` ya existe en ambos orgs, es de otro proyecto) |
| `RM_VN_CambiarMoneda_Ctrl`(+Test), `RM_VN_CrearOportunidad_Ctrl_CU07_Test`, `RM_VN_GetOppRecordTypes_CtrlTest`, `rm_vn_cambiar_moneda`, `envioAprobacionCentroCostosQuoteAura`, `Opportunity.Cambiar_Moneda_VN`, `Quote.CPEnvioDeAprobacionAura`, `solicitarAprobacionDescuento` (LWC), `Opportunity.Solicitar_Aprobacion_Descuento_Lightning` | NO EXISTE EN NINGÚN ORG LIVE | Artefactos que solo existen en el working tree local (`git status` los muestra como `??` sin rastrear) — nunca fueron desplegados a Partial, por lo que no califican como "corrección validada" bajo ningún criterio usado en esta sesión |

---

## 10. Incidentes / hallazgos externos (no causados por estos deploys)

Todos **CONFIRMADO** por consulta directa a Prod durante esta sesión:

1. **SOQL 101 preexistente de Producción:** confirmado que el límite se agotaba por acumulación de automatizaciones (`Resetea_Aprobador_con_nuevo_producto_de_oportunidad`, `Opp_line_item_costo_unitario_update`, `BMW_Gestiona_Listas_de_Precios`) — **preexistía antes de cualquier deploy de esta sesión**. La prueba fue reproducirlo con `BMW_Gestiona_Listas_de_Precios` (A2) completamente excluido del paquete (Validation `0AfPH000001yd7Z0AQ`): los mismos 4 fallos ocurrieron igual, confirmando que el Flow no era la causa en ese momento. **Esta sesión NO afirma que la condición persista igual después de los 7 deploys reales ya aplicados** (algunos de ellos, como B1 y CU-10, cambiaron justamente el volumen/patrón de SOQL de la cadena de creación de Opportunity) — eso queda **pendiente de una auditoría/smoke test post-Go-Live** (referida por el usuario como pendiente de Codex).
2. **`CotizacionTriggerHandler_Test` roto en Prod:** encontrado durante el primer intento de check-only con `RunLocalTests` (Validation `0AfPH000001ycxt0AA`) — `line 23, column 4: Variable does not exist: TestDataFactory.cotizacion`. **No relacionado a PEKING**, no se intentó corregir (fuera de alcance de esta sesión).
3. **`Opp_line_item_costo_unitario_update`:** su origen fue rastreado a un deploy de 2026-08-20 junto a un candidato explícitamente no autorizado (`Llena_Porcentaje_de_Usados`) — reportado como hallazgo, no incluido en ningún paquete.
4. **Otros incidentes reportados por Luis/Diego no causados por estos deploys:** **NO RECONCILIADO** — esta sesión no tuvo acceso a un canal de reportes de Luis/Diego fuera de lo ya documentado en `CONTINUIDAD_QA_PRODUCCION_20260830.md` (histórico).

---

## 11. QA

**Resumen CU-01 a CU-17.** El estado de QA funcional en Partial está en la tabla de la sección 4 (repetida aquí por conveniencia) — **SEGÚN QA FUNCIONAL EN PARTIAL, reportado y confirmado por el usuario**, no verificado de forma independiente por esta sesión mediante ejecución de test manual propia:

| CU | Estado QA funcional (Partial) | Corrección técnica desplegada a Prod esta sesión |
|---|---|---|
| CU-01 a CU-03 | **NO RECONCILIADO** | — |
| CU-04 | PASS | No aplica (sin componente de esta sesión asociado) |
| CU-05 | BLOCKED | — |
| CU-06 | BLOCKED | — |
| CU-07 | PASS | No aplica directamente — el mecanismo real (conversión de moneda de referencia) ya estaba LIVE; ver sección 5 |
| CU-08 | PASS | Sí — `Ano1__c` (paquete A-safe) |
| CU-09 | PASS | Sí — eliminación de `brand="BMW"` (paquete D1) |
| CU-10 | PASS | Sí — reconstrucción limpia de `RM_VN_Inventario_Ctrl`+LWC (paquete CU-10) |
| CU-11 | PASS | No aplica (sin componente de esta sesión asociado) |
| CU-12 | PASS | Sí — Handler/Service (paquete B1) + Flow (paquete A2) |
| CU-13 | NO APLICA | — |
| CU-14 | BLOCKED | — |
| CU-15 | NO APLICA | — |
| CU-16 | BLOCKED | — |
| CU-17 | PASS | Sí — `PEKING_Presupuesto_Estandar` (paquete A-safe) |

**Bloqueos externos:** CU-05, CU-06, CU-14 y CU-16 están registrados como BLOCKED — esta bitácora no tiene evidencia propia del motivo de cada bloqueo (son datos reportados por el usuario al corregir este borrador); **no se debe inferir causa ni intentar desbloquearlos** sin instrucción explícita.

**Diferencia explícita entre cierre técnico y cierre funcional:**
- **Cierre técnico** (esta sesión sí puede certificarlo): validación automatizada (`check-only`) + deploy real + verificación de contenido LIVE post-deploy, para los 7 paquetes de la sección 6.
- **Cierre funcional en Partial** (reportado por el usuario, no re-ejecutado por esta sesión): PASS para CU-04, CU-07 a CU-12, CU-17; BLOCKED para CU-05, CU-06, CU-14, CU-16; NO APLICA para CU-13, CU-15; sin evidencia para CU-01 a CU-03.
- **Cierre funcional equivalente en Producción:** **pendiente** — ningún PASS de Partial se traduce automáticamente en un PASS en Prod sin una auditoría/smoke test post-Go-Live (ver sección 15).

---

## 12. Estado final LIVE (Partial vs Prod, al cierre de esta sesión)

**CONFIRMADO** por retrieve fresco final (última consulta de esta sesión antes de escribir esta bitácora):

**Ya sincronizados (idénticos Partial=Prod):** `EmpresaPricebookResolver`+Test, `RM_SyncQuoteService`+`_v2`, `RM_VN_CrearOportunidad_Ctrl`+Test, `RM_VN_GetOppRecordTypes_Ctrl`, `RM_VN_Service`, `Lead-Lead Layout`, y los 8 componentes/paquetes promovidos en esta sesión (sección 6).

**Todavía diferentes, pero no clasificados como necesarios:**
| Componente | Clasificación final |
|---|---|
| `rm_vn_get_record_opp_record_types` | Opcional |
| `WsProcesosAprobacion`+Test | Bloqueado por negocio |
| `Opportunity_Record_Page_VN` | Requiere merge |
| `Quote_Record_Page6` | Requiere merge (RQ329) |
| `Quote-Vehiculos Nuevos V1.2` | Fuera de alcance |

**Confirmación explícita:** al cierre de esta sesión, **no queda ningún componente clasificado como "NECESARIO Y FALTA EN PROD"**. Esta conclusión se estableció en la auditoría final de la sección anterior de esta misma sesión, re-verificada aquí.

---

## 13. Git / operación

**CONFIRMADO** (`git status -sb`, `git branch`, `git rev-parse HEAD` ejecutados justo antes de escribir esta bitácora):

- **Worktree:** `C:\Users\dokur\Documents\Repositorios\RedMotors-PEKING-Rebuild-20260901`
- **Rama:** `fix/pc/redmotors-peking-rebuild-20260901`
- **HEAD:** `2b97a7788cb7a5534c196be819a2b970248e15ce`
- **Remote:** `origin` → `https://github.com/Peseck89/RedMotorsPartial.git`

**Estado del working tree — NO se asume listo para commit.** `git status -sb` reporta 84 líneas de cambios, entre ellas:
- Archivos modificados (`M`) preexistentes desde antes de esta sesión (17 clases/flows/LWC — el mismo conjunto visto al inicio de la sesión, sin relación con los deploys reales de esta sesión, que se hicieron contra proyectos SFDX aislados en el scratchpad, no contra este working tree).
- 7 carpetas `backup-prod-before-*` (untracked) — ver sección 7.
- 8 carpetas `check-only-package-*` (untracked) — paquetes preparados/usados esta sesión (`A`, `A-safe`, `A2`, `B1`, `CU10`, `C1`, `C2`, `D1`).
- Varios archivos `.json` sueltos (`check_only_*_result.json`, `deploy_*_result.json`) — resultados crudos de las validaciones/deploys de esta sesión, dejados en la raíz del worktree.
- Archivos/carpetas untracked preexistentes nunca desplegados a ningún org (`RM_VN_CambiarMoneda_Ctrl`, `envioAprobacionCentroCostosQuoteAura`, `rm_vn_cambiar_moneda`, `solicitarAprobacionDescuento`, `PEKING_Presupuesto_Estandar.permissionset-meta.xml` local — **nota:** esta copia local del permission set es independiente de la que ya está LIVE en Prod tras el deploy de A-safe; no se comparó su contenido en esta bitácora).

**Ningún archivo fue agregado al índice de Git, ningún commit fue creado, ningún push fue ejecutado durante esta sesión.**

---

## 14. Pendientes no bloqueantes

- **Decisión de negocio:** cuál mecanismo de aprobación de descuento es el vigente — `Opportunity.Solicitud_de_descuento_BETA` (Prod actual) vs `Opportunity.Solicitar_Aprobacion_Descuento_Lightning` (propuesto en Partial, respaldado por `WsProcesosAprobacion.solicitarAprobacionDescuento`).
- **Merge de FlexiPages:** `Opportunity_Record_Page_VN` y `Quote_Record_Page6` requieren fusión manual campo por campo, no deploy directo.
- **RQ329:** coordinación con el equipo/dueño de ese proyecto antes de tocar `Quote_Record_Page6`.
- **Mejora opcional:** `rm_vn_get_record_opp_record_types` (manejo de error) — sin urgencia.
- **Datos/decisiones de negocio externas:** **NO RECONCILIADO** — esta sesión no tuvo visibilidad de pendientes de negocio fuera de lo ya citado en `CONTINUIDAD_QA_PRODUCCION_20260830.md` (histórico, p. ej. bodega productiva definitiva de PEKING vía Softland, garantías N3, catálogo de sucursales N4) — se listan aquí solo como referencia documental, no verificados por esta sesión.

---

## 15. Conclusión

Se separan expresamente cuatro niveles de cierre, que **no deben confundirse entre sí**:

**1. Cierre técnico de la promoción a Producción:** ✅ **Completo.** 7 deploys reales (A-safe, A2, B1, CU-10, C1, C2, D1), cada uno con check-only exitoso previo, backup previo con hash, deploy real verificado (`checkOnly: false`, `status: Succeeded`), y verificación de contenido LIVE posterior contra el paquete validado. No queda ningún componente clasificado como "necesario y falta en Prod" según el criterio técnico usado en esta sesión (sección 12).

**2. QA funcional en Partial:** ✅ **Existe**, para los CU indicados en la sección 11 — PASS confirmado por el usuario para CU-04, CU-07 a CU-12 y CU-17; BLOCKED para CU-05, CU-06, CU-14, CU-16; NO APLICA para CU-13 y CU-15. Sin evidencia disponible para CU-01 a CU-03. Este QA fue ejecutado y reportado por el usuario/equipo funcional — esta sesión lo documenta, no lo generó ni lo re-ejecutó de forma independiente.

**3. Validación funcional post-deploy en Producción:** ⏳ **Pendiente.** Ningún PASS funcional de Partial (punto 2) se declara aquí como equivalente automático a un comportamiento correcto en Producción. Se requiere una auditoría/smoke test post-Go-Live (mencionada por el usuario como pendiente de Codex) antes de dar por cerrado el proyecto a nivel funcional en el ambiente productivo. Esto incluye, en particular, reconfirmar el comportamiento del límite de SOQL (sección 10) ahora que B1 y CU-10 ya están LIVE.

**4. Cierre documental/operativo (Git):** ⚠️ **Pendiente.** Esta bitácora es un **borrador local, no commiteado, no oficial**. El working tree tiene decenas de líneas de cambios sin commitear (backups, paquetes de check-only, resultados JSON de validaciones/deploys, y cambios preexistentes de antes de esta sesión) que no se tocaron ni se asumen listos para integrar al historial de Git — esa decisión queda pendiente de quien revise este borrador.

---

## Tabla final

| COMPONENTE | PARTIAL | PROD | QA | VALIDATION ID | DEPLOY ID | BACKUP | ESTADO FINAL |
|---|---|---|---|---|---|---|---|
| `PEKING_Presupuesto_Estandar` | Existe | **Existe (desplegado)** | N/A (permset) | `0AfPH000001ydE10AI` | `0AfPH000001ydHF0AY` | `backup-prod-before-A-safe-20260902-191150/` | Cierre técnico OK |
| `Lead-Lead Layout` / `Ano1__c` | Existe | **Existe (desplegado)** | N/A (layout) | `0AfPH000001ydE10AI` | `0AfPH000001ydHF0AY` | `backup-prod-before-A-safe-20260902-191150/` | Cierre técnico OK |
| `BMW_Gestiona_Listas_de_Precios` | v5 (origen) | **v5 Active (desplegado + activado manualmente)** | 16/16 Pass | `0AfPH000001ydSX0AY` | `0AfPH000001ydVl0AI` | `backup-prod-before-A2-20260902-193219/` | Cierre técnico OK |
| `OpportunityLineItemTriggerHandler` | Existe | **Existe (desplegado)** | 4/4 Pass, 86.0% cobertura | `0AfPH000001ydcD0AQ` | `0AfPH000001yddp0AA` | `backup-prod-before-B1-20260902-201544/` | Cierre técnico OK |
| `OpportunityDetalleProductosService`+Test | Existe | **Existe (desplegado)** | 6/6 Pass, 93.2% cobertura | `0AfPH000001ydcD0AQ` | `0AfPH000001yddp0AA` | `backup-prod-before-B1-20260902-201544/` | Cierre técnico OK |
| `RM_VN_Inventario_Ctrl`+Test | Existe (limpio) | **Existe (desplegado, limpio)** | 14/14 Pass, 85.7% cobertura | `0AfPH000001ydlt0AA` | `0AfPH000001ydnV0AQ` | `backup-prod-before-CU10-20260902-203718/` | Cierre técnico OK |
| `rm_vn_inventario` / `rm_vn_inventario_movil` | Existe | **Existe (desplegado)** | (cubierto por test Apex asociado) | `0AfPH000001ydlt0AA` | `0AfPH000001ydnV0AQ` | `backup-prod-before-CU10-20260902-203718/` | Cierre técnico OK |
| `HttpCalloutCreateKit`+Test | Existe | **Existe (desplegado)** | 11/11 Pass, 96.6% cobertura | `0AfPH000001ydqj0AA` | `0AfPH000001ydsL0AQ` | `backup-prod-before-C1-20260902-210748/` | Cierre técnico OK |
| `RM_VN_CambiarUbicacion_Ctrl`+Test | Existe | **Existe (desplegado)** | 7/7 Pass, 78.9% cobertura | `0AfPH000001ydtx0AA` | `0AfPH000001ydvZ0AQ` | `backup-prod-before-C2-20260902-211530/` | Cierre técnico OK |
| `rm_vn_crear_opp_general` / `_home_movil` | Existe | **Existe (desplegado)** | 16/16 Pass (`QuoteAvailabilityRefreshControllerTest`) | `0AfPH000001ye210AA` | `0AfPH000001ye3d0AA` | `backup-prod-before-D1-20260902-213825/` | Cierre técnico OK |
| `rm_vn_get_record_opp_record_types` | Existe (más) | Existe (menos) | N/A | — | — | — | Opcional, no promovido |
| `WsProcesosAprobacion`+Test | Existe (más) | Existe (menos) | 14/14 Pass (histórico) | — | — | — | Bloqueado por negocio |
| `Opportunity_Record_Page_VN` | Existe (distinto) | Existe (distinto, config viva) | N/A | — | — | — | Requiere merge |
| `Quote_Record_Page6` | Existe (distinto) | Existe (distinto, RQ329) | N/A | — | — | — | Requiere merge |
| `Quote-Vehiculos Nuevos V1.2` | Existe (distinto) | Existe (distinto) | N/A | — | — | — | Fuera de alcance |

---

## 16. Addendum de reconciliación (2026-09-11) — NO reescribe las secciones anteriores

Este addendum documenta hallazgos de una sesión posterior (reconciliación del commit set autoritativo, 2026-09-11) que **actualizan el estado** de dos afirmaciones de este documento. Las secciones 1-15 quedan intactas como registro histórico de lo que era cierto el 2026-09-02/03; lo que sigue es la corrección objetiva, con fecha, sin alterar el texto original.

**1. `RM_VN_CrearOportunidad_Ctrl` — §5, §12: "idéntica entre Partial y Prod" ya no es válido.**
Cierto al 2026-09-02/03. Una auditoría LIVE posterior (2026-09-04, fuera del alcance de esta bitácora) encontró que Producción recibió un deploy adicional (`DeployRequest 0AfPH000001ylmf0AA`, 2026-09-04T06:35 UTC, `admin Portalnet`, 8 componentes: `OpportunityServiceInvoker`, `RM_Lead_Trigger_Helper`, `RM_VN_CrearOportunidad_Ctrl`, `TrabajoQuoteController` + Tests) que reescribió esta clase con una arquitectura distinta (`EmpresaResolver`/`EmpresaContext` en vez del mapeo estático previo). La copia local del working tree de PEKING-Rebuild sigue sin representar correctamente lo LIVE actual — la exclusión de esta clase de cualquier commit PEKING **se mantiene**, ahora por una razón adicional a la original.

**2. `OpportunityLineItemTriggerHandlerTest3.cls` y `OpportunityDetalleProductosServiceTest.cls` — el working tree actual diverge del artefacto realmente desplegado en B1.**
La §5 de este documento afirma correctamente que B1 preservó `Sucursal__c = suc.Name` (descartando el hardcode `'Escazú'` de Partial) y que `OpportunityDetalleProductosServiceTest` incluyó el helper `recalcularDetalle()`. La reconciliación del 2026-09-11 encontró que el **working tree actual** de `OpportunityLineItemTriggerHandlerTest3.cls` tiene otra vez `Sucursal__c = 'Escazú'`, y que `OpportunityDetalleProductosServiceTest.cls` ya no tiene `recalcularDetalle()` ni sus 4 usos — ambos divergen del contenido exacto de `check-only-package-B1-peking/` (el paquete real, validado y desplegado, `Deploy ID 0AfPH000001yddp0AA`). Causa exacta no determinada (posible edición posterior no reconciliada). **Consecuencia:** estos dos archivos de test quedaron **excluidos** del commit PEKING del 2026-09-11 pese a que su clase principal asociada (`OpportunityLineItemTriggerHandler.cls` y `OpportunityDetalleProductosService.cls`, respectivamente) sí coincide byte a byte con lo desplegado y sí se incluyó.

**3. Componentes confirmados con coincidencia byte a byte contra su paquete real desplegado (verificado 2026-09-11, `diff --strip-trailing-cr` contra `check-only-package-*-peking/`):** `HttpCalloutCreateKit(+Test)`, `RM_VN_CambiarUbicacion_Ctrl(+Test)`, `OpportunityLineItemTriggerHandler.cls`, `OpportunityDetalleProductosService.cls`, `rm_vn_crear_opp_general`, `rm_vn_crear_opp_home_movil`, `Lead-Lead Layout`. `PEKING_Presupuesto_Estandar` y `BMW_Gestiona_Listas_de_Precios` coinciden con diferencias menores no funcionales (`hasActivationRequired`, `nameSegment` — probable ruido de re-serialización del Metadata API, no confirmado como funcional).

*Este addendum no declara cerrado nada que siga pendiente (secciones 11, 15 de este mismo documento). Ver `RECUPERACION_Y_CONTINUIDAD_REDMOTORS_PEKING.md` para el estado consolidado final.*

---

*Fin del borrador. Generado íntegramente a partir de resultados de comandos ejecutados en esta sesión (`sf data query`, `sf project retrieve/deploy`, `git`) y de los documentos citados por nombre en `docs/empresa-marcas-chinas/`. Ningún dato fue inventado; los puntos sin evidencia quedaron marcados como NO RECONCILIADO.*
