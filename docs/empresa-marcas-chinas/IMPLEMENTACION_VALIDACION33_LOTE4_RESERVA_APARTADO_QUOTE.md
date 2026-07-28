# Validación 33+3 — Lote 4: reserva y apartado de artículos en Quote

## Alcance

Se revisó `ServicioReservaApartadoArticulosQuote`, componente confirmado en el documento original del alcance y utilizado desde `QuoliGridController.requestDespacho()` y `QuoliGridController.requestApartar()`.

## Situación encontrada

La versión desplegada en RedMotorsSandbox / Partial difería de la versión local de Git. Antes de modificarla se recuperó la versión vigente de Partial y se aplicó el cambio sobre esa base.

## Comportamiento anterior

La clase resolvía la compañía con una condición binaria:

- `BMW_Compania__c = Bavarian` → `RMBAVARIAN`;
- cualquier otro valor → `RMOTOBAI`.

Ese comportamiento podía enviar a Softland una reserva o apartado con `RMOTOBAI` cuando la empresa era nula, desconocida o correspondía a una compañía no contemplada.

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

Se conservó la prueba histórica y se agregaron escenarios para:

- `RMPEKING` mediante lookup no cae a Otobai y se detiene antes del callout;
- empresa nula no cae a Otobai;
- empresa no soportada mediante lookup no cae a Otobai.

## Estado

Dry-run enfocado:

- Deploy ID: `0AfAK000000wxhH0AQ`;
- componentes: 2/2;
- pruebas: 4/4 aprobadas;
- fallas: 0;
- cobertura de `ServicioReservaApartadoArticulosQuote`: 118/143 líneas = 82.52%;
- resultado: validación enfocada aprobada.

Regresión relacionada:

- Deploy ID: `0AfAK000000x1ph0AA`;
- componentes: 2/2;
- pruebas: 37/37 aprobadas;
- fallas: 0;
- cobertura de `ServicioReservaApartadoArticulosQuote`: 118/143 líneas = 82.52%;
- resultado: regresión relacionada aprobada.

Deploy real:

- Deploy ID: `0AfAK000000x0gk0AA`;
- ambiente: RedMotorsSandbox / Partial;
- componentes: 2/2;
- pruebas: 37/37 aprobadas;
- fallas: 0;
- estado: Succeeded.

Verificación post-deploy:

- Test Run ID: `707AK00000H9jrT`;
- prueba ejecutada: `SRAArticulosQuoteTest`;
- resultado: 5/5 pruebas aprobadas;
- fallas: 0.

Estado: lote completado, validado y desplegado en RedMotorsSandbox / Partial.
