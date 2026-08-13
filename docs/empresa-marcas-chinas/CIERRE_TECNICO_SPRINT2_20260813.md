# Cierre técnico conciliado — Sprint 2 Empresa / PEKING

**Fecha de corte:** 13 de agosto de 2026

**Fuente operativa vigente:** este documento y `CIERRE_FUNCIONAL_SPRINT2_POST_RESPUESTA_LUIS_20260813.md`. La fila F07 de `MATRIZ_CIERRE_SPRINT2.csv` queda pendiente de sincronización editorial.

**Ambiente funcional de referencia:** RedMotors Sandbox Partial

**Naturaleza:** cierre documental; no resuelve ni autoriza decisiones de negocio pendientes

> **Actualización posterior — 2026-08-13:** las respuestas de Luis desbloquearon F07, N2 y N4 con baselines provisionales. El fault inicial de F07 fue identificado como FLS faltante en `Copy_1_of_CreateQuoteLineItem`; el Permission Set temporal mínimo fue desplegado y el único reintento v24 terminó `Completed`, con Plan y QLI persistidos. N4 quedó desplegado técnicamente en v21/v55 y N2 quedó preparado, pero sus QA no se ejecutaron en este bloque. Ver `CIERRE_FUNCIONAL_SPRINT2_POST_RESPUESTA_LUIS_20260813.md`.

## Conclusión

**C. SPRINT 2 NO CERRABLE — F07 está cerrado; N2/N4 conservan QA funcional pendiente y N3 espera confirmación de Diego.**

Los 20 Flows del alcance autoritativo permanecen conciliados sin doble conteo. F07 superó el defecto FLS preexistente y quedó funcionalmente validado con PEKING. El cierre formal sigue pendiente porque N2 y N4 aún requieren sus QA dirigidos y N3 continúa sujeto a confirmación externa.

N2 tiene dataset provisional listo, N4 está técnicamente desplegado y N3 continúa pendiente de confirmación de Diego. Ninguno de esos tres bloques debe declararse QA funcional OK en este corte.

## Matriz final por estado

| ID | Flow | Estado final de cierre | Evidencia o pendiente |
|---|---|---|---|
| F01 | `Opportunity_Flow` | **REVISADO SIN CAMBIO** | Resolución dinámica ya presente; regresión depende de datos oficiales de moneda/Pricebook. |
| F02 | `Opp_flow_v4` | **REVISADO SIN CAMBIO** | Sin cambio técnico; evidencia E2E depende de catálogo, moneda y respuesta Softland oficiales. |
| F03 | `BMW_ImportarPlantilla` | **REVISADO SIN CAMBIO** | Sin cambio técnico; QA depende de bodega y territorio PEKING confirmados. |
| F04 | `BMW_Gestiona_Listas_de_Precios` | **REVISADO SIN CAMBIO** | Fallback acotado; la fecha de retiro del mecanismo legacy continúa pendiente. |
| F05 | `Obtener_PricebookEntry_en_Linea_de_Plantilla_de_Presupuesto` | **REVISADO SIN CAMBIO** | Resolución ya validada; QA depende de productos y precios oficiales. |
| F06 | `Opportunity_Flow_From_Work_Order` | **REVISADO SIN CAMBIO** | Ruta PEKING presente; QA depende del mapeo oficial Empresa–Record Type–territorio. |
| F07 | `PlanDeMantenimientoV2` | **QA FUNCIONAL OK** | v24 `Completed`; Plan `A-0607` y QLI Regalía PEKING Local/CRC persistidos sin duplicado ni rollback. |
| F08 | `Work_Order_from_Quote_Selective` | **BLOQUEO DE NEGOCIO** | Resolución técnica de Empresa terminada en v8; N2 y QA funcional pendientes. |
| F09 | `Work_Order_from_Quote` | **BLOQUEO DE NEGOCIO** | Resolución técnica de Empresa terminada en v10; N2 y QA funcional pendientes. |
| F10 | `SegregateWOLIs` | **BLOQUEO DE NEGOCIO** | N3: garantía/segregación PEKING sin equivalencia autorizada. |
| F11 | `ReciboUsadosFlow` | **NO APLICA** | Proceso exclusivo de usados; Luis confirmó no extenderlo a PEKING. |
| F12 | `Opp_Flow_V5` | **QA FUNCIONAL OK** | Creación y navegación al Quote aprobadas en v33. |
| F13 | `Opp_flow_V3` | **VALIDACIÓN TÉCNICA OK / QA DIFERIDO** | Creación funcional aprobada; enlace v30 pendiente en la siguiente ejecución normal. |
| F14 | `Opp_Flow_v6` | **VALIDACIÓN TÉCNICA OK / QA DIFERIDO** | Creación funcional aprobada; enlace v82 y ruta Mostrador pendientes. |
| F15 | `Opportunity_Flow_V2` | **VALIDACIÓN TÉCNICA OK / QA DIFERIDO** | Creación funcional aprobada; enlace v8 y ruta Mostrador pendientes. |
| F16 | `CreateWoliFromExpense` | **QA FUNCIONAL OK** | WOLI PEKING único y correcto creado desde `EXP-1458`. |
| F17 | `aperturaCaseWorOrderEvent` | **BLOQUEO DE NEGOCIO** | N4: servicios, agenda, sucursales, territorios y fuente estructural de Empresa. |
| F18 | `ct_newCaseWorkOrderEvent` | **BLOQUEO DE NEGOCIO** | Mismo bloqueo N4. |
| F19 | `AgregarManoObra` | **QA FUNCIONAL OK** | WOLI y Subtipo PEKING únicos, sin fault, rollback ni duplicidad. |
| F20 | `Carga_MO_26_Lavado_a_Caso` | **NO APLICA** | Sin versión activa; Luis confirmó no trabajar Flows inactivos. |

Resumen exacto: 4 **QA FUNCIONAL OK**, 3 **VALIDACIÓN TÉCNICA OK / QA DIFERIDO**, 5 **BLOQUEO DE NEGOCIO**, 6 **REVISADO SIN CAMBIO** y 2 **NO APLICA**. Total: **20 Flows**.

## Flows con creación funcional aprobada

| Flow | Creación funcional | Navegación |
|---|---|---|
| `Opp_Flow_V5` | Opportunity y Quote PEKING persistidos correctamente. | QA OK: el enlace abrió el Quote en v33. |
| `Opp_flow_V3` | Opportunity y Quote PEKING persistidos correctamente. | Remediada en v30; QA manual diferido. |
| `Opp_Flow_v6` | Opportunity y Quote PEKING persistidos correctamente. | Remediada en v82; QA manual diferido. |
| `Opportunity_Flow_V2` | Opportunity y Quote PEKING persistidos correctamente. | Remediada en v8; QA manual diferido. |
| `CreateWoliFromExpense` | WOLI PEKING correcto y único. | No aplica. |
| `AgregarManoObra` | WOLI y Subtipo PEKING correctos y únicos. | El reinicio posterior a `FlowFinish` es una entrevista nueva del runtime, no un loop de creación. |
| `PlanDeMantenimientoV2` | Plan `A-0607` y QLI Regalía PEKING correctos y únicos. | No aplica; finalizó con `FlowFinish`. |

La creación funcional ya demostrada no se degrada por la validación diferida de los enlaces. Estos enlaces no bloquean el cierre: la metadata fue remediada y validada técnicamente, la creación está aprobada y la comprobación integrada se realizará durante la siguiente ejecución funcional normal, sin repetir Flows solo para producir evidencia.

## Bloqueos que requieren respuesta

### F07 — `PlanDeMantenimientoV2`

F07 está cerrado funcionalmente. El primer QA falló por FLS de `QuoteLineItem.Quote_Line_Item__c` y `QuoteLineItem.esRegalia__c`; el permiso temporal `Plan_Mantenimiento_QLI_QA` concedió únicamente Read/Edit sobre esos campos. El reintento único v24 finalizó `Completed` y persistió exactamente un Plan y un QLI.

### N2 — Quote a Work Order

Flows afectados: `Work_Order_from_Quote` y `Work_Order_from_Quote_Selective`.

- Resuelto técnicamente: ambos usan `Opportunity.Empresa_Operadora__c` y `Empresa__r.Codigo_ERP__c`, sin rama literal PEKING; el fallback Bavarian/Otobai permanece intacto. Versiones activas: v10 y v8.
- Pendiente de catálogo/configuración: bodega y territorio oficiales aplicables a PEKING.
- Decisión mínima: confirmar bodega, territorio, reserva, despacho y taller que deben aplicar en las rutas normal y selectiva.

Después de la respuesta se configurarán únicamente los valores autorizados y se ejecutará una QA funcional por ruta, con trazabilidad Quote–Work Order–WOLI.

### N3 — garantía y segregación

Flow afectado: `SegregateWOLIs`.

Pregunta mínima:

> ¿PEKING utiliza garantía de fábrica y cuál es el mecanismo o campo equivalente autorizado para identificarla y segregar los WOLI?

No existe una equivalencia Bavarian demostrada que pueda copiarse. La resolución técnica del Record Type por `DeveloperName` puede abordarse dentro del mismo bloque, pero no define el comportamiento PEKING ni elimina la necesidad de N3.

### N4 — servicios, agenda y territorios

Flows afectados: `aperturaCaseWorOrderEvent` y `ct_newCaseWorkOrderEvent`.

Pregunta mínima:

> ¿Qué servicios, agenda, sucursales y territorios oficiales corresponden a PEKING, y qué relación estructural debe identificar la Empresa en lugar de depender del texto del nombre del Service Territory?

`ServiceTerritory.Empresa__c` ya fue desplegado como fuente configurable. Las versiones activas v21/v55 conservan el fallback legacy para territorios sin Empresa y no agregan una tercera rama textual PEKING. El QA funcional de esa configuración permanece pendiente.

## QA diferido documentado

| Pendiente | Estado | ¿Bloquea el cierre? |
|---|---|---|
| Enlace de `Opp_flow_V3` v30 | Creación OK; navegación estándar desplegada y técnicamente validada. | No. Validar en la siguiente ejecución funcional normal. |
| Enlace de `Opp_Flow_v6` v82 | Creación OK; navegación estándar desplegada y técnicamente validada. | No. Validar en la siguiente ejecución funcional normal. |
| Enlace de `Opportunity_Flow_V2` v8 | Creación OK; navegación estándar desplegada y técnicamente validada. | No. Validar en la siguiente ejecución funcional normal. |
| Rutas Mostrador de v82/v8 | Requieren sesión funcional autorizada de tipo `Mostrador` o `Todas`. | No. Mantener como QA diferido; no modificar usuarios para forzar la prueba. |

## Artefactos QA temporales y disposición propuesta

No se elimina ni modifica ningún artefacto en este cierre.

| Artefacto | Identificación | Disposición propuesta |
|---|---|---|
| Case QA | `500AK00000Hm5usYAB` / `00091090` | Conservar hasta completar N2 y el QA diferido que reutilice el dataset; luego revisar retiro. **QA TEMPORAL — NO PRODUCCIÓN**. |
| Work Order QA | `0WOAK000005jxsH4AQ` / `00087392` | Conservar mientras existan QA pendientes de mantenimiento/WO. **QA TEMPORAL — NO PRODUCCIÓN**. |
| Tipo de trabajo del Case | `a2iAK000001zjndYAA` / `T-180171` | Conservar junto con el Work Order; retirar en conjunto cuando termine el QA pendiente. **QA TEMPORAL — NO PRODUCCIÓN**. |
| Expense | `1V4AK00000001tl0AA` / `EXP-1458` | Conservar como evidencia del QA aprobado; no redisparar. Revisar retiro al cierre de datos QA. **QA TEMPORAL — NO PRODUCCIÓN**. |
| WOLI Subcontrato | `1WLAK0000000rh34AA` | Conservar como evidencia de `CreateWoliFromExpense`; no duplicar. **QA TEMPORAL — NO PRODUCCIÓN**. |
| WOLI Mano de Obra | `1WLAK0000000rif4AA` | Conservar como evidencia de `AgregarManoObra`; no duplicar. **QA TEMPORAL — NO PRODUCCIÓN**. |
| Subtipo Mano de Obra | `a2oAK0000001eQ1YAI` | Conservar junto con el WOLI correspondiente. **QA TEMPORAL — NO PRODUCCIÓN**. |
| PBE SAD001 / PEKING Local | `01uAK000000YRDtYAO` | Conservar como evidencia de los QA de Mano de Obra y F07. Precio nominal `1`: no tratar como catálogo comercial definitivo. |
| PBE SAD001 / PEKING Dólares | `01uAK000000YRFVYA4` | Conservar temporalmente con el dataset; configuración provisional no comercial y no aplicable como vehículo de F07. |
| PBE SUB histórica de variante Mano de Obra / PEKING Local | `01uAK000000YRH7YAO` | Conservar: participa en catálogo de Mano de Obra; no confundir con el producto autoritativo Subcontrato. Requiere decisión de catálogo antes de promoción. |
| PBE SUB histórica de variante Mano de Obra / PEKING Dólares | `01uAK000000YRFWYA4` | Misma disposición que la anterior. |
| PBE Subcontrato autoritativa / PEKING Local | `01uAK000000YUy9YAG` | Conservar como evidencia y configuración funcional de Sandbox; `UnitPrice=1` sigue siendo baseline QA, no precio oficial. |
| Service Territory provisional | `0HhAK0000000sbV0AQ` / `PEKING TEMPORAL - NO PRODUCCION` | Conservar hasta respuesta N2/N4; retirar o reemplazar cuando exista territorio oficial. **QA TEMPORAL — NO PRODUCCIÓN**. |
| Permission Set de consulta | `Empresa_Consulta_Flows` | Conservar. Su Read mínimo sobre `Empresa__c` puede constituir configuración funcional real para usuarios que ejecutan los Opportunity Flows; la población definitiva debe confirmarse antes de ampliar asignaciones. |
| Assignment de consulta Empresa | `0PaAK000002rbcz0AA` | Conservar para el usuario QA que ejecuta los Opportunity Flows; no ampliar masivamente sin definición funcional. |
| Permission Set | `WorkOrder_Empresa_Factura_QA` / `0PSAK0000007gIf4AI` | Opción **B: conservar temporalmente** hasta terminar N2 y cualquier QA de Work Order. No promover a Producción ni convertirlo en configuración definitiva sin revisión funcional de permisos. |
| Assignment técnico | `0PaAK000002s2ba0AA` | Conservar junto con el Permission Set mientras continúe el QA; retirar al desmontar el acceso temporal. |
| Assignment usuario funcional QA | `0PaAK000002s5nx0AA` | Conservar mientras el perfil QA deba ejecutar los pendientes; retirar al desmontar el acceso temporal. |
| Permission Set F07 | `Plan_Mantenimiento_QLI_QA` / `0PSAK0000007hwH4AQ` | Conservar hasta finalizar Sprint 2 y revisar el modelo definitivo de acceso. **QA TEMPORAL — NO PROMOVER A PRODUCCIÓN**. |
| Assignment F07 usuario funcional QA | `0PaAK000002sntp0AA` | Conservar junto con el Permission Set mientras se mantenga el dataset y la validación funcional; no asignar masivamente. |
| Plan F07 | `a4VAK0000000XAT2A2` / `A-0607` | Conservar como evidencia del QA PEKING aprobado; dato provisional basado en Bavarian. |
| QLI Regalía F07 | `0QLAK000001wmYM4AY` | Conservar junto con el Plan; PEKING Local, CRC, `SAD001`, precio nominal `1`, dato QA no comercial. |

`WorkOrder_Empresa_Factura_QA` no debe eliminarse todavía porque N2 requiere acceso al mismo dataset. Tampoco debe convertirse automáticamente en configuración real: su contenido fue creado para QA, está rotulado **QA TEMPORAL — NO PROMOVER A PRODUCCIÓN**, y una solución definitiva exige decidir qué perfiles funcionales necesitan el campo y con qué nivel de acceso.

## Preguntas mínimas para Luis/Diego

1. Para N2: bodega, territorio, reserva, despacho y taller oficiales para las rutas Quote→Work Order; entretanto se conserva el baseline provisional autorizado.
2. Para N3: confirmar si PEKING usa garantía de fábrica y el mecanismo/campo autorizado para identificarla y segregar WOLI.
3. Para N4: confirmar servicios, agenda, sucursales y territorios oficiales que sustituirán la configuración provisional.

No se requieren nuevas confirmaciones sobre los Flows ya aprobados ni sobre la creación funcional ya demostrada.

## Mensaje propuesto para WhatsApp

> Hola Luis/Diego. F07 de mantenimiento ya quedó validado funcionalmente con PEKING. Para cerrar los pendientes restantes necesito confirmar: 1) para Quote a Work Order, qué bodega, territorio, reserva, despacho y taller definitivos aplican; 2) si PEKING usa garantía de fábrica y con qué campo o mecanismo se identifica; y 3) qué servicios, agenda, sucursales y territorios definitivos sustituirán la configuración provisional. Con esas respuestas se cierran únicamente los bloques afectados.

Este mensaje queda preparado; no se envió.

## Tabla de reanudación

| Respuesta negocio | Componente desbloqueado | Acción | QA requerido |
|---|---|---|---|
| N2: bodega/territorio/reserva/despacho/taller | `Work_Order_from_Quote`, `Work_Order_from_Quote_Selective` | Sustituir datos provisionales por configuración autorizada si corresponde; no reabrir la resolución técnica de Empresa. | Una ejecución normal y una selectiva, con trazabilidad Quote–WO–WOLI. |
| N3: garantía y mecanismo/campo | `SegregateWOLIs` | Implementar solo la regla autorizada y resolver el Record Type sin Id fijo dentro del mismo sublote. | Segregación con y sin garantía; regresión Bavarian/Otobai. |
| N4: servicios/agenda/sucursales/territorios + relación Empresa | `aperturaCaseWorOrderEvent`, `ct_newCaseWorkOrderEvent` | Configurar la fuente estructural y las rutas autorizadas, sin inferir por texto. | Caso–WO–Evento para PEKING y regresión de empresas existentes. |
| Sesión funcional Mostrador disponible | `Opp_Flow_v6`, `Opportunity_Flow_V2` | Ejecutar las rutas ya desplegadas sin modificar usuario ni metadata. | Una sesión por Flow; confirmar Empresa, Quote y enlace. |
| Siguiente ejecución funcional normal | `Opp_flow_V3`, `Opp_Flow_v6`, `Opportunity_Flow_V2` | Verificar el enlace ya remediado sin repetir solo por evidencia. | Apertura correcta del Quote. |

## Siguiente paso recomendado

Continuar con el QA dirigido de N2 usando el dataset provisional ya preparado y, después, con N4. N3 permanece detenido hasta la confirmación de Diego. No reabrir F07 ni repetir su entrevista únicamente para producir evidencia adicional.

## Límites del cierre

- Se ejecutó únicamente el reintento autorizado de F07; no se avanzó N2/N4.
- Se agregó únicamente el FLS temporal mínimo y su asignación al usuario QA.
- No se eliminó ningún artefacto temporal.
- No se consultó ni modificó Producción.
- El QA diferido y los bloqueos de negocio permanecen explícitamente abiertos.
