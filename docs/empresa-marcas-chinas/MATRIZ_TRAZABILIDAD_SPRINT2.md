# Matriz de trazabilidad — Sprint 2 Empresa/Pricebook (PEKING), 2026-07-30

Ver el detalle narrativo completo en `CIERRE_TECNICO_SPRINT2_EMPRESA_PRICEBOOK.md`. Esta matriz resume requerimiento → componente → cambio → prueba → estado para auditoría rápida.

| # | Requerimiento | Componente | Cambio realizado | Pruebas | Dry-run | Deploy | Cobertura | Estado |
|---|---|---|---|---|---|---|---|---|
| 1 | PEKING Local debe ser CRC | `Pricebook2` (`01sAK0000006DVdYAM`) | `CurrencyIsoCode` USD → CRC vía `sf data update record`, sin dependencias (0 PricebookEntry/Opportunity/Quote/Order) | Verificación post-DML (`sf data query`) | N/A (dato, no metadata) | N/A | N/A | **COMPLETADO** |
| 2 | PEKING Dólares debe ser USD | `Pricebook2` (`01sAK0000006DXFYA2`) | Ninguno — ya era USD | Verificación (`sf data query`) | N/A | N/A | N/A | **COMPLETADO (sin cambio necesario)** |
| 3 | PEKING activa en Partial | `Pricebook2` (ambos) | Ninguno — ya `IsActive = true` | Verificación (`sf data query`) | N/A | N/A | N/A | **COMPLETADO (ya cumplido)** |
| 4 | Drift de campos `Empresa__c` no visibles vía SOQL | `Empresa__c` (Codigo_ERP__c, Nombre_Legal__c, Activa__c) + Permission Set `Empresa_Admin` | Diagnóstico vía Tooling API (campo existe, `TableEnumOrId` correcto) + `sf org assign permset --name Empresa_Admin` | Verificación (`SELECT Id, Codigo__c, Codigo_ERP__c, Nombre_Legal__c, Activa__c FROM Empresa__c` sin error) | N/A | N/A (asignación de permiso, no deploy de metadata nueva) | N/A | **COMPLETADO** |
| 5 | Relación `Pricebook2` ↔ `Empresa__c` para resolución dinámica | Ninguno existe | Ninguno — requiere decisión de arquitectura (campo nuevo vs. junction) | N/A | N/A | N/A | N/A | **BLOQUEADO** — ver `CIERRE_TECNICO_SPRINT2_EMPRESA_PRICEBOOK.md` §6, 2 opciones + recomendación |
| 6 | Registros `Empresa__c` (Bavarian/Otobai/PEKING) | `Empresa__c` (0 registros) | Ninguno — `Nombre_Legal__c` (razón social) no confirmada por ninguna fuente | N/A | N/A | N/A | N/A | **BLOQUEADO** — ver `CIERRE_TECNICO_SPRINT2_EMPRESA_PRICEBOOK.md` §7 |
| 7 | Resolver compartido de Pricebooks (`EmpresaPricebookResolver` o equivalente) | Clase Apex nueva | No creada — depende de #5 | N/A | N/A | N/A | N/A | **BLOQUEADO** (depende de #5) |
| 8 | `Opportunity_Flow` — 2 reglas + 2 assignments para PEKING | Flow | No modificado — depende de #5/#7; ya no depende del valor de `BMW_Compania__c` (decisión de Luis lo sustituye) | N/A | N/A | N/A | N/A | **AUTORIZADO, BLOQUEADO** |
| 9 | `Opp_flow_v4` — mismo cambio que #8 | Flow | No modificado — misma dependencia que #8 | N/A | N/A | N/A | N/A | **AUTORIZADO, BLOQUEADO** |
| 10 | `BMW_ImportarPlantilla` — expandir Decision a 3 vías | Flow | No modificado — misma dependencia que #8 | N/A | N/A | N/A | N/A | **AUTORIZADO, BLOQUEADO** |
| 11 | `BMW_Gestiona_Listas_de_Precios` | Flow | No modificado — inspeccionado (6 Decisions, Ids de `Pricebook2` hardcodeados), sigue `PENDIENTE DE CONFIRMACIÓN` de alcance además del bloqueo de #5 | N/A | N/A | N/A | N/A | **PENDIENTE DE CONFIRMACIÓN + BLOQUEADO** |
| 12 | `Obtener_PricebookEntry_en_Linea_de_Plantilla_de_Presupuesto` | Flow | No modificado — inspeccionado (RecordLookup por `Pricebook2.Name`), sigue `PENDIENTE DE CONFIRMACIÓN` de alcance además del bloqueo de #5 | N/A | N/A | N/A | N/A | **PENDIENTE DE CONFIRMACIÓN + BLOQUEADO** |
| 13 | `CambiarPricebook` (regresión) | Flow | Ninguno — confirmado sin dependencia de Empresa/Pricebook | Inspección estática | N/A | N/A | N/A | **COMPLETADO (regresión limpia, sin cambio necesario)** |
| 14 | `rm_vu_inventario` — selector dinámico de Pricebook por Empresa | LWC + `RM_VU_Inventario_Ctrl` | No modificado — depende de #5/#7, y el cambio funcional exacto sigue sin extraerse de ninguna fuente (`REGLAS_ALCANCE_AUTORIZADO.md` Fase 3) | N/A | N/A | N/A | N/A | **AUTORIZADO EN ALCANCE, BLOQUEADO** |
| 15 | Permisos mínimos sobre Empresa__c/EmpresaResolver | Permission Set `Empresa_Admin` | Ya existía en Git/Partial; se asignó al usuario conectado (ítem #4) | Verificación de asignación (`SELECT ... FROM PermissionSetAssignment`) | N/A | N/A | N/A | **COMPLETADO** |
| 16 | Candidatos adicionales (12 Flows con `BMW_Compania__c`/`Pricebook2Id` no nombrados por Luis/Diego) | `AgregarManoObra`, `BMW_Importar_Plantilla_Orden_de_Trabajo`, `CreateWoliFromExpense`, `Llena_Porcentaje_de_Usados`, `Opp_Flow_V5`, `Opp_Flow_v6`, `Opp_flow_V3`, `Opportunity_Flow_V2`, `Opportunity_Flow_From_Work_Order`, `Work_Order_from_Quote`, `Work_Order_from_Quote_Selective`, `FlowOppMostrador` | Ninguno — documentados como candidatos, no autorizados | N/A | N/A | N/A | N/A | **FUERA DE ALCANCE CONFIRMADO** (requiere autorización explícita por nombre) |

## Leyenda de estado

- **COMPLETADO**: ejecutado, verificado, sin bloqueo.
- **AUTORIZADO, BLOQUEADO**: el componente tiene autorización de alcance vigente, pero su implementación depende de un bloqueo documentado (arquitectura o dato) que no puede resolverse sin inventar información.
- **PENDIENTE DE CONFIRMACIÓN + BLOQUEADO**: no tiene autorización de alcance nombre-por-nombre todavía, y además depende del mismo bloqueo estructural.
- **BLOQUEADO**: requiere una decisión de negocio/arquitectura que solo Luis o Diego pueden tomar.
- **FUERA DE ALCANCE CONFIRMADO**: descubierto durante la investigación, no solicitado, no se toca.

## Resumen ejecutivo

De 16 ítems rastreados: 6 completados sin bloqueo (PEKING currency ×2, PEKING activa, drift de permisos, permisos asignados, `CambiarPricebook`), 7 bloqueados por la falta de relación Pricebook2–Empresa__c y/o el dato de razón social (incluye los 5 Flows de Pricebook + resolver + rm_vu_inventario), y 12 Flows adicionales quedan registrados como fuera de alcance confirmado sin tocar. **Sprint 2 no se declara completo** — persiste un bloqueo real que requiere una decisión de Luis/Diego, documentada con 2 opciones y una recomendación en `CIERRE_TECNICO_SPRINT2_EMPRESA_PRICEBOOK.md` §6 y §10.
