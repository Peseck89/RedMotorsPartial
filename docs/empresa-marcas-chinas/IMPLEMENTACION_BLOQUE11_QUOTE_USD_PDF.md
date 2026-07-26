# Implementación Bloque 11 — PEKING en PDF de cotización USD

## Estado

Bloque completado, validado y desplegado en RedMotorsSandbox / Partial.

El Bloque 10 de visibilidad de Pricebooks permanece pausado hasta revisar el
mapeo de sucursales. Este bloque es independiente de esa decisión.

## Autorización y alcance

Luis autorizó avanzar directamente con cambios claros y de bajo riesgo,
documentando cada acción. Se mantuvo la estructura autorizada de Pricebooks
por nombre:

- `Bavarian Local` → `Bavarian Dólar`;
- `Otobai Local` → `Otobai Dólares`;
- `PEKING Local` → `PEKING Dólares`.

El alcance se limita a la selección del Pricebook USD utilizada por
`cT_QuoteUsdPDFController.getData(String recordId)`.

## Comportamiento anterior

El controlador reconocía únicamente `Bavarian Local` y `Otobai Local`.
`PEKING Local` no seleccionaba un Pricebook destino. Un nombre desconocido
dejaba vacío el nombre destino en producción.

La clase contenía dos bifurcaciones `Test.isRunningTest()` que impedían que
las pruebas recorrieran la consulta productiva del Pricebook destino y que
alteraban el tratamiento de nombres desconocidos durante las pruebas.

## Cambio realizado

Se agregó exclusivamente la asociación explícita:

- `PEKING Local` → `PEKING Dólares`.

No se agregó fallback. Los nombres desconocidos conservan el comportamiento
productivo anterior: no seleccionan ningún Pricebook autorizado.

Se retiraron únicamente los dos guards de prueba relacionados con esta
selección. En producción siempre evaluaban `false`, por lo que su eliminación
no cambia la ejecución productiva; permite validar la misma ruta con datos
autocontenidos.

No se modificaron cálculos, tasas, montos, productos, agregaciones ni otras
ramas del PDF.

## Pruebas

`cT_QuoteUsdPDFController_test` contiene cuatro métodos:

1. Bavarian Local utiliza Bavarian Dólar.
2. Otobai Local utiliza Otobai Dólares.
3. PEKING Local utiliza PEKING Dólares.
4. Un Pricebook desconocido no selecciona Bavarian, Otobai ni PEKING.

Cada conversión valida que:

- el Pricebook destino sea el esperado;
- la entrada destino corresponda al mismo producto;
- el precio USD provenga de esa entrada;
- la cantidad y el cálculo de total conserven el comportamiento existente.

Los datos son propios de cada prueba. No se utiliza `SeeAllData`, IDs reales
ni Pricebooks operativos.

## Validación y deploy

| Validación | Deploy ID | Componentes | Pruebas | Fallas |
|---|---|---:|---:|---:|
| Dry-run | `0AfAK000000vpdh0AA` | 2/2 | 4/4 | 0 |
| Deploy real | `0AfAK000000vpfJ0AQ` | 2/2 | 4/4 | 0 |

El dry-run confirmó una cobertura de 97/112 líneas para
`cT_QuoteUsdPDFController`, equivalente a 86.61%.

El deploy real terminó correctamente en RedMotorsSandbox / Partial. Quedaron
desplegados `cT_QuoteUsdPDFController` y
`cT_QuoteUsdPDFController_test`.

Se validaron los cuatro escenarios funcionales previstos. Se conservaron las
asociaciones de Bavarian y Otobai, se agregó PEKING Local → PEKING Dólares y
no se incorporó ningún fallback.

## Riesgos y pendientes

- La consulta productiva exige que exista exactamente un Pricebook con el
  nombre destino. La gestión de destinos inexistentes o duplicados no se
  modificó en este bloque.
- Se conserva la lógica de conversión y cálculo existente, incluidas sus
  tasas y reglas históricas.
- El controlador inverso `cT_QuoteCrcPDFController` permanece pendiente.

No se modificaron cálculos, tasas, montos, productos ni la estructura del
PDF.

## Avance técnico estimado

- completado: 75%;
- pendiente: 25%.

Es una estimación del alcance técnico y no representa horas oficiales,
trabajadas, registradas ni facturables.
