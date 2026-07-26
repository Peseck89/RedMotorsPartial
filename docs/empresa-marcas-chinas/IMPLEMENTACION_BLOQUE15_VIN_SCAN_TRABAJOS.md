# Implementación Bloque 15 — Empresa configurable en trabajos de VIN Scan

## Estado

Bloque completado, validado y desplegado en RedMotorsSandbox / Partial.

## Alcance autorizado

El bloque modifica exclusivamente la resolución empresarial de:

- `BMWVinScanTrabajoGenerator.createTrabajosFromVinScan(...)`;
- `BMWVinScanTrabajoGenerator.createSubtrabajosFromVinScan(...)`.

No cambia el procesamiento del VIN Scan, deduplicación, UTS, productos,
PricebookEntry, jerarquía padre/hijo, correos ni automatizaciones.

## Comportamiento anterior

Ambos recorridos consultaban únicamente `WorkOrder.empresaFactura__c` y
utilizaban directamente su valor para localizar la configuración en
`TipoDeCargoConManoDeObra__c`.

El lookup `WorkOrder.empresaFacturaCP__c` no se consultaba. Por ello no podía
tener prioridad ante una contradicción y PEKING solo podía operar mediante el
campo heredado.

Además, la empresa se determinaba después de preparar o crear registros
intermedios. Una configuración empresarial inválida podía detectarse después
de iniciar el procesamiento.

## Cambio realizado

- Las dos consultas de WorkOrder incluyen `empresaFacturaCP__c`.
- Cuando el lookup está informado, se resuelve mediante `EmpresaResolver` y
  se utiliza `EmpresaContext.codigo`.
- Cuando está vacío, `empresaFactura__c` permanece como respaldo temporal.
- Si ambos campos están informados, gana el lookup.
- Solo se admiten `RMBAVARIAN`, `RMOTOBAI` y `RMPEKING`.
- Una empresa nula, inactiva, incompleta o con código no soportado genera
  `EmpresaConfigurationException`.
- No se utiliza `Empresa__c.Name`.
- No existe selección empresarial por descarte.
- La resolución ocurre después de consultar el WorkOrder y antes de crear
  tipos de trabajo, trabajos, subtrabajos o WorkOrderLineItems.

La consulta posterior de `TipoDeCargoConManoDeObra__c` conserva su estructura
y utiliza el código empresarial ya validado.

## Pruebas

Se conservaron todas las pruebas históricas y se agregaron escenarios
independientes para los dos recorridos:

1. lookup RMBAVARIAN;
2. lookup RMOTOBAI;
3. lookup RMPEKING;
4. precedencia del lookup sobre un picklist contradictorio;
5. respaldo heredado RMBAVARIAN;
6. respaldo heredado RMOTOBAI;
7. respaldo heredado RMPEKING;
8. Empresa inactiva;
9. código de lookup no soportado;
10. lookup y respaldo vacíos;
11. ausencia de fallback y de registros parciales.

Los escenarios exitosos verifican:

- WorkOrder correcto;
- producto de mano de obra correspondiente a la empresa efectiva;
- PricebookEntry perteneciente al Pricebook efectivo del WorkOrder;
- conversión de 24 UTS a una cantidad de 2 horas;
- vínculo del subtrabajo con el WorkOrderLineItem;
- relación con el padre en el recorrido de subtrabajos.

Los escenarios de error confirman la excepción controlada y que no se crean
tipos de trabajo, WorkOrderLineItems ni subtrabajos parciales.

Los datos son autocontenidos, utilizan los Pricebooks locales autorizados y
no dependen de registros operativos, IDs reales ni `SeeAllData`. Se conservan
los mocks históricos para automatizaciones indirectas.

## Riesgos heredados

- La configuración de mano de obra continúa dependiendo de empresa, tipo de
  cargo y tipo de vehículo.
- El PricebookEntry debe coincidir con el Pricebook efectivo del WorkOrder.
- Las automatizaciones indirectas de WorkOrderLineItem pueden afectar límites
  o requerir los mocks existentes.
- La clase conserva consultas y DML históricos que no forman parte del
  alcance de este bloque.
- La disponibilidad operativa de PEKING requiere configuraciones y entradas
  de productos válidas; este bloque no crea datos operativos.

## Manifest

El manifest incluye únicamente:

- `BMWVinScanTrabajoGenerator`;
- `BMWVinScanTrabajoGeneratorTest`.

## Primer dry-run

El dry-run `0AfAK000000vqTJ0AY` compiló correctamente los 2/2 componentes,
aprobó 30/42 pruebas y falló en las doce rutas empresariales exitosas: seis
de creación de trabajos y seis de creación de subtrabajos. La org no fue
modificada.

Las fallas llegaron a los lanzamientos directos de `AuraHandledException`
que protegen la ausencia de PricebookEntry compatible. No existe un `catch`
final en esas ubicaciones y el controlador no fue modificado durante el
diagnóstico.

La consulta productiva utiliza exclusivamente:

- `Pricebook2Id = WorkOrder.Pricebook2Id`;
- `Product2Id` incluido en el conjunto de productos de mano de obra.

No filtra por moneda, estado activo ni precio. Sin embargo, la combinación
Pricebook2Id + Product2Id no coincidía en los fixtures.

Los escenarios creaban la entrada en `Bavarian Local`, `Otobai Local` o
`PEKING Local`, pero actualizaban el WorkOrder sin fijar
`CurrencyIsoCode`. Salesforce conservaba USD y `WorkOrderTrigger` seleccionaba
el Pricebook en dólares de la empresa. El generador consultaba ese Pricebook
efectivo y no encontraba la entrada creada en el Pricebook local.

Se corrigieron únicamente los datos de prueba:

- se fija CRC en el WorkOrder;
- se vuelve a consultar el WorkOrder después del trigger;
- se comprueba que el Pricebook efectivo sea el Pricebook local exacto;
- se crea o reutiliza una entrada estándar CRC para el producto;
- se crea la PricebookEntry de la mano de obra en el Pricebook efectivo y en
  CRC;
- se verifican Product2Id, Pricebook2Id, moneda, estado activo y precio antes
  de ejecutar el generador.

Los recorridos de trabajos y subtrabajos continúan usando el mismo producto
de mano de obra configurado para la empresa efectiva. Se conservaron los 42
métodos, mocks y fixtures históricos. `BMWVinScanTrabajoGenerator` no fue
modificado como parte de esta corrección.

## Validación final y deploy

| Etapa | Deploy ID | Componentes | Pruebas | Fallas | Resultado |
|---|---|---:|---:|---:|---|
| Primer dry-run | `0AfAK000000vqTJ0AY` | 2/2 | 30/42 | 12 | Fallido |
| Dry-run funcional | `0AfAK000000vqY90AI` | 2/2 | 42/42 | 0 | Exitoso |
| Dry-run de regresión | `0AfAK000000vqZl0AI` | 2/2 | 93/93 | 0 | Exitoso |
| Deploy real | `0AfAK000000vqeb0AA` | 2/2 | 93/93 | 0 | Exitoso |

El dry-run funcional confirmó 569/656 líneas cubiertas en
`BMWVinScanTrabajoGenerator`, equivalentes a 86.74%.

El deploy real terminó correctamente en RedMotorsSandbox / Partial. Quedaron
validados:

- `empresaFacturaCP__c` como fuente principal en trabajos y subtrabajos;
- `empresaFactura__c` como respaldo temporal;
- soporte explícito para `RMBAVARIAN`, `RMOTOBAI` y `RMPEKING`;
- ausencia de selección empresarial por descarte;
- resolución empresarial antes de crear registros;
- conservación del procesamiento VIN Scan, deduplicación, UTS, productos,
  PricebookEntry, jerarquías padre/hijo y correos.

Se aprobaron 42 pruebas funcionales y 93 pruebas de regresión sin fallas. El
Bloque 15 queda completado, validado y desplegado.

## Avance técnico estimado

El avance técnico estimado queda en 82% completado y 18% pendiente. Esta
estimación representa alcance técnico, no horas oficiales, trabajadas ni
facturables.
