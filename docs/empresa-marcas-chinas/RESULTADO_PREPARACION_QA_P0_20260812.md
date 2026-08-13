# Resultado — preparación dirigida de QA P0 de Sprint 2

**Fecha:** 12 de agosto de 2026

**Ambiente:** `RedMotorsSandbox` (Partial)

**Tipo de bloque:** preparación y ejecución controlada de QA en Partial; Permission Set temporal y datos QA mínimos

## Resultado ejecutivo

| Flow | Versión activa | Clasificación de QA | Estado alcanzado |
|---|---:|---|---|
| `Opp_flow_V3` | v30 (`301AK00000PW6LeYAL`) | C — manual | **QA DE CREACIÓN OK — NAVEGACIÓN REMEDIADA; QA MANUAL DEL ENLACE PENDIENTE** |
| `Opp_Flow_v6` | v82 (`301AK00000PWE36YAH`) | C — manual | **QA CREACIÓN OK — NAVEGACIÓN REMEDIADA; QA MANUAL DEL ENLACE PENDIENTE** en ruta Taller; Mostrador requiere una sesión funcional autorizada de ese tipo |
| `Opportunity_Flow_V2` | v8 (`301AK00000PWLPYYA5`) | C — manual | **QA CREACIÓN OK — NAVEGACIÓN REMEDIADA; QA MANUAL DEL ENLACE PENDIENTE** en ruta Taller/general; Mostrador requiere una sesión funcional autorizada de ese tipo |
| `PlanDeMantenimientoV2` | v24 (`301AK00000PC2ngYAD`) | C — manual | **BLOQUEO DE NEGOCIO**: no existe Quote PEKING con línea de vehículo; falta catálogo de vehículo PEKING y definición de término/plan aplicable |
| `CreateWoliFromExpense` | v16 (`301AK00000PWXVVYA5`) | **QA FUNCIONAL OK — PEKING** | Selección estructural del producto `SUB` de tipo `Subcontrato`, PBE CRC activa en `PEKING Local` y creación única del WOLI desde `EXP-1458` verificadas |
| `AgregarManoObra` | v4 (`301AK00000PWR5CYAX`) | **QA FUNCIONAL OK — PEKING** | La carga colectiva, selección de `BSI / SAD001`, procesamiento del checkbox no marcado y creación persistida de un único WOLI y Subtipo quedaron confirmados sin fault ni rollback |

La remediación de acceso QA fue autorizada y desplegada únicamente en Partial. El primer QA demostró un defecto de configuración/determinismo en `CreateWoliFromExpense`; la remediación técnica limitada y su validación funcional quedaron completadas el 13 de agosto de 2026, sin ampliar el alcance.

## Evidencia común reutilizable

El caso listo utiliza únicamente registros QA ya existentes:

- usuario funcional QA activo `Control de Calidad` (`0050P0000074Bf7QAE`), perfil `New Asesor Postventa`;
- configuración del usuario: tipo de oportunidad `Taller`, sucursal `Uruca`, moneda `CRC` y Empresa legacy `Bavarian`;
- Permission Set `Empresa_Consulta_Flows` asignado;
- Asset `02iAK000001xtZNYAY`, placa/VIN `VNA00260810051041`;
- Account y Contact asociados: `QA Prueba`;
- `Marca_Nvo__c = BMW Automovil`;
- Empresa estructural `PEKING` activa;
- Pricebook `PEKING Local` activo, moneda `CRC`.

La diferencia entre `User.Empresa__c = Bavarian` y la selección estructural `PEKING` permite comprobar expresamente que el lookup nuevo prevalece sin extender el mecanismo legacy.

## `Opp_flow_V3`

- La ejecución funcional de v29 creó y conservó la Opportunity `006AK00000JTVVJYA5` y el Quote `0Q0AK000001zPyb0AE` con Empresa `PEKING`, moneda `CRC`, Pricebook `PEKING Local`, Cuenta y Asset correctos.
- La creación funcional queda en **QA OK**: `Empresa_Operadora__c = PEKING`, `BMW_Compania__c` vacío y sin fault ni rollback.
- El único defecto observado fue la falta de navegación del componente legacy `ecflc:flowIdRedirect` en la pantalla final, aun cuando `presupuestoid` contenía el Quote correcto.
- La navegación fue remediada de forma aislada mediante el enlace estándar `/lightning/r/Quote/{!presupuestoid}/view`; v30 (`301AK00000PW6LeYAL`) está activa.
- La ruta ejecutable no contiene nombres ni identificadores fijos de Pricebook.
- La integración del enlace dentro de v30 queda pendiente de una comprobación manual en la siguiente ejecución funcional normal. No debe crearse otra Opportunity únicamente para repetir evidencia.
- Evidencia completa: [`RESULTADO_QA_REMEDIACION_OPP_FLOW_V3_20260812.md`](RESULTADO_QA_REMEDIACION_OPP_FLOW_V3_20260812.md).

## `Opp_Flow_v6`

- La definición activa es v82 (`301AK00000PWE36YAH`). La serialización moderna omite propiedades visuales/defaults preexistentes, pero conserva el grafo y los elementos funcionales de Empresa/Pricebook.
- Hay dos entrevistas v80 abandonadas después de la primera pantalla; no constituyen QA.
- La nueva entrevista v80 (`8gZAK000000IgaH2AS`) falló en `CreateQuote` porque `Quote.Compania__c`, picklist legacy restringido, recibió `PEKING`. Opportunity y Quote fueron revertidos.
- Se sustituyó únicamente la fuente por `EmpresaLegacySeleccionada`: Bavarian/Otobai conservan sus valores y PEKING deja el campo legacy vacío. El dry-run `0AfAK0000014Amb0AE` y el deploy `0AfAK0000014AoD0AU` fueron exitosos.
- El QA v81 creó y conservó Opportunity `006AK00000JTWT1YAP` y Quote `0Q0AK000001zNQZ0A2` con PEKING, CRC, `PEKING Local`, Cuenta, Contacto, Asset y territorio correctos; la creación queda en **QA OK**.
- La pantalla final usaba el mismo `ecflc:flowIdRedirect` defectuoso de los Flows ya remediados. Se sustituyó únicamente por el enlace estándar al Quote; v82 está activa y la navegación integrada queda pendiente de QA manual.
- `Empresa_Operadora__c` y `Resolver_Pricebook_Empresa` permanecen intactos. Mostrador requiere una sesión funcional autorizada con tipo `Mostrador` o `Todas`.
- Evidencia completa: [`RESULTADO_REMEDIACION_OPP_FLOW_V6_20260812.md`](RESULTADO_REMEDIACION_OPP_FLOW_V6_20260812.md).

## `Opportunity_Flow_V2`

- El QA v7 quedó identificado por el GUID `31656edfaf899d2705c10b59fc519ff96325cc-61d2` y no registró faults.
- Los selectores `EmpresaSeleccionada` y `EmpresaSeleccionadaMostrador` están en las rutas general y Mostrador respectivamente.
- La ruta general/Taller creó y conservó Opportunity `006AK00000JTeqQYAT` y Quote `0Q0AK000001zZuj0AE` con PEKING, CRC, `PEKING Local`, Account, Asset y territorio correctos; la creación queda en **QA OK**.
- La pantalla final usaba el mismo `ecflc:flowIdRedirect` defectuoso de los otros Flows remediados. Se sustituyó únicamente por el enlace estándar al Quote; v8 está activa y la navegación integrada queda pendiente de QA manual.
- La ruta Mostrador continúa pendiente de una sesión funcional autorizada con tipo `Mostrador` o `Todas`.
- Evidencia completa: [`RESULTADO_QA_REMEDIACION_OPPORTUNITY_FLOW_V2_20260812.md`](RESULTADO_QA_REMEDIACION_OPPORTUNITY_FLOW_V2_20260812.md).

## P0 de planes y mano de obra

Los cinco `PricebookEntry` provisionales de `SAD001` y las dos variantes funcionales `SUB` para PEKING continúan activos y resuelven N1 a nivel técnico. Sin embargo, esa configuración no sustituye los registros funcionales de entrada:

- `PlanDeMantenimientoV2`: se revisaron los seis Quotes QA PEKING `PT-00080231` a `PT-00080236`; todos tienen `PEKING Local`, CRC y Opportunity con `Empresa_Operadora__c = PEKING`, pero contienen **cero QuoteLineItem**. Tampoco existe en Partial otro Quote PEKING con una línea `BMW_TipoDeArticulo__c = Vehiculo`.
- El Asset QA `VNA00260810051041` no tiene `Product2Id`. `PEKING Local` contiene tres PricebookEntry activas: `SAD001` (BSI), `SUB` de Mano de Obra y `SUB` de Subcontrato; no existe una entrada de vehículo de la que pueda derivarse de forma segura la QuoteLineItem seleccionable.
- El Flow resuelve correctamente `SAD001` en `PEKING Local`, por lo que N1 no bloquea la ruta. El término se selecciona mediante `Plan_de_mantenimiento__c.Warranty_Term__c` y el Flow solo acepta `WarrantyUnitOfTime = Years`. Existen 13 términos activos en años, sin filtro de lookup ni relación con Empresa/Pricebook, pero todos pertenecen a tipos legacy BSI BMW/MINI/Motorrad. Elegir cuál aplica a PEKING y qué tipo de plan usar requiere definición de negocio; no se infirió por baseline.
- `CreateWoliFromExpense` v16 (`301AK00000PWXVVYA5`) es un Flow after-save sobre `Expense`. Se dispara al crear o actualizar un Expense cuyo `ExpenseType` sea exactamente `Facturable`; no tiene entrada manual. Resuelve Empresa primero desde `WorkOrder.empresaFacturaCP__c` y conserva el fallback legacy únicamente para Bavarian/Otobai. Con Empresa, moneda de la orden y Pricebook actual invoca `EmpresaPricebookResolver`, exige estado `EXITO` y una PricebookEntry activa del producto cuyo código es `SUB`, tipo `Subcontrato` y estado activo. Según `WoliCreated__c`, crea o actualiza un `WorkOrderLineItem`; al crear, marca el Expense y guarda el Id del WOLI.
- Para ese Flow se verificaron los 9.959 Work Orders disponibles mediante relaciones consultables. No existe ninguno con `PEKING Local`, ninguno ligado a una Opportunity con `Empresa_Operadora__c = PEKING`, y ninguno asociado al Account/Asset QA usados en este Sprint. El lookup `WorkOrder.empresaFacturaCP__c` existe y es la fuente de la versión activa, pero el usuario de consulta no tiene FLS para leer sus valores directamente; por tanto no se reutilizó ningún registro cuya asociación estructural completa no pudiera demostrarse.
- Existen únicamente dos Expenses `Facturable` con `WoliCreated__c = false`: `EXP-0001` (`1V44U0000010wBVSAY`) y `EXP-0003` (`1V44U0000010wFnSAI`). Ambos tienen `WorkOrderId = null`, por lo que no son candidatos válidos. Los Expenses procesados ya apuntan a WOLI y no deben reutilizarse.
- La comparación de Expenses Bavarian procesados confirmó que `CreateWoliFromExpense` crea la línea con el producto cuyo código es `SUB`; el título del Expense no decide el producto. `EXP-1446` (`1V4PH0000001GAn0AM`) conserva un patrón exitoso trazable: CRC, categoría vacía, `CalculoGanancia__c = Ingresar valor`, `PrecioCliente__c` trasladado sin transformación a `UnitPrice` y producto `SUB`. Su importe operativo no se copia. No se encontró un Expense QA exitoso de 1 CRC, por lo que el valor mínimo `1` se clasifica como propuesta técnica QA, no como baseline de negocio.
- `AgregarManoObra` v4 (`301AK00000PWR5CYAX`) es un Screen Flow cuyo input `recordId` corresponde a `tiposDeTrabajoCaso__c`, no a WorkOrder. Desde ese registro obtiene el Case y luego el primer WorkOrder del Case. La prueba requiere un Case aislado con un único WorkOrder PEKING, porque el lookup de WorkOrder no tiene orden explícito; un Case con varias órdenes produciría una selección ambigua. La orden debe tener Empresa estructural, moneda y Pricebook coherentes. `ServiceTerritoryId` no se filtra en este Flow, pero debe permanecer válido en la orden base.
- El Flow consulta una vez los `Product2` con `tipoProducto__c = Mano de Obra`, construye en memoria su colección de Ids y consulta colectivamente las `PricebookEntry` cuyo `Pricebook2Id` coincide con el Pricebook resuelto y cuyo `Product2Id` pertenece a esa colección. Permite seleccionar una o más entradas y crea colecciones de `WorkOrderLineItem` y `Subtipo_de_trabajo_del_caso__c`; solicita alias, cantidad en horas o UTS y descuento opcional.
- `PEKING Local` (`01sAK0000006DVdYAM`, CRC) está activo y relacionado con PEKING. Contiene dos PricebookEntry activas de mano de obra: `SAD001 / BSI` (`01uAK000000YRDtYAO`) y `SUB / Subcontratos Taller Externo Autos` (`01uAK000000YRH7YAO`), ambas con precio unitario 1. Son los mismos productos compartidos que tienen entradas activas en los Pricebooks Bavarian y Otobai; no se necesita crear producto ni PricebookEntry.
- No existe un `tiposDeTrabajoCaso__c` claramente QA cuyo Case carezca de WorkOrder. Los casos sin orden encontrados pertenecen a datos funcionales existentes y no son reutilizables. El Case QA de referencia `00091070` tampoco sirve: ya contiene más de un WorkOrder Bavarian y el Flow podría elegir cualquiera.
- Tres Work Orders Bavarian recientes y equivalentes —`00087374`, `00087369` y `00087363`— repiten el mismo patrón neutro: Case `Autos` en `Cita`, origen `Calendario`, estado de orden `Nuevo`, CRC, `Uruca - Mecánica General` y Work Type `Mecánica General Autos` (`08qPH0000003dhZYAQ`). Sus cuentas, contactos, Assets, propietarios, Pricebook y compañía legacy no se copian.
- El tipo `-Control final` (`a2jPH00000AChZhYAL`) es el valor genérico con mayor evidencia de uso en el baseline revisado: 265 registros `tiposDeTrabajoCaso__c` con cargo `Cliente` y 207 relaciones posteriores a subtipo en órdenes Bavarian de Mecánica General. Los registros recientes repiten CRC, `RM_EsTrabajoAdicional__c = true`, `RM_ModoTrabajo__c = null` y `Status__c = null`. `AgregarManoObra` usa el registro como contenedor para localizar Case/WorkOrder; no usa `Tipotrabajo__c` para resolver Empresa, Pricebook ni producto.

### PRE-DML LISTO PARA AUTORIZACIÓN

Ambos Flows permanecen como **B — QA PREPARABLE CON DML MÍNIMO**. Todos los datos necesarios quedaron derivados y no queda una decisión de negocio tipo D. Un único Case con un único WorkOrder puede servir a ambos: el Expense añade una línea al WorkOrder, mientras `AgregarManoObra` localiza ese mismo WorkOrder por el Case sin exigir que esté vacío.

Clasificación utilizada: **A** derivado técnicamente; **B** baseline Bavarian válido y neutral; **C** dato técnico de QA propuesto; **D** requiere negocio.

| Objeto | Campo | Valor propuesto | Fuente/evidencia | Derivable | Clase |
|---|---|---|---|---|---|
| Case | `RecordTypeId` | `0124U00000111E9QAI` (`Autos`) | Record Type activo y patrón de los tres Cases baseline | Sí | B |
| Case | `Status` | `Cita` | Valor inicial predeterminado y repetido en los tres baselines | Sí | B |
| Case | `Origin` | `Calendario` | Valor inicial predeterminado y repetido en los tres baselines | Sí | B |
| Case | `Subject` | `QA PEKING Sprint2 - WorkOrder Flows` | Nomenclatura temporal inequívoca | Sí | C |
| Case | `Description` | `null` | Campo opcional; baseline equivalente vacío | Sí | B |
| Case | `AccountId` | `001PH00001O6pqGYAR` | Account QA `QA Prueba` | Sí | A |
| Case | `ContactId` | `003PH00001VYijKYAT` | Contact QA `QA Prueba`, asociado al mismo Account | Sí | A |
| Case | `AssetId` | `02iAK000001xtZNYAY` | Asset QA `VNA00260810051041`, asociado al mismo Account/Contact | Sí | A |
| Case | `CurrencyIsoCode` | `CRC` | Moneda PEKING/Pricebook y baseline Taller | Sí | A |
| Case | `Service_Territory1__c` | `0Hh4U0000010wVFSAY` | `Uruca - Mecánica General`, repetido en baselines | Sí | B |
| Case | `OwnerId` | `0050P0000074Bf7QAE` | Usuario funcional QA activo `Control de Calidad`; se fija para no depender del ejecutor del DML | Sí | C |
| Case | `CaseNumber` | generado por Salesforce | Campo autonumérico, no se envía | Sí | A |
| WorkOrder | `CaseId` | Id del Case creado en el paso 1 | Relación requerida por ambos Flows | Sí | A |
| WorkOrder | `AccountId` | `001PH00001O6pqGYAR` | Mismo Account QA del Case/Asset | Sí | A |
| WorkOrder | `ContactId` | `003PH00001VYijKYAT` | Mismo Contact QA del Case/Asset | Sí | A |
| WorkOrder | `AssetId` | `02iAK000001xtZNYAY` | Mismo Asset QA | Sí | A |
| WorkOrder | `Status` | `Nuevo` | Valor inicial predeterminado y repetido en los tres baselines | Sí | B |
| WorkOrder | `CurrencyIsoCode` | `CRC` | Moneda de `PEKING Local` | Sí | A |
| WorkOrder | `Pricebook2Id` | `01sAK0000006DVdYAM` (`PEKING Local`) | Pricebook activo relacionado con PEKING | Sí | A |
| WorkOrder | `empresaFacturaCP__c` | `a1UAK0000009wft2AA` (PEKING) | Lookup estructural a `Empresa__c` usado por ambos Flows | Sí | A |
| WorkOrder | `empresaFactura__c` | `null` explícito | El default del campo es `RMBAVARIAN`; debe neutralizarse porque el mecanismo legacy no representa PEKING | Sí | A |
| WorkOrder | `ServiceTerritoryId` | `0Hh4U0000010wVFSAY` | `Uruca - Mecánica General` | Sí | B |
| WorkOrder | `WorkTypeId` | `08qPH0000003dhZYAQ` (`Mecánica General Autos`) | Patrón repetido en los tres Work Orders baseline | Sí | B |
| WorkOrder | `Subject` | `QA PEKING Sprint2 - WorkOrder Flows` | Nomenclatura temporal inequívoca | Sí | C |
| WorkOrder | `Description` | `null` | Campo opcional; baseline equivalente vacío | Sí | B |
| WorkOrder | `OwnerId` | `0050P0000074Bf7QAE` | Usuario funcional QA; valor explícito | Sí | C |
| WorkOrder | `WorkOrderNumber` | generado por Salesforce | Campo autonumérico, no se envía | Sí | A |
| `tiposDeTrabajoCaso__c` | `Caso__c` | Id del Case creado en el paso 1 | Único campo obligatorio del objeto | Sí | A |
| `tiposDeTrabajoCaso__c` | `Tipotrabajo__c` | `a2jPH00000AChZhYAL` (`-Control final`) | Baseline genérico con 265 usos y 207 relaciones posteriores | Sí | B |
| `tiposDeTrabajoCaso__c` | `Tipo_de_cargo__c` | `Cliente` | Valor repetido en el baseline validado | Sí | B |
| `tiposDeTrabajoCaso__c` | `CurrencyIsoCode` | `CRC` | Registros baseline equivalentes y coherencia con Case/WorkOrder | Sí | B |
| `tiposDeTrabajoCaso__c` | `RM_EsTrabajoAdicional__c` | `true` | Valor repetido en los registros recientes del baseline | Sí | B |
| `tiposDeTrabajoCaso__c` | `RM_ModoTrabajo__c` | `null` | Baseline equivalente | Sí | B |
| `tiposDeTrabajoCaso__c` | `Status__c` | `null` | Baseline equivalente | Sí | B |
| `tiposDeTrabajoCaso__c` | `Name` | generado por Salesforce | Campo autonumérico, no se envía | Sí | A |
| Expense | `WorkOrderId` | Id del WorkOrder creado en el paso 2 | Entrada estructural del Flow after-save | Sí | A |
| Expense | `AccountId` | `001PH00001O6pqGYAR` | Mismo Account QA del WorkOrder | Sí | A |
| Expense | `ExpenseType` | `Facturable` | Criterio exacto de disparo de `CreateWoliFromExpense` | Sí | A |
| Expense | `Amount` | `1` CRC | Valor técnico QA mínimo; el objeto no tiene validación activa que exija un monto mayor | Sí | C |
| Expense | `TransactionDate` | `2026-08-13` | Fecha técnica propuesta para el bloque; si la autorización se ejecuta otro día, sustituir únicamente por esa fecha real | Sí | C |
| Expense | `Category__c` | `null` | Baseline `EXP-1446`; la rama `Ingresar valor` no necesita categoría | Sí | B |
| Expense | `CalculoGanancia__c` | `Ingresar valor` | Baseline `EXP-1446`; evita inferir margen por categoría | Sí | B |
| Expense | `PrecioCliente__c` | `1` | Propuesta técnica QA coherente con `Ingresar valor`; el baseline demuestra que se traslada a `UnitPrice` | Sí | C |
| Expense | `CurrencyIsoCode` | `CRC` | Baseline y moneda del WorkOrder/Pricebook | Sí | A |
| Expense | `Title` | `QA PEKING Sprint2 - Expense Facturable` | Nomenclatura temporal inequívoca; el producto no se deriva del título | Sí | C |
| Expense | `Description` | `QA técnico para CreateWoliFromExpense` | Nomenclatura temporal inequívoca | Sí | C |
| Expense | `Discount` | `null` | Baseline exitoso | Sí | B |
| Expense | `WoliCreated__c` | `false` | Estado inicial que obliga a la rama de creación | Sí | A |
| Expense | `Work_Order_Line_Item__c` | `null` | Estado inicial previo a la creación del WOLI | Sí | A |
| Expense | `OwnerId` | `0050P0000074Bf7QAE` | Usuario funcional QA; valor explícito | Sí | C |
| Expense | `ExpenseNumber` | generado por Salesforce | Campo autonumérico, no se envía | Sí | A |

Los demás campos editables de estos cuatro objetos se dejan `null` y no se envían; no intervienen en las rutas analizadas. Antes de insertar el Expense deben verificarse dos invariantes del WorkOrder recién creado: `empresaFacturaCP__c = PEKING` y `empresaFactura__c = null`. Si el default legacy llegara a poblar `RMBAVARIAN`, se debe detener la ejecución y corregir únicamente ese dato antes de disparar el Flow.

Orden exacto: (1) Case QA; (2) WorkOrder PEKING y verificación de sus dos campos de Empresa; (3) `tiposDeTrabajoCaso__c`; (4) Expense `Facturable`, cuyo insert constituye la ejecución real de `CreateWoliFromExpense`. El Id del paso 3 será el `recordId` de la futura ejecución manual de `AgregarManoObra`.

Riesgo previsto: bajo y acotado a registros QA nuevos. No se modifica catálogo, PricebookEntry ni datos Bavarian/Otobai. En la preparación pre-DML inicial no se ejecutó ningún cambio; la ejecución autorizada posterior se registra a continuación.

### Ejecución controlada del 13 de agosto de 2026 — detenida en Fase B

La creación autorizada comenzó por fases y se detuvo antes de generar el WorkOrder:

- **Fase A completada:** Case QA `00091090` (`500AK00000Hm5usYAB`) creado con Record Type `Autos`, estado `Cita`, origen `Calendario`, Account y Contact `QA Prueba`, Asset `VNA00260810051041`, CRC, territorio `Uruca - Mecánica General` y propietario funcional `Control de Calidad`.
- **Fase B detenida sin insert:** el acceso utilizado para la ejecución no expone `WorkOrder.empresaFacturaCP__c` por seguridad de campo. Salesforce rechazó la operación antes de crear el registro; no se utilizó una vía que omitiera ese control.
- Checkpoint posterior: el Case conserva **0 WorkOrders**, **0 `tiposDeTrabajoCaso__c`** y **0 Expenses** relacionados. No existe WOLI del bloque y `CreateWoliFromExpense` no se ejecutó.
- No se eliminó el Case QA, de acuerdo con la instrucción de preservar los datos creados. Permanece aislado y claramente identificado para reanudar el mismo juego cuando exista un ejecutor autorizado con acceso de creación al lookup estructural.

Estado operativo: **EJECUCIÓN DETENIDA EN FASE B — ACCESO FLS REQUERIDO PARA `WorkOrder.empresaFacturaCP__c`**. No es un defecto del Flow ni una decisión funcional pendiente; es una condición de acceso del ejecutor. No deben crearse el tipo de trabajo ni el Expense hasta resolverla.

#### Diagnóstico dirigido de FLS

La identidad autenticada que ejecutó el DML fallido es el usuario `005AK0000050FWPYA2`, username `peseck89@gmail.com.partial.redmotors`, perfil `System Administrator`. No fue el propietario funcional `Control de Calidad` del Case. Sus permisos efectivos son:

- WorkOrder: Read, Create y Edit disponibles por el perfil; también posee permisos administrativos amplios propios de ese perfil.
- `WorkOrder.empresaFactura__c`: Read y Edit disponibles.
- `WorkOrder.empresaFacturaCP__c`: sin FieldPermission Read ni Edit; el campo no aparece en el contrato de datos disponible para esa identidad.
- Permission Sets directos: `Empresa_Admin` y `QA_PEKING_S3_RecordType_Access`; ninguno concede acceso al campo. No tiene Permission Set Groups asignados.

La búsqueda global no encontró ningún Permission Set asignable con Edit sobre el lookup estructural:

| Fuente existente | Id | WorkOrder | `empresaFacturaCP__c` | Uso actual | Evaluación |
|---|---|---|---|---|---|
| Perfil `Asistente de Taller` | `00ePH00000Os4C5YAJ` | Read/Create/Edit; sin Delete/View All/Modify All | Read=true; Edit=false | Un usuario funcional activo de Taller | Baseline funcional de solo lectura; no es Permission Set asignable y no resuelve el insert |
| `Data Cloud Salesforce Connector` | `0PSPH000000Hart4AC` | Read=true; Create/Edit=false; View All=true | Read=true; Edit=false | Usuario de integración de Data Cloud | Inadecuado y más amplio de lo necesario; no resuelve el insert |

No existe una identidad técnica autenticada y respaldada que tenga Edit sobre el campo. Tampoco existe una alternativa clase A. Clasificación final: **C — NO EXISTE PERMISSION SET ADECUADO**.

Propuesta mínima pendiente de autorización separada:

- Permission Set sugerido: `WorkOrder_Empresa_Factura_QA` / `WorkOrder Empresa Factura QA`.
- WorkOrder: Read=true, Create=true, Edit=true; Delete=false, View All=false, Modify All=false.
- `WorkOrder.empresaFacturaCP__c`: Read=true, Edit=true.
- No agregar acceso a otros objetos, campos, administración, datos globales ni Production.
- Asignación prevista únicamente al ejecutor `005AK0000050FWPYA2` en `RedMotorsSandbox`, conservándola hasta instrucción expresa de retiro.

#### Reanudación autorizada y resultado del 13 de agosto de 2026

Se creó el Permission Set `WorkOrder_Empresa_Factura_QA` con el rótulo **QA TEMPORAL — NO PROMOVER A PRODUCCIÓN**. Su contenido se limita a WorkOrder Read/Create/Edit, sin Delete/View All/Modify All, y Read/Edit sobre `WorkOrder.empresaFacturaCP__c`; no contiene permisos Apex, Flow, Setup, administrativos ni sobre otros objetos o campos.

- Dry-run exclusivo exitoso: `0AfAK0000014CjZ0AU` (1/1 componente).
- Deploy exclusivo a `RedMotorsSandbox`: `0AfAK0000014Cmn0AE` (1/1 componente), Permission Set `0PSAK0000007gIf4AI`.
- Asignación exclusiva al ejecutor técnico autorizado: `0PaAK000002s2ba0AA`.
- Verificación efectiva posterior: `WorkOrder.empresaFacturaCP__c` quedó Read=true y Edit=true. No se modificó ningún Profile, Permission Set existente ni Permission Set Group.

Con el acceso mínimo disponible se reutilizó el Case `00091090` y se creó el dataset autorizado:

| Registro | Id / número | Resultado verificado |
|---|---|---|
| Case | `500AK00000Hm5usYAB` / `00091090` | Reutilizado; exactamente un WorkOrder |
| WorkOrder | `0WOAK000005jxsH4AQ` / `00087392` | PEKING, CRC, `PEKING Local`, territorio `Uruca - Mecánica General`, tipo `Mecánica General Autos`, empresa legacy vacía |
| `tiposDeTrabajoCaso__c` | `a2iAK000001zjndYAA` / `T-180171` | Case correcto, tipo `-Control final`, cargo Cliente y trabajo adicional |
| Expense | `1V4AK00000001tl0AA` / `EXP-1458` | Persistido con `Facturable`, Amount=1, `PrecioCliente__c=1`, `WoliCreated__c=false` y lookup WOLI vacío |
| WorkOrderLineItem | No creado | Cero WOLI asociados al WorkOrder después del insert |

`CreateWoliFromExpense` v15 estaba activa al ejecutar el insert. No se conservó `FlowInterview`, `FlowInterviewLog` ni Apex log para esta ejecución. Tampoco hubo excepción ni rollback: el Expense permaneció creado y sin modificación posterior.

El análisis estructural y de datos aisló el punto de salida:

1. `GetMarialesProveedorProduct` busca `Product2.Codigo_de_Producto__c = SUB`, pide el primer registro y no define orden.
2. Existen dos productos activos con ese código. La consulta equivalente devuelve `01t4U000005sF8FQAU`.
3. `PEKING Local` no tiene PricebookEntry para ese producto.
4. La entrada provisional esperada `01uAK000000YRH7YAO` corresponde al otro producto `SUB`, `01t4U000005w41KQAQ`.
5. `GetPricebook_Dinamico` no obtiene registro y `Validar_PricebookEntry` toma la salida controlada **“Entrada no configurada: detener”**, antes de `CreateWoliFromExpense` (Record Create).

Resultado: **CreateWoliFromExpense — QA EJECUTADO, NO APROBADO; SIN FAULT NI ROLLBACK; DETENIDO POR PRODUCTO `SUB` AMBIGUO/SIN PBE PARA EL PRODUCTO SELECCIONADO**. No se reintentó, no se modificaron catálogo ni Flow y no se ejecutó `AgregarManoObra`.

#### Diagnóstico dirigido de los dos Product2 `SUB`

La igualdad de nombre y código externo no representa un duplicado accidental. `Codigo_de_Producto__c` es External ID pero no es único; el catálogo diferencia las variantes mediante `codigoProductoInterno__c`, que sí es único, además de Empresa y tipo de producto.

| Dato | Producto histórico de subcontrato | Variante de mano de obra |
|---|---|---|
| Product2 Id | `01t4U000005sF8FQAU` | `01t4U000005w41KQAQ` |
| Nombre | `Subcontratos Taller Externo Autos` | `Subcontratos Taller Externo Autos` |
| Código externo | `SUB` | `SUB` |
| Código interno | `SUB-RMOTOBAI` | `SUB-RMBAVARIAN` |
| Empresa legacy | `RMOTOBAI` | `RMBAVARIAN` |
| Tipo de producto | `Subcontrato` | `Mano de Obra` |
| Record Type | `Materiales` | `Materiales` |
| Activo / moneda base | Sí / CRC | Sí / CRC |
| Creado | 2022-10-25 | 2022-07-08 |
| Última modificación | 2026-05-11 | 2022-10-24 |
| WOLI históricos | 25 | 0 |
| QuoteLineItem / OpportunityLineItem | 0 / 0 | 0 / 0 |

Los demás campos poblados son equivalentes: grupo `SERVICIOS`, códigos secundarios `ND`, importes/precios base de 1, sin marca/modelo/familia/descripción/unidad ni otro identificador externo. No existen registros de historial de campos que permitan reconstruir cambios anteriores.

Las 25 ejecuciones históricas demostrables de `CreateWoliFromExpense` — Expenses `EXP-1432` a `EXP-1457`, entre el 23 de junio y el 14 de julio de 2026 — crearon WOLI con `Product__c = 01t4U000005sF8FQAU`, PBE `01u4U00000wowwSQAQ`, `Bavarian Local`, CRC y `empresaFactura__c = RMBAVARIAN`. Ejemplos recientes: `EXP-1457`/`1WLPH00000aExoS4AS`, `EXP-1456`/`1WLPH00000aDCdJ4AW` y `EXP-1455`/`1WLPH00000aAYp14AG`. No existe uso histórico del producto `01t4U000005w41KQAQ` en WOLI.

Inventario de PricebookEntry:

- `01t4U000005sF8FQAU` tiene seis PBE activas y cero inactivas: Standard CRC/USD, Bavarian Local/Dólar y Otobai Local/Dólares. No tiene PBE en PEKING.
- `01t4U000005w41KQAQ` tiene seis PBE activas y cero inactivas: Standard CRC/USD, Bavarian Local/Dólar y PEKING Local/Dólares. No tiene PBE en Otobai.
- La PBE PEKING Local `01uAK000000YRH7YAO` y la PBE PEKING Dólares `01uAK000000YRFWYA4` pertenecen a la variante `Mano de Obra`, no al producto histórico de `Subcontrato`.

Conclusión de autoridad: para `CreateWoliFromExpense`, el producto autoritativo es `01t4U000005sF8FQAU`. Es el único marcado como `Subcontrato`, es el único usado por resultados históricos del Flow y ya posee cobertura Bavarian/Otobai. El valor legacy `Empresa__c = RMOTOBAI` no se puede usar como filtro único porque esos 25 resultados corresponden a Bavarian; el criterio estructural inequívoco es `tipoProducto__c = Subcontrato` junto con `IsActive = true` y `Codigo_de_Producto__c = SUB`.

La metadata de `GetMarialesProveedorProduct` conserva desde la versión inicial un único filtro `Codigo_de_Producto__c = SUB`, `getFirstRecordOnly = true`, sin sort, y almacena automáticamente el Product2. La prueba Apex existente también crea un único producto `SUB`, por lo que no cubre la coexistencia de variantes. La duplicidad del código externo es válida en el modelo, pero el lookup del Flow trata incorrectamente ese código no único como si fuera suficiente.

Corrección segura propuesta en el diagnóstico inicial y ejecutada posteriormente en el bloque autorizado:

1. endurecer `GetMarialesProveedorProduct` con `IsActive = true` y `tipoProducto__c = Subcontrato`, sin Id ni empresa hardcodeados;
2. crear la PBE PEKING correspondiente para el producto autoritativo `01t4U000005sF8FQAU` en la moneda requerida; para el QA actual basta `PEKING Local`/CRC;
3. conservar las PBE de `01t4U000005w41KQAQ`, porque esa variante `Mano de Obra` participa en el universo seleccionable de `AgregarManoObra` y no se demostró que sea catálogo inválido;
4. agregar una prueba con dos Product2 `SUB` de tipos distintos y verificar que el Flow use exclusivamente el de `Subcontrato`.

Ninguna alternativa aislada era suficiente: modificar solo el Flow dejaba PEKING sin PBE para el producto correcto; crear solo la PBE permitía que el lookup siguiera siendo no determinista. Normalizar o eliminar uno de los productos habría sido incorrecto sin una decisión adicional porque son variantes funcionales distintas. Clasificación diagnóstica previa a la autorización: **D — OTRO: CORRECCIÓN COMBINADA A+B, DEFECTO TÉCNICO DE SELECCIÓN MÁS CONFIGURACIÓN PEKING FALTANTE PARA EL PRODUCTO AUTORITATIVO**.

`EXP-1458` fue reutilizado una sola vez después de completar y validar ambas correcciones. La actualización se limitó a `Description = QA técnico CreateWoliFromExpense PEKING`; no se alteraron importe, precio, Work Order, tipo de Expense, Empresa ni los campos de control manualmente. El resultado se documenta en la sección siguiente.

El dataset de `AgregarManoObra` continúa válido e independiente de esta duplicidad: `a2iAK000001zjndYAA` conserva Case `00091090`, tipo `-Control final`, cargo `Cliente`, CRC y el Case mantiene un único WorkOrder. Ese Screen Flow obtiene productos con `tipoProducto__c = Mano de Obra` y sus PBE; no contiene un filtro literal `SUB`. Queda **LISTO PARA QA MANUAL** y no fue ejecutado en este bloque.

#### Remediación combinada y QA final de `CreateWoliFromExpense` — 13 de agosto de 2026

Clasificación: **REMEDIACIÓN TÉCNICA PERMITIDA — CAMBIO LIMITADO**.

- La consulta estructural previa `Codigo_de_Producto__c = SUB AND tipoProducto__c = Subcontrato AND IsActive = true` devolvió exactamente un Product2: `01t4U000005sF8FQAU`. Los dos productos con código externo `SUB` se conservaron porque representan tipos funcionales distintos; la variante `01t4U000005w41KQAQ`, de tipo `Mano de Obra`, no fue modificada.
- `GetMarialesProveedorProduct` pasó de filtrar únicamente `Codigo_de_Producto__c = SUB` a exigir también `tipoProducto__c = Subcontrato` e `IsActive = true`. Conserva `getFirstRecordOnly = true`; no contiene Id, Empresa, Pricebook ni código interno fijo.
- La regresión estructural queda cubierta por las PBE activas ya existentes del mismo producto autoritativo en Bavarian Local (`01u4U00000wowwSQAQ`, CRC, precio 1) y Otobai Local/Dólares. No se ejecutaron datos de esas empresas.
- No se agregó una prueba automatizada: `BMW_ExpenseProcessTest` solo crea un producto `SUB` y no dispone de aserciones sobre la selección interna del Flow. Cubrir la coexistencia de dos variantes exigiría infraestructura de prueba nueva fuera de esta remediación; se aplicaron validación estructural y QA real controlado.
- Dry-run exclusivo exitoso: `0AfAK0000014CEw0AM` (1/1 componente). Deploy exclusivo exitoso a `RedMotorsSandbox`: `0AfAK0000014DKf0AM` (1/1 componente). La versión v16 (`301AK00000PWXVVYA5`) quedó activa y la lectura posterior confirmó los tres filtros exactos.
- Se creó únicamente la PBE `01uAK000000YUy9YAG` para el producto `01t4U000005sF8FQAU` en `PEKING Local` (`01sAK0000006DVdYAM`), CRC, activa y `UnitPrice = 1`. El valor 1 sigue el baseline provisional autorizado para configuraciones técnicas PEKING y coincide con la entrada Bavarian Local del mismo producto; no representa un precio comercial definitivo.
- No se creó una PBE PEKING Dólares para el producto autoritativo. Las PBE de la variante `Mano de Obra` permanecen intactas.
- Antes del redisparo, `EXP-1458` conservaba `Facturable`, Amount=1, `PrecioCliente__c=1`, `WoliCreated__c=false`, lookup WOLI vacío y su Work Order no tenía WOLI. La única actualización autorizada produjo exactamente el WOLI `1WLAK0000000rh34AA`.
- El WOLI persistido apunta a Work Order `0WOAK000005jxsH4AQ`, Product2 `01t4U000005sF8FQAU` de tipo `Subcontrato`, PBE `01uAK000000YUy9YAG`, `PEKING Local`, CRC, Quantity=1, UnitPrice=1 y `Trabajo__c = Subcontrato`. El Expense terminó con `WoliCreated__c=true` y `Work_Order_Line_Item__c=1WLAK0000000rh34AA`.

Resultado final: **CreateWoliFromExpense — QA FUNCIONAL OK — PEKING**. Se creó un solo WOLI correcto, sin duplicidad y sin usar la variante `01t4U000005w41KQAQ`.

#### Bloqueo FLS de `AgregarManoObra` y preparación del reintento — 13 de agosto de 2026

La entrevista manual con GUID `2839336d668afbd48bc33bb8a9a519ffa1ab129-735d`, ejecutada por el perfil QA funcional, falló en `GetWorkOrder`. La consulta generada intentó leer `Id`, `Pricebook2Id`, `empresaFacturaCP__c` y `empresaFactura__c`; Salesforce devolvió `No such column 'empresaFacturaCP__c' on entity 'WorkOrder'` aunque el campo existe en la org.

La causa quedó demostrada como FLS exclusivo del usuario funcional:

- WorkOrder ya tenía Read/Create/Edit efectivos y acceso de lectura al registro `0WOAK000005jxsH4AQ`;
- `WorkOrder.Pricebook2Id`: Read/Edit efectivos;
- `WorkOrder.empresaFactura__c`: Read/Edit efectivos;
- `WorkOrder.empresaFacturaCP__c`: Read=false y Edit=false antes de la corrección;
- no faltaba visibilidad sobre otro campo usado por `GetWorkOrder`.

Se reutilizó el Permission Set `WorkOrder_Empresa_Factura_QA` (`0PSAK0000007gIf4AI`), marcado **QA TEMPORAL — NO PROMOVER A PRODUCCIÓN**, sin modificar Profile, Flow ni el propio Permission Set. La nueva asignación al usuario funcional es `0PaAK000002s5nx0AA`. La asignación técnica anterior `0PaAK000002s2ba0AA` se conservó.

Después de la asignación, `empresaFacturaCP__c` quedó con Read=true y Edit=true; `empresaFactura__c` y `Pricebook2Id` conservaron Read/Edit, WorkOrder conserva permiso de lectura y el registro mantiene acceso efectivo. No se modificaron Case, WorkOrder, Expense, WOLI, catálogo ni otro dato funcional.

Estado: **AgregarManoObra — LISTO PARA REINTENTO QA MANUAL**. No se marca QA OK y el Flow no fue ejecutado nuevamente en este bloque.

#### Límite SOQL de `AgregarManoObra` y remediación colectiva — 13 de agosto de 2026

El segundo intento manual, entrevista `0FoAK000001dKUY0A2` y GUID `7553248cd0259e6fd65a18a1c5219ffa245fde-7006`, superó `GetWorkOrder`, resolvió correctamente PEKING, CRC y `PEKING Local`, y falló en `GetPricebookEntry` con `Too many SOQL queries: 101`. No se creó ni modificó ningún registro funcional. La causa era metadata preexistente: `GetProducts_0` devolvía 610 productos de tipo `Mano de Obra` y el loop ejecutaba una consulta de PricebookEntry por cada producto.

Clasificación: **REMEDIACIÓN TÉCNICA PERMITIDA — CAMBIO LIMITADO**.

- La colección anterior se construía mediante `GetProducts_0 → LoopProduct → GetPricebookEntry → IFNOTNULL`: por cada producto con una PBE en el Pricebook resuelto se agregaban el Id a `PricebookEntries` y el registro a `PricebookEntryObject`. `Pantalla1` consumía `PricebookEntries` como Ids de `PricebookEntry` y mostraba `ProductNameFormula__c`, `productCode__c` y `UnitPrice`; no existía orden explícito.
- La nueva ruta ejecutable es `GetProducts_0 → LoopProductsManoObra → AgregarProductIdManoObra → GetPricebookEntriesManoObra → LoopPricebookEntriesManoObra → AsignarProductoPricebook_0 → Pantalla1`. La primera consulta conserva `Product2.tipoProducto__c = Mano de Obra`; el loop solo construye `ProductIdsManoObra`. La segunda y única consulta de PBE filtra `Pricebook2Id = PricebookSeleccionado` y `Product2Id IN ProductIdsManoObra`.
- La carga inicial de catálogo queda en dos consultas constantes y cero Get Records dentro de sus loops. `Pantalla1`, su DataGrid, `CreateWoli`, `CreateWorkOrderLineItems`, `CreateSubtiposDeTrabajo`, Empresa, moneda, descuentos y horas/UTS no cambiaron.
- No se añadieron filtros `IsActive`, `Product2.IsActive` ni `CurrencyIsoCode`: la ruta anterior no los exigía y agregarlos habría excluido dos PBE inactivas que el comportamiento histórico de Otobai incluía.
- La comparación de solo lectura confirmó equivalencia exacta y sin Product2 duplicados: PEKING Local 2/2, Bavarian Local 102/102 y Otobai Local 182/182. Para PEKING se obtuvieron únicamente `01uAK000000YRDtYAO` (`BSI`, `SAD001`) y `01uAK000000YRH7YAO` (`Subcontratos Taller Externo Autos`, tipo `Mano de Obra`); se excluyó la variante `SUB` de tipo `Subcontrato`.
- Un primer deploy técnico creó v3 (`301AK00000PWTTYYA5`), pero la verificación posterior detectó que el filtro de relación directa había sido serializado por Salesforce como `null__NotFound`. No se solicitó QA sobre esa versión. Se sustituyó por la representación soportada `Product2Id IN ProductIdsManoObra`, sin cambiar la semántica.
- Dry-run final exclusivo exitoso: `0AfAK0000014DhF0AU` (1/1 componente). Deploy final exclusivo exitoso a `RedMotorsSandbox`: `0AfAK0000014Cek0AE` (1/1 componente). `AgregarManoObra` v4 (`301AK00000PWR5CYAX`) quedó activa y la recuperación posterior preservó los filtros, colecciones y conectores esperados.

Estado: **AgregarManoObra — VALIDACIÓN TÉCNICA OK — QA FUNCIONAL MANUAL PENDIENTE**. No se ejecutó el Screen Flow después del deploy.

#### QA funcional final de `AgregarManoObra` v4 — 13 de agosto de 2026

La entrevista funcional v4 con GUID `525008d488878c0aed243898ed1819ffa37b434-7764` y log `8gZAK000000Ij8L2AS` terminó en estado `Completed`. La secuencia registrada fue `Pantalla1 → PantallaFinal → CreateWoli → FlowFinish`; no hubo fault ni rollback.

- Se seleccionó una sola entrada de Mano de Obra: Product2 `01t4U000005uyXYQAY`, `BSI / SAD001`, con PBE `01uAK000000YRDtYAO` de `PEKING Local`.
- El checkbox `AgregarManoObra` (`Agregar nueva mano duplicada`) permaneció desmarcado. La Decision `CrearNuevaManoObra` tomó correctamente su conector default hacia `ForEachPricebookEntryGlobal`; únicamente el valor `true` regresa a `Pantalla1` para agregar otra selección.
- Se creó exactamente un WOLI nuevo: `1WLAK0000000rif4AA`, Work Order `0WOAK000005jxsH4AQ`, CRC, Quantity `1`, UnitPrice `1`, modalidad Horas, descuento vacío y alias vacío.
- Se creó exactamente un Subtipo: `a2oAK0000001eQ1YAI`, nombre `BSI`, cantidad de horas `1`, UTS vacío, relacionado con el Case `500AK00000Hm5usYAB`, el Work Order y el tipo de trabajo `a2iAK000001zjndYAA` correctos.
- El WOLI histórico de Subcontrato `1WLAK0000000rh34AA` se conservó separado. No existe duplicado nuevo de Mano de Obra.
- El aparente regreso al listado ocurrió después de `FlowFinish`: Salesforce inició una entrevista distinta un segundo más tarde. Las entrevistas posteriores tienen GUID propios y corresponden al comportamiento del contenedor/runtime, no a un loop interno de `CrearNuevaManoObra` ni a un defecto de creación. No se amplía este bloque para investigar esa navegación.

Estado final: **AgregarManoObra — QA FUNCIONAL OK — PEKING**.

## Acciones manuales ordenadas

Ejecutar cada caso una sola vez. Si aparece un fault, detenerse y conservar captura, hora, GUID y elemento; no repetir para obtener evidencia redundante.

1. **`Opp_flow_V3`.** No repetir el Flow únicamente para obtener evidencia. La creación PEKING ya quedó validada. Verificar el destino del Quote existente abriendo `/lightning/r/Quote/0Q0AK000001zPyb0AE/view`; confirmar el enlace integrado en v30 durante la siguiente ejecución funcional normal.
2. **`Opp_Flow_v6`.** No repetir el Flow únicamente para obtener evidencia. La creación PEKING ya quedó validada. Confirmar el enlace integrado en v82 durante la siguiente ejecución funcional normal.
3. **`Opportunity_Flow_V2`.** No repetir el Flow únicamente para obtener evidencia. La creación PEKING ya quedó validada. Confirmar el enlace integrado en v8 durante la siguiente ejecución funcional normal.
4. **Rutas Mostrador de v82/v8.** Ejecutarlas únicamente cuando exista una sesión funcional autorizada de un usuario activo con tipo `Mostrador` o `Todas`. Repetir el mismo control PEKING/CRC y verificar que el selector propio de Mostrador persiste `Empresa_Operadora__c`. No modificar usuarios para preparar la prueba.
5. **`PlanDeMantenimientoV2`.** No ejecutar todavía. Confirmar qué producto/vehículo y término/tipo de plan aplican a PEKING; después proporcionar un Quote QA PEKING/CRC con una QuoteLineItem `Vehiculo` basada en una PricebookEntry activa de `PEKING Local`.
6. **`CreateWoliFromExpense`.** QA funcional PEKING completado. No volver a actualizar `EXP-1458` para obtener evidencia redundante.
7. **`AgregarManoObra` v4.** QA funcional PEKING completado. No repetir el Flow ni crear otra línea para obtener evidencia redundante. El reinicio posterior a `FlowFinish` queda fuera de este bloque mientras no sea un requisito explícito del Sprint.

## Criterio de estado

`Opp_flow_V3`, `Opp_Flow_v6` y `Opportunity_Flow_V2` quedan con **QA de creación OK** y navegación remediada técnicamente, pendiente únicamente de validar manualmente el enlace integrado. Las rutas Mostrador de `Opp_Flow_v6` y `Opportunity_Flow_V2` requieren sesiones funcionales autorizadas. `PlanDeMantenimientoV2` conserva **BLOQUEO DE NEGOCIO**. `CreateWoliFromExpense` y `AgregarManoObra` quedan **QA FUNCIONAL OK — PEKING**. No debe repetirse ninguno únicamente para generar evidencia adicional.
