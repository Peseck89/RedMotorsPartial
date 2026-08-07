# Plan de regresión — Approval Processes de descuento

**Fecha:** 6 de agosto de 2026  
**Estado:** preparación ejecutable; no se enviaron aprobaciones reales

Los ocho procesos están activos, son neutrales a Empresa/Marca/Record Type y resuelven sus aprobadores mediante campos de usuario relacionados. No requieren cambio técnico; sí evidencia funcional con usuarios y Opportunities QA autorizados.

| Approval Process | Criterio de entrada | Campos dinámicos de aprobador | Escenario aprobado | Escenario rechazado/no elegible | Regresión legacy | Datos necesarios |
|---|---|---|---|---|---|---|
| `Aprobacion_descuento_Director_con_Jefe` | Director; Director y Jefe informados; Gerente vacío; descuento > 0 | `JefeSucursal__c`, `DirectorVentas__c` | Completa ambos pasos y acciones finales | Descuento 0 o combinación distinta no entra; rechazo conserva acciones vigentes | Bavarian y Otobai; aprobar, rechazar y recall | Opportunity PEKING QA; Jefe y Director autorizados |
| `Aprobacion_descuento_Director_Full_Team` | Director; Jefe, Gerente y Director informados; descuento > 0 | `JefeSucursal__c`, `GerenteSucursal__c`, `DirectorVentas__c` | Recorre los tres pasos | Un responsable vacío debe seleccionar otra variante o impedir esta | Bavarian y Otobai; acciones finales, rechazo y recall | Opportunity PEKING QA; tres usuarios autorizados |
| `Aprobacion_descuento_Director_Gerente4` | Director; Gerente y Director informados; Jefe vacío; descuento > 0 | `GerenteSucursal__c`, `DirectorVentas__c` | Completa ambos pasos | Jefe informado hace no elegible esta variante | Bavarian y Otobai | Opportunity PEKING QA; Gerente y Director autorizados |
| `Aprobacion_descuento_gerente_con_Jefe` | Gerente; Jefe y Gerente informados; descuento > 0; no aprobado | `JefeSucursal__c`, `GerenteSucursal__c` | Completa ambos pasos | Ya aprobado o responsable vacío no entra | Bavarian y Otobai; rechazo y recall | Opportunity PEKING QA; Jefe y Gerente autorizados |
| `Aprobacion_descuento_Gerente_sin_Gerente` | Gerente; Jefe informado; Gerente vacío; descuento > 0; no aprobado | `JefeSucursal__c`, `DirectorVentas__c` | Completa ambos pasos | Gerente informado hace no elegible esta variante | Bavarian y Otobai | Opportunity PEKING QA; Jefe y Director autorizados |
| `Aprobacion_descuento_Gerente_sin_jefe` | Gerente; Jefe vacío; Gerente informado; descuento > 0; no aprobado | `GerenteSucursal__c` | Entra y aprueba con Gerente | Jefe informado hace no elegible esta variante | Bavarian y Otobai | Opportunity PEKING QA; Gerente autorizado |
| `Aprobacion_descuento_Jefe_con_jefe` | Jefe; Jefe informado; descuento > 0; no aprobado | `JefeSucursal__c` | Entra y aprueba con Jefe | Jefe vacío selecciona otra variante | Bavarian y Otobai | Opportunity PEKING QA; Jefe autorizado |
| `Aprobacion_descuento_Jefe_sin_Jefe` | Jefe; Jefe vacío; descuento > 0; no aprobado | `GerenteSucursal__c` | Entra y aprueba con Gerente | Jefe informado hace no elegible esta variante | Bavarian y Otobai | Opportunity PEKING QA; Gerente autorizado |

## Evidencia por proceso

- Video completo desde el envío hasta aprobación o rechazo.
- Captura de los campos que determinan la variante y del aprobador resuelto.
- Resultado de las acciones finales existentes: descuento aprobado, pendiente y último descuento aprobado, cuando correspondan.
- Evidencia de recall en al menos una ruta representativa por nivel.
- Caso equivalente legacy sin cambio de comportamiento.

## Límites

No se deben inventar responsables ni usar usuarios reales sin autorización. La preparación no resuelve la disponibilidad de Jefatura, Gerencia y Dirección para PEKING. `DATOS_QA_NO_DISPONIBLES` hasta que el equipo proporcione registros y usuarios autorizados.
