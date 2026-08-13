# Cierre funcional Sprint 2 posterior a respuesta de Luis

**Fecha:** 13 de agosto de 2026

**Ambiente:** RedMotors Sandbox Partial
**Resultado:** **C. SPRINT 2 NO CERRABLE — F07 cerrado; N2/N4 conservan QA funcional pendiente y N3 espera confirmación de Diego**

## Autorización aplicada

Luis autorizó el 13 de agosto de 2026:

- usar Bavarian como baseline técnico para F07, N2 y N4 cuando exista una equivalencia real;
- crear datos de QA provisionales cuando todavía no exista configuración oficial PEKING;
- mantener todo valor no confirmado como **PROVISIONAL / QA / BASADO EN BAVARIAN — PENDIENTE DEFINICIÓN FINAL**;
- considerar temporalmente que PEKING no usa garantía de fábrica, sin convertir esa suposición en regla definitiva hasta recibir confirmación de Diego.

Esta autorización no convierte los datos provisionales en catálogo, territorio, bodega, servicio ni política oficial de PEKING.

## F07 — `PlanDeMantenimientoV2`

### Baseline Bavarian utilizado

No existe una entrevista histórica completa que conserve simultáneamente vehículo, QuoteLineItem, WarrantyTerm y Plan. Se utilizó un baseline compuesto, verificable y expresamente provisional:

| Elemento | Baseline | Uso en QA |
|---|---|---|
| Vehículo/Product2 | BMW X1, Product2 `01tPH00000K5VMDYA3`, código/VIN `WBA21EE04V5719240` | Ejemplo mecánico; no es catálogo oficial PEKING. |
| PBE Bavarian CRC | `01uPH000009qCo2YAE`, Bavarian Local | Evidencia de que el producto tiene representación CRC. |
| Tipo de plan | `Regalías Autos` | Baseline histórico del Plan `A-0575`. |
| WarrantyTerm | `4V3PH00000000eL0AQ`, `Cambio de Aceite y Filtro` | CRC, duración 1 año, tipo `Regalías Autos`; no es término oficial PEKING. |
| Quote PEKING | `0Q0AK000001zL5N0AU` / `00080233` | PEKING Local, CRC. |

Se creó el PBE provisional PEKING Local `01uAK000000YWrtYAG` con precio nominal `1` y el QLI de vehículo `0QLAK000001wnB34AI`, rotulado como dato provisional basado en Bavarian.

### Primer QA y diagnóstico

La entrevista funcional:

- inició correctamente como perfil QA funcional;
- reconoció el Quote PEKING y el único QLI de vehículo;
- permitió seleccionar `Regalías Autos`;
- permitió seleccionar el WarrantyTerm provisional;
- aceptó fecha, detalle, costo nominal y clasificación como regalía;
- falló al intentar persistir el resultado.

Evidencia de entrevista:

- Flow: `PlanDeMantenimientoV2`;
- versión: v24;
- GUID: `8650ffa67691e21665d43c649a7719ffbfb9dd8-59d2`;
- estado: `Error`;
- secuencia posterior a la última pantalla: `Costo_Plan → Termino → GetTerminoPlan → ifA_os → crearPlanMantenimiento → Ifextra → Copy_1_of_CreateQuoteLineItem`;
- no quedó un Plan nuevo;
- no quedó el QLI `SAD001` generado por el Flow;
- la transacción fue revertida.

La entrevista preservada identificó después el elemento exacto `Copy_1_of_CreateQuoteLineItem` y el mensaje `INVALID_FIELD_FOR_INSERT_UPDATE`: el perfil funcional tenía lectura, pero no edición, sobre `QuoteLineItem.Quote_Line_Item__c` y `QuoteLineItem.esRegalia__c`. No existen Validation Rules activas sobre `Plan_de_mantenimiento__c` ni `QuoteLineItem`; Pricebook, moneda, Product2, WarrantyTerm y automatización downstream no fueron la causa.

### Remediación FLS y QA final

Se creó el Permission Set `Plan_Mantenimiento_QLI_QA`, marcado **QA TEMPORAL — NO PROMOVER A PRODUCCIÓN**, con únicamente Read/Edit sobre los dos campos requeridos. Dry-run `0AfAK0000014SoM0AU`, deploy `0AfAK0000014XZV0A2` y asignación funcional `0PaAK000002sntp0AA`.

Se ejecutó una sola entrevista posterior con el mismo dataset:

- versión v24;
- GUID `65760061b22932e5cc1210b9d45c19ffc1a94d3-3be6`;
- estado `Completed` y evento final `FlowFinish`;
- Plan `a4VAK0000000XAT2A2` / `A-0607` persistido;
- QLI `0QLAK000001wmYM4AY` persistido;
- Quote `0Q0AK000001zL5N0AU` / `00080233`, PEKING Local, CRC;
- producto `SAD001`, PBE `01uAK000000YRDtYAO`, cantidad `1`, precio `1`;
- `Quote_Line_Item__c = 0QLAK000001wnB34AI` y `esRegalia__c = true`;
- exactamente un Plan y un QLI creados, sin duplicado, fault ni rollback.

Estado F07: **QA FUNCIONAL OK — PEKING**.

## N2 — Quote a Work Order

Baseline real confirmado:

- ejecución selectiva Bavarian completada;
- Work Order real `0WOPH00000czlQk4AI` / `00087315`;
- Bavarian Local, CRC;
- origen `Reserva`;
- territorio Bavarian real;
- WOLI creados desde las líneas del Quote.

Dataset PEKING preparado:

- Quote normal `0Q0AK000001zH8E0AU` / `00080231`;
- QLI normal `0QLAK000001wnCf4AI`;
- Quote selectivo `0Q0AK000001zJ8P0AU` / `00080232`;
- QLI selectivo `0QLAK000001wnFt4AI`;
- PBE `SAD001` PEKING Local `01uAK000000YRDtYAO`;
- bodega provisional `a2bAK0000000vvxYAA`;
- territorio provisional `0HhAK0000000sbV0AQ`.

El defecto de propagación quedó confirmado antes del QA: los dos Flows escribían únicamente el código ERP en `WorkOrder.empresaFactura__c` y omitían el lookup canónico `WorkOrder.empresaFacturaCP__c`. La remediación mínima agregó en `Crear_la_Ot` la asignación `empresaFacturaCP__c = Datos_Opp.Empresa_Operadora__c`, conservando sin cambios el código ERP legacy y los conectores. Dry-run `0AfAK0000014YVZ0A2` y deploy `0AfAK0000014YXB0A2`, ambos 2/2. Versiones activas resultantes: `Work_Order_from_Quote` v11 (`301AK00000PXmdtYAD`) y `Work_Order_from_Quote_Selective` v9 (`301AK00000PXmduYAD`). El retrieve posterior confirmó ambas asignaciones en la serialización de la org.

La única ejecución normal autorizada, con Quote `0Q0AK000001zH8E0AU`, usó v11 y terminó `Error` antes de crear la Work Order. Entrevista `0FoAK000001dktg0AA`, GUID `353408d488878c0aed243898ed1819ffc2d6b7-a94a`, log `8gZAK000000Iuer2AC`; elemento `Asignar_Codigo_Empresa_Operadora`. Mensaje: *"El flujo no pudo acceder al valor para Datos_Opp.Empresa_Operadora__r.Codigo_ERP__c porque el campo no está disponible para el usuario que ejecuta."* El usuario funcional no tiene FLS de lectura efectivo sobre `Empresa__c.Codigo_ERP__c`. No se persistió Work Order ni WOLI y no se ejecutó la variante selectiva.

Estado N2: **REMEDIACIÓN LOOKUP DESPLEGADA — QA NORMAL BLOQUEADO POR FLS — QA SELECTIVO NO EJECUTADO**.

## N4 — servicios, agenda y territorios

### Patrón real y equivalencia implementada

El patrón heredado distinguía Otobai por texto en el nombre del Service Territory y enviaba el resto por un default Bavarian. La equivalencia mínima se hizo configurable sin agregar una rama literal PEKING:

- nuevo lookup `ServiceTerritory.Empresa__c`;
- resolución del código ERP desde `Empresa__r.Codigo_ERP__c`;
- conservación de los fallbacks `RMBAVARIAN` y `RMOTOBAI` únicamente para territorios legacy sin Empresa;
- `WorkOrder.empresaFacturaCP__c` poblado desde la Empresa del territorio;
- `Opportunity.Empresa_Operadora__c` poblado desde la Empresa del territorio;
- Pricebook CRC activo resuelto por `Pricebook2.Empresa__c`, con fallback nominal solo para territorios legacy sin Empresa;
- permisos mínimos: lectura para ejecutores de Flow y edición solo para administración de configuración.

No se modificaron reglas de agenda, Case, Asset, contacto, sucursal ni pantallas.

Validación y despliegue:

- dry-run: `0AfAK0000014Qhj0AE`, 4/4 componentes;
- deploy: `0AfAK0000014VRF0A2`, 4/4 componentes;
- `aperturaCaseWorOrderEvent` v21 activa, `301AK00000PXgqCYAT`;
- `ct_newCaseWorkOrderEvent` v55 activa, `301AK00000PXgqDYAT`;
- permiso administrativo complementario: dry-run `0AfAK0000014Ve90AE`, deploy `0AfAK0000014V7u0AE`.

Configuración PEKING provisional:

- Service Territory `0HhAK0000000sbV0AQ` relacionado con PEKING;
- moneda CRC;
- descripción `PROVISIONAL_QA_BASADO_EN_BAVARIAN_NO_PRODUCCION`.

Estado N4: **VALIDACIÓN TÉCNICA OK — CONFIGURACIÓN PROVISIONAL DESPLEGADA — QA FUNCIONAL PENDIENTE**.

## N3 — garantía

`SegregateWOLIs` solo muestra la selección específica de garantía Otobai cuando el Work Order pertenece a `RMOTOBAI` y existen porcentajes de garantía. Con porcentajes de garantía en cero, PEKING cae naturalmente en el comportamiento sin garantía y no requiere cambio técnico.

No se modificó el Flow y no se creó ningún campo o regla PEKING.

Estado N3: **PENDIENTE CONFIRMACIÓN DIEGO — GARANTÍA PEKING**.

Diego debe confirmar si la ausencia de garantía de fábrica será la regla definitiva y si existen excepciones, porcentajes o tipos de garantía aplicables.

## Datos provisionales

| Dato | Valor usado QA | Baseline | Provisional | Reemplazar cuando |
|---|---|---|---|---|
| Product2/vehículo F07 | `01tPH00000K5VMDYA3` / BMW X1 | Vehículo Bavarian real | Sí; no es catálogo PEKING | Exista Product2/vehículo PEKING oficial. |
| PBE vehículo F07 | `01uAK000000YWrtYAG`, PEKING Local, CRC, precio `1` | PBE Bavarian CRC del mismo producto | Sí | Exista catálogo y precio PEKING oficial. |
| WarrantyTerm | `4V3PH00000000eL0AQ` | Plan Bavarian `A-0575` | Sí | Se defina término PEKING. |
| Tipo de plan | `Regalías Autos` | Plan Bavarian `A-0575` | Sí | Se defina tipo de plan PEKING. |
| Bodega | `a2bAK0000000vvxYAA` | Estructura Bavarian | Sí | Se defina bodega PEKING oficial. |
| Service Territory | `0HhAK0000000sbV0AQ` | Estructura Bavarian | Sí | Se definan territorio, taller y servicios PEKING. |
| Reserva/despacho/taller | Defaults existentes de los Flows y territorio provisional | Bavarian | Sí | Se definan reglas operativas PEKING. |
| Sucursal/servicios | No se creó catálogo nuevo; se preservaron reglas existentes | Bavarian | Sí | Se definan sucursales y servicios PEKING. |

## Permiso temporal

`WorkOrder_Empresa_Factura_QA` debe conservarse. La entrevista normal N2 se ejecutó una vez y quedó bloqueada antes de crear registros; el acceso sobre Work Order sigue siendo necesario para completar sus pruebas. Continúa marcado **QA TEMPORAL — NO PROMOVER A PRODUCCIÓN** y no debe retirarse automáticamente.

`Plan_Mantenimiento_QLI_QA` y su asignación `0PaAK000002sntp0AA` deben conservarse hasta terminar Sprint 2 y decidir el modelo definitivo de acceso para los usuarios funcionales que ejecuten planes de mantenimiento. No promover a Producción ni ampliar asignaciones sin esa revisión.

## Criterio final

**C. SPRINT 2 NO CERRABLE — F07 está cerrado; quedan QA funcionales N2/N4 y la confirmación N3.**

El fault FLS de F07 quedó diagnosticado y remediado de forma mínima, y el reintento único concluyó correctamente. N2 tiene la propagación de Empresa desplegada, pero su QA normal quedó bloqueado por FLS de `Empresa__c.Codigo_ERP__c`; la ruta selectiva no se ejecutó. N4 permanece listo para QA dirigido. N3 continúa siendo una confirmación externa de Diego y no debe convertirse en regla definitiva.
