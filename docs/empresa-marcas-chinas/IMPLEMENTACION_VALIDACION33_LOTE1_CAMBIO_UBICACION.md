# Validación 33+3 — Lote 1: protección de cambio de ubicación VN

## Alcance

Se revisó `RM_VN_CambiarUbicacion_Ctrl`, componente identificado en el inventario Apex como pendiente por tener resolución interna de empresa con fallback silencioso.

## Comportamiento anterior

El método privado de resolución recibía `Product2.Empresa__c` y aplicaba:

- `OTOBAI` → `RMOTOBAI`;
- cualquier otro valor → `RMBAVARIAN`.

Con la configuración actual de `Product2.Empresa__c`, los valores activos son `RMBAVARIAN`, `RMOTOBAI` y `RMPEKING`. Por tanto:

- `RMOTOBAI` podía caer incorrectamente en `RMBAVARIAN`;
- `RMPEKING` caía incorrectamente en `RMBAVARIAN`;
- empresa nula también caía en `RMBAVARIAN`.

## Cambio aplicado

Se reemplazó la resolución por una tabla explícita:

- `RMOTOBAI` u `OTOBAI` → `RMOTOBAI`;
- `RMBAVARIAN` o `BAVARIAN` → `RMBAVARIAN`;
- `RMPEKING` → error controlado antes de llamar a Softland;
- valor nulo, vacío o desconocido → error controlado.

La decisión técnica evita enviar una transferencia de ubicación a la compañía equivocada. No habilita operativamente PEKING para cambio de ubicación, porque no existe contrato confirmado de bodega/Softland para esa operación.

## Pruebas agregadas

Se mantuvieron las pruebas históricas y se agregaron escenarios para:

- Otobai usa `RMOTOBAI` en el payload del callout;
- PEKING no hace fallback a Bavarian;
- empresa nula no hace fallback a Bavarian.

## Alcance no modificado

No se modificaron:

- endpoints;
- payloads fuera del campo de compañía ya existente;
- bodegas;
- inventario;
- reservas;
- Softland;
- Flows;
- LWC;
- metadata funcional.

## Validación

Primer dry-run enfocado:

- Deploy ID: `0AfAK000000wueY0AQ`;
- componentes: 1/2;
- pruebas ejecutadas: 0;
- resultado: falló por compilación en `RM_VN_CambiarUbicacion_Ctrl_Test`;
- causa: la prueba histórica llamaba `RM_CalloutException.dummy()`, método no disponible en la versión desplegada en Partial.

Corrección aplicada:

- se retiró únicamente el bloque artificial que llamaba `dummy()`;
- no se modificó código productivo por esta falla.

Segundo dry-run enfocado:

- Deploy ID: `0AfAK000000x07F0AQ`;
- componentes: 2/2;
- pruebas: 5/6 aprobadas;
- cobertura temporal: 53/69 líneas en `RM_VN_CambiarUbicacion_Ctrl`;
- resultado: falló únicamente `cambioBodegaPekingNoHaceFallbackBavarianTest`.

Causa:

- `Product2.Empresa__c` tiene `RMPEKING` activo;
- el fixture intentaba asignarlo al producto vehicular creado por la fábrica histórica;
- ese Record Type de producto no permite actualmente el valor PEKING en su matriz de picklist.

Corrección aplicada:

- el escenario PEKING usa un producto no vehicular del fixture, suficiente para validar que el controlador bloquea `RMPEKING` antes de cualquier callout;
- no se modificaron Record Types, picklists ni metadata funcional.

Tercer dry-run enfocado:

- Deploy ID: `0AfAK000000x0C50AI`;
- componentes: 2/2;
- pruebas: 6/6 aprobadas;
- fallas: 0;
- cobertura de `RM_VN_CambiarUbicacion_Ctrl`: 55/69 líneas = 79.71%;
- resultado: validación enfocada aprobada.

Regresión seleccionada:

- Deploy ID: `0AfAK000000wvM60AI`;
- componentes: 2/2;
- pruebas: 77/77 aprobadas;
- fallas: 0;
- cobertura de `RM_VN_CambiarUbicacion_Ctrl`: 55/69 líneas = 79.71%;
- resultado: regresión relacionada aprobada.

Deploy real:

- Deploy ID: `0AfAK000000x0Ll0AI`;
- ambiente: RedMotorsSandbox / Partial;
- componentes: 2/2;
- pruebas: 77/77 aprobadas;
- fallas: 0;
- estado: Succeeded.

Verificación post-deploy:

- Test Run ID: `707AK00000H9YSw`;
- pruebas: 7/7 aprobadas;
- fallas: 0.

Estado: Lote 1 completado, validado y desplegado en RedMotorsSandbox / Partial.
