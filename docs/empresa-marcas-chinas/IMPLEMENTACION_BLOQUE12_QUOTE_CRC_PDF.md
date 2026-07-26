# Implementación Bloque 12 — PEKING en PDF de cotización CRC

## Estado

Bloque completado, validado y desplegado en RedMotorsSandbox / Partial.

El Bloque 10 de visibilidad de Pricebooks continúa pausado. Este bloque es
independiente del mapeo de sucursales pendiente.

## Autorización y alcance

Luis autorizó avanzar con cambios claros de bajo riesgo, documentando lo
realizado. Se conserva la estructura autorizada de Pricebooks por nombre:

- `Bavarian Dólar` → `Bavarian Local`;
- `Otobai Dólares` → `Otobai Local`;
- `PEKING Dólares` → `PEKING Local`.

El alcance se limita a la selección del Pricebook CRC utilizada por
`cT_QuoteCrcPDFController.getData(String recordId)`.

## Comportamiento anterior

El controlador reconocía únicamente `Bavarian Dólar` y
`Otobai Dólares`. `PEKING Dólares` no seleccionaba un Pricebook destino. Un
nombre desconocido dejaba vacío el nombre destino en producción.

Existían dos bifurcaciones `Test.isRunningTest()` que impedían ejecutar en
pruebas la consulta productiva del Pricebook destino y alteraban el
tratamiento de nombres desconocidos.

## Cambio realizado

Se agregó exclusivamente:

- `PEKING Dólares` → `PEKING Local`.

No se agregó fallback. Los nombres desconocidos conservan el comportamiento
productivo anterior y no seleccionan ningún Pricebook autorizado.

Se retiraron únicamente los dos guards relacionados con la selección. Como
siempre evaluaban `false` en producción, su eliminación no cambia la ruta
productiva y permite validarla con datos autocontenidos.

No se modificaron cálculos, tasa fija, montos, productos, wrappers, nombres de
variables ni estructura del PDF.

## Pruebas

`cT_QuoteCrcPDFController_test` contiene cinco métodos:

1. Bavarian Dólar utiliza Bavarian Local.
2. Otobai Dólares utiliza Otobai Local.
3. PEKING Dólares utiliza PEKING Local.
4. Un Pricebook desconocido no selecciona ninguna empresa.
5. Una cotización CRC conserva el comportamiento directo actual.

Cada conversión configura expresamente Opportunity, WorkOrder y su Pricebook
de origen. Se valida el Pricebook destino, el mismo producto, el precio CRC,
la cantidad y el total.

Los escenarios crean sus propios registros. No utilizan `SeeAllData`, IDs
reales ni consultas amplias.

## Validación y deploy

| Validación | Deploy ID | Componentes | Pruebas | Fallas |
|---|---|---:|---:|---:|
| Dry-run | `0AfAK000000vpiX0AQ` | 2/2 | 5/5 | 0 |
| Deploy real | `0AfAK000000vpk90AA` | 2/2 | 5/5 | 0 |

El dry-run confirmó una cobertura de 113/115 líneas para
`cT_QuoteCrcPDFController`, equivalente a 98.26%.

El deploy real terminó correctamente en RedMotorsSandbox / Partial. Quedaron
desplegados `cT_QuoteCrcPDFController` y
`cT_QuoteCrcPDFController_test`.

Se validaron los cinco escenarios funcionales previstos. Se conservaron las
asociaciones de Bavarian y Otobai, se agregó PEKING Dólares → PEKING Local y
no se incorporó ningún fallback.

## Riesgos heredados y pendientes

- La consulta exige un único Pricebook con el nombre destino.
- Un destino inexistente o duplicado conserva la excepción heredada.
- La tasa fija y los cálculos existentes permanecen sin cambios.

No se modificaron cálculos, tasa fija, montos, productos, wrappers ni la
estructura del PDF.

## Avance técnico estimado

- completado: 76%;
- pendiente: 24%.

Es una estimación del alcance técnico y no representa horas oficiales,
trabajadas, registradas ni facturables.
