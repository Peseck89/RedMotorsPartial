# Matriz de trazabilidad — Sprint 2 Empresa/Pricebook (PEKING), 2026-07-30

Ver el detalle narrativo completo en `CIERRE_TECNICO_SPRINT2_EMPRESA_PRICEBOOK.md`. Esta matriz resume requerimiento → componente → cambio → prueba → estado para auditoría rápida.

**Actualización (2026-07-30, segunda pasada):** Luis autorizó expresamente `Pricebook2.Empresa__c` (lookup, no obligatorio) el mismo día, desbloqueando los ítems #5–#14. Todos los ítems previamente `BLOQUEADO`/`AUTORIZADO, BLOQUEADO` quedan `COMPLETADO` abajo. Detalle completo, deploy IDs y QA funcional en `CIERRE_TECNICO_SPRINT2_EMPRESA_PRICEBOOK.md`.

| # | Requerimiento | Componente | Cambio realizado | Pruebas | Dry-run | Deploy | Cobertura | Estado |
|---|---|---|---|---|---|---|---|---|
| 1 | PEKING Local debe ser CRC | `Pricebook2` (`01sAK0000006DVdYAM`) | `CurrencyIsoCode` USD → CRC vía `sf data update record`, sin dependencias (0 PricebookEntry/Opportunity/Quote/Order) | Verificación post-DML (`sf data query`) | N/A (dato, no metadata) | N/A | N/A | **COMPLETADO** |
| 2 | PEKING Dólares debe ser USD | `Pricebook2` (`01sAK0000006DXFYA2`) | Ninguno — ya era USD | Verificación (`sf data query`) | N/A | N/A | N/A | **COMPLETADO (sin cambio necesario)** |
| 3 | PEKING activa en Partial | `Pricebook2` (ambos) | Ninguno — ya `IsActive = true` | Verificación (`sf data query`) | N/A | N/A | N/A | **COMPLETADO (ya cumplido)** |
| 4 | Drift de campos `Empresa__c` no visibles vía SOQL | `Empresa__c` (Codigo_ERP__c, Nombre_Legal__c, Activa__c) + Permission Set `Empresa_Admin` | Diagnóstico vía Tooling API (campo existe, `TableEnumOrId` correcto) + `sf org assign permset --name Empresa_Admin` | Verificación (`SELECT Id, Codigo__c, Codigo_ERP__c, Nombre_Legal__c, Activa__c FROM Empresa__c` sin error) | N/A | N/A (asignación de permiso, no deploy de metadata nueva) | N/A | **COMPLETADO** |
| 5 | Relación `Pricebook2` ↔ `Empresa__c` para resolución dinámica | `Pricebook2.Empresa__c` (Lookup, autorizado por Luis) | Campo creado y deployado | N/A (metadata) | Exitoso | `0AfAK000000yUzJ0AU` | N/A | **COMPLETADO** |
| 6 | Registros `Empresa__c` (Bavarian/Otobai/PEKING) | `Empresa__c` (3 registros nuevos) | `Codigo__c`/`Codigo_ERP__c`/`Activa__c` poblados; `Nombre_Legal__c` deliberadamente vacío (no confirmado, no inventado) | Verificación (`sf data query`) | N/A | N/A (dato) | N/A | **COMPLETADO** |
| 7 | Resolver compartido de Pricebooks (`EmpresaPricebookResolver`) | Clase Apex nueva + test | Creada: bulk-safe, no reutiliza `Nombre_Legal__c`, nunca usa Name/Id hardcodeado | 14 métodos, 0 fallos | Exitoso | `0AfAK000000yUzJ0AU` | 100% de la clase (unit) | **COMPLETADO** |
| 8 | `Opportunity_Flow` | Flow | Decision+Assignments+RecordLookup por Name → resolver dinámico + fallback `BMW_Compania__c` comentado | QA funcional indirecta (§10 cierre técnico) | Exitoso | `0AfAK000000yVKH0A2` | N/A (Flow) | **COMPLETADO** |
| 9 | `Opp_flow_v4` | Flow | Mismo patrón que #8 | — | Exitoso | `0AfAK000000yVTx0AM` | N/A | **COMPLETADO** |
| 10 | `BMW_ImportarPlantilla` | Flow | Mismo patrón que #8 | — | Exitoso | `0AfAK000000yU860AE` | N/A | **COMPLETADO** |
| 11 | `BMW_Gestiona_Listas_de_Precios` | Flow (Workflow/Process legacy) | 6 Decisions + 6 RecordUpdates con Ids fijos → resolver dinámico; 3 bugs de ejecución encontrados y corregidos (ver cierre técnico §9) | QA funcional directa: Opportunity real PEKING/CRC → Pricebook2Id correcto; Bavarian ambiguo → no asigna | Exitoso | `0AfAK000000yViT0AU` | N/A | **COMPLETADO** |
| 12 | `Obtener_PricebookEntry_en_Linea_de_Plantilla_de_Presupuesto` | Flow | RecordLookup por Name (siempre Dólar) → resolver dinámico con `$Record.CurrencyIsoCode`; se agregó filtro IsActive/CurrencyIsoCode a PricebookEntry | — | Exitoso | `0AfAK000000yVlh0AE` | N/A | **COMPLETADO** |
| 13 | `CambiarPricebook` (regresión) | Flow | Ninguno — confirmado sin dependencia de Empresa/Pricebook | Inspección estática | N/A | N/A | N/A | **COMPLETADO (regresión limpia, sin cambio necesario)** |
| 14 | `rm_vu_inventario` — selector dinámico de Pricebook por Empresa | LWC + `RM_VU_Inventario_Ctrl` | Arreglo fijo Bavarian/Otobai eliminado; nuevo método `getPricebookOptions` vía resolver; `getRecords` ahora por Id con moneda derivada del Pricebook | 8 métodos (4 nuevos), 0 fallos + QA funcional directa | Exitoso | bloque `RM_VU_Inventario_Ctrl`/LWC | N/A | **COMPLETADO** |
| 15 | Permisos mínimos sobre Empresa__c/EmpresaResolver/nuevo campo/resolver | `Empresa_Admin` + `Vehiculos_Nuevos_PS` | FLS de `Pricebook2.Empresa__c` + acceso a `EmpresaPricebookResolver` en ambos permsets | Verificación de deploy | Exitoso | `0AfAK000000yUzJ0AU` | N/A | **COMPLETADO** |
| 16 | Candidatos adicionales (12 Flows con `BMW_Compania__c`/`Pricebook2Id` no nombrados por Luis/Diego) | `AgregarManoObra`, `BMW_Importar_Plantilla_Orden_de_Trabajo`, `CreateWoliFromExpense`, `Llena_Porcentaje_de_Usados`, `Opp_Flow_V5`, `Opp_Flow_v6`, `Opp_flow_V3`, `Opportunity_Flow_V2`, `Opportunity_Flow_From_Work_Order`, `Work_Order_from_Quote`, `Work_Order_from_Quote_Selective`, `FlowOppMostrador` | Ninguno — documentados como candidatos, no autorizados | N/A | N/A | N/A | N/A | **FUERA DE ALCANCE CONFIRMADO** (requiere autorización explícita por nombre) |

## Leyenda de estado

- **COMPLETADO**: ejecutado, verificado, sin bloqueo.
- **FUERA DE ALCANCE CONFIRMADO**: descubierto durante la investigación, no solicitado, no se toca.

## Resumen ejecutivo

De 16 ítems rastreados: 15 completados (campo, resolver, permisos, los 5 Flows, `rm_vu_inventario`, datos de Empresa/Pricebook, regresión `CambiarPricebook`), y 12 Flows adicionales permanecen fuera de alcance confirmado sin tocar. Pendientes reales no bloqueantes: razón social de las 3 Empresas, moneda de `Bavarian Local`/`Otobai Local` (hallazgo de datos preexistente), y QA de extremo a extremo de los 3 Flows de Quote (validados por deploy + pruebas del resolver, no por interview completa). Detalle en `CIERRE_TECNICO_SPRINT2_EMPRESA_PRICEBOOK.md` §11.
