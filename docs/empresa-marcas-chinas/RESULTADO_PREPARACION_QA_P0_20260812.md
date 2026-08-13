# Resultado — preparación dirigida de QA P0 de Sprint 2

**Fecha:** 12 de agosto de 2026

**Ambiente:** `RedMotorsSandbox` (Partial)

**Tipo de bloque:** consulta y preparación de QA; sin ejecución de Flows, DML, deploy ni cambios de metadata

## Resultado ejecutivo

| Flow | Versión activa | Clasificación de QA | Estado alcanzado |
|---|---:|---|---|
| `Opp_flow_V3` | v30 (`301AK00000PW6LeYAL`) | C — manual | **QA DE CREACIÓN OK — NAVEGACIÓN REMEDIADA; QA MANUAL DEL ENLACE PENDIENTE** |
| `Opp_Flow_v6` | v82 (`301AK00000PWE36YAH`) | C — manual | **QA CREACIÓN OK — NAVEGACIÓN REMEDIADA; QA MANUAL DEL ENLACE PENDIENTE** en ruta Taller; Mostrador requiere una sesión funcional autorizada de ese tipo |
| `Opportunity_Flow_V2` | v8 (`301AK00000PWLPYYA5`) | C — manual | **QA CREACIÓN OK — NAVEGACIÓN REMEDIADA; QA MANUAL DEL ENLACE PENDIENTE** en ruta Taller/general; Mostrador requiere una sesión funcional autorizada de ese tipo |
| `PlanDeMantenimientoV2` | v24 (`301AK00000PC2ngYAD`) | C — manual | **BLOQUEO DE NEGOCIO**: no existe Quote PEKING con línea de vehículo; falta catálogo de vehículo PEKING y definición de término/plan aplicable |
| `CreateWoliFromExpense` | v15 (`301AK00000PC2nfYAD`) | **B — QA PREPARABLE CON DML MÍNIMO** | No existe Work Order PEKING ni Expense facturable relacionado reutilizable; catálogo técnico listo |
| `AgregarManoObra` | v2 (`301AK00000PC2neYAD`) | **B — QA PREPARABLE CON DML MÍNIMO** | No existe Work Order PEKING reutilizable; entradas de mano de obra en `PEKING Local` listas |

No se encontró un defecto técnico nuevo y demostrable que autorizara modificar o desplegar metadata en este bloque.

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

Los cuatro `PricebookEntry` provisionales de `SAD001` y `SUB` para PEKING continúan activos y resuelven N1 a nivel técnico. Sin embargo, esa configuración no sustituye los registros funcionales de entrada:

- `PlanDeMantenimientoV2`: se revisaron los seis Quotes QA PEKING `PT-00080231` a `PT-00080236`; todos tienen `PEKING Local`, CRC y Opportunity con `Empresa_Operadora__c = PEKING`, pero contienen **cero QuoteLineItem**. Tampoco existe en Partial otro Quote PEKING con una línea `BMW_TipoDeArticulo__c = Vehiculo`.
- El Asset QA `VNA00260810051041` no tiene `Product2Id`. `PEKING Local` contiene únicamente dos PricebookEntry activas: `SAD001` (BSI) y `SUB`; no existe una entrada de vehículo de la que pueda derivarse de forma segura la QuoteLineItem seleccionable.
- El Flow resuelve correctamente `SAD001` en `PEKING Local`, por lo que N1 no bloquea la ruta. El término se selecciona mediante `Plan_de_mantenimiento__c.Warranty_Term__c` y el Flow solo acepta `WarrantyUnitOfTime = Years`. Existen 13 términos activos en años, sin filtro de lookup ni relación con Empresa/Pricebook, pero todos pertenecen a tipos legacy BSI BMW/MINI/Motorrad. Elegir cuál aplica a PEKING y qué tipo de plan usar requiere definición de negocio; no se infirió por baseline.
- `CreateWoliFromExpense` v15 (`301AK00000PC2nfYAD`) es un Flow after-save sobre `Expense`. Se dispara al crear o actualizar un Expense cuyo `ExpenseType` sea exactamente `Facturable`; no tiene entrada manual. Resuelve Empresa primero desde `WorkOrder.empresaFacturaCP__c` y conserva el fallback legacy únicamente para Bavarian/Otobai. Con Empresa, moneda de la orden y Pricebook actual invoca `EmpresaPricebookResolver`, exige estado `EXITO` y una PricebookEntry activa del producto `SUB`. Según `WoliCreated__c`, crea o actualiza un `WorkOrderLineItem`; al crear, marca el Expense y guarda el Id del WOLI.
- Para ese Flow se verificaron los 9.959 Work Orders disponibles mediante relaciones consultables. No existe ninguno con `PEKING Local`, ninguno ligado a una Opportunity con `Empresa_Operadora__c = PEKING`, y ninguno asociado al Account/Asset QA usados en este Sprint. El lookup `WorkOrder.empresaFacturaCP__c` existe y es la fuente de la versión activa, pero el usuario de consulta no tiene FLS para leer sus valores directamente; por tanto no se reutilizó ningún registro cuya asociación estructural completa no pudiera demostrarse.
- Existen únicamente dos Expenses `Facturable` con `WoliCreated__c = false`: `EXP-0001` (`1V44U0000010wBVSAY`) y `EXP-0003` (`1V44U0000010wFnSAI`). Ambos tienen `WorkOrderId = null`, por lo que no son candidatos válidos. Los Expenses procesados ya apuntan a WOLI y no deben reutilizarse.
- `AgregarManoObra` v2 (`301AK00000PC2neYAD`) es un Screen Flow cuyo input `recordId` corresponde a `tiposDeTrabajoCaso__c`, no a WorkOrder. Desde ese registro obtiene el Case y luego el primer WorkOrder del Case. La prueba requiere un Case aislado con un único WorkOrder PEKING, porque el lookup de WorkOrder no tiene orden explícito; un Case con varias órdenes produciría una selección ambigua. La orden debe tener Empresa estructural, moneda y Pricebook coherentes. `ServiceTerritoryId` no se filtra en este Flow, pero debe permanecer válido en la orden base.
- El Flow consulta todos los `Product2` activos o disponibles con `tipoProducto__c = Mano de Obra`, conserva solo los que tienen PricebookEntry en el Pricebook resuelto y permite seleccionar uno o más. Crea colecciones de `WorkOrderLineItem` y `Subtipo_de_trabajo_del_caso__c`; solicita alias, cantidad en horas o UTS y descuento opcional.
- `PEKING Local` (`01sAK0000006DVdYAM`, CRC) está activo y relacionado con PEKING. Contiene dos PricebookEntry activas de mano de obra: `SAD001 / BSI` (`01uAK000000YRDtYAO`) y `SUB / Subcontratos Taller Externo Autos` (`01uAK000000YRH7YAO`), ambas con precio unitario 1. Son los mismos productos compartidos que tienen entradas activas en los Pricebooks Bavarian y Otobai; no se necesita crear producto ni PricebookEntry.
- No existe un `tiposDeTrabajoCaso__c` claramente QA cuyo Case carezca de WorkOrder. Los casos sin orden encontrados pertenecen a datos funcionales existentes y no son reutilizables. El Case QA de referencia `00091070` tampoco sirve: ya contiene más de un WorkOrder Bavarian y el Flow podría elegir cualquiera.

### Propuesta pre-DML compartida — pendiente de autorización

Ambos Flows se clasifican como **B — QA PREPARABLE CON DML MÍNIMO**. Un único conjunto aislado puede servir para los dos, sin alterar Bavarian/Otobai:

1. Crear un Case exclusivamente QA, con Record Type `Autos`, Account `QA Prueba` (`001PH00001O6pqGYAR`), Contact `QA Prueba` (`003PH00001VYijKYAT`) y Asset `VNA00260810051041` (`02iAK000001xtZNYAY`). Los restantes valores obligatorios deben copiarse de un Case QA `Autos` vigente, no de un registro real.
2. Crear un único WorkOrder QA ligado a ese Case: Account, Contact y Asset anteriores; estado inicial estándar; `CurrencyIsoCode = CRC`; `Pricebook2Id = 01sAK0000006DVdYAM` (`PEKING Local`); `empresaFacturaCP__c = a1UAK0000009wft2AA` (PEKING); `empresaFactura__c` vacío; y `ServiceTerritoryId = 0Hh4U0000010wVFSAY` (`Uruca - Mecánica General`). La fuente de Empresa/Pricebook/moneda es la configuración estructural ya validada; la cuenta, contacto y vehículo provienen del juego QA existente.
3. Crear un `tiposDeTrabajoCaso__c` sobre el Case nuevo usando un `tiposDeTrabajo__c` existente y controlado. El tipo concreto que se use debe copiarse de un caso QA equivalente; no se creará catálogo nuevo. Este Id será el `recordId` manual de `AgregarManoObra`.
4. Crear un Expense QA ligado al mismo WorkOrder, con `ExpenseType = Facturable`, CRC, `WoliCreated__c = false`, `Work_Order_Line_Item__c = null`, título explícitamente QA y valores de importe/categoría/cálculo tomados de un Expense QA aprobado. Crear este registro disparará automáticamente `CreateWoliFromExpense`; por eso requiere autorización de ejecución y no debe hacerse como simple preparación silenciosa.

Riesgo: bajo y acotado a datos nuevos de Sandbox si se usa un Case aislado. No se cambia ningún registro, producto ni PricebookEntry Bavarian/Otobai. La única información todavía no derivada de manera segura es el tipo de trabajo concreto y el conjunto de valores funcionales del Expense (`Amount`, `Category__c`, `CalculoGanancia__c` y, según la opción, `PrecioCliente__c`); deben copiarse de un caso QA aprobado o confirmarse antes del DML.

Estos tres Flows permanecen técnicamente validados, pero **no están listos para QA manual positivo** hasta que el equipo proporcione los registros funcionales de entrada. No se crearon registros para suplirlos.

## Acciones manuales ordenadas

Ejecutar cada caso una sola vez. Si aparece un fault, detenerse y conservar captura, hora, GUID y elemento; no repetir para obtener evidencia redundante.

1. **`Opp_flow_V3`.** No repetir el Flow únicamente para obtener evidencia. La creación PEKING ya quedó validada. Verificar el destino del Quote existente abriendo `/lightning/r/Quote/0Q0AK000001zPyb0AE/view`; confirmar el enlace integrado en v30 durante la siguiente ejecución funcional normal.
2. **`Opp_Flow_v6`.** No repetir el Flow únicamente para obtener evidencia. La creación PEKING ya quedó validada. Confirmar el enlace integrado en v82 durante la siguiente ejecución funcional normal.
3. **`Opportunity_Flow_V2`.** No repetir el Flow únicamente para obtener evidencia. La creación PEKING ya quedó validada. Confirmar el enlace integrado en v8 durante la siguiente ejecución funcional normal.
4. **Rutas Mostrador de v82/v8.** Ejecutarlas únicamente cuando exista una sesión funcional autorizada de un usuario activo con tipo `Mostrador` o `Todas`. Repetir el mismo control PEKING/CRC y verificar que el selector propio de Mostrador persiste `Empresa_Operadora__c`. No modificar usuarios para preparar la prueba.
5. **`PlanDeMantenimientoV2`.** No ejecutar todavía. Confirmar qué producto/vehículo y término/tipo de plan aplican a PEKING; después proporcionar un Quote QA PEKING/CRC con una QuoteLineItem `Vehiculo` basada en una PricebookEntry activa de `PEKING Local`.
6. **`CreateWoliFromExpense` y `AgregarManoObra`.** No ejecutar todavía. Autorizar o rechazar la propuesta pre-DML compartida. Antes de crear registros, confirmar el tipo de trabajo y los valores funcionales del Expense; después crear un único Case/WorkOrder PEKING aislado, su `tiposDeTrabajoCaso__c` y el Expense. El alta del Expense constituye la ejecución real del Flow record-triggered.

## Criterio de estado

`Opp_flow_V3`, `Opp_Flow_v6` y `Opportunity_Flow_V2` quedan con **QA de creación OK** y navegación remediada técnicamente, pendiente únicamente de validar manualmente el enlace integrado. Las rutas Mostrador de `Opp_Flow_v6` y `Opportunity_Flow_V2` requieren sesiones funcionales autorizadas. `PlanDeMantenimientoV2` conserva **BLOQUEO DE NEGOCIO**. `CreateWoliFromExpense` y `AgregarManoObra` quedan como **B — QA PREPARABLE CON DML MÍNIMO**, pendientes de autorización del juego QA compartido y de confirmar los valores funcionales no derivables del Expense/tipo de trabajo.
