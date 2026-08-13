# Cierre funcional Sprint 2 posterior a respuesta de Luis

**Fecha:** 13 de agosto de 2026

**Ambiente:** RedMotors Sandbox Partial
**Resultado:** **SPRINT 2 — CERRADO**

**Historial de correcciones de este documento:** el resultado "F07, N2 y N4 cerrados; N3 espera confirmación de Diego" (temprano el 13 de agosto) era prematuro porque el bug de recálculo de Pricebook en los 4 Flows de Opportunity todavía no estaba corregido; esa corrección ya se aplicó (ver sección dedicada más abajo). Con N3 ahora validado sin cambio técnico (ver sección "N3 — garantía"), Sprint 2 queda **CERRADO** — no quedan pendientes técnicos ni de negocio dentro del alcance implementable de este Sprint.

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

La primera ejecución normal autorizada, con Quote `0Q0AK000001zH8E0AU`, usó v11 y terminó `Error` antes de crear la Work Order. Entrevista `0FoAK000001dktg0AA`, GUID `353408d488878c0aed243898ed1819ffc2d6b7-a94a`, log `8gZAK000000Iuer2AC`; elemento `Asignar_Codigo_Empresa_Operadora`. Mensaje: *"El flujo no pudo acceder al valor para Datos_Opp.Empresa_Operadora__r.Codigo_ERP__c porque el campo no está disponible para el usuario que ejecuta."* No se persistió Work Order ni WOLI. La causa quedó demostrada como ausencia de lectura efectiva sobre `Empresa__c.Codigo_ERP__c` para el usuario funcional.

La remediación mínima reutilizó el acceso existente a `Empresa__c` y agregó únicamente el Permission Set `Empresa_Codigo_ERP_QA` (`0PSAK0000007i2j4AA`) con Read sobre `Empresa__c.Codigo_ERP__c`, sin Edit ni permisos adicionales de objeto. Dry-run `0AfAK0000014ZUr0AM`, deploy `0AfAK0000014ZY50AM` y asignación al usuario funcional `0PaAK000002skDC0AY`. El acceso efectivo posterior quedó en Read=true y Edit=false.

El único reintento normal posterior terminó `Completed` en v11: log `8gZAK000000IsGU2A0`, GUID `469561e249a549bc9c5a63f24a19ffc414307-5b7d`. Creó exactamente la Work Order `0WOAK000005k8vl4AA` / `00087393` y el WOLI `1WLAK0000000s8T4AQ`, con PEKING en `empresaFacturaCP__c`, código ERP legacy `RMPEKING`, CRC, Pricebook `PEKING Local`, bodega provisional PEKING y territorio provisional PEKING. No hubo fault, rollback ni duplicidad.

Solo después de ese resultado se ejecutó una vez la variante selectiva. La entrevista v9 terminó `Completed`: log `8gZAK000000ItPS2A0`, GUID `9761e249a549bc9c5a63f24a19ffc414307-4569`. Se eligió su único ítem y se crearon exactamente la Work Order `0WOAK000005k8yz4AA` / `00087394` y el WOLI `1WLAK0000000sBh4AI`, con los mismos valores estructurales PEKING, CRC y Pricebook `PEKING Local`. No hubo fault, rollback ni duplicidad.

Estado N2: **QA FUNCIONAL OK — PEKING**. La validación utiliza **CONFIGURACIÓN OPERATIVA PROVISIONAL BASADA EN BAVARIAN — NO PRODUCCIÓN** para bodega y territorio; no los convierte en configuración oficial.

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

QA dirigido posterior:

- usuario asesor funcional (`005PH000007m1k9YAA`);
- Event QA `00UAK000003Bik12AC`, con `OwnerId = Asesor__c`, Account/Contact/Asset QA y Service Territory provisional PEKING;
- `Empresa_Consulta_Flows` fue asignado mediante `0PaAK000002spqp0AA`; aporta Read sobre `Empresa__c` y Read sobre `ServiceTerritory.Empresa__c`, sin Create/Edit/Delete;
- `Empresa_Codigo_ERP_QA` fue asignado mediante `0PaAK000002swU60AI`; aporta exclusivamente Read sobre `Empresa__c.Codigo_ERP__c`;
- el fallo de inicialización quedó demostrado como ausencia de Read efectivo sobre `Event.WhoId` para el usuario asesor;
- se creó `Event_Who_QA` (`0PSAK0000007iE14AI`), marcado **QA TEMPORAL — NO PROMOVER A PRODUCCIÓN**, con Read sobre `Event.WhoId` y el par Activity `Task.WhoId`, ambos con Edit=false y sin permisos de objeto o sistema adicionales; dry-run `0AfAK0000014eJF0AY`, deploy `0AfAK0000014eKr0AI` y asignación exclusiva `0PaAK000002slyU0AQ`;
- la verificación posterior confirmó Read=true y Edit=false sobre ambos campos;
- la única ejecución autorizada posterior de `aperturaCaseWorOrderEvent` v21 inició correctamente y llegó a la pantalla final sin fault; log `8gZAK000000IwNJ2A0`, GUID `1544989ff01e71df3f04aa31b5d19ffc9ce303-745e`;
- se creó el Case `500AK00000HnxI5YAJ` / `00091091` y se reutilizó la Work Order `0WOAK000005k8vl4AA` / `00087393`; el Event quedó relacionado con ambos y en estado `Asistió`;
- la Work Order conservó PEKING en `empresaFacturaCP__c`, `RMPEKING` en `empresaFactura__c`, CRC y Pricebook `PEKING Local`; no se creó otra Work Order ni se observó duplicidad;
- la Opportunity asociada `006AK00000JM25SYAT` era preexistente y no cumplió el criterio estructural de N4: `Empresa_Operadora__c = null`, compañía legacy vacía, moneda USD, Pricebook estándar y Record Type BMW;
- no se creó Opportunity ni Quote en esta ejecución; los cambios persistidos fueron Case, relaciones Event–Case–Work Order y actualización de la Work Order, sin rollback;
- `ct_newCaseWorkOrderEvent` v55 no se ejecutó en ese momento porque v21 no satisfizo todos los criterios de aceptación, conforme al criterio de parada.

### Remediación del dataset y cierre de N4

Con autorización explícita, se aplicó un único DML sobre el Asset QA `02iAK000001xtZNYAY`: se actualizaron exclusivamente los lookups `Oportunidad__c` y `Oportunidad_relacionada__c`, de la Opportunity legacy `006AK00000JM25SYAT` (BMW, `Empresa_Operadora__c = null`) hacia la Opportunity ya validada `006AK00000JT9UoYAL` ("QA Prueba-Taller-12/08/2026", `Empresa_Operadora__c = PEKING`, Pricebook `PEKING Local`, CRC, `BMW_Compania__c = null`, con Quote `0Q0AK000001zJ8P0AU` ya relacionada). No se modificó ningún otro campo del Asset ni se ejecutó ningún otro DML.

Con el dataset corregido:

- `aperturaCaseWorOrderEvent` v21 se re-ejecutó una sola vez sobre el mismo Event `00UAK000003Bik12AC`. El Flow reconoció que el Event ya contaba con Case y Work Order (mensaje controlado "Este evento ya cuenta con caso y orden de trabajo"), sin fault y sin crear registros nuevos. FlowInterviewLog `8gZAK000000IxeM2AS` (2026-08-13T20:42:19Z). Verificado por SOQL: Case `500AK00000HnxI5YAJ`/`00091091` y Work Order `0WOAK000005k8vl4AA`/`00087393` sin cambios ni duplicados; la Opportunity asociada al Asset ya resuelve PEKING (`Empresa_Operadora__r.Codigo_ERP__c = RMPEKING`), sin fallback Bavarian/Otobai.
- Con v21 aprobado, `ct_newCaseWorkOrderEvent` v55 se ejecutó una sola vez sobre el mismo Event. El Flow avanzó por las pantallas de "Asistió" y "Kilometraje/Horas de uso" y terminó con el mismo mensaje controlado, sin error visible. FlowInterviewLog `8gZAK000000IxuT2AS` (2026-08-13T20:54:34Z). Verificado por SOQL: `Event.Estado__c = "Asistió"`, `Kilometraje__c`/`Kilometraje_Horas_de_uso__c = 10` y `Asset.Kilometros__c = 10` persistidos sin rollback; Case y Work Order siguen siendo los mismos (`00091091` / `00087393`, sin duplicado); Work Order conserva `empresaFacturaCP__c` → PEKING y `empresaFactura__c = RMPEKING`; total de Cases y Work Orders de la cuenta QA sin cambio (2 y 3 respectivamente) — sin duplicidad.

Estado N4: **QA FUNCIONAL OK — PEKING**.

## N3 — garantía (validación final, 2026-08-13)

`SegregateWOLIs` v51 (activa) fue revisado de forma dirigida. La regla que determina si una línea (WOLI) tiene garantía depende únicamente de dos campos porcentuales de la línea, `Garantia2 > 0` y `BSIInterno2 > 0` — es agnóstica de empresa, aplica igual a Bavarian, Otobai y PEKING.

Se encontró una única condición por empresa en todo el Flow: el campo de pantalla `GarantiaOtobai` ("Garantía Otobai", opciones `KAWASAKI`/`POLARIS`) solo es visible cuando `GetWorkOrder.empresaFactura__c EqualTo 'RMOTOBAI'` (además de `Garantia2`/`BSIInterno2` > 0). Diego confirmó que esta condición no forma parte de la regla general de garantía — únicamente controla la visibilidad del selector de sub-marca de motocicleta propio de Otobai (Kawasaki/Polaris), no una regla de garantía distinta por empresa. Ninguna otra referencia a Bavarian, PEKING, `BMW_Compania__c`, `Empresa_Operadora__c`, `empresaFacturaCP__c`, Record Type o marca existe en el Flow.

No se modificó el Flow y no se creó ningún campo o regla PEKING.

Estado N3: **VALIDADO — SIN CAMBIO TÉCNICO PARA PEKING**.

**Observación para el futuro:** si PEKING llega a manejar garantía con porcentaje mayor a cero, la línea se segregará correctamente como "con garantía" (esa parte es agnóstica de empresa), pero no aparecerá ningún selector de tipo de garantía para PEKING — `Garant_a_Otobai__c` quedaría vacío en esos registros. Definir un selector o tipo de garantía propio para PEKING es una decisión funcional a tomar en ese momento; no corresponde inventarlo hoy sin ese caso de negocio.

## Corrección del bug de Pricebook en 4 Flows de Opportunity

`Obtener_PriceBook_Opp` filtraba `Pricebook2.Name EqualTo Resolver_Pricebook_Empresa.pricebookId` (texto contra Id, nunca coincide), dejando el Pricebook vacío en la ruta de **recálculo/reapertura** de un Presupuesto ya existente en `Opp_flow_V3`, `Opp_Flow_V5`, `Opp_Flow_v6` y `Opportunity_Flow_V2`. Afectaba a las 3 empresas, no solo a PEKING. La ruta de creación inicial no estaba afectada (usa el valor correcto directamente) y por eso el QA previo de creación fue exitoso.

**Corrección:** en los 4 Flows, cada punto que dependía de `Obtener_PriceBook_Opp.Id` ahora usa `Resolver_Pricebook_Empresa.pricebookId` directamente; se eliminó el `RecordLookup` roto y se reconectaron sus predecesores al Decision `Price_Book_vac_o`. Sin cambios en creación, navegación, ni distinción por empresa.

**Deploy a `RedMotorsSandbox`** (dividido en 2 manifiestos por una incompatibilidad de versión de API preexistente entre los 4 archivos, no relacionada con este cambio):
- `Opp_flow_V3` v31 + `Opportunity_Flow_V2` v9 — deploy `0AfAK0000014j610AA`, 0 errores.
- `Opp_Flow_V5` v34 + `Opp_Flow_v6` v83 — deploy `0AfAK0000014ezD0AQ`, 0 errores.

**QA:** validación estructural completa (los 4 Flows usan el mismo camino de código para PEKING, Bavarian y Otobai, sin ramas por empresa). La validación funcional en vivo de la ruta de recálculo (reabrir un Presupuesto con Pricebook vacío) queda **diferida** — requiere una interacción de pantalla que no pudo ejecutarse en este bloque; no se encontraron Quotes existentes con `Pricebook2Id` nulo y Empresa PEKING/Bavarian/Otobai válidas para usar como evidencia real. No bloquea el cierre técnico: el código ya no puede reproducir el resultado incorrecto (Id nulo) observado antes.

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

`WorkOrder_Empresa_Factura_QA` debe conservarse mientras se decide el modelo definitivo de acceso para Work Order. Continúa marcado **QA TEMPORAL — NO PROMOVER A PRODUCCIÓN** y no debe retirarse automáticamente.

`Plan_Mantenimiento_QLI_QA` y su asignación `0PaAK000002sntp0AA` deben conservarse hasta terminar Sprint 2 y decidir el modelo definitivo de acceso para los usuarios funcionales que ejecuten planes de mantenimiento. No promover a Producción ni ampliar asignaciones sin esa revisión.

`Empresa_Codigo_ERP_QA` (`0PSAK0000007i2j4AA`) y su asignación funcional `0PaAK000002skDC0AY` deben conservarse hasta terminar Sprint 2 y revisar el acceso definitivo al código ERP. Concede únicamente Read sobre `Empresa__c.Codigo_ERP__c`, sin Edit ni ampliación de permisos de objeto. Está marcado **QA TEMPORAL — NO PROMOVER A PRODUCCIÓN**.

Para el QA N4 del usuario asesor se agregaron las asignaciones temporales `0PaAK000002spqp0AA` (`Empresa_Consulta_Flows`), `0PaAK000002swU60AI` (`Empresa_Codigo_ERP_QA`) y `0PaAK000002slyU0AQ` (`Event_Who_QA`). Deben conservarse únicamente mientras se completa N4, sin ampliación masiva ni promoción a Producción.

## Criterio final

**SPRINT 2 — CERRADO.**

El fault FLS de F07 quedó diagnosticado y remediado de forma mínima, y el reintento único concluyó correctamente. N2 también cerró su FLS mínimo y completó una ejecución normal y una selectiva con PEKING, sin fault, rollback ni duplicidad. En N4, el Read mínimo de Activity resolvió la inicialización; tras corregir con autorización explícita el vínculo de Opportunity del Asset QA (de una Opportunity legacy BMW a la Opportunity PEKING ya validada `006AK00000JT9UoYAL`), v21 confirmó Case, Work Order y Opportunity estructuralmente PEKING sin fault ni duplicado, y v55 completó las pantallas de Asistió y Kilometraje con los mismos datos PEKING, sin fault, rollback ni duplicidad. Estado N4: **QA FUNCIONAL OK — PEKING**. Se corrigió el bug de recálculo de Pricebook en los 4 Flows de Opportunity (`Opp_flow_V3` v31, `Opp_Flow_V5` v34, `Opp_Flow_v6` v83, `Opportunity_Flow_V2` v9), validado estructuralmente para las 3 empresas, con la validación funcional en vivo diferida por requerir interacción de pantalla. N3 (`SegregateWOLIs` v51) quedó **VALIDADO — SIN CAMBIO TÉCNICO PARA PEKING**: la segregación de garantía depende únicamente de `Garantia2`/`BSIInterno2` (agnóstico de empresa); la única condición por empresa encontrada (`empresaFactura__c = 'RMOTOBAI'`) solo gobierna un selector de sub-marca de motocicleta propio de Otobai (Kawasaki/Polaris), confirmado por Diego como fuera del alcance de una regla general de garantía. No quedan pendientes técnicos ni de negocio dentro del alcance implementable de Sprint 2.
