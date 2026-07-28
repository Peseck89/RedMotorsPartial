# Bitácora técnica de implementación

## 1. Información general

| Dato | Valor |
|---|---|
| Proyecto | RedMotors — Empresa Configurable y Marcas Chinas |
| Objetivo | Incorporar nuevas empresas y marcas reduciendo decisiones binarias Bavarian/Otobai y evitando defaults silenciosos |
| Nueva empresa | PEKING |
| Marcas | Omoda y Jaecoo |
| Ambiente | RedMotorsSandbox, Sandbox Partial |
| Org ID documentado | `00DAK000000npFt2AI` |
| Rama | `feature/pc/redmotors-empresa-marcas-chinas-sprint1-20260724` |
| Repositorio | `C:\Users\dokur\Documents\Repositorios\RedMotors-Empresa-Marcas-Chinas` |
| Alcance aprobado | 30 horas Apex + 14 horas para objeto Empresa y clases de soporte |

La asignación aprobada representa un Sprint 1 de 44 horas. Las estimaciones
incluidas en esta bitácora son técnicas; no deben interpretarse como horas
reales facturables mientras no exista un registro oficial de tiempo.

## 2. Estado ejecutivo

- Bloque 1 desplegado y probado: objeto `Empresa__c`, clases de soporte,
  pruebas y Permission Set `Empresa_Admin`.
- Bloque 2 desplegado y probado: conversión de moneda por nombres autorizados
  para Bavarian, Otobai y PEKING en `BMW_ChangeCurrencyWOWOLI` y
  `QuoteController`.
- Bavarian y Otobai conservan sus pares de Pricebook.
- PEKING tiene soporte explícito en Apex para `PEKING Local` y
  `PEKING Dólares`.
- No existe fallback a Bavarian, Otobai ni PEKING en los dos consumidores
  modificados.
- Los Pricebooks `PEKING Local` y `PEKING Dólares` ya existen y están activos
  en `RedMotorsSandbox`.
- PEKING aún no está completamente operativa: faltan `PricebookEntry`,
  productos, registros operativos de Empresa y consumidores pendientes.

## 3. Línea de tiempo

Todas las fechas verificables del historial corresponden al 24 de julio de
2026. Cuando una acción no tiene hora o fecha propia en la evidencia, se
conserva el orden relativo sin inventar precisión.

| Orden | Hito | Evidencia y resultado |
|---:|---|---|
| 1 | Inicio del análisis | Se creó el contexto y se incorporaron sin modificación las dos fuentes originales. Commit `4397836`. |
| 2 | Inventario local | Se analizaron 986 archivos `.cls`; 69 clases productivas presentaban evidencia funcional relevante. Inicialmente no había archivos `.trigger` locales. |
| 3 | Validación de solo lectura contra Partial | Se confirmaron las 69 clases locales activas, cinco clases productivas adicionales, cuatro triggers y diez tests adicionales. `DummyRemovalCoverageTest` quedó solo documental/no confirmado. |
| 4 | Retrieve dirigido de línea base | Se recuperaron cinco clases productivas, cuatro triggers y diez tests, para una línea base de 74 clases productivas, cuatro triggers y 67 tests relacionados. Commit `2b9d850`. |
| 5 | Cierre del plan | Se clasificaron 41 clases directas, 21 dependencias indirectas, 12 pendientes de validación funcional, un trigger directo y tres triggers pendientes de decisión. Commit `6e218e2`. |
| 6 | Presupuesto | Luis confirmó 30 horas Apex más 14 horas para objeto y soporte; total de referencia: 44 horas. |
| 7 | Modelo Empresa | Se creó `Empresa__c`, sus cuatro campos, el contexto, resolver, excepción y tests. Commit `7f8b919`. |
| 8 | Primer dry-run del Bloque 1 | `0AfAK000000vhkz0AA`: 9/9 componentes y 9/9 pruebas correctas, sin fallas de tests; bloqueó únicamente la cobertura de `EmpresaContext` en 52.381%. |
| 9 | Corrección de cobertura | Se agregó cobertura directa para invariantes, getters y errores de `EmpresaContext`. La ejecución `0AfAK000000vhpp0AA` fue mencionada como evidencia, pero sus cifras y resultado no constan en los documentos revisados. |
| 10 | Deploy real del Bloque 1 | `0AfAK000000vhrR0AQ`: 10/10 componentes, 18/18 pruebas, cero fallas. |
| 11 | Permission Set | Se creó `Empresa_Admin`, sin eliminación, View All ni Modify All. |
| 12 | Primer deploy del Permission Set | `0AfAK000000vi9B0AQ`: falló, 0/1 desplegados; Salesforce rechazó `fieldPermissions` sobre el campo obligatorio `Codigo__c`. La org no cambió. |
| 13 | Corrección de permisos | Se omitió intencionalmente `Codigo__c` de `fieldPermissions`, sin cambiar su carácter Required, Unique y External ID. |
| 14 | Validación y deploy del Permission Set | Dry-run `0AfAK000000viCP0AY` y deploy real `0AfAK000000viHF0AY`, ambos 1/1 y exitosos. Commit `cc1614c`. |
| 15 | Análisis de Pricebooks | Se evaluó una configuración Empresa + moneda → Pricebook; el bloque se pausó mientras se solicitaba decisión funcional. |
| 16 | Decisión de Pricebooks | Diego autorizó mantener nombres fijos, no crear campos en `Pricebook2`, priorizar los `if` de Apex y usar PEKING con Omoda y Jaecoo. |
| 17 | Implementación inicial del Bloque 2 | Se modificaron dos clases productivas y sus tests para los seis nombres autorizados y errores controlados. |
| 18 | Primer dry-run del Bloque 2 | `0AfAK000000vlNB0AY`: 4/4 componentes, 7/12 pruebas aprobadas y cinco fallas. No cambió la org. |
| 19 | Primera corrección de pruebas | Se separaron las conversiones por transacción y se corrigieron códigos y campos obligatorios de datos de prueba. |
| 20 | Segundo dry-run del Bloque 2 | `0AfAK000000vlOn0AI`: 4/4 componentes, 19/22 pruebas aprobadas y tres fallas de datos. No cambió la org. |
| 21 | Segunda corrección de pruebas | Se eliminó una entrada de precio duplicada y se ajustaron valores de picklist a valores activos confirmados. |
| 22 | Dry-run final del Bloque 2 | `0AfAK000000vlS10AI`: 4/4 componentes, 22/22 pruebas y cero fallas. |
| 23 | Deploy real del Bloque 2 | `0AfAK000000vlTd0AI`: 4/4 componentes, 22/22 pruebas y cero fallas. |
| 24 | Registro en Git | El Bloque 2 quedó en el commit `9669237`. Al revisar esta bitácora, la rama local y su rama remota apuntaban al mismo commit. |
| 25 | Consulta previa de Pricebooks PEKING | Se confirmó que no existían Pricebooks con los nombres `PEKING Local` y `PEKING Dólares`. |
| 26 | Creación autorizada de datos | Se crearon `PEKING Local` y `PEKING Dólares` activos en `RedMotorsSandbox`. Fue una operación de datos autorizada, no un deploy de metadata. No se crearon `PricebookEntry`, productos ni registros de `Empresa__c`. |
| 27 | Bloque 3 local — scheduler de moneda | Se agregó soporte explícito para corregir entradas de `PEKING Local` de USD a CRC y de `PEKING Dólares` de CRC a USD en `UpdateCurrencyScheduler`. Se fortalecieron las pruebas para los seis nombres autorizados y un Pricebook desconocido. Implementación local pendiente de dry-run; `WorkOrderTrigger` permanece sin cambios. |
| 28 | Primer dry-run del Bloque 3 | `0AfAK000000vli90AA`: 2/2 componentes compilados, 0/7 pruebas aprobadas y cobertura 0% de `UpdateCurrencyScheduler`. Todas las pruebas fallaron antes de ejecutar el scheduler porque `createStandardPrices()` intentaba duplicar la entrada estándar USD ya generada después de insertar el producto. La org no fue modificada. Se corrigió el helper para reutilizar monedas existentes dentro de la prueba e insertar únicamente las definiciones estándar faltantes. |
| 29 | Dry-run exitoso del Bloque 3 | `0AfAK000000vljl0AA`: 2/2 componentes, 7/7 pruebas y cero fallas. |
| 30 | Deploy real del Bloque 3 | `0AfAK000000vllN0AQ`: 2/2 componentes, 7/7 pruebas y cero fallas. `UpdateCurrencyScheduler` quedó actualizado en `RedMotorsSandbox` con soporte para `PEKING Local` y `PEKING Dólares`, conservando las cuatro conversiones anteriores, sin fallbacks y sin procesar Pricebooks desconocidos. No se crearon `PricebookEntry` reales ni se modificaron Softland, reservas, inventario o anticipos. El riesgo heredado de eliminar antes de reinsertar permanece sin corregir por no estar autorizado. `WorkOrderTrigger` sigue pendiente de respuesta de Diego. |
| 31 | Bloque 4 local — Pricebook de WorkOrder | Se confirmó `RMPEKING` como código de `WorkOrder.empresaFactura__c` y se agregaron las asociaciones CRC → `PEKING Local` y USD → `PEKING Dólares` en `WorkOrderTrigger`. Luis confirmó temporalmente conservar el Pricebook actual ante empresa vacía o desconocida, pendiente de confirmación final de Diego. Se retiró `Test.isRunningTest()` únicamente de la selección y se fortaleció `WorkOrderTriggerTest` con las seis asociaciones, casos de conservación, insert, update y procesamiento bulk. Implementación local pendiente de dry-run. |
| 32 | Primer dry-run del Bloque 4 | `0AfAK000000vlzt0AA`: 2/2 componentes compilados, 5/13 pruebas aprobadas, ocho fallas y 35% de cobertura del trigger. La org no fue modificada. La validación de solo lectura confirmó que `empresaFactura__c` es restringido y solo admite `RMBAVARIAN` y `RMOTOBAI`; `RMPEKING` está pendiente de autorización de Diego. `CurrencyType` solo tiene CRC y USD activas, y WorkOrder usa USD cuando se omite la moneda. Se dejaron preparadas pero inactivas las pruebas PEKING, se retiraron los DML imposibles de empresa/moneda desconocidas, se ajustó la expectativa de moneda omitida y se corrigió la prueba histórica para usar un `PricebookEntry` del Pricebook asignado. |
| 33 | Autorización y metadata de `RMPEKING` | Luis autorizó expresamente agregar `RMPEKING` al picklist restringido `WorkOrder.empresaFactura__c`. La metadata del campo y del objeto WorkOrder fue recuperada desde `RedMotorsSandbox`; `WorkOrder.object-meta.xml` permanece sin cambios. Se agregó únicamente `RMPEKING` activo y no predeterminado, conservando `RMBAVARIAN` como predeterminado y `RMOTOBAI` como valor existente. Se reactivaron las tres pruebas PEKING y las dos combinaciones PEKING del escenario bulk. La decisión temporal de conservar Pricebook ante empresa nula o no aplicable continúa pendiente de confirmación final de Diego. |
| 34 | Segundo dry-run del Bloque 4 | `0AfAK000000vm1V0AQ`: 3/3 componentes compilados, 10/11 pruebas aprobadas, una falla y cobertura parcial de 38.125% para `WorkOrderTrigger`. La única falla provenía del valor legado `Enviar a facturar` en `testWorkOrderTrigger`; se reemplazó por el valor activo `Facturada`, que conserva la intención funcional de facturación. La org no fue modificada. |
| 35 | Dry-run acumulado del Bloque 4 | `0AfAK000000vm370AA`: 3/3 componentes, 49/51 pruebas aprobadas, dos fallas y cobertura de 54.375% para `WorkOrderTrigger`. Las causas fueron el límite de 101 consultas en la prueba histórica por operaciones acumuladas sobre líneas y un `PricebookEntry` incompatible en `test_clsClasses.workOrderTriggerTest`. La org no fue modificada. |
| 36 | Reorientación local del Bloque 4 | Luis autorizó `WorkOrder.empresaFacturaCP__c` como lookup principal a `Empresa__c`, con relación `WorkOrders_Empresa_Factura` y label `Órdenes de trabajo`. Diego confirmó mantener temporalmente `empresaFactura__c` como respaldo, dar precedencia al lookup y conservar las seis asociaciones explícitas sin selección por descarte. Se prepararon metadata, resolución bulk por `Empresa__c.Codigo__c`, pruebas autocontenidas y estabilización de las dos pruebas fallidas. Permisos, registros operativos y mapeo de datos continúan pendientes. |
| 37 | Segundo dry-run de la arquitectura lookup | `0AfAK000000vm9Z0AQ`: 5/5 componentes, 26/30 pruebas aprobadas, cuatro fallas y cobertura de 43.931% para `WorkOrderTrigger`. La org no fue modificada. Dos fallas pertenecían a pruebas ajenas de Order/Account incluidas al ejecutar toda `test_clsClasses`; se revirtió exactamente el cambio local en esa clase y se retiró del manifest. Las otras dos fallas compartían creación duplicada de `PricebookEntry`; el helper ahora reutiliza las combinaciones existentes e inserta solo las faltantes. Se agregaron pruebas de desbloqueo, rechazo de anulación con una línea facturada y actualización de `tipoCargo__c` para BCI. `before delete` se difirió porque aislar el permiso del usuario introduciría Mixed DML o cambios de permisos. |
| 38 | Dry-run y estabilización de cobertura del Bloque 4 | `0AfAK000000vmHd0AI`: 4/4 componentes, 44/45 pruebas aprobadas, una falla y cobertura de 60.694% para `WorkOrderTrigger`. La org no fue modificada. El reporte identificó 173 líneas ejecutables, 105 cubiertas y 68 no cubiertas. La falla BCI provenía de insertar un cargo al 100% adicional al creado automáticamente; la prueba ahora reutiliza el cargo existente, crea uno al 100% solo si falta y valida una suma máxima de 100. Se agregaron pruebas para Cliente `1`, Garantía `4`, BSI Interno `6`, Aseguradora `3`, Interno `2` y una prueba aislada del flujo de presupuesto que verifica el manejo existente del DML de User sin correo real ni registros parciales. No se modificó código productivo ni se agregó `before delete`. |
| 39 | Dry-run con aprovisionamiento exitoso | `0AfAK000000vmRJ0AY`: 4/4 componentes y 49/51 pruebas aprobadas. La cobertura real fue 163/173 líneas, equivalente a 94.220%. La org no fue modificada. La rama de presupuesto creó correctamente un User asociado al Contact y una `Peticion_de_envio__c`; la prueba se renombró y ahora valida exactamente ese User, Username, Email, nombres, petición e indicador de WorkOrder sin depender del correo real. La segunda falla confirmó un defecto funcional: el picklist activo usa `Garantia`, pero `WorkOrderTrigger` compara `Garantía`. La prueba de esa rama se retiró porque ningún valor válido actual puede ejecutarla. Queda pendiente decidir si se corrige el literal productivo o el valor del picklist; no se modificaron código productivo, metadata ni datos. |
| 40 | Dry-run final exitoso del Bloque 4 | `0AfAK000000vmSv0AI`: estado `Succeeded`, 4/4 componentes, 50/50 pruebas y cero fallas. La org no fue modificada porque la ejecución fue un dry-run. Quedó validada la arquitectura con `WorkOrder.empresaFacturaCP__c` como lookup principal, `empresaFactura__c` como compatibilidad temporal, precedencia del lookup, las seis combinaciones empresa/moneda y conservación del Pricebook ante código o moneda no reconocidos. |
| 41 | Deploy real exitoso del Bloque 4 | El 25/07/2026 a las 12:49 p. m. se completó en `RedMotorsSandbox / Partial` el deploy `0AfAK000000vnon0AA`, con estado `Succeeded`, 4/4 componentes, 50/50 pruebas y cero fallas. Quedaron desplegados `WorkOrder.empresaFacturaCP__c`, `WorkOrder.empresaFactura__c`, `WorkOrderTrigger` y `WorkOrderTriggerTest`. El Bloque 4 queda completado y desplegado. |
| 42 | Bloque 5 local — Garantia en WorkOrder | Luis autorizó corregir antes del cierre del Sprint 1 la discrepancia entre el valor activo `Garantia` y el literal productivo `Garantía`. Se cambió únicamente el literal del switch en `WorkOrderTrigger`, se restauró `updatesTipoCargoForWarrantyExpense` y se mantuvo la validación de porcentajes menor o igual a 100. No se modificaron metadata, lógica de Empresa, Pricebooks ni otros componentes. Implementación local pendiente de dry-run. |

## 4. Decisiones autorizadas

| Decisión | Confirmada por | Evidencia disponible | Fecha aproximada | Impacto técnico |
|---|---|---|---|---|
| Presupuesto de 30 horas Apex + 14 horas de modelo y soporte | Luis | Confirmación registrada en el alcance de trabajo y reflejada en el plan | 24 de julio de 2026 | Separa el esfuerzo de soporte del esfuerzo sobre consumidores |
| Nueva empresa: PEKING | Diego | Autorización registrada antes del Bloque 2 | 24 de julio de 2026 | Agrega una tercera rama explícita, sin activar todavía la operación completa |
| Marcas: Omoda y Jaecoo | Diego | Misma autorización del Bloque 2 | 24 de julio de 2026 | Define las marcas asociadas al alcance PEKING; no crea por sí sola relaciones o registros |
| Pricebooks `PEKING Local` y `PEKING Dólares` | Diego | Autorización registrada en la solicitud del Bloque 2 | 24 de julio de 2026 | Define los nombres exactos para CRC y USD |
| Crear ambos Pricebooks activos desde su creación | Diego | Autorización registrada antes de la operación de datos | Fecha exacta no confirmada | Permitió crear los dos registros activos en `RedMotorsSandbox`, sin cargar productos |
| Mantener Pricebooks por nombres fijos | Diego | Decisión expresa posterior al análisis de alternativas | 24 de julio de 2026 | Se conserva `Pricebook2.Name` como clave funcional autorizada para este bloque |
| Priorizar la corrección de los `if` de Apex | Diego | Decisión expresa del Bloque 2 | 24 de julio de 2026 | Se corrigieron ramas binarias y fallbacks en dos consumidores |
| No crear campos nuevos en `Pricebook2` | Diego | Decisión expresa del Bloque 2 | 24 de julio de 2026 | Se descartó para este bloque una relación configurable Empresa + moneda |

No se atribuyen a Luis o Diego decisiones que no estén registradas en las
fuentes revisadas. Las decisiones de códigos ERP, sharing definitivo y
operación integral permanecen pendientes.

### 4.1 Pricebooks creados en RedMotorsSandbox

La consulta previa confirmó que no existían registros con esos nombres. Después
de la autorización de Diego se crearon:

| Name | Id de RedMotorsSandbox | IsActive | IsStandard | CurrencyIsoCode |
|---|---|:---:|:---:|---|
| `PEKING Local` | `01sAK0000006DVdYAM` | true | false | USD |
| `PEKING Dólares` | `01sAK0000006DXFYA2` | true | false | USD |

Los IDs pertenecen exclusivamente a `RedMotorsSandbox`. No son portables entre
ambientes y no deben guardarse ni compararse en Apex, tests o configuración
desplegable.

La creación fue una operación de datos autorizada, no un deploy de metadata.
No se crearon `PricebookEntry`, no se cargaron productos y no se crearon
registros de `Empresa__c`.

## 5. Línea base técnica

### 5.1 Conteos confirmados después del retrieve

| Categoría | Cantidad | Estado |
|---|---:|---|
| Clases productivas revisadas | 74 | Presentes localmente |
| Clases de test relacionadas | 67 | Presentes localmente |
| Triggers | 4 | Presentes localmente |
| Test solo documental | 1 | `DummyRemovalCoverageTest`, no confirmado |
| Falsos positivos identificados | 9 | Excluidos del alcance funcional |

### 5.2 Clasificación funcional

| Clasificación | Clases | Triggers |
|---|---:|---:|
| Directo Sprint 1 | 41 | 1 |
| Dependencia indirecta | 21 | 0 |
| Requiere validación funcional | 12 | 3 |

Las 41 clases constituyen el alcance técnico directo detectado, no el alcance
completado ni una obligación de modificarlas todas dentro de las 44 horas.

## 6. Componentes creados

### 6.1 Objeto `Empresa__c`

| Elemento | Configuración implementada |
|---|---|
| `Name` | Texto; etiqueta “Nombre de Empresa”; no es clave técnica |
| `Codigo__c` | Text(80), requerido, Unique, External ID y case-insensitive |
| `Codigo_ERP__c` | Text(80); requerido funcionalmente por el resolver para empresa activa |
| `Nombre_Legal__c` | Text(255); requerido funcionalmente por el resolver |
| `Activa__c` | Checkbox, default true |
| Sharing | ReadWrite, pendiente de confirmación definitiva |
| Reportes | Habilitados |

### 6.2 Clases de soporte

- `EmpresaResolver`: resolución por Id o `Codigo__c`, APIs bulk, caché por
  transacción y validación fail-closed.
- `EmpresaContext`: contexto sin SOQL, propiedades de solo lectura e
  invariantes validadas antes de quedar `CONFIGURED`.
- `EmpresaConfigurationException`: excepción controlada para configuración
  nula, desconocida, inactiva, incompleta o inconsistente.
- `EmpresaResolverTest`: pruebas unitarias, negativas y bulk por Id/código.
- `EmpresaContextTest`: pruebas directas de invariantes, estado, getters y
  excepciones.

### 6.3 Permission Set

`Empresa_Admin` incluye:

- lectura, creación y edición de `Empresa__c`;
- lectura y edición de `Codigo_ERP__c`, `Nombre_Legal__c` y `Activa__c`;
- acceso a `EmpresaResolver` y `EmpresaContext`.

Excluye eliminación, View All Records, Modify All Records, clases de test,
asignaciones de usuarios y Custom Tab. `Codigo__c` se omite de
`fieldPermissions` porque Salesforce no admite esa entrada para un campo
obligatorio.

### 6.4 Manifests

| Manifest | Contenido |
|---|---|
| `empresa-marcas-chinas-sprint1-retrieve.xml` | Cinco clases productivas, diez tests y cuatro triggers recuperados |
| `empresa-marcas-chinas-bloque1.xml` | `Empresa__c` y cinco clases Apex del Bloque 1, incluidos dos tests |
| `empresa-marcas-chinas-bloque1-permisos.xml` | `Empresa_Admin` |
| `empresa-marcas-chinas-bloque2-pricebook.xml` | Dos clases productivas y sus dos tests |

### 6.5 Documentación

- `CONTEXTO_CODEX_EMPRESA_MARCAS_CHINAS.md`
- `INVENTARIO_APEX_SPRINT1.md`
- `PLAN_IMPLEMENTACION_SPRINT1.md`
- `IMPLEMENTACION_BLOQUE1.md`
- `IMPLEMENTACION_BLOQUE2_PRICEBOOK.md`
- esta bitácora central.

Los documentos originales del alcance se mantienen sin modificaciones.

## 7. Componentes modificados

| Componente | Comportamiento anterior | Riesgo anterior | Cambio realizado | Comportamiento final | Pruebas |
|---|---|---|---|---|---|
| `BMW_ChangeCurrencyWOWOLI` | Reconocía Otobai y trataba otros valores como Bavarian | Una empresa desconocida podía usar el Pricebook de Bavarian | Mapeo explícito de seis nombres; validación previa del origen y destino | Conversión bidireccional CRC/USD para Bavarian, Otobai y PEKING; error controlado ante nulo, desconocido, inexistente o ambiguo | `BMW_ChangeCurrencyWOWOLITest`, con seis conversiones separadas y casos negativos |
| `BMW_ChangeCurrencyWOWOLITest` | Cobertura centrada en pares existentes | No demostraba PEKING ni ausencia de fallback | Datos autocontenidos y una conversión por transacción | Valida pares autorizados, líneas y errores sin depender de datos del org | Parte de las 22/22 pruebas finales |
| `QuoteController` | Inicializaba el destino en Bavarian Local, contenía una tabulación residual en Otobai y no tenía PEKING | Podía seleccionar un Pricebook incorrecto o fallar después de modificar líneas | Eliminación del default, corrección del literal y mapeo explícito PEKING | Valida antes de eliminar o actualizar; conserva la regla existente de no recrear `WorkOrderLineItem` | `QuoteControllerTest` y pruebas relacionadas incluidas en el dry-run |
| `QuoteControllerTest` | No cubría todos los pares y tenía datos incompatibles con el estado actual del org | Límites SOQL, duplicados y valores de picklist inactivos | Casos separados, productos/códigos únicos y valores activos `Cita`/`Aprobación` | Pruebas autocontenidas, sin `SeeAllData`, con validación anterior al DML | Parte de las 22/22 pruebas finales |

No se modificaron `UpdateCurrencyScheduler`, `WorkOrderTrigger`, Softland,
reservas, anticipos ni inventario durante el Bloque 2.

## 8. Evidencias de Salesforce

| Deploy ID | Tipo | Resultado | Componentes | Pruebas | Fallas | Motivo o corrección |
|---|---|---|---:|---:|---:|---|
| `0AfAK000000vhkz0AA` | Dry-run Bloque 1 | Bloqueado por cobertura | 9/9 correctos | 9/9 aprobadas | 0 | `EmpresaContext` tenía 52.381%; se agregó `EmpresaContextTest` |
| `0AfAK000000vhpp0AA` | Pendiente de confirmación | Pendiente de confirmación documental | No confirmado | No confirmado | No confirmado | El ID fue suministrado para la bitácora, pero no aparece detallado en los documentos revisados |
| `0AfAK000000vhrR0AQ` | Deploy real Bloque 1 | Succeeded | 10/10 | 18/18 | 0 | Objeto, soporte y tests disponibles en `RedMotorsSandbox` |
| `0AfAK000000vi9B0AQ` | Deploy real Permission Set | Failed | 0/1 | No aplica | No aplica | `fieldPermissions` no permitido para `Empresa__c.Codigo__c`; la org no cambió |
| `0AfAK000000viCP0AY` | Dry-run Permission Set | Succeeded | 1/1 | No aplica | 0 | Se validó el Permission Set sin permiso explícito del campo obligatorio |
| `0AfAK000000viHF0AY` | Deploy real Permission Set | Succeeded | 1/1 | No aplica | 0 | `Empresa_Admin` quedó disponible y sin asignaciones |
| `0AfAK000000vlNB0AY` | Dry-run Bloque 2 | Failed por tests | 4/4 | 7/12 | 5 | Límites SOQL por seis conversiones juntas, campo obligatorio ausente y códigos duplicados |
| `0AfAK000000vlOn0AI` | Dry-run Bloque 2 | Failed por tests | 4/4 | 19/22 | 3 | `PricebookEntry` duplicado y valor inactivo `Nuevo` en dos pruebas |
| `0AfAK000000vlS10AI` | Dry-run Bloque 2 | Succeeded | 4/4 | 22/22 | 0 | Validación final del bloque |
| `0AfAK000000vlTd0AI` | Deploy real Bloque 2 | Succeeded | 4/4 | 22/22 | 0 | Clases productivas disponibles con soporte PEKING |

Los dry-runs fallidos no modificaron la organización. El intento fallido del
Permission Set tampoco desplegó componentes.

## 9. Evidencias Git

| Hash | Mensaje | Contenido principal | Estado de push |
|---|---|---|---|
| `4397836` | `docs(empresa): initialize marcas chinas sprint 1 context` | Contexto y dos fuentes originales | Confirmado en la rama remota |
| `7fcb996` | `docs(empresa): validate apex sprint 1 inventory` | Inventario Apex y validación de línea base | Confirmado en la rama remota |
| `2b9d850` | `chore(empresa): sync sprint 1 apex baseline from partial` | Retrieve dirigido: cinco clases, diez tests, cuatro triggers y manifest | Confirmado en la rama remota |
| `6e218e2` | `docs(empresa): define sprint 1 implementation plan` | Clasificación y plan de implementación | Confirmado en la rama remota |
| `7f8b919` | `feat(empresa): add configurable company foundation` | Objeto, campos, soporte, tests, manifest y documentación del Bloque 1 | Confirmado en la rama remota |
| `cc1614c` | `feat(empresa): add company administration permissions` | `Empresa_Admin`, manifest y actualización del Bloque 1 | Confirmado en la rama remota |
| `9669237` | `feat(pricebook): add PEKING currency conversions` | Dos clases productivas, sus tests, manifest y documentación del Bloque 2 | Confirmado en la rama remota |

Al crear esta bitácora, `HEAD` y
`origin/feature/pc/redmotors-empresa-marcas-chinas-sprint1-20260724`
apuntaban a `9669237`. La bitácora nueva todavía no estaba registrada en Git.

## 10. Pruebas consolidadas

### 10.1 Bloque 1

Resultado final: **18/18 pruebas aprobadas, cero fallas**.

Casos principales:

- Bavarian, Otobai y empresa genérica nueva;
- resolución por Id y por `Codigo__c`;
- resolución bulk de 200 Ids y 200 códigos con una consulta;
- colecciones vacías sin consultas;
- Id/código nulo, vacío o inexistente;
- empresa inactiva;
- código ERP o nombre legal faltante;
- independencia de `Name`;
- invariantes y estado `CONFIGURED`;
- ausencia de fallback implícito a Bavarian.

### 10.2 Bloque 2

Resultado final: **22/22 pruebas aprobadas, cero fallas**.

Casos principales:

- Bavarian Local ↔ Bavarian Dólar;
- Otobai Local ↔ Otobai Dólares;
- PEKING Local ↔ PEKING Dólares;
- Pricebook nulo, desconocido, inexistente o ambiguo;
- ausencia de fallback a cualquiera de las tres empresas;
- conservación del comportamiento existente de WorkOrder, Quote y líneas;
- validación antes de eliminar o actualizar información;
- datos independientes y sin `SeeAllData`.

### 10.3 Errores encontrados y correcciones

| Error | Corrección |
|---|---|
| Cobertura de `EmpresaContext` en 52.381% | Pruebas directas de constructor, invariantes, getters y defensas |
| `fieldPermissions` sobre `Codigo__c` obligatorio | Omisión intencional del permiso de campo |
| Seis conversiones en una transacción agotaban SOQL | Una conversión por método de prueba y transacción |
| `Codigo_de_Producto__c` ausente o duplicado | Códigos explícitos y únicos por escenario |
| `PricebookEntry` duplicado | Una sola combinación Pricebook–Producto–Moneda |
| Picklist restringido con `Nuevo` inactivo | Uso de valores activos confirmados `Cita` y `Aprobación` |

## 11. Horas y avance

### 11.1 Presupuesto y estimaciones

| Concepto | Estimación declarada | Consumido estimado documentado | Restante verificable |
|---|---:|---:|---:|
| Modelo Empresa y soporte | 14 h | 9 h estimadas en el documento del Bloque 1 | 5 h de reserva técnica |
| Apex | 30 h | No existe un registro consolidado de horas reales o consumidas del Bloque 2 | No calculable con evidencia disponible |
| Total Sprint 1 | 44 h | No calculable como tiempo real facturable | No calculable con evidencia disponible |

Las 9 horas del Bloque 1 son una estimación técnica equivalente, no un
timesheet. Las cinco horas restantes fueron descritas como reserva para
validación, permisos, configuración y primeros consumidores; parte de esas
actividades ya ocurrió, pero no existe una actualización de horas aprobada que
permita reducir la reserva con precisión.

### 11.2 Alcance completado

- modelo base `Empresa__c`;
- contexto, resolver y excepción;
- pruebas bulk y fail-closed;
- Permission Set de administración;
- dos consumidores de Pricebook/moneda;
- soporte explícito PEKING en esos consumidores;
- dry-runs y deploys exitosos de los Bloques 1 y 2.

### 11.3 Alcance pendiente

El alcance técnico directo original contiene 41 clases y un trigger. Solo se
han modificado dos de esas clases directas. El objeto y soporte no convierten
automáticamente a los consumidores restantes; tampoco existen todavía
registros operativos de Empresa.

## 12. Pendientes

### 12.1 Configuración operativa

- cargar sus `PricebookEntry`;
- cargar los productos y precios autorizados;
- definir códigos estables y códigos ERP;
- crear de forma controlada los registros de Empresa;
- asignar `Empresa_Admin` a usuarios autorizados;
- confirmar si `ReadWrite` es el sharing definitivo;
- definir si se requiere una Custom Tab.

### 12.2 Consumidores y procesos

- `UpdateCurrencyScheduler`;
- `WorkOrderTrigger`;
- `BMW_LineaPlantillaEmpresa`;
- servicios y contratos Softland;
- reservas;
- inventario y bodegas;
- anticipos;
- PDFs, documentos y email;
- schedulers y batches diferidos;
- componentes de usados, taller y FSL pendientes de decisión.

### 12.3 Triggers de Account

- `ChanceAccountBavarian`;
- `ChanceAccountContado`;
- `ChanceAccountOtobai`.

Antes de refactorizarlos se debe confirmar si sus cuentas representan empresas
facturadoras, cuentas técnicas protegidas o ambas. No se recomienda crear un
trigger adicional para PEKING.

## 13. Riesgos y restricciones vigentes

| Riesgo o restricción | Tratamiento |
|---|---|
| `Pricebook2.Name` permanece como clave funcional | Decisión autorizada para este bloque; cualquier renombre requiere coordinación y regresión |
| Empresa desconocida cae en otra empresa | Prohibido; se exige error controlado |
| Códigos operativos o ERP no confirmados | No inventarlos ni crear registros semilla |
| PEKING tiene Apex y Pricebooks activos, pero no `PricebookEntry`, productos ni registro de Empresa | No considerar la empresa operativa de punta a punta |
| Componentes parciales pueden aplicar reglas distintas | No habilitar conversiones reales de PEKING hasta completar y probar los datos y dominios necesarios |
| IDs de Pricebook específicos del Sandbox | No hardcodearlos ni tratarlos como identificadores portables |
| Nuevos objetos, campos o relaciones | Requieren autorización funcional previa |
| Cambios en Softland | Requieren confirmar contrato, código y comportamiento |
| Decisiones funcionales ambiguas | Detener implementación y solicitar confirmación |
| Sharing y permisos | `ReadWrite` y asignaciones siguen pendientes |
| Documentos legales y anticipos | No incluirlos sin confirmar alcance y datos legales |

## 14. Datos no confirmados

1. Tipo, resultado, componentes y pruebas de
   `0AfAK000000vhpp0AA`.
2. Horas reales consumidas y facturables de ambos bloques.
3. Horas consumidas estimadas del Bloque 2.
4. Códigos definitivos `Codigo__c` y `Codigo_ERP__c`.
5. Nombres legales y registros operativos de Bavarian, Otobai y PEKING.
6. Productos y precios que deben cargarse en los Pricebooks PEKING.
7. Usuarios que recibirán `Empresa_Admin`.
8. Sharing definitivo de `Empresa__c`.
9. Alcance funcional final de Softland, reservas, inventario, anticipos,
    documentos, taller y usados.

## 15. Cierre de jornada — 25/07/2026

| Dato | Registro |
|---|---|
| Hora de cierre | 01:01 a. m. |
| Zona horaria | Monterrey, Nuevo León |
| Estado del Bloque 4 | Dry-run final exitoso; deploy real pendiente |
| Avance técnico estimado | 62% completado |
| Pendiente estimado | 38% |

El porcentaje es una estimación basada en el alcance técnico identificado y
completado. No representa horas oficiales registradas, consumidas o
facturables.

Resultado principal de la jornada:

- Bloque 4 reorientado a `WorkOrder.empresaFacturaCP__c`;
- lookup principal hacia `Empresa__c`;
- `empresaFactura__c` conservado como compatibilidad temporal;
- precedencia del lookup cuando ambos campos tienen valor;
- soporte explícito para `RMBAVARIAN`, `RMOTOBAI` y `RMPEKING`;
- conservación de las seis combinaciones empresa/moneda;
- ausencia de selección empresarial por descarte;
- conservación de `Pricebook2Id` ante código o moneda no reconocidos;
- cobertura comprobada de 163/173 líneas, equivalente a 94.220%.

Pendientes al cierre:

1. Respuesta de Luis sobre la discrepancia `Garantia` / `Garantía`.
2. Deploy real del Bloque 4.
3. Permisos para `WorkOrder.empresaFacturaCP__c`.
4. Creación y mapeo de registros operativos de `Empresa__c`.
5. Migración de WorkOrders existentes al nuevo lookup.
6. Decisión futura para retirar `empresaFactura__c`.
7. Implementación de los siguientes componentes Apex del inventario.

Hasta recibir respuesta sobre `Garantia` / `Garantía`, no debe modificarse el
trigger ni el picklist.

## 16. Cierre técnico del Bloque 4 — 25/07/2026

| Dato | Registro |
|---|---|
| Inicio de jornada | 9:00 a. m. |
| Hora de registro del deploy | 12:49 p. m. |
| Ambiente | RedMotorsSandbox / Partial |
| Deploy ID | `0AfAK000000vnon0AA` |
| Estado | Succeeded |
| Componentes | 4/4 |
| Pruebas | 50/50 |
| Fallas | 0 |
| Estado del Bloque 4 | Completado y desplegado |

Componentes desplegados:

- `WorkOrder.empresaFacturaCP__c`;
- `WorkOrder.empresaFactura__c`;
- `WorkOrderTrigger`;
- `WorkOrderTriggerTest`.

Comportamiento desplegado:

- `empresaFacturaCP__c` es la fuente principal de empresa;
- `empresaFactura__c` permanece como compatibilidad temporal;
- el lookup tiene prioridad cuando ambos campos están informados;
- se soportan explícitamente `RMBAVARIAN`, `RMOTOBAI` y `RMPEKING`;
- se mantienen las seis combinaciones empresa/moneda;
- no existe selección empresarial por descarte.

Avance técnico estimado del Sprint 1:

- completado: 65%;
- pendiente: 35%.

Este porcentaje es una estimación basada en alcance técnico. No representa
horas oficiales, trabajadas, registradas ni facturables.

La discrepancia entre `Garantia`, valor activo del picklist, y `Garantía`,
literal utilizado por el trigger, continúa pendiente. Luis indicó que debe
corregirse antes de cerrar el Sprint 1.

### Respaldo del cierre técnico

Verificación realizada el 25/07/2026 a la 01:00:25 p. m., hora local
UTC−06:00:

| Dato | Registro |
|---|---|
| Commit | `67410e3` |
| Mensaje | `feat(workorder): add configurable company lookup` |
| Push | Exitoso |
| Rama | `feature/pc/redmotors-empresa-marcas-chinas-sprint1-20260724` |
| Sincronización | Rama sincronizada con origin, diferencia 0/0 |
| Working tree al verificar el cierre | Limpio |

El Bloque 4 quedó desplegado, validado, documentado y respaldado en GitHub.
El avance técnico estimado del Sprint 1 se mantiene en 65% completado y 35%
pendiente. Esta estimación no representa horas oficiales, trabajadas,
registradas ni facturables.

La discrepancia `Garantia` / `Garantía` era el pendiente obligatorio antes
del cierre del Sprint 1 y fue resuelta posteriormente en el Bloque 5.

## 17. Cierre técnico del Bloque 5 — 25/07/2026

Registro realizado a la 1:19 p. m., zona horaria UTC−06:00, en
RedMotorsSandbox / Partial.

### Dry-run exitoso

| Dato | Registro |
|---|---|
| Deploy ID | `0AfAK000000vnqP0AQ` |
| Componentes | 2/2 |
| Pruebas | 51/51 |
| Fallas | 0 |

### Deploy real exitoso

| Dato | Registro |
|---|---|
| Deploy ID | `0AfAK000000vo4v0AA` |
| Estado | Succeeded |
| Componentes | 2/2 |
| Pruebas | 51/51 |
| Fallas | 0 |

Componentes desplegados:

- `WorkOrderTrigger`;
- `WorkOrderTriggerTest`.

Se corrigió exclusivamente la comparación productiva `Garantía` →
`Garantia`. El literal ahora coincide con el valor activo del picklist y la
rama asigna `tipoCargo__c = '4'`. La prueba dirigida de garantía fue
restaurada y aprobada.

No se modificaron campos, permisos, `Empresa__c`, Pricebooks ni
integraciones. El defecto obligatorio quedó resuelto y el Bloque 5 quedó
completado, validado y desplegado.

Avance técnico estimado del Sprint 1:

- completado: 66%;
- pendiente: 34%.

Este porcentaje corresponde al alcance técnico. No representa horas
oficiales, trabajadas, registradas ni facturables.

## 18. Bloque 6 — Empresa en Opportunity

| Dato | Registro |
|---|---|
| Fecha | 25/07/2026 |
| Bloque | 6 — Empresa en Opportunity |
| Checkpoint protegido | `b427ab6` |
| Backup | `backup/pc/redmotors-sprint1-before-opportunity-20260725` |
| Estado | Completado, validado y desplegado |

La decisión se basa en la sesión con Diego y fue informada a Luis. Se creó
localmente el lookup opcional `Opportunity.Empresa_Operadora__c` hacia
`Empresa__c`.

`ProductControllerTwo.getAvailabilityByQuote()` utiliza el lookup como fuente
principal. Cuando está vacío conserva temporalmente
`Opportunity.BMW_Compania__c`, con los mapeos explícitos Bavarian →
`RMBAVARIAN` y Otobai → `RMOTOBAI`. El lookup tiene prioridad ante una
contradicción y no existe selección por descarte.

No se modificaron flows, integraciones, reservas, Quote, Product2,
`Plantilla_de_Presupuesto__c` ni Permission Sets. Permanecen pendientes los
permisos, los registros operativos de Empresa y la migración de datos
históricos.

El avance técnico posterior queda pendiente de validación mediante dry-run.

### Primer dry-run del Bloque 6

| Dato | Registro |
|---|---|
| Deploy ID | `0AfAK000000vog10AA` |
| Componentes compilados | 3/3 |
| Pruebas aprobadas | 8/9 |
| Falla | `ProductControllerTwoTest.ProductControllerTwoTest` |
| Cobertura temporal | 2.874% |
| Estado de la org | Sin modificaciones |

La prueba histórica terminó anticipadamente al intentar insertar dos
productos con `Codigo_de_Producto__c = '0012'` dentro del mismo método. No
intervinieron `@testSetup`, factories ni productos automáticos.

Se corrigieron únicamente los datos de prueba:

- materiales: `PCT2-MAT-0012`;
- mano de obra: `PCT2-MO-0012`.

La cobertura registrada no es definitiva porque la prueba no alcanzó a
ejecutar los métodos históricos de `ProductControllerTwo`. El porcentaje
exacto queda pendiente del siguiente dry-run.

### Cierre técnico del Bloque 6

Registro realizado el 25/07/2026 a las 2:19 p. m., zona horaria UTC−06:00,
en RedMotorsSandbox / Partial.

| Validación | Deploy ID | Estado | Componentes | Pruebas | Fallas |
|---|---|---|---:|---:|---:|
| Dry-run final | `0AfAK000000vojF0AQ` | Succeeded | 3/3 | 9/9 | 0 |
| Deploy real | `0AfAK000000vokr0AA` | Succeeded | 3/3 | 9/9 | 0 |

Cobertura confirmada de `ProductControllerTwo`: 766/870 líneas, equivalente
a 88.046%.

Componentes desplegados:

- `Opportunity.Empresa_Operadora__c`;
- `ProductControllerTwo`;
- `ProductControllerTwoTest`.

`Empresa_Operadora__c` es un lookup opcional hacia `Empresa__c` y queda como
fuente principal. `BMW_Compania__c` permanece como compatibilidad temporal.
Cuando ambos campos tienen valor, el lookup tiene prioridad.

Se conserva Bavarian como `RMBAVARIAN` y Otobai como `RMOTOBAI`.
`RMPEKING` funciona mediante el lookup. Los valores nulos o desconocidos
conservan el comportamiento anterior.

No se modificaron flows, reservas, servicios Softland, Quote, Product2 ni
plantillas. Continúan pendientes los permisos, los registros operativos de
Empresa y la migración histórica.

El Bloque 6 queda completado, validado y desplegado. Se mantiene registrado
el checkpoint remoto `b427ab6`.

Avance técnico estimado del Sprint 1:

- completado: 69%;
- pendiente: 31%.

Este porcentaje corresponde al alcance técnico y no representa horas
oficiales, trabajadas, registradas ni facturables.

## 19. Bloque 7 — Crear Plan de Venta

Se retomó la propagación de `Opportunity.Empresa_Operadora__c` en
`CrearPlandeVenta`, respaldada antes de la pausa.

El dry-run anterior `0AfAK000000vomT0AQ` compiló 2/2 componentes y terminó
con 0/2 pruebas aprobadas. Ambas fallaron al insertar la nueva Opportunity
porque la cuenta fija `001PH00000X9ZEcYAN` produjo
`INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY`. La org no fue modificada.

Luis autorizó que `Opportunity.Cuenta_de_Facturaci_n__c` de la Opportunity
original tenga prioridad. Las cuentas fijas actuales por Record Type se
conservan como respaldo cuando ese campo está vacío.

La implementación local:

- consulta `Cuenta_de_Facturaci_n__c`;
- inicializa la cuenta de facturación con el valor original;
- ejecuta la asignación fija únicamente cuando el campo está vacío;
- propaga el mismo valor a la nueva Opportunity y al nuevo Quote;
- conserva la copia de `Empresa_Operadora__c` y los cálculos existentes de
  compañía, Pricebook, taller y centro de costo.

Las pruebas usan Accounts autocontenidas para validar la precedencia. La ruta
de respaldo conserva los IDs existentes y continúa expuesta al riesgo de
acceso propio de esas referencias fijas.

El Bloque 8 de permisos ya fue cerrado y respaldado en el cambio `a137b19`.

### Dry-run y estabilización de cobertura del Bloque 7

| Dato | Registro |
|---|---|
| Deploy ID | `0AfAK000000vp7R0AQ` |
| Componentes | 2/2 |
| Pruebas | 3/3 |
| Fallas | 0 |
| Cobertura | 75/127, equivalente a 59.055% |
| Estado de la org | Sin modificaciones |

El reporte identificó 52 líneas no cubiertas. Se agregaron cuatro pruebas
dirigidas para:

- retorno anticipado cuando ya existe un plan con el mismo VIN;
- copia de una regalía con PricebookEntry compatible;
- omisión de una regalía cuya entrada compatible está inactiva;
- rama Otobai mediante el Record Type Indian y cuenta de facturación
  autocontenida.

La cobertura esperada mínima es 107/127, equivalente a 84.252%. Puede
alcanzar aproximadamente 113/127, equivalente a 88.976%, si el escenario
Indian recorre todas las líneas previstas. El resultado definitivo permanece
pendiente del siguiente dry-run.

No se modificó código productivo, metadata ni automatizaciones.

### Corrección de compilación de las regalías

El dry-run `0AfAK000000vp930AA` no ejecutó pruebas porque
`CrearPlandeVentaTest` intentaba escribir
`QuoteLineItem.BMW_TipoDeArticulo__c`. Ese campo es una fórmula de texto
basada en `TEXT(Product2.tipoProducto__c)` y es de solo lectura.

Se eliminó la asignación directa y el tipo se configura ahora mediante el
picklist editable `Product2.tipoProducto__c`. La inclusión como regalía se
mantiene mediante `QuoteLineItem.esRegalia__c = true`.

La org no fue modificada. Permanecen los siete métodos de prueba y los
escenarios de VIN, entrada compatible, entrada inactiva, Record Type Indian y
las tres validaciones anteriores.

### Corrección de Record Types de prueba

El dry-run `0AfAK000000vpAf0AI` compiló 2/2 componentes, aprobó 1/7 pruebas y
registró cobertura temporal de 61.417%. Las seis fallas ocurrieron al insertar
la Opportunity fuente en `createSourceQuote`, línea 360, por
`INVALID_CROSS_REFERENCE_KEY` sobre `RecordTypeId`. La org no fue modificada.

El helper incluía explícitamente un `RecordTypeId` nulo en los seis escenarios
que no requerían un tipo específico. La única ruta con Record Type expreso
era Indian, resuelto como disponible.

Se corrigieron únicamente los datos de prueba:

- cuando no se requiere una rama específica, no se asigna `RecordTypeId`;
- Indian se resuelve dinámicamente por `DeveloperName = Indian`;
- el retorno por VIN resuelve Opportunity
  `DeveloperName = Planes_de_Venta` y Quote
  `DeveloperName = Taller`;
- cada resolución confirma existencia y disponibilidad mediante Schema
  Describe;
- se eliminaron los IDs fijos de Record Type de la prueba.

### Cierre técnico del Bloque 7

| Validación | Deploy ID | Componentes | Pruebas | Fallas |
|---|---|---:|---:|---:|
| Dry-run funcional | `0AfAK000000vpFV0AY` | 2/2 | 7/7 | 0 |
| Dry-run de regresión | `0AfAK000000vpH70AI` | 2/2 | 17/17 | 0 |
| Deploy real | `0AfAK000000vpIj0AI` | 2/2 | 17/17 | 0 |

El deploy real terminó correctamente en RedMotorsSandbox / Partial. La
cobertura final de `CrearPlandeVenta` fue 115/127 líneas, equivalente a
90.55%.

El comportamiento desplegado:

- copia `Opportunity.Empresa_Operadora__c` sin transformación;
- prioriza `Opportunity.Cuenta_de_Facturaci_n__c` de la Opportunity original;
- conserva las cuentas fijas únicamente como fallback cuando el campo
  original está vacío;
- utiliza la misma cuenta de facturación en la nueva Opportunity y el nuevo
  Quote.

No se modificaron Record Types, compañías, Pricebooks, talleres, centros de
costo, VIN, líneas ni automatizaciones.

`CrearPlandeVentaTest` quedó con siete métodos. Se validaron copia del lookup,
precedencia de cuenta, fallback heredado, retorno por VIN y manejo de
regalías.

El Bloque 7 queda completado, validado y desplegado.

Avance técnico estimado del Sprint 1:

- completado: 72%;
- pendiente: 28%.

Este porcentaje corresponde al alcance técnico y no representa horas
oficiales, trabajadas, registradas ni facturables.

## 20. Bloque 8 — permisos de Empresa Operadora en Opportunity

Se preparó localmente la réplica de acceso de
`Opportunity.BMW_Compania__c` hacia
`Opportunity.Empresa_Operadora__c`, conforme a la autorización de mantener
el modelo vigente basado en perfiles.

Resultados de la preparación:

- 146 perfiles recuperados y procesados;
- 144 accesos habilitados desde estado sin acceso;
- 2 perfiles elevados de solo lectura a lectura y edición:
  `Asesor de Taller V2` y `Jefe de Ventas Usados Motos A1`;
- 146 perfiles con lectura y edición como resultado final;
- `Vehiculos_Nuevos_PS` preparado con lectura y sin edición;
- 0 perfiles faltantes o bloqueados;
- 0 cambios colaterales dentro de los Profile XML.

`procesos_walking` y `sfdc_a360_sfcrm_data_extract` ya coincidían con el
acceso requerido y no fueron modificados. Tampoco se modificaron los permisos
existentes de `Opportunity.BMW_Compania__c`, layouts, páginas, objetos,
clases, flows, usuarios ni asignaciones.

La implementación local quedó validada. Dry-run y deploy permanecen
pendientes.

### Primer dry-run del Bloque 8

| Dato | Registro |
|---|---|
| Deploy ID | `0AfAK000000vouX0AQ` |
| Componentes válidos | 146/147 |
| Perfiles aceptados | 146/146 |
| Falla exclusiva | `Vehiculos_Nuevos_PS` |
| Estado de la org | Sin modificaciones |

El Permission Set falló por ubicación inválida de un bloque
`fieldPermissions`: el permiso de `Opportunity.Empresa_Operadora__c` estaba
después de `tabSettings`, fuera del grupo permitido por el esquema. El bloque
aparecía una sola vez y fue reubicado junto con los demás permisos de campo.

La entrada conserva `readable=true` y `editable=false`.
`Opportunity.BMW_Compania__c` y los demás permisos permanecieron intactos.

### Cierre técnico del Bloque 8

Registro realizado el 25/07/2026 a las 3:44 p. m., zona horaria UTC−06:00,
en RedMotorsSandbox / Partial.

| Validación | Deploy ID | Estado | Componentes | Fallas | Pruebas Apex |
|---|---|---|---:|---:|---|
| Dry-run final | `0AfAK000000vow90AA` | Succeeded | 147/147 | 0 | No aplican |
| Deploy real | `0AfAK000000voUk0AI` | Succeeded | 147/147 | 0 | No aplican |

El deploy actualizó 146 perfiles y `Vehiculos_Nuevos_PS`.

Los 146 perfiles replican en `Opportunity.Empresa_Operadora__c` los permisos
de lectura y edición existentes en `Opportunity.BMW_Compania__c`. De ellos,
144 recibieron acceso que no tenían previamente. `Asesor de Taller V2` y
`Jefe de Ventas Usados Motos A1` pasaron de solo lectura a lectura y edición.
`Vehiculos_Nuevos_PS` recibió lectura sin edición.

No se modificaron `procesos_walking` ni
`sfdc_a360_sfcrm_data_extract` porque ya coincidían. Tampoco se modificaron
layouts, FlexiPages, usuarios, asignaciones, Apex ni flows.

El Bloque 8 queda completado, validado y desplegado.

Avance técnico estimado del Sprint 1:

- completado: 71%;
- pendiente: 29%.

Este porcentaje se basa en el alcance técnico completado y no representa
horas oficiales, trabajadas, registradas ni facturables.

## 21. Bloque 9 — Empresa configurable en líneas de plantilla

Se preparó `Plantilla_de_Presupuesto__c.Empresa_Operadora__c` como lookup
opcional hacia `Empresa__c`.

`BMW_LineaPlantillaEmpresa.getEmpresa()` utiliza el lookup como fuente
principal y retorna el código validado por `EmpresaResolver`. Cuando el lookup
está vacío conserva temporalmente el respaldo explícito Bavarian →
`RMBAVARIAN` y Otobai → `RMOTOBAI`.

Se eliminó el fallback por descarte a Otobai. El método rechaza Id nulo,
plantilla inexistente, falta de configuración, valor heredado desconocido,
Empresa inactiva o configuración incompleta.

La prueba quedó con nueve métodos dirigidos para las tres empresas,
precedencia, compatibilidad heredada y errores controlados. Los casos
heredados nulo y desconocido no pueden persistirse porque
`BMW_Compania__c` es un picklist restringido y obligatorio; no se utilizaron
bypasses.

El inventario de solo lectura no encontró permisos explícitos del campo
heredado en perfiles ni Permission Sets. Para replicar exactamente ese estado
no se modificaron perfiles ni Permission Sets.

No se modificaron layouts, Lightning Pages, integraciones, otras clases ni
datos. Dry-run, regresión y deploy permanecen pendientes.

### Primer dry-run del Bloque 9

El dry-run `0AfAK000000vpLx0AI` compiló 3/3 componentes y aprobó 2/9
pruebas. Las siete fallas restantes ocurrieron en `createPlantilla` por el
campo obligatorio `BMW_TipoDeVehiculo__c`. La org no fue modificada.

El campo es un picklist restringido y obligatorio. Sus valores activos son
Automóvil, Motocicleta, Mula y Cuadraciclo. No se encontró otra prueba local
que creara una plantilla asignando este campo.

Se agregó `Automóvil`, valor activo confirmado por Schema Describe, a los
datos autocontenidos del helper. Se mantienen los nueve métodos y sus
aserciones.

### Cierre técnico del Bloque 9

| Validación | Deploy ID | Componentes | Pruebas | Fallas |
|---|---|---:|---:|---:|
| Dry-run funcional | `0AfAK000000vpPB0AY` | 3/3 | 9/9 | 0 |
| Dry-run de regresión | `0AfAK000000vpSP0AY` | 3/3 | 18/18 | 0 |
| Deploy real | `0AfAK000000vpU10AI` | 3/3 | 18/18 | 0 |

El deploy real terminó correctamente en RedMotorsSandbox / Partial. La
cobertura confirmada de `BMW_LineaPlantillaEmpresa` fue 16/21 líneas,
equivalente a 76.19%.

Se creó `Plantilla_de_Presupuesto__c.Empresa_Operadora__c`. El lookup tiene
prioridad sobre `BMW_Compania__c`; Bavarian y Otobai permanecen como respaldo
explícito, mientras que PEKING se resuelve mediante `EmpresaResolver` y
`Codigo__c`.

Se eliminó el fallback automático a Otobai y se validaron nueve escenarios
funcionales. No se modificaron layouts, migraciones ni permisos.

El Bloque 9 queda completado, validado y desplegado.

Avance técnico estimado del Sprint 1:

- completado: 74%;
- pendiente: 26%.

Este porcentaje corresponde al alcance técnico y no representa horas
oficiales, trabajadas, registradas ni facturables.

## 22. Bloque 11 — PEKING en PDF de cotización USD

El Bloque 10 de visibilidad de Pricebooks permanece pausado por indicación de
Diego hasta revisar el mapeo de sucursales. Luis autorizó continuar con
cambios claros de bajo riesgo y documentar cada acción.

Se agregó a `cT_QuoteUsdPDFController.getData(String recordId)` la asociación
explícita `PEKING Local` → `PEKING Dólares`, conservando Bavarian Local →
Bavarian Dólar y Otobai Local → Otobai Dólares. No se agregó fallback y un
nombre desconocido continúa sin seleccionar un Pricebook autorizado.

Se retiraron únicamente los dos guards `Test.isRunningTest()` que impedían
recorrer en pruebas la misma resolución de Pricebook que se utiliza en
producción. Como esos guards siempre evaluaban `false` en producción, no se
alteró su comportamiento.

La prueba directa quedó con cuatro escenarios autocontenidos: Bavarian,
Otobai, PEKING y Pricebook desconocido. Las conversiones validan el nombre
destino, el mismo producto, el precio USD, la cantidad y el total. No se
utilizan datos reales, IDs fijos ni `SeeAllData`.

No se modificaron cálculos, tasas, montos, productos, otras ramas del PDF,
metadata ni integraciones.

### Cierre técnico del Bloque 11

| Validación | Deploy ID | Componentes | Pruebas | Fallas |
|---|---|---:|---:|---:|
| Dry-run | `0AfAK000000vpdh0AA` | 2/2 | 4/4 | 0 |
| Deploy real | `0AfAK000000vpfJ0AQ` | 2/2 | 4/4 | 0 |

El dry-run confirmó 97/112 líneas cubiertas en
`cT_QuoteUsdPDFController`, equivalentes a 86.61%.

El deploy real terminó correctamente en RedMotorsSandbox / Partial. Se
validaron cuatro escenarios funcionales y quedaron desplegados
`cT_QuoteUsdPDFController` y `cT_QuoteUsdPDFController_test`.

El Bloque 11 queda completado, validado y desplegado. Se conserva el
comportamiento de Bavarian y Otobai, se agregó PEKING Local → PEKING Dólares,
no se agregó fallback y no se modificaron cálculos, tasas, montos, productos
ni el PDF.

Avance técnico estimado del Sprint 1:

- completado: 75%;
- pendiente: 25%.

Este porcentaje corresponde al alcance técnico y no representa horas
oficiales, trabajadas, registradas ni facturables.

## 23. Bloque 12 — PEKING en PDF de cotización CRC

Luis autorizó continuar con cambios claros de bajo riesgo y documentar lo
realizado. El Bloque 10 permanece pausado y este cambio no depende del mapeo
de sucursales.

Se agregó a `cT_QuoteCrcPDFController.getData(String recordId)` la asociación
explícita `PEKING Dólares` → `PEKING Local`. Se conservaron Bavarian Dólar →
Bavarian Local y Otobai Dólares → Otobai Local. No se agregó fallback.

Se retiraron únicamente los dos guards `Test.isRunningTest()` que impedían
recorrer en pruebas la resolución productiva de Pricebook. Como evaluaban
`false` en producción, no se modificó el comportamiento productivo.

La prueba directa quedó con cinco escenarios autocontenidos: Bavarian,
Otobai, PEKING, Pricebook desconocido y cotización CRC directa. Se validan la
relación Opportunity–WorkOrder, el Pricebook de origen, el Pricebook destino,
el mismo producto, el precio, la cantidad y el total.

No se modificaron cálculos, tasa fija, montos, productos, wrappers, estructura
del PDF, metadata ni integraciones.

### Cierre técnico del Bloque 12

| Validación | Deploy ID | Componentes | Pruebas | Fallas |
|---|---|---:|---:|---:|
| Dry-run | `0AfAK000000vpiX0AQ` | 2/2 | 5/5 | 0 |
| Deploy real | `0AfAK000000vpk90AA` | 2/2 | 5/5 | 0 |

El dry-run confirmó 113/115 líneas cubiertas en
`cT_QuoteCrcPDFController`, equivalentes a 98.26%.

El deploy real terminó correctamente en RedMotorsSandbox / Partial. Se
validaron cinco escenarios funcionales y quedaron desplegados
`cT_QuoteCrcPDFController` y `cT_QuoteCrcPDFController_test`.

El Bloque 12 queda completado, validado y desplegado. Se conservaron Bavarian
y Otobai, se agregó PEKING Dólares → PEKING Local, no se agregó fallback y no
se modificaron cálculos, tasa fija, montos, productos, wrappers ni el PDF.

Avance técnico estimado del Sprint 1:

- completado: 76%;
- pendiente: 24%.

Este porcentaje corresponde al alcance técnico y no representa horas
oficiales, trabajadas, registradas ni facturables.

## 24. Bloque 13 — Empresa configurable en trabajos de Quote

Luis autorizó continuar con cambios claros de bajo riesgo y documentar lo
realizado. El Bloque 10 permanece pausado y este cambio no depende del mapeo
de sucursales.

`TrabajoQuoteController.saveTrabajo()` utiliza ahora
`Opportunity.Empresa_Operadora__c` como fuente principal. El lookup se
resuelve mediante `EmpresaResolver` y admite los códigos `RMBAVARIAN`,
`RMOTOBAI` y `RMPEKING`.

Cuando el lookup está vacío se conserva únicamente el respaldo explícito
Bavarian/RMBavarian → RMBAVARIAN y Otobai → RMOTOBAI. El lookup tiene
prioridad ante contradicción y se eliminó el fallback que enviaba valores
nulos o desconocidos a Otobai.

La prueba histórica se conserva y se agregaron ocho escenarios
autocontenidos para las tres empresas, precedencia, compatibilidad heredada y
errores controlados. Las líneas creadas validan producto, PricebookEntry,
Pricebook, cantidad y precio.

No se modificaron otros métodos, tipos de vehículo, tipos de cargo,
PricebookEntry, cálculos, creación general de QuoteLineItem ni integraciones.
La única metadata del bloque es la extensión de la picklist de empresa con
`RMPEKING`.

### Primer dry-run del Bloque 13

El dry-run `0AfAK000000vpqb0AA` no ejecutó pruebas porque
`TrabajoQuoteControllerTest` no compiló al intentar asignar directamente
`tiposDeTrabajo__c.Cantidad__c` en la línea 252. La org no fue modificada.

`Cantidad__c` es una fórmula numérica de solo lectura derivada de `UTS__c`,
con 12 UTS por unidad de cantidad. Se eliminó únicamente la asignación a la
fórmula y se conservó `UTS__c = 12`.

Los escenarios nuevos utilizan `TrabajoWrapper.uts = 2`, que es el dato
editable empleado por `saveTrabajo()` para establecer la cantidad de la
QuoteLineItem. Los nueve métodos y sus aserciones funcionales permanecen
intactos. No se modificó producción ni metadata.

### Segundo dry-run del Bloque 13

El dry-run `0AfAK000000vpsD0AQ` compiló 2/2 componentes, aprobó 5/9 pruebas y
falló en cuatro escenarios. La org no fue modificada.

Dos pruebas PEKING fallaron porque
`TipoDeCargoConManoDeObra__c.Empresa__c` es una picklist local restringida
que solo contenía `RMBAVARIAN` y `RMOTOBAI`. No utiliza Global Value Set. Se
preparó la metadata del campo conservando ambos valores y agregando únicamente
`RMPEKING` activo y no predeterminado. El CustomField se agregó al manifest.

Las pruebas de Empresa inactiva y Empresa nula recibieron la
`AuraHandledException` producida por el manejo público de `saveTrabajo()`,
pero sus aserciones dependían del texto interno. Se corrigieron para validar
el tipo de excepción controlada y confirmar que no se crea ninguna
QuoteLineItem.

No se modificó producción. Permanecen los nueve métodos, la precedencia del
lookup, los respaldos Bavarian/Otobai, los datos autocontenidos y la ausencia
de fallback.

### Cierre técnico del Bloque 13

| Validación | Deploy ID | Componentes | Pruebas | Fallas |
|---|---|---:|---:|---:|
| Dry-run funcional | `0AfAK000000vptp0AA` | 3/3 | 9/9 | 0 |
| Dry-run de regresión | `0AfAK000000vpvR0AQ` | 3/3 | 18/18 | 0 |
| Deploy real | `0AfAK000000vpx30AA` | 3/3 | 18/18 | 0 |

El dry-run funcional confirmó 282/302 líneas cubiertas en
`TrabajoQuoteController`, equivalentes a 93.38%.

El deploy real terminó correctamente en RedMotorsSandbox / Partial. Se
validaron nueve escenarios funcionales y 18 pruebas de regresión.

`Opportunity.Empresa_Operadora__c` quedó como fuente principal y
`BMW_Compania__c` permanece como respaldo explícito para Bavarian y Otobai.
Se agregó soporte para `RMPEKING`, incluido el valor en
`TipoDeCargoConManoDeObra__c.Empresa__c`, y se eliminó el fallback automático
hacia `RMOTOBAI`.

No se modificaron cálculos, tipos de cargo, Pricebooks ni la creación general
de líneas. El Bloque 13 queda completado, validado y desplegado.

Avance técnico estimado del Sprint 1:

- completado: 78%;
- pendiente: 22%.

Este porcentaje corresponde al alcance técnico y no representa horas
oficiales, trabajadas, registradas ni facturables.

## 25. Bloque 14 — Empresa configurable en trabajos de WorkOrder

Estado: completado, validado y desplegado en RedMotorsSandbox / Partial.

Se actualizó únicamente `TrabajoController.saveSubtrabajos()` para utilizar
`WorkOrder.empresaFacturaCP__c` como fuente principal mediante
`EmpresaResolver` y `Empresa__c.Codigo__c`. El picklist
`empresaFactura__c` permanece como respaldo temporal cuando el lookup está
vacío.

Se admiten explícitamente `RMBAVARIAN`, `RMOTOBAI` y `RMPEKING`. El lookup
tiene prioridad ante contradicción y no existe selección por descarte. Una
empresa nula, inactiva, incompleta o con código no soportado genera un error
controlado antes de crear WorkOrderLineItems.

`TrabajoControllerTest` conserva las siete pruebas históricas y agrega diez
escenarios autocontenidos para las tres empresas, precedencia, respaldo
heredado y configuraciones inválidas. También valida producto, PricebookEntry,
cantidad, precio y ausencia de líneas ante error.

No se modificaron metadata, impuestos, tipos de cargo, PricebookEntry,
integraciones ni la estructura general de creación de líneas. Permanecen como
riesgos heredados la consulta de PricebookEntry dentro del ciclo y las
automatizaciones indirectas de WorkOrderLineItem.

Avance estimado después de validar y desplegar: 80% completado y 20%
pendiente. Corresponde al alcance técnico y no representa horas oficiales,
trabajadas ni facturables.

### Primer dry-run del Bloque 14

El dry-run `0AfAK000000vq0H0AQ` compiló 2/2 componentes, aprobó 8/17 pruebas
y falló en nueve rutas. La org no fue modificada.

Las siete rutas empresariales exitosas, `testSaveTrabajo` y
`testSaveSubtrabajos` recibieron un error técnico envuelto por los `catch` de
`TrabajoController` como `AuraHandledException` en las líneas 144 y 329.

Se agregó inicialmente el mock HTTP a cada método, pero el segundo dry-run
`0AfAK000000vq1t0AA` volvió a compilar 2/2 componentes y obtuvo exactamente
8/17 pruebas. Esto descartó el mock como causa raíz. La org no fue modificada.

El dry-run diagnóstico `0AfAK000000vq570AA` relanzó temporalmente las
excepciones originales y reveló una `System.QueryException: List has no rows
for assignment to SObject` en la consulta de PricebookEntry de la línea 298.
El controlador fue restaurado inmediatamente y conserva el contrato
`AuraHandledException`.

Las pruebas creaban la PricebookEntry en un Pricebook genérico, pero
`WorkOrderTrigger` reasignaba el WorkOrder a `Bavarian Local`, `Otobai Local`
o `PEKING Local`. Si el Pricebook autorizado no existía, el trigger asignaba
`null`. Por ello no coincidían Product2Id y Pricebook2Id en una misma entrada.

Se corrigieron únicamente los fixtures: ahora crean o reutilizan el
Pricebook local autorizado, fijan CRC en WorkOrder y PricebookEntry, y
comprueban el Pricebook efectivo después del trigger. El mock por método se
mantiene para automatizaciones indirectas.

Las tres pruebas negativas fallaron durante el diagnóstico porque recibieron
directamente `EmpresaConfigurationException` al retirarse temporalmente el
envoltorio. No fue una regresión y el manejo original quedó restaurado. La org
no fue modificada.

### Cierre técnico del Bloque 14

| Etapa | Deploy ID | Componentes | Pruebas | Fallas | Resultado |
|---|---|---:|---:|---:|---|
| Primer dry-run | `0AfAK000000vq0H0AQ` | 2/2 | 8/17 | 9 | Fallido |
| Segundo dry-run | `0AfAK000000vq1t0AA` | 2/2 | 8/17 | 9 | Fallido |
| Dry-run diagnóstico | `0AfAK000000vq570AA` | 2/2 | Diagnóstico | No aplica | Causa identificada |
| Dry-run funcional | `0AfAK000000vqBZ0AY` | 2/2 | 17/17 | 0 | Exitoso |
| Dry-run de regresión | `0AfAK000000vqEn0AI` | 2/2 | 26/26 | 0 | Exitoso |
| Deploy real | `0AfAK000000vqGP0AY` | 2/2 | 26/26 | 0 | Exitoso |

El dry-run funcional confirmó una cobertura de 232/266 líneas en
`TrabajoController`, equivalente a 87.22%.

El deploy real terminó correctamente en RedMotorsSandbox / Partial.
`WorkOrder.empresaFacturaCP__c` quedó como fuente principal y
`empresaFactura__c` como respaldo temporal. Se admiten explícitamente
`RMBAVARIAN`, `RMOTOBAI` y `RMPEKING`, sin selección empresarial por
descarte.

Se conservaron los impuestos, PricebookEntry, tipo de vehículo, tipo de
cargo y la creación general de WorkOrderLineItems. Se validaron 17 pruebas
funcionales y 26 pruebas de regresión sin fallas.

El controlador fue restaurado después del diagnóstico temporal y conserva el
manejo público mediante `AuraHandledException`. El Bloque 14 queda
completado, validado y desplegado.

Avance técnico estimado del Sprint 1:

- completado: 80%;
- pendiente: 20%.

Este porcentaje corresponde al alcance técnico y no representa horas
oficiales, trabajadas, registradas ni facturables.

## 26. Bloque 15 — Empresa configurable en trabajos de VIN Scan

Estado: completado, validado y desplegado en RedMotorsSandbox / Partial.

Se actualizaron los recorridos de creación de trabajos y subtrabajos de
`BMWVinScanTrabajoGenerator` para utilizar
`WorkOrder.empresaFacturaCP__c` como fuente principal. El lookup se resuelve
mediante `EmpresaResolver` y se utiliza `EmpresaContext.codigo`.

Cuando el lookup está vacío, `empresaFactura__c` permanece como respaldo
temporal. El lookup tiene prioridad ante contradicción y solo se admiten
`RMBAVARIAN`, `RMOTOBAI` y `RMPEKING`. No se utiliza el nombre de Empresa ni
existe selección empresarial por descarte.

La resolución se ejecuta antes de crear tipos de trabajo, trabajos,
subtrabajos o WorkOrderLineItems. Una empresa nula, inactiva, incompleta o
con código no soportado produce un error controlado.

La prueba directa conserva los escenarios históricos y agrega cobertura
autocontenida para las tres empresas, precedencia, los tres respaldos
heredados, empresa inactiva, código no soportado y campos empresariales
vacíos en ambos recorridos. También verifica producto, PricebookEntry,
cantidad, UTS, relación padre/hijo y ausencia de registros parciales.

El primer dry-run `0AfAK000000vqTJ0AY` compiló 2/2 componentes, aprobó 30/42
pruebas y falló únicamente en las doce rutas empresariales exitosas. La org
no fue modificada.

La causa fue una diferencia entre la PricebookEntry creada por los fixtures
y el Pricebook efectivo del WorkOrder. Las pruebas preparaban entradas en
los Pricebooks locales, pero no fijaban CRC. Con USD, `WorkOrderTrigger`
seleccionaba el Pricebook en dólares y el generador no encontraba la
combinación Pricebook2Id + Product2Id esperada.

Se corrigieron solo los fixtures: ahora fijan CRC, vuelven a consultar el
WorkOrder después del trigger, comprueban el Pricebook local efectivo y crean
la entrada de la misma mano de obra dentro de ese Pricebook. También validan
moneda, estado activo y precio. Se mantienen los 42 métodos, mocks y pruebas
históricas.

Las excepciones de las líneas 368 y 796 son lanzamientos directos ante una
entrada inexistente, no errores envueltos por un `catch`. El controlador no
fue alterado durante el análisis ni durante la corrección de fixtures.

No se modificaron metadata, procesamiento del VIN Scan, deduplicación,
productos, PricebookEntry, jerarquías padre/hijo, correos ni automatizaciones.

### Cierre técnico del Bloque 15

| Etapa | Deploy ID | Componentes | Pruebas | Fallas | Resultado |
|---|---|---:|---:|---:|---|
| Primer dry-run | `0AfAK000000vqTJ0AY` | 2/2 | 30/42 | 12 | Fallido |
| Dry-run funcional | `0AfAK000000vqY90AI` | 2/2 | 42/42 | 0 | Exitoso |
| Dry-run de regresión | `0AfAK000000vqZl0AI` | 2/2 | 93/93 | 0 | Exitoso |
| Deploy real | `0AfAK000000vqeb0AA` | 2/2 | 93/93 | 0 | Exitoso |

El dry-run funcional confirmó una cobertura de 569/656 líneas en
`BMWVinScanTrabajoGenerator`, equivalente a 86.74%.

El deploy real terminó correctamente en RedMotorsSandbox / Partial.
`empresaFacturaCP__c` quedó como fuente principal en trabajos y subtrabajos,
y `empresaFactura__c` como respaldo temporal. Se admiten explícitamente
`RMBAVARIAN`, `RMOTOBAI` y `RMPEKING`, sin selección empresarial por
descarte.

Se conservaron VIN Scan, deduplicación, UTS, productos, PricebookEntry,
jerarquías y correos. Se validaron 42 pruebas funcionales y 93 pruebas de
regresión sin fallas. El Bloque 15 queda completado, validado y desplegado.

Avance técnico estimado: 82% completado y 18% pendiente. Corresponde al
alcance técnico y no representa horas oficiales, trabajadas ni facturables.

## 27. Bloque 16 — Empresa configurable en QuoterController

Estado: completado, validado y desplegado en RedMotorsSandbox / Partial.

`QuoterController.createQuote()` y `addLineItem()` dejaron de seleccionar
globalmente `Bavarian Dólar`. Ahora resuelven
`Opportunity.Empresa_Operadora__c` mediante `EmpresaResolver` y
`EmpresaContext.codigo`; `BMW_Compania__c` permanece como respaldo temporal
para Bavarian y Otobai.

Los mapeos USD son explícitos: `RMBAVARIAN` usa `Bavarian Dólar`,
`RMOTOBAI` usa `Otobai Dólares` y `RMPEKING` usa `PEKING Dólares`. El lookup
tiene prioridad, no se usa el nombre de Empresa y no existe selección por
descarte.

En `createQuote()` se validan producto, Opportunity, empresa, Pricebook activo
único y PricebookEntry única antes de eliminar líneas o actualizar la
Opportunity. En `addLineItem()` se confirma que el Pricebook de la Quote
coincide con el de su empresa y la entrada se busca únicamente dentro de ese
Pricebook.

Se retiraron los siete bloques activos de `Test.isRunningTest` que impedían
ejecutar errores y DML reales en pruebas. El guard comentado para alias
permanece sin cambios. No se agregó lógica especial de pruebas.

`QuoterControllerTest` fue reconstruida con once métodos funcionales para las
tres empresas, precedencia, respaldos, configuraciones inválidas, Pricebook y
PricebookEntry inexistentes, ausencia de DML parcial y selección correcta en
`addLineItem`. La prueba ya no utiliza `dummy()` como sustituto de cobertura.

El primer dry-run `0AfAK000000vqjR0AQ` aprobó 11/11 pruebas y reportó
108/515 líneas cubiertas, equivalentes a 20.971%. La org no fue modificada.
El análisis confirmó que 379 de las 515 líneas ejecutables correspondían a
`dummy()`, un método de concatenaciones vacías agregado históricamente para
cobertura.

Luis autorizó eliminar completamente `dummy()` y el comentario asociado. No
se modificó ninguna otra lógica productiva. Se agregaron dos regresiones:
cambio de Pricebook con una línea existente, y creación de una regalía/extra
con el costo fijo de la PricebookEntry empresarial. La prueba queda con 13
métodos funcionales y una cobertura esperada superior al 75%. El Bloque 16
quedó preparado para su validación final.

No se modificaron regalos, extras, mano de obra, comisiones, cantidades,
precios, cálculos, metadata ni automatizaciones.

### Cierre técnico del Bloque 16

| Etapa | Deploy ID | Componentes | Pruebas | Fallas | Resultado |
|---|---|---:|---:|---:|---|
| Primer dry-run | `0AfAK000000vqjR0AQ` | 2/2 | 11/11 | 0 | Exitoso; cobertura afectada por `dummy()` |
| Dry-run funcional final | `0AfAK000000vqpt0AA` | 2/2 | 13/13 | 0 | Exitoso |
| Dry-run de regresión | `0AfAK000000vqrV0AQ` | 2/2 | 22/22 | 0 | Exitoso |
| Deploy real | `0AfAK000000vqt70AA` | 2/2 | 22/22 | 0 | Exitoso |

El dry-run funcional final confirmó 118/136 líneas cubiertas en
`QuoterController`, equivalentes a 86.77%. El deploy real terminó
correctamente en RedMotorsSandbox / Partial.

`Opportunity.Empresa_Operadora__c` quedó como fuente principal y
`BMW_Compania__c` como respaldo temporal para Bavarian y Otobai. El lookup
tiene prioridad ante contradicción. Los mapeos explícitos son `RMBAVARIAN` →
`Bavarian Dólar`, `RMOTOBAI` → `Otobai Dólares` y `RMPEKING` →
`PEKING Dólares`. No existe selección por descarte.

`createQuote()` valida empresa, Pricebook y PricebookEntry antes de eliminar
OpportunityLineItems o actualizar Opportunity. `addLineItem()` comprueba que
el Pricebook efectivo de la Quote corresponda a la empresa configurada.

Se eliminaron siete guards activos de `Test.isRunningTest` que alteraban la
ruta ejecutada durante pruebas. `dummy()` y su comentario asociado fueron
eliminados con autorización de Luis, sin modificar la lógica productiva
restante por ese ajuste.

Se validaron 13 pruebas funcionales y 22 pruebas de regresión. El Bloque 16
queda completado, validado y desplegado.

Avance técnico estimado: 83% completado y 17% pendiente. Corresponde al
alcance técnico y no representa horas oficiales, trabajadas ni facturables.

## 28. Bloque 17 — Metadata base de PEKING, Omoda y Jaecoo

Luis autorizó agregar `RMPEKING` a `Product2.Empresa__c` y crear los Record
Types de Opportunity `Omoda` y `Jaecoo`. La implementación local preparó la
metadata base sin modificar Apex, Flows, perfiles, layouts ni Lightning Record
Pages.

`Product2.Empresa__c` queda con `RMPEKING` como valor activo y no
predeterminado, conservando `RMBAVARIAN`, `RMOTOBAI`, `restricted=true`,
`sorted=false` y sin valor predeterminado.

`Opportunity.Omoda` y `Opportunity.Jaecoo` fueron creados usando
`Opportunity.BMW` como plantilla técnica, porque BMW y MINI corresponden a
automóviles en la metadata recuperada. Ambos Record Types quedan activos, con
Sales Process `Autos`, compact layout `Vehiculos_Nuevos` y los mismos
`picklistValues` de BMW.

`Vehiculos_Nuevos_PS` conserva la visibilidad existente para `Opportunity.BMW`
y agrega visibilidad para `Opportunity.Jaecoo` y `Opportunity.Omoda`. No se
modificaron otros permisos.

El primer dry-run `0AfAK000000vrE50AI` validó 3/4 componentes y falló porque
`Vehiculos_Nuevos_PS` contenía `viewAllFields`, elemento no compatible con
Metadata API 61.0. El segundo dry-run `0AfAK000000vrHJ0AY` volvió a validar
3/4 componentes y falló porque el parámetro `--api-version 67.0` no sustituyó
la versión 61.0 declarada dentro del manifest.

El ajuste aplicado fue actualizar
`manifest/empresa-marcas-chinas-bloque17-product2-recordtypes.xml` de 61.0 a
67.0. No se modificó ni eliminó `viewAllFields` del Permission Set.

El dry-run final `0AfAK000000vquk0AA` terminó sin fallas, con 4/4
componentes y `NoTestRun`. El deploy real `0AfAK000000vrNl0AI` terminó sin
fallas en RedMotorsSandbox / Partial, con 4/4 componentes.

La validación post-deploy confirmó que `Opportunity.Jaecoo` y
`Opportunity.Omoda` existen y están activos; ambos usan Sales Process `Autos`
y compact layout `Vehiculos_Nuevos`. `Product2.Empresa__c` quedó como
picklist restringido con los valores activos `RMBAVARIAN`, `RMOTOBAI` y
`RMPEKING`, todos con `default=false`.

No se modificaron Apex, Flows, perfiles, layouts ni FlexiPages. El manifest
quedó en Metadata API 67.0. `ProductSearcherController` queda separado para
un Bloque 18 posterior.

El Bloque 17 queda completado, validado y desplegado.

Avance técnico estimado: 84% completado y 16% pendiente. Corresponde al
alcance técnico y no representa horas oficiales, trabajadas ni facturables.

## 29. Bloque 19 — Empresa Operadora en creación de Opportunity desde modelo de interés

Luis autorizó implementar el Bloque 19 en un worktree aislado y asignar `Opportunity.Empresa_Operadora__c` desde `RM_VN_CrearOppModeloInteres_Ctrl.createOpportunity(...)`.

La implementación agrega un mapeo explícito de marca a empresa:

- BMW / MINI → `RMBAVARIAN`;
- Polaris / Kawasaki → `RMOTOBAI`;
- Omoda / Jaecoo → `RMPEKING`.

La marca desconocida produce error controlado antes de cualquier DML. La empresa se resuelve mediante `EmpresaResolver.resolveByCodigo(...)` y se asigna a `Opportunity.Empresa_Operadora__c`.

Se conservó la resolución actual de Record Type con `DeveloperName = :brand.toUpperCase()`, validada contra los Record Types activos `BMW`, `MINI`, `Polaris`, `Kawasaki`, `Omoda` y `Jaecoo`.

No se modificaron `Pricebook2Id`, `OpportunityLineItem`, `Oportunidad_Producto_Interes__c`, tráfico, Account, forma de pago, datos financieros, Softland, reservas, inventario, permisos, Flows, `ProductSearcherController` ni componentes del Bloque 18.

### Validación de fixtures y cobertura

Se confirmó que el fixture de `Product2` debe respetar dependencias de picklist:

- `Marca__c = BMW`;
- `Categor_a_veh_culo__c = SUV`;
- `Grupo__c = X`;
- `Familia__c = X1`;
- Record Type `Producto_Red_Motors`, resuelto dinámicamente.

`Product2.Marca__c = BMW` se usa solo para habilitar la cadena de picklists del fixture. La marca funcional probada sigue llegando por el parámetro `brand`.

Se eliminó el método histórico `dummy()` porque no tenía llamadores y distorsionaba la cobertura. También se retiraron helpers privados locales sin llamadores en esta clase; se conservó `findValidTraffic(...)` porque sí es utilizado por `createOpportunity(...)`.

### Dry-run enfocado aprobado

Dry-run `0AfAK000000vtML0AY`:

- Componentes: 2/2.
- Pruebas: 11/11.
- Fallas: 0.
- Cobertura `RM_VN_CrearOppModeloInteres_Ctrl`: 136/151 = 90.066%.
- Estado: Succeeded.
- La org no fue modificada.

### Regresión externa corregida

Regresiones inicialmente bloqueadas:

- `0AfAK000000vtPZ0AY`: 47/48 pruebas, una falla.
- `0AfAK000000vtRB0AY`: 47/48 pruebas, misma falla.

Falla única:

- Clase: `RM_VN_CrearOportunidad_Ctrl_Test`.
- Método: `test_createOpportunity_conTrafico`.
- Error: `System.AssertException: Assertion Failed: No debió lanzar excepción: Script-thrown exception`.

La falla correspondía a una prueba externa al Bloque 19. El diagnóstico
confirmó que la conversión de tráfico ejecutaba la validación activa
`Bloquear_conversion_estandar`, que exige `Lead.Convertido_custom__c = true`
para representar el flujo del botón personalizado de conversión.

Se corrigió únicamente el fixture de
`RM_VN_CrearOportunidad_Ctrl_Test.test_createOpportunity_conTrafico`,
agregando `Convertido_custom__c = true` al Lead de prueba antes del insert.
No se modificaron `RM_VN_CrearOportunidad_Ctrl`,
`RM_VU_CrearOportunidad_Ctrl`, `RM_VN_CrearOppModeloInteres_Ctrl`, la regla
de validación, Flows, permisos ni datos operativos.

La clase de prueba externa fue desplegada de forma aislada en Partial:

- Deploy test-only: `0AfAK000000vt1O0AQ`.
- Ejecución del método corregido: Test Run `707AK00000GxB33`, 1/1 aprobado.
- Ejecución de la clase completa: Test Run `707AK00000Gx9BH`, 29/29 aprobadas.

### Cierre técnico del Bloque 19

| Etapa | ID | Componentes | Pruebas | Fallas | Resultado |
|---|---|---:|---:|---:|---|
| Dry-run enfocado | `0AfAK000000vtML0AY` | 2/2 | 11/11 | 0 | Exitoso |
| Dry-run de regresión | `0AfAK000000vtkX0AQ` | 2/2 | 48/48 | 0 | Exitoso |
| Deploy real | `0AfAK000000vtnl0AA` | 2/2 | 48/48 | 0 | Exitoso |
| Verificación post-deploy | Test Run `707AK00000GwjmT` | No aplica | 48/48 | 0 | Exitoso |

El deploy real fue ejecutado únicamente contra RedMotorsSandbox / Partial.
Quedaron desplegados:

- `RM_VN_CrearOppModeloInteres_Ctrl`;
- `RM_VN_CrearOppModeloInteres_Ctrl_Test`.

La cobertura comprobada para `RM_VN_CrearOppModeloInteres_Ctrl` fue 136/151
líneas, equivalente a 90.07%.

Estado: Bloque 19 completado, validado y desplegado en RedMotorsSandbox /
Partial. La rama del Bloque 19 permanece separada de la rama principal del
sprint hasta que se autorice su integración.

Avance técnico estimado después del deploy del Bloque 19: 86% completado y
14% pendiente. Corresponde al alcance técnico y no representa horas oficiales,
trabajadas ni facturables.

## 30. Bloque 18 — Empresa configurable en búsqueda de mano de obra (pausado por cobertura)

Luis autorizó implementar el mapeo Omoda/Jaecoo → `RMPEKING` en
`ProductSearcherController.getProducts()`, exclusivamente en la rama
`productType.contains('mano obra')`, con código exacto de `Empresa__c` en vez
de `LIKE` parcial, y sin devolver productos de todas las empresas cuando el
Record Type de la Opportunity/Quote no está mapeado.

El cambio productivo quedó aplicado en
`force-app/main/default/classes/ProductSearcherController.cls`: el bloque de
mapeo ahora usa `companyCode` (`RMBAVARIAN`, `RMOTOBAI`, `RMPEKING`) con
comparación exacta (`Empresa__c = :companyCode`) y un `return responseMap;`
temprano cuando el Record Type no se reconoce, sin construir nunca un filtro
`LIKE '%%'`. El método `dummy()` (350 líneas de asignaciones artificiales sin
llamadores productivos, confirmado por `git grep`) fue eliminado, porque
`ProductSearcherControllerTest` ya no lo invoca para inflar cobertura.

Durante la implementación se encontró y resolvió, con autorización explícita
para ampliar el alcance de este bloque, que el Record Type `Producto_Red_Motros`
de `Product2` no tenía `RMPEKING` habilitado en su restricción de picklist
para `Empresa__c` (aunque el campo sí lo soportaba a nivel global desde el
Bloque 17). Se agregó la sección `<picklistValues><picklist>Empresa__c</picklist>...`
con `RMBAVARIAN`, `RMOTOBAI` y `RMPEKING` en
`force-app/main/default/objects/Product2/recordTypes/Producto_Red_Motors.recordType-meta.xml`
(archivo recuperado desde RedMotorsSandbox porque no estaba versionado
localmente; se eliminó el `Product2.object-meta.xml` recuperado como
referencia, sin cambio funcional, igual que en el Bloque 17).

`ProductSearcherControllerTest` fue reconstruido con 13 métodos: los 12
escenarios solicitados (BMW/MINI/Polaris/Kawasaki/Omoda/Jaecoo devuelven solo
su empresa; Record Type no reconocido no devuelve nada; producto inactivo y
de otra empresa quedan excluidos; ruta por Opportunity y por Quote;
PricebookEntry del Pricebook efectivo de la Quote) más pruebas de validación
temprana (marca/año/modelo/recordId en blanco). Los 13 métodos pasan sin
fallas en todos los dry-runs.

Durante la corrección de fixtures se encontraron y resolvieron, todos dentro
de `ProductSearcherControllerTest.cls`: colisión de cédula duplicada al
reutilizar `TestDataFactory.createAccount`, rechazo de picklist restringido
en `Categor_a_veh_culo__c` al construir productos a mano (resuelto
reutilizando `TestDataFactory.createProduct`), un `PricebookEntry` estándar
autogenerado por el org al insertar `Product2` activos (resuelto con
upsert manual), y el hallazgo de que `Opportunity.Name`/`Quote.Name` no son
confiables como clave de búsqueda en este org (una automatización los
recalcula); se sustituyó por identificación vía `Campana__c` + `RT_Lead__c` y
`OpportunityId`/`Product2.Name`.

**Cobertura de `ProductSearcherController`: 73.438% (141/192 líneas), por
debajo del mínimo de 75% exigido por el org incluso para deploys a sandbox
con `RunSpecifiedTests`.** Las 51 líneas restantes pertenecen casi en su
totalidad a la rama `vehiculo` (precios de fantasía vía
`getPricesGroupByModelFantasia`/`RM_VN_Service.gePBEBavarian`, segundo bloque
de filtros de vehículo, y la ruta de paginación compartida que depende de
ellos), fuera del alcance autorizado de este bloque.

Con autorización explícita para tocar fixtures de la rama vehículo (solo en
el archivo de test, sin modificar código productivo), se intentó cerrar la
brecha y se encontraron tres obstáculos técnicos distintos e independientes,
todos preexistentes en el org y ajenos a este cambio:

1. `Categor_a_veh_culo__c` — picklist restringido por Record Type (ya
   resuelto para el flujo de mano de obra).
2. `Modelo_De_Inter_s__c` — el mismo tipo de restricción en un campo
   distinto, requerido por `getPricesGroupByModelFantasia`. Ningún valor
   probado fue aceptado para `Producto_Red_Motros`.
3. `Schema.RecordTypeInfo.getPicklistValuesForField(SObjectField)` no existe
   en la `apiVersion` 55.0 declarada en `ProductSearcherController.cls`/
   `ProductSearcherControllerTest.cls-meta.xml` (error de compilación real
   del deploy, no una suposición).
4. Un sondeo autocontenido (insertar cada valor candidato del picklist
   global con `Database.insert(..., false)` hasta encontrar uno aceptado)
   agotó el límite de 150 DML statements por transacción
   (`Too many DML statements: 151`) sin encontrar ninguno válido.

Se verificó directamente, primero en el archivo local y luego recuperando
temporalmente `RecordType:Product2.Producto_Red_Motors` desde
RedMotorsSandbox (con respaldo y restauración de la versión autorizada, sin
dejar metadata temporal), que **no existe ninguna sección
`<picklist>Modelo_De_Inter_s__c</picklist>` en el Record Type
`Producto_Red_Motros`, ni localmente ni en el org real**. Esto confirma que
el campo no tiene ningún valor habilitado para ese Record Type — no es un
valor que no se encontró, es una configuración de catálogo pendiente en
Setup, fuera del alcance de Apex/Metadata API declarativa vía CLI.

Se revirtió por completo el fixture de vehículo (Pricebook de fantasía,
`Configuracion_de_ventas__c`, productos de precio/inventario,
`ProductoXBodega__c` y el helper de resolución de picklist), dejando
`ProductSearcherControllerTest.cls` en el último estado limpio y verificado:
13/13 pruebas pasan, 73.438% de cobertura.

**El Bloque 18 queda pausado aquí, sin deploy, sin commit y sin push**, a la
espera de que alguien con acceso a Setup habilite al menos un valor de
`Modelo_De_Inter_s__c` para el Record Type `Producto_Red_Motros` (o de una
decisión alternativa sobre cómo cerrar la cobertura de la rama vehículo).

No se modificaron las ramas de vehículo/extra/RM_VN_Service ni sucursales,
Softland, reservas o anticipos.

Avance técnico estimado si se completa: 85% completado y 15% pendiente
(sobre la base de 84%/16% del Bloque 17). No aplica todavía porque el bloque
no se ha desplegado.

### 30.1 Continuación — rama WIP, prueba huérfana y validación con RunLocalTests

Se creó la rama `wip/pc/redmotors-block18-product-searcher-coverage-20260726`
desde el estado pausado del Bloque 18, con el commit `f1ce045
wip(product-search): preserve blocked block 18` (staging exclusivo de los 6
archivos del bloque, `git diff --cached --check` limpio, push a origin).

**Análisis dirigido de cobertura (sin tocar Setup ni la rama vehículo):** se
enumeraron y clasificaron las 51 líneas sin cubrir de
`ProductSearcherController` por método/rama. Se probaron dos hipótesis en un
único dry-run combinado: (1) reutilizar los productos "Rack" ya creados por
`TestDataFactory.createQuoteWithItems()` para cubrir la rama `extra`/`ProductoXBodega__c`,
y (2) provocar una excepción controlada en `getProductDataFromOLI()`/
`getProductByQuoteId()` pasando un `Id` de otro objeto. Ambas fallaron: la
hipótesis (1) reveló que esos productos quedan con RecordType
`Producto_Red_Motros`, no `Materiales` (el que exige la consulta de la rama
`extra`) — un mismatch estructural de los datos existentes, no corregible
ajustando parámetros de búsqueda; la hipótesis (2) confirmó que un `Id` de
tipo incorrecto no dispara excepción en SOQL en este org, solo retorna cero
filas. Ambos experimentos se revirtieron (`git checkout`), dejando el árbol
exactamente igual al commit WIP.

**Validación con `RunLocalTests` (primer intento, `0AfAK000000vsRt0AI`):**
reveló un hallazgo no relacionado con cobertura: `ProductSearcherControllerOtobaiTest`,
una clase de prueba huérfana existente solo en RedMotorsSandbox (no
versionada en este repositorio, creada el 2026-06-17 y nunca modificada
desde entonces), llama a `ProductSearcherController.getProducts()` con 16
argumentos posicionales, mientras el método vigente (cuya firma no fue
tocada en el Bloque 18) tiene 14 parámetros. Ese único error de compilación
provocó que otras 24 clases no relacionadas (por unidad de dependencia de
Apex) se marcaran como "Dependent class is invalid and needs recompilation",
bloqueando cualquier corrida de `RunLocalTests` — 25 pruebas, 25 fallas, 0
completadas, cobertura no calculable (`codeCoverage: []`), aunque los 3
componentes del Bloque 18 validaron sin error de forma independiente
(`numberComponentErrors: 0`).

Con autorización explícita y de alcance estrictamente limitado, se recuperó
`ApexClass:ProductSearcherControllerOtobaiTest` (sin sobrescribir nada
existente) y se corrigió únicamente su fixture:

- Se realineó la llamada a `getProducts()` de 16 a 14 argumentos, eliminando
  dos parámetros `null` obsoletos que ya no existen en la firma vigente y
  conservando el resto en las mismas posiciones relativas (verificado por
  coincidencia exacta de valores: `'MT-06'` coincide con
  `Codigo_de_Producto__c` del producto de prueba, `'subcontratados'`
  coincide con su `Name`).
- Se asignó a la `Opportunity` del fixture el `RecordTypeId` de
  `Opportunity.Kawasaki`, obtenido dinámicamente vía
  `Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Kawasaki').getRecordTypeId()`
  — sin IDs reales, porque la resolución de empresa en el código vigente
  depende exclusivamente del `RecordType.DeveloperName` real de la
  Opportunity/Quote, y el fixture original no lo asignaba.
- Tras el primer re-intento (14 argumentos + RecordTypeId), quedó un único
  fallo: `"El modelo es requerido."` — el parámetro `model` (posición 11)
  quedó en `null` al preservar fielmente el valor original, y esa
  validación de entrada (preexistente, no introducida por el Bloque 18) lo
  exige para cualquier `productType` que no contenga `'vehiculo'`. Con
  autorización explícita, se reutilizó `'MT-06'` (ya usado legítimamente
  como `vin` en la misma prueba) también como `model`, documentando en el
  propio archivo que ese parámetro no participa en ningún punto de la rama
  `mano obra` — solo satisface esa validación de entrada preexistente, sin
  afectar la lógica ni el resultado de la búsqueda.
- No se modificó `ProductSearcherController.cls` en ningún momento de esta
  corrección; no se creó metadata adicional; no se usaron IDs reales ni
  `SeeAllData`.

`ProductSearcherControllerOtobaiTest` se agregó al manifest del Bloque 18.
El dry-run enfocado final (`ProductSearcherControllerTest` +
`ProductSearcherControllerOtobaiTest`) terminó con **14/14 pruebas
aprobadas, 0 fallas**, pero la cobertura de `ProductSearcherController` se
mantuvo exactamente igual: **73.438% (141/192)** — la prueba Otobai ejercita
la misma rama `mano obra` ya cubierta por los escenarios existentes
(Kawasaki → `RMOTOBAI`), sin aportar líneas nuevas.

**Validación con `RunLocalTests` (segundo intento, `0AfAK000000vsYL0AY`):**
con la clase huérfana ya corregida, la suite completa del org **sí compiló**
esta vez. Resultado antes de la cancelación:

| Dato | Valor |
|---|---|
| Deploy ID | `0AfAK000000vsYL0AY` |
| Componentes | 5/5 validados sin error (`numberComponentErrors: 0`, `componentFailures: []`) |
| Pruebas totales del org | 3567 |
| Pruebas completadas | 1491 |
| Pruebas con error | 287 |
| Estado final | `Canceled` (cancelado manualmente por el usuario para liberar RedMotorsSandbox), `success: false` |
| Cobertura global | No calculable — la corrida se canceló antes de completarse |

Las 3 clases del Bloque 18 (`ProductSearcherController` vía sus 2 pruebas,
`ProductSearcherControllerTest` y `ProductSearcherControllerOtobaiTest`)
aparecen explícitamente en la sección `successes` del resultado — es decir,
**todas las pruebas del Bloque 18 pasaron** dentro de esa corrida, antes de
la cancelación. Las 287 fallas registradas corresponden a la suite general
preexistente del org (cientos de clases no relacionadas con este bloque);
el usuario confirmó explícitamente que son "fallas ajenas al Bloque 18" y
canceló la corrida para liberar el sandbox, no por ningún hallazgo nuevo
imputable a este bloque.

**Estado final de este ciclo: sin deploy, sin commit adicional, sin push.**
La rama WIP permanece con el commit `f1ce045` como único commit; los
cambios de esta sección (`ProductSearcherControllerOtobaiTest.cls`/
`.cls-meta.xml`, el manifest actualizado) quedan en el working tree,
pendientes de una decisión explícita sobre si se documentan/commitean o se
descartan. `RunLocalTests` en este org, con la suite completa (3567
pruebas), excede ampliamente el tiempo práctico para completarse en una
sesión de validación puntual — cualquier intento futuro debería
considerarse con ese costo en mente.

### 30.2 Cierre — laboratorio de cobertura, validación y deploy real

Se retomó el Bloque 18 desde el worktree aislado
`C:\Users\dokur\Documents\Repositorios\RedMotors-Bloque18-CoverageLab`, rama
`analysis/pc/redmotors-block18-coverage-lab-20260726`, basada en la rama WIP
del Bloque 18. El commit de laboratorio `6f63321 test(product-search): prepare
legitimate coverage scenarios` preparó un escenario funcional de cobertura para
la rama `vehiculo`.

El cambio final posterior al laboratorio quedó limitado a
`ProductSearcherControllerTest.cls`: se ajustó el fixture de `Product2` para
respetar una cadena real de picklists dependientes confirmada en
RedMotorsSandbox (`BMW`, `Sedán`, `Serie`, `Serie 2`,
`BMW-218-GC-VR-PAQ-M`). No se modificó `ProductSearcherController.cls` durante
este cierre, no se usaron IDs reales, no se agregó `SeeAllData`, no se agregó
`Test.isRunningTest()` y no se modificaron Record Types, picklists, permisos,
Flows ni metadata funcional adicional.

Dry-runs del laboratorio:

| Deploy ID | Resultado |
|---|---|
| `0AfAK000000vu5V0AQ` | 4/4 componentes, 14/15 pruebas. Falla por `Modelo_De_Inter_s__c = COOPER-S-VR-COUNT-ALL`. Cobertura temporal 141/192 = 73.438%. Org sin modificaciones. |
| `0AfAK000000vu770AA` | 4/4 componentes, 14/15 pruebas. Falla por incompatibilidad de la cadena de picklists dependientes para `BMW-218-GC-VR-PAQ-M`. Cobertura temporal 141/192 = 73.438%. Org sin modificaciones. |
| `0AfAK000000vu8j0AA` | 4/4 componentes, 15/15 pruebas, 0 fallas. Cobertura `ProductSearcherController`: 182/192 = 94.79%. Org sin modificaciones. |
| `0AfAK000000vuAL0AY` | Regresión dirigida: 4/4 componentes, 33/33 pruebas, 0 fallas. Cobertura `ProductSearcherController`: 182/192 = 94.79%. Org sin modificaciones. |

Deploy real:

- Deploy ID: `0AfAK000000vuBx0AI`
- Ambiente: RedMotorsSandbox / Partial
- Estado: `Succeeded`
- Componentes: 4/4
- Pruebas: 33/33
- Fallas: 0
- Cobertura `ProductSearcherController`: 182/192 = 94.79%

Verificación post-deploy:

- Test Run ID: `707AK00000GwtdT`
- Pruebas: 34/34
- Fallas: 0
- Resultado: `Passed`

Resultado funcional final:

- Omoda y Jaecoo resuelven `RMPEKING` en la rama de mano de obra de
  `ProductSearcherController.getProducts()`.
- BMW y MINI conservan `RMBAVARIAN`.
- Polaris y Kawasaki conservan `RMOTOBAI`.
- No existe selección por descarte.
- Un Record Type no reconocido no devuelve productos de todas las empresas.
- Se conserva fuera de alcance cualquier decisión de sucursales, visibilidad
  comercial, Softland, reservas, anticipos, permisos o layouts.

El Bloque 18 queda completado, validado y desplegado.

Avance técnico estimado: 85% completado y 15% pendiente. Corresponde al
alcance técnico y no representa horas oficiales, trabajadas ni facturables.

## 31. Bloque 20 — Lead/Tráfico PEKING

Se retomó el Bloque 20 bajo el criterio de autonomía autorizado por Luis:
“dale tú sin miedo a los ajustes, documenta y en todo caso si hay cosas que
cambiar, lo vemos el lunes”.

Evidencia revisada:

- `TraficoTriggerHandler.afterUpdate()` llama a
  `RM_Lead_Trigger_Helper.setOpportunityRecordType()` cuando un Lead se
  convierte.
- `RM_Lead_Trigger_Helper` resuelve el Record Type destino por
  `RM_RecordTypeMapping__mdt`, no por lógica fija de marca.
- En RedMotorsSandbox existen Lead Record Types `BMW`, `MINI`, `Polaris` y
  `Kawasaki`; no existían Lead Record Types `Omoda` ni `Jaecoo`.
- En RedMotorsSandbox ya existen Opportunity Record Types `Omoda` y `Jaecoo`.
- `RM_RecordTypeMapping__mdt` contiene mappings activos para MINI, Polaris y
  Kawasaki; no contiene Omoda ni Jaecoo.
- `Lead_BMW_to_Opp` apunta actualmente a `Opportunity.Polaris`. Se documenta
  como anomalía existente y no se modifica en este bloque.

Decisión aplicada:

- Crear `Lead.Omoda` y `Lead.Jaecoo` usando `Lead.BMW` como plantilla técnica,
  con `businessProcess=Autos`, mismos picklists y `active=true`.
- Crear `RM_RecordTypeMapping.Lead_Omoda_to_Opp` activo para
  `Lead.Omoda` → `Opportunity.Omoda`.
- Crear `RM_RecordTypeMapping.Lead_Jaecoo_to_Opp` activo para
  `Lead.Jaecoo` → `Opportunity.Jaecoo`.
- No modificar `Lead.BMW` → `Opportunity.Polaris`.
- No modificar lógica productiva de `RM_Lead_Trigger_Helper`.

Pruebas preparadas:

- `RM_Lead_Trigger_Helper_Test` deja de ser solo llamada artificial a
  `name()` y pasa a validar mappings reales.
- Valida Omoda → Omoda.
- Valida Jaecoo → Jaecoo.
- Valida conservación de mappings heredados MINI y Kawasaki.
- Valida que `setOpportunityRecordType()` actualiza oportunidades convertidas
  desde Lead Omoda y Lead Jaecoo.
- Valida que un Lead sin Record Type mapeado no modifica la Opportunity.

No se elimina `RM_Lead_Trigger_Helper.name()` porque `TraficoServiceTest` aún
lo invoca; retirarlo ampliaría el alcance a pruebas ajenas.

Fuera de alcance:

- Softland;
- reservas;
- anticipos;
- finanzas;
- branding legal;
- sucursales o territorios;
- Flows, LWC, permisos, layouts;
- corrección de `Lead_BMW_to_Opp`.

Validación:

- Primer dry-run enfocado: `0AfAK000000vuK10AI`, 5/5 componentes, 0/3 pruebas.
  Falló por asignación directa a `Lead.ConvertedOpportunityId`.
- Segundo dry-run enfocado: `0AfAK000000vuLd0AI`, 5/5 componentes, 0/3
  pruebas. Falló porque los Record Types nuevos no estaban disponibles para el
  perfil ejecutor durante el check-only y porque `ConvertedOpportunityId` no era
  editable mediante `SObject.put()`.
- Corrección aplicada solo en prueba: uso de RecordTypeId sin exigir
  `isAvailable()` para metadata creada en la misma transacción y construcción de
  Leads convertidos en memoria mediante deserialización JSON.
- Dry-run enfocado aprobado: `0AfAK000000vuNF0AY`, 5/5 componentes, 3/3
  pruebas, 0 fallas.
- Regresión seleccionada aprobada: `0AfAK000000vuOr0AI`, 5/5 componentes,
  53/53 pruebas, 0 fallas.
- Deploy real: `0AfAK000000vuQT0AY`, 5/5 componentes, 53/53 pruebas, 0 fallas,
  estado Succeeded.
- Verificación post-deploy: `Lead.Omoda` y `Lead.Jaecoo` existen y están
  activos; los mappings Omoda → Omoda y Jaecoo → Jaecoo existen y están activos.
- Test post-deploy: `707AK00000GxONW`, 3/3 pruebas, 0 fallas.

Estado: Bloque 20 completado, validado y desplegado en RedMotorsSandbox /
Partial.

Avance técnico estimado: 86% completado y 14% pendiente. Corresponde al alcance
técnico y no representa horas oficiales, trabajadas ni facturables.

## 32. Bloque 21 — Experiencia declarativa de Opportunity para Omoda y Jaecoo

Se recuperó y comparó metadata declarativa de Opportunity en RedMotorsSandbox /
Partial para replicar únicamente equivalencias directas del patrón BMW.

Evidencia:

- `Opportunity.Omoda` y `Opportunity.Jaecoo` ya estaban activos con el patrón de
  vehículos nuevos definido previamente: Sales Process Autos, Compact Layout
  Vehiculos_Nuevos y picklists equivalentes.
- No fue necesario crear layouts ni Lightning Record Pages nuevas.
- La Lightning Record Page relevante para vehículos nuevos es
  `Opportunity_Record_Page_VN`.
- Esa página tenía tres campos visibles solo para BMW/MINI:
  `Asignado_original__c`, `Reasignado_por__c` y
  `Fecha_de_reasignaci_n__c`.
- Las List Views BMW tienen un patrón directo por marca para oportunidades
  abiertas, ganadas, perdidas propias y perdidas de equipo.

Cambios preparados:

- `Opportunity_Record_Page_VN`: visibilidad de los tres campos anteriores
  ampliada de BMW/MINI a BMW/MINI/Omoda/Jaecoo.
- Ocho List Views nuevas:
  - `Oportunidades_abiertas_Omoda`
  - `Oportunidades_ganadas_Omoda`
  - `Oportunidades_Perdidas_Omoda`
  - `Todas_Oportunidades_Perdidas_Omoda`
  - `Oportunidades_abiertas_Jaecoo`
  - `Oportunidades_ganadas_Jaecoo`
  - `Oportunidades_Perdidas_Jaecoo`
  - `Todas_Oportunidades_Perdidas_Jaecoo`

Fuera de alcance:

- Apex;
- Lead;
- seguridad;
- perfiles;
- Flows;
- datos;
- Softland;
- reservas;
- anticipos;
- sucursales;
- territorios.

Validación:

- Dry-run declarativo: `0AfAK000000vtcU0AQ`, 9/9 componentes, NoTestRun,
  0 fallas.
- Deploy real: `0AfAK000000vuTh0AI`, 9/9 componentes, NoTestRun, 0 fallas,
  estado Succeeded.
- Verificación post-deploy: existen las ocho List Views de Opportunity para
  Omoda/Jaecoo y `Opportunity_Record_Page_VN` quedó actualizada.

Estado: Bloque 21 completado, validado y desplegado en RedMotorsSandbox /
Partial.

Avance técnico estimado registrado al cerrar el Bloque 21: 87% completado y
13% pendiente. Corresponde al alcance técnico estimado en ese momento y no
representa horas oficiales, trabajadas ni facturables. El cierre consolidado
posterior del Sprint 1 comprometido se actualiza a 19/19 = 100%.

## 33. Bloque 10 — Búsqueda detallada y sincronización de precios

Se investigó en RedMotorsSandbox / Partial si existía evidencia suficiente para
cerrar el único bloque funcional pendiente del Sprint 1:

- `BusquedaDetalladaController`;
- `precioProductoJSON`.

Resultado:

- `BusquedaDetalladaController` continúa dependiendo de `User.Sucursal__c` y
  nombres fijos de sucursal/territorio.
- No existe una relación comprobable `Sucursal → Empresa → Pricebook /
  ServiceTerritory` para PEKING.
- No se encontraron usuarios activos con sucursal PEKING, Omoda o Jaecoo.
- No se encontraron territorios activos PEKING, Omoda o Jaecoo.
- `precioProductoJSON` usa dos convenciones distintas:
  `Codigo_de_Producto__c` para Bavarian y `CodigoProductoInterno__c` compuesto
  para Otobai.
- No existen productos ni entradas de precio PEKING/Omoda/Jaecoo en Partial que
  permitan inferir la convención correcta.
- Los Pricebooks PEKING existen activos, pero no contienen `PricebookEntry`.

Decisión:

- No se implementó cambio productivo.
- No se integraron pruebas de caracterización que congelaban comportamientos
  defectuosos.
- El Bloque 10 queda reclasificado como dependencia externa comprobada.

Pendientes:

- Definir relación operativa entre sucursal, empresa, Pricebook y territorio
  para PEKING.
- Definir llave de producto para PEKING/Omoda/Jaecoo.
- Cargar productos y entradas de precio PEKING cuando corresponda.

Validación:

- No se ejecutó dry-run ni deploy porque no hubo cambio funcional seguro.
- No se modificaron Apex productivo, metadata, datos, Pricebooks, territorios,
  productos, integraciones ni permisos.

Avance:

- Sprint 1 comprometido queda en 19/19 bloques funcionales cerrados: 100%.
- Bloque 10 queda como investigación adicional bloqueada por dependencias
  externas y no forma parte del pendiente de las 44 horas.

## 34. Análisis — `Quote.empresaFactura__c`

Se revisó `Quote.empresaFactura__c` como siguiente pendiente técnico resoluble
después de reclasificar el Bloque 10.

Hallazgos:

- `Quote.empresaFactura__c` existe como fórmula de texto.
- La fórmula es `TEXT(Opportunity.empresaQueFactura__c)`.
- No es un campo editable directamente en Quote.
- `Quote.Compania__c` es picklist restringido con valores `Bavarian` y
  `Otobai`.
- `Opportunity.empresaQueFactura__c` es picklist restringido con valores
  `Bavarian` y `Otobay`.
- La fuente estratégica ya implementada en bloques anteriores es
  `Opportunity.Empresa_Operadora__c`.

Consumidores:

- componentes de búsqueda de productos;
- Flows de Opportunity y WorkOrder;
- procesos de encuesta;
- clases relacionadas con órdenes e integraciones.

Decisión:

- No se implementó cambio funcional.
- No se modificó Quote, Opportunity, Apex, Flows, permisos ni datos.
- Cualquier cambio sobre `empresaQueFactura__c` requiere definición funcional
  por su impacto en procesos heredados y por la discrepancia `Otobay` /
  `Otobai`.

Validación:

- No se ejecutó dry-run ni deploy porque no hubo cambio desplegable seguro.

## 35. Validación 33+3 — Lote 1: cambio de ubicación VN

Se inició la validación solicitada sobre los componentes Apex y triggers del
alcance informado. Como primer cambio seguro, se corrigió
`RM_VN_CambiarUbicacion_Ctrl` para eliminar el fallback silencioso hacia
`RMBAVARIAN` cuando `Product2.Empresa__c` viene nulo, desconocido o con
`RMPEKING`.

El comportamiento de Bavarian y Otobai se conserva mediante comparación
explícita. `RMPEKING` queda bloqueado con error controlado antes de cualquier
llamada a Softland, porque no existe configuración confirmada de
bodega/contrato externo para ejecutar la transferencia. Se agregaron pruebas
funcionales dirigidas en `RM_VN_CambiarUbicacion_Ctrl_Test`.

Validación:

- Primer dry-run enfocado `0AfAK000000wueY0AQ`: 1/2 componentes, sin
  ejecución de pruebas. Falló por compilación de la prueba histórica debido a
  la llamada artificial `RM_CalloutException.dummy()`, inexistente en Partial.
  Se retiró solo ese bloque del test; no se modificó código productivo por
  esta falla.
- Segundo dry-run enfocado `0AfAK000000x07F0AQ`: 2/2 componentes, 5/6 pruebas
  aprobadas y cobertura temporal de 53/69 líneas. Falló únicamente el escenario
  PEKING porque el producto vehicular usado por la fábrica histórica no permite
  el valor `RMPEKING` en la matriz de picklist del Record Type. Se ajustó el
  fixture PEKING para usar un producto no vehicular autocontenido, sin cambiar
  metadata funcional.
- Tercer dry-run enfocado `0AfAK000000x0C50AI`: 2/2 componentes, 6/6 pruebas,
  0 fallas. Cobertura de `RM_VN_CambiarUbicacion_Ctrl`: 55/69 = 79.71%.
- Regresión seleccionada `0AfAK000000wvM60AI`: 2/2 componentes, 77/77 pruebas,
  0 fallas. Cobertura de `RM_VN_CambiarUbicacion_Ctrl`: 55/69 = 79.71%.
- Deploy real `0AfAK000000x0Ll0AI`: 2/2 componentes, 77/77 pruebas, 0 fallas,
  estado Succeeded en RedMotorsSandbox / Partial.
- Verificación post-deploy `707AK00000H9YSw`: 7/7 pruebas, 0 fallas.

Estado: Lote 1 completado, validado y desplegado en RedMotorsSandbox / Partial.

## 36. Validación 33+3 — Lote 2: consulta de disponibilidad de bodega en Quote

Se inició la corrección de `ServicioConsDispBodegaQuoli`, componente confirmado en el
documento original del alcance. La clase se utiliza desde `QuoliGridController` para
consultar disponibilidad de artículos en bodega asociados a una cotización.

Antes de modificarla se confirmó que la versión local difería de la versión vigente en
RedMotorsSandbox / Partial. Se recuperó la versión desplegada y el cambio se aplicó
sobre esa base.

Comportamiento anterior:

- `BMW_Compania__c = Bavarian` resolvía `RMBAVARIAN`;
- cualquier otro valor resolvía `RMOTOBAI`.

Cambio aplicado:

- `Opportunity.Empresa_Operadora__c` es fuente principal cuando está informado;
- `BMW_Compania__c` queda como respaldo temporal;
- Bavarian/RMBAVARIAN y Otobai/RMOTOBAI conservan su comportamiento;
- `RMPEKING` se reconoce explícitamente, pero se detiene antes del callout porque no
  existe contrato confirmado de bodega/Softland para esta operación;
- empresa nula o desconocida produce error controlado y no cae por descarte en Otobai.

Estado: pendiente de dry-run enfocado.

Validación:

- Primer dry-run enfocado `0AfAK000000x1050AA`: 2/2 componentes, 3/4 pruebas.
  Falló la prueba histórica porque el fixture no declaraba explícitamente
  `BMW_Compania__c = Bavarian` y el nuevo control detuvo la ejecución antes de
  caer por descarte en Otobai. La org no fue modificada.
- Corrección aplicada: se ajustó únicamente el fixture histórico para declarar
  `Bavarian` de forma explícita.
- Segundo dry-run enfocado `0AfAK000000x1890AA`: 2/2 componentes, 4/4 pruebas,
  0 fallas. Cobertura de `ServicioConsDispBodegaQuoli`: 153/195 = 78.46%.
- Regresión relacionada `0AfAK000000x1Eb0AI`: 2/2 componentes, 31/31 pruebas,
  0 fallas. Cobertura de `ServicioConsDispBodegaQuoli`: 153/195 = 78.46%.
- Deploy real `0AfAK000000x1Hp0AI`: 2/2 componentes, 31/31 pruebas,
  0 fallas. Estado: Succeeded en RedMotorsSandbox / Partial.
- Verificación post-deploy `707AK00000H9Xcl`: `ServicioConsDispBodegaQuoliTest`,
  5/5 pruebas, 0 fallas.

Estado: Lote 2 completado, validado y desplegado en RedMotorsSandbox / Partial.

## 37. Validación 33+3 — Lote 3: eliminación de reserva de artículos en Quote

Se inició la corrección de `ServicioEliminarReservaArticuloQuote`, componente confirmado en
el documento original del alcance. La clase se utiliza desde `QuoliGridController` para
solicitar la eliminación de reservas asociadas a líneas de una cotización.

Antes de modificarla se confirmó que la versión local difería de la versión vigente en
RedMotorsSandbox / Partial. Se recuperó la versión desplegada y el cambio se aplicó sobre
esa base.

Comportamiento anterior:

- `BMW_Compania__c = Bavarian` enviaba `RMBAVARIAN`.
- Cualquier otro valor enviaba `RMOTOBAI`.

Cambio aplicado:

- `Opportunity.Empresa_Operadora__c` queda como fuente principal y se resuelve mediante
  `EmpresaResolver`.
- `Opportunity.BMW_Compania__c` se conserva como respaldo temporal cuando el lookup está
  vacío.
- `Bavarian` / `RMBAVARIAN` mantienen `RMBAVARIAN`.
- `Otobai` / `RMOTOBAI` mantienen `RMOTOBAI`.
- `RMPEKING` se reconoce explícitamente, pero se detiene antes del callout porque no existe
  contrato confirmado de bodega/Softland para esta operación.
- Empresa nula o no soportada produce error controlado y no cae por descarte en Otobai.

No se modificaron endpoint, bodegas, sucursales, Service Territory, reservas operativas,
inventario, Flows ni LWC.

Validación:

- Dry-run enfocado `0AfAK000000x1T70AI`: 2/2 componentes, 5/5 pruebas,
  0 fallas. Cobertura de `ServicioEliminarReservaArticuloQuote`: 122/140 = 87.14%.
- Regresión relacionada `0AfAK000000x1ZZ0AY`: 2/2 componentes, 34/34 pruebas,
  0 fallas. Cobertura de `ServicioEliminarReservaArticuloQuote`: 122/140 = 87.14%.
- Deploy real `0AfAK000000wxqx0AA`: 2/2 componentes, 34/34 pruebas,
  0 fallas. Estado: Succeeded en RedMotorsSandbox / Partial.
- Verificación post-deploy `707AK00000H9CIw`: `ServicioEliminarReservaArticuloQuoteTest`,
  6/6 pruebas, 0 fallas.

Estado: Lote 3 completado, validado y desplegado en RedMotorsSandbox / Partial.

## 38. Validación 33+3 — Lote 4: reserva y apartado de artículos en Quote

Se inició la corrección de `ServicioReservaApartadoArticulosQuote`, componente confirmado
en el documento original del alcance. La clase se utiliza desde `QuoliGridController` para
solicitar reserva o apartado de artículos asociados a una cotización.

Antes de modificarla se confirmó que la versión local difería de la versión vigente en
RedMotorsSandbox / Partial. Se recuperó la versión desplegada y el cambio se aplicó sobre
esa base.

Comportamiento anterior:

- `BMW_Compania__c = Bavarian` enviaba `RMBAVARIAN`.
- Cualquier otro valor enviaba `RMOTOBAI`.

Cambio aplicado:

- `Opportunity.Empresa_Operadora__c` queda como fuente principal y se resuelve mediante
  `EmpresaResolver`.
- `Opportunity.BMW_Compania__c` se conserva como respaldo temporal cuando el lookup está
  vacío.
- `Bavarian` / `RMBAVARIAN` mantienen `RMBAVARIAN`.
- `Otobai` / `RMOTOBAI` mantienen `RMOTOBAI`.
- `RMPEKING` se reconoce explícitamente, pero se detiene antes del callout porque no existe
  contrato confirmado de bodega/Softland para esta operación.
- Empresa nula o no soportada produce error controlado y no cae por descarte en Otobai.

No se modificaron endpoint, bodegas, sucursales, Service Territory, reservas operativas,
inventario, Flows ni LWC.

Validación:

- Dry-run enfocado `0AfAK000000wxhH0AQ`: 2/2 componentes, 4/4 pruebas,
  0 fallas. Cobertura de `ServicioReservaApartadoArticulosQuote`: 118/143 = 82.52%.
- Regresión relacionada `0AfAK000000x1ph0AA`: 2/2 componentes, 37/37 pruebas,
  0 fallas. Cobertura de `ServicioReservaApartadoArticulosQuote`: 118/143 = 82.52%.
- Deploy real `0AfAK000000x0gk0AA`: 2/2 componentes, 37/37 pruebas,
  0 fallas. Estado: Succeeded en RedMotorsSandbox / Partial.
- Verificación post-deploy `707AK00000H9jrT`: `SRAArticulosQuoteTest`,
  5/5 pruebas, 0 fallas.

Estado: Lote 4 completado, validado y desplegado en RedMotorsSandbox / Partial.

## 39. Validación 33+3 — Lote 5: solicitud de compra en Quote

Se inició la corrección de `ServicioCrearSCQuote`, componente confirmado en el documento
original del alcance. La clase se utiliza desde controladores de líneas para crear
solicitudes de compra asociadas a una cotización.

Antes de modificarla se confirmó que la versión local difería de la versión vigente en
RedMotorsSandbox / Partial. Se recuperó la versión desplegada y el cambio se aplicó sobre
esa base.

Comportamiento anterior:

- `BMW_Compania__c = Bavarian` enviaba `RMBAVARIAN`.
- Cualquier otro valor enviaba `RMOTOBAI`.

Cambio aplicado:

- `Opportunity.Empresa_Operadora__c` queda como fuente principal y se resuelve mediante
  `EmpresaResolver`.
- `Opportunity.BMW_Compania__c` se conserva como respaldo temporal cuando el lookup está
  vacío.
- `Bavarian` / `RMBAVARIAN` mantienen `RMBAVARIAN`.
- `Otobai` / `RMOTOBAI` mantienen `RMOTOBAI`.
- `RMPEKING` se reconoce explícitamente, pero se detiene antes del callout porque no existe
  contrato confirmado de Softland para crear solicitudes de compra de Quote.
- Empresa nula o no soportada produce error controlado y no cae por descarte en Otobai.

No se modificaron endpoint, bodegas, sucursales, Service Territory, anticipos,
inventario, Flows ni LWC.

Validación:

- Dry-run enfocado `0AfAK000000x2CH0AY`: 2/2 componentes, 17/17 pruebas,
  0 fallas. Cobertura de `ServicioCrearSCQuote`: 125/134 = 93.28%.
- Regresión relacionada `0AfAK000000x2KL0AY`: 2/2 componentes, 76/76 pruebas,
  0 fallas. Cobertura de `ServicioCrearSCQuote`: 125/134 = 93.28%.
- Deploy real `0AfAK000000x2PB0AY`: 2/2 componentes, 76/76 pruebas,
  0 fallas. Estado: Succeeded en RedMotorsSandbox / Partial.
- Verificación post-deploy `707AK00000H9lER`: `ServicioCrearSCQuoteTest`,
  18/18 pruebas, 0 fallas.

Estado: Lote 5 completado, validado y desplegado en RedMotorsSandbox / Partial.

## 40. Validación 33+3 — Next8 Lote 1: pedido Softland de Quote

Se completó la corrección de `QuoteSoftlandPedidoService` y
`QuoteSoftlandQueryService`, componentes confirmados para el alcance pendiente
ejecutable. `QuoteSoftlandPedidoService` depende de `QuoteSoftlandQueryService`
para obtener los campos de Quote y Opportunity usados en la construcción del
payload.

Antes de modificar se confirmó que la versión local difería de la versión
vigente en RedMotorsSandbox / Partial. Se recuperó la versión desplegada y los
cambios se aplicaron sobre esa base para evitar reintroducir deuda local.

Comportamiento anterior:

- `BMW_Compania__c = Bavarian` enviaba `RMBAVARIAN`.
- Cualquier otro valor enviaba `RMOTOBAI`.

Cambio aplicado:

- `Opportunity.Empresa_Operadora__c` queda como fuente principal y se resuelve
  mediante `EmpresaResolver`.
- `Opportunity.BMW_Compania__c` se conserva como respaldo temporal cuando el
  lookup está vacío.
- `Bavarian` / `RMBAVARIAN` mantienen `RMBAVARIAN`.
- `Otobai` / `RMOTOBAI` mantienen `RMOTOBAI`.
- `RMPEKING` se reconoce explícitamente y el valor enviado en `payload.compania`
  proviene de `EmpresaContext.Codigo_ERP__c`.
- Empresa nula o no soportada produce error controlado antes de consultar
  Softland y no cae por descarte en Otobai.

No se modificaron endpoint, credenciales, bodegas, sucursales, reservas,
anticipos, inventario, Flows ni LWC.

Validación:

- Primer dry-run enfocado `0AfAK000000x3WY0AY`: 3/3 componentes compilados,
  7/11 pruebas aprobadas. Fallaron las pruebas nuevas por datos de fixture
  incompletos ante automatizaciones de Account. La org no fue modificada.
- Segundo dry-run enfocado `0AfAK000000x3hp0AA`: 3/3 componentes compilados,
  7/11 pruebas aprobadas. Fallaron las pruebas nuevas por duplicidad de
  `PricebookEntry` estándar. La org no fue modificada.
- Dry-run enfocado final `0AfAK000000x3mf0AA`: 3/3 componentes, 11/11 pruebas,
  0 fallas. Cobertura de `QuoteSoftlandPedidoService`: 105/117 = 89.74%.
  Cobertura de `QuoteSoftlandQueryService`: 7/7 = 100%.
- Regresión relacionada `0AfAK000000x3zZ0AQ`: 3/3 componentes, 12/12 pruebas,
  0 fallas.
- Deploy real `0AfAK000000x2qd0AA`: 3/3 componentes, 12/12 pruebas, 0 fallas.
  Estado: Succeeded en RedMotorsSandbox / Partial.
- Verificación post-deploy `707AK00000H9tYa`: `TestServiciosQuote` y
  `QuoteOrderSoftlandCalloutTest2`, 12/12 pruebas, 0 fallas.

Estado: Next8 Lote 1 completado, validado y desplegado en RedMotorsSandbox /
Partial.

## 41. Validación 33+3 — Next8 Lote 2: reserva de vehículo

Se completó la corrección de `servicioReservas`, componente confirmado del
alcance pendiente ejecutable. La clase solicita la reserva de un vehículo en
Softland tomando la empresa desde `Product2.Empresa__c`.

Antes de modificar se confirmó que la versión local de la prueba y del mock
difería de la versión vigente en RedMotorsSandbox / Partial. Se recuperó la
versión desplegada y el cambio se aplicó sobre esa base.

Comportamiento anterior:

- `Product2.Empresa__c = Bavarian` se convertía a `RMBAVARIAN`.
- `Product2.Empresa__c = Otobai` se convertía a `RMOTOBAI`.
- Solo `RMBAVARIAN` y `RMOTOBAI` continuaban hacia Softland.
- La validación de empresa ocurría después de solicitar token.

Cambio aplicado:

- `Bavarian` / `RMBAVARIAN` mantienen `RMBAVARIAN`.
- `Otobai` / `RMOTOBAI` mantienen `RMOTOBAI`.
- `RMPEKING` se reconoce explícitamente, pero se detiene antes del callout de
  reserva porque no existe contrato confirmado de reserva Softland para PEKING.
- Empresa nula o no soportada produce error controlado y no cae por descarte en
  Bavarian u Otobai.
- La validación de empresa ocurre antes de solicitar token.

No se modificaron endpoint, credenciales, VIN, Opportunity, Product2, reservas
operativas, inventario, Flows ni LWC.

Validación:

- Primer dry-run enfocado `0AfAK000000x47d0AA`: 3/3 componentes compilados,
  3/4 pruebas aprobadas. Falló el fixture PEKING porque `Product2.Marca__c =
  Omoda` no es un valor activo del picklist. La org no fue modificada.
- Segundo dry-run enfocado `0AfAK000000x4Ar0AI`: 3/3 componentes compilados,
  3/4 pruebas aprobadas. Falló el fixture PEKING porque `RMPEKING` no estaba
  habilitado para el Record Type `Product2.Vehiculos` usado por la prueba. La
  org no fue modificada.
- Corrección aplicada: el fixture usa el Record Type `Product2.Producto_Red_Motors`,
  que tiene habilitados `RMBAVARIAN`, `RMOTOBAI` y `RMPEKING`.
- Dry-run enfocado final `0AfAK000000wwlC0AQ`: 3/3 componentes, 4/4 pruebas,
  0 fallas. Cobertura de `servicioReservas`: 58/68 = 85.29%.
- Regresión relacionada `0AfAK000000x30I0AQ`: 3/3 componentes, 16/16 pruebas,
  0 fallas.
- Deploy real `0AfAK000000x3mg0AA`: 3/3 componentes, 16/16 pruebas, 0 fallas.
  Estado: Succeeded en RedMotorsSandbox / Partial.
- Verificación post-deploy `707AK00000H9o1s`: `servicioReservasTest`, 4/4
  pruebas, 0 fallas.

Estado: Next8 Lote 2 completado, validado y desplegado en RedMotorsSandbox /
Partial.

## 42. Validación 33+3 — Next8 Lote 2: eliminación de reserva de vehículo

Fecha: 28/07/2026.

Componentes:

- `servicioEliminarReserva`;
- `servicioEliminarReservaTest`;
- `servicioEliminarReservaMock`.

Antes de modificar se confirmó que la versión local de la prueba y del mock
difería de la versión vigente en RedMotorsSandbox / Partial. Se recuperó la
versión desplegada y el cambio se aplicó sobre esa base.

Comportamiento anterior:

- `Product2.Empresa__c = Bavarian` se convertía a `RMBAVARIAN`.
- Solo `RMBAVARIAN` continuaba hacia Softland.
- `Otobai`, `RMOTOBAI`, `RMPEKING`, empresa nula o empresa no soportada no
  tenían una respuesta explícita.
- La solicitud de token ocurría antes de validar empresa.
- Existía un bypass `Test.isRunningTest()` para simular token en pruebas.

Cambio aplicado:

- `Bavarian` / `RMBAVARIAN` mantienen `RMBAVARIAN`.
- `Otobai` / `RMOTOBAI` se reconocen explícitamente y se detienen antes del
  callout porque no existe contrato confirmado de eliminación de reserva
  Softland para Otobai en esta clase.
- `RMPEKING` se reconoce explícitamente y se detiene antes del callout porque
  no existe contrato confirmado de eliminación de reserva Softland para PEKING.
- Empresa nula o no soportada produce error controlado y no cae por descarte en
  Bavarian u Otobai.
- La validación de empresa ocurre antes de solicitar token.
- Se retiró el bypass `Test.isRunningTest()` para probar la ruta real mediante
  mock HTTP.

No se modificaron endpoint, credenciales, VIN, Opportunity, Product2, reservas
operativas, inventario, Flows ni LWC.

Validación:

- Dry-run enfocado `0AfAK000000x4Vp0AI`: 3/3 componentes, 4/4 pruebas,
  0 fallas. Cobertura de `servicioEliminarReserva`: 48/51 = 94.12%.
- Regresión relacionada `0AfAK000000x4af0AA`: 3/3 componentes, 17/17 pruebas,
  0 fallas.
- Deploy real `0AfAK000000x4ij0AA`: 3/3 componentes, 17/17 pruebas, 0 fallas.
  Estado: Succeeded en RedMotorsSandbox / Partial.
- Verificación post-deploy `707AK00000HA7uX`: `servicioEliminarReservaTest`,
  4/4 pruebas, 0 fallas.

Estado: Next8 Lote 2 completado, validado y desplegado en RedMotorsSandbox /
Partial.

## 43. Plantilla reutilizable de actualización

Copiar esta sección para cada siguiente cambio y completar solo con evidencia
confirmada:

### Actualización — [bloque o componente]

| Dato | Registro |
|---|---|
| Fecha | Pendiente |
| Bloque | Pendiente |
| Solicitud | Pendiente |
| Autorizado por | Pendiente |
| Componentes | Pendiente |
| Cambios | Pendiente |
| Pruebas | Pendiente |
| Dry-run | ID, estado, componentes, pruebas y fallas; o “No ejecutado” |
| Deploy | ID, estado, componentes, pruebas y fallas; o “No ejecutado” |
| Evidencia | Pendiente |
| Commit | Hash y mensaje; o “Pendiente” |
| Horas | Estimadas y/o registradas, claramente diferenciadas |
| Riesgos | Pendiente |
| Pendientes | Pendiente |

Reglas de actualización:

1. No reemplazar estimaciones por horas reales sin timesheet o confirmación.
2. No atribuir decisiones sin indicar quién y qué evidencia las respalda.
3. Registrar fallas y correcciones, no solo resultados exitosos.
4. Marcar como pendiente cualquier dato no comprobado.
5. Mantener separados disponibilidad técnica, configuración operativa y
   activación funcional.
