# Validación 33+3 — Lote 5: solicitud de compra en Quote

## Alcance

Se revisó `ServicioCrearSCQuote`, componente confirmado en el documento original del alcance y utilizado para crear solicitudes de compra desde líneas de cotización.

## Situación encontrada

La versión desplegada en RedMotorsSandbox / Partial difería de la versión local de Git. Antes de modificarla se recuperó la versión vigente de Partial y el cambio se aplicó sobre esa base.

## Comportamiento anterior

La clase resolvía la compañía con una condición binaria:

- `BMW_Compania__c = Bavarian` → `RMBAVARIAN`;
- cualquier otro valor → `RMOTOBAI`.

Ese comportamiento podía enviar a Softland una solicitud de compra con `RMOTOBAI` cuando la empresa era nula, desconocida o correspondía a una compañía no contemplada.

## Cambio aplicado

Se agregó resolución explícita de empresa:

- si `Opportunity.Empresa_Operadora__c` está informado, se resuelve mediante `EmpresaResolver`;
- si el lookup está vacío, `Opportunity.BMW_Compania__c` se mantiene como respaldo temporal;
- `Bavarian` / `RMBAVARIAN` → `RMBAVARIAN`;
- `Otobai` / `RMOTOBAI` → `RMOTOBAI`;
- `RMPEKING` se reconoce explícitamente, pero se detiene antes del callout porque no existe contrato confirmado de Softland para crear solicitudes de compra de Quote;
- empresa nula o no soportada produce error controlado y no cae por descarte en Otobai.

## Alcance no modificado

No se modificaron:

- endpoint de Softland;
- payload fuera del valor de compañía;
- bodegas;
- sucursales;
- Service Territory;
- anticipos;
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

- Deploy ID: `0AfAK000000x2CH0AY`;
- componentes: 2/2;
- pruebas: 17/17 aprobadas;
- fallas: 0;
- cobertura de `ServicioCrearSCQuote`: 125/134 líneas = 93.28%;
- resultado: validación enfocada aprobada.

Regresión relacionada:

- Deploy ID: `0AfAK000000x2KL0AY`;
- componentes: 2/2;
- pruebas: 76/76 aprobadas;
- fallas: 0;
- cobertura de `ServicioCrearSCQuote`: 125/134 líneas = 93.28%;
- resultado: regresión relacionada aprobada.

Deploy real:

- Deploy ID: `0AfAK000000x2PB0AY`;
- ambiente: RedMotorsSandbox / Partial;
- componentes: 2/2;
- pruebas: 76/76 aprobadas;
- fallas: 0;
- estado: Succeeded.

Verificación post-deploy:

- Test Run ID: `707AK00000H9lER`;
- prueba ejecutada: `ServicioCrearSCQuoteTest`;
- resultado: 18/18 pruebas aprobadas;
- fallas: 0.

Estado: lote completado, validado y desplegado en RedMotorsSandbox / Partial.
