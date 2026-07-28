# Next8 Lote 4 — Registro y consulta de anticipos

Fecha: 28/07/2026.

## Componentes

- `Registrar_Anticipo_Controller`
- `Registrar_Anticipo_Controller_Test`

## Comportamiento anterior

- La compañía para consultar y registrar anticipos iniciaba en `RMBAVARIAN`.
- Solo cambiaba a `RMOTOBAI` cuando el nombre del Pricebook contenía `Otobai`.
- Opportunity sin Pricebook, Pricebook desconocido o llamada sin Opportunity podían caer por descarte en `RMBAVARIAN`.
- No existía tratamiento explícito para `RMPEKING`.

## Cambio aplicado

- Se agregó resolución explícita de empresa antes de las llamadas externas de anticipos.
- `Opportunity.Empresa_Operadora__c` es la fuente principal.
- Si el lookup está vacío, se conserva el respaldo temporal por nombre de Pricebook:
  - Bavarian / `RMBAVARIAN` → `RMBAVARIAN`
  - Otobai / `RMOTOBAI` → `RMOTOBAI`
  - PEKING / `RMPEKING` → `RMPEKING`
- `RMBAVARIAN` y `RMOTOBAI` conservan el comportamiento operativo existente.
- `RMPEKING` se reconoce explícitamente y se detiene antes de autenticar o llamar a Softland porque no existe contrato confirmado de anticipos Softland para PEKING.
- Opportunity nula, Pricebook nulo, Pricebook desconocido o empresa no soportada producen error controlado.
- No existe selección por descarte hacia Bavarian u Otobai.

## Alcance no modificado

No se modificaron endpoint, autenticación, payloads fuera de la compañía, creación de `Anticipo__c`, reserva posterior del vehículo, OpportunityLineItem, Product2, Flows ni LWC.

## Pruebas

Se actualizaron las pruebas para cubrir:

- consulta de anticipo con Bavarian heredado;
- consulta de anticipo con Otobai heredado;
- consulta de anticipo con PEKING por lookup detenida antes de callout;
- registro de anticipo con Bavarian heredado;
- registro de anticipo con Otobai heredado;
- registro de anticipo con PEKING por lookup detenido antes de callout;
- llamada sin Opportunity detenida sin fallback;
- escenarios históricos de validaciones de Opportunity, producto, identificador, producto reservado y producto reportado.

## Validación

- Dry-run enfocado `0AfAK000000x5wX0AQ`: 2/2 componentes, 28/28 pruebas,
  0 fallas. Cobertura de `Registrar_Anticipo_Controller`: 169/191 = 88.48%.
- Regresión relacionada `0AfAK000000x3Zm0AI`: 2/2 componentes, 41/41 pruebas,
  0 fallas.
- Deploy real `0AfAK000000x62z0AA`: 2/2 componentes, 41/41 pruebas, 0 fallas.
  Estado: Succeeded en RedMotorsSandbox / Partial.
- Verificación post-deploy `707AK00000HA3Hy`: `Registrar_Anticipo_Controller_Test`,
  28/28 pruebas, 0 fallas.

## Riesgos y pendientes

- La operación real de anticipos para PEKING queda pendiente de definición del contrato externo correspondiente.
- La consulta de anticipos ahora requiere una Opportunity para determinar empresa y evitar fallback silencioso.
