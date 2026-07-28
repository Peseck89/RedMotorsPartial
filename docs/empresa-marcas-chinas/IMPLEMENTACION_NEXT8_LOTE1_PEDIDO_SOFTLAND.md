# Next8 — Lote 1: pedido Softland de Quote

## Alcance

Componentes revisados:

- `QuoteSoftlandPedidoService`;
- `QuoteSoftlandQueryService`;
- `TestServiciosQuote`.

## Situación encontrada

La versión local de Git difería de la versión vigente en RedMotorsSandbox / Partial. Antes de aplicar cambios se recuperó la versión desplegada para evitar reintroducir deuda local y preservar el comportamiento operativo existente.

## Comportamiento anterior

La compañía se resolvía con una condición binaria:

- `BMW_Compania__c = Bavarian` enviaba `RMBAVARIAN`;
- cualquier otro valor enviaba `RMOTOBAI`.

Ese comportamiento podía enviar pedidos de Quote bajo una compañía incorrecta si la empresa era nula, desconocida o PEKING.

## Cambio aplicado

Se agregó `Opportunity.Empresa_Operadora__c` al SOQL de `QuoteSoftlandQueryService`.

En `QuoteSoftlandPedidoService`:

- `Opportunity.Empresa_Operadora__c` queda como fuente principal;
- si el lookup está vacío, `Opportunity.BMW_Compania__c` se mantiene como respaldo temporal;
- la empresa se resuelve mediante `EmpresaResolver`;
- el valor enviado en `payload.compania` proviene de `EmpresaContext.Codigo_ERP__c`;
- se admiten explícitamente `RMBAVARIAN`, `RMOTOBAI` y `RMPEKING`;
- empresa nula o no soportada produce error controlado antes de consultar Softland;
- no existe selección por descarte hacia Bavarian u Otobai.

## Alcance no modificado

No se modificaron:

- endpoints;
- credenciales;
- contrato de payload fuera del campo `compania`;
- bodegas;
- sucursales;
- reservas;
- anticipos;
- inventario;
- Flows;
- LWC.

## Pruebas

Se actualizaron pruebas para cubrir:

- respaldo heredado Bavarian;
- respaldo heredado Otobai;
- lookup PEKING con prioridad sobre el valor heredado;
- empresa nula sin fallback;
- empresa no soportada sin fallback.

## Estado

Completado, validado y desplegado en RedMotorsSandbox / Partial.

## Validación

- Primer dry-run enfocado `0AfAK000000x3WY0AY`: 3/3 componentes compilados,
  7/11 pruebas aprobadas. Las cuatro pruebas nuevas fallaron por datos de
  fixture incompletos ante automatizaciones de Account; la org no fue
  modificada.
- Segundo dry-run enfocado `0AfAK000000x3hp0AA`: 3/3 componentes compilados,
  7/11 pruebas aprobadas. Las cuatro pruebas nuevas fallaron por duplicidad de
  `PricebookEntry` estándar en el fixture; la org no fue modificada.
- Dry-run enfocado final `0AfAK000000x3mf0AA`: 3/3 componentes, 11/11 pruebas,
  0 fallas. Cobertura: `QuoteSoftlandPedidoService` 105/117 = 89.74% y
  `QuoteSoftlandQueryService` 7/7 = 100%.
- Regresión relacionada `0AfAK000000x3zZ0AQ`: 3/3 componentes, 12/12 pruebas,
  0 fallas.
- Deploy real `0AfAK000000x2qd0AA`: 3/3 componentes, 12/12 pruebas, 0 fallas,
  estado Succeeded.
- Verificación post-deploy `707AK00000H9tYa`: 12/12 pruebas, 0 fallas.

## Correcciones de fixture

- Se declararon explícitamente los valores requeridos por automatizaciones de
  Account para condición de pago, categoría de cliente e impuesto.
- Se ajustó la creación de `PricebookEntry` para reutilizar la entrada estándar
  existente del producto cuando ya fue creada dentro de la prueba.
