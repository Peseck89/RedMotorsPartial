# Matriz autoritativa — Sprint 1: clases Apex y triggers del alcance original

> **Advertencia de fuente.** Esta matriz se construyó **sin** la fuente #1 (tabla
> enviada por Luis) ni la fuente #3 (transcripción de la conversación). Ninguna de
> las dos está en el repositorio. La lista se derivó de la fuente #2 disponible de
> mayor jerarquía: la **sección 3 "Apex (clases y triggers)"** del documento
> *DEV Evaluación - Alcance - Inclusión de nueva Empresa- Marchas chinas Redmotors*,
> complementada con su sección 9. El resultado son **25 clases productivas reales**
> y **4 nombres de trigger**, no 33 + 3. La diferencia se documenta en la sección 3
> y no se cerró inventando componentes.

## 1. Método de derivación

Se extrajeron únicamente los nombres API que aparecen literalmente en la sección
Apex del documento original. No se agregaron clases por contener "Empresa", ni se
incorporaron componentes del Manual amplio, del inventario de 69/74 clases, ni de
los bloques ejecutados después.

| Fila del documento (sección 3) | Componentes nombrados | Acción textual del documento |
|---|---|---|
| Fila 1 | `ChanceAccountBavarian.trigger`, `ChanceAccountOtobai.trigger`, `ChanceAccountContado.trigger` | Crear `ChanceAccountNueva.trigger` o refactorizar a genérico parametrizado |
| Fila 2 | `WorkOrderTrigger.trigger` | Agregar rama para nueva compañía + sus 2 pricebooks (Local/Dólar) |
| Fila 3 | `BMW_LineaPlantillaEmpresa.cls` | Convertir a `else if` + nueva rama |
| Fila 4 | `QuoteSoftlandPedidoService.cls` | Agregar código de empresa Softland de la nueva compañía |
| Fila 5 | `ProductControllerTwo.cls`, `servicioReservas.cls`, `ServicioReservaApartadoArticulosQuote.cls`, `ServicioConsDispBodegaQuoli.cls`, `servicioEliminarReserva.cls`, `ServicioEliminarReservaArticuloQuote.cls`, `ServicioCrearSCQuote.cls` | Crítico: agregar rama explícita en cada uno |
| Fila 6 | `QuoteController.cls`, `cT_QuoteCrcPDFController.cls`, `cT_QuoteUsdPDFController.cls`, `UpdateCurrencyScheduler.cls`, `BMW_ChangeCurrencyWOWOLI.cls` | Crear los 2 Pricebooks + agregar ramas |
| Fila 7 | `OpportunityServiceInvoker.cls`, `Registrar_Anticipo_Controller.cls`, `savePDFfile.cls` | Convertir el default oculto a comparación explícita |
| Fila 8 | `BatchGetCatalogoSoftland.cls` | Parametrizar para las 3 compañías |
| Fila 9 | `BMWServiceQuoteApprovalEmailInvocable.cls` | Agregar rama de territorio nuevo |
| Fila 10 | `~20 clases de test (*Test.cls)` | Actualizar masas de datos de test |
| Sección 9 | `BatchGetBodegaSoftland.cls`, `BatchGetCatalogoSoftland.cls` | Verificar que el batch recorra las 3 compañías |

### 1.1 Regla aplicada a los tests

La fila 10 menciona "~20 clases de test" como masa de datos a actualizar, no como
entregable productivo enumerado. **No se cuentan dentro de las clases del alcance**,
conforme a la regla indicada. Se actualizan como consecuencia de cada clase productiva.

### 1.2 Corrección de un nombre no existente

`BatchGetCatalogoSoftland` **no existe** como clase en el repositorio ni en la línea
base recuperada. Es una etiqueta de familia; el propio documento aclara que hardcodea
`RMBAVARIAN` "en 5 endpoints de catálogo". Los componentes reales son seis:

`BatchGetCategoriaClienteSoftland`, `BatchGetCentroCostoSoftland`,
`BatchGetCondicionPagoSoftland`, `BatchGetCuentaContableSoftland`,
`BatchGetImpuestoSoftland`, `BatchGetSubtipoDocumentoSoftland`.

Al expandir esa familia, los 19 nombres reales de la sección 3 más
`BatchGetBodegaSoftland` producen **25 clases productivas reales**.

## 2. Contradicción de triggers

| Fuente | Triggers enumerados | Cantidad |
|---|---|---:|
| Documento original, fila 1 + fila 2 | `ChanceAccountBavarian`, `ChanceAccountOtobai`, `ChanceAccountContado`, `WorkOrderTrigger` | 4 nombres en 2 filas |
| Manual (según `INVENTARIO_APEX_SPRINT1.md` §4) | `ChanceAccountBavarian`, `ChanceAccountContado`, `WorkOrderTrigger` | 3 |
| Tabla de Luis | no disponible en el repositorio | 3 (según el enunciado) |
| `RedMotorsSandbox` (validación de solo lectura) | los 4 existen y están activos | 4 |

### 2.1 Evaluación de las cuatro hipótesis

| Hipótesis | Evidencia a favor | Evidencia en contra | Veredicto |
|---|---|---|---|
| a) Uno fue excluido expresamente | Ninguna. No hay registro de exclusión en el documento original, la bitácora ni los documentos de bloque | El documento original sí nombra los cuatro | **Descartada por falta de evidencia** |
| b) Los tres `ChanceAccount` cuentan como un bloque único | El documento original efectivamente los agrupa en **una sola fila** con una acción común | Si se cuentan filas el total es 2, no 3 | **Parcialmente sustentada, no produce 3** |
| c) El conteo de la tabla es aproximado | La propia cifra de clases se comunicó como "aproximadamente 33"; el documento no contiene un conteo cerrado | No verificable sin la tabla | **Plausible, no comprobable** |
| d) Error documental | El Manual omite `ChanceAccountOtobai`, que **sí existe y está activo** en `RedMotorsSandbox`. La omisión es demostrablemente incorrecta respecto del org | No prueba que la tabla de Luis herede ese error | **Sustentada para el Manual; no extrapolable a la tabla** |

### 2.2 Lectura más defendible con la evidencia disponible

Los tres triggers `ChanceAccount*` forman un grupo con una acción común y
`WorkOrderTrigger` es un ítem independiente con acción propia. Si "3 triggers"
designa la familia `ChanceAccount`, entonces `WorkOrderTrigger` es adicional y el
alcance real es **3 + 1**. Si "3 triggers" reproduce la lista del Manual
(`Bavarian`, `Contado`, `WorkOrderTrigger`), entonces arrastra la omisión
verificada de `ChanceAccountOtobai`.

No se elige entre ambas por conveniencia.

### 2.3 Pregunta única necesaria para Luis

> En tu tabla de Sprint 1, los "3 triggers" ¿son los tres `ChanceAccount*`
> (`Bavarian`, `Otobai`, `Contado`) con `WorkOrderTrigger` como cuarto ítem
> aparte, o son `ChanceAccountBavarian`, `ChanceAccountContado` y
> `WorkOrderTrigger`, dejando `ChanceAccountOtobai` fuera del alcance?

## 3. Diferencia entre 33 y 25

La derivación documental produce 25 clases productivas reales. La cifra de 33 no
se reproduce con las fuentes disponibles. La diferencia de **8 componentes** no se
puede atribuir sin la tabla de Luis, y **no se rellenó con candidatos inventados**.

Constancia: seis clases fueron implementadas y desplegadas durante el sprint que
**no aparecen** en la sección Apex del documento original (`CrearPlandeVenta`,
`TrabajoQuoteController`, `TrabajoController`, `BMWVinScanTrabajoGenerator`,
`QuoterController`, `ProductSearcherController`). Es probable —pero no
demostrable sin la fuente #1— que parte de la diferencia de 8 corresponda a estas.
Se registran abajo como "No pertenece a las 33+3" **según evidencia documental**,
con la salvedad expresa de que la tabla de Luis podría incluirlas.

## 4. Matriz

Estados exclusivos: **ID** Implementado y desplegado · **IL** Implementado local, no desplegado ·
**RSC** Revisado, sin cambio necesario · **PI** Pendiente de implementar ·
**BLQ** Bloqueado por dato/decisión externa · **NP** No pertenece a las 33+3.

### 4.1 Clases productivas del alcance documental (25)

| # | Clase | Fuente exacta | Acción solicitada | Estado en Git | Bloque | Cambio realizado | Commit | Deploy ID | Pruebas | Estado real | Trabajo faltante | Bloqueo |
|---:|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | `BMW_LineaPlantillaEmpresa` | Doc. original §3 fila 3 | `else if` + rama nueva | Modificada | 9 | `Empresa_Operadora__c` como fuente principal, `BMW_Compania__c` como respaldo | rama sprint1 | `0AfAK000000vpU10AI` | Sí, desplegadas | **ID** | — | — |
| 2 | `QuoteSoftlandPedidoService` | Doc. original §3 fila 4 | Código Softland de la nueva compañía | Sin cambios | — | Ninguno | — | — | — | **PI** | Resolver empresa y enviar `RMPEKING` en el payload | — |
| 3 | `ProductControllerTwo` | Doc. original §3 fila 5 | Rama explícita | Modificada | 6 | Adopta lookup `Opportunity.Empresa_Operadora__c` | rama sprint1 | `0AfAK000000vokr0AA` | Sí, desplegadas | **ID** | — | — |
| 4 | `servicioReservas` | Doc. original §3 fila 5 | Rama explícita | Sin cambios | — | Ninguno | — | — | — | **PI** | Resolver `Product2.Empresa__c` sin normalización binaria | — |
| 5 | `ServicioReservaApartadoArticulosQuote` | Doc. original §3 fila 5 | Rama explícita | Sin cambios | — | Ninguno | — | — | — | **PI** | Rama `RMPEKING` en `realizarReservaApartado` | — |
| 6 | `ServicioConsDispBodegaQuoli` | Doc. original §3 fila 5 | Rama explícita | Sin cambios | — | Ninguno | — | — | — | **PI** | Rama `RMPEKING`; eliminar `else` a Otobai | — |
| 7 | `servicioEliminarReserva` | Doc. original §3 fila 5 | Rama explícita | Sin cambios | — | Ninguno | — | — | — | **PI** | Resolver por código, no por normalización | — |
| 8 | `ServicioEliminarReservaArticuloQuote` | Doc. original §3 fila 5 | Rama explícita | Sin cambios | — | Ninguno | — | — | — | **PI** | Rama `RMPEKING`; validar bodega | — |
| 9 | `ServicioCrearSCQuote` | Doc. original §3 fila 5 | Rama explícita | Sin cambios | — | Ninguno | — | — | — | **PI** | Código ERP desde contexto | — |
| 10 | `QuoteController` | Doc. original §3 fila 6 | 2 Pricebooks + ramas | Modificada | 2 | Seis nombres autorizados, sin fallback | `9669237` | `0AfAK000000vlTd0AI` | 22/22 | **ID** | — | — |
| 11 | `cT_QuoteCrcPDFController` | Doc. original §3 fila 6 | 2 Pricebooks + ramas | Modificada | 12 | `PEKING Dólares` → `PEKING Local`; retirado `Test.isRunningTest()` | rama sprint1 | `0AfAK000000vpk90AA` | Sí, desplegadas | **ID** | — | — |
| 12 | `cT_QuoteUsdPDFController` | Doc. original §3 fila 6 | 2 Pricebooks + ramas | Modificada | 11 | `PEKING Local` → `PEKING Dólares`; retirado `Test.isRunningTest()` | rama sprint1 | `0AfAK000000vpfJ0AQ` | Sí, desplegadas | **ID** | — | — |
| 13 | `UpdateCurrencyScheduler` | Doc. original §3 fila 6 | 2 Pricebooks + ramas | Modificada | 3 | Corrección CRC/USD para los dos Pricebooks PEKING | rama sprint1 | `0AfAK000000vllN0AQ` | 7/7 | **ID** | Riesgo heredado de borrar antes de reinsertar, no autorizado | — |
| 14 | `BMW_ChangeCurrencyWOWOLI` | Doc. original §3 fila 6 | 2 Pricebooks + ramas | Modificada | 2 | Seis nombres autorizados, sin fallback | `9669237` | `0AfAK000000vlTd0AI` | 22/22 | **ID** | — | — |
| 15 | `OpportunityServiceInvoker` | Doc. original §3 fila 7 | Comparación explícita | Sin cambios | — | Ninguno | — | — | — | **PI** | Eliminar default Bavarian; resolver desde Opportunity | — |
| 16 | `Registrar_Anticipo_Controller` | Doc. original §3 fila 7 | Comparación explícita | Sin cambios | — | Ninguno | — | — | — | **PI** | Resolver una vez por transacción en dos bloques | — |
| 17 | `savePDFfile` | Doc. original §3 fila 7 | Comparación explícita | Sin cambios | — | Ninguno | — | — | — | **BLQ** | Política documental/email por empresa | Falta decisión de branding, territorios y correos para PEKING |
| 18 | `BatchGetCategoriaClienteSoftland` | Doc. original §3 fila 8 (familia) | Parametrizar 3 compañías | Sin cambios | — | Ninguno | — | — | — | **BLQ** | Parametrizar código ERP | Falta confirmar si PEKING integra catálogos Softland |
| 19 | `BatchGetCentroCostoSoftland` | Doc. original §3 fila 8 (familia) | Parametrizar 3 compañías | Sin cambios | — | Ninguno | — | — | — | **BLQ** | Igual | Igual |
| 20 | `BatchGetCondicionPagoSoftland` | Doc. original §3 fila 8 (familia) | Parametrizar 3 compañías | Sin cambios | — | Ninguno | — | — | — | **BLQ** | Igual | Igual |
| 21 | `BatchGetCuentaContableSoftland` | Doc. original §3 fila 8 (familia) | Parametrizar 3 compañías | Sin cambios | — | Ninguno | — | — | — | **BLQ** | Igual | Igual |
| 22 | `BatchGetImpuestoSoftland` | Doc. original §3 fila 8 (familia) | Parametrizar 3 compañías | Sin cambios | — | Ninguno | — | — | — | **BLQ** | Igual | Igual |
| 23 | `BatchGetSubtipoDocumentoSoftland` | Doc. original §3 fila 8 (familia) | Parametrizar 3 compañías | Sin cambios | — | Ninguno | — | — | — | **BLQ** | Igual | Igual |
| 24 | `BatchGetBodegaSoftland` | Doc. original §9 | Recorrer las 3 compañías | Sin cambios | — | Ninguno | — | — | — | **BLQ** | Clave compuesta Empresa+bodega | Falta modelo de Bodega y confirmación de bodega PEKING |
| 25 | `BMWServiceQuoteApprovalEmailInvocable` | Doc. original §3 fila 9 | Rama de territorio nuevo | Solo recuperada en línea base | — | Ninguno | `2b9d850` (retrieve) | — | — | **BLQ** | Política de email por empresa | Falta territorio, destinatarios y branding de PEKING |

### 4.2 Triggers

| # | Trigger | Fuente exacta | Acción solicitada | Estado en Git | Bloque | Cambio realizado | Commit | Deploy ID | Pruebas | Estado real | Trabajo faltante | Bloqueo |
|---:|---|---|---|---|---|---|---|---|---|---|---|---|
| T1 | `WorkOrderTrigger` | Doc. original §3 fila 2 | Rama nueva compañía + 2 pricebooks | Modificado | 4 y 5 | Seis asociaciones empresa×moneda, lookup `empresaFacturaCP__c` con precedencia, literal `Garantia` corregido | rama sprint1 | `0AfAK000000vnon0AA` y `0AfAK000000vo4v0AA` | 50/50 | **ID** | — | — |
| T2 | `ChanceAccountBavarian` | Doc. original §3 fila 1 | Crear nuevo o refactorizar a genérico | Solo recuperado | — | Ninguno | `2b9d850` (retrieve) | — | — | **BLQ** | Consolidar protección configurable | Falta definir si las cuentas son empresas facturadoras o cuentas técnicas |
| T3 | `ChanceAccountContado` | Doc. original §3 fila 1 | Crear nuevo o refactorizar a genérico | Solo recuperado | — | Ninguno | `2b9d850` (retrieve) | — | — | **BLQ** | Igual | Igual; además no representa claramente una empresa |
| T4 | `ChanceAccountOtobai` | Doc. original §3 fila 1 | Crear nuevo o refactorizar a genérico | Solo recuperado | — | Ninguno | `2b9d850` (retrieve) | — | — | **BLQ** | Igual | Igual; además pendiente confirmar si está dentro de los "3" de Luis |

### 4.3 Componentes trabajados fuera del alcance documental

Se registran para trazabilidad. Estado **NP** según el documento original; podrían
pertenecer a la tabla de Luis.

| Clase | Bloque | Estado real | Deploy ID |
|---|---:|---|---|
| `CrearPlandeVenta` | 7 | **ID** (NP documental) | `0AfAK000000vpIj0AI` |
| `TrabajoQuoteController` | 13 | **ID** (NP documental) | `0AfAK000000vpx30AA` |
| `TrabajoController` | 14 | **ID** (NP documental) | `0AfAK000000vqGP0AY` |
| `BMWVinScanTrabajoGenerator` | 15 | **ID** (NP documental) | `0AfAK000000vqeb0AA` |
| `QuoterController` | 16 | **ID** (NP documental) | `0AfAK000000vqt70AA` |
| `ProductSearcherController` | 18 | **IL** (NP documental) | — |

### 4.4 Soporte del modelo (presupuesto separado de 14 horas)

No forman parte de las 33 clases; corresponden al presupuesto de modelo y soporte.

| Componente | Estado real | Deploy ID |
|---|---|---|
| `Empresa__c` + 4 campos | **ID** | `0AfAK000000vhrR0AQ` |
| `EmpresaContext`, `EmpresaResolver`, `EmpresaConfigurationException` | **ID** | `0AfAK000000vhrR0AQ` |
| `Empresa_Admin` (Permission Set) | **ID** | `0AfAK000000viHF0AY` |

## 5. Cálculo

### 5.1 Totales

| Concepto | Valor |
|---|---:|
| Clases del alcance documental derivado | 25 |
| Clases que Luis comunicó | ~33 |
| Diferencia no atribuible sin la tabla de Luis | 8 |
| Triggers nombrados en el documento original | 4 |
| Triggers que Luis comunicó | 3 |

### 5.2 Estado sobre las 25 clases documentales

| Estado | Clases | % |
|---|---:|---:|
| Implementado y desplegado | 7 | 28.0% |
| Implementado local, no desplegado | 0 | 0.0% |
| Revisado, sin cambio necesario | 0 | 0.0% |
| Pendiente de implementar | 8 | 32.0% |
| Bloqueado por dato/decisión externa | 10 | 40.0% |
| **Total** | **25** | **100%** |

### 5.3 Estado sobre los triggers

| Estado | Triggers (base 4) | % |
|---|---:|---:|
| Implementado y desplegado | 1 | 25.0% |
| Bloqueado por decisión externa | 3 | 75.0% |

Sobre la base de 3 triggers de la tabla de Luis, y bajo la lectura de que esos 3
son la familia `ChanceAccount*`, el avance es **0 de 3 (0%)**.

### 5.4 Porcentaje sobre componentes exactos

| Base de cálculo | Desplegado | Total | % |
|---|---:|---:|---:|
| 25 clases documentales | 7 | 25 | **28.0%** |
| 25 clases + 4 triggers | 8 | 29 | **27.6%** |
| Base declarada por Luis (33 + 3) | 8 | 36 | **22.2%** |

Los 6 componentes de la sección 4.3 y las 4 piezas de soporte de la 4.4 no se
suman a estos porcentajes por no pertenecer al alcance documental verificable.
Si la tabla de Luis los incluyera, el avance sobre 33 + 3 subiría a 14 de 36
(**38.9%**), cifra que **no debe reportarse** hasta contar con esa tabla.

### 5.5 Ninguna clase se marcó completada por haber sido analizada

Las 18 clases en estado **PI** o **BLQ** fueron analizadas en el inventario y el
plan, pero no tienen cambio productivo ni deploy. Analizar no es implementar.

## 6. Pendientes ejecutables priorizados

Criterio: mismo patrón binario ya resuelto en bloques desplegados, con
`EmpresaResolver` disponible en el org y sin decisión externa pendiente.

| Prioridad | Clase | Patrón | Por qué es ejecutable ya | Est. |
|---:|---|---|---|---:|
| 1 | `ServicioConsDispBodegaQuoli` | `Opportunity.BMW_Compania__c`: Bavarian → RM; `else` → Otobai | Receta idéntica a los bloques 13 y 14, ya desplegados | 2 h |
| 2 | `ServicioEliminarReservaArticuloQuote` | Igual | Misma fuente y mismo consumidor de Quote | 2 h |
| 3 | `ServicioReservaApartadoArticulosQuote` | Igual | Cierra el par reservar/liberar con la anterior | 3 h |
| 4 | `ServicioCrearSCQuote` | Igual | Mismo patrón; código ERP `RMPEKING` ya autorizado | 3 h |
| 5 | `QuoteSoftlandPedidoService` | Igual | Payload usa el código ERP ya confirmado | 3 h |
| 6 | `servicioReservas` | `Product2.Empresa__c`, normaliza dos códigos | `RMPEKING` ya activo en `Product2.Empresa__c` (bloque 17) | 2 h |
| 7 | `servicioEliminarReserva` | Igual | Cierra el par con la anterior | 2 h |
| 8 | `OpportunityServiceInvoker` | `contains('Otobai')` con default Bavarian | No requiere decisión externa; sí regresión de anticipos | 2 h |

Realista para cerrar antes de mañana: **prioridades 1 a 4** (10 h estimadas), o
1 a 3 más 6 y 7 si se prefiere cerrar el ciclo de reservas completo.

No ejecutable sin respuesta externa: los seis batches de catálogo,
`BatchGetBodegaSoftland`, `savePDFfile`, `BMWServiceQuoteApprovalEmailInvocable`
y los tres triggers `ChanceAccount*`.

## 7. Riesgo abierto de `ProductSearcherController`

El bloque 18 quedó pausado en `wip/pc/redmotors-block18-product-searcher-coverage-20260726`
(commit `5c287ba`). El código local pasa 14/14 pruebas, pero la cobertura de la
clase es 73.438%, por debajo del 75% exigido con `RunSpecifiedTests`. La
validación alternativa con `RunLocalTests` se canceló tras confirmar 287 fallas
ajenas al bloque. No se desplegó, y esa clase no está en el alcance documental.

## 8. Advertencias de reconciliación

1. Las 33 clases **no se reprodujeron**. Se documenta 25 con trazabilidad por fila.
2. La contradicción de triggers **no se resolvió**; se dejó una pregunta única.
3. No se reclasificó ninguna clase de Softland, reservas, anticipos o Pricebook
   como sprint posterior. Todas siguen dentro del alcance, en estado **PI** o **BLQ**.
4. El Manual amplio no se usó para sustituir la lista; solo se citó su omisión
   verificada de `ChanceAccountOtobai`.
5. No se afirma avance del 100% ni se actualizó ningún documento de cierre.
