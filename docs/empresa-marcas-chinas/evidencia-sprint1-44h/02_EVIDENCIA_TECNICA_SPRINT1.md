# Evidencia técnica — Sprint 1 Empresa / Marcas Chinas

## Criterio

Esta tabla usa únicamente información documentada en la bitácora, matriz de trazabilidad, documentos de implementación y commits existentes. Cuando un dato no aparece documentado, se marca como `No documentado`.

| Bloque | Componente | Cambio realizado | Pruebas / cobertura | Dry-run ID | Deploy ID | Test Run ID | Commit | Estado |
|---|---|---|---|---|---|---|---|---|
| 1 | `Empresa__c`, `EmpresaResolver`, `EmpresaContext`, `EmpresaConfigurationException` | Fundación de empresa configurable con resolución por código estable. | 18/18 pruebas. | No documentado | `0AfAK000000vhrR0AQ` | No documentado | `7f8b919` | Completado |
| 1 | `Empresa_Admin` | Permission Set administrativo mínimo para `Empresa__c`. | No aplica. | `0AfAK000000viCP0AY` | `0AfAK000000viHF0AY` | No documentado | `cc1614c` | Completado |
| 2 | `QuoteController`, `BMW_ChangeCurrencyWOWOLI`, `BMW_LineaPlantillaEmpresa` | Pricebooks y conversión de moneda con soporte PEKING. | 22/22 pruebas. | `0AfAK000000vlS10AI` | `0AfAK000000vlTd0AI` | No documentado | `9669237` | Completado |
| 3 | `UpdateCurrencyScheduler` | Soporte PEKING Local / PEKING Dólares conservando conversiones existentes. | 7/7 pruebas. | `0AfAK000000vljl0AA` | `0AfAK000000vllN0AQ` | No documentado | `2d5fab4` | Completado |
| 4 | `WorkOrder.empresaFacturaCP__c`, `WorkOrderTrigger` | Lookup principal a `Empresa__c`; picklist heredado como respaldo temporal. | 50/50 pruebas. Cobertura documentada durante estabilización: 163/173 = 94.220%. | `0AfAK000000vmSv0AI` | `0AfAK000000vnon0AA` | No documentado | `67410e3` | Completado |
| 5 | `WorkOrderTrigger` | Corrección del literal `Garantía` → `Garantia`. | 51/51 pruebas. | `0AfAK000000vnqP0AQ` | `0AfAK000000vo4v0AA` | No documentado | `b427ab6` | Completado |
| 6 | `Opportunity.Empresa_Operadora__c`, `ProductControllerTwo` | Lookup principal de empresa en Opportunity; BMW_Compania__c como respaldo temporal. | 9/9 pruebas. Cobertura `ProductControllerTwo`: 766/870 = 88.046%. | `0AfAK000000vojF0AQ` | `0AfAK000000vokr0AA` | No documentado | `ae6e0e6` | Completado |
| 7 | `CrearPlandeVenta` | Copia `Empresa_Operadora__c`; `Cuenta_de_Facturaci_n__c` original tiene prioridad. | 7/7 funcionales, 17/17 regresión. Cobertura: 115/127 = 90.55%. | `0AfAK000000vpFV0AY`; regresión `0AfAK000000vpH70AI` | `0AfAK000000vpIj0AI` | No documentado | `492e99b` | Completado |
| 8 | Perfiles y `Vehiculos_Nuevos_PS` | Permisos de `Opportunity.Empresa_Operadora__c` replicados desde `BMW_Compania__c`. | Apex no aplica. | `0AfAK000000vow90AA` | `0AfAK000000voUk0AI` | No aplica | `a137b19` | Completado |
| 9 | `Plantilla_de_Presupuesto__c.Empresa_Operadora__c`, `BMW_LineaPlantillaEmpresa` | Lookup principal en plantillas; respaldo Bavarian/Otobai; PEKING por resolver. | 9/9 funcionales, 18/18 regresión. Cobertura: 16/21 = 76.19%. | `0AfAK000000vpPB0AY`; regresión `0AfAK000000vpSP0AY` | `0AfAK000000vpU10AI` | No documentado | `4af8ced` | Completado |
| 10 | `BusquedaDetalladaController`, `precioProductoJSON` | Investigación adicional. No se implementó por dependencia externa comprobada. | No aplica. | No ejecutado | No ejecutado | No aplica | `254c35f` documentación | Reclasificado fuera del pendiente 44h |
| 11 | `cT_QuoteUsdPDFController` | Mapeo `PEKING Local` → `PEKING Dólares`; sin fallback. | 4/4 pruebas. Cobertura: 97/112 = 86.61%. | `0AfAK000000vpdh0AA` | `0AfAK000000vpfJ0AQ` | No documentado | `4b127b3` | Completado |
| 12 | `cT_QuoteCrcPDFController` | Mapeo `PEKING Dólares` → `PEKING Local`; sin fallback. | 5/5 pruebas. Cobertura: 113/115 = 98.26%. | `0AfAK000000vpiX0AQ` | `0AfAK000000vpk90AA` | No documentado | `86ab781` | Completado |
| 13 | `TrabajoQuoteController` | Empresa configurable en trabajos de Quote; RMPEKING en mano de obra. | 9/9 funcionales, 18/18 regresión. Cobertura: 282/302 = 93.38%. | `0AfAK000000vptp0AA`; regresión `0AfAK000000vpvR0AQ` | `0AfAK000000vpx30AA` | No documentado | `57d1880` | Completado |
| 14 | `TrabajoController` | Empresa configurable en trabajos de WorkOrder. | 17/17 funcionales, 26/26 regresión. Cobertura: 232/266 = 87.22%. | `0AfAK000000vqBZ0AY`; regresión `0AfAK000000vqEn0AI` | `0AfAK000000vqGP0AY` | No documentado | `2f8a923` | Completado |
| 15 | `BMWVinScanTrabajoGenerator` | Empresa configurable en trabajos y subtrabajos de VIN Scan. | 42/42 funcionales, 93/93 regresión. Cobertura: 569/656 = 86.74%. | `0AfAK000000vqY90AI`; regresión `0AfAK000000vqZl0AI` | `0AfAK000000vqeb0AA` | No documentado | `1b9e859` | Completado |
| 16 | `QuoterController` | Empresa configurable y Pricebooks USD por empresa; eliminación de `dummy()`. | 13/13 funcionales, 22/22 regresión. Cobertura: 118/136 = 86.77%. | `0AfAK000000vqpt0AA`; regresión `0AfAK000000vqrV0AQ` | `0AfAK000000vqt70AA` | No documentado | `3e7232a` | Completado |
| 17 | `Product2.Empresa__c`, `Opportunity.Omoda`, `Opportunity.Jaecoo` | Metadata base PEKING, Omoda y Jaecoo; visibilidad en `Vehiculos_Nuevos_PS`. | NoTestRun. | `0AfAK000000vquk0AA` | `0AfAK000000vrNl0AI` | No aplica | `2e1c733` | Completado |
| 18 | `ProductSearcherController` | Búsqueda de mano de obra por empresa, incluyendo Omoda/Jaecoo → RMPEKING. | 15/15 funcionales, 33/33 regresión. Cobertura: 182/192 = 94.79%. | `0AfAK000000vu8j0AA`; regresión `0AfAK000000vuAL0AY` | `0AfAK000000vuBx0AI` | `707AK00000GwtdT` | `37af27a`; merge `a623f54` | Completado |
| 19 | `RM_VN_CrearOppModeloInteres_Ctrl` | Asigna `Empresa_Operadora__c` según marca: BMW/MINI, Polaris/Kawasaki, Omoda/Jaecoo. | 11/11 funcionales, 48/48 regresión. Cobertura: 136/151 = 90.066%. | `0AfAK000000vtML0AY`; regresión `0AfAK000000vtkX0AQ` | `0AfAK000000vtnl0AA` | Post-deploy `707AK00000GwjmT` | `fe432cd`, `a993eee`; merge `eede33e` | Completado |
| 20 | Lead Omoda/Jaecoo, mappings Lead → Opportunity | Record Types Lead Omoda/Jaecoo y mappings `Lead.Omoda→Opportunity.Omoda`, `Lead.Jaecoo→Opportunity.Jaecoo`. | 3/3 funcionales, 53/53 regresión. | `0AfAK000000vuNF0AY`; regresión `0AfAK000000vuOr0AI` | `0AfAK000000vuQT0AY` | Post-deploy `707AK00000GxONW` | `1d83228`; merge `f8155f4` | Completado |
| 21 | Opportunity UI | 8 List Views Omoda/Jaecoo y `Opportunity_Record_Page_VN`. | NoTestRun. | `0AfAK000000vtcU0AQ` | `0AfAK000000vuTh0AI` | No aplica | `67c180b`; merge `52e1ef1` | Completado |
| Cierre Git | Sprint1 | Cierre documental 44h, matriz y checkpoint final. | Validación documental y `git diff --check`. | No aplica | No aplica | No aplica | `83127dd` | Cerrado |

## Confirmación final

El cierre consolidado documenta Sprint 1 comprometido como **19/19 = 100%**. Bloque 10 no se presenta como implementado; queda clasificado como investigación adicional bloqueada por dependencias externas.
