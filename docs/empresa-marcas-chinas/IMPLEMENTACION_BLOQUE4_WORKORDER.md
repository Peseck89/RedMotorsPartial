# Implementación del Bloque 4 — Pricebook de WorkOrder

## Estado

Implementación local terminada y pendiente de dry-run.

No se ejecutó deploy ni se modificaron datos en `RedMotorsSandbox`.

## Autorizaciones utilizadas

- Mantener la selección de Pricebooks por nombres fijos.
- Priorizar la corrección de los `if` de Apex.
- Empresa nueva: PEKING.
- Código de PEKING en `WorkOrder.empresaFactura__c`: `RMPEKING`.
- Luis autorizó expresamente agregar `RMPEKING` al picklist restringido.
- Pricebooks PEKING:
  - `PEKING Local`;
  - `PEKING Dólares`.
- No crear campos nuevos en `Pricebook2`.

Luis confirmó temporalmente que, si `empresaFactura__c` está vacía o contiene
un valor desconocido, se debe conservar el `Pricebook2Id` actual. La
confirmación final de Diego continúa pendiente.

La misma regla de conservación se aplicó a moneda nula, vacía o distinta de
CRC/USD.

## Componentes

- `WorkOrderTrigger`
- `WorkOrderTriggerTest`
- `WorkOrder.empresaFactura__c`
- `manifest/empresa-marcas-chinas-bloque4-workorder.xml`

La metadata del campo y del objeto WorkOrder fue recuperada correctamente desde
`RedMotorsSandbox`. Solo se modificó
`objects/WorkOrder/fields/empresaFactura__c.field-meta.xml`;
`WorkOrder.object-meta.xml` permanece sin cambios y no forma parte del
manifest.

## Comportamiento anterior

La selección se ejecutaba en `before insert` y `before update`, pero las cuatro
ramas estaban deshabilitadas durante pruebas mediante `Test.isRunningTest()`.

Asociaciones productivas existentes:

| Empresa | Moneda | Pricebook |
|---|---|---|
| `RMBAVARIAN` | CRC | `Bavarian Local` |
| `RMBAVARIAN` | USD | `Bavarian Dólar` |
| `RMOTOBAI` | CRC | `Otobai Local` |
| `RMOTOBAI` | USD | `Otobai Dólares` |

PEKING no tenía una rama y, por tanto, el trigger conservaba el Pricebook
recibido.

## Cambio realizado

Se agregaron únicamente estas asociaciones:

| Empresa | Moneda | Pricebook |
|---|---|---|
| `RMPEKING` | CRC | `PEKING Local` |
| `RMPEKING` | USD | `PEKING Dólares` |

La matriz completa queda:

| Empresa | Moneda | Pricebook |
|---|---|---|
| `RMBAVARIAN` | CRC | `Bavarian Local` |
| `RMBAVARIAN` | USD | `Bavarian Dólar` |
| `RMOTOBAI` | CRC | `Otobai Local` |
| `RMOTOBAI` | USD | `Otobai Dólares` |
| `RMPEKING` | CRC | `PEKING Local` |
| `RMPEKING` | USD | `PEKING Dólares` |

No se agregaron IDs hardcodeados, fallbacks, errores ni selección por
`Pricebook2.CurrencyIsoCode`.

## Valores vacíos o desconocidos

La cadena de condiciones no contiene una rama final. Por ello:

- empresa nula o vacía: conserva `Pricebook2Id`;
- empresa desconocida: conserva `Pricebook2Id`;
- moneda nula o vacía: conserva `Pricebook2Id`;
- moneda distinta de CRC/USD: conserva `Pricebook2Id`;
- combinación no aplicable con Pricebook previamente asignado: conserva
  `Pricebook2Id`.

No se agregó `addError` para estos escenarios.

## Retiro de `Test.isRunningTest()`

El guard se retiró exclusivamente de las cuatro condiciones de selección de
Pricebook. No se agregó otro bypass.

El comportamiento productivo no cambia porque `Test.isRunningTest()` siempre
es falso fuera de pruebas. El cambio permite que las seis ramas reales sean
ejecutadas y verificadas por `WorkOrderTriggerTest`.

Pruebas indirectas con posible impacto:

- `BMWVinScanTrabajoGeneratorTest`: usa `RMBAVARIAN` y Pricebook estándar; ya
  contiene una recuperación explícita si el Pricebook queda nulo.
- `RM_CT_TestDataFactory`: crea WorkOrders `RMOTOBAI` en USD sin Pricebook
  explícito; continuará con el resultado de la selección disponible en la
  transacción.
- `TestDataFactory`: crea WorkOrders `RMOTOBAI` en CRC sin Pricebook explícito.
- `RM_TraerTrabajosEmailServiceTest`: usa `RMBAVARIAN` con un Pricebook propio;
  debe incluirse en regresión porque el trigger ahora intentará seleccionar
  `Bavarian Local` o `Bavarian Dólar` según la moneda efectiva.

No se modificaron estas pruebas preventivamente.

## Pruebas directas

`WorkOrderTriggerTest` mantiene `SeeAllData=false` y crea siete Pricebooks
propios: los seis autorizados y uno inicial usado para verificar conservación.

Casos agregados:

1. `RMBAVARIAN` + CRC → `Bavarian Local`.
2. `RMBAVARIAN` + USD → `Bavarian Dólar`.
3. `RMOTOBAI` + CRC → `Otobai Local`.
4. `RMOTOBAI` + USD → `Otobai Dólares`.
5. `RMPEKING` + CRC → `PEKING Local`.
6. `RMPEKING` + USD → `PEKING Dólares`.
7. Empresa nula conserva el Pricebook inicial.
8. Moneda omitida recibe USD por defecto y selecciona `Bavarian Dólar`.
9. Selección `RMPEKING` + USD durante update.
10. Inserción bulk de 200 WorkOrders distribuida entre las seis combinaciones.

La prueba histórica `testWorkOrderTrigger()` se conserva.

Las pruebas de `RMPEKING` para insert CRC, insert USD y update USD están
activas. El escenario bulk volvió a incluir las dos combinaciones PEKING.

## Resultado del primer dry-run

| Dato | Resultado |
|---|---|
| Deploy ID | `0AfAK000000vlzt0AA` |
| Componentes compilados | 2/2 |
| Pruebas aprobadas | 5/13 |
| Pruebas fallidas | 8/13 |
| Cobertura de `WorkOrderTrigger` | 35% |
| Modificación de la org | Ninguna; la ejecución fue dry-run |

Las ocho fallas fueron:

- tres pruebas PEKING por `RMPEKING` ausente del picklist restringido;
- el caso bulk, porque incluía WorkOrders `RMPEKING`;
- empresa desconocida, porque `EMPRESA_DESCONOCIDA` no es un valor permitido;
- moneda desconocida, porque EUR no está activa;
- moneda nula, porque Salesforce asignó USD antes de la selección y el trigger
  eligió `Bavarian Dólar`;
- la prueba histórica, porque utilizó un `PricebookEntry` perteneciente a un
  Pricebook distinto del asignado al WorkOrder.

La cobertura quedó en 35% porque ocho escenarios no completaron su ejecución.

## Validación de solo lectura de configuración

### `WorkOrder.empresaFactura__c`

| Propiedad | Valor |
|---|---|
| Tipo | Picklist restringido |
| Permite nulo | Sí |
| Valor predeterminado | `RMBAVARIAN` |

Valores activos:

- `RMBAVARIAN`;
- `RMOTOBAI`.

Este era el estado de `RedMotorsSandbox` durante el dry-run
`0AfAK000000vlzt0AA`: `RMPEKING` todavía no existía y tampoco había otro valor
activo que pudiera usarse como empresa válida no mapeada.

Salesforce impide persistir `EMPRESA_DESCONOCIDA`; por ello se retiró el caso
DML de empresa desconocida. La prueba de empresa nula permanece porque el campo
es nillable y el dry-run confirmó que ese escenario es técnicamente posible.

### Monedas activas

`CurrencyType` confirmó únicamente:

- CRC;
- USD, moneda corporativa.

EUR no está activa y Salesforce impide persistirla. No existe una tercera
moneda activa para representar de forma válida el caso “moneda desconocida”,
por lo que ese escenario DML fue retirado.

`WorkOrder.CurrencyIsoCode` tiene USD como valor predeterminado. Cuando no se
proporciona moneda, Salesforce entrega USD al trigger; con `RMBAVARIAN`, la
conducta real es seleccionar `Bavarian Dólar`. La prueba fue ajustada para
verificar este comportamiento sin cambiar el trigger.

## Correcciones limitadas a pruebas

- Las tres pruebas PEKING se conservaron preparadas, pero sin ejecutarse hasta
  recibir autorización y metadata.
- El bulk se limita temporalmente a Bavarian y Otobai.
- Se retiraron los escenarios DML imposibles de empresa y moneda desconocidas.
- La prueba de moneda omitida ahora espera el default USD y
  `Bavarian Dólar`.
- La prueba histórica crea una entrada estándar CRC cuando hace falta y una
  entrada CRC en el mismo Pricebook que el trigger asignó al WorkOrder.
- No se usa `SeeAllData`, deserialización, bypass ni captura de errores de
  validación.
- `WorkOrderTrigger` no fue modificado durante esta corrección.

## Resolución local del bloqueo de `RMPEKING`

Luis autorizó expresamente agregar `RMPEKING` al picklist restringido. La
metadata recuperada conserva su estructura original:

- label `Empresa que Factura`;
- tipo `Picklist`;
- conjunto restringido;
- campo no requerido;
- `RMOTOBAI` como valor existente no predeterminado;
- `RMBAVARIAN` como valor existente y predeterminado.

Se agregó únicamente:

| Valor | Activo | Predeterminado |
|---|:---:|:---:|
| `RMPEKING` | Sí | No |

Valores finales preparados localmente:

1. `RMOTOBAI`, no predeterminado.
2. `RMBAVARIAN`, predeterminado.
3. `RMPEKING`, no predeterminado.

No se renombraron, eliminaron ni reordenaron los valores existentes. Con la
metadata preparada, las tres pruebas PEKING están activas y el bulk vuelve a
cubrir las seis asociaciones.

El manifest incluye únicamente:

- CustomField `WorkOrder.empresaFactura__c`;
- ApexTrigger `WorkOrderTrigger`;
- ApexClass `WorkOrderTriggerTest`.

No incluye `WorkOrder.object-meta.xml` ni `CustomObject: WorkOrder`.

## Segundo dry-run y corrección de la prueba histórica

El dry-run `0AfAK000000vm1V0AQ` compiló los 3/3 componentes. Se aprobaron
10/11 pruebas y una prueba falló. La cobertura parcial reportada para
`WorkOrderTrigger` fue de 38.125%. La org no fue modificada.

La única falla ocurrió en `WorkOrderTriggerTest.testWorkOrderTrigger`: el valor
legado `Enviar a facturar` ya no es válido para el picklist restringido
`WorkOrder.Etapa_de_flujo_de_trabajo__c`.

La actualización histórica pretende llevar la orden al estado de facturación
y ejecutar el flujo relacionado del trigger. Se sustituyó únicamente el valor
legado por `Facturada`, valor activo que conserva esa intención funcional. No
se modificaron el trigger, la metadata del picklist, las asociaciones de
Pricebook ni las demás pruebas.

Se verificó que las siguientes clases existen y son pruebas Apex ejecutables
para medir la cobertura acumulada real del trigger:

- `WorkOrderTriggerTest`;
- `BMWVinScanTrabajoGeneratorTest`;
- `RM_TraerTrabajosEmailServiceTest`;
- `test_clsClasses`.

Comando propuesto para el siguiente dry-run:

```powershell
sf project deploy start --dry-run --manifest manifest/empresa-marcas-chinas-bloque4-workorder.xml --target-org RedMotorsSandbox --test-level RunSpecifiedTests --tests WorkOrderTriggerTest --tests BMWVinScanTrabajoGeneratorTest --tests RM_TraerTrabajosEmailServiceTest --tests test_clsClasses --wait 60
```

## Comportamiento no modificado

- bloqueo de WorkOrders;
- cambios de etapa;
- anulación con líneas facturadas;
- creación de usuarios y peticiones;
- envío de correo;
- actualización de tipos de cargo;
- validación de eliminación;
- cualquier lógica posterior a la selección de Pricebook.

## Reorientación autorizada al lookup de Empresa

Luis autorizó cambiar la arquitectura del Bloque 4 para que WorkOrder utilice
como fuente principal un lookup configurable a `Empresa__c`. Diego confirmó
que deben mantenerse las condiciones actuales, agregar PEKING como tercera
empresa explícita y evitar estructuras binarias que seleccionen una empresa
por descarte.

Metadata local creada:

| Propiedad | Valor |
|---|---|
| Campo | `WorkOrder.empresaFacturaCP__c` |
| Label | Empresa que Factura |
| Tipo | Lookup |
| Referencia | `Empresa__c` |
| Requerido | No |
| Eliminación | `SetNull` |
| Relationship name | `WorkOrders_Empresa_Factura` |
| Relationship label | Órdenes de trabajo |

El campo heredado `WorkOrder.empresaFactura__c` continúa activo durante la
transición. La precedencia implementada es:

1. Si `empresaFacturaCP__c` está informado, se consulta en bulk
   `Empresa__c.Codigo__c` y ese código gobierna la selección.
2. Solamente cuando el lookup está vacío se utiliza temporalmente
   `empresaFactura__c`.
3. Si lookup y picklist difieren, gana el lookup.
4. Un código o moneda no reconocido conserva `Pricebook2Id`.

No se utiliza `Empresa__c.Name`, no se hardcodean IDs y ninguna empresa se
selecciona por descarte. Las seis asociaciones explícitas permanecen:

- `RMBAVARIAN` + CRC/USD;
- `RMOTOBAI` + CRC/USD;
- `RMPEKING` + CRC/USD.

## Dry-run acumulado anterior al cambio de arquitectura

El dry-run `0AfAK000000vm370AA` compiló 3/3 componentes, aprobó 49/51
pruebas y presentó dos fallas. La cobertura reportada para
`WorkOrderTrigger` fue de 54.375%. La org no fue modificada.

Las fallas fueron:

- `WorkOrderTriggerTest.testWorkOrderTrigger`: límite de 101 consultas
  acumulado por múltiples líneas y operaciones que activaban
  `WorkOrderLineItemTrigger` y
  `WorkOrderLineItemHandler.recalculateParentSADuration`;
- `test_clsClasses.workOrderTriggerTest`: el `PricebookEntry` pertenecía a
  un Pricebook distinto del seleccionado por el WorkOrder.

La prueba histórica se dividió en escenarios independientes de actualización
a facturación y actualización con una sola línea. Cada escenario conserva
aserciones funcionales y una sola operación principal dentro de
`Test.startTest()` y `Test.stopTest()`. La prueba de `test_clsClasses` deja
explícitamente nulos el lookup y el picklist, porque su intención no es
validar selección empresarial.

Las pruebas del lookup crean registros autocontenidos de `Empresa__c` para
`RMBAVARIAN`, `RMOTOBAI`, `RMPEKING` y un código no reconocido. Cubren las
seis asociaciones, insert, update, bulk, precedencia sobre un picklist
contradictorio, compatibilidad heredada, ambos campos vacíos, código no
reconocido, moneda omitida y ausencia de fallback.

No se crearon registros operativos de Empresa. Permanecen pendientes los
permisos del nuevo campo, la carga y el mapeo de registros reales y la
definición del retiro futuro del picklist heredado.

## Dry-run posterior al cambio de arquitectura

El dry-run `0AfAK000000vm9Z0AQ` compiló 5/5 componentes, aprobó 26/30
pruebas y presentó cuatro fallas. La cobertura reportada para
`WorkOrderTrigger` fue de 43.931%. La org no fue modificada.

Dos fallas correspondieron a
`test_clsClasses.orderTriggerHandlerTest` y
`test_clsClasses.orderTriggerHandlerTest1`. Esas pruebas pertenecen a los
dominios de Order y Account y quedaron incluidas únicamente porque se
ejecutó la clase completa. El cambio local de este bloque fue revertido
exactamente y `test_clsClasses` se retiró del manifest. No se modificaron sus
pruebas ni los componentes productivos relacionados.

Las otras dos fallas compartieron la preparación duplicada de
`PricebookEntry`. El helper insertaba incondicionalmente la entrada estándar
y la entrada del Pricebook del WorkOrder aun cuando la combinación
`Pricebook2Id + Product2Id + CurrencyIsoCode` ya existía para el producto.
El helper ahora consulta las entradas del producto, las indexa por Pricebook
y moneda, inserta solo las faltantes y devuelve la entrada correspondiente al
Pricebook del WorkOrder. No captura ni ignora `DUPLICATE_VALUE`.

Se agregaron tres pruebas funcionales directas:

- desbloqueo de una WorkOrder y normalización de la etapa a `Proceso`;
- rechazo de la anulación cuando existe una única línea `Facturado`;
- actualización de `tipoCargo__c` a código `5` al cambiar el gasto a `BCI`,
  con una sola línea y sin integraciones.

El escenario `before delete` no se agregó. Su resultado depende del permiso
`User.CanDeleteWO__c`; aislar ambas ramas exigiría crear o modificar un
usuario, lo que introduce riesgo de Mixed DML o cambios de permisos ajenos al
alcance.

El siguiente dry-run debe ejecutar únicamente:

- `WorkOrderTriggerTest`;
- `BMWVinScanTrabajoGeneratorTest`;
- `RM_TraerTrabajosEmailServiceTest`.

La cobertura objetivo continúa siendo al menos 75%, preferiblemente 80%, y
debe confirmarse con la medición del siguiente dry-run.

## Dry-run y estabilización final de cobertura

El dry-run `0AfAK000000vmHd0AI` compiló 4/4 componentes, aprobó 44/45
pruebas y presentó una falla. La cobertura reportada para
`WorkOrderTrigger` fue de 60.694%. La org no fue modificada.

El detalle real de cobertura identificó 173 líneas ejecutables:

- 105 cubiertas;
- 68 no cubiertas.

La única falla ocurrió en
`WorkOrderTriggerTest.updatesTipoCargoForBciExpense`. Al crear la línea,
la automatización podía generar un cargo automáticamente; la prueba insertaba
después otro cargo con porcentaje 100 y superaba el límite acumulado.

La corrección consulta los cargos existentes para la línea y reutiliza el
primero. Solamente crea un cargo al 100% cuando no existe ninguno y valida
que la suma acumulada sea menor o igual a 100. Después conserva la aserción
funcional de que BCI termina con `tipoCargo__c = '5'`.

Se agregaron pruebas independientes para las ramas seguras de `after update`:

| Tipo de gasto | Código esperado |
|---|---:|
| Cliente | `1` |
| BSI Interno | `6` |
| Aseguradora | `3` |
| Interno | `2` |

Cada prueba utiliza una WorkOrder, una línea, los cargos mínimos y una única
actualización principal. Aseguradora utiliza una Account de prueba e Interno
un CentroCosto de prueba; no se usan integraciones ni datos operativos.

También se agregó una prueba aislada para la rama de envío de presupuesto.
La prueba crea Account, Contact y WorkOrder propios, cambia
`Enviar_presupuesto_a_service__c` de falso a verdadero y utiliza el perfil
existente `Customer Community User Test` a través de la lógica productiva.
La prueba confirma que:

- la WorkOrder conserva el indicador y el Contact;
- se crea exactamente un User para el Contact;
- Username, Email, nombre y apellido corresponden al Contact de prueba;
- se crea exactamente una `Peticion_de_envio__c` con el mismo email, nombre
  y apellido;
- no depende del envío de un correo real.

No se agregó cobertura de `before delete`, no se modificaron permisos y no
se cambió código productivo. Con las ramas de tipo de cargo y presupuesto,
la cobertura esperada supera el mínimo de 75%; el porcentaje definitivo debe
confirmarse mediante dry-run.

## Dry-run con aprovisionamiento exitoso y discrepancia de Garantía

El dry-run `0AfAK000000vmRJ0AY` compiló 4/4 componentes y aprobó 49/51
pruebas. La org no fue modificada. El detalle de cobertura confirmó 163 de
173 líneas cubiertas, equivalente a 94.220%.

La prueba de presupuesto esperaba que el alta de User fallara, pero la
ejecución real creó correctamente un User asociado al Contact y la petición
correspondiente. El método se renombró a
`budgetRequestCreatesCommunityUser` y ahora valida únicamente registros
propios de la prueba:

- exactamente un User consultado por el `ContactId` creado;
- Username y Email iguales al email único;
- nombre `Cliente` y apellido `Presupuesto`;
- exactamente una `Peticion_de_envio__c` consultada por ese email;
- email, nombre y apellido correctos en la petición;
- indicador de envío y Contact conservados en la WorkOrder.

La segunda falla reveló una discrepancia funcional:

- el valor activo del picklist restringido `WorkOrder.tipoDeGasto__c` es
  `Garantia`, sin tilde;
- `WorkOrderTrigger` compara `Garantía`, con tilde.

No existe actualmente un valor persistible que alcance esa rama productiva.
Se retiró únicamente `updatesTipoCargoForWarrantyExpense`. Corregir el
literal del trigger o modificar el valor del picklist requiere una decisión
funcional posterior. No se modificaron código productivo, metadata ni datos
de la org.

## Dry-run final exitoso

El dry-run final `0AfAK000000vmSv0AI` terminó con estado `Succeeded`:

| Resultado | Valor |
|---|---:|
| Componentes | 4/4 |
| Pruebas | 50/50 |
| Fallas | 0 |

La org no fue modificada porque la validación fue un dry-run. Durante la
estabilización se comprobó una cobertura de 163/173 líneas para
`WorkOrderTrigger`, equivalente a 94.220%.

Quedaron validados:

- `WorkOrder.empresaFacturaCP__c` como lookup principal a `Empresa__c`;
- `WorkOrder.empresaFactura__c` como compatibilidad temporal;
- precedencia del lookup cuando ambos campos contienen valores;
- soporte explícito para `RMBAVARIAN`, `RMOTOBAI` y `RMPEKING`;
- las seis combinaciones empresa/moneda;
- ausencia de selección por descarte;
- conservación de `Pricebook2Id` ante empresa o moneda no reconocida.

## Cierre de jornada — 25/07/2026

Hora de cierre: 01:01 a. m., zona horaria de Monterrey, Nuevo León.

Avance técnico estimado:

- completado: 62%;
- pendiente: 38%.

Esta distribución es una estimación basada en alcance técnico. No representa
horas oficiales registradas, consumidas ni facturables.

Pendientes:

1. Respuesta de Luis sobre la discrepancia entre `Garantia`, valor activo del
   picklist, y `Garantía`, literal utilizado por el trigger.
2. Deploy real del Bloque 4.
3. Permisos para `WorkOrder.empresaFacturaCP__c`.
4. Creación y mapeo de registros operativos de `Empresa__c`.
5. Migración de WorkOrders existentes.
6. Decisión futura para retirar el picklist heredado
   `WorkOrder.empresaFactura__c`.
7. Siguientes componentes Apex identificados en el inventario.

La rama de garantía permanece inaccesible con la configuración actual. Se
consultó a Luis si debe corregirse ahora o quedar pendiente. Hasta recibir
respuesta no debe modificarse el trigger ni el picklist.

## Deploy real y cierre técnico

El 25/07/2026, con inicio de jornada a las 9:00 a. m., se registró a las
12:49 p. m. el deploy real `0AfAK000000vnon0AA` en
`RedMotorsSandbox / Partial`.

| Resultado | Valor |
|---|---:|
| Estado | Succeeded |
| Componentes | 4/4 |
| Pruebas | 50/50 |
| Fallas | 0 |

Componentes desplegados:

- `WorkOrder.empresaFacturaCP__c`;
- `WorkOrder.empresaFactura__c`;
- `WorkOrderTrigger`;
- `WorkOrderTriggerTest`.

El comportamiento disponible en el ambiente es:

- `empresaFacturaCP__c` como fuente principal;
- `empresaFactura__c` como compatibilidad temporal;
- precedencia del lookup cuando ambos campos están informados;
- soporte explícito para `RMBAVARIAN`, `RMOTOBAI` y `RMPEKING`;
- conservación de las seis combinaciones empresa/moneda.

El Bloque 4 queda completado y desplegado.

El avance técnico estimado del Sprint 1 queda en 65% completado y 35%
pendiente. Esta estimación se basa en alcance técnico y no representa horas
oficiales, trabajadas, registradas ni facturables.

La discrepancia `Garantia` / `Garantía` continúa pendiente. Luis indicó que
debe corregirse antes de cerrar el Sprint 1.

## Riesgos heredados no corregidos

- El trigger consulta todos los Pricebooks sin filtrar por estado.
- Un mapa por `Name` conserva un solo Id cuando existen nombres duplicados.
- Un Pricebook esperado inexistente puede producir una asignación nula.
- El trigger mantiene múltiples responsabilidades.
- Existen consultas y DML en secciones que no fueron refactorizadas.
- La regla de conservar Pricebook ante empresa vacía o desconocida es temporal
  y todavía requiere confirmación final de Diego.
- Las pruebas indirectas no se modificaron y deben incluirse en regresión
  antes del deploy.

## Fuera de alcance

- `UpdateCurrencyScheduler`;
- triggers `ChanceAccount`;
- Softland;
- reservas;
- inventario y bodegas;
- anticipos;
- `PricebookEntry` reales;
- objetos, campos, clases auxiliares o registros.

## Estado de despliegue

El dry-run y el deploy real finalizaron correctamente. Permanecen pendientes
la configuración de permisos y datos operativos, la migración de WorkOrders
existentes y la corrección `Garantia` / `Garantía` antes del cierre del
Sprint 1.
