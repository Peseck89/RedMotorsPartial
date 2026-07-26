# Matriz de pendientes — Sprint 1 Empresa / Marcas Chinas (26/07/2026)

Worktree: `C:\Users\dokur\Documents\Repositorios\RedMotors-Sprint1-Pendientes`
Rama: `analysis/pc/redmotors-empresa-marcas-chinas-sprint1-pendientes-20260726`
Base: `origin/feature/pc/redmotors-empresa-marcas-chinas-sprint1-20260724` @ `a623f54`

Análisis local, sin `sf`, sin consulta a ningún org, sin deploy.

## Fuentes reconciliadas

- `DEV Evaluación - Alcance...pdf` (documento original de alcance, Portalnet).
- `CONTEXTO_CODEX_EMPRESA_MARCAS_CHINAS.md`.
- `INVENTARIO_APEX_SPRINT1.md` (69→74 clases productivas, 4 triggers, 41 clases de alcance directo).
- `PLAN_IMPLEMENTACION_SPRINT1.md` (matriz de las 41 clases, S30/S44).
- `BITACORA_IMPLEMENTACION.md` (Bloques 1-19 cerrados e integrados).
- `PENDIENTES_DECISION_BLOQUE20.md`.
- Commits integrados en `sprint1` hasta `a623f54`.

## FASE 1 — Matriz completa (A/B/C/D)

### A. Completado, desplegado e integrado

| Componente | Bloque | Objetivo cumplido |
|---|---:|---|
| `Empresa__c`, `EmpresaContext`, `EmpresaResolver`, `EmpresaConfigurationException`, `Empresa_Admin` | 1 | Modelo base sin default silencioso a Bavarian |
| `BMW_ChangeCurrencyWOWOLI`, `QuoteController` | 2 | Conversión CRC/USD para Bavarian/Otobai/PEKING |
| `UpdateCurrencyScheduler` | 3 | Scheduler de corrección para las 3 empresas |
| `WorkOrder.empresaFacturaCP__c`, `WorkOrderTrigger` | 4/5 | Lookup a `Empresa__c`, 3 empresas soportadas, defecto `Garantia` corregido |
| `Opportunity.Empresa_Operadora__c`, `ProductControllerTwo` | 6 | Lookup en Opportunity |
| `CrearPlandeVenta` | 7 | Propagación de `Empresa_Operadora__c` |
| Permisos de `Empresa_Operadora__c` (146 perfiles) | 8 | Réplica de acceso |
| `BMW_LineaPlantillaEmpresa` | 9 | Resolución vía lookup, sin fallback a Otobai |
| `cT_QuoteUsdPDFController`, `cT_QuoteCrcPDFController` | 11/12 | PEKING en PDF de cotización |
| `TrabajoQuoteController` | 13 | Empresa configurable en trabajos de Quote |
| `TrabajoController` | 14 | Empresa configurable en trabajos de WorkOrder |
| `BMWVinScanTrabajoGenerator` | 15 | Empresa configurable en VIN Scan |
| `QuoterController` | 16 | Empresa configurable, sin default a Bavarian Dólar |
| `Product2.Empresa__c=RMPEKING`, RT `Opportunity.Omoda`/`Opportunity.Jaecoo` | 17 | Metadata base PEKING/Omoda/Jaecoo |
| `ProductSearcherController`, `ProductSearcherControllerTest`, `ProductSearcherControllerOtobaiTest`, RT `Producto_Red_Motors` picklist `Empresa__c` | 18 | Mano de obra por empresa, cobertura 182/192 |
| `RM_VN_CrearOppModeloInteres_Ctrl`, su test | 19 | `Empresa_Operadora__c` en Opportunity desde modelo de interés |

**Confirmado dinámico sin cambio necesario:** `RM_VN_GetOppRecordTypes_Ctrl.getRecordTypes()` y `RM_VN_Service.getOppVNRecordTypes()`/`addBrandFilter()` ya incluyen Omoda/Jaecoo automáticamente (excluyen por lista negra, no por lista blanca) porque los Record Types de Opportunity ya existen (Bloque 17). No requieren cambio.

### B. Técnicamente resoluble ahora sin decisiones funcionales

Ningún candidato de código productivo nuevo sobrevivió el filtro estricto de Fase 2 (ver abajo). El único trabajo identificado en esta categoría es **declarativo, no Apex**:

| Componente | Objetivo | Dependencia | Riesgo | Esfuerzo |
|---|---|---|---|---|
| List Views de Opportunity/Lead para RT `Omoda`/`Jaecoo` (equivalentes a `Oportunidades_abiertas_BMW`, etc.) | Hacer usable en UI las Opportunities de las 2 marcas ya activas | Ninguna — RTs ya existen (Bloque 17) | Bajo | Bajo |
| Layout `Opportunity-BMW Opportunity Layout` duplicado para RT nuevos | Layout específico para Omoda/Jaecoo | Ninguna | Bajo | Bajo |

Ambos son metadata declarativa pura, sin Apex, sin prueba automatizable — no encajan en el patrón de "bloque" (Apex + test + dry-run) usado en los Bloques 1-19, por lo que no se implementan en esta tarea sin autorización explícita de tratarlos como un formato distinto de entregable.

### C. Bloqueado exclusivamente por preguntas para Luis/Diego

| Componente | Pregunta bloqueante | Origen |
|---|---|---|
| `RM_Lead_Trigger_Helper`, Record Types `Lead.Omoda`/`Lead.Jaecoo` | ¿PEKING tendrá flujo de Lead/Tráfico en Sprint 1? ¿Deben crearse esos RT? ¿Mapeo Omoda→Omoda/Jaecoo→Jaecoo? ¿BMW→Polaris es correcto? | `PENDIENTES_DECISION_BLOQUE20.md` |
| `LeadService`, `LeadStatusService` (mapa de RecordType Id hardcodeado por marca) | Dependen de la misma decisión de RT de Lead para Omoda/Jaecoo | Bloqueado por lo anterior |
| `CreateProductAfterWizardController.createNewModeloByFamilia` | Requiere RT de Lead por marca para `addPicklistToRecordType`; misma decisión pendiente | Bloqueado por lo anterior |
| `HttpCalloutCreateKit` | Mapea RecordType de Opportunity a empresa; requiere confirmar si Omoda/Jaecoo entran al mismo criterio que BMW/MINI | `PLAN_IMPLEMENTACION_SPRINT1.md` §7 |
| `BMWServiceQuoteApprovalEmailInvocable` | Requiere decisión de branding/territorio para el email de aprobación | `PLAN_IMPLEMENTACION_SPRINT1.md`, fila de la clase |
| `ChanceAccountBavarian`/`ChanceAccountContado`/`ChanceAccountOtobai` | ¿Las cuentas protegidas representan empresas facturadoras, cuentas técnicas o ambas? | `PLAN_IMPLEMENTACION_SPRINT1.md` §11.2 |
| `WorkOrder.empresaFacturaCP__c` vacío/no aplicable | Decisión temporal de Luis de conservar Pricebook actual, pendiente de confirmación final de Diego | Bitácora, hito 36 |

### D. Fuera de Sprint 1 o diferido por riesgo

| Dominio | Componentes | Motivo de exclusión |
|---|---|---|
| Softland (integración ERP real) | `QuoteSoftlandPedidoService`, `QuoteSoftlandQueryService`, `ServicioCrearSCQuote`, `ServicioCrearSCWorkOrder`, `ProductoLocalizacionHelper`, `HttpCalloutCreateKit`, `HttpCalloutGetProductRefPrices`, `HttpCalloutGetProductFreshRefPrices`, 6 `BatchGet*Softland`, `BatchGetBodegaSoftland`, 3 `ScheduleGet*Softland`, `ServicioEnvioEncuestaSoftland`, `doCalloutCancelarPedidoSoftland`, `OrderBatch`, `orderJSONData`, `generarPedidoJSONData`, `ExternalServiceCaller`, `RM_VN_CambiarUbicacion_Ctrl` (calls `RM_SoftlandClient`), `cls_DMLHelper`, `http_Helper`, `ServicePayment`, `ServicioGenerarPedidoFlow` | Callout real a ERP externo; riesgo crítico, requiere confirmar contrato/código con Softland |
| Reservas | `servicioReservas`, `servicioEliminarReserva`, `ServicioConsDispBodegaQuoli`, `ServicioEliminarReservaArticuloQuote`, `ServicioReservaApartadoArticulosQuote`, `ServicioEliminarReservaArticulo`, `ServicioReservaApartadoArticulos`, `ReservaOportunidadController`, `ReservaOppUsadosController`, `WoliGridController`/`WoliGridController2` | Excluido explícitamente por Fase 2 |
| Anticipos/financiero | `OpportunityServiceInvoker`, `Registrar_Anticipo_Controller`, `TemporalOPFinanciamientoService` | Excluido explícitamente por Fase 2 |
| PDF/branding legal | `cT_QuotePDFEmail`, `savePDFfile` | Razón social fija; requiere `Nombre_Legal__c` y decisión de branding |
| Agenda/sucursales/Service Territory | `ServicioCitas`, `ServicioCitasFieldService`, `CT_nuevaCita_controller`, `cT_nuevaCitaGarantia_controller`, `getHorasCitasFlow`, `OpportunityTriggerHandler` (asignación por sucursal), `kpiSucursales`, `quoliGridDespacho`/`woliGridDespacho`, componentes Aura de Community | Excluido explícitamente por Fase 2 |
| Inventario/producto sin config aún | `productJSON`, `RM_VU_Inventario_Ctrl`, `RM_VU_Service` (usados) | Depende de si "usados" entra al alcance (pregunta abierta en `PLAN_IMPLEMENTACION_SPRINT1.md` §7) |
| Tráfico/Lead (Bloque 20) | `TraficoService`, `TraficoTriggerHandler`, `envioCotizacionTrafico`, `WSenvioCotizacionTrafico`, `controllerPlantillaCotizacionTrafico` | Mismo bloqueo documentado en `PENDIENTES_DECISION_BLOQUE20.md` |
| Saneamiento sin valor de alcance | `QuoteService.PRICEBOOK_NAME` (`'Bavarian Dólar'`, constante declarada y **nunca usada** en el archivo) | Es código muerto; eliminarlo no aporta soporte real a PEKING — descartado explícitamente por instrucción de la tarea |
| Batches/schedulers Softland de catálogo | (listados arriba en Softland) | Igual |
| Triggers Account | `ChanceAccountBavarian`, `ChanceAccountContado`, `ChanceAccountOtobai` | Ver categoría C — decisión previa requerida antes de siquiera diferir la implementación |

## FASE 2 — Búsqueda de siguiente bloque ejecutable

Se aplicaron los criterios exactos solicitados sobre:

- las 41 clases directas + 21 dependencias indirectas + 12 de validación funcional del `PLAN_IMPLEMENTACION_SPRINT1.md`;
- grep dirigido en `force-app/main/default/classes` por combinaciones `MINI`+`Kawasaki`/`Polaris` sin `Omoda`/`Jaecoo`;
- grep de `preciosBavarian`/`preciosFantasia` en LWC;
- verificación de `@api brand = 'BMW'` en `rm_vn_crear_opp_home(_movil)`/`rm_vn_crear_opp_general`.

**Resultado: no se encontró código productivo nuevo que cumpla simultáneamente todos los criterios.** Motivo estructural: los Bloques 1-19 ya cerraron exactamente la vertical "limpia" (modelo Empresa, Pricebook/moneda, Opportunity, trabajos de Quote/WorkOrder, VIN Scan, Quoter, Record Types base, mano de obra, modelo de interés). Todo lo que queda del inventario original cae en Softland real, reservas, anticipos, agenda/sucursales, branding legal, o depende de una decisión de Luis/Diego ya identificada en `PENDIENTES_DECISION_BLOQUE20.md` o en `PLAN_IMPLEMENTACION_SPRINT1.md`.

Se revisaron también los componentes LWC señalados por el PDF (`productSearcher`, `rm_vn_crear_opp_inventario`, `rm_vn_inventario`, `rm_vn_inventario_movil`) con arrays `preciosBavarian`/`preciosFantasia` hardcodeados: **son candidatos reales a mediano plazo, pero se descartan para esta tarea** porque el repositorio no tiene ninguna infraestructura Jest (`0` archivos `*.test.js`, sin `jest.config.js`), por lo que "agregar pruebas autocontenidas" implicaría introducir infraestructura de test nueva, no un cambio acotado.

## FASE 3 — Los cinco candidatos más cercanos (ninguno aprueba todos los filtros)

| # | Clase/componente | Test asociado | Comportamiento actual | Cambio exacto | Por qué NO califica hoy |
|---|---|---|---|---|---|
| 1 | `LeadService.getRecordTypeId` / `LeadStatusService` (mapa de Id por marca) | Sin test directo identificado | Mapa fijo `BMW/MINI/Kawasaki/Motorrad/Polaris → Id` de RecordType de Lead | Agregar `Omoda`/`Jaecoo` al mapa | No existen (ni están confirmados) los Record Types de Lead para Omoda/Jaecoo — depende de la decisión #2 de `PENDIENTES_DECISION_BLOQUE20.md` |
| 2 | `HttpCalloutCreateKit` | `HttpCalloutCreateKitTest` | RT `BMW/MINI/Motorrad` → `RMBAVARIAN`; resto → `RMOTOBAI` (default silencioso) | Convertir a `else if` explícito por RT, incluyendo Omoda/Jaecoo | Es integración Softland real (creación de kit) — fuera de alcance por exclusión explícita |
| 3 | `RM_VN_CambiarUbicacion_Ctrl.getCompanyName` | `RM_VN_CambiarUbicacion_Ctrl_Test` | `OTOBAI` → `RMOTOBAI`; resto → `RMBAVARIAN` (default silencioso a Bavarian) | Resolver por `EmpresaResolver` en vez de string matching | Llama a `RM_SoftlandClient.postData(...)` — integración Softland real |
| 4 | List Views Opportunity/Lead para `Omoda`/`Jaecoo` | No aplica (metadata declarativa) | No existen list views para los 2 RT nuevos | Duplicar el set de BMW (abiertas/ganadas/perdidas) | Sin Apex, sin prueba automatizable — rompe el patrón de "bloque" usado en 1-19 |
| 5 | `QuoteService.PRICEBOOK_NAME` | N/A (constante sin uso) | Declarada `'Bavarian Dólar'`, nunca referenciada en el archivo | Eliminar la constante muerta | Es saneamiento puro sin aporte real a PEKING — excluido por instrucción expresa de la tarea |

**Ningún candidato se selecciona como siguiente bloque.** Los primeros tres dependen de Softland real o de una decisión de Lead/RT ya registrada como pendiente; el cuarto no es Apex y no tiene prueba posible en el formato usado hasta ahora; el quinto es saneamiento sin valor de alcance.

## FASE 4 — Preparación local

No se implementó ningún cambio de código productivo ni de test. No se creó manifest nuevo. No se afirma que exista un candidato listo para deploy. Esta decisión sigue exactamente la instrucción de la tarea: *"Si no existe un candidato seguro: no forzar implementación; dejar únicamente la matriz; documentar que el trabajo restante depende de decisiones funcionales o está fuera de Sprint 1."*

## FASE 5 — Resumen

- **Porcentaje de alcance técnico cerrado:** el último valor confirmado en la bitácora es **85% completado / 15% pendiente** (cierre del Bloque 18). Esta tarea no avanza ni retrocede ese porcentaje: no se implementó código.
- **Pendientes técnicamente ejecutables (categoría B):** solo trabajo declarativo (List Views/Layout de Omoda/Jaecoo), sin Apex.
- **Pendientes de Luis/Diego (categoría C):** RT de Lead Omoda/Jaecoo y flujo de tráfico PEKING (`PENDIENTES_DECISION_BLOQUE20.md`), mapeo de marca en `HttpCalloutCreateKit`, branding del email de aprobación, propósito funcional de los 3 triggers de Account, confirmación final de `empresaFacturaCP__c` vacío/no aplicable.
- **Pendientes diferidos por riesgo (categoría D):** Softland real (~20 componentes), reservas (~10), anticipos/financiero (3), PDF/branding legal (2), agenda/sucursales (~6), inventario de usados (3, condicionado a decisión de alcance).
- **Candidato seleccionado:** ninguno.
- **Archivos modificados:** ninguno de código; se creó únicamente este documento de análisis.
- **Commit y push:** ver confirmación en la entrega de la tarea (commit de documentación en la rama de análisis, no en `sprint1`).
- **Confirmación:** no se ejecutó Salesforce CLI, no se consultó ningún org, no se tocaron los worktrees de Bloque 18, Bloque 19, Bloque 20, hotfix de tráfico ni VN-RQ106.
