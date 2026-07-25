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

## 15. Plantilla reutilizable de actualización

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
