# Plan de ejecución Sprint 2 — Empresa / Marcas Chinas (BORRADOR, no autorizado para trabajo)

## Estado del documento

**Plan de organización, no autorización de trabajo.** No se recuperó metadata, no se ejecutó Salesforce CLI, no se hizo deploy, no se tocó Producción, no se tocó Sprint 1. Ningún lote de este plan puede iniciarse sin resolver primero el "Lote 0".

**AVISO (2026-07-28, corregido en segunda revisión): la vigencia operativa de este plan quedó sustituida por la regla de alcance obligatoria en `REGLAS_ALCANCE_AUTORIZADO.md`.** Ningún lote está "activo completo" — **ningún componente de este plan está todavía en estado "AUTORIZADO PARA IMPLEMENTACIÓN"**. El Lote 1 (Pricebook) y `rm_vu_inventario` dentro del Lote 4 son el único bloque con alcance de categoría/nombre respaldado por Luis, pero permanecen en investigación (`rm_vu_inventario`: autorizado por nombre, falta el cambio funcional; los 5 Flows de Pricebook: categoría autorizada, nombres pendientes de validación documental — 3 de 5 con vínculo explícito, 2 de 5 solo con coincidencia de nombre). Los 4 componentes hermanos de `rm_vu_inventario` dentro del Lote 4 (`rm_vn_inventario`, `rm_vn_inventario_movil`, `rm_vn_crear_opp_inventario`, `productSearcher`) quedan fuera de cualquier bloque activo. Los Lotes 2, 3, 5, 6 y 7 quedan **congelados**: sus componentes están en estado PENDIENTE DE CONFIRMACIÓN, no AUTORIZADO. No se vuelven a investigar los 48 Flows ni los 36 componentes completos del inventario. Este documento se conserva como registro de la investigación de patrones funcionales, no como plan operativo vigente.

## Advertencia sobre el estado de confirmación

`rm_vu_inventario` está autorizado por nombre por Luis, pero falta su cambio funcional exacto. El conteo de 5 Flows de Pricebook está autorizado por Luis como **categoría**; los 5 nombres documentados coinciden en cantidad, pero **no todos tienen vínculo documental explícito** (ver validación nombre por nombre en `REGLAS_ALCANCE_AUTORIZADO.md`, Fase 2) y ninguno fue confirmado individualmente por Luis o Diego todavía. **Ningún otro componente de este plan está confirmado como parte del ~20/~16 de Luis**. Los lotes siguientes agrupan los componentes que sí tienen **patrón funcional documentado** en fuentes de rango 2-3 (ver `INVENTARIO_SPRINT2_FLOWS_COMPONENTES.md`, secciones A y C-D), como la organización más defendible disponible hoy — pero cada lote lleva su propia pregunta de confirmación pendiente. No se reinterpretó ninguna estimación: donde una fuente da una cifra, se cita tal cual.

## Lote 0 — Prerrequisito: cerrar la brecha de confirmación (no es un lote de implementación)

| Campo | Detalle |
|---|---|
| Flows o componentes | Ninguno — este lote es una gestión, no una implementación |
| Dependencia | Respuesta de Luis y/o Diego |
| Riesgo | Si se omite, cualquier lote posterior corre el riesgo de tocar componentes fuera del ~20/~16 real de Luis, ampliando el alcance sin autorización |
| Prueba | No aplica |
| Orden recomendado | **Antes que cualquier otro lote** |
| Pregunta pendiente | ¿Cuáles de los 47 Flows candidatos del Manual (Anexo A.3) y cuáles de los 22-36 LWC/Aura candidatos son exactamente los ~20/~16 que Luis tiene en mente? ¿Los 8 Flows con estado `Obsolete` (ver `INVENTARIO_SPRINT2_FLOWS_COMPONENTES.md`, sección A2) quedan fuera por defecto? ¿`PlanDeMantenimientoV2` (solo en el documento original, no en el Manual) entra o no? ¿`kpiSucursales` y `cT_Estadisticas_Inventario_lwc` (nombrados por las fuentes pero ausentes del Git actual) siguen vigentes o ya no existen? |
| Estimación tomada del documento, sin reinterpretar | Luis: "~20 Flows, incluidos 5 relacionados con Pricebooks" y "~16 LWC/Aura, incluido `rm_vu_inventario.js`" — cita textual, no se amplía ni se reduce aquí |

## Lote 1 — Flows de Pricebook (coincide exactamente con la cifra de Luis: 5)

| Campo | Detalle |
|---|---|
| Flows o componentes | `Opportunity_Flow`, `Opp_flow_v4`, `BMW_ImportarPlantilla`, `BMW_Gestiona_Listas_de_Precios`, `Obtener_PricebookEntry_en_Linea_de_Plantilla_de_Presupuesto` |
| Dependencia | `Opportunity_Flow`/`Opp_flow_v4` comparten patrón (Decision `Encuentra_Price_Book`); `BMW_ImportarPlantilla` depende de `Plantilla_de_Presupuesto__c.BMW_Compania__c` |
| Riesgo | Mismo patrón "else binario" ya identificado en Apex durante Sprint 1 (fallback silencioso a Bavarian) — riesgo de que el mismo defecto exista aquí a nivel de Flow |
| Prueba | Ninguna identificada en las fuentes disponibles para estos Flows — no existe evidencia de test/validación automatizada de Flows en este inventario |
| Orden recomendado | 1º después del Lote 0 — es el grupo con mayor coincidencia exacta con la instrucción de Luis |
| Pregunta pendiente | ¿La corrección sigue el mismo patrón "agregar rama explícita" usado en los fixes Apex de Sprint 1, o requiere un enfoque distinto por ser Flow declarativo? |
| Estimación tomada del documento | Documento original §4: "Agregar 2 reglas + 2 assignments para la compañía nueva (Local/Dólar)" (aplica a `Opportunity_Flow`/`Opp_flow_v4`); "crear plantillas de presupuesto para la compañía nueva" (aplica a `BMW_ImportarPlantilla`) |

## Lote 2 — WorkOrder desde Quote y garantía

| Campo | Detalle |
|---|---|
| Flows o componentes | `Work_Order_from_Quote`, `Work_Order_from_Quote_Selective`, `SegregateWOLIs` |
| Dependencia | Depende de `WorkOrder.empresaFactura__c` (ya reconciliado en Sprint 1 vía `WorkOrderTrigger`) — verificar consistencia con el trigger ya reconciliado antes de tocar estos Flows |
| Riesgo | `SegregateWOLIs` ya presenta drift Git/Partial sin explicar (ver `INVENTARIO_SPRINT2_FLOWS_COMPONENTES.md`, fila 7) — riesgo de tocar una versión desactualizada |
| Prueba | Ninguna identificada en las fuentes disponibles |
| Orden recomendado | 2º — depende conceptualmente del trabajo de `WorkOrderTrigger` ya cerrado en Sprint 1 |
| Pregunta pendiente | Para `SegregateWOLIs`: ¿la compañía nueva necesita un campo de garantía análogo a `Garantia_Otobai__c`? (pregunta explícita del documento original, sin resolver) |
| Estimación tomada del documento | Documento original §4: "Expandir a 3 vías (es el flow que crea la Work Order desde Quote)" |

## Lote 3 — Flows de un solo propósito, con discrepancia de fuente

| Campo | Detalle |
|---|---|
| Flows o componentes | `ReciboUsadosFlow`, `PlanDeMantenimientoV2` |
| Dependencia | `ReciboUsadosFlow` depende de `ReciboUsado__c.Empresa__c` |
| Riesgo | `PlanDeMantenimientoV2` **no aparece en el Anexo A.3 del Manual** (47 candidatos) pese a estar nombrado en el documento original — riesgo de que ya no sea relevante, o de que el Manual tenga un vacío |
| Prueba | Ninguna identificada |
| Orden recomendado | 3º — bajo acoplamiento con los lotes anteriores |
| Pregunta pendiente | ¿Por qué `PlanDeMantenimientoV2` no está en la lista de 47 del Manual? ¿Sigue vigente el patrón descrito en el documento original? |
| Estimación tomada del documento | Documento original §4: choices hardcodeadas `RMBAVARIAN`/`RMOTOBAI` en `ReciboUsadosFlow`; misma fórmula binaria `EmpresaProductoMantenimiento` en `PlanDeMantenimientoV2` |

## Lote 4 — Inventario: LWC con mapeo de precios hardcodeado (incluye el componente confirmado por Luis)

| Campo | Detalle |
|---|---|
| Flows o componentes | `rm_vu_inventario` (**confirmado por Luis**), `rm_vn_inventario`, `rm_vn_inventario_movil`, `rm_vn_crear_opp_inventario`, `productSearcher` |
| Dependencia | Controladores Apex ya identificados: `RM_VU_Inventario_Ctrl`, `RM_VN_Inventario_Ctrl`, `ProductSearcherController` |
| Riesgo | El documento original marca este grupo como "Crítico para inventario" — mapeo de precios `preciosBavarian`/`preciosFantasia` hardcodeado en JS; el dato puede existir en Salesforce y no mostrarse igual |
| Prueba | No se identificó test/validación específica para el JS en las fuentes disponibles; existen tests Apex para los controladores (`RM_VU_Inventario_Ctrl_Test` confirmado en Git) |
| Orden recomendado | 4º — es el único lote con un componente explícitamente confirmado por Luis, pero requiere resolver primero la discrepancia de nombres del Lote 0 (`rm_vn_inventario` vs. `rm_vu_inventario` vs. `rm_vu_crear_opp`) |
| Pregunta pendiente | ¿Los 4 componentes hermanos de `rm_vu_inventario` (`rm_vn_inventario`, `rm_vn_inventario_movil`, `rm_vn_crear_opp_inventario`) también entran al Sprint 2, o el alcance de Luis es solo `rm_vu_inventario`? |
| Estimación tomada del documento | Documento original §10: "refactorizar para n compañías, no 2 fijas"; "el dato exista en Salesforce, la pantalla no lo va a mostrar sin tocar JS" |

## Lote 5 — Búsqueda detallada y localización (parcialmente tocado en Sprint 1)

| Campo | Detalle |
|---|---|
| Flows o componentes | `busquedaDetallada`, `qoSearchDetailProduct`, `woSearchDetailProduct`, `localizacionDetails`, `pricebookReferenceDetails` |
| Dependencia | Apex de localización en Softland (`getSoftlandLocations` y relacionados); `BusquedaDetalladaController` ya revisado parcialmente en Sprint 1 Bloque 10 |
| Riesgo | Bajo acoplamiento a Sprint 1 — Bloque 10 solo revisó el Apex, no el JS. Riesgo de reabrir un bloque considerado cerrado sin coordinarlo con esa evidencia |
| Prueba | Cobertura Apex de `BusquedaDetalladaController` documentada en `LABORATORIO_COBERTURA_BLOQUE18.md`/Bloque 10 (Sprint 1) — no hay prueba de JS documentada |
| Orden recomendado | 5º — requiere revisar primero `IMPLEMENTACION_BLOQUE10_BUSQUEDA_DETALLADA.md` para no duplicar trabajo de Sprint 1 |
| Pregunta pendiente | ¿Este lote es Sprint 2 nuevo, o es la continuación pendiente de un bloque de Sprint 1 que se cerró solo parcialmente (solo Apex, no JS)? |
| Estimación tomada del documento | Documento original §5: "reciben `empresaFactura` vía `@api` desde el padre (dinámico) pero dependen del Apex de localización en Softland" |

## Lote 6 — Aura de Community (portal)

| Campo | Detalle |
|---|---|
| Flows o componentes | `CommunityMenu`, `CommunityControl`, `CommunityCalendar`, `customerCommunity_lwc`, `callcenterCommunity_lwc` |
| Dependencia | Ninguna dependencia Apex identificada en las fuentes disponibles para este grupo específico |
| Riesgo | Patrón condicional binario (`if (selectedService === "Otobai")`) + JSON hardcodeado de ubicaciones por servicio — mismo tipo de riesgo "else binario" que en Apex/Flows |
| Prueba | Ninguna identificada |
| Orden recomendado | 6º — mayor superficie de cambio (portal completo), conviene después de validar el patrón en lotes más pequeños |
| Pregunta pendiente | El Manual lista 8 componentes Aura de Community adicionales (`CommunityAppointmentsHistory`, `CommunityCancelAppointments`, `CommunityCarsManagement`, `CommunityHome`, `CommunityInspectionHistory`, `CommunityManageWorksMenu`, `CommunityProfile`, `bMW_newLineaPlantilla`) sin patrón documentado — ¿comparten el mismo problema o son independientes? |
| Estimación tomada del documento | Documento original §5: "Agregar rama de servicio para citas/community de la compañía nueva" |

## Lote 7 — Componente aislado de garantía

| Campo | Detalle |
|---|---|
| Flows o componentes | `assetGarantiaLookupLwc` |
| Dependencia | Ninguna identificada en las fuentes disponibles |
| Riesgo | Bajo — cambio acotado a una URL hardcodeada |
| Prueba | Ninguna identificada |
| Orden recomendado | 7º — bajo riesgo, puede adelantarse u ordenarse libremente si se prioriza por esfuerzo |
| Pregunta pendiente | ¿Este componente está dentro del ~16 de Luis o es candidato solo del documento original? |
| Estimación tomada del documento | Documento original §5: "Parametrizar según marca activa" |

## Sin lotificar — candidatos sin patrón funcional documentado (no programar todavía)

37 Flows (sección A2 del inventario) y 12 LWC/Aura adicionales (sección C2/D2 del inventario) están confirmados como candidatos por el Manual, pero **sin ninguna descripción de qué cambiar**. No se les asigna lote porque hacerlo sin saber su contenido funcional sería una conclusión nueva no respaldada. Quedan en una bolsa de "pendiente de análisis" hasta que se investiguen individualmente o se descarten explícitamente.

## Resumen de orden recomendado

Lote 0 (prerrequisito) → Lote 1 (Pricebook, 5) → Lote 2 (WorkOrder/garantía, 3) → Lote 3 (misceláneo, 2) → Lote 4 (inventario, 5, incluye el confirmado por Luis) → Lote 5 (búsqueda detallada, 5) → Lote 6 (Community Aura, 5) → Lote 7 (garantía Asset, 1).

## Restricciones respetadas en este plan

- No se programó ninguna fecha ni sprint de calendario.
- No se recuperó metadata de Partial para ninguno de estos componentes.
- No se ejecutó Salesforce CLI.
- No se hizo deploy.
- No se tocó Producción.
- No se modificó nada de Sprint 1.
- No se crearon conclusiones funcionales nuevas — cada fila de "estimación" cita la fuente literal; donde no hay fuente, se dice explícitamente "ninguna identificada" en vez de inventar una.
