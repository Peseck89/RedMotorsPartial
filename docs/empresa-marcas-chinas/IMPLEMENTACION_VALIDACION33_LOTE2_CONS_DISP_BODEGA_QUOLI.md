# Validación 33+3 — Lote 2: consulta de disponibilidad de bodega en Quote

## Alcance

Se revisó `ServicioConsDispBodegaQuoli`, componente confirmado en el documento original del alcance y utilizado desde `QuoliGridController.consultarDisponibilidad()`.

## Situación encontrada

La versión desplegada en RedMotorsSandbox / Partial difería de la versión local de Git. Antes de modificarla se recuperó la versión vigente de Partial y se aplicó el cambio sobre esa base para no sobrescribir ajustes operativos existentes.

## Comportamiento anterior

La clase resolvía la compañía con una condición binaria:

- `BMW_Compania__c = Bavarian` → `RMBAVARIAN`;
- cualquier otro valor → `RMOTOBAI`.

Ese comportamiento podía enviar a Softland una consulta de disponibilidad con `RMOTOBAI` cuando la empresa era nula, desconocida o correspondía a una compañía no contemplada.

## Cambio aplicado

Se agregó resolución explícita de empresa:

- si `Opportunity.Empresa_Operadora__c` está informado, se resuelve mediante `EmpresaResolver`;
- si el lookup está vacío, `Opportunity.BMW_Compania__c` se mantiene como respaldo temporal;
- `Bavarian` / `RMBAVARIAN` → `RMBAVARIAN`;
- `Otobai` / `RMOTOBAI` → `RMOTOBAI`;
- `RMPEKING` se reconoce explícitamente, pero se detiene antes del callout porque no existe contrato confirmado de bodega/Softland para esta operación;
- empresa nula o desconocida produce error controlado y no cae por descarte en Otobai.

## Alcance no modificado

No se modificaron:

- endpoint de Softland;
- payload fuera del valor de compañía;
- bodegas;
- sucursales;
- Service Territory;
- reservas;
- inventario;
- Flows;
- LWC.

## Pruebas

Se conservaron las pruebas históricas y se agregaron escenarios para:

- `RMPEKING` mediante lookup no cae a Otobai y se detiene antes del callout;
- empresa nula no cae a Otobai;
- Otobai heredado conserva el comportamiento existente.

## Estado

Primer dry-run enfocado:

- Deploy ID: `0AfAK000000x1050AA`;
- componentes: 2/2;
- pruebas: 3/4 aprobadas;
- falla: la prueba histórica no fijaba explícitamente `BMW_Compania__c = Bavarian` y el nuevo control la bloqueó antes de caer por descarte en Otobai;
- org sin modificaciones.

Corrección aplicada:

- se ajustó únicamente el fixture histórico para declarar `Bavarian` de forma explícita;
- no se modificó el comportamiento productivo por esta falla.

Segundo dry-run enfocado:

- Deploy ID: `0AfAK000000x1890AA`;
- componentes: 2/2;
- pruebas: 4/4 aprobadas;
- fallas: 0;
- cobertura de `ServicioConsDispBodegaQuoli`: 153/195 líneas = 78.46%;
- resultado: validación enfocada aprobada.

Regresión relacionada:

- Deploy ID: `0AfAK000000x1Eb0AI`;
- componentes: 2/2;
- pruebas: 31/31 aprobadas;
- fallas: 0;
- cobertura de `ServicioConsDispBodegaQuoli`: 153/195 líneas = 78.46%;
- resultado: regresión relacionada aprobada.

Deploy real:

- Deploy ID: `0AfAK000000x1Hp0AI`;
- ambiente: RedMotorsSandbox / Partial;
- componentes: 2/2;
- pruebas: 31/31 aprobadas;
- fallas: 0;
- estado: Succeeded.

Verificación post-deploy:

- Test Run ID: `707AK00000H9Xcl`;
- prueba ejecutada: `ServicioConsDispBodegaQuoliTest`;
- resultado: 5/5 pruebas aprobadas;
- fallas: 0.

Estado: lote completado, validado y desplegado en RedMotorsSandbox / Partial.
