# Implementación del Bloque 2 — Lógica Pricebook

## Autorización y alcance

Se autorizó mantener la estructura actual de Pricebooks identificados por
nombres fijos y priorizar la corrección de las decisiones binarias en Apex.

La nueva empresa autorizada es **PEKING**, asociada a las marcas **Omoda** y
**Jaecoo**.

Los seis nombres exactos autorizados son:

- `Bavarian Local`
- `Bavarian Dólar`
- `Otobai Local`
- `Otobai Dólares`
- `PEKING Local`
- `PEKING Dólares`

No se agregaron campos a `Pricebook2`, objetos de asociación, registros ni
resolutores adicionales.

## Componentes modificados

- `BMW_ChangeCurrencyWOWOLI`
- `BMW_ChangeCurrencyWOWOLITest`
- `QuoteController`
- `QuoteControllerTest`

## Lógica anterior

`BMW_ChangeCurrencyWOWOLI.changeCurrency()` trataba como Otobai únicamente un
nombre reconocido y asumía Bavarian para cualquier otro Pricebook.

`QuoteController.changeCurrencygtQLIs()` inicializaba el destino con
`Bavarian Local`, comparaba cuatro nombres y contenía una tabulación residual
en el literal `Otobai Dólares`.

En ambos casos un Pricebook nulo, desconocido o sin pareja podía producir una
consulta fallida o seleccionar una empresa incorrecta.

## Corrección realizada

Cada método contiene una relación explícita y cerrada entre los seis nombres
autorizados:

| Origen | Destino | Moneda destino |
|---|---|---|
| `Bavarian Local` | `Bavarian Dólar` | USD |
| `Bavarian Dólar` | `Bavarian Local` | CRC |
| `Otobai Local` | `Otobai Dólares` | USD |
| `Otobai Dólares` | `Otobai Local` | CRC |
| `PEKING Local` | `PEKING Dólares` | USD |
| `PEKING Dólares` | `PEKING Local` | CRC |

Antes de eliminar o actualizar información, los métodos validan:

- Pricebook de origen no nulo;
- existencia del Pricebook de origen;
- nombre de origen autorizado;
- existencia del Pricebook destino;
- ausencia de duplicados para el nombre destino.

Una configuración nula, desconocida, inexistente o ambigua produce
`AuraHandledException` con un mensaje explícito. No existe fallback a Bavarian,
Otobai o PEKING.

La conducta existente de `QuoteController` sobre `WorkOrderLineItem` se
conservó: las líneas se eliminan y no se recrean. La única variación es que la
validación del Pricebook ocurre antes de esa eliminación.

## Pruebas

Las pruebas crean sus propios Pricebooks y datos, sin `SeeAllData` y sin
depender de registros existentes.

Se agregaron casos para:

- las seis conversiones autorizadas;
- Pricebook de origen desconocido;
- Pricebook nulo;
- Pricebook destino inexistente;
- Pricebook destino ambiguo;
- ausencia de fallback;
- conservación de WorkOrder, Quote y QuoteLineItem;
- conservación de la cantidad de líneas recreadas por
  `BMW_ChangeCurrencyWOWOLI`;
- validación previa a la eliminación de líneas en `QuoteController`.

Las seis conversiones de cada controlador se ejecutan en métodos `@IsTest`
independientes. Cada método prepara únicamente su par de Pricebooks y ejecuta
una sola conversión dentro de `Test.startTest()` y `Test.stopTest()`.

## Resultado del primer dry-run

| Dato | Resultado |
|---|---|
| Deploy ID | `0AfAK000000vlNB0AY` |
| Componentes compilados | 4/4 |
| Tests aprobados | 7/12 |
| Tests fallidos | 5/12 |
| Cobertura previa de `QuoteController` | 26.302% |
| Modificación de la org | Ninguna; la ejecución fue dry-run |

Las cinco fallas se originaron por:

- ejecución de seis conversiones de `QuoteController` dentro de una sola
  transacción y agotamiento del límite SOQL;
- ejecución de seis conversiones de `BMW_ChangeCurrencyWOWOLI` dentro de una
  sola transacción y agotamiento del límite SOQL;
- ausencia de `Codigo_de_Producto__c` en el producto usado para comprobar que
  un error no elimina líneas;
- códigos de producto repetidos en `workOrderHistoryTest`;
- códigos de producto repetidos en `workOrderHistoryTest2`.

Correcciones aplicadas:

- una prueba independiente por cada sentido de conversión y controlador;
- una sola llamada productiva por transacción de prueba;
- `Codigo_de_Producto__c = QCT-UNKNOWN` en el producto de la prueba negativa;
- códigos `QCT-HISTORY-1-*` y `QCT-HISTORY-2-*` independientes para los dos
  escenarios históricos;
- conservación de las aserciones funcionales y de la validación previa al DML.

## Resultado del segundo dry-run

| Dato | Resultado |
|---|---|
| Deploy ID | `0AfAK000000vlOn0AI` |
| Componentes compilados | 4/4 |
| Tests aprobados | 19/22 |
| Tests fallidos | 3/22 |
| Cobertura previa de `QuoteController` | 26.302% |
| Modificación de la org | Ninguna; la ejecución fue dry-run |

Las tres fallas fueron exclusivamente de preparación de datos:

- `rejectsUnknownPricebookBeforeDeletingLines` intentaba insertar una
  definición de precio estándar adicional para el mismo producto, moneda y
  Pricebook;
- `workOrderHistoryTest` utilizaba `Nuevo`, valor que ya no está activo en el
  picklist restringido `WorkOrder.Etapa_de_flujo_de_trabajo__c`;
- `workOrderHistoryTest2` utilizaba el mismo valor inactivo.

Correcciones aplicadas:

- el producto `QCT-UNKNOWN` conserva una única entrada de precio en el
  Pricebook desconocido usado por el escenario;
- se retiró la creación explícita e innecesaria de una entrada adicional en el
  Pricebook estándar;
- ambos escenarios históricos usan `Cita`, valor activo predeterminado que
  representa el estado inicial más cercano a la intención original de
  `Nuevo`;
- la preparación previa usa `Aprobación`, valor activo equivalente al texto
  legado `Aprobación de presupuesto`.

Los valores activos confirmados para el picklist fueron: `Cita`, `Check-In`,
`Recep`, `Espera Taller`, `Torre`, `Revisión`, `Presupuesto`, `Aprobación`,
`Proceso`, `Prueba`, `Lavado`, `C.Calidad`, `Listo`, `Facturada`, `Anulado` y
`En proceso`.

## Validación final y deploy real

### Dry-run exitoso

| Dato | Resultado |
|---|---|
| Deploy ID | `0AfAK000000vlS10AI` |
| Estado | Succeeded |
| Componentes | 4/4 |
| Pruebas | 22/22 |
| Fallas | 0 |

### Deploy real exitoso

| Dato | Resultado |
|---|---|
| Deploy ID | `0AfAK000000vlTd0AI` |
| Estado | Succeeded |
| Componentes | 4/4 |
| Pruebas | 22/22 |
| Fallas | 0 |

`BMW_ChangeCurrencyWOWOLI` y `QuoteController` están disponibles en
`RedMotorsSandbox` con soporte explícito para `PEKING Local` y
`PEKING Dólares`. La lógica desplegada no contiene fallback a Bavarian,
Otobai ni PEKING.

No se modificaron `UpdateCurrencyScheduler` ni `WorkOrderTrigger`. Tampoco se
tocaron los componentes de Softland, reservas, anticipos o inventario.

## Riesgos

- Los nombres siguen siendo claves funcionales y cualquier renombre requiere
  coordinación con Apex.
- La existencia de dos Pricebooks con el mismo nombre bloquea la
  conversión de forma intencional.
- `BMW_ChangeCurrencyWOWOLI` conserva su proceso existente de eliminar y
  recrear líneas.
- `QuoteController` conserva su proceso existente de eliminar líneas sin
  recrearlas.
- Las tasas y demás reglas monetarias existentes no se modificaron.

## Componentes pendientes

- `UpdateCurrencyScheduler`
- `WorkOrderTrigger`
- creación de los Pricebooks `PEKING Local` y `PEKING Dólares`;
- creación de las entradas de productos correspondientes en esos Pricebooks;
- consumidores de Softland, anticipos, reservas e inventario;
- pruebas integrales posteriores a la creación de los Pricebooks y sus
  entradas de productos.

No se habilita todavía la operación completa de PEKING.
