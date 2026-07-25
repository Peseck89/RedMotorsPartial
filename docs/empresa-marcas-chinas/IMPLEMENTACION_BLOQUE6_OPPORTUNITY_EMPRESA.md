# Implementación del Bloque 6 — Empresa en Opportunity

## Objetivo

Iniciar la transición de Opportunity hacia el modelo configurable
`Empresa__c` mediante un lookup opcional y adoptar ese lookup en la consulta
de disponibilidad de productos de `ProductControllerTwo`.

## Autorización y checkpoint

La decisión se basa en la sesión con Diego en la que se indicó que los
objetos con empresa representada mediante picklist deben incorporar un lookup
hacia `Empresa__c`, conservando temporalmente la lógica heredada.

Se envió a Luis un mensaje informativo sobre el inicio de este bloque.

Checkpoint protegido:

- referencia: `b427ab6`;
- backup: `backup/pc/redmotors-sprint1-before-opportunity-20260725`.

## Metadata creada

Se creó `Opportunity.Empresa_Operadora__c` con la siguiente configuración:

| Propiedad | Valor |
|---|---|
| Label | Empresa Operadora |
| Tipo | Lookup |
| Referencia | `Empresa__c` |
| Requerido | No |
| Comportamiento al eliminar | SetNull |
| Relationship name | `Opportunities_Empresa_Operadora` |
| Relationship label | Oportunidades |

`Opportunity.BMW_Compania__c` no fue modificado.

## Comportamiento anterior

`ProductControllerTwo.getAvailabilityByQuote()` obtenía exclusivamente
`Opportunity.BMW_Compania__c`:

- `Bavarian` se transformaba en `RMBAVARIAN`;
- `Otobai` se transformaba en `RMOTOBAI`;
- un valor desconocido se conservaba sin cambios;
- un valor nulo permanecía nulo.

El valor resultante se entregaba a `HttpCalloutGetProductAvailability`. No
existía selección por descarte.

## Cambio implementado

`Empresa_Operadora__c` es ahora la fuente principal:

1. Si el lookup está informado, `EmpresaResolver` resuelve el registro y se
   utiliza `Empresa__c.Codigo__c`.
2. Si el lookup está vacío, se conserva temporalmente el mapeo del picklist:
   - `Bavarian` → `RMBAVARIAN`;
   - `Otobai` → `RMOTOBAI`.
3. Si lookup y picklist se contradicen, gana el lookup.
4. PEKING no se agregó al picklist heredado.
5. Los valores heredados nulos o desconocidos conservan exactamente la
   conducta anterior.

No se modificó el contrato ni el flujo de la integración.

## Pruebas

Se agregaron escenarios independientes para:

- lookup `RMBAVARIAN`;
- lookup `RMOTOBAI`;
- lookup `RMPEKING`;
- precedencia del lookup sobre un picklist contradictorio;
- compatibilidad heredada con Bavarian;
- compatibilidad heredada con Otobai;
- ausencia de fallback ante un valor desconocido;
- conservación del valor nulo.

Los escenarios de lookup crean sus propios registros de `Empresa__c`,
Opportunity, Quote y Pricebook. No usan `SeeAllData` ni datos reales.

El picklist restringido impide persistir un valor desconocido nuevo. Por esa
razón, la conservación de ese comportamiento se valida directamente sobre el
helper de resolución.

## Componentes no modificados

- flows;
- Quote;
- Product2;
- `Plantilla_de_Presupuesto__c`;
- reservas;
- servicios Softland;
- `ServicioConsDispBodegaQuoli`;
- Permission Sets.

## Pendientes y riesgos

- asignar permisos sobre `Opportunity.Empresa_Operadora__c`;
- crear y validar los registros operativos de Empresa;
- definir y ejecutar la migración de Opportunities históricas;
- revisar los flows que continúan escribiendo únicamente
  `BMW_Compania__c`;
- confirmar cuándo debe retirarse la compatibilidad heredada;
- validar el soporte operativo de `RMPEKING` en la integración de
  disponibilidad.

La adopción operativa del lookup no debe iniciarse hasta contar con registros
de Empresa completos y permisos autorizados.

## Estado

### Primer dry-run

| Dato | Resultado |
|---|---|
| Deploy ID | `0AfAK000000vog10AA` |
| Componentes compilados | 3/3 |
| Pruebas aprobadas | 8/9 |
| Pruebas fallidas | 1/9 |
| Cobertura temporal de `ProductControllerTwo` | 2.874% |
| Modificación de la org | Ninguna |

La única falla ocurrió en la prueba histórica
`ProductControllerTwoTest.ProductControllerTwoTest`, antes de alcanzar las
llamadas al controlador. El método insertaba dos productos con
`Codigo_de_Producto__c = '0012'`; la segunda inserción fue rechazada por la
validación de unicidad.

No intervienen `@testSetup`, factories ni productos creados por otro helper
en este escenario. La duplicidad se originaba dentro del mismo método.

La corrección asigna códigos propios y deterministas:

- producto de materiales: `PCT2-MAT-0012`;
- producto de mano de obra: `PCT2-MO-0012`.

También se diferenciaron sus valores de `ProductCode`. No se desactivó ni
alteró la validación.

La cobertura de 2.874% no es definitiva porque la prueba histórica terminó
durante la preparación de datos. Al superar esa inserción, la prueba vuelve a
ejecutar:

- `getAvailabilityByQuote`;
- `searchProductxBodegaxQuote`;
- `getQolis`;
- `getMOAccess`;
- `deleteQlis`;
- `dummy`.

No se agregaron pruebas nuevas únicamente para elevar cobertura.

### Validación final y deploy real

Registro del 25/07/2026 a las 2:19 p. m., zona horaria UTC−06:00, en
RedMotorsSandbox / Partial:

| Validación | Deploy ID | Estado | Componentes | Pruebas | Fallas |
|---|---|---|---:|---:|---:|
| Dry-run final | `0AfAK000000vojF0AQ` | Succeeded | 3/3 | 9/9 | 0 |
| Deploy real | `0AfAK000000vokr0AA` | Succeeded | 3/3 | 9/9 | 0 |

Cobertura confirmada de `ProductControllerTwo`:

- líneas cubiertas: 766/870;
- porcentaje: 88.046%.

Componentes desplegados:

- `Opportunity.Empresa_Operadora__c`;
- `ProductControllerTwo`;
- `ProductControllerTwoTest`.

El lookup opcional `Empresa_Operadora__c` hacia `Empresa__c` queda como fuente
principal. `BMW_Compania__c` permanece como compatibilidad temporal y el
lookup tiene prioridad cuando ambos campos contienen valor.

Comportamiento validado:

- Bavarian conserva el código `RMBAVARIAN`;
- Otobai conserva el código `RMOTOBAI`;
- `RMPEKING` funciona mediante el lookup;
- los valores nulos o desconocidos conservan el comportamiento anterior.

No se modificaron flows, reservas, servicios Softland, Quote, Product2 ni
plantillas. Continúan pendientes los permisos, la creación de registros
operativos de Empresa y la migración histórica.

El Bloque 6 queda completado, validado y desplegado. El checkpoint remoto del
bloque es `b427ab6`.

Avance técnico estimado del Sprint 1:

- completado: 69%;
- pendiente: 31%.

Este porcentaje corresponde al alcance técnico. No representa horas
oficiales, trabajadas, registradas ni facturables.
