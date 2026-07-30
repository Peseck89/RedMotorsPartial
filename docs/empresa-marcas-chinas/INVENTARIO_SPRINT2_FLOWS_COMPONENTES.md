# Inventario exacto Sprint 2 — Flows y Componentes (Empresa / Marcas Chinas)

## Estado del documento

**INVENTARIO, no alcance confirmado.** Ningún componente de este documento está autorizado para implementación. No se ejecutó Salesforce CLI ni retrieve de Partial en esta sesión — las columnas "existe en Partial" reflejan únicamente la comparación que el Manual de desarrollo capturó el 2026-07-22 (6 días de antigüedad respecto a hoy), no un estado verificado ahora.

**AVISO (2026-07-28, corregido en segunda revisión):** la columna "Sprint confirmado" de este documento usa el lenguaje de la sesión en que se escribió ("No confirmado — candidato"). Desde `REGLAS_ALCANCE_AUTORIZADO.md`, todo lo listado aquí debe leerse bajo la clasificación formal AUTORIZADO / PENDIENTE DE CONFIRMACIÓN / FUERA DE ALCANCE / DEPENDENCIA TÉCNICA. **Corrección:** ni los 5 Flows de Pricebook de la sección B ni `rm_vu_inventario` (fila C.5) están en estado "AUTORIZADO PARA IMPLEMENTACIÓN" — `rm_vu_inventario` está autorizado por nombre pero sin cambio funcional extraído, y los 5 Flows de Pricebook siguen pendientes de validación documental nombre por nombre (ver la tabla-puerta corregida en `REGLAS_ALCANCE_AUTORIZADO.md`). Todo lo demás en este inventario es PENDIENTE DE CONFIRMACIÓN.

## Método

Se buscó exclusivamente en las fuentes de rango 1-3 (ver `SPRINT2_FUENTES_AUTORITATIVAS.md`): comunicación directa de Luis, el documento original de alcance (PDF) y el Manual de desarrollo (DOCX). No se usó el repositorio completo como universo de búsqueda — el repositorio tiene 455 Flows, 201 LWC y 90 Aura en total; usar "todo lo encontrado" habría violado la instrucción explícita. Cada fila de este inventario existe porque una fuente de rango 1-3 la nombra, no porque exista en Git.

## Resumen de conteo (respuesta directa a la regla de conteo)

| Universo | Cantidad exacta respaldada por documentos | Estimación de Luis | Diferencia |
|---|---:|---|---|
| Flows nombrados en el Manual (Anexo A.3, candidatos) | 47 | ~20 | +27 sin resolver |
| Flows nombrados adicionalmente solo en el documento original (no están en los 47 del Manual) | 1 (`PlanDeMantenimientoV2`) | — | — |
| Flows con **patrón funcional específico documentado** (no solo listados) | 10 | — | — |
| Flows relacionados con Pricebooks, con patrón documentado | **5** (coincide exactamente con la cifra de Luis) | 5 | 0 |
| LWC/Aura nombrados en el Manual (Anexo A.4, candidatos, bundles distintos) | 22 | ~16 | +6 sin resolver |
| LWC/Aura nombrados adicionalmente solo en el documento original (no están en los 22 del Manual) | 14 | — | — |
| **Universo total distinto de LWC/Aura entre ambas fuentes rango 2+3** | 36 | ~16 | +20 sin resolver |
| LWC confirmado explícitamente por Luis por nombre | 1 (`rm_vu_inventario`) | 1 | 0 |

**Conclusión de conteo:** la cifra de Luis para Pricebooks (5) coincide exactamente con lo documentado. Las cifras generales (~20 Flows, ~16 LWC/Aura) son **menores** que el universo de candidatos documentado en las fuentes de rango 2-3 (47 Flows, 22-36 LWC/Aura según se cuente). Esto es esperable: el Manual mismo advierte que su Anexo A es un universo de candidatos, no una lista final. La diferencia debe resolverse con una curación explícita de Luis/Diego sobre cuáles de los 47/36 candidatos son los ~20/~16 confirmados — **no se completó esa curación en esta sesión** porque hacerlo sin esa confirmación sería inventar alcance.

## A. Flows con patrón funcional documentado (10)

| # | Nombre API | Fuente exacta | Objeto/proceso afectado | Empresa actual | Cambio requerido para Empresa/PEKING | Existe en Git | Existe en Partial (Manual, 2026-07-22) | Test/validación | Sprint confirmado | Estado |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | `Opportunity_Flow` | PDF §4 (fila "Flow / Opportunity_Flow, Opp_flow_v4") | Opportunity | Decision `Encuentra_Price_Book` + Assignments `Asigna_Bavarial_Local/Dolar`, `Asigna_Oto_Local/Otobai_Dolar` | Agregar 2 reglas + 2 assignments para la compañía nueva (Local/Dólar) | Sí | Active / identical — reconfirmado 2026-07-29 vía Tooling API (v25, sin cambios) | 8 escenarios preparados, ver `EVIDENCIA_PRICEBOOK_FLOWS_PEKING_20260729.md` | AUTORIZADO PARA IMPLEMENTACIÓN (ver `REGLAS_ALCANCE_AUTORIZADO.md`) | **BLOQUEADO (2026-07-29):** Pricebooks `PEKING Local`/`PEKING Dólares` confirmados, pero `Opportunity.BMW_Compania__c` (picklist restringido) no tiene ningún valor PEKING activo — sin Record Types alternativos, cero datos reales. Ningún cambio aplicado. |
| 2 | `Opp_flow_v4` | PDF §4 (misma fila que #1) | Opportunity | Mismo patrón que `Opportunity_Flow` | Mismo cambio que `Opportunity_Flow` | Sí | Active / identical — reconfirmado 2026-07-29 (v16, sin cambios) | Mismos 8 escenarios que `Opportunity_Flow` | AUTORIZADO PARA IMPLEMENTACIÓN | **BLOQUEADO (2026-07-29)** — misma causa que `Opportunity_Flow`, ver `EVIDENCIA_PRICEBOOK_FLOWS_PEKING_20260729.md` |
| 3 | `BMW_ImportarPlantilla` | PDF §4 + §10 | Plantilla_de_Presupuesto\_\_c / WorkOrder | Decision `Determina_Nombre_Price_Book` (mismo mecanismo que #1/#2; la fórmula `EmpresaProductoMantenimiento` citada no existe en este archivo, ver corrección en `REGLAS_ALCANCE_AUTORIZADO.md`); RecordLookup filtra `Plantilla_de_Presupuesto__c.BMW_Compania__c` | Pasar el `else` binario a 3 vías; crear plantillas de presupuesto para la compañía nueva | Sí | Active / identical — reconfirmado 2026-07-29 (v13, sin cambios) | Mismos 8 escenarios que `Opportunity_Flow` | AUTORIZADO PARA IMPLEMENTACIÓN | **BLOQUEADO (2026-07-29)** — misma causa que `Opportunity_Flow`, ver `EVIDENCIA_PRICEBOOK_FLOWS_PEKING_20260729.md` |
| 4 | `PlanDeMantenimientoV2` | PDF §4 (agrupado con `BMW_ImportarPlantilla`) | Plan de mantenimiento | Misma fórmula `EmpresaProductoMantenimiento` binaria | Mismo problema de "else" binario — pasar a 3 vías | Sí | **No está en la lista de 47 del Manual — ver contradicción #2 en `SPRINT2_FUENTES_AUTORITATIVAS.md`** | No documentado | No confirmado — candidato, con discrepancia de fuente | Pendiente de confirmación de por qué no aparece en el Manual |
| 5 | `Work_Order_from_Quote_Selective` | PDF §4 | WorkOrder desde Quote | Decision `revisar_Empresa_Factura` asigna `RMOTOBAI`/`RMBAVARIAN` a la OT | Expandir a 3 vías (es el flow que crea la Work Order desde Quote) | Sí | Active / identical | No documentado | No confirmado — candidato | Pendiente |
| 6 | `Work_Order_from_Quote` | PDF §4 (misma familia que #5) | WorkOrder desde Quote | Mismo patrón que #5 | Mismo cambio que #5 | Sí | Active / identical | No documentado | No confirmado — candidato | Pendiente |
| 7 | `SegregateWOLIs` | PDF §4 | WorkOrderLineItem | 3 Assignments que setean `tipoCargo__c.Garantia_Otobai__c` | Definir si la compañía nueva necesita un campo de garantía análogo (pregunta pendiente, no resuelta por ninguna fuente) | Sí | Active / **different** (Git y Partial ya divergen) | No documentado | No confirmado — candidato | Pendiente; además tiene drift Git/Partial sin explicar |
| 8 | `ReciboUsadosFlow` | PDF §4 | ReciboUsado\_\_c | Choices hardcodeadas `RMBAVARIAN`/`RMOTOBAI` + `DynamicChoiceSet` sobre `ReciboUsado__c.Empresa__c` | El DynamicChoiceSet se actualiza solo al tocar el picklist; las choices hardcodeadas no | Sí | Active / identical | No documentado | No confirmado — candidato | Pendiente |
| 9 | `BMW_Gestiona_Listas_de_Precios` | PDF §4 ("resto de la lista", ejemplo nombrado) + Manual A.3 | Pricebook / Listas de precios | Nombre indica gestión de listas de precios por marca/compañía | No detallado por ninguna fuente — solo nombrado | Sí | Active / identical | No documentado | No confirmado — candidato | Pendiente de análisis funcional (solo existencia confirmada) |
| 10 | `Obtener_PricebookEntry_en_Linea_de_Plantilla_de_Presupuesto` | Manual A.3 | Linea_Plantilla_de_Presupuesto\_\_c / PricebookEntry | Nombre indica resolución de `PricebookEntry` en línea de plantilla | No detallado por ninguna fuente — solo nombrado | Sí | Active / identical | No documentado | No confirmado — candidato | Pendiente de análisis funcional (solo existencia confirmada) |

## B. Flows relacionados con Pricebooks (subconjunto de A — coincide con la cifra de Luis)

Los 5 Pricebook que menciona Luis corresponden exactamente a las filas #1, #2, #3, #9 y #10 de la tabla A: `Opportunity_Flow`, `Opp_flow_v4`, `BMW_ImportarPlantilla`, `BMW_Gestiona_Listas_de_Precios`, `Obtener_PricebookEntry_en_Linea_de_Plantilla_de_Presupuesto`. Los 5 están confirmados como existentes en Git y en el Manual (rango 3). `PlanDeMantenimientoV2` (fila #4) comparte el mismo patrón de riesgo de Pricebook según el documento original, pero **no está entre los 5 de Luis ni entre los 47 del Manual** — se documenta como candidato adicional a confirmar, no como parte de los 5.

## A2. Flows candidatos adicionales del Manual, sin patrón funcional documentado (37)

Estos 37 nombres provienen únicamente del Anexo A.3 del Manual (rango 3) — existencia y estado local/Partial confirmados por esa fuente al 2026-07-22, pero **sin ninguna descripción funcional de qué cambia para Empresa/PEKING** en ninguna fuente disponible. No se investigó su contenido en esta sesión (fuera del alcance de "inventariar", no de "analizar"). "Sprint confirmado" es "No confirmado — candidato" para los 37.

| Nombre API | Estado local (Git, según Manual) | Estado vs. Partial (según Manual, 2026-07-22) | Existe en Git (verificado esta sesión) |
|---|---|---|---|
| `AgregarManoObra` | Active | identical | Sí |
| `alerta_cita_actualizada` | Active | different | Sí |
| `Alerta_de_cita_nueva_o_actualizada` | Obsolete | identical | Sí |
| `aperturaCaseWorOrderEvent` | Active | different | Sí |
| `automateCommUser` | Active | identical | Sí |
| `BMW_Importar_Plantilla_Orden_de_Trabajo` | Active | identical | Sí |
| `Carga_MO_26_Lavado_a_Caso` | Obsolete | identical | Sí |
| `CorreoEventosMotos` | Active | identical | Sí |
| `CreateCaseWorkOrderFromEvent` | Obsolete | identical | Sí |
| `CreateWoliFromExpense` | Active | identical | Sí |
| `cT_Cancelacion_y_reprogramacion_de_citas` | Active | different | Sí |
| `ct_newCaseWorkOrderEvent` | Active | identical | Sí |
| `EnviaCorreoCuandoClienteApruebaPresupuestoEnService` | Active | identical | Sí |
| `Enviar_correo_Fomalizaci_n` | Obsolete | identical | Sí |
| `Enviar_correo_Fomalizacion2` | Obsolete | identical | Sí |
| `Enviar_correo_Formalizaci_n_Usados` | Obsolete | identical | Sí |
| `Enviar_correo_Formalizaci_n_Usados1` | Active | different | Sí |
| `Enviar_correo_Formalizacion1` | Obsolete | identical | Sí |
| `Enviar_correo_Formalizacion3` | Active | different | Sí |
| `FlowEventNuevoEmaiol` | Draft | identical | Sí |
| `FlowOppMostrador` | Draft | identical | Sí |
| `Gasto_Exento_Flow` | Active | identical | Sí |
| `Llena_Porcentaje_de_Usados` | Active | identical | Sí |
| `NotificacionCargoGarantiaBSI` | Obsolete | different | Sí |
| `Opp_flow_V3` | Active | identical | Sí |
| `Opp_Flow_V5` | Draft | identical | Sí |
| `Opp_Flow_v6` | Active | different | Sí |
| `Opportunity_Flow_From_Work_Order` | Active | identical | Sí |
| `Opportunity_Flow_V2` | Active | identical | Sí |
| `Reenviar_formalizacion` | Active | different | Sí |
| `ReenviarEncuesta` | Draft | different | Sí |
| `ReenviarEncuestaOpp` | Draft | different | Sí |
| `SearchByAssetOrVIN` | Active | identical | Sí |
| `Send_Cotizacion` | Active | different | Sí |
| `Show_Softland_Order_Response` | Active | identical | Sí |
| `trafico_cotizador_web` | Draft | different | Sí |
| `Work_Order_On_Create_Create_OPP_and_Quote_and_Update_WO_Values` | Active | missing_in_compare | **No** |
| `WorkOrderCancelada` | Active | identical | Sí |

**Elementos dudosos dentro de A2:** `Work_Order_On_Create_Create_OPP_and_Quote_and_Update_WO_Values` no se encontró en el Git de esta sesión pese a estar en el Manual como "Active" con estado `missing_in_compare` contra Partial — riesgo de que sea un nombre obsoleto, renombrado, o de un flow eliminado entre el 2026-07-22 y hoy. Los 8 Flows con estado `Obsolete` (`Alerta_de_cita_nueva_o_actualizada`, `Carga_MO_26_Lavado_a_Caso`, `CreateCaseWorkOrderFromEvent`, `Enviar_correo_Fomalizaci_n`, `Enviar_correo_Fomalizacion2`, `Enviar_correo_Formalizaci_n_Usados`, `Enviar_correo_Formalizacion1`, `NotificacionCargoGarantiaBSI`) son dudosos por definición — un Flow obsoleto probablemente no requiere cambios funcionales activos; deben confirmarse como fuera de alcance antes de incluirse en cualquier lote de ejecución.

## C. LWC con patrón funcional documentado (10)

| # | Nombre API | Fuente exacta | Objeto/proceso afectado | Empresa actual | Cambio requerido | Existe en Git | Existe en Partial | Controlador Apex asociado (E) | Sprint confirmado | Estado |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | `productSearcher` | PDF §5, §10 | Búsqueda de productos/inventario | Arrays hardcodeados `preciosBavarian`/`preciosFantasia` | Refactorizar para n compañías, no 2 fijas | Sí | No verificado en esta sesión | `ProductSearcherController`, `SampleLookupController` | No confirmado — candidato | Crítico para inventario per el documento original |
| 2 | `rm_vn_inventario` | PDF §5, §10 | Inventario VN | Mismo mapeo de precios hardcodeado que `productSearcher` | Refactorizar mapeo de precios por compañía | Sí | No verificado | `RM_VN_Inventario_Ctrl` | No confirmado — candidato | Pendiente — ver contradicción de nombre con `rm_vu_inventario` |
| 3 | `rm_vn_inventario_movil` | PDF §5 | Inventario VN móvil | Mismo patrón que #2 | Mismo cambio que #2 | Sí | No verificado | No determinado en esta sesión | No confirmado — candidato | Pendiente |
| 4 | `rm_vn_crear_opp_inventario` | PDF §5 | Creación de Opp — selección de inventario | Mismo patrón de precios hardcodeados | Mismo cambio que #1/#2 | Sí | No verificado | No determinado en esta sesión | No confirmado — candidato | Pendiente |
| 5 | `rm_vu_inventario` | **Luis (rango 1, mensaje directo de esta sesión)** + Manual A.4 | Inventario VU | No descrito funcionalmente por ninguna fuente de rango 2-3 | No descrito — solo confirmado por nombre por Luis y por el Manual | Sí | Candidato en Manual (sin anotación local/Partial para LWC) | `RM_VU_Inventario_Ctrl` | **Confirmado por Luis** | Único componente con confirmación de rango 1 explícita |
| 6 | `busquedaDetallada` | PDF §5 (fila "busquedaDetallada, qoSearchDetailProduct...") + Manual A.4 | Búsqueda detallada de productos | Recibe `empresaFactura` vía `@api` desde el padre; depende del Apex de localización en Softland | Verificar que el Apex detrás (`getSoftlandLocations`, etc.) soporte la 3ra compañía | Sí | Candidato en Manual | `BusquedaDetalladaController` | No confirmado — candidato | **Parcialmente tocado en Sprint 1** (Bloque 10 revisó el Apex, no el JS) — ver `IMPLEMENTACION_BLOQUE10_BUSQUEDA_DETALLADA.md` |
| 7 | `qoSearchDetailProduct` | PDF §5 (misma fila) + Manual A.4 | Búsqueda detallada (Quote) | Mismo patrón que #6 | Mismo cambio que #6 | Sí | Candidato en Manual | No determinado en esta sesión | No confirmado — candidato | Pendiente |
| 8 | `woSearchDetailProduct` | PDF §5 (misma fila) + Manual A.4 | Búsqueda detallada (WorkOrder) | Mismo patrón que #6 | Mismo cambio que #6 | Sí | Candidato en Manual | No determinado en esta sesión | No confirmado — candidato | Pendiente |
| 9 | `localizacionDetails` | PDF §5 (misma fila que #6-8) | Detalle de localización | Mismo patrón que #6 | Mismo cambio que #6 | Sí | No verificado (no está en Manual A.4) | No determinado en esta sesión | No confirmado — candidato | Pendiente |
| 10 | `assetGarantiaLookupLwc` | PDF §5 | Lookup de garantía de Asset | URL hardcodeada `...?servicio=BMW&callcenter=true` | Parametrizar según marca activa | Sí | No verificado (no está en Manual A.4) | No determinado en esta sesión | No confirmado — candidato | Pendiente |

## D. Aura con patrón funcional documentado (1 grupo)

| # | Nombre API (grupo) | Fuente exacta | Objeto/proceso afectado | Empresa actual | Cambio requerido | Existe en Git | Existe en Partial | Sprint confirmado | Estado |
|---|---|---|---|---|---|---|---|---|---|
| 1 | `CommunityMenu`, `CommunityControl`, `CommunityCalendar`, `customerCommunity_lwc`, `callcenterCommunity_lwc` | PDF §5 ("Componentes Aura de Community") + Manual A.4 (los 5 confirmados como bundles existentes) | Community / portal de clientes | `if (selectedService === "Otobai")` + JSON hardcodeado de ubicaciones por servicio | Agregar rama de servicio para citas/community de la compañía nueva | Sí (los 5) | Candidatos en Manual (sin anotación individual) | No confirmado — candidato | Pendiente — grupo de 5 Aura con el mismo patrón condicional binario |

## C2 / D2. LWC/Aura candidatos adicionales sin patrón funcional documentado (26)

**Del documento original (PDF §5), nombrados pero sin narrativa propia más allá del nombre (7):**

| Nombre API | Tipo | Fuente | Existe en Git |
|---|---|---|---|
| `quoliGridDespacho` | LWC | PDF §5 (array `MOTO_SERVICE_TERRITORIES`) | Sí |
| `woliGridDespacho` | LWC | PDF §5 (mismo patrón) | Sí |
| `kpiSucursales` | LWC | PDF §5 (array fijo de sucursales) + Manual A.4 | **No** — nombrado en ambas fuentes pero ausente del Git actual |
| `rm_vn_get_record_opp_record_types` | LWC | PDF §5 | Sí |
| `rm_vn_crear_opp_home` | LWC | PDF §5 (agrupado `(_movil)`) | Sí |
| `rm_vn_crear_opp_home_movil` | LWC | PDF §5 (mismo grupo) | Sí |
| `rm_vn_crear_opp_general` | LWC | PDF §5 | Sí |
| `pricebookReferenceDetails` | LWC | PDF §5 (agrupado con `busquedaDetallada`) | Sí |
| `rm_vu_crear_opp` | LWC | PDF §10 (FlexiPage de inventario VU) | Sí |
| `cT_Estadisticas_Inventario_lwc` | LWC | PDF §10 (FlexiPage de inventario) | **No** — nombrado en el PDF, ausente del Git actual |

**Del Manual (Anexo A.4), sin narrativa en ninguna fuente (12):**

| Nombre API | Tipo | Existe en Git |
|---|---|---|
| `bMW_newLineaPlantilla` | Aura | Sí |
| `CommunityAppointmentsHistory` | Aura | Sí |
| `CommunityCancelAppointments` | Aura | Sí |
| `CommunityCarsManagement` | Aura | Sí |
| `CommunityHome` | Aura | Sí |
| `CommunityInspectionHistory` | Aura | Sí |
| `CommunityManageWorksMenu` | Aura | Sí |
| `CommunityProfile` | Aura | Sí |
| `customAssetSection_lwc` | LWC | Sí |
| `rm_vu_crear_opp_confirmar` | LWC | Sí |
| `vehiculosEnTallerTabla` | LWC | Sí |

**Elementos dudosos dentro de C2/D2:** `kpiSucursales` y `cT_Estadisticas_Inventario_lwc` están nombrados por fuentes de rango 2 y/o 3 pero **no existen en el Git actual** — requieren confirmación de si fueron renombrados, eliminados, o si la referencia del documento es a un componente que nunca se versionó en este repositorio.

## E. Elementos expresamente fuera del Sprint 2

- Todo lo ya reconciliado en Sprint 1: `BatchGetCatalogoSoftland` y los 7 `BatchGet*Softland` (el documento original los menciona en su tabla de Flows/Batches, pero ya se reconciliaron en el cierre 33x3 de Sprint 1 — no se repiten aquí).
- Los 41 clases / 3 triggers del alcance técnico total de Sprint 1 y sus derivados (33x3) — dominio Apex, no Flows/LWC, y ya gestionado por su propio hilo de trabajo.
- Cualquier Flow marcado `Obsolete` en el Manual (8 identificados en la sección A2) — candidatos a excluirse explícitamente, pendiente de confirmación.
- `PlanDeMantenimientoV2` no debe tratarse como uno de los "5 Pricebook" de Luis — es un candidato adicional del documento original, fuera de esa cuenta de 5.

## F. Dependencias Apex (solo referencia, no cuentan en el conteo de Sprint 2)

Controladores Apex identificados como dependencia directa de los LWC de la sección C, mediante import real (`@salesforce/apex/...`) en el código fuente actual:

- `ProductSearcherController`, `SampleLookupController` (← `productSearcher`)
- `RM_VN_Inventario_Ctrl` (← `rm_vn_inventario`)
- `RM_VU_Inventario_Ctrl` (← `rm_vu_inventario`)
- `BusquedaDetalladaController` (← `busquedaDetallada`)

El resto de controladores asociados a los componentes de las secciones A2/C2/D2 no se determinaron en esta sesión (no se leyó el código fuente de cada componente, solo se inventarió su existencia y su mención documental). Esta lista es referencia técnica únicamente — **no se agrega ninguna clase Apex al conteo de componentes de Sprint 2**.
