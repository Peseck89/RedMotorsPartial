# Next8 Lote 6 — productJSON

Fecha: 28/07/2026.

## Componentes

- `productJSON`
- `productJSONTest`

## Comportamiento anterior

- `RMBAVARIAN` buscaba productos por `Product2.Codigo_de_Producto__c`.
- `RMOTOBAI` buscaba productos por `Product2.CodigoProductoInterno__c` compuesto como `articulo-empresa`.
- Cualquier empresa distinta de `RMBAVARIAN` terminaba usando el patrón de bodega `RMOTOBAI + bodega`.
- No existía una ruta explícita para `RMPEKING`.
- Una empresa nula o desconocida podía terminar en error técnico o en comportamiento no controlado.

## Evidencia revisada

- En RedMotorsSandbox / Partial no se encontraron bodegas activas con patrón PEKING o `RMPEKING`.
- No se encontraron productos existentes con `Product2.Empresa__c = RMPEKING`, Omoda o Jaecoo que confirmaran una llave operativa.
- La versión local difería de la versión vigente en Partial, por lo que el cambio se aplicó sobre la versión desplegada.

## Cambio aplicado

- Se normalizó la empresa recibida por el payload.
- Se admiten explícitamente `RMBAVARIAN`, `RMOTOBAI` y `RMPEKING`.
- `BAVARIAN`, `OTOBAI` y `PEKING` se normalizan a sus códigos operativos.
- `RMPEKING` se reconoce y se detiene antes de crear o actualizar `Product2`, porque falta la bodega principal confirmada.
- Empresas nulas o desconocidas producen error controlado.
- La ruta de bodegas ya no cae por descarte al prefijo de Otobai.

## Alcance no modificado

No se modificaron endpoints, payloads externos, productos reales, bodegas reales, Softland, reservas, inventario, Flows, LWC ni metadata.

## Pruebas

Se agregaron escenarios para validar:

- `RMPEKING` detenido antes de crear productos o bodegas parciales.
- empresa desconocida detenida sin fallback a Bavarian u Otobai.

Se conservaron las pruebas existentes de creación/actualización de producto, vehículo, usado, tránsito, bodegas y detalle de costo.

## Validación

Dry-run enfocado:

- ID: `0AfAK000000x6iv0AA`.
- Componentes: 2/2.
- Pruebas: 7/7.
- Fallas: 0.
- Cobertura de `productJSON`: 294/359 líneas, 81.89%.

Deploy real:

- ID: `0AfAK000000x6m90AA`.
- Ambiente: RedMotorsSandbox / Partial.
- Componentes: 2/2.
- Pruebas: 7/7.
- Fallas: 0.
- Estado: Succeeded.

Verificación post-deploy:

- Test Run ID: `707AK00000HADCD`.
- Clase ejecutada: `productJSONTest`.
- Pruebas: 7/7.
- Fallas: 0.

## Riesgos y pendientes

- Falta definir la bodega operativa principal de `RMPEKING`.
- Falta confirmar la llave definitiva para productos PEKING/Omoda/Jaecoo si debe diferir de `articulo-empresa`.
- Mientras esos datos no existan, `RMPEKING` queda protegido contra asignación silenciosa a bodegas Bavarian u Otobai.
