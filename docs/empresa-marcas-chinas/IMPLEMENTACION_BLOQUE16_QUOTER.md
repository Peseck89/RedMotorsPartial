# Implementación Bloque 16 — Empresa configurable en QuoterController

## Estado

Bloque completado, validado y desplegado en RedMotorsSandbox / Partial.

## Alcance autorizado

El bloque modifica exclusivamente la resolución empresarial y selección de
Pricebook en:

- `QuoterController.createQuote(...)`;
- `QuoterController.addLineItem(...)`.

No cambia regalos, extras, mano de obra, comisiones, cantidades, precios,
cálculos, estructura de Quote ni automatizaciones.

## Comportamiento anterior

Ambos métodos dependían de una constante global con el valor
`Bavarian Dólar`. Toda Opportunity y Quote buscaba PricebookEntry en ese
Pricebook, sin considerar la empresa configurada.

Como resultado, Otobai y PEKING podían utilizar precios Bavarian. En
`createQuote()`, la Opportunity podía cambiar al Pricebook Bavarian y perder
sus líneas antes de detectar una configuración empresarial incorrecta.

## Cambio realizado

- `Opportunity.Empresa_Operadora__c` es la fuente principal.
- El lookup se resuelve mediante `EmpresaResolver` y se utiliza
  `EmpresaContext.codigo`.
- Cuando el lookup está vacío, `BMW_Compania__c` permanece como respaldo
  temporal:
  - Bavarian → `RMBAVARIAN`;
  - Otobai → `RMOTOBAI`.
- El lookup tiene prioridad ante contradicción.
- Los mapeos USD son explícitos:
  - `RMBAVARIAN` → `Bavarian Dólar`;
  - `RMOTOBAI` → `Otobai Dólares`;
  - `RMPEKING` → `PEKING Dólares`.
- No se utiliza `Empresa__c.Name`.
- No existe selección empresarial ni de Pricebook por descarte.
- Empresa nula, inactiva, incompleta o no soportada produce un error
  controlado.
- Se eliminó la dependencia global de `Bavarian Dólar` en las dos rutas.

## Orden de validación y DML

### createQuote

Antes de eliminar OpportunityLineItems o actualizar Opportunity:

1. se valida el producto por bodega;
2. se valida el producto de interés y su Opportunity;
3. se resuelve y valida la empresa;
4. se exige exactamente un Pricebook activo con el nombre empresarial;
5. se exige exactamente una PricebookEntry activa para el producto dentro de
   ese Pricebook.

Solo después se conserva el comportamiento histórico de cambio de Pricebook,
eliminación de líneas, creación de Quote y creación de QuoteLineItem.

### addLineItem

1. se conservan las validaciones históricas de cantidad y precio;
2. se determina el producto;
3. se consulta la Quote y su Opportunity;
4. se resuelve y valida la empresa;
5. se localiza el Pricebook empresarial activo;
6. se comprueba que coincida con el Pricebook efectivo de la Quote;
7. se busca la PricebookEntry exclusivamente dentro de ese Pricebook;
8. se crea la línea sin modificar silenciosamente la Quote.

## Revisión de Test.isRunningTest

Se encontraron siete guards activos y uno comentado.

Se retiraron los siete guards activos porque impedían ejecutar en pruebas la
misma ruta productiva:

1. producto por bodega inexistente en `createQuote`;
2. PricebookEntry inexistente en `createQuote`;
3. DML fallido en `createQuote`;
4. cantidad de mano de obra inválida;
5. precio de mano de obra inválido;
6. producto por bodega inexistente en `addLineItem`;
7. DML fallido en `addLineItem`.

Los dos guards de DML formaban dos usos adicionales de
`Test.isRunningTest`, por lo que el inventario corresponde a siete bloques
activos, no seis. Todos fueron retirados y ahora conservan el mismo error
controlado que producción.

El guard comentado para alias de mano de obra se conservó sin cambios porque
no ejecuta comportamiento.

No se agregó ningún guard nuevo ni lógica especial para pruebas.

## Pruebas

`QuoterControllerTest` dejó de usar `dummy()` como sustituto de cobertura y
ahora contiene escenarios funcionales autocontenidos para:

1. lookup RMBAVARIAN;
2. lookup RMOTOBAI;
3. lookup RMPEKING;
4. precedencia de PEKING sobre Bavarian heredado;
5. respaldo Bavarian;
6. respaldo Otobai;
7. empresa nula sin fallback;
8. empresa inactiva;
9. Pricebook empresarial inexistente;
10. PricebookEntry empresarial inexistente;
11. `addLineItem()` con Quote PEKING y una entrada Bavarian competidora;
12. cambio de Pricebook con OpportunityLineItem existente;
13. regalía/extra con el costo fijo de la PricebookEntry empresarial.

Los escenarios verifican Pricebook de Opportunity y Quote, producto,
PricebookEntry, cantidad, precio, ausencia de selección cruzada y ausencia de
DML parcial cuando falla la configuración.

Los datos no usan `SeeAllData`, IDs reales ni registros operativos.

### Primer dry-run y deuda de cobertura

El dry-run `0AfAK000000vqjR0AQ` aprobó los 11/11 escenarios funcionales, pero
reportó 108/515 líneas cubiertas, equivalentes a 20.971%. La org no fue
modificada.

El análisis del reporte confirmó que 379 de las 515 líneas ejecutables
pertenecían a `dummy()`, un método sin comportamiento funcional compuesto por
concatenaciones vacías. Excluyendo esa deuda, las pruebas cubrían 108 de las
136 líneas funcionales, equivalentes a 79.41%.

Luis autorizó retirar completamente `dummy()` y su comentario asociado. La
eliminación no cambia `createQuote()`, `addLineItem()`,
`resolveCompanyCode()` ni `getActivePricebook()`.

Se agregaron dos regresiones funcionales:

1. cambio desde un Pricebook previo con OpportunityLineItem existente al
   Pricebook USD empresarial, seguido de la creación de Quote y
   QuoteLineItem;
2. creación de una regalía/extra mediante `ProductoXBodega__c`, utilizando
   `Costo_Fijo__c` de la PricebookEntry del Pricebook efectivo de la Quote.

La clase quedó con 13 métodos funcionales.

## Cierre técnico

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
tiene prioridad ante contradicción. Los mapeos son `RMBAVARIAN` →
`Bavarian Dólar`, `RMOTOBAI` → `Otobai Dólares` y `RMPEKING` →
`PEKING Dólares`, sin selección por descarte.

`createQuote()` valida empresa, Pricebook y PricebookEntry antes de eliminar
líneas o actualizar Opportunity. `addLineItem()` valida que el Pricebook
efectivo de la Quote coincida con la empresa.

Se retiraron los siete guards activos de `Test.isRunningTest` y se eliminó
`dummy()` con autorización de Luis. Se validaron 13 pruebas funcionales y 22
pruebas de regresión. El Bloque 16 queda completado, validado y desplegado.

## Riesgos heredados

- El cambio de Pricebook conserva la eliminación histórica de
  OpportunityLineItems, pero solo después de validar toda la configuración.
- Las automatizaciones de Opportunity, Quote y sus líneas pueden agregar
  requisitos o consumo de límites.
- Los nombres fijos de Pricebook permanecen por autorización funcional.
- `dummy()` y su cobertura artificial fueron eliminados con autorización
  expresa.
- No se modificaron comisiones, regalos, extras ni cálculos.

## Manifest

El manifest incluye únicamente:

- `QuoterController`;
- `QuoterControllerTest`.

## Avance técnico estimado

El avance técnico estimado queda en 83% completado y 17% pendiente. Esta
estimación representa alcance técnico, no horas oficiales, trabajadas ni
facturables.
