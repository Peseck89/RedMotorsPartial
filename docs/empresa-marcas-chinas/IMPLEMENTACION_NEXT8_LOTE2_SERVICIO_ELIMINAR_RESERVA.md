# Next8 — Lote 2: eliminación de reserva de vehículo

## Alcance

Componentes revisados:

- `servicioEliminarReserva`;
- `servicioEliminarReservaTest`;
- `servicioEliminarReservaMock`.

## Situación encontrada

La versión local de prueba y mock difería de la versión vigente en
RedMotorsSandbox / Partial. Antes de aplicar cambios se recuperó la versión
desplegada para preservar el comportamiento operativo existente.

## Comportamiento anterior

La compañía para eliminar reserva se tomaba de `Product2.Empresa__c`:

- `Bavarian` se convertía a `RMBAVARIAN`;
- solo `RMBAVARIAN` continuaba hacia Softland;
- `Otobai`, `RMOTOBAI`, `RMPEKING`, empresa nula o empresa no soportada no
  tenían una respuesta explícita;
- la solicitud de token ocurría antes de validar la empresa;
- existía un bypass `Test.isRunningTest()` para simular el token en pruebas.

## Cambio aplicado

Se centralizó la resolución de `Product2.Empresa__c`:

- `Bavarian` / `RMBAVARIAN` conservan `RMBAVARIAN`;
- `Otobai` / `RMOTOBAI` se reconocen explícitamente, pero se detienen antes del
  callout porque no existe contrato confirmado de eliminación de reserva
  Softland para Otobai en esta clase;
- `RMPEKING` se reconoce explícitamente, pero se detiene antes del callout
  porque no existe contrato confirmado de eliminación de reserva Softland para
  PEKING;
- empresa nula o no soportada produce error controlado;
- no existe selección por descarte hacia Bavarian u Otobai;
- la validación de empresa ocurre antes de solicitar token;
- se retiró el bypass `Test.isRunningTest()` para probar la ruta real mediante
  mock HTTP.

## Alcance no modificado

No se modificaron:

- endpoints;
- credenciales;
- payload fuera de `compania`;
- VIN;
- Opportunity;
- Product2;
- reservas operativas;
- inventario;
- Flows;
- LWC.

## Pruebas

Se actualizaron pruebas para cubrir:

- eliminación de reserva Bavarian;
- Otobai detenido antes del callout;
- PEKING detenido antes del callout;
- empresa nula sin fallback.

## Estado

Completado, validado y desplegado en RedMotorsSandbox / Partial.

## Validación

- Dry-run enfocado `0AfAK000000x4Vp0AI`: 3/3 componentes, 4/4 pruebas,
  0 fallas. Cobertura de `servicioEliminarReserva`: 48/51 = 94.12%.
- Regresión relacionada `0AfAK000000x4af0AA`: 3/3 componentes, 17/17 pruebas,
  0 fallas.
- Deploy real `0AfAK000000x4ij0AA`: 3/3 componentes, 17/17 pruebas, 0 fallas,
  estado Succeeded.
- Verificación post-deploy `707AK00000HA7uX`: 4/4 pruebas, 0 fallas.
