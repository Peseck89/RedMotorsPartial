# Plan de implementación — Sprint 1

## 1. Propósito

Este documento cierra el alcance técnico detectado para Empresa configurable y marcas chinas, clasifica los 74 componentes Apex productivos y los cuatro triggers confirmados, y propone un orden de implementación compatible con dos restricciones de tiempo.

Es un plan de análisis y ejecución futura. No implica que se hayan modificado clases, triggers, objetos, campos o configuración.

## 2. Línea base confirmada

| Tipo | Cantidad | Estado |
|---|---:|---|
| Clases productivas revisadas | 74 | Presentes localmente después de la sincronización desde RedMotorsSandbox |
| Clases de test relacionadas | 67 | Presentes localmente |
| Triggers revisados | 4 | Presentes localmente |
| Test solo documental | 1 | `DummyRemovalCoverageTest`, no confirmado |

Clasificación funcional:

| Clasificación | Clases | Triggers |
|---|---:|---:|
| Directo Sprint 1 | 41 | 1 |
| Dependencia indirecta | 21 | 0 |
| Requiere validación funcional | 12 | 3 |
| Fuera de Sprint 1 | 0 | 0 |
| Falso positivo dentro de los 74 | 0 | 0 |

Los nueve falsos positivos ya identificados en el inventario no forman parte de las 74 clases productivas de esta línea base.

## 3. Tres alcances que no deben confundirse

### 3.1 Alcance técnico total detectado

El alcance directo completo contiene **41 clases y un trigger**. Son componentes con decisiones empresariales binarias, códigos fijos, selección de Pricebook por nombre, defaults silenciosos o identidad documental dependiente de Bavarian/Otobai.

Este alcance representa la deuda que debe resolverse para que una tercera empresa opere de punta a punta. No cabe en 30 ni en 44 horas.

### 3.2 Alcance ejecutable en 30 horas totales

Incluye:

- modelo mínimo y clases de soporte: 14 horas;
- seis clases representativas: 14 horas;
- pruebas, estabilización y evidencia: 2 horas.

No incluye modificación de triggers. El resultado es una vertical técnica mínima que demuestra resolución sin defaults en Pricebook, Softland e inventario/reservas, pero no habilita todavía la tercera empresa de punta a punta.

### 3.3 Alcance ejecutable en 44 horas

Se interpreta como **30 horas Apex + 14 horas de modelo y soporte**, sin asumir que ambos presupuestos sean intercambiables.

Incluye:

- modelo mínimo y clases de soporte: 14 horas;
- doce clases productivas: 27 horas;
- `WorkOrderTrigger`: 2 horas;
- estabilización integrada: 1 hora.

El resultado cubre una vertical más completa: resolución, Pricebook/moneda, Softland, reserva de Quote, anticipos y asignación de Pricebook en WorkOrder. Aun así, no completa las 41 clases.

## 4. Diferencia entre las aproximadamente 33 clases comunicadas y las 41 clases directas confirmadas

No se ajustó artificialmente el resultado a 33. La inspección de la línea base recuperada produce **41 clases directas**.

La cifra aproximada puede explicarse porque las fuentes iniciales:

- agruparon varios endpoints de catálogo Softland como una sola familia;
- no contaron por separado los tres schedulers que enumeran únicamente Bavarian y Otobai;
- trataron reservas, disponibilidad, eliminación de reserva y solicitud de compra como un solo bloque;
- agruparon controladores de CRC/USD y cambio de moneda bajo “Pricebooks”;
- no contenían todas las clases recuperadas posteriormente desde RedMotorsSandbox;
- no distinguían el servicio de precios frescos del servicio de precios de referencia;
- omitían o agrupaban componentes documentales y de email.

Componentes que amplían de forma verificable el conteo:

1. Schedulers separados:
   - `ScheduleGetActividadComercialSoftland`
   - `ScheduleGetAseguradoraSoftland`
   - `ScheduleGetBodegaSoftland`
2. Servicios Softland separados:
   - seis batches de catálogo fijados a `RMBAVARIAN`;
   - `BatchGetBodegaSoftland`;
   - `HttpCalloutGetProductRefPrices`;
   - `HttpCalloutGetProductFreshRefPrices`;
   - `QuoteSoftlandPedidoService`;
   - `ServicioEnvioEncuestaSoftland`.
3. Servicios independientes de reservas e inventario:
   - reservar;
   - eliminar reserva;
   - consultar disponibilidad;
   - apartar artículos;
   - eliminar artículos;
   - solicitud de compra.
4. Componentes independientes de Pricebook/moneda:
   - cambio de moneda de WorkOrder;
   - cambio CRC/USD en Quote;
   - scheduler de corrección;
   - búsqueda y precios de producto.
5. Recuperados posteriormente desde RedMotorsSandbox:
   - `BMWServiceQuoteApprovalEmailInvocable`
   - `CrearPlandeVenta`
   - `HttpCalloutGetProductFreshRefPrices`

`BMWVinScanTrabajoGenerator` y `ServicioCitasFieldService` también fueron recuperados, pero permanecen en validación funcional y no inflan el conteo directo.

La referencia de Luis debe tratarse como estimación inicial, no como criterio de aceptación numérico.

## 5. Matriz de las 41 clases directas

Leyenda:

- S30: incluido en el escenario de 30 horas totales.
- S44: incluido en el escenario de 30 horas Apex + 14 horas de modelo/soporte.
- ER: `EmpresaResolver`.
- EC: `EmpresaContext`.
- ECE: `EmpresaConfigurationException`.

| Componente | Dominio | Método o bloque afectado | Patrón actual | Campo/literal | Riesgo tercera empresa | Cambio recomendado | Soporte | Test asociado | Prioridad | Est. | Bloque | S30 | S44 | Justificación |
|---|---|---|---|---|---|---|---|---|---|---:|---:|:---:|:---:|---|
| `BMW_LineaPlantillaEmpresa` | Resolución | `getEmpresa` | Bavarian; `else` Otobai | `BMW_Compania__c`, RM* | Nueva empresa cae en Otobai | Resolver valor legado y fallar si es desconocido | ER/EC/ECE | `BMW_LineaPlantillaEmpresa_Test` | Crítica | 2 h | 1/2 | Sí | Sí | Consumidor mínimo para probar el resolver |
| `BMW_ChangeCurrencyWOWOLI` | Pricebook/moneda | cambio WO/WOLI | `else` Bavarian | nombres Otobai/Bavarian | Pricebook incorrecto | Seleccionar por empresa+código moneda | ER/EC/ECE | `BMW_ChangeCurrencyWOWOLITest` | Crítica | 3 h | 2 | Sí | Sí | Caso representativo de moneda |
| `BusquedaDetalladaController` | Pricebook | `getActivePricebooks` | `LIKE Bavarian/Otobai` | `Pricebook2.Name` | Nueva lista invisible | Filtrar por relación/código de empresa | ER/EC | `BusquedaDetalladaTest` | Alta | 2 h | 2 | No | No | Diferible tras selector base |
| `cT_QuoteCrcPDFController` | Pricebook/PDF | conversión | pares por Name | cuatro nombres | Documento con lista incorrecta | Selector de lista equivalente | ER/EC/ECE | test homónimo | Alta | 2 h | 2/4 | No | No | PDF completo se difiere |
| `cT_QuoteUsdPDFController` | Pricebook/PDF | conversión | pares por Name | cuatro nombres | Igual | Selector común | ER/EC/ECE | test homónimo | Alta | 2 h | 2/4 | No | No | Misma familia |
| `QuoteController` | Pricebook | cambio de lista | cuatro `if` por Name | Bavarian/Otobai Local/Dólar | Sin rama tercera empresa | Selector central de Pricebook | ER/EC/ECE | `QuoteControllerTest` | Crítica | 3 h | 2 | Sí | Sí | Vertical principal de Quote |
| `UpdateCurrencyScheduler` | Pricebook/batch | `execute` | consulta cuatro nombres | `Pricebook2.Name` | No procesa nuevas listas | Iterar empresas/listas activas | ER/EC/ECE | `UpdateCurrencySchedulerTest` | Crítica | 3 h | 2 | No | Sí | Cierra regresión de moneda en S44 |
| `precioProductoJSON` | Pricebook/inventario | precios de referencia | ramas RM* y nombres | `empresa`, Pricebook Name | Sin precio tercera empresa | Repositorio por contexto | ER/EC/ECE | `precioProductoJSONTest` | Crítica | 3 h | 2/3 | No | No | Requiere selector ya estable |
| `ProductSearcherController` | Inventario/precios | búsqueda | `Bavarian Dólar`, arrays fijos | Bavarian/Otobai | UI omite tercera empresa | DTO por empresa | ER/EC | tests de búsqueda/VN | Alta | 3 h | 2/3 | No | No | Debe coordinarse con LWC |
| `OpportunityServiceInvoker` | Anticipos/servicio | invocable | default Bavarian; contains Otobai | Pricebook Name, RM* | Anticipo en empresa equivocada | Resolver desde Opportunity/Pricebook | ER/EC/ECE | `OpportunityServiceInvokerTest` | Crítica | 2 h | 4 | No | Sí | Incluido solo en vertical S44 |
| `Registrar_Anticipo_Controller` | Anticipos | dos bloques de registro | default Bavarian | Pricebook Name, RM* | Registro contable incorrecto | Resolver una vez por transacción | ER/EC/ECE | tests de anticipo | Crítica | 3 h | 4 | No | Sí | Riesgo financiero |
| `RM_VN_CambiarUbicacion_Ctrl` | Inventario | resolución interna | Otobai; retorno default Bavarian | `empresa`, RM* | Movimiento contra compañía errónea | Resolver y bloquear desconocida | ER/EC/ECE | test homónimo | Crítica | 2 h | 3 | No | No | Diferible tras reservas principales |
| `TrabajoQuoteController` | Taller/Quote | selección de trabajo | Bavarian; `else` Otobai | `BMW_Compania__c` | Trabajo facturado por empresa errónea | Resolver desde Quote | ER/EC/ECE | `TrabajoQuoteControllerTest` | Crítica | 2 h | 3 | No | No | Siguiente sprint |
| `ProductControllerTwo` | Inventario/Quote | productos por Quote | dos conversiones `if` | `BMW_Compania__c`, RM* | Código no normalizado | Usar contexto del Quote | ER/EC/ECE | `ProductControllerTwoTest` | Crítica | 2 h | 3 | Sí | Sí | Vertical mínima inventario |
| `QuoteSoftlandPedidoService` | Softland/pedidos | creación de pedido | Bavarian; `else` Otobai | `BMW_Compania__c`, RM* | Pedido en empresa equivocada | Payload desde EC.codigoErp | ER/EC/ECE | pruebas Quote/servicios | Crítica | 3 h | 3 | Sí | Sí | Integración representativa |
| `ServicioConsDispBodegaQuoli` | Bodega/Quote | disponibilidad | Bavarian; `else` Otobai | `BMW_Compania__c` | Consulta inventario cruzado | Contexto del Quote | ER/EC/ECE | test homónimo | Crítica | 2 h | 3 | No | Sí | Completa consulta previa a reserva |
| `ServicioCrearSCQuote` | Softland/compras | solicitud de compra | Bavarian; `else` Otobai | `BMW_Compania__c` | Compra en compañía errónea | Código ERP desde contexto | ER/EC/ECE | `ServicioCrearSCQuoteTest` | Crítica | 3 h | 3 | No | No | Diferido por tiempo |
| `ServicioEliminarReservaArticuloQuote` | Reserva/Quote | eliminar reserva | Bavarian; `else` Otobai | `BMW_Compania__c`, literal RM | Libera inventario equivocado | Resolver Quote y validar bodega | ER/EC/ECE | test homónimo | Crítica | 2 h | 3 | No | Sí | Cierra ciclo de reserva S44 |
| `ServicioReservaApartadoArticulosQuote` | Reserva/Quote | reservar/apartar | Bavarian; `else` Otobai | `BMW_Compania__c`, literal RM | Reserva cruzada | Resolver y validar producto/bodega | ER/EC/ECE | `SRAArticulosQuoteTest` | Crítica | 3 h | 3 | No | Sí | Flujo principal S44 |
| `servicioReservas` | Reserva vehículos | `getReservaById` | normaliza dos empresas | `Product2.Empresa__c`, RM* | No admite tercer código | Resolver producto; no mutar valor | ER/EC/ECE | `servicioReservasTest` | Crítica | 2 h | 3 | Sí | Sí | Caso representativo de reserva |
| `servicioEliminarReserva` | Reserva vehículos | liberación | Bavarian→RM y lista binaria | `Product2.Empresa__c` | No libera tercera empresa | Resolver por código | ER/EC/ECE | test homónimo | Crítica | 2 h | 3 | No | No | Diferido en ambos timeboxes |
| `productJSON` | Inventario/bodega | disponibilidad y precios | ramas RM*; prefijo Otobai | empresa/prefijo bodega | Mezcla productos/bodegas | Repositorios por EC | ER/EC/ECE | `productJSONTest` | Crítica | 4 h | 3 | No | No | Alto esfuerzo; posterior |
| `ProductoLocalizacionHelper` | Softland/bodega | request | compañía fija Bavarian | `RMBAVARIAN` | Siempre consulta Bavarian | Parámetro EC obligatorio | ER/EC/ECE | test homónimo | Crítica | 1 h | 3 | No | No | Cambio simple pero depende del caller |
| `HttpCalloutCreateKit` | Softland | creación de kit | RT BMW/MINI/Motorrad; resto Otobai | RT Name, RM* | Marca desconocida cae en Otobai | Empresa explícita, no inferir por RT | ER/EC/ECE | test homónimo | Crítica | 2 h | 3 | No | No | Requiere decisión marca–empresa |
| `HttpCalloutGetProductRefPrices` | Softland/precios | POST referencias | compañía fija Bavarian | `RMBAVARIAN` | Excluye Otobai y tercera | Recibir EC.codigoErp | ER/EC/ECE | test homónimo | Crítica | 1 h | 3 | No | No | Coordinar con servicio fresco |
| `HttpCalloutGetProductFreshRefPrices` | Softland/precios | `getProductFreshRefPricesPOST` | nulo→Bavarian | parámetro compañía, `RMBAVARIAN` | Default silencioso | Entrada obligatoria y validada | ER/EC/ECE | sin test directo identificado | Crítica | 2 h | 3 | No | No | Recuperada después; requiere prueba |
| `BatchGetCategoriaClienteSoftland` | Softland/catálogo | callout batch | literal único | `RMBAVARIAN` | No sincroniza otras empresas | Parametrizar por EC | ER/EC/ECE | test homónimo | Crítica | 2 h | 3 | No | No | Parte de familia posterior |
| `BatchGetCentroCostoSoftland` | Softland/catálogo | callout batch | literal único | `RMBAVARIAN` | Igual | Parametrizar | ER/EC/ECE | test homónimo | Crítica | 2 h | 3 | No | No | Igual |
| `BatchGetCondicionPagoSoftland` | Softland/catálogo | callout batch | literal único | `RMBAVARIAN` | Igual | Parametrizar | ER/EC/ECE | test homónimo | Crítica | 2 h | 3 | No | No | Igual |
| `BatchGetCuentaContableSoftland` | Softland/catálogo | callout batch | literal único | `RMBAVARIAN` | Igual | Parametrizar | ER/EC/ECE | test homónimo | Crítica | 2 h | 3 | No | No | Igual |
| `BatchGetImpuestoSoftland` | Softland/catálogo | callout batch | literal único | `RMBAVARIAN` | Igual | Parametrizar | ER/EC/ECE | test homónimo | Crítica | 2 h | 3 | No | No | Igual |
| `BatchGetSubtipoDocumentoSoftland` | Softland/catálogo | callout batch | literal único | `RMBAVARIAN` | Igual | Parametrizar | ER/EC/ECE | test homónimo | Crítica | 2 h | 3 | No | No | Igual |
| `BatchGetBodegaSoftland` | Softland/bodega | carga | prefijo especial Otobai | `company`, `RMOTOBAI` | Clave externa inconsistente | Empresa+código de bodega | ER/EC/ECE | test homónimo | Crítica | 3 h | 3 | No | No | Requiere modelo de Bodega |
| `ScheduleGetActividadComercialSoftland` | Scheduler | `execute` | encola dos códigos | RM* | Omite tercera empresa | Iterar empresas activas | ER/EC/ECE | test homónimo | Alta | 1 h | 3 | No | No | Scheduler contado por separado |
| `ScheduleGetAseguradoraSoftland` | Scheduler | `execute` | encola dos códigos | RM* | Omite tercera empresa | Iterar empresas activas | ER/EC/ECE | test homónimo | Alta | 1 h | 3 | No | No | Igual |
| `ScheduleGetBodegaSoftland` | Scheduler | `execute` | encola dos códigos | RM* | Inventario no sincronizado | Iterar empresas activas | ER/EC/ECE | test homónimo | Crítica | 1 h | 3 | No | No | Igual |
| `ServicioEnvioEncuestaSoftland` | Softland | invocable | nulo→Bavarian | `req.compania`, `RMBAVARIAN` | Encuesta atribuida mal | Requerir código configurado | ER/EC/ECE | test homónimo | Crítica | 2 h | 3 | No | No | Diferible |
| `CrearPlandeVenta` | Opportunity/Quote | `generarEstructuraPlanVenta` | RT→empresa; IDs de PB | Bavarian/Otobai, IDs | Nueva marca hereda lista errónea | Resolver empresa y seleccionar PB | ER/EC/ECE | sin test directo identificado | Crítica | 4 h | 2 | No | No | Recuperada; deuda adicional grande |
| `BMWServiceQuoteApprovalEmailInvocable` | Email | `getInternalRecipients`, subject/body | territorios y correos fijos | `contains('Otobai')`, BMW | Sin destinatario/branding nuevo | Política email por EC | ER/EC/ECE | sin test directo identificado | Alta | 3 h | 4 | No | No | Requiere decisión de branding |
| `cT_QuotePDFEmail` | PDF/email | cuerpo HTML | razón social Bavarian fija | texto legal | Documento legal incorrecto | Nombre legal desde EC | ER/EC/ECE | test homónimo | Crítica | 3 h | 4 | No | No | PDF diferido |
| `savePDFfile` | PDF/email | enrutamiento | territorios/correos y contains Otobai | ServiceTerritory Name | Omite empresa nueva | Política documental/email | ER/EC/ECE | `savePDFfileTest` | Crítica | 3 h | 4 | No | No | Pendiente decisión PDF |

Estimación técnica de las 41 clases: **aproximadamente 96 horas**, sin contar modelo, metadata, revisión funcional, Flows/LWC ni QA E2E. Es una estimación de implementación dirigida, no un compromiso de Sprint.

## 6. Dependencias indirectas: revisar sin modificar en Sprint 1

Estas 21 clases transportan empresa, orquestan consumidores o dependen de los servicios directos. Deben entrar en regresión y análisis de impacto, pero no requieren cambio mientras sus contratos sigan aceptando el código validado producido por `EmpresaResolver`.

| Componente | Motivo de dependencia |
|---|---|
| `cls_DMLHelper` | Persiste campos de empresa usados por pedidos. |
| `consultaDisponibleBodega` | Propaga `WorkOrder.EmpresaFactura__c` al servicio. |
| `doCalloutCancelarPedidoSoftland` | Propaga empresa del Order. |
| `ExternalServiceCaller` | Envía empresa de ReciboUsado; no decide entre compañías. |
| `generarPedidoJSONData` | Serializa empresa de WorkOrder. |
| `http_Helper` | Adaptador de integración; revisar contrato tras resolver en caller. |
| `OrderBatch` | Orquesta pedidos y consume empresa del WorkOrder. |
| `orderJSONData` | Serializa empresa de Order. |
| `ProductController` | Obtiene empresa de WorkOrder para servicios downstream. |
| `QuoteService` | Servicio base consumido por controladores directos. |
| `QuoteSoftlandQueryService` | Carga la señal empresarial para pedido. |
| `RM_VN_Service` | Provee Pricebooks y productos a consumidores directos. |
| `RM_VU_Inventario_Ctrl` | Delega búsqueda a servicio de usados. |
| `RM_VU_Service` | Consulta por Pricebook recibido. |
| `ServicePayment` | Propaga empresa del WorkOrder. |
| `ServicioCrearSCWorkOrder` | Usa empresa ya almacenada en WorkOrder. |
| `ServicioEliminarReservaArticulo` | Usa empresa ya almacenada en WorkOrder. |
| `ServicioGenerarPedidoFlow` | Orquesta generación de pedido. |
| `ServicioReservaApartadoArticulos` | Usa empresa de WorkOrder. |
| `WoliGridController` | Orquesta disponibilidad/reservas. |
| `WoliGridController2` | Segunda versión del mismo orquestador. |

Criterio de reclasificación: si una prueba demuestra que cualquiera aplica un default, acepta vacío o transforma empresa, pasa a Directo Sprint 1.

## 7. Componentes que requieren validación funcional

No pueden clasificarse definitivamente sin confirmar procesos, marcas, talleres, usados y propósito legal.

| Componente | Pregunta funcional |
|---|---|
| `BatchOppActivityUploader` | ¿Distribuidor y vitrina deben variar por empresa? |
| `BMWVinScanTrabajoGenerator` | ¿Tipos de trabajo/Empresa__c son compartidos entre empresas o exclusivos? |
| `CT_nuevaCita_controller` | ¿La nueva empresa tendrá agenda/taller propio? |
| `cT_nuevaCitaGarantia_controller` | ¿La garantía aplica a marcas chinas en el mismo calendario? |
| `getHorasCitasFlow` | ¿Debe reconocer una sucursal nueva o un territorio dinámico? |
| `QuoterController` | ¿Su Pricebook Bavarian fijo participa en el flujo de marcas chinas? |
| `RM_Lead_Trigger_Helper` | ¿Usados/Lead forman parte del Sprint 1? |
| `ReservaOportunidadController` | ¿La nueva empresa usa reserva sin anticipo? |
| `ReservaOppUsadosController` | ¿Usados forman parte del alcance? |
| `ServicioCitas` | ¿Ventas y posventa/taller entran juntas? |
| `ServicioCitasFieldService` | ¿FSL y portal deben habilitarse en Sprint 1? |
| `TrabajoController` | ¿Catálogo de trabajos cambia por empresa o solo por tipo de vehículo? |

## 8. Arquitectura mínima implementable

### 8.1 Objeto `Empresa__c`

| Campo | Sprint 1 | Obligatoriedad propuesta | Motivo |
|---|---|---|---|
| `Name` | Sí | Requerido por plataforma | Etiqueta visible; nunca clave de decisión. |
| `Codigo__c` | Sí | Requerido, Unique, External ID | Clave estable usada por Apex. |
| `Codigo_ERP__c` | Sí | Requerido para empresas activas que integran | Código explícito para Softland. |
| `Nombre_Legal__c` | Condicional | Requerido si PDFs/email están en el sprint | Puede diferirse si todo documento queda fuera. |
| `Activa__c` | Sí | Requerido; default false hasta completar configuración | Evita habilitar empresas incompletas. |

Recomendación: crear los cinco campos desde el inicio. Permitir temporalmente `Nombre_Legal__c` nulo solo si el bloque documental queda formalmente diferido. `Codigo_ERP__c` puede ser nulo únicamente para una empresa inactiva o declarada sin integración.

### 8.2 `EmpresaContext`

DTO inmutable de transacción:

- `Id empresaId`;
- `String codigo`;
- `String codigoErp`;
- `String nombreLegal`;
- `Boolean activa`;
- `Boolean integracionHabilitada`.

Métodos públicos mínimos:

```apex
Boolean isActive()
Boolean canIntegrate()
String requireCodigoErp()
String requireNombreLegal()
```

No debe consultar datos ni decidir precedencias.

### 8.3 `EmpresaResolver`

Responsabilidades:

- consultar `Empresa__c` por Id o `Codigo__c`;
- traducir valores legados mediante mapeo explícito y temporal;
- cachear por transacción;
- devolver `EmpresaContext`;
- validar empresa activa;
- nunca consultar por `Name`;
- nunca devolver Bavarian por default.

Métodos públicos mínimos:

```apex
EmpresaContext resolve(Id empresaId)
EmpresaContext resolveByCodigo(String codigo)
EmpresaContext resolveLegacyValue(String legacyValue)
Map<Id, EmpresaContext> resolveAll(Set<Id> empresaIds)
Map<String, EmpresaContext> resolveAllByCodigo(Set<String> codigos)
```

Bulkificación:

- una consulta por conjunto de Ids o códigos;
- mapas estáticos por transacción;
- sin SOQL dentro de ciclos;
- los consumidores por lote deben resolver primero el conjunto completo.

Empresa nula:

- lanzar `EmpresaConfigurationException`;
- no convertir a Bavarian;
- el caller presenta mensaje funcional o registra error según el proceso.

Empresa desconocida:

- lanzar excepción con el código recibido;
- no ejecutar callout, reserva, pedido, anticipo o documento.

### 8.4 `EmpresaConfigurationException`

Excepción funcional única para:

- empresa nula;
- código desconocido;
- empresa inactiva;
- código ERP requerido y ausente;
- nombre legal requerido y ausente;
- conflicto entre empresa del registro, producto, bodega o Pricebook.

El mensaje no debe exponer credenciales, endpoints ni payloads sensibles.

## 9. Primer bloque recomendado

### 9.1 Metadata a crear

- objeto `Empresa__c`;
- campos:
  - `Codigo__c`;
  - `Codigo_ERP__c`;
  - `Nombre_Legal__c`;
  - `Activa__c`;
- permisos mínimos para perfiles de administración/integración que se definan;
- datos de configuración para Bavarian, Otobai y la nueva empresa en Sandbox.

No crear todavía relaciones adicionales a Pricebook, Bodega u objetos transaccionales hasta confirmar si forman parte de las 14 horas de modelo.

### 9.2 Clases de soporte

- `EmpresaContext`;
- `EmpresaResolver`;
- `EmpresaConfigurationException`;
- `EmpresaResolverTest`.

### 9.3 Consumidores representativos

Primer grupo:

1. `BMW_LineaPlantillaEmpresa`
2. `QuoteController`
3. `BMW_ChangeCurrencyWOWOLI`
4. `QuoteSoftlandPedidoService`
5. `ProductControllerTwo`
6. `servicioReservas`

En el escenario de 44 horas se agregan:

7. `UpdateCurrencyScheduler`
8. `OpportunityServiceInvoker`
9. `Registrar_Anticipo_Controller`
10. `ServicioConsDispBodegaQuoli`
11. `ServicioReservaApartadoArticulosQuote`
12. `ServicioEliminarReservaArticuloQuote`
13. `WorkOrderTrigger` — no cuenta como clase.

### 9.4 Pruebas del bloque

- resolver Bavarian, Otobai y nueva empresa por `Codigo__c`;
- resolver conjuntos de 200 registros con una consulta por clave;
- empresa nula produce excepción;
- código desconocido produce excepción;
- empresa inactiva produce excepción;
- falta de código ERP bloquea integración;
- ningún caso cae implícitamente en Bavarian;
- regresión de pares CRC/USD;
- pedido, disponibilidad y reserva usan el código ERP correcto;
- WorkOrder selecciona la lista configurada y no por `Pricebook2.Name`.

### 9.5 Criterio de terminado

- tres empresas configuradas en Sandbox;
- resolver bulkificado con pruebas positivas y negativas;
- cero defaults silenciosos en consumidores incluidos;
- tests existentes actualizados sin reducir aserciones;
- nueva empresa pasa los casos representativos;
- Bavarian y Otobai conservan resultados aprobados;
- componentes no incluidos permanecen sin cambios y documentados.

### 9.6 Estimación

| Trabajo | 30 h totales | 44 h |
|---|---:|---:|
| Modelo y soporte | 14 h | 14 h |
| Seis consumidores base | 14 h | 14 h |
| Seis consumidores adicionales | 0 h | 13 h |
| `WorkOrderTrigger` | 0 h | 2 h |
| Estabilización | 2 h | 1 h |
| **Total** | **30 h** | **44 h** |

## 10. Implementación por bloques

### Bloque 1 — Modelo Empresa y soporte

Entregables:

- `Empresa__c` y cinco campos mínimos;
- resolver, contexto y excepción;
- pruebas bulk y fail-closed.

Dependencias: código estable de la nueva empresa y confirmación del presupuesto de 14 horas.

### Bloque 2 — Pricebook y moneda

Orden:

1. `BMW_LineaPlantillaEmpresa`
2. `QuoteController`
3. `BMW_ChangeCurrencyWOWOLI`
4. `UpdateCurrencyScheduler` en S44
5. `WorkOrderTrigger` en S44

Pruebas:

- empresa × CRC/USD;
- Pricebook inexistente;
- empresa desconocida;
- regresión Bavarian/Otobai;
- ejecución bulk de WorkOrder.

### Bloque 3 — Softland, pedidos, reservas e inventario

Orden base:

1. `QuoteSoftlandPedidoService`
2. `ProductControllerTwo`
3. `servicioReservas`

Extensión S44:

4. `ServicioConsDispBodegaQuoli`
5. `ServicioReservaApartadoArticulosQuote`
6. `ServicioEliminarReservaArticuloQuote`

Pruebas:

- código ERP por empresa;
- producto y bodega compatibles;
- reserva y liberación sobre la misma empresa;
- empresa nula/desconocida no ejecuta callout;
- mocks separados por compañía.

### Bloque 4 — Anticipos, PDFs y documentos

S44 incluye:

- `OpportunityServiceInvoker`;
- `Registrar_Anticipo_Controller`.

PDF/email queda diferido salvo decisión explícita de Luis. Si entra, debe desplazar componentes del Bloque 3 o ampliar horas.

Pruebas:

- anticipo con empresa correcta;
- Pricebook sin empresa;
- PDF/email bloqueado si falta nombre legal;
- identidad legal por empresa;
- golden samples cuando se autorice la capa documental.

### Bloque 5 — Triggers y regresión

S44 incluye `WorkOrderTrigger`. Los tres triggers de Account no se modifican hasta resolver su propósito funcional.

Pruebas:

- WorkOrder en CRC/USD por las tres empresas;
- 200 WorkOrders sin SOQL por registro;
- actualización sin empresa debe fallar de forma controlada cuando requiere Pricebook;
- regresión de bloqueo, cancelación y líneas facturadas;
- protección de cuentas solo después de aprobar la regla funcional.

## 11. Estrategia para los triggers

### 11.1 `WorkOrderTrigger`

Clasificación: **Directo Sprint 1**.

Problemas:

- consulta todos los Pricebooks y los indexa por Name;
- contiene cuatro ramas empresa×moneda;
- no tiene rama para empresa desconocida;
- omite la asignación durante tests mediante `Test.isRunningTest()`;
- contiene otras responsabilidades y consultas no bulkificadas.

Recomendación:

- no crear otro trigger;
- mover la selección a handler/servicio;
- consumir `EmpresaResolver`;
- seleccionar Pricebook por configuración estable;
- eliminar bypass funcional en tests;
- conservar en el trigger solo delegación por contexto.

### 11.2 `ChanceAccountBavarian`, `ChanceAccountContado` y `ChanceAccountOtobai`

Clasificación: **Requiere validación funcional**.

Hallazgos:

- protegen cuentas por nombre y Salesforce Id hardcodeado;
- las reglas de campos permitidos no son idénticas;
- el trigger de Contado no representa claramente una empresa;
- añadir `ChanceAccountNuevaEmpresa` multiplicaría la deuda.

Recomendación:

- no crear un quinto trigger;
- consolidar la protección en lógica genérica/configurable;
- usar un handler único de Account;
- identificar cuentas por configuración portable, no por Id ni Name;
- parametrizar campos editables/excepciones y permiso administrativo;
- decidir si la configuración pertenece a `Empresa__c`, Custom Metadata o una política separada.

Decisión pendiente: confirmar si las cuentas son empresas facturadoras, cuentas técnicas protegidas o ambas. Sin esta respuesta no debe diseñarse la relación con `Empresa__c`.

## 12. Componentes necesariamente diferidos

### 12.1 Escenario A — 30 horas totales

Se difieren:

- 35 de las 41 clases directas;
- `WorkOrderTrigger`;
- los tres triggers de Account;
- las 21 dependencias indirectas, salvo regresión de contratos;
- las 12 clases pendientes de decisión;
- PDFs/email;
- batches y schedulers Softland;
- integración completa de inventario y reservas.

Riesgo: la nueva empresa no queda habilitada de punta a punta. Se entrega arquitectura y prueba vertical.

### 12.2 Escenario B — 44 horas

Se difieren:

- 29 de las 41 clases directas;
- los tres triggers de Account;
- las 21 dependencias indirectas, salvo regresión;
- las 12 clases pendientes de decisión;
- PDFs/email completos;
- batches/schedulers de catálogo;
- búsqueda avanzada e inventario UI;
- solicitudes de compra y flujos de WorkOrder no incluidos.

Riesgo: existe una vertical funcional más amplia, pero activar globalmente la nueva empresa antes de completar los diferidos produciría rutas inconsistentes.

## 13. Riesgos

| Riesgo | Nivel | Control |
|---|---|---|
| Interpretar empresa desconocida como Bavarian | Crítico | ECE y pruebas negativas |
| Pretender habilitar producción con una vertical parcial | Crítico | Feature flag/activación bloqueada hasta completar dominios |
| Softland recibe código erróneo | Crítico | `Codigo_ERP__c` requerido |
| Pricebook resuelto por Name | Crítico | Selector estable y pruebas CRC/USD |
| Reserva o bodega cruzada | Crítico | Validar empresa de producto, bodega y documento |
| PDF con razón social incorrecta | Crítico | Diferir emisión o exigir `Nombre_Legal__c` |
| 30 horas consumidas por metadata/soporte | Alto | Confirmar si las 14 horas son adicionales |
| Triggers de Account consolidados con semántica incorrecta | Alto | Decisión funcional previa |
| Tests existentes validan bypasses | Alto | Eliminar dependencia de `Test.isRunningTest()` |
| Dependencias indirectas cambian contrato | Alto | Pruebas de regresión por consumidor |

## 14. Preguntas para Luis antes de iniciar implementación

1. ¿Sprint 1 dispone de 30 horas totales o de 30 horas Apex más 14 horas de modelo y soporte?
2. Si son solo 30 horas, ¿se aprueba el subconjunto de seis clases propuesto o debe priorizarse otro dominio?
3. ¿Cuál es el propósito funcional exacto de `ChanceAccountBavarian`, `ChanceAccountContado` y `ChanceAccountOtobai`?
4. ¿Las cuentas protegidas representan empresas facturadoras, cuentas técnicas o ambas?
5. ¿Cuál será el `Codigo__c` estable de la nueva empresa?
6. ¿Cuál será su `Codigo_ERP__c`?
7. ¿Softland mantiene el mismo contrato y únicamente cambia el código de empresa?
8. ¿El objeto `Empresa__c` y las tres clases de soporte deben entregarse en este mismo sprint?
9. ¿Se permite una transición dual entre lookup nuevo y picklists actuales?
10. ¿Sprint 1 incluye PDFs y anticipos o deben moverse a otro bloque?
11. ¿La nueva empresa incluye Ventas y Postventa/Taller desde la primera liberación?
12. ¿Usados y reservas sin anticipo forman parte del alcance?
13. ¿Las marcas chinas comparten Product2, bodegas y Pricebooks con empresas existentes?
14. ¿Se autoriza activar la nueva empresa solo después de completar todos los componentes directos?

## 15. Recomendación final

Iniciar por Bloque 1 y una vertical representativa, sin intentar editar las 41 clases simultáneamente.

Orden recomendado:

1. cerrar decisiones de Luis;
2. crear modelo y soporte;
3. probar resolución bulk y fail-closed;
4. implementar las seis clases base;
5. si existen 44 horas, ampliar a doce clases y `WorkOrderTrigger`;
6. mantener la nueva empresa inactiva hasta completar los dominios diferidos;
7. planificar el resto de las 41 clases en uno o más sprints posteriores.

Las 41 clases son el alcance técnico directo confirmado. Los escenarios de 30 y 44 horas son subconjuntos ejecutables, no una redefinición del hallazgo.
