# Next8 — Lote 3: enlace de pago desde Opportunity

## Alcance

Componentes revisados:

- `OpportunityServiceInvoker`;
- `OpportunityServiceInvokerTest`.

## Situación encontrada

La versión local difería de la versión vigente en RedMotorsSandbox / Partial.
Antes de aplicar cambios se recuperó la versión desplegada para preservar el
comportamiento operativo existente.

## Comportamiento anterior

La compañía enviada al servicio se determinaba desde `Opportunity.Pricebook2.Name`:

- iniciaba siempre en `RMBAVARIAN`;
- solo cambiaba a `RMOTOBAI` cuando el nombre de Pricebook contenía `Otobai`;
- cualquier Pricebook desconocido, nulo o no relacionado con Otobai caía por
  descarte en `RMBAVARIAN`;
- no existía tratamiento explícito para `RMPEKING`;
- la validación de empresa ocurría después de consultar datos operativos.

## Cambio aplicado

Se agregó resolución explícita de empresa:

- `Opportunity.Empresa_Operadora__c` es la fuente principal;
- si el lookup está vacío, se conserva el respaldo temporal por nombre de
  Pricebook;
- Pricebooks Bavarian conservan `RMBAVARIAN`;
- Pricebooks Otobai conservan `RMOTOBAI`;
- `RMPEKING` se reconoce explícitamente, pero se detiene antes del callout
  porque no existe contrato confirmado de enlace de pago Softland para PEKING;
- empresa nula, Pricebook desconocido o empresa no soportada producen error
  controlado;
- no existe selección por descarte hacia Bavarian u Otobai.

## Alcance no modificado

No se modificaron:

- endpoint;
- autenticación;
- payload fuera de `compania`;
- Account;
- OpportunityLineItem;
- productos;
- datos financieros;
- Flows;
- LWC.

## Pruebas

Se actualizaron pruebas para cubrir:

- lista nula;
- lista vacía;
- lookup Bavarian;
- lookup Otobai;
- respuesta HTTP 500;
- respuesta no parseable;
- Pricebook desconocido sin fallback;
- lookup PEKING detenido antes del callout;
- precedencia del lookup PEKING sobre Pricebook Otobai.

## Estado

Completado, validado y desplegado en RedMotorsSandbox / Partial.

## Validación

- Dry-run enfocado `0AfAK000000x44Q0AQ`: 2/2 componentes, 9/9 pruebas,
  0 fallas. Cobertura de `OpportunityServiceInvoker`: 67/76 = 88.16%.
- Regresión relacionada `0AfAK000000x31u0AA`: 2/2 componentes, 18/18 pruebas,
  0 fallas.
- Deploy real `0AfAK000000x5dB0AQ`: 2/2 componentes, 18/18 pruebas, 0 fallas,
  estado Succeeded.
- Verificación post-deploy `707AK00000HA56U`: 9/9 pruebas, 0 fallas.
