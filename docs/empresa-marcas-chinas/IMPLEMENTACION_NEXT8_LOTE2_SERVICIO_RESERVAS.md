# Next8 — Lote 2: reserva de vehículo

## Alcance

Componentes revisados:

- `servicioReservas`;
- `servicioReservasTest`;
- `servicioReservasMock`.

## Situación encontrada

La versión local de prueba y mock difería de la versión vigente en
RedMotorsSandbox / Partial. Antes de aplicar cambios se recuperó la versión
desplegada para preservar el comportamiento operativo existente.

## Comportamiento anterior

La compañía de la reserva se tomaba de `Product2.Empresa__c`:

- `Bavarian` se convertía a `RMBAVARIAN`;
- `Otobai` se convertía a `RMOTOBAI`;
- solo `RMBAVARIAN` y `RMOTOBAI` continuaban hacia Softland;
- `RMPEKING`, empresa nula o empresa no soportada quedaban como empresa no
  válida, pero el token ya podía haberse solicitado antes de validar la empresa.

## Cambio aplicado

Se centralizó la resolución de `Product2.Empresa__c`:

- `Bavarian` / `RMBAVARIAN` conservan `RMBAVARIAN`;
- `Otobai` / `RMOTOBAI` conservan `RMOTOBAI`;
- `RMPEKING` se reconoce explícitamente, pero se detiene antes del callout de
  reserva porque no existe contrato confirmado de reserva Softland para PEKING;
- empresa nula o no soportada produce error controlado;
- no existe selección por descarte hacia Bavarian u Otobai;
- la validación de empresa ocurre antes de solicitar token.

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

- reserva Bavarian;
- reserva Otobai;
- PEKING detenido antes del callout;
- empresa nula sin fallback.

## Estado

Completado, validado y desplegado en RedMotorsSandbox / Partial.

## Validación

- Primer dry-run enfocado `0AfAK000000x47d0AA`: 3/3 componentes compilados,
  3/4 pruebas aprobadas. La falla se debió a que `Product2.Marca__c = Omoda`
  no es un valor activo del picklist para el fixture. La org no fue modificada.
- Segundo dry-run enfocado `0AfAK000000x4Ar0AI`: 3/3 componentes compilados,
  3/4 pruebas aprobadas. La falla confirmó que `RMPEKING` existe en el campo
  `Product2.Empresa__c`, pero no estaba habilitado para el Record Type
  `Product2.Vehiculos` usado por el fixture. La org no fue modificada.
- Corrección aplicada: el fixture utiliza `Product2.Producto_Red_Motors`, Record
  Type que tiene habilitados `RMBAVARIAN`, `RMOTOBAI` y `RMPEKING`, y elimina
  campos de marca que no intervienen en la lógica probada.
- Dry-run enfocado final `0AfAK000000wwlC0AQ`: 3/3 componentes, 4/4 pruebas,
  0 fallas. Cobertura de `servicioReservas`: 58/68 = 85.29%.
- Regresión relacionada `0AfAK000000x30I0AQ`: 3/3 componentes, 16/16 pruebas,
  0 fallas.
- Deploy real `0AfAK000000x3mg0AA`: 3/3 componentes, 16/16 pruebas, 0 fallas,
  estado Succeeded.
- Verificación post-deploy `707AK00000H9o1s`: 4/4 pruebas, 0 fallas.
