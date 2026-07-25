# Implementación del Bloque 3 — Scheduler de moneda

## Estado

Bloque desplegado correctamente en `RedMotorsSandbox`.

`UpdateCurrencyScheduler` está actualizado con soporte para `PEKING Local` y
`PEKING Dólares`. No se crearon `PricebookEntry` reales.

## Autorización utilizada

El bloque se implementó con las siguientes decisiones confirmadas:

- mantener la estructura actual de Pricebooks por nombres fijos;
- priorizar la corrección de los `if` de las clases Apex;
- incorporar la empresa PEKING, asociada a Omoda y Jaecoo;
- usar `PEKING Local` y `PEKING Dólares`;
- no crear campos nuevos en `Pricebook2`.

Los seis nombres de Pricebook contemplados son:

- `Bavarian Local`;
- `Bavarian Dólar`;
- `Otobai Local`;
- `Otobai Dólares`;
- `PEKING Local`;
- `PEKING Dólares`.

## Componentes del bloque

- `UpdateCurrencyScheduler`
- `UpdateCurrencySchedulerTest`
- `manifest/empresa-marcas-chinas-bloque3-scheduler.xml`

`WorkOrderTrigger` y `WorkOrderTriggerTest` permanecen sin cambios.

## Comportamiento anterior

`UpdateCurrencyScheduler.execute()` localizaba entradas modificadas durante los
últimos siete minutos cuya moneda no coincidía con uno de los cuatro nombres de
Pricebook de Bavarian y Otobai:

| Pricebook | Moneda incorrecta consultada | Moneda recreada |
|---|---|---|
| `Bavarian Local` | USD | CRC |
| `Bavarian Dólar` | CRC | USD |
| `Otobai Local` | USD | CRC |
| `Otobai Dólares` | CRC | USD |

Las entradas de PEKING no estaban incluidas en la consulta y, por tanto, no se
procesaban.

## Soporte agregado para PEKING

Se agregaron únicamente:

- `PEKING Local` a la consulta de entradas incorrectamente registradas en USD;
- `PEKING Dólares` a la consulta de entradas incorrectamente registradas en
  CRC;
- una rama explícita que recrea `PEKING Local` en CRC;
- una rama explícita que recrea `PEKING Dólares` en USD.

El resultado esperado queda así:

| Pricebook | Moneda incorrecta consultada | Moneda recreada |
|---|---|---|
| `Bavarian Local` | USD | CRC |
| `Bavarian Dólar` | CRC | USD |
| `Otobai Local` | USD | CRC |
| `Otobai Dólares` | CRC | USD |
| `PEKING Local` | USD | CRC |
| `PEKING Dólares` | CRC | USD |

No se agregó un `else` predeterminado. Los Pricebooks cuyos nombres no están
incluidos en la consulta conservan el comportamiento anterior: no se procesan.

## Comportamiento conservado

- La selección continúa basada exclusivamente en los seis nombres autorizados.
- No se usa `Pricebook2.CurrencyIsoCode` para decidir la moneda.
- La entrada recreada conserva el mismo `Pricebook2Id` y `Product2Id`.
- Se siguen copiando:
  - `Costo_Fijo__c`;
  - `Gerente__c`;
  - `IsActive`;
  - `Jefe__c`;
  - `pricebookEntryId__c`;
  - `UnitPrice`;
  - `UseStandardPrice`;
  - `Vendedor__c`.
- No se agregaron IDs hardcodeados.
- No se procesan nombres desconocidos.

## Pruebas

`UpdateCurrencySchedulerTest` crea todos sus productos, Pricebooks y
`PricebookEntry` dentro de cada prueba, sin `SeeAllData` ni dependencia de
registros existentes.

Casos independientes:

1. `Bavarian Local`: USD → CRC.
2. `Bavarian Dólar`: CRC → USD.
3. `Otobai Local`: USD → CRC.
4. `Otobai Dólares`: CRC → USD.
5. `PEKING Local`: USD → CRC.
6. `PEKING Dólares`: CRC → USD.
7. Pricebook desconocido: permanece sin cambios y sin fallback.

Cada conversión comprueba:

- que la entrada incorrecta deja de existir;
- que se crea una sola entrada corregida;
- que se conserva el mismo `Pricebook2Id`;
- que se conserva el mismo `Product2Id`;
- que la moneda final es la esperada;
- que se conservan los campos copiados históricamente por el scheduler;
- que no se utiliza otro Pricebook como fallback.

Cada método ejecuta una sola programación dentro de `Test.startTest()` y
`Test.stopTest()`. Los códigos de producto son únicos por escenario.

## Resultado del primer dry-run

| Dato | Resultado |
|---|---|
| Deploy ID | `0AfAK000000vli90AA` |
| Componentes compilados | 2/2 |
| Pruebas aprobadas | 0/7 |
| Cobertura de `UpdateCurrencyScheduler` | 0% |
| Modificación de la org | Ninguna; la ejecución fue dry-run |

Las siete pruebas fallaron durante la preparación de datos en
`createStandardPrices()`, antes de ejecutar el scheduler. El helper intentaba
insertar entradas estándar CRC y USD para el producto. La inserción previa de
`Product2` ya había provocado la existencia de la definición estándar USD
dentro de la misma transacción de prueba, por lo que el helper intentaba
repetir la combinación:

- Pricebook estándar;
- mismo `Product2Id`;
- `CurrencyIsoCode = USD`.

`assertConversion()` no creaba directamente otro precio estándar antes de
llamar al helper. `createEntry()` creaba únicamente la entrada del Pricebook
personalizado. La prueba del Pricebook desconocido tampoco reutilizaba
manualmente otra entrada: la colisión tenía el mismo origen común posterior a
la inserción del producto.

### Corrección de datos de prueba

`createStandardPrices()` fue sustituido por `ensureStandardPrices()`. El nuevo
helper:

1. recibe únicamente las monedas requeridas por el escenario;
2. consulta las entradas estándar del producto creadas dentro de la misma
   prueba;
3. identifica las monedas ya existentes;
4. inserta solo las definiciones estándar faltantes;
5. no captura ni ignora errores `DUPLICATE_VALUE`.

Preparación por escenario:

- las seis conversiones solicitan una entrada estándar USD y una CRC, como
  máximo una vez por moneda;
- el Pricebook desconocido solicita únicamente la entrada estándar USD;
- cada prueba conserva un producto y un `Codigo_de_Producto__c` exclusivos.

La cobertura reportada fue 0% porque ninguna prueba alcanzó
`UpdateCurrencyScheduler.execute()`. La corrección no modifica el scheduler ni
reduce los siete escenarios o sus aserciones funcionales.

## Validación final y deploy real

### Dry-run exitoso

| Dato | Resultado |
|---|---|
| Deploy ID | `0AfAK000000vljl0AA` |
| Componentes | 2/2 |
| Pruebas | 7/7 |
| Fallas | 0 |

### Deploy real exitoso

| Dato | Resultado |
|---|---|
| Deploy ID | `0AfAK000000vllN0AQ` |
| Componentes | 2/2 |
| Pruebas | 7/7 |
| Fallas | 0 |

El deploy real dejó `UpdateCurrencyScheduler` actualizado en
`RedMotorsSandbox`. Se agregó soporte explícito para `PEKING Local` y
`PEKING Dólares`, se conservaron las cuatro conversiones anteriores y no se
introdujeron fallbacks. Los Pricebooks cuyos nombres no están incluidos en la
consulta continúan sin procesarse.

## Riesgo heredado no corregido

El scheduler conserva deliberadamente su estructura histórica:

1. prepara las nuevas entradas;
2. elimina las entradas incorrectas mediante `Database.delete(..., false)`;
3. intenta insertar las entradas corregidas mediante
   `Database.insert(..., false)`.

Una falla de reinserción puede dejar un resultado parcial después de la
eliminación. Este riesgo no se corrigió porque el rediseño transaccional no fue
autorizado para el bloque.

## Fuera de alcance

- `WorkOrderTrigger`;
- `WorkOrderTriggerTest`;
- Pricebooks y `PricebookEntry` reales;
- objetos, campos, relaciones o helpers nuevos;
- Softland;
- inventario y bodegas;
- reservas;
- anticipos;
- datos operativos de PEKING.

No se crearon `PricebookEntry` reales y no se modificaron Softland, reservas,
inventario ni anticipos. `WorkOrderTrigger` sigue pendiente de respuesta de
Diego.

## Estado final

El Bloque 3 está compilado, probado y desplegado en `RedMotorsSandbox`. El
riesgo heredado de eliminar antes de reinsertar permanece documentado y no fue
corregido porque ese rediseño no estaba autorizado.
