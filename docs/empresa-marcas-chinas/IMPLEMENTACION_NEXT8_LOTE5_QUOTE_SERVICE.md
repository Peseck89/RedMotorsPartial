# Next8 Lote 5 — QuoteService

Fecha: 28/07/2026.

## Componentes

- `QuoteService`
- `QuoteServiceTest`

## Comportamiento anterior

- La bodega principal para vehículos y extras se resolvía con lógica de marca o Record Type.
- Otobai conservaba `BR02` con el identificador externo operativo existente.
- Los valores no reconocidos podían terminar en `BR01`, que corresponde al comportamiento heredado de Bavarian.
- No existía tratamiento explícito para `RMPEKING`.

## Cambio aplicado

- Se agregó resolución explícita de empresa antes de determinar bodega principal.
- Para vehículos, la fuente principal es `Product2.Empresa__c`; si no está informada se mantiene compatibilidad por marca.
- Para líneas de Quote, la fuente principal es `Opportunity.Empresa_Operadora__c`; si está vacía se conserva compatibilidad por `BMW_Compania__c`, Record Type o Pricebook.
- Bavarian conserva `BR01`.
- Otobai conserva `BR02`.
- PEKING se reconoce explícitamente y se detiene antes de crear líneas porque no existe bodega principal confirmada para `RMPEKING`.
- Empresa nula o no reconocida produce error controlado.

## Alcance no modificado

No se modificaron Pricebooks, cálculos, comisiones, productos, configuración de ventas, reglas de fantasía, Flows, LWC, bodegas reales ni datos operativos.

## Pruebas

Se agregaron escenarios para validar:

- vehículo PEKING detenido antes de caer a bodega Bavarian;
- línea extra de Quote PEKING detenida antes de caer a bodega Bavarian;
- ausencia de registros parciales cuando falta la bodega PEKING confirmada.

También se conservaron las pruebas funcionales existentes de Otobai, errores de datos relacionados, precio, extras, regalías y mano de obra.

## Validación

Primer dry-run enfocado:

- ID: `0AfAK000000x5yA0AQ`.
- Componentes: 2/2.
- Resultado: fallido.
- Causa: una ruta de `addLineItem` resolvía bodega antes de validar la existencia del Quote y dos fixtures PEKING intentaban usar `Product2.Empresa__c` con una combinación de metadata no permitida para el Record Type usado por la prueba.

Segundo dry-run enfocado:

- ID: `0AfAK000000x4cI0AQ`.
- Componentes: 2/2.
- Resultado: fallido.
- Causa: el fixture de vehículo PEKING intentaba crear `Configuracion_de_ventas__c.Marca__c = Omoda`, valor no permitido por el picklist actual para ese escenario de prueba.

Dry-run enfocado exitoso:

- ID: `0AfAK000000x6ML0AY`.
- Componentes: 2/2.
- Pruebas: 10/10.
- Fallas: 0.
- Cobertura de `QuoteService`: 260/327 líneas, 79.51%.

Regresión relacionada:

- ID: `0AfAK000000x2nO0AQ`.
- Componentes: 2/2.
- Pruebas: 19/19.
- Fallas: 0.

Deploy real:

- ID: `0AfAK000000x6RB0AY`.
- Ambiente: RedMotorsSandbox / Partial.
- Componentes: 2/2.
- Pruebas: 19/19.
- Fallas: 0.
- Estado: Succeeded.

Verificación post-deploy:

- Test Run ID: `707AK00000HA55b`.
- Clase ejecutada: `QuoteServiceTest`.
- Pruebas: 10/10.
- Fallas: 0.

## Riesgos y pendientes

- Falta definir bodega principal operativa para `RMPEKING`.
- Mientras esa definición no exista, PEKING queda protegido contra asignación silenciosa a `BR01` o `BR02`.
