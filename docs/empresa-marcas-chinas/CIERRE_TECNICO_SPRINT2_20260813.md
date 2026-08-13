# Cierre técnico conciliado — Sprint 2 Empresa / PEKING

**Fecha de corte:** 13 de agosto de 2026

**Fuente operativa vigente:** este documento y `CIERRE_FUNCIONAL_SPRINT2_POST_RESPUESTA_LUIS_20260813.md`. Las filas F07/F08/F09 de `MATRIZ_CIERRE_SPRINT2.csv` quedan pendientes de sincronización editorial.

**Ambiente funcional de referencia:** RedMotors Sandbox Partial

**Naturaleza:** cierre documental; no resuelve ni autoriza decisiones de negocio pendientes

> **Actualización posterior — 2026-08-13:** las respuestas de Luis desbloquearon F07, N2 y N4 con baselines provisionales. F07 terminó `Completed`, con Plan y QLI persistidos. N2 cerró el FLS mínimo y completó correctamente las rutas normal v11 y selectiva v9, con Work Orders y WOLI PEKING persistidos. En N4, tras el FLS mínimo de Activity y una corrección autorizada del vínculo de Opportunity del Asset QA (de una Opportunity legacy BMW a una Opportunity PEKING ya validada), v21 y v55 se ejecutaron una vez cada uno sin fault, con Case, Work Order y Opportunity estructuralmente PEKING. Adicionalmente se corrigió el bug confirmado de recálculo de Pricebook (`Pricebook2.Name = Id`) en los 4 Flows de Opportunity (`Opp_flow_V3` v31, `Opp_Flow_V5` v34, `Opp_Flow_v6` v83, `Opportunity_Flow_V2` v9), que afectaba también a Bavarian y Otobai, no solo a PEKING. Ver `CIERRE_FUNCIONAL_SPRINT2_POST_RESPUESTA_LUIS_20260813.md`.

## Conclusión

**A. SPRINT 2 CERRADO TÉCNICAMENTE — único pendiente de negocio: N3 (garantía PEKING), a la espera de Diego.**

**Corrección respecto a versiones anteriores de este documento:** el estado "F07, N2 y N4 cerrados, único pendiente N3" registrado antes del 13 de agosto de 2026 (tarde) era prematuro — en ese momento el bug de recálculo de Pricebook en los 4 Flows de Opportunity todavía no se había corregido. Esa corrección ya se aplicó (ver sección siguiente); con ella, la afirmación de "único pendiente N3" pasa a ser exacta.

Los 20 Flows del alcance autoritativo permanecen conciliados sin doble conteo. F07, N2 y N4 superaron sus defectos preexistentes y quedaron funcionalmente validados con PEKING. Los 4 Flows de Opportunity ya no dependen de la búsqueda incorrecta de Pricebook por nombre. El cierre técnico queda completo; el único pendiente restante es de negocio (N3).

N2 tiene dataset provisional, remediación técnica desplegada y QA funcional aprobado en ambas variantes. N4 tiene el mismo tipo de dataset provisional, la corrección del vínculo de Opportunity del Asset QA, y QA funcional aprobado en v21 y v55. N3 continúa pendiente de confirmación de Diego y no debe declararse QA funcional OK en este corte.

## Corrección del bug de Pricebook2.Name = Id (4 Flows de Opportunity)

**Defecto:** `Obtener_PriceBook_Opp` (RecordLookup) filtraba `Pricebook2.Name EqualTo Resolver_Pricebook_Empresa.pricebookId` — comparando un campo de texto contra un Id, una condición que nunca podía ser verdadera. Su salida `.Id`, siempre nula, se usaba para asignar `Pricebook2Id` en el Presupuesto y en la Oportunidad durante la ruta de **recálculo/reapertura** de un Presupuesto ya existente (no en la ruta de creación inicial, que usa `Resolver_Pricebook_Empresa.pricebookId` directamente y por eso su QA anterior fue exitoso). Afectaba a las 3 empresas por igual, no solo a PEKING.

**Corrección aplicada (cambio mínimo, sin tocar lógica de creación ni navegación):**

| Flow | Qué se encontró | Corrección |
|---|---|---|
| `Opp_flow_V3` | `Coloca_PB_en_Quote` y la actualización de Opportunity usaban `Obtener_PriceBook_Opp.Id` | Reemplazado por `Resolver_Pricebook_Empresa.pricebookId`; eliminado el `RecordLookup` roto; reconectados sus 5 predecesores (incluida la rama legacy ya muerta `Encuentra_Price_Book`) directamente al Decision `Price_Book_vac_o` |
| `Opp_Flow_V5` | Las asignaciones ya usaban `Resolver_Pricebook_Empresa.pricebookId` directamente; solo quedaba el `RecordLookup` roto, sin consumidores | Eliminado el `RecordLookup` muerto; reconectados sus 6 predecesores directamente a `Price_Book_vac_o` |
| `Opp_Flow_v6` | Mismo caso que `Opp_Flow_V5` (ambas rutas, principal y Mostrador, ya usaban el valor correcto) | Mismo tratamiento: eliminado el `RecordLookup` muerto, predecesores reconectados |
| `Opportunity_Flow_V2` | 3 consumidores del valor roto: `Coloca_PB_en_Quote`, actualización de Opportunity, y un `RecordLookup` de `PricebookEntry` filtrado por `Pricebook2Id = Obtener_PriceBook_Opp.Id` | Los 3 reemplazados por `Resolver_Pricebook_Empresa.pricebookId`; eliminado el `RecordLookup` roto; predecesores reconectados a `Price_Book_vac_o` |

No se modificó la lógica de creación inicial (ya validada con QA funcional), no se tocó navegación, no se agregaron hardcodes ni distinción por empresa — el resolver ya es agnóstico de Bavarian/Otobai/PEKING.

**Deploy:** `RedMotorsSandbox` únicamente. Por una incompatibilidad de versión de API preexistente entre estos 4 archivos (no causada por este cambio — 2 requieren API ≤54.0 por un componente de pantalla tipo Sección sin `regionContainerType`, y los otros 2 requieren API ≥67.0 por el uso de `styleProperties` en varios campos de pantalla), el despliegue se dividió en dos manifiestos:
- `Opp_flow_V3` + `Opportunity_Flow_V2` — deploy `0AfAK0000014j610AA`, API 54.0, 0 errores.
- `Opp_Flow_V5` + `Opp_Flow_v6` — deploy `0AfAK0000014ezD0AQ`, API 67.0, 0 errores.

Versiones activas resultantes: `Opp_flow_V3` v31, `Opportunity_Flow_V2` v9, `Opp_Flow_V5` v34, `Opp_Flow_v6` v83.

**QA de la ruta de recálculo/reapertura:**

- **Validación estructural (completa):** confirmado por lectura directa que los 4 Flows ahora asignan `Pricebook2Id` desde `Resolver_Pricebook_Empresa.pricebookId` en todos los puntos donde antes dependían del `RecordLookup` roto, sin ninguna rama condicionada por empresa — el mismo camino de código se ejecuta igual para PEKING, Bavarian y Otobai.
- **Validación funcional en vivo: diferida.** Ejercer esta ruta específica requiere reabrir un Presupuesto ya existente con `Pricebook2Id` vacío desde la Oportunidad (acción "Ir a presupuesto" u equivalente) — una interacción de pantalla que no se pudo ejecutar de forma automatizada en este bloque. Se buscaron Quotes existentes con `Pricebook2Id` nulo como candidatos de prueba; los únicos encontrados no tienen Empresa PEKING/Bavarian/Otobai asociada, por lo que no sirven como evidencia funcional real y no se usaron. **Pendiente:** una ejecución manual dirigida (reapertura de un Presupuesto con Pricebook vacío) para las 3 empresas, documentando resultado exacto — no bloquea el cierre técnico porque el código ya no puede producir el resultado incorrecto observado antes (Id nulo); solo confirma en vivo lo que la lectura de código ya demuestra.

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
| F08 | `Work_Order_from_Quote_Selective` | **QA FUNCIONAL OK** | v9 `Completed`; Work Order `00087394` y un WOLI PEKING persistidos, sin fault, rollback ni duplicidad. |
| F09 | `Work_Order_from_Quote` | **QA FUNCIONAL OK** | v11 `Completed`; Work Order `00087393` y un WOLI PEKING persistidos, sin fault, rollback ni duplicidad. |
| F10 | `SegregateWOLIs` | **BLOQUEO DE NEGOCIO** | N3: garantía/segregación PEKING sin equivalencia autorizada. |
| F11 | `ReciboUsadosFlow` | **NO APLICA** | Proceso exclusivo de usados; Luis confirmó no extenderlo a PEKING. |
| F12 | `Opp_Flow_V5` | **QA FUNCIONAL OK** | Creación y navegación al Quote aprobadas en v33; bug de Pricebook corregido en v34, validación funcional de la ruta de recálculo diferida (estructural OK). |
| F13 | `Opp_flow_V3` | **VALIDACIÓN TÉCNICA OK / QA DIFERIDO** | Creación funcional aprobada; enlace pendiente en la siguiente ejecución normal; bug de Pricebook corregido en v31, validación funcional de la ruta de recálculo diferida (estructural OK). |
| F14 | `Opp_Flow_v6` | **VALIDACIÓN TÉCNICA OK / QA DIFERIDO** | Creación funcional aprobada; enlace y ruta Mostrador pendientes; bug de Pricebook corregido en v83, validación funcional de la ruta de recálculo diferida (estructural OK). |
| F15 | `Opportunity_Flow_V2` | **VALIDACIÓN TÉCNICA OK / QA DIFERIDO** | Creación funcional aprobada; enlace y ruta Mostrador pendientes; bug de Pricebook corregido en v9, validación funcional de la ruta de recálculo diferida (estructural OK). |
| F16 | `CreateWoliFromExpense` | **QA FUNCIONAL OK** | WOLI PEKING único y correcto creado desde `EXP-1458`. |
| F17 | `aperturaCaseWorOrderEvent` | **QA FUNCIONAL OK** | v21 sin fault; Case `00091091` y Work Order `00087393` PEKING validados tras corregir el vínculo de Opportunity del Asset QA. |
| F18 | `ct_newCaseWorkOrderEvent` | **QA FUNCIONAL OK** | v55 sin fault; Asistió y Kilometraje persistidos sobre el mismo dataset PEKING, sin duplicidad. |
| F19 | `AgregarManoObra` | **QA FUNCIONAL OK** | WOLI y Subtipo PEKING únicos, sin fault, rollback ni duplicidad. |
| F20 | `Carga_MO_26_Lavado_a_Caso` | **NO APLICA** | Sin versión activa; Luis confirmó no trabajar Flows inactivos. |

Resumen exacto: 8 **QA FUNCIONAL OK**, 3 **VALIDACIÓN TÉCNICA OK / QA DIFERIDO**, 1 **BLOQUEO DE NEGOCIO**, 6 **REVISADO SIN CAMBIO** y 2 **NO APLICA**. Total: **20 Flows**.

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

- Resuelto técnicamente: ambos asignan `WorkOrder.empresaFacturaCP__c = Opportunity.Empresa_Operadora__c` y conservan `WorkOrder.empresaFactura__c = Empresa__r.Codigo_ERP__c`, sin rama literal PEKING; el fallback Bavarian/Otobai permanece intacto. Versiones activas: v11 y v9. Dry-run `0AfAK0000014YVZ0A2`; deploy `0AfAK0000014YXB0A2`.
- Fault histórico: la primera entrevista normal v11 (`0FoAK000001dktg0AA`, GUID `353408d488878c0aed243898ed1819ffc2d6b7-a94a`) terminó `Error` en `Asignar_Codigo_Empresa_Operadora` por falta de lectura sobre `Empresa__c.Codigo_ERP__c`; no persistió registros.
- Remediación FLS: `Empresa_Codigo_ERP_QA` (`0PSAK0000007i2j4AA`) concede únicamente Read sobre `Empresa__c.Codigo_ERP__c`, sin Edit ni permisos de objeto adicionales. Dry-run `0AfAK0000014ZUr0AM`, deploy `0AfAK0000014ZY50AM`, asignación funcional `0PaAK000002skDC0AY`.
- QA normal: el único reintento v11 terminó `Completed`; log `8gZAK000000IsGU2A0`, GUID `469561e249a549bc9c5a63f24a19ffc414307-5b7d`. Persistió Work Order `0WOAK000005k8vl4AA` / `00087393` y un WOLI `1WLAK0000000s8T4AQ`.
- QA selectivo: ejecutado una sola vez después del éxito normal; v9 terminó `Completed`, log `8gZAK000000ItPS2A0`, GUID `9761e249a549bc9c5a63f24a19ffc414307-4569`. Persistió Work Order `0WOAK000005k8yz4AA` / `00087394` y un WOLI `1WLAK0000000sBh4AI`.
- Resultado: ambas Work Orders conservan PEKING en `empresaFacturaCP__c`, `RMPEKING` en el campo legacy, CRC, Pricebook `PEKING Local`, bodega y territorio provisionales; no hubo fault, rollback ni duplicidad.

Estado N2: **QA FUNCIONAL OK — PEKING**. Bodega y territorio continúan **CONFIGURACIÓN OPERATIVA PROVISIONAL BASADA EN BAVARIAN — NO PRODUCCIÓN**.

### N3 — garantía y segregación

Flow afectado: `SegregateWOLIs`.

Pregunta mínima:

> ¿PEKING utiliza garantía de fábrica y cuál es el mecanismo o campo equivalente autorizado para identificarla y segregar los WOLI?

No existe una equivalencia Bavarian demostrada que pueda copiarse. La resolución técnica del Record Type por `DeveloperName` puede abordarse dentro del mismo bloque, pero no define el comportamiento PEKING ni elimina la necesidad de N3.

### N4 — servicios, agenda y territorios

Flows afectados: `aperturaCaseWorOrderEvent` y `ct_newCaseWorkOrderEvent`.

Pregunta mínima:

> ¿Qué servicios, agenda, sucursales y territorios oficiales corresponden a PEKING, y qué relación estructural debe identificar la Empresa en lugar de depender del texto del nombre del Service Territory?

`ServiceTerritory.Empresa__c` ya fue desplegado como fuente configurable. Las versiones activas v21/v55 conservan el fallback legacy para territorios sin Empresa y no agregan una tercera rama textual PEKING.

El dataset dirigido usa Event `00UAK000003Bik12AC`, usuario asesor `005PH000007m1k9YAA`, `OwnerId = Asesor__c` y Service Territory `0HhAK0000000sbV0AQ` relacionado con PEKING/RMPEKING. Para cubrir exclusivamente la lectura requerida se asignaron `Empresa_Consulta_Flows` (`0PaAK000002spqp0AA`) y `Empresa_Codigo_ERP_QA` (`0PaAK000002swU60AI`). La comprobación efectiva confirmó Read sobre `Empresa__c`, `ServiceTerritory.Empresa__c`, `Empresa__c.Codigo_ERP__c` y los registros involucrados.

El fallo de inicialización quedó demostrado como ausencia de Read sobre `Event.WhoId`. El permiso temporal `Event_Who_QA` (`0PSAK0000007iE14AI`) concede solo Read sobre `Event.WhoId` y el par Activity `Task.WhoId`, con Edit=false; dry-run `0AfAK0000014eJF0AY`, deploy `0AfAK0000014eKr0AI` y asignación exclusiva `0PaAK000002slyU0AQ`.

La única ejecución posterior de v21 inició correctamente y llegó sin fault a la pantalla final: log `8gZAK000000IwNJ2A0`, GUID `1544989ff01e71df3f04aa31b5d19ffc9ce303-745e`. Creó el Case `500AK00000HnxI5YAJ` / `00091091`, relacionó el Event con la Work Order existente `0WOAK000005k8vl4AA` / `00087393` y mantuvo PEKING, RMPEKING, CRC y Pricebook `PEKING Local`, sin crear una Work Order duplicada. No creó Opportunity ni Quote.

La Opportunity preexistente asociada `006AK00000JM25SYAT` no cumplió el criterio de N4: `Empresa_Operadora__c = null`, compañía legacy vacía, moneda USD, Pricebook estándar y Record Type BMW.

Con autorización explícita se aplicó un único DML sobre el Asset QA `02iAK000001xtZNYAY`, actualizando exclusivamente `Oportunidad__c` y `Oportunidad_relacionada__c` hacia la Opportunity ya validada `006AK00000JT9UoYAL` (`Empresa_Operadora__c = PEKING`, Pricebook `PEKING Local`, CRC, `BMW_Compania__c = null`, misma cuenta QA, con Quote `0Q0AK000001zJ8P0AU` relacionada). Ningún otro campo ni registro fue modificado.

Con el dataset corregido, v21 se re-ejecutó una sola vez sobre el mismo Event: sin fault, reconoció el Case/Work Order existentes (mensaje controlado "Este evento ya cuenta con caso y orden de trabajo"), sin crear duplicados. FlowInterviewLog `8gZAK000000IxeM2AS`. Verificado por SOQL: la Opportunity asociada al Asset ya resuelve `Empresa_Operadora__r.Codigo_ERP__c = RMPEKING`, sin fallback Bavarian/Otobai.

Con v21 aprobado, `ct_newCaseWorkOrderEvent` v55 se ejecutó una sola vez sobre el mismo Event: avanzó por las pantallas de Asistió y Kilometraje/Horas de uso y terminó con el mismo mensaje controlado, sin error. FlowInterviewLog `8gZAK000000IxuT2AS`. Verificado por SOQL: `Event.Estado__c = "Asistió"`, `Kilometraje_Horas_de_uso__c = 10` y `Asset.Kilometros__c = 10` persistidos sin rollback; Work Order `00087393` conserva `empresaFacturaCP__c` → PEKING y `empresaFactura__c = RMPEKING`; el total de Cases (2) y Work Orders (3) de la cuenta QA no cambió — sin duplicidad.

Estado N4: **QA FUNCIONAL OK — PEKING**.

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
| Event QA N4 | `00UAK000003Bik12AC` | Conservar sin redisparar hasta diagnosticar el arranque de v21; `OwnerId = Asesor__c`, PEKING provisional y sin Case/WO/Quote persistidos. **QA TEMPORAL — NO PRODUCCIÓN**. |
| Permission Set de consulta | `Empresa_Consulta_Flows` | Conservar. Su Read mínimo sobre `Empresa__c` puede constituir configuración funcional real para usuarios que ejecutan los Opportunity Flows; la población definitiva debe confirmarse antes de ampliar asignaciones. |
| Assignment de consulta Empresa | `0PaAK000002rbcz0AA` | Conservar para el usuario QA que ejecuta los Opportunity Flows; no ampliar masivamente sin definición funcional. |
| Assignment N4 consulta Empresa | `0PaAK000002spqp0AA` | Asignación temporal al usuario asesor N4; retirar o revisar al cerrar el diagnóstico funcional. |
| Permission Set | `WorkOrder_Empresa_Factura_QA` / `0PSAK0000007gIf4AI` | Opción **B: conservar temporalmente** hasta terminar N2 y cualquier QA de Work Order. No promover a Producción ni convertirlo en configuración definitiva sin revisión funcional de permisos. |
| Assignment técnico | `0PaAK000002s2ba0AA` | Conservar junto con el Permission Set mientras continúe el QA; retirar al desmontar el acceso temporal. |
| Assignment usuario funcional QA | `0PaAK000002s5nx0AA` | Conservar mientras el perfil QA deba ejecutar los pendientes; retirar al desmontar el acceso temporal. |
| Permission Set F07 | `Plan_Mantenimiento_QLI_QA` / `0PSAK0000007hwH4AQ` | Conservar hasta finalizar Sprint 2 y revisar el modelo definitivo de acceso. **QA TEMPORAL — NO PROMOVER A PRODUCCIÓN**. |
| Assignment F07 usuario funcional QA | `0PaAK000002sntp0AA` | Conservar junto con el Permission Set mientras se mantenga el dataset y la validación funcional; no asignar masivamente. |
| Permission Set N2 | `Empresa_Codigo_ERP_QA` / `0PSAK0000007i2j4AA` | Conservar hasta finalizar Sprint 2 y revisar el modelo definitivo de acceso. Solo Read sobre `Empresa__c.Codigo_ERP__c`; **QA TEMPORAL — NO PROMOVER A PRODUCCIÓN**. |
| Assignment N2 usuario funcional QA | `0PaAK000002skDC0AY` | Conservar junto con el Permission Set; no ampliar asignaciones sin revisión funcional. |
| Assignment N4 código ERP | `0PaAK000002swU60AI` | Asignación temporal al usuario asesor N4; concede únicamente el Read ya definido por el Permission Set. |
| Permission Set N4 Activity | `Event_Who_QA` / `0PSAK0000007iE14AI` | Solo Read sobre `Event.WhoId` y `Task.WhoId`, con Edit=false. **QA TEMPORAL — NO PROMOVER A PRODUCCIÓN**. |
| Assignment N4 Activity | `0PaAK000002slyU0AQ` | Asignación exclusiva al usuario asesor N4; conservar solo mientras se completa el QA. |
| Work Order N2 normal | `0WOAK000005k8vl4AA` / `00087393` | Evidencia QA PEKING normal aprobada; conservar con su WOLI. Configuración provisional, no Producción. |
| WOLI N2 normal | `1WLAK0000000s8T4AQ` | Único WOLI de la ejecución normal; conservar como evidencia y no duplicar. |
| Work Order N2 selectiva | `0WOAK000005k8yz4AA` / `00087394` | Evidencia QA PEKING selectiva aprobada; conservar con su WOLI. Configuración provisional, no Producción. |
| WOLI N2 selectiva | `1WLAK0000000sBh4AI` | Único WOLI de la ejecución selectiva; conservar como evidencia y no duplicar. |
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
| N2: bodega/territorio/reserva/despacho/taller | `Work_Order_from_Quote`, `Work_Order_from_Quote_Selective` | Sustituir datos provisionales por configuración autorizada si corresponde; no reabrir la resolución técnica de Empresa ni repetir el QA ya aprobado solo por evidencia. | Validar únicamente si la configuración oficial difiere del baseline provisional. |
| N3: garantía y mecanismo/campo | `SegregateWOLIs` | Implementar solo la regla autorizada y resolver el Record Type sin Id fijo dentro del mismo sublote. | Segregación con y sin garantía; regresión Bavarian/Otobai. |
| N4: servicios/agenda/sucursales/territorios oficiales | `aperturaCaseWorOrderEvent`, `ct_newCaseWorkOrderEvent` | QA funcional ya cerrado con dataset provisional; sustituir por configuración oficial cuando exista, sin reabrir la resolución técnica ya validada. | Validar únicamente si la configuración oficial difiere del baseline provisional. |
| Sesión funcional Mostrador disponible | `Opp_Flow_v6`, `Opportunity_Flow_V2` | Ejecutar las rutas ya desplegadas sin modificar usuario ni metadata. | Una sesión por Flow; confirmar Empresa, Quote y enlace. |
| Siguiente ejecución funcional normal | `Opp_flow_V3`, `Opp_Flow_v6`, `Opportunity_Flow_V2` | Verificar el enlace ya remediado sin repetir solo por evidencia. | Apertura correcta del Quote. |

## Siguiente paso recomendado

N3 permanece detenido hasta la confirmación de Diego sobre garantía de fábrica PEKING — es el único pendiente real de Sprint 2. No reabrir F07, N2, N4 ni la corrección de Pricebook, ni repetir entrevistas únicamente para producir evidencia adicional. Queda diferida solo la validación funcional en vivo de la ruta de recálculo de Pricebook (ver sección dedicada arriba), que no bloquea el cierre técnico.

## Límites del cierre

- Se ejecutó F07 y, posteriormente, una única entrevista normal N2 y una única entrevista selectiva N2. En N4 se ejecutó una sola vez v21 después de aplicar el FLS mínimo de Activity y corregir el vínculo de Opportunity del Asset QA, y una sola vez v55 tras aprobar v21; ambas sin fault, rollback ni duplicidad.
- Se agregó únicamente Read sobre `Empresa__c`, `ServiceTerritory.Empresa__c`, `Empresa__c.Codigo_ERP__c`, `Event.WhoId` y `Task.WhoId` mediante Permission Sets y asignaciones dirigidas a los usuarios QA correspondientes. Se aplicó además un único DML de datos (lookups de Opportunity en el Asset QA `02iAK000001xtZNYAY`, con autorización explícita).
- Se corrigió el bug de recálculo de Pricebook en `Opp_flow_V3`, `Opp_Flow_V5`, `Opp_Flow_v6` y `Opportunity_Flow_V2` (cambio mínimo de metadata Flow, sin Apex, sin tocar lógica de creación ni navegación); no se ejecutó ningún QA funcional en vivo adicional de creación ya validada, solo se corrigió la ruta de recálculo previamente rota.
- No se eliminó ningún artefacto temporal.
- No se consultó ni modificó Producción.
- El QA diferido y los bloqueos de negocio permanecen explícitamente abiertos.
