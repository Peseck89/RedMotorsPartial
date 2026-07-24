# Inventario Apex — Sprint 1

> **Inventario local preliminar del repositorio; pendiente de validación contra RedMotorsSandbox.**

## 1. Propósito y alcance

Este documento identifica los componentes Apex con evidencia funcional relacionada con Empresa facturadora, Bavarian, Otobai, códigos `RMBAVARIAN`/`RMOTOBAI`, listas de precios, moneda, Softland, inventario, bodegas y reservas.

La revisión técnica detallada se limita al contenido presente en `force-app`. Posteriormente se realizó una validación de existencia y estado mediante Tooling API, de solo lectura, contra `RedMotorsSandbox`. No se realizó retrieve, modificación de metadata, edición de Apex, creación de objetos ni despliegue. Los dos documentos fuente se utilizaron como referencias de candidatos; una afirmación documental no se considera confirmada si el archivo no está presente y tampoco fue encontrado en el sandbox.

Las 986 clases locales **no constituyen el alcance**. Solamente 69 clases productivas tienen evidencia funcional suficiente para este inventario.

## 2. Resumen ejecutivo

| Categoría | Confirmado localmente | Confirmado local + sandbox | Confirmado solo en sandbox, pendiente de retrieve | Solo documental / no confirmado | Falso positivo |
|---|---:|---:|---:|---:|---:|
| Archivos `.cls` totales | 986 | No aplica | No aplica | No aplica | No aplica |
| Clases productivas relevantes | 69 | 69 | 5 | 0 | 5 candidatas documentales locales descartadas |
| Clases de test relacionadas | 57 | No determinado por la validación suministrada | 10 | 1 | 0 dentro del conteo confirmado |
| Triggers | 0 | 0 | 4 | 0 | 0 |
| Otros falsos positivos léxicos revisados | No aplica | No aplica | No aplica | No aplica | 4 |

**Falsos positivos totales clasificados: 9.** Son cinco candidatos de la matriz documental que no representan la empresa operadora y cuatro coincidencias adicionales obtenidas por búsqueda textual.

**Componentes confirmados solo en el sandbox y pendientes de retrieve: 19:** cinco clases productivas, diez tests y cuatro triggers.

**Solo documental / no confirmado en `RedMotorsSandbox`: 1:** `DummyRemovalCoverageTest`. No se asume que haya sido eliminado o renombrado.

## 3. Método reproducible

### 3.1 Conteo físico

Ejecutar desde la raíz del repositorio:

```powershell
$classes = @(rg --files force-app -g '*.cls')
$triggers = @(rg --files force-app -g '*.trigger')
"CLS=$($classes.Count) TRIGGER=$($triggers.Count)"
```

Resultado de esta línea base:

```text
CLS=986 TRIGGER=0
```

### 3.2 Búsqueda inicial de candidatos

```powershell
rg -i -l --glob '*.cls' --glob '*.trigger' `
  'Bavarian|Otobai|RMBAVARIAN|RMOTOBAI|empresaFactura|empresaQueFactura|BMW_Compania|Compania__c|Pricebook|Softland|inventario|bodega|reserva|CurrencyIsoCode|moneda|tipo.?de.?cambio' `
  force-app
```

La salida de esta búsqueda es deliberadamente amplia. No es un conteo de alcance: incluye tests, DTO, mocks, comentarios, nombres de métodos heredados, moneda de procesos no empresariales y campos homónimos.

### 3.3 Búsqueda de patrones de riesgo

```powershell
rg -n -i --glob '*.cls' `
  'Bavarian|Otobai|RMBAVARIAN|RMOTOBAI|empresaFactura__c|empresaQueFactura__c|BMW_Compania__c|Compania__c|Pricebook\.Name' `
  force-app/main/default/classes
```

También se revisaron manualmente:

- condiciones `if`/`else`, ternarios y retornos por defecto;
- `contains('Otobai')`;
- consultas o filtros por `Pricebook2.Name`;
- constantes de compañía y endpoints;
- campos que transportan compañía sin resolverla;
- SOQL/DML dentro de ciclos o métodos invocados por ciclos;
- correspondencia entre clases productivas y clases `@isTest`;
- candidatos listados en las dos fuentes documentales.

### 3.4 Regla de clasificación

Una clase se considera **productiva relevante** cuando su archivo local contiene al menos una de estas evidencias:

1. resuelve o transforma la empresa;
2. selecciona una lista de precios o moneda según empresa;
3. envía el código de empresa a Softland;
4. consulta, reserva o libera inventario/bodega con contexto empresarial;
5. propaga la empresa a Quote, Opportunity, Order o WorkOrder;
6. genera documentos o correos cuya identidad depende de empresa;
7. agenda o ejecuta procesos por códigos empresariales.

Una coincidencia se clasifica como **textual** cuando solo aparece en comentarios, textos descriptivos, URLs, nombres históricos o direcciones. Se clasifica como **falso positivo funcional** cuando el campo “empresa” representa empleador, cliente u otro concepto distinto de la empresa operadora/facturadora.

## 4. Validación de solo lectura contra RedMotorsSandbox — 24 de julio de 2026

### 4.1 Organización validada

| Dato | Valor confirmado |
|---|---|
| Alias | `RedMotorsSandbox` |
| Org Id | `00DAK000000npFt2AI` |
| Nombre | Red Motors |
| Tipo | Sandbox (`IsSandbox = true`) |
| Mecanismo | Tooling API, consultas de solo lectura |

No se realizó retrieve. La validación confirma existencia y estado en el org, pero no incorpora el cuerpo de las clases o triggers ausentes al repositorio local.

### 4.2 Resultado de la validación

- Las 69 clases productivas locales fueron consultadas en tres grupos.
- Las 69 existen y están `Active` en `RedMotorsSandbox`.
- Cinco clases productivas adicionales existen y están `Active`, pero no están presentes localmente.
- Cuatro triggers existen y están `Active`, pero no están presentes localmente.
- Diez de los once tests documentales pendientes existen y están `Active`, pero no están presentes localmente.
- `DummyRemovalCoverageTest` no fue encontrado. Se conserva como solo documental / no confirmado, sin inferir eliminación o renombre.

La validación resuelve la discrepancia sobre triggers: **`RedMotorsSandbox` contiene cuatro triggers candidatos, no tres**.

### 4.3 Estado probatorio posterior a la validación

| Estado | Componentes |
|---|---:|
| Clases productivas confirmadas localmente y en sandbox | 69 |
| Clases productivas confirmadas solo en sandbox | 5 |
| Triggers confirmados solo en sandbox | 4 |
| Tests confirmados localmente | 57 |
| Tests adicionales confirmados solo en sandbox | 10 |
| Solo documental / no confirmado | 1 |
| Falsos positivos | 9 |
| Pendientes de retrieve dirigido | 19 |

## 5. Discrepancias entre fuentes y repositorio local

- El repositorio local contiene **986 archivos `.cls`**.
- El repositorio local **no contiene archivos `.trigger`**.
- El manual técnico menciona tres triggers:
  - `ChanceAccountBavarian`
  - `ChanceAccountContado`
  - `WorkOrderTrigger`
- El PDF inicial también menciona `ChanceAccountOtobai`; existía una discrepancia entre las propias fuentes sobre si eran tres o cuatro candidatos.
- La validación del sandbox resolvió esta discrepancia: los cuatro triggers existen y están `Active`.
- La matriz del manual contiene 75 candidatas productivas: cinco no existen en el árbol local pero sí en el sandbox, y cinco presentes resultaron falsos positivos funcionales o textuales.
- La matriz documental de tests contiene 64 nombres: 53 están presentes localmente. La revisión local agregó cuatro tests relevantes no incluidos en esa matriz, para un total local confirmado de 57. De los once documentales que faltaban localmente, diez fueron encontrados en el sandbox.
- Las fuentes reflejan inspecciones de otros espejos y/o estados del org. Sus conteos no sustituyen una comparación contra el Sandbox Partial.

### 5.1 Clases productivas confirmadas solo en el sandbox

1. `BMWServiceQuoteApprovalEmailInvocable`
2. `BMWVinScanTrabajoGenerator`
3. `CrearPlandeVenta`
4. `HttpCalloutGetProductFreshRefPrices`
5. `ServicioCitasFieldService`

Las cinco existen y están `Active`; permanecen pendientes de retrieve.

### 5.2 Tests confirmados solo en el sandbox

1. `BMWVinScanTrabajoGeneratorTest`
2. `cT_assetChangeData_ctrl_test`
3. `cT_quoteChangeData_ctrl_tst`
4. `facturadaQuoteTest`
5. `MargenSustitutoCoverageTest`
6. `RM_TraerTrabajosEmailServiceTest`
7. `ServicioCrearSCQuoteTest`
8. `ServicioCrearSCWorkOrderTest`
9. `ServicioEliminarReservaArticuloQuoteTest`
10. `VehicleReservationHistoryServiceTest`

Los diez existen y están `Active`; permanecen pendientes de retrieve.

### 5.3 Solo documental / no confirmado

- `DummyRemovalCoverageTest`

No fue encontrado en `RedMotorsSandbox`. No se asume que fue eliminado o renombrado.

### 5.4 Triggers confirmados solo en el sandbox

1. `ChanceAccountBavarian.trigger`
2. `ChanceAccountContado.trigger`
3. `WorkOrderTrigger.trigger`
4. `ChanceAccountOtobai.trigger`

Los primeros tres provienen del manual. El cuarto aparece en el PDF inicial. Los cuatro existen, están `Active` y permanecen pendientes de retrieve. Sus objetos asociados son:

| Trigger | Objeto |
|---|---|
| `ChanceAccountBavarian` | Account |
| `ChanceAccountContado` | Account |
| `ChanceAccountOtobai` | Account |
| `WorkOrderTrigger` | WorkOrder |

## 6. Hallazgos transversales críticos

### 5.1 `if Otobai / else Bavarian` o equivalente

Se confirmó el patrón binario o un fallback equivalente en:

- `BMW_ChangeCurrencyWOWOLI`
- `BMW_LineaPlantillaEmpresa`
- `BusquedaDetalladaController`
- `http_Helper`
- `OpportunityServiceInvoker`
- `ProductControllerTwo`
- `QuoteSoftlandPedidoService`
- `Registrar_Anticipo_Controller`
- `RM_VN_CambiarUbicacion_Ctrl`
- `ServicioConsDispBodegaQuoli`
- `ServicioCrearSCQuote`
- `ServicioEliminarReservaArticuloQuote`
- `ServicioReservaApartadoArticulosQuote`
- `TrabajoQuoteController`

Una tercera empresa puede caer en Bavarian o en Otobai dependiendo de la clase. El problema no es solamente el valor hardcodeado: cada clase implementa una regla de precedencia distinta.

### 5.2 `contains('Otobai')`

Confirmado en:

- `OpportunityServiceInvoker`
- `Registrar_Anticipo_Controller`
- `savePDFfile` — sobre territorio/sucursal, para correo de despacho.

Los dos primeros inicializan `RMBAVARIAN` y solo cambian a `RMOTOBAI` cuando el nombre contiene Otobai; por tanto tienen fallback implícito a Bavarian.

### 5.3 Comparaciones por `Name` y `Pricebook.Name`

Confirmadas en:

- `BMW_ChangeCurrencyWOWOLI`
- `BusquedaDetalladaController`
- `cT_QuoteCrcPDFController`
- `cT_QuoteUsdPDFController`
- `OpportunityServiceInvoker`
- `QuoteController`
- `Registrar_Anticipo_Controller`
- `UpdateCurrencyScheduler`
- `ProductSearcherController`
- `precioProductoJSON`
- `RM_Lead_Trigger_Helper`
- `RM_VN_Service`
- `RM_VU_Service`

El nombre visible de Pricebook funciona como clave técnica. Esto es frágil ante renombres, tildes, singular/plural (`Dólar`/`Dólares`), espacios y nuevas empresas.

### 5.4 Códigos empresariales hardcodeados

`RMBAVARIAN` y/o `RMOTOBAI` aparecen como decisiones activas en batches, schedulers, servicios de reservas, inventario, anticipos, creación de kits y generación de payloads. El caso más peligroso es un literal único `RMBAVARIAN`, porque excluye incluso a Otobai:

- `BatchGetCategoriaClienteSoftland`
- `BatchGetCentroCostoSoftland`
- `BatchGetCondicionPagoSoftland`
- `BatchGetCuentaContableSoftland`
- `BatchGetImpuestoSoftland`
- `BatchGetSubtipoDocumentoSoftland`
- `HttpCalloutGetProductRefPrices`
- `ProductoLocalizacionHelper`
- `ServicioEnvioEncuestaSoftland` cuando la entrada viene vacía.

### 5.5 IDs y endpoints hardcodeados

No se confirmó un Salesforce Id literal como mecanismo principal para resolver empresa en las 69 clases. Sí se observaron endpoints/IP integrados directamente en clases como `OrderBatch`, `ExternalServiceCaller`, `ReservaOportunidadController` y `ReservaOppUsadosController`. Se deben tratar como deuda de configuración de integración, sin copiar sus valores a documentación funcional ni a un nuevo modelo.

### 5.6 Bulkificación

Riesgos confirmados:

- `ProductControllerTwo`: consulta directa por Quote en un método de controlador; debe revisar volumen de invocación.
- `productJSON` y `precioProductoJSON`: consultas de Pricebook/bodega en ramas y procesamiento de respuestas; precargar mapas por empresa, código y moneda.
- `ReservaOportunidadController` y `ReservaOppUsadosController`: múltiples consultas y DML secuenciales en `makeReserva`; servicio diseñado para una reserva por llamada, no para lotes.
- `ServicioCrearSCQuote`, `ServicioConsDispBodegaQuoli`, `ServicioEliminarReservaArticuloQuote` y `ServicioReservaApartadoArticulosQuote`: consulta única por invocación y transformación binaria; deben recibir contextos precargados si se reutilizan en lotes.
- `UpdateCurrencyScheduler`: consulta acotada por tiempo, pero selector fijo de cuatro nombres; debe procesar empresas activas y aislar fallos por empresa.
- `BatchGet*Softland`: cada batch atiende un código fijo o recibido; la orquestación debe iterar configuración activa sin crear consultas/callouts por registro.

No se afirma que toda consulta individual sea un defecto de límites. La prioridad se asigna cuando el patrón se combina con bucles, scheduler/batch o posibilidad real de invocación masiva.

## 7. Inventario productivo local confirmado

Ruta base común: `force-app/main/default/classes/`. En la columna “test” se indica la prueba principal cuando es identificable; “sin test directo identificado” no significa cobertura cero, sino ausencia de correspondencia inequívoca por nombre o uso local.

### 7.1 Resolución de empresa

| Clase | Métodos afectados | Campo/señal | Hardcode y comportamiento actual | Riesgo tercera empresa | Test asociado | Cambio recomendado | Prioridad |
|---|---|---|---|---|---|---|---|
| `BMW_LineaPlantillaEmpresa.cls` | `getEmpresa` | `Plantilla_de_Presupuesto__c.BMW_Compania__c` | Bavarian → `RMBAVARIAN`; cualquier otro valor → `RMOTOBAI` | Crítico: default a Otobai | `BMW_LineaPlantillaEmpresa_Test` | Resolver lookup/código y lanzar excepción si no está configurada | Crítica |
| `http_Helper.cls` | construcción de compañía para request | `Opportunity.empresaQueFactura__c` | Ternario Bavarian → `RMBAVARIAN`; resto → `RMOTOBAI` | Crítico | tests de callout indirectos | Usar `EmpresaResolver` | Crítica |
| `OpportunityServiceInvoker.cls` | invocación principal | `Opportunity.Pricebook2.Name` | Inicializa `RMBAVARIAN`; solo `contains('Otobai')` cambia a `RMOTOBAI` | Crítico: default Bavarian | `OpportunityServiceInvokerTest` | Resolver por relación de Pricebook a Empresa | Crítica |
| `Registrar_Anticipo_Controller.cls` | registro y consulta de anticipo | `Opportunity.Pricebook2.Name` | Mismo fallback a Bavarian en dos bloques | Crítico | `Registrar_Anticipo_Controller_Test`, `RegistrarAnticipoCasillasTst` | Resolver una vez y reutilizar contexto | Crítica |
| `ProductControllerTwo.cls` | consulta de productos por Quote | `Quote.Opportunity.BMW_Compania__c` | Dos `if`: Bavarian/Otobai; otros valores quedan sin normalizar | Alto | `ProductControllerTwoTest`, `TestServiciosQuote` | Recibir `EmpresaContext` explícito | Crítica |
| `RM_VN_CambiarUbicacion_Ctrl.cls` | resolución interna de código | empresa recibida | Solo `OTOBAI` → `RMOTOBAI`; cualquier otro → `RMBAVARIAN` | Crítico: default Bavarian | `RM_VN_CambiarUbicacion_Ctrl_Test` | Tabla de códigos, sin retorno default | Crítica |
| `TrabajoQuoteController.cls` | selección de tareas/empresa | `Quote.Opportunity.BMW_Compania__c` | Bavarian/RMBavarian → `RMBAVARIAN`; resto → `RMOTOBAI` | Crítico | `TrabajoQuoteControllerTest` | Resolver por Id/código estable | Crítica |
| `cls_DMLHelper.cls` | consultas y persistencia de pedidos | `empresaQueFactura__c` | Propaga valor existente sin validarlo | Alto: datos inválidos llegan a integración | tests de servicios/pedidos | Validar con resolver antes de DML/callout | Alta |

### 7.2 Pricebooks y moneda

| Clase | Métodos afectados | Campo/señal | Hardcode y comportamiento actual | Riesgo tercera empresa | Test asociado | Cambio recomendado | Prioridad |
|---|---|---|---|---|---|---|---|
| `BMW_ChangeCurrencyWOWOLI.cls` | cambio de moneda de WorkOrder/WOLI | `WorkOrder.Pricebook2.Name`, `CurrencyIsoCode` | Otobai explícito; `else` selecciona Bavarian | Crítico | `BMW_ChangeCurrencyWOWOLITest`, `BMW_ExpenseProcessTest` | Selector por Empresa + moneda + canal | Crítica |
| `BusquedaDetalladaController.cls` | `getActivePricebooks` | sucursal y `Pricebook2.Name` | Filtros `Bavarian%`/`Otobai%` | Alto: nueva empresa invisible | `BusquedaDetalladaTest` | Consultar Pricebooks relacionados a Empresa | Alta |
| `cT_QuoteCrcPDFController.cls` | constructor/conversión | nombre de Pricebook | Bavarian Dólar↔Local; Otobai Dólares↔Local | Alto | `cT_QuoteCrcPDFController_test` | Selector único y validación de par monetario | Alta |
| `cT_QuoteUsdPDFController.cls` | constructor/conversión | nombre de Pricebook | Mapeo inverso por nombre | Alto | `cT_QuoteUsdPDFController_test` | Igual que anterior | Alta |
| `QuoteController.cls` | cambio/búsqueda de Pricebook | `Pricebook2.Name` | Cuatro nombres exactos; contiene además un literal con tabulación | Crítico | `QuoteControllerTest` | Selector declarativo; eliminar nombres técnicos | Crítica |
| `QuoteService.cls` | consultas/servicio de Quote | constante de Pricebook | Default `Bavarian Dólar` | Alto | `QuoteServiceControllerTest` | No usar constante empresarial global | Alta |
| `QuoterController.cls` | selección de Pricebook | constante de Pricebook | Default `Bavarian Dólar` | Alto | `QuoterControllerTest` | Resolver desde Opportunity/Empresa | Alta |
| `UpdateCurrencyScheduler.cls` | `execute` | `PricebookEntry.Pricebook2.Name`, moneda | Solo cuatro Pricebooks Bavarian/Otobai | Crítico: no procesa tercera empresa | `UpdateCurrencySchedulerTest` | Iterar configuración activa por Empresa | Crítica |
| `precioProductoJSON.cls` | precios de referencia | código de empresa | Selecciona listas Bavarian/Otobai por nombre | Crítico | `precioProductoJSONTest` | Repositorio de Pricebook por claves estables | Crítica |
| `ProductSearcherController.cls` | búsqueda de vehículos/precios | marca, nombre de Pricebook | `Bavarian Dólar`, `preciosBavarian`; asigna Bavarian/Otobai | Alto | `ProductSearcherControllerTest`, pruebas VN | DTO por empresa; no arrays fijos | Alta |
| `RM_Lead_Trigger_Helper.cls` | `getPBBavarianId`, `getBavarianPricesByPlaca` | Pricebook de usados | Implementación nominalmente Bavarian | Alto | `RM_Lead_Trigger_Helper_Test` | Selector por empresa de la Opportunity/Lead | Alta |
| `RM_VN_Service.cls` | `getSoftlandPriceBookId`, `gePBEBavarian` | marca/configuración de venta | Nombre histórico Bavarian y supuestos de lista | Alto | pruebas VN/DataFactory | Devolver configuración empresarial, no método Bavarian | Alta |
| `RM_VU_Inventario_Ctrl.cls` | consulta de inventario usado | Pricebook Id/moneda | Delega a `gePBEBavarian` | Alto | `RM_VU_Inventario_Ctrl_Test` | Pasar Empresa explícita | Alta |
| `RM_VU_Service.cls` | `gePBEBavarian` | Pricebook Id/moneda | Servicio de inventario con semántica Bavarian | Alto | `RM_VU_Service_Test` | Generalizar por EmpresaContext | Alta |

### 7.3 Softland, catálogo y pedidos

| Clase | Métodos afectados | Campo/señal | Hardcode y comportamiento actual | Riesgo tercera empresa | Test asociado | Cambio recomendado | Prioridad |
|---|---|---|---|---|---|---|---|
| `BatchGetCategoriaClienteSoftland.cls` | `execute`/callout | ninguno configurable | endpoint usa `RMBAVARIAN` | Crítico: excluye otras empresas | test homónimo | Parametrizar/iterar empresas activas | Crítica |
| `BatchGetCentroCostoSoftland.cls` | `execute`/callout | ninguno configurable | `RMBAVARIAN` | Crítico | test homónimo | Igual | Crítica |
| `BatchGetCondicionPagoSoftland.cls` | `execute`/callout | ninguno configurable | `RMBAVARIAN` | Crítico | test homónimo | Igual | Crítica |
| `BatchGetCuentaContableSoftland.cls` | `execute`/callout | ninguno configurable | `RMBAVARIAN` | Crítico | test homónimo | Igual | Crítica |
| `BatchGetImpuestoSoftland.cls` | `execute`/callout | ninguno configurable | `RMBAVARIAN` | Crítico | test homónimo | Igual | Crítica |
| `BatchGetSubtipoDocumentoSoftland.cls` | `execute`/callout | ninguno configurable | `RMBAVARIAN` | Crítico | test homónimo | Igual | Crítica |
| `BatchGetBodegaSoftland.cls` | ejecución de carga de bodegas | parámetro `company` | Prefijo especial solo para `RMOTOBAI` | Alto: clave externa inconsistente | `BatchGetBodegaSoftlandTest` | Clave compuesta Empresa+código | Crítica |
| `ExternalServiceCaller.cls` | envío de recibo usado | `ReciboUsado__c.Empresa__c` | Propaga valor a `compania`; endpoint embebido | Alto | `TestExternalServiceCaller` | Resolver/validar Empresa y externalizar conexión | Alta |
| `HttpCalloutCreateKit.cls` | creación de kit | `Opportunity.RecordType.Name` | BMW/MINI/Motorrad → `RMBAVARIAN`; resto → `RMOTOBAI` | Crítico | `HttpCalloutCreateKitTest` | Marca/RT no deben ser default de empresa | Crítica |
| `HttpCalloutGetProductRefPrices.cls` | `getProductRefPricesPOST` | ninguno | payload siempre `RMBAVARIAN` | Crítico | `HttpCalloutGetProductRefPricesTest` | Recibir código ERP validado | Crítica |
| `QuoteSoftlandPedidoService.cls` | creación/envío de pedido | `Opportunity.BMW_Compania__c` | Bavarian → `RMBAVARIAN`; resto → `RMOTOBAI` | Crítico | pruebas Quote/servicios | Contexto único para payload | Crítica |
| `QuoteSoftlandQueryService.cls` | constructor/consulta | `Opportunity.BMW_Compania__c` | Obtiene señal para servicio posterior | Alto | pruebas Quote indirectas | Consultar lookup Empresa | Alta |
| `doCalloutCancelarPedidoSoftland.cls` | cancelación/estado | `Order.empresaQueFactura__c` | Propaga valor sin validar | Alto | test homónimo | Validar configuración antes del callout | Alta |
| `OrderBatch.cls` | `start`, `execute` | `Work_Order__r.empresaFactura__c` | Propaga empresa; contiene endpoint/caso RMBAVARIAN embebido | Crítico | `OrderBatchTest` | Gateway por empresa y configuración segura | Crítica |
| `orderJSONData.cls` | generación de payload | `Order.empresaQueFactura__c` | Usa vacío si no hay empresa | Crítico: default silencioso vacío | `TestOrderSoftlandWrapper` y pruebas de servicios | Excepción por empresa ausente | Crítica |
| `generarPedidoJSONData.cls` | generación de pedido WO | `WorkOrder.empresaFactura__c` | Usa vacío si es nulo | Crítico | `TestServiciosWorkOrder` | Igual | Crítica |
| `ServicioCrearSCWorkOrder.cls` | solicitud de compra | `WorkOrder.empresaFactura__c` | Propaga código | Alto | candidato documental ausente | Validar EmpresaContext | Alta |
| `ServicioGenerarPedidoFlow.cls` | generación desde Flow | `WorkOrder.empresaFactura__c` | Consume valor legado | Alto | `ServicioGenerarPedidoFlow_Test` | Resolver antes de generar pedido | Alta |
| `ServicePayment.cls` | pago de WorkOrder | `WorkOrder.empresaFactura__c` | Envía compañía tal cual | Alto | `ServicePaymentTest` | Fail-closed si no está configurada | Alta |
| `ServicioEnvioEncuestaSoftland.cls` | invocable/request | `req.compania` | Si viene vacío usa `RMBAVARIAN` | Crítico: default silencioso | `ServicioEnvioEncuestaSoftlandTest` | Entrada obligatoria y validada | Crítica |

### 7.4 Inventario, bodegas y reservas

| Clase | Métodos afectados | Campo/señal | Hardcode y comportamiento actual | Riesgo tercera empresa | Test asociado | Cambio recomendado | Prioridad |
|---|---|---|---|---|---|---|---|
| `consultaDisponibleBodega.cls` | `consultarDisponibilidad` | `WorkOrder.EmpresaFactura__c` | Propaga empresa a Softland | Alto | `TestConsultaDisponibleBodega` | EmpresaContext desde WorkOrder | Alta |
| `ProductController.cls` | métodos de producto por WO | `WorkOrder.empresaFactura__c` | Consulta la empresa, sin resolver | Alto | `ProductControllerTest` | Reutilizar contexto cargado | Alta |
| `productJSON.cls` | disponibilidad/precios/bodegas | `Product2.Empresa__c`/parámetro | Ramas `RMBAVARIAN`/`RMOTOBAI`; prefijo Otobai | Crítico | `productJSONTest` | Repositorios de producto/bodega por Empresa | Crítica |
| `ProductoLocalizacionHelper.cls` | construcción de request | ninguno | compañía fija `RMBAVARIAN` | Crítico | `ProductoLocalizacionHelperTest` | Parámetro obligatorio validado | Crítica |
| `ReservaOportunidadController.cls` | `makeReserva`, `reservarVehiculo` | `Product2.Empresa__c` | Envía el valor del producto | Crítico por reserva cruzada y secuencia no bulk | `ReservaOportunidadControllerTst` | Validar coherencia Producto–Empresa–Opportunity | Crítica |
| `ReservaOppUsadosController.cls` | `makeReserva`, `reservarVehiculo` | `Product2.Empresa__c` | Igual para usados | Crítico | `ReservaOppUsadosControllerTest` | Igual | Crítica |
| `servicioReservas.cls` | `getReservaById` y reserva | `Product2.Empresa__c` | Normaliza Bavarian/Otobai; solo admite dos códigos RM | Crítico | `servicioReservasTest` | Resolver sin mutar semánticamente Product2 | Crítica |
| `servicioEliminarReserva.cls` | liberación de reserva | `Product2.Empresa__c` | Bavarian → RM; lógica posterior favorece dos valores | Crítico | `servicioEliminarReservaTest` | Resolver por configuración | Crítica |
| `ServicioConsDispBodegaQuoli.cls` | consulta de disponibilidad Quote | `Opportunity.BMW_Compania__c` | Bavarian → RM; resto → Otobai | Crítico | `ServicioConsDispBodegaQuoliTest` | Resolver explícitamente | Crítica |
| `ServicioEliminarReservaArticulo.cls` | eliminación en WorkOrder | `WorkOrder.EmpresaFactura__c` | Propaga valor; ejemplo/literal RMBAVARIAN embebido | Alto | `TestServicioEliminarReservaArticulo` | Contexto y payload tipado | Alta |
| `ServicioEliminarReservaArticuloQuote.cls` | eliminación en Quote | `Opportunity.BMW_Compania__c` | Bavarian → RM; resto → Otobai | Crítico | test documental ausente | Resolver y bloquear desconocida | Crítica |
| `ServicioReservaApartadoArticulos.cls` | `realizarReservaApartado` | `WorkOrder.EmpresaFactura__c` | Propaga valor; literal RMBAVARIAN residual | Alto | `TestServicioReservaApartadoArticulos` | Contexto validado | Alta |
| `ServicioReservaApartadoArticulosQuote.cls` | `realizarReservaApartado` | `Opportunity.BMW_Compania__c` | Bavarian → RM; resto → Otobai | Crítico | `SRAArticulosQuoteTest` | Resolver sin else binario | Crítica |
| `ServicioCrearSCQuote.cls` | solicitud de compra Quote | `Opportunity.BMW_Compania__c` | Bavarian → RM; resto → Otobai | Crítico | test documental ausente | EmpresaContext único | Crítica |
| `WoliGridController.cls` | precios, ubicaciones, reserva/liberación | parámetro `empresaFactura`, WorkOrder | Orquesta servicios; confía en valor recibido | Alto | `WoliGridTest` | Resolver en servidor desde registro | Alta |
| `WoliGridController2.cls` | mismos métodos versión 2 | parámetro `empresaFactura`, WorkOrder | Igual | Alto | `WoliGridTest2` | Consolidar y resolver en servidor | Alta |

### 7.5 Opportunity, Quote, Order y WorkOrder/taller

| Clase | Métodos afectados | Campo/señal | Hardcode y comportamiento actual | Riesgo tercera empresa | Test asociado | Cambio recomendado | Prioridad |
|---|---|---|---|---|---|---|---|
| `TrabajoController.cls` | carga de trabajos por WO | `WorkOrder.empresaFactura__c`, `Pricebook2.Name` | Propaga empresa y depende de Pricebook | Alto | `TrabajoControllerTest` | Contexto de WorkOrder y selector | Alta |
| `ServicioCitas.cls` | resolución de sucursal/servicio | sucursal/servicio `Otobai` | Ramas explícitas por nombre de sucursal | Alto: nueva red de talleres invisible | `ServicioCitasTest` | Relacionar ServiceTerritory con Empresa | Alta |
| `CT_nuevaCita_controller.cls` | creación/resolución de cita | sucursal | Asigna `Otobai` como nombre operativo | Alto | `CT_nuevaCita_controller` tests indirectos | Territorio/Empresa configurables | Media |
| `cT_nuevaCitaGarantia_controller.cls` | cita de garantía | sucursal | Igual | Alto | tests indirectos | Igual | Media |
| `getHorasCitasFlow.cls` | invocable de horarios | sucursal | Asigna `Otobai` en dos ramas | Alto | `GetHorasCitasFlowTest` | Resolver territorio por Empresa | Alta |
| `BatchOppActivityUploader.cls` | exportación de actividad | distribuidor/vitrina | Razón social Bavarian fija | Alto: atribución incorrecta | pruebas batch indirectas | Tomar identidad legal de Empresa | Alta |

### 7.6 PDF, documentos y email

| Clase | Métodos afectados | Campo/señal | Hardcode y comportamiento actual | Riesgo tercera empresa | Test asociado | Cambio recomendado | Prioridad |
|---|---|---|---|---|---|---|---|
| `cT_QuotePDFEmail.cls` | generación del cuerpo de email | sin empresa explícita | Razón social `BAVARIAN MOTORS CR S.A.` repetida | Crítico: documento legal incorrecto | `cT_QuotePDFEmail_test` | `DocumentContext` desde Empresa | Crítica |
| `savePDFfile.cls` | guardado/enrutamiento | `ServiceTerritory.Name` | Correos por sucursal y `contains('Otobai')`; sin ruta para empresa nueva | Crítico | `savePDFfileTest` | Política documental/email por Empresa | Crítica |

### 7.7 Batch y scheduler

| Clase | Métodos afectados | Campo/señal | Hardcode y comportamiento actual | Riesgo tercera empresa | Test asociado | Cambio recomendado | Prioridad |
|---|---|---|---|---|---|---|---|
| `ScheduleGetActividadComercialSoftland.cls` | `execute` | ninguno | Encola códigos `RMBAVARIAN` y `RMOTOBAI`; localmente llama batch de aseguradora | Alto y posible defecto adicional | test homónimo | Iterar empresas activas y confirmar batch correcto | Alta |
| `ScheduleGetAseguradoraSoftland.cls` | `execute` | ninguno | Encola solo dos códigos | Alto | test homónimo | Iterar configuración | Alta |
| `ScheduleGetBodegaSoftland.cls` | `execute` | ninguno | Encola solo dos códigos | Crítico para inventario | test homónimo | Iterar empresas activas y aislar fallos | Crítica |

## 8. Clases de test confirmadas

Se confirmaron **57 archivos locales con `@isTest`** relacionados. Cincuenta y tres coinciden con la matriz documental y cuatro se agregaron por evidencia local directa:

- `actualizarFechaFacturacionVehiculoTest`
- `CreateProductAfterWizardControllerTest`
- `cT_QuoteUsdPDFController_test`
- `ReservaOppUsadosControllerTest`

Los 53 confirmados de la matriz documental son:

`BMW_ExpenseProcessTest`, `BMW_LineaPlantillaEmpresa_Test`, `BMW_presupuestoVencido_test`, `BusquedaDetalladaTest`, `ChanceAccountBavarianTest`, `ChanceAccountContadoTest`, `ClientesCallout_Test`, `cT_ChangeData_copy_ctrl_tst`, `cT_ChangeData_ctrl_tst`, `cT_QuoteCrcPDFController_test`, `GetHorasCitasFlowTest`, `HttpCalloutAddOrderTest`, `HttpCalloutCreateKitTest`, `HttpCalloutGetOrderLastResponsesTest`, `HttpCalloutGetProductAvailabilityTest`, `HttpCalloutGetProductRefPricesTest`, `OpportunityServiceInvokerTest`, `precioProductoJSONTest`, `productJSONTest`, `ProductoLocalizacionHelperTest`, `QuitarReservaControllerTst`, `QuitarReservaUsadosControllerTst`, `QuoteControllerTest`, `QuoterControllerTest`, `Registrar_Anticipo_Controller_Test`, `RegistrarAnticipoCasillasTst`, `RM_CT_TestDataFactory`, `RM_Lead_Trigger_Helper_Test`, `RM_TransferirProductoInteres_Test`, `RM_VN_CrearOportunidad_Ctrl_Test`, `RM_VN_CrearOppModeloInteres_Ctrl_Test`, `RM_VN_DataFactoryHelper`, `RM_VU_Inventario_Ctrl_Test`, `RM_VU_Service_Test`, `RM_VU_TestDataFactory`, `ServicePaymentTest`, `ServicioCitasTest`, `ServicioConsDispBodegaQuoliTest`, `servicioEliminarReservaTest`, `ServicioEnvioEncuestaSoftlandTest`, `servicioReservasTest`, `SRAArticulosQuoteTest`, `TestDataFactory`, `TestExternalServiceCaller`, `TestServicioEliminarReservaArticulo`, `TestServicioReservaApartadoArticulos`, `TestServiciosQuote`, `TestServiciosWorkOrder`, `TrabajoControllerTest`, `TrabajoQuoteControllerTest`, `UpdateCurrencySchedulerTest`, `WoliGridTest` y `WoliGridTest2`.

La existencia de un test no demuestra cobertura suficiente. Para Sprint 1 deben agregarse casos negativos de empresa nula, empresa desconocida, configuración incompleta y tercera empresa; también debe verificarse que ninguna prueba “apruebe” un fallback silencioso.

## 9. Falsos positivos

### 9.1 Candidatos documentales descartados localmente

| Clase | Motivo |
|---|---|
| `ClientesRequest.cls` | `nombreEmpresa` y `moneda` pertenecen a datos KYC/ingresos del cliente, no a empresa operadora. |
| `ct_CustomAsset.cls` | `Contact.Empresa__c` representa empresa/contacto externo; el manual ya advierte este homónimo. |
| `ct_traficoOrigenWeb.cls` | “Bavarian” aparece en una URL/texto de ubicación. Coincidencia textual. |
| `KPIEstadoTallerController.cls` | No se encontró señal local de empresa, Pricebook, Softland, bodega, reserva o moneda empresarial. |
| `wsCrearCotizacionAltica_Rest.cls` | `Cotizacion__c.Compania__c` corresponde al flujo Altica y no demuestra relación con la empresa operadora de este proyecto. Pendiente solo si negocio amplía alcance. |

### 9.2 Coincidencias léxicas adicionales descartadas

| Clase | Motivo |
|---|---|
| `AnticipoTriggerHandler.cls` | `RMBAVARIAN` aparece únicamente en código comentado. |
| `cT_ChangeData_copy_ctrl.cls` | “bavarian” forma parte de una dirección de correo técnica, no de una resolución de empresa. |
| `cT_ChangeData_ctrl.cls` | Mismo caso anterior. |
| `PendingTasksByBranchController.cls` | “Otobai” aparece únicamente en un comentario descriptivo de sucursales. |

## 10. Agrupación por dominio

| Dominio | Componentes confirmados | Lectura de Sprint 1 |
|---|---:|---|
| Resolución de empresa | 8 | Crear el núcleo común antes de refactorizar consumidores. |
| Pricebooks y moneda | 14 | Eliminar nombres como claves; relación Empresa+moneda+canal. |
| Softland | 20 | Código ERP obligatorio, sin defaults; orquestación por empresas activas. |
| Inventario, bodegas y reservas | 16 | Validar coherencia entre producto, bodega, Opportunity/WO y empresa. |
| Opportunity/Quote/Order | Transversal | Las señales están duplicadas y usan vocabularios distintos. |
| WorkOrder/taller | 6 principales más consumidores transversales | Relacionar territorios y listas de precios a Empresa. |
| PDF/documentos | 2 directos más controladores monetarios | Bloquear emisión si falta contexto legal. |
| Email | 2 directos | Identidad y destinatarios deben configurarse. |
| Batch/scheduler | 10, incluidos batches Softland | Iterar configuración activa y aislar fallos por empresa. |

Los conteos por dominio se solapan: una clase puede participar en varios dominios. No deben sumarse para reconstruir las 69 clases únicas.

## 11. Modelo mínimo propuesto para Sprint 1

### 11.1 `Empresa__c`

Campos mínimos:

| Campo | Tipo sugerido | Regla |
|---|---|---|
| `Name` | Text | Nombre visible; nunca clave de decisión. |
| `Codigo__c` | Text, Unique, External ID | Clave estable e inmutable dentro de Salesforce. |
| `Codigo_ERP__c` | Text, Unique según contrato | Código enviado a Softland. |
| `Nombre_Legal__c` | Text | Razón social para PDF/email. |
| `Identificacion_Tributaria__c` | Text | Identidad fiscal. |
| `Activa__c` | Checkbox | Una empresa inactiva no inicia transacciones nuevas. |
| `Moneda_Local__c` | Picklist/Text ISO | Moneda local operativa. |
| `Cuenta_Facturacion__c` | Lookup(Account), opcional | Cuenta legal/contable cuando aplique. |
| `Politica_Documental__c` | Text o relación de configuración | Selección de logos, plantillas y textos legales. |

Relaciones mínimas posteriores o paralelas:

- `Pricebook2.Empresa__c`;
- `Bodega__c.Empresa__c`;
- `Marca__c.Empresa__c` si negocio confirma exclusividad, o junction si una marca puede operar en varias empresas;
- `Empresa_Facturadora__c` en Opportunity, Quote, Order y WorkOrder;
- `ServiceTerritory.Empresa__c` o junction si un territorio es compartido.

### 11.2 Clases de soporte

#### `EmpresaResolver`

Responsabilidades:

- resolver por `Empresa__c` Id o `Codigo__c`;
- normalizar temporalmente valores legados Bavarian/Otobai/RM* mediante una tabla explícita;
- resolver desde Pricebook, WorkOrder, Quote u Opportunity con precedencia documentada;
- consultar en lote usando `Set<Id>` y mapas;
- no consultar por `Name`;
- no devolver Bavarian por defecto.

#### `EmpresaContext`

DTO inmutable mínimo:

- `empresaId`;
- `codigo`;
- `codigoErp`;
- `nombreLegal`;
- `monedaLocal`;
- `pricebookLocalId`;
- `pricebookUsdId`;
- indicador de configuración completa;
- referencias de política documental e integración.

#### `EmpresaConfigurationException`

Excepción funcional para:

- empresa ausente;
- código legado desconocido;
- Pricebook sin empresa;
- empresa sin código ERP;
- configuración monetaria incompleta;
- conflicto entre empresa del producto, documento, bodega o territorio.

### 11.3 Estrategia contra defaults silenciosos

1. No usar `else` como sinónimo de Bavarian u Otobai.
2. No inicializar variables con `RMBAVARIAN`.
3. No convertir nulos a cadena vacía en payloads.
4. Toda resolución debe terminar en contexto configurado o excepción.
5. Registrar la excepción con objeto, registro y dominio, sin datos sensibles.
6. Bloquear Softland, reserva o documento si el contexto no es válido.
7. Añadir pruebas negativas para empresa nula, desconocida y parcialmente configurada.

## 12. Componentes de prioridad crítica

Clases confirmadas que deben abordarse primero:

1. `BMW_LineaPlantillaEmpresa`
2. `BMW_ChangeCurrencyWOWOLI`
3. `OpportunityServiceInvoker`
4. `Registrar_Anticipo_Controller`
5. `QuoteController`
6. `UpdateCurrencyScheduler`
7. `QuoteSoftlandPedidoService`
8. `ProductControllerTwo`
9. `productJSON`
10. `precioProductoJSON`
11. `HttpCalloutCreateKit`
12. `HttpCalloutGetProductRefPrices`
13. `ServicioConsDispBodegaQuoli`
14. `ServicioCrearSCQuote`
15. `ServicioEliminarReservaArticuloQuote`
16. `ServicioReservaApartadoArticulosQuote`
17. `servicioReservas`
18. `servicioEliminarReserva`
19. `ReservaOportunidadController`
20. `ReservaOppUsadosController`
21. `OrderBatch`
22. `orderJSONData`
23. `generarPedidoJSONData`
24. `ServicioEnvioEncuestaSoftland`
25. `cT_QuotePDFEmail`
26. `savePDFfile`
27. los seis batches de catálogo Softland fijados a `RMBAVARIAN`
28. `BatchGetBodegaSoftland`
29. `ScheduleGetBodegaSoftland`

## 13. Decisiones pendientes

1. Código y nombre legal de la nueva empresa.
2. Código aceptado por Softland y si utiliza contrato/endpoints separados.
3. Si marca pertenece exclusivamente a una empresa o requiere relación muchos-a-muchos.
4. Si Product2 puede compartirse entre empresas.
5. Pricebooks requeridos por empresa, moneda, canal y vigencia.
6. Bodegas, claves externas y territorios exclusivos/compartidos.
7. Precedencia cuando Opportunity, Quote, WorkOrder, Product2 y Pricebook discrepan.
8. Política de documentos, logos, razón social, textos legales y emails.
9. Alcance de Ventas frente a Postventa/Taller.
10. Estrategia de seguridad y acceso cruzado.
11. Tratamiento de valores históricos nulos y del typo `Otobay`.
12. Retrieve y análisis de las clases, tests y triggers confirmados solo en el sandbox.

## 14. Distribución recomendada de horas del Sprint 1

Distribución propuesta para un Sprint 1 de **80 horas**, concentrado en línea base y diseño, no en refactor completo:

| Actividad | Horas | Porcentaje |
|---|---:|---:|
| Retrieve dirigido/consulta de solo lectura y conciliación del Sandbox Partial | 12 | 15% |
| Validación de clases, triggers y versiones activas | 10 | 12.5% |
| Cierre del inventario Apex y matriz de dependencias | 14 | 17.5% |
| Diseño de `Empresa__c`, relaciones y reglas de datos | 12 | 15% |
| Diseño de `EmpresaResolver`, `EmpresaContext` y excepción | 10 | 12.5% |
| Estrategia de migración, precedencia y fail-closed | 8 | 10% |
| Diseño de pruebas y criterios de aceptación | 8 | 10% |
| Revisión con negocio, integración, seguridad y arquitectura | 6 | 7.5% |
| **Total** | **80** | **100%** |

Si Sprint 1 no autoriza retrieve, las primeras 22 horas quedan bloqueadas o deben trasladarse a análisis documental, manteniendo la línea base como preliminar. La implementación completa de las 69 clases no cabe razonablemente en estas 80 horas.

## 15. Siguiente paso obligatorio para cerrar la línea base

La consulta de solo lectura ya confirmó la existencia y estado. Para convertir este inventario en línea base local completa se requiere un **retrieve dirigido de exactamente 19 componentes**:

- cinco clases productivas;
- cuatro triggers;
- diez tests.

### 15.1 Lista exacta del retrieve dirigido

Clases productivas:

1. `BMWServiceQuoteApprovalEmailInvocable`
2. `BMWVinScanTrabajoGenerator`
3. `CrearPlandeVenta`
4. `HttpCalloutGetProductFreshRefPrices`
5. `ServicioCitasFieldService`

Triggers:

6. `ChanceAccountBavarian`
7. `ChanceAccountContado`
8. `ChanceAccountOtobai`
9. `WorkOrderTrigger`

Tests:

10. `BMWVinScanTrabajoGeneratorTest`
11. `cT_assetChangeData_ctrl_test`
12. `cT_quoteChangeData_ctrl_tst`
13. `facturadaQuoteTest`
14. `MargenSustitutoCoverageTest`
15. `RM_TraerTrabajosEmailServiceTest`
16. `ServicioCrearSCQuoteTest`
17. `ServicioCrearSCWorkOrderTest`
18. `ServicioEliminarReservaArticuloQuoteTest`
19. `VehicleReservationHistoryServiceTest`

El retrieve no se realizó durante esta tarea. Hasta completarlo:

- las 69 clases productivas locales están confirmadas también en el sandbox;
- el conteo físico local sigue siendo 69 clases productivas relevantes, 57 tests relacionados y cero triggers;
- cinco clases productivas, cuatro triggers y diez tests están confirmados solo en el sandbox;
- `DummyRemovalCoverageTest` permanece solo documental / no confirmado;
- la discrepancia documental de triggers está resuelta a favor de cuatro componentes existentes en el sandbox;
- las diferencias de cuerpo y versión entre repositorio y sandbox no pueden analizarse hasta recuperar los 19 componentes.
