# Validación 33+3 — Lote 3: eliminación de reserva de artículos en Quote

## Alcance

Se revisó `ServicioEliminarReservaArticuloQuote`, componente confirmado en el documento original del alcance y utilizado desde `QuoliGridController.eliminarReservaArticulos()`.

## Situación encontrada

La versión desplegada en RedMotorsSandbox / Partial difería de la versión local de Git. Antes de modificarla se recuperó la versión vigente de Partial y se aplicó el cambio sobre esa base.

## Comportamiento anterior

La clase resolvía la compañía con una condición binaria:

- `BMW_Compania__c = Bavarian` → `RMBAVARIAN`;
- cualquier otro valor → `RMOTOBAI`.

Ese comportamiento podía enviar a Softland una eliminación de reserva con `RMOTOBAI` cuando la empresa era nula, desconocida o correspondía a una compañía no contemplada.

## Cambio aplicado

Se agregó resolución explícita de empresa:

- si `Opportunity.Empresa_Operadora__c` está informado, se resuelve mediante `EmpresaResolver`;
- si el lookup está vacío, `Opportunity.BMW_Compania__c` se mantiene como respaldo temporal;
- `Bavarian` / `RMBAVARIAN` → `RMBAVARIAN`;
- `Otobai` / `RMOTOBAI` → `RMOTOBAI`;
- `RMPEKING` se reconoce explícitamente, pero se detiene antes del callout porque no existe contrato confirmado de bodega/Softland para esta operación;
- empresa nula o no soportada produce error controlado y no cae por descarte en Otobai.

## Alcance no modificado

No se modificaron:

- endpoint de Softland;
- payload fuera del valor de compañía;
- bodegas;
- sucursales;
- Service Territory;
- reservas operativas;
- inventario;
- Flows;
- LWC.

## Pruebas

Se conservaron las pruebas históricas y se agregaron escenarios para:

- `RMPEKING` mediante lookup no cae a Otobai y se detiene antes del callout;
- empresa nula no cae a Otobai;
- empresa no soportada mediante lookup no cae a Otobai;
- Otobai heredado conserva el comportamiento existente.

## Estado

Dry-run enfocado:

- Deploy ID: `0AfAK000000x1T70AI`;
- componentes: 2/2;
- pruebas: 5/5 aprobadas;
- fallas: 0;
- cobertura de `ServicioEliminarReservaArticuloQuote`: 122/140 líneas = 87.14%;
- resultado: validación enfocada aprobada.

Regresión relacionada:

- Deploy ID: `0AfAK000000x1ZZ0AY`;
- componentes: 2/2;
- pruebas: 34/34 aprobadas;
- fallas: 0;
- cobertura de `ServicioEliminarReservaArticuloQuote`: 122/140 líneas = 87.14%;
- resultado: regresión relacionada aprobada.

Deploy real:

- Deploy ID: `0AfAK000000wxqx0AA`;
- ambiente: RedMotorsSandbox / Partial;
- componentes: 2/2;
- pruebas: 34/34 aprobadas;
- fallas: 0;
- estado: Succeeded.

Verificación post-deploy:

- Test Run ID: `707AK00000H9CIw`;
- prueba ejecutada: `ServicioEliminarReservaArticuloQuoteTest`;
- resultado: 6/6 pruebas aprobadas;
- fallas: 0.

Estado: lote completado, validado y desplegado en RedMotorsSandbox / Partial.
