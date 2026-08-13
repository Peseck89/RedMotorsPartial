# Cierre técnico conciliado — Sprint 2 Empresa / PEKING

**Fecha de corte:** 13 de agosto de 2026

**Fuente autoritativa:** `MATRIZ_CIERRE_SPRINT2.csv`

**Ambiente funcional de referencia:** RedMotors Sandbox Partial

**Naturaleza:** cierre documental; no resuelve ni autoriza decisiones de negocio pendientes

> **Actualización posterior — 2026-08-13:** las respuestas de Luis desbloquearon F07, N2 y N4 con baselines provisionales. F07 fue ejecutado una sola vez y terminó con un fault de persistencia en v24; no quedó Plan ni línea generada. N4 quedó desplegado técnicamente en v21/v55 y N2 quedó preparado, pero sus QA no se ejecutaron después del fault. Por tanto, la conclusión original de este documento queda sustituida por **C. SPRINT 2 NO CERRABLE — queda trabajo técnico desbloqueado en F07**. Ver `CIERRE_FUNCIONAL_SPRINT2_POST_RESPUESTA_LUIS_20260813.md`.

## Conclusión

**C. SPRINT 2 NO CERRABLE — F07 presenta un fault de persistencia pendiente de diagnóstico concluyente.**

Los 20 Flows del alcance autoritativo permanecen conciliados sin doble conteo. Sin embargo, la ejecución F07 posterior a la respuesta de Luis demostró un fault real de persistencia. La transacción fue revertida y la evidencia preservada no permite identificar de forma concluyente cuál de los dos Record Create finales falló. Este trabajo técnico desbloqueado impide el cierre formal.

N2 tiene dataset provisional listo, N4 está técnicamente desplegado y N3 continúa pendiente de confirmación de Diego. Ninguno debe declararse QA funcional OK en este corte.

## Matriz final por estado

| ID | Flow | Estado final de cierre | Evidencia o pendiente |
|---|---|---|---|
| F01 | `Opportunity_Flow` | **REVISADO SIN CAMBIO** | Resolución dinámica ya presente; regresión depende de datos oficiales de moneda/Pricebook. |
| F02 | `Opp_flow_v4` | **REVISADO SIN CAMBIO** | Sin cambio técnico; evidencia E2E depende de catálogo, moneda y respuesta Softland oficiales. |
| F03 | `BMW_ImportarPlantilla` | **REVISADO SIN CAMBIO** | Sin cambio técnico; QA depende de bodega y territorio PEKING confirmados. |
| F04 | `BMW_Gestiona_Listas_de_Precios` | **REVISADO SIN CAMBIO** | Fallback acotado; la fecha de retiro del mecanismo legacy continúa pendiente. |
| F05 | `Obtener_PricebookEntry_en_Linea_de_Plantilla_de_Presupuesto` | **REVISADO SIN CAMBIO** | Resolución ya validada; QA depende de productos y precios oficiales. |
| F06 | `Opportunity_Flow_From_Work_Order` | **REVISADO SIN CAMBIO** | Ruta PEKING presente; QA depende del mapeo oficial Empresa–Record Type–territorio. |
| F07 | `PlanDeMantenimientoV2` | **BLOQUEO DE NEGOCIO** | Falta vehículo/Product2 PEKING autorizado, WarrantyTerm, tipo de plan y autorización de PBE/QLI QA. |
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

Resumen exacto: 3 **QA FUNCIONAL OK**, 3 **VALIDACIÓN TÉCNICA OK / QA DIFERIDO**, 6 **BLOQUEO DE NEGOCIO**, 6 **REVISADO SIN CAMBIO** y 2 **NO APLICA**. Total: **20 Flows**.

## Flows con creación funcional aprobada

| Flow | Creación funcional | Navegación |
|---|---|---|
| `Opp_Flow_V5` | Opportunity y Quote PEKING persistidos correctamente. | QA OK: el enlace abrió el Quote en v33. |
| `Opp_flow_V3` | Opportunity y Quote PEKING persistidos correctamente. | Remediada en v30; QA manual diferido. |
| `Opp_Flow_v6` | Opportunity y Quote PEKING persistidos correctamente. | Remediada en v82; QA manual diferido. |
| `Opportunity_Flow_V2` | Opportunity y Quote PEKING persistidos correctamente. | Remediada en v8; QA manual diferido. |
| `CreateWoliFromExpense` | WOLI PEKING correcto y único. | No aplica. |
| `AgregarManoObra` | WOLI y Subtipo PEKING correctos y únicos. | El reinicio posterior a `FlowFinish` es una entrevista nueva del runtime, no un loop de creación. |

La creación funcional ya demostrada no se degrada por la validación diferida de los enlaces. Estos enlaces no bloquean el cierre: la metadata fue remediada y validada técnicamente, la creación está aprobada y la comprobación integrada se realizará durante la siguiente ejecución funcional normal, sin repetir Flows solo para producir evidencia.

## Bloqueos que requieren respuesta

### F07 — `PlanDeMantenimientoV2`

Pregunta mínima:

> ¿Qué Product2/vehículo PEKING está autorizado para el caso de mantenimiento, qué WarrantyTerm y tipo de plan le corresponden, y se autoriza crear la PBE/QuoteLineItem QA mínima necesaria en `PEKING Local`?

Con la respuesta se podrá preparar inmediatamente un Quote PEKING/CRC con una sola QLI de tipo vehículo, ejecutar una entrevista manual y registrar el resultado sin ampliar el Flow.

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

El objeto `ServiceTerritory` no tiene hoy una relación con `Empresa__c`; la convención textual existente solo distingue nombres que contienen Otobai y envía todo lo demás por la ruta default. No se agregará una tercera rama textual sin decisión expresa.

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
| Case QA | `500AK00000Hm5usYAB` / `00091090` | Conservar hasta completar F07/N2 y el QA diferido que reutilice el dataset; luego revisar retiro. **QA TEMPORAL — NO PRODUCCIÓN**. |
| Work Order QA | `0WOAK000005jxsH4AQ` / `00087392` | Conservar mientras existan QA pendientes de mantenimiento/WO. **QA TEMPORAL — NO PRODUCCIÓN**. |
| Tipo de trabajo del Case | `a2iAK000001zjndYAA` / `T-180171` | Conservar junto con el Work Order; retirar en conjunto cuando termine el QA pendiente. **QA TEMPORAL — NO PRODUCCIÓN**. |
| Expense | `1V4AK00000001tl0AA` / `EXP-1458` | Conservar como evidencia del QA aprobado; no redisparar. Revisar retiro al cierre de datos QA. **QA TEMPORAL — NO PRODUCCIÓN**. |
| WOLI Subcontrato | `1WLAK0000000rh34AA` | Conservar como evidencia de `CreateWoliFromExpense`; no duplicar. **QA TEMPORAL — NO PRODUCCIÓN**. |
| WOLI Mano de Obra | `1WLAK0000000rif4AA` | Conservar como evidencia de `AgregarManoObra`; no duplicar. **QA TEMPORAL — NO PRODUCCIÓN**. |
| Subtipo Mano de Obra | `a2oAK0000001eQ1YAI` | Conservar junto con el WOLI correspondiente. **QA TEMPORAL — NO PRODUCCIÓN**. |
| PBE SAD001 / PEKING Local | `01uAK000000YRDtYAO` | Conservar como evidencia del QA de Mano de Obra. Precio nominal `1`: no tratar como catálogo comercial definitivo ni como vehículo válido para F07. |
| PBE SAD001 / PEKING Dólares | `01uAK000000YRFVYA4` | Conservar temporalmente con el dataset; configuración provisional no comercial y no aplicable como vehículo de F07. |
| PBE SUB histórica de variante Mano de Obra / PEKING Local | `01uAK000000YRH7YAO` | Conservar: participa en catálogo de Mano de Obra; no confundir con el producto autoritativo Subcontrato. Requiere decisión de catálogo antes de promoción. |
| PBE SUB histórica de variante Mano de Obra / PEKING Dólares | `01uAK000000YRFWYA4` | Misma disposición que la anterior. |
| PBE Subcontrato autoritativa / PEKING Local | `01uAK000000YUy9YAG` | Conservar como evidencia y configuración funcional de Sandbox; `UnitPrice=1` sigue siendo baseline QA, no precio oficial. |
| Service Territory provisional | `0HhAK0000000sbV0AQ` / `PEKING TEMPORAL - NO PRODUCCION` | Conservar hasta respuesta N2/N4; retirar o reemplazar cuando exista territorio oficial. **QA TEMPORAL — NO PRODUCCIÓN**. |
| Permission Set de consulta | `Empresa_Consulta_Flows` | Conservar. Su Read mínimo sobre `Empresa__c` puede constituir configuración funcional real para usuarios que ejecutan los Opportunity Flows; la población definitiva debe confirmarse antes de ampliar asignaciones. |
| Assignment de consulta Empresa | `0PaAK000002rbcz0AA` | Conservar para el usuario QA que ejecuta los Opportunity Flows; no ampliar masivamente sin definición funcional. |
| Permission Set | `WorkOrder_Empresa_Factura_QA` / `0PSAK0000007gIf4AI` | Opción **B: conservar temporalmente** hasta terminar F07/N2 y cualquier QA de Work Order. No promover a Producción ni convertirlo en configuración definitiva sin revisión funcional de permisos. |
| Assignment técnico | `0PaAK000002s2ba0AA` | Conservar junto con el Permission Set mientras continúe el QA; retirar al desmontar el acceso temporal. |
| Assignment usuario funcional QA | `0PaAK000002s5nx0AA` | Conservar mientras el perfil QA deba ejecutar los pendientes; retirar al desmontar el acceso temporal. |

`WorkOrder_Empresa_Factura_QA` no debe eliminarse todavía porque F07/N2 pueden requerir acceso al mismo dataset. Tampoco debe convertirse automáticamente en configuración real: su contenido fue creado para QA, está rotulado **QA TEMPORAL — NO PROMOVER A PRODUCCIÓN**, y una solución definitiva exige decidir qué perfiles funcionales necesitan el campo y con qué nivel de acceso.

## Preguntas mínimas para Luis/Diego

1. Para F07: Product2/vehículo PEKING, WarrantyTerm, tipo de plan y autorización de PBE/QLI QA.
2. Para N2: bodega, territorio, reserva, despacho y taller oficiales para las rutas Quote→Work Order.
3. Para N3: si PEKING usa garantía de fábrica y el mecanismo/campo autorizado para identificarla y segregar WOLI.
4. Para N4: servicios, agenda, sucursales y territorios oficiales, más el mecanismo estructural de Empresa para Service Territory.

No se requieren nuevas confirmaciones sobre los Flows ya aprobados ni sobre la creación funcional ya demostrada.

## Mensaje propuesto para WhatsApp

> Hola Luis/Diego. Sprint 2 está prácticamente cerrado técnicamente: los principales Flows de PEKING ya pasaron QA de creación y los de mano de obra quedaron aprobados. Para cerrar los pendientes funcionales solo necesito cuatro definiciones: 1) para mantenimiento, qué vehículo/Product2, WarrantyTerm y tipo de plan usar, y si autorizan la PBE/QLI QA mínima; 2) para Quote a Work Order, qué bodega, territorio, reserva, despacho y taller aplican; 3) si PEKING usa garantía de fábrica y con qué campo o mecanismo se identifica; y 4) qué servicios, agenda, sucursales y territorios corresponden a PEKING, incluyendo cómo relacionar el territorio con la Empresa. Con esas respuestas retomo únicamente los bloques afectados.

Este mensaje queda preparado; no se envió.

## Tabla de reanudación

| Respuesta negocio | Componente desbloqueado | Acción | QA requerido |
|---|---|---|---|
| F07: vehículo/Product2 + WarrantyTerm + tipo de plan + autorización PBE/QLI | `PlanDeMantenimientoV2` | Preparar una QLI PEKING válida y ejecutar el caso sin ampliar el Flow. | Una entrevista manual con estados positivo y controlado. |
| N2: bodega/territorio/reserva/despacho/taller | `Work_Order_from_Quote`, `Work_Order_from_Quote_Selective` | Sustituir datos provisionales por configuración autorizada si corresponde; no reabrir la resolución técnica de Empresa. | Una ejecución normal y una selectiva, con trazabilidad Quote–WO–WOLI. |
| N3: garantía y mecanismo/campo | `SegregateWOLIs` | Implementar solo la regla autorizada y resolver el Record Type sin Id fijo dentro del mismo sublote. | Segregación con y sin garantía; regresión Bavarian/Otobai. |
| N4: servicios/agenda/sucursales/territorios + relación Empresa | `aperturaCaseWorOrderEvent`, `ct_newCaseWorkOrderEvent` | Configurar la fuente estructural y las rutas autorizadas, sin inferir por texto. | Caso–WO–Evento para PEKING y regresión de empresas existentes. |
| Sesión funcional Mostrador disponible | `Opp_Flow_v6`, `Opportunity_Flow_V2` | Ejecutar las rutas ya desplegadas sin modificar usuario ni metadata. | Una sesión por Flow; confirmar Empresa, Quote y enlace. |
| Siguiente ejecución funcional normal | `Opp_flow_V3`, `Opp_Flow_v6`, `Opportunity_Flow_V2` | Verificar el enlace ya remediado sin repetir solo por evidencia. | Apertura correcta del Quote. |

## Siguiente paso recomendado

Enviar el mensaje preparado a Luis/Diego y esperar las cuatro definiciones agrupadas. Al recibirlas, priorizar F07 por ser el pendiente P0 más acotado; continuar después con N2, N3 y N4 según disponibilidad de respuestas. No iniciar implementación antes de contar con la respuesta correspondiente.

## Límites del cierre

- No se ejecutaron Flows ni QA adicionales.
- No se modificaron datos, permisos, metadata o configuración.
- No se eliminó ningún artefacto temporal.
- No se consultó ni modificó Producción.
- El QA diferido y los bloqueos de negocio permanecen explícitamente abiertos.
