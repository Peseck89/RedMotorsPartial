# Cierre funcional Sprint 2 posterior a respuesta de Luis

**Fecha:** 13 de agosto de 2026

**Ambiente:** RedMotors Sandbox Partial
**Resultado:** **C. SPRINT 2 NO CERRABLE — F07 presenta un fallo funcional reproducido y aún no diagnosticado de forma concluyente**

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

### QA ejecutado una sola vez

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

No existen Validation Rules activas sobre `Plan_de_mantenimiento__c` ni `QuoteLineItem`. La evidencia preservada no permite distinguir de forma concluyente si el fault ocurrió en `crearPlanMantenimiento` o en `Copy_1_of_CreateQuoteLineItem`; no había registro de depuración previo y el evento técnico detallado no quedó disponible para consulta posterior.

Estado F07: **QA FUNCIONAL ERROR — FAULT DE PERSISTENCIA PENDIENTE DE DIAGNÓSTICO CON EVIDENCIA TÉCNICA**.

No se repitió la entrevista y no se aplicó una corrección especulativa.

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

Los dos Flows ya conservan la resolución técnica dinámica por Empresa. No se ejecutaron las entrevistas N2 porque el fault de F07 activó el criterio de parada antes de continuar.

Estado N2: **DATASET PROVISIONAL LISTO — QA FUNCIONAL NO EJECUTADO POR PARADA F07**.

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

Estado N4: **VALIDACIÓN TÉCNICA OK — CONFIGURACIÓN PROVISIONAL DESPLEGADA — QA FUNCIONAL NO EJECUTADO POR PARADA F07**.

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

`WorkOrder_Empresa_Factura_QA` debe conservarse. N2 no fue ejecutado y el acceso sigue siendo necesario para completar sus pruebas. Continúa marcado **QA TEMPORAL — NO PROMOVER A PRODUCCIÓN** y no debe retirarse automáticamente.

## Criterio final

**C. SPRINT 2 NO CERRABLE — queda trabajo técnico desbloqueado.**

El bloqueo inmediato es el fault de persistencia de F07. Antes de repetir la prueba se debe capturar evidencia técnica del fault —mediante registro de depuración dirigido o la notificación completa de Salesforce— y determinar el nodo exacto. N2 y N4 permanecen listos para QA, pero no deben ejecutarse hasta cerrar ese diagnóstico. N3 continúa siendo una confirmación externa de Diego y no debe convertirse en regla definitiva.
