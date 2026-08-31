# Contexto activo — Empresa / Marcas Chinas

**ALCANCE PRIMERO: ningún componente se trabaja solo por aparecer en documentos, Git o Partial. Requiere autorización explícita de Luis o Diego.**

Ver la regla completa, el orden de autoridad entre fuentes y la tabla de autorización vigente en [`REGLAS_ALCANCE_AUTORIZADO.md`](REGLAS_ALCANCE_AUTORIZADO.md). Esa regla es obligatoria para cualquier agente (Claude Code, Codex, Cowork, ChatGPT) que trabaje en este proyecto, en cualquier Sprint o worktree.

**Índice maestro de auditoría (agregado 2026-08-05):** para el estado vigente completo del proyecto (Sprint 1/2/3, TD-RQ308, documentos sustituidos, worktrees pendientes) sin depender de inventarios de auditoría de más de mil filas, ver [`auditoria/INDICE_MAESTRO_AUDITORIA.md`](auditoria/INDICE_MAESTRO_AUDITORIA.md) y [`auditoria/MATRIZ_DOCUMENTOS_CLAVE_VIGENCIA.csv`](auditoria/MATRIZ_DOCUMENTOS_CLAVE_VIGENCIA.csv).

## REGLA DE CARGA DE CONTEXTO (obligatoria, vigente desde 2026-07-28)

**Los agentes no deben leer recursivamente todos los documentos de `docs/empresa-marcas-chinas`.** Deben comenzar únicamente por este archivo (`README_CONTEXTO_ACTIVO.md`) y abrir después solo los archivos expresamente listados abajo como contexto activo del Sprint en curso. No abrir documentos históricos de Sprint 1 (bloques, reconciliación 33x3, cierres, inventarios antiguos) salvo que un documento activo remita expresamente a uno de ellos para resolver una dependencia puntual.

## Contexto activo del Sprint 2 (única lista válida — nada más)

1. [`REGLAS_ALCANCE_AUTORIZADO.md`](REGLAS_ALCANCE_AUTORIZADO.md)
2. [`SPRINT2_FUENTES_AUTORITATIVAS.md`](SPRINT2_FUENTES_AUTORITATIVAS.md)
3. [`INVENTARIO_SPRINT2_FLOWS_COMPONENTES.md`](INVENTARIO_SPRINT2_FLOWS_COMPONENTES.md)
4. [`PLAN_EJECUCION_SPRINT2.md`](PLAN_EJECUCION_SPRINT2.md)
5. El documento original de alcance del cliente (`DEV Evaluación - Alcance - Inclusión de nueva Empresa- Marchas chinas Redmotors.docx.pdf`).
6. El Manual de desarrollo (`Manual_Analisis_Empresa_RedMotors_2026-07-22.docx`) — **solo las secciones ya citadas** por los documentos activos de arriba, no lectura completa.
7. Respuestas directas de Luis y Diego (no son un archivo — viven en la conversación de trabajo activa).

El cierre de Sprint 1 (`CIERRE_TECNICO_SPRINT1_33_CLASES_3_TRIGGERS_DRAFT.md` y todo lo indexado en [`INDICE_DOCUMENTOS_HISTORICOS.md`](INDICE_DOCUMENTOS_HISTORICOS.md)) queda disponible **solo como referencia** cuando se consulte una dependencia de ese Sprint — nunca como punto de partida para trabajo de Sprint 2.

## Contexto activo de Sprint 3 y TD-RQ308 (agregado 2026-08-05)

Luis autorizó el 2026-08-05 **continuar Sprint 3** con el alcance del documento original de
PortalNet, para ganar tiempo, aunque algunas definiciones puedan ajustarse después ("Puedes
continuar con Sprint 3 con lo que tenemos del documento original... es mejor continuar para ganar
tiempo, aunque luego cambie un poco la definición"). Esta instrucción prevalece sobre cualquier
lectura de los documentos de abajo como bloqueo total a la espera de confirmaciones — las
definiciones pendientes quedan como puntos que pueden generar ajustes posteriores, no como condición
para no avanzar. Detalle completo en `auditoria/INDICE_MAESTRO_AUDITORIA.md` sección 7.3.

Documentos vigentes para Sprint 3 y TD-RQ308 (además de los del Sprint 2 listados arriba, que siguen
aplicando porque Sprint 2 conserva pendientes de negocio y QA diferido documentados):

1. [`DEV_Evaluacion_Alcance_Actualizada_20260805.docx`](DEV_Evaluacion_Alcance_Actualizada_20260805.docx) — fuente principal de alcance vigente.
2. [`TD-RQ308_Diferencias_Alcance_Entrega_Oficial.docx`](TD-RQ308_Diferencias_Alcance_Entrega_Oficial.docx) — documento oficial para Red Motors, aprobado en general por Luis.
3. [`CONTEXTO_RQ308_Y_AUTORIZACION_SPRINT3_20260805.md`](CONTEXTO_RQ308_Y_AUTORIZACION_SPRINT3_20260805.md)
4. [`PLAN_SPRINT3_CORREGIDO_20260805.md`](PLAN_SPRINT3_CORREGIDO_20260805.md), [`LOTES_SPRINT3_CORREGIDOS_20260805.md`](LOTES_SPRINT3_CORREGIDOS_20260805.md), [`MATRIZ_ALCANCE_SPRINT3_CORREGIDA_20260805.csv`](MATRIZ_ALCANCE_SPRINT3_CORREGIDA_20260805.csv)
5. [`CIERRE_TECNICO_SPRINT3_20260813.md`](CIERRE_TECNICO_SPRINT3_20260813.md) y [`MATRIZ_CIERRE_SPRINT3.csv`](MATRIZ_CIERRE_SPRINT3.csv) — cierre autoritativo de B7, B9 y B11; datos finales diferidos y N3/N4 separados como Sprint 2 congelado.
6. [`CONTINUIDAD_QA_PRODUCCION_20260830.md`](CONTINUIDAD_QA_PRODUCCION_20260830.md) — QA en Producción del 30/08/2026 (CU-07 a CU-10), decisión de Luis sobre resolución de bodega VN por `RM_Config`, autorización excepcional de trabajo directo en Producción para CU-10, y evidencias en Drive. CU-10 no cerrado.

**Sustituidos — no usar para ejecución** (autodeclarados "SUSTITUIDO PARA EJECUCIÓN", conservados solo
por trazabilidad): `LOTES_PROPUESTOS_SPRINT3_20260805.md`, `PLAN_INICIO_SPRINT3_20260805.md`,
`RESUMEN_PREPARACION_SPRINT3_20260805.md`, `MATRIZ_ALCANCE_SPRINT3_PRELIMINAR_20260805.csv`.

## Estado actual (2026-07-28)

- **Sprint 1 (33x3):** cerrado técnicamente en `feature/pc/redmotors-empresa-marcas-chinas-sprint1-20260724` (HEAD `bf1e260`). Clase 33 pendiente de confirmación de Luis.
- **Sprint 2 (Flows/LWC/Aura):** worktree `RedMotors-Sprint2-Flows-Components`, rama `feature/pc/redmotors-empresa-marcas-chinas-sprint2-flows-components-20260728`.
- **Bloque previo al cierre (2026-08-12):** corregidas 2 de 3 regresiones técnicas Apex confirmadas por precheck (`precioProductoJSON.cls`, `BatchGetCatalogoSoftland.calloutBodega`); el tercer hallazgo (schedulers Softland) se confirmó que **no** era una regresión real y se dejó documentado sin cambios de código. Ver [`RESULTADO_PRECHECK_REGRESIONES_20260812.md`](RESULTADO_PRECHECK_REGRESIONES_20260812.md).
- **Bloque N2/N3/N4 (2026-08-12):** con autorización directa de Luis para usar Bavarian como baseline provisional, se migraron `Work_Order_from_Quote` y `Work_Order_from_Quote_Selective` a resolución por `Empresa_Operadora__c` (v10/v8 activas) y se crearon datos provisionales mínimos (4 `PricebookEntry` de PEKING, 1 `ServiceTerritory` provisional). `SegregateWOLIs`, `aperturaCaseWorOrderEvent` y `ct_newCaseWorkOrderEvent` permanecen bloqueados por decisiones de negocio sin equivalente Bavarian (N3/N4) — sin cambios de código. Ver [`RESULTADO_BLOQUE_N2N3N4_PEKING_20260812.md`](RESULTADO_BLOQUE_N2N3N4_PEKING_20260812.md).
- **Bloque de reconciliación y QA (2026-08-12):** matriz autoritativa final confirmada en 20 Flows exactos (sin doble conteo). Se confirmó que la rama Taller de `Opp_Flow_V5` no escribía `Empresa_Operadora__c`. Ningún componente LWC/Aura previamente bloqueado (C01-C25) cruzó el umbral de desbloqueo. Solo quedan 2 preguntas reales pendientes para Luis/Diego (política de garantía N3, catálogo/diseño de sucursales N4). Ver [`RESULTADO_RECONCILIACION_QA_20260812.md`](RESULTADO_RECONCILIACION_QA_20260812.md).
- **Remediación técnica `Opp_Flow_V5` (2026-08-12):** la ruta Taller quedó corregida mediante selección estructural de Empresa, resolución efectiva de Cuenta y navegación estándar al Quote. `Opp_Flow_V5` v33 está activa en Partial. El QA funcional final con PEKING confirmó la creación persistida de Opportunity y Quote, `Empresa_Operadora__c`, Cuenta, moneda CRC, Pricebook `PEKING Local` y apertura correcta del Quote desde `Ir a presupuesto`. Estado: **QA FUNCIONAL OK — CREACIÓN + NAVEGACIÓN**. Ver [`RESULTADO_REMEDIACION_OPP_FLOW_V5_TALLER_20260812.md`](RESULTADO_REMEDIACION_OPP_FLOW_V5_TALLER_20260812.md).
- **QA P0 — Flows de Opportunity y mano de obra (2026-08-13):** `Opp_flow_V3`, `Opp_Flow_v6` y `Opportunity_Flow_V2` conservan **QA de creación OK** y navegación remediada. `CreateWoliFromExpense` v16 quedó limitado a seleccionar el único producto `SUB` activo de tipo `Subcontrato`; el único redisparo de `EXP-1458` creó exactamente un WOLI correcto. `AgregarManoObra` v4 eliminó el límite SOQL de la carga de 610 productos y su QA funcional PEKING creó exactamente un WOLI `BSI / SAD001` y un Subtipo correctos, sin duplicado, fault ni rollback. El checkbox no marcado tomó el default de `CrearNuevaManoObra`; el aparente regreso al listado fue una entrevista nueva posterior a `FlowFinish`, no un loop interno. Estado de ambos Flows de mano de obra: **QA FUNCIONAL OK — PEKING**. El permiso mínimo `WorkOrder_Empresa_Factura_QA` continúa marcado **QA TEMPORAL — NO PROMOVER A PRODUCCIÓN**. Ver [`RESULTADO_QA_REMEDIACION_OPP_FLOW_V3_20260812.md`](RESULTADO_QA_REMEDIACION_OPP_FLOW_V3_20260812.md), [`RESULTADO_REMEDIACION_OPP_FLOW_V6_20260812.md`](RESULTADO_REMEDIACION_OPP_FLOW_V6_20260812.md), [`RESULTADO_QA_REMEDIACION_OPPORTUNITY_FLOW_V2_20260812.md`](RESULTADO_QA_REMEDIACION_OPPORTUNITY_FLOW_V2_20260812.md) y [`RESULTADO_PREPARACION_QA_P0_20260812.md`](RESULTADO_PREPARACION_QA_P0_20260812.md).
- **Cierre técnico conciliado de Sprint 2 (2026-08-13):** los 20 Flows autoritativos quedaron reconciliados sin duplicados: 3 con QA funcional completo, 3 con creación funcional aprobada y QA de navegación diferido, 6 revisados sin cambio técnico, 6 bloqueados por decisiones de negocio y 2 no aplicables. No queda trabajo técnico obligatorio desbloqueado. Sprint 2 es **CERRABLE AHORA CON PENDIENTES DE NEGOCIO DOCUMENTADOS**; el cierre no convierte N2/N3/N4 ni F07 en resueltos. Ver [`CIERRE_TECNICO_SPRINT2_20260813.md`](CIERRE_TECNICO_SPRINT2_20260813.md).
- **Remediación técnica `Opp_Flow_v6` (2026-08-12):** el QA v81 confirmó la creación persistida de Opportunity y Quote con PEKING, campos legacy vacíos, CRC, Pricebook `PEKING Local`, Cuenta, Contacto, Asset y territorio correctos. La creación queda en **QA OK**. El componente legacy de navegación final coincidía con los defectos ya conocidos y fue sustituido exclusivamente por el enlace estándar al Quote; v82 está activa. Estado: **QA CREACIÓN OK — NAVEGACIÓN REMEDIADA — QA MANUAL DEL ENLACE PENDIENTE**. Ver [`RESULTADO_REMEDIACION_OPP_FLOW_V6_20260812.md`](RESULTADO_REMEDIACION_OPP_FLOW_V6_20260812.md).
- **Alcance de Sprint 2 al día de hoy:** usar `MATRIZ_CIERRE_SPRINT2.csv` y `CIERRE_TECNICO_SPRINT2_20260813.md` para el estado operativo final de los 20 Flows. `REGLAS_ALCANCE_AUTORIZADO.md` conserva la trazabilidad histórica y la puerta obligatoria para cualquier reanudación; una implementación previa no autoriza cambios nuevos fuera de las respuestas F07/N2/N3/N4.
- **Sprint 3 (agregado 2026-08-05):** autorizado por Luis para **continuar** con el alcance del documento original de PortalNet. Ver sección "Contexto activo de Sprint 3 y TD-RQ308" arriba y `auditoria/INDICE_MAESTRO_AUDITORIA.md`.
- **Cierre técnico de Sprint 3 (2026-08-13):** B7, B9 y B11, por 23 horas explícitas, quedan **TÉCNICAMENTE CERRABLES CON DATOS/CONFIGURACIONES FINALES DIFERIDOS Y PENDIENTES EXTERNOS DOCUMENTADOS**. No queda trabajo técnico nuevo autorizado y desbloqueado ni preguntas inevitables actuales de Sprint 3. N3 Garantías y N4 Service Territories permanecen congelados como pendientes de Sprint 2. Ver [`CIERRE_TECNICO_SPRINT3_20260813.md`](CIERRE_TECNICO_SPRINT3_20260813.md) y [`MATRIZ_CIERRE_SPRINT3.csv`](MATRIZ_CIERRE_SPRINT3.csv).
- **QA en Producción — 2026-08-30:** CU-07, CU-08 y CU-09 quedaron validados en Producción (con una nota de cobertura parcial en CU-07 frente al requisito oficial completo de dos monedas). CU-10 quedó **EN REMEDIACIÓN, NO CERRADO** — falta la solución definitiva de resolución de bodega VN por `RM_Config` según decisión explícita de Luis, y repetir la evidencia de repuestos. Luis autorizó excepcionalmente resolver CU-10 directo en Producción (no es regla general). QA Producción **no** está 100% cerrado. Detalle completo, fuentes oficiales citadas (XLSM/DOCX), decisiones textuales y pendientes en [`CONTINUIDAD_QA_PRODUCCION_20260830.md`](CONTINUIDAD_QA_PRODUCCION_20260830.md).

## Documentos de control (no forman parte del contexto activo de lectura por defecto)

- `ESTADO_GIT_INICIO_SPRINT2.md` — estado de ramas y worktrees.
- `PROPUESTA_LIMPIEZA_DOCUMENTAL.md` — propuesta de limpieza de Sprint 1, no ejecutada.
- `INDICE_DOCUMENTOS_HISTORICOS.md` — índice y advertencias de uso de todo lo histórico de Sprint 1.

## Reglas generales del repositorio

Ver `CLAUDE.md` (raíz del repositorio) para el flujo de trabajo Git/rama/entorno, y `AGENTS.md` (raíz del repositorio) para el resumen de la regla de alcance obligatoria y la regla de carga de contexto orientadas a agentes de IA.
