# Lotes propuestos de remediación — Sprint 2

Los lotes son pequeños, ordenados y aún no autorizados para ejecución. Apex, campos y Permission Sets se tratan como dependencias; no cuentan dentro de los 25 bundles.

## Lote 0 — reconciliación segura Git–Partial

**Elementos:** los 11 bundles con contenido distinto; `kpiSucursales`; `cT_Estadisticas_Inventario_lwc`; referencia productiva de `Opp_Flow_V5` v29 y `Opp_Flow_v6` v79. `Carga_MO_26_Lavado_a_Caso` queda excluido: no tiene definición activa en Producción.

**Cambios propuestos:** ninguno funcional. Comparar recurso por recurso, identificar propietario/cambio vigente, documentar decisión autoritativa y preparar una base reconciliada. Incorporar bundles faltantes solo si Luis lo confirma.

**Dependencias:** L1 y D1; inventario de invocadores y dependencias. La vigencia productiva de los Flows ya está confirmada.

**Riesgo:** crítico si se sobrescribe Partial; bajo si el lote permanece documental y de solo lectura.

**Tests:** comparación reproducible de recursos; validación de conteos y versiones; smoke test solo después de una futura sincronización aprobada.

**Videos:** no se requiere video funcional para la fase documental; sí capturas de versiones/diffs y, después, smoke test de cada área afectada.

**Terminado:** los 13 bundles involucrados y 3 Flows con estado de versión tienen fuente/versión autoritativa documentada, sin pérdida de contenido.

**Orden:** primero D1; luego L1; después alinear el análisis con las versiones activas de Producción; por último base reconciliada.

**¿Antes de respuestas funcionales?** Sí, como análisis/reconciliación de solo lectura. Cualquier escritura requiere aprobación específica.

## Lote 1 — dependencias compartidas y resolución dinámica de Empresa

**Elementos:** dependencias de `productSearcher`, `rm_vn_crear_opp_inventario`, `rm_vn_inventario(_movil)`, `busquedaDetallada`, `qoSearchDetailProduct`, `woSearchDetailProduct`, `localizacionDetails`, `pricebookReferenceDetails`, despacho, garantía y Community; Flows que usarán resolución común.

**Cambios propuestos:** contrato neutral basado en `Empresa__c`/`Empresa_Operadora__c`; resolver ERP solo en integración; validación servidor de Pricebook/PricebookEntry; estado “no configurado”; DeveloperName/configuración en vez de Record Type Id.

**Dependencias:** D2/D3, diseño aprobado; inventario de Apex/campos/Permission Sets sin contarlos como bundles.

**Riesgo:** alto por amplitud del contrato compartido.

**Tests:** unitarios Apex por Empresa, nulo, configuración ausente, cruce de Pricebook y regresión Bavarian/Otobai.

**Videos:** no para utilidades internas; su comportamiento se evidencia en lotes 2–6.

**Terminado:** API estable, sin nombres/Ids empresariales fijos y con manejo explícito de desconocidos.

**Orden:** Empresa → Pricebook → ERP/Softland → Record Type → permisos.

**¿Antes de respuestas funcionales?** Parcialmente: diseño y pruebas negativas sí; asociaciones reales no.

## Lote 2 — Flows críticos no bloqueados

**Elementos:** los 12 Flows activos con impacto PEKING: `PlanDeMantenimientoV2`, `Work_Order_from_Quote`, `Work_Order_from_Quote_Selective`, `SegregateWOLIs`, `CreateWoliFromExpense`, `aperturaCaseWorOrderEvent`, `ct_newCaseWorkOrderEvent`, `AgregarManoObra`, `Opp_Flow_V5` v29, `Opp_flow_V3` v28, `Opp_Flow_v6` v79 y `Opportunity_Flow_V2` v6.

**Cambios propuestos:** sustituir decisiones Bavarian/Otobai y Pricebooks nominales por Empresa/configuración; detener rutas no configuradas; conservar fallback legacy únicamente donde esté documentado.

**Dependencias:** Lote 1; N1/N2 para pruebas positivas PEKING. No se requiere otra decisión de vigencia de Luis.

**Riesgo:** alto; afecta Opportunity, Quote, Work Order, WOLI, Event y PricebookEntry.

**Tests:** cada Flow con Bavarian/Otobai; empresa desconocida; Empresa ausente; Pricebook incompatible; rollback de error.

**Videos:** Quote→WO normal/selectivo; gasto→WOLI; caso→WO/Event; mano de obra; mantenimiento.

**Terminado:** ninguna ruta residual selecciona otra empresa; pruebas negativas completas y positivas con datos confirmados.

**Orden:** mantenimiento → Quote/WO/segregación → gasto/MO → caso/evento → Flows legacy activos.

**¿Antes de respuestas funcionales?** Solo refactor seguro y pruebas negativas tras aprobación; cierre funcional no.

## Lote 3 — componentes de inventario VN/VU

**Elementos:** `productSearcher`, `rm_vn_crear_opp_inventario`, `rm_vn_inventario`, `rm_vn_inventario_movil`, `rm_vn_get_record_opp_record_types`, `rm_vn_crear_opp_home`, `rm_vn_crear_opp_home_movil`, `rm_vn_crear_opp_general`, `kpiSucursales`, `cT_Estadisticas_Inventario_lwc`. `rm_vu_inventario` y `rm_vu_crear_opp` quedan fuera por ser usados (`NO APLICA`).

**Cambios propuestos:** reconciliar fuentes; eliminar contrato Bavarian en componentes VN aplicables; mantener contenedores sin lógica duplicada; incorporar los dos bundles faltantes solo si se autorizan. No extender VU para PEKING.

**Dependencias:** Lotes 0–1; L1; N1/N2/N4/N6.

**Riesgo:** alto por inventario, precios, bodega y creación de Opportunity.

**Tests:** desktop/móvil, filtros, permiso de bodega, Pricebook correcto, ausencia de Empresa, mismo producto en varias empresas.

**Videos:** entrada real **Ver inventario**, VIN/datos completos; creación de Opportunity sin Apex/CLI; perfiles QA.

**Terminado:** paridad VN/VU, aislamiento empresarial, bundle/versiones trazables y videos reales.

**Orden:** contratos de búsqueda/creación VN → VN desktop/móvil → Record Types → KPI/estadísticas.

**¿Antes de respuestas funcionales?** Reconciliación y estructura sí; pruebas positivas y permisos no.

## Lote 4 — despacho, Work Order y taller

**Elementos:** `quoliGridDespacho`, `woliGridDespacho`, `qoSearchDetailProduct`, `woSearchDetailProduct`, `localizacionDetails`, `pricebookReferenceDetails`, `SegregateWOLIs`, `assetGarantiaLookupLwc`; integración con Flows del lote 2.

**Cambios propuestos:** reconciliar fuente; contrato Empresa/ERP; eliminar bodega por nombre e Id de Record Type; configurar reglas de despacho/garantía/taller.

**Dependencias:** Lotes 0–2; D2/D3; N2/N3/N4/N6.

**Riesgo:** crítico por reserva, despacho, devolución, cargos, garantía y Softland.

**Tests:** transiciones completas, errores Softland, bodega insuficiente, empresa cruzada, garantía válida/no válida, segregación.

**Videos:** reserva, apartado, despacho, devolución, WOLI/cargos, búsqueda de taller y garantía.

**Terminado:** reglas confirmadas, sin identificadores fijos, trazabilidad Softland y regresión completa.

**Orden:** contrato Softland → búsquedas → despacho → segregación → garantía.

**¿Antes de respuestas funcionales?** No para cambios funcionales; solo reconciliación.

## Lote 5 — Community, calendarios y citas

**Elementos:** `CommunityMenu`, `CommunityControl`, `customerCommunity_lwc`, `callcenterCommunity_lwc`, `CommunityCalendar`.

**Cambios propuestos:** reconciliar recursos; externalizar sucursales, servicios, usuarios y capacidades; conservar `CommunityCalendar` genérico; incorporar textos legales solo aprobados.

**Dependencias:** Lote 0; N5/N6; revisión legal.

**Riesgo:** crítico por experiencia pública, citas, PII y texto legal.

**Tests:** navegación, visibilidad, capacidad, zona horaria, citas, errores y perfiles QA.

**Videos:** recorrido cliente y call center por Empresa/sucursal; consentimiento legal visible.

**Terminado:** configuración aprobada, sin IDs embebidos, texto legal validado y citas correctas.

**Orden:** reconciliar → configurar servicios → calendario/capacidad → cliente → call center → legal.

**¿Antes de respuestas funcionales?** No, salvo reconciliación documental.

## Lote 6 — elementos desbloqueados después de respuestas funcionales

**Elementos:** `kpiSucursales`, `cT_Estadisticas_Inventario_lwc` y cualquier elemento de lotes 2–5 pendiente de datos. Se excluyen `ReciboUsadosFlow`, `rm_vu_inventario`, `rm_vu_crear_opp` y `Carga_MO_26_Lavado_a_Caso` por `NO APLICA`.

**Cambios propuestos:** aplicar únicamente decisiones escritas; configurar asociaciones reales; retirar elementos descartados mediante proceso separado y aprobado.

**Dependencias:** respuestas L1, D1–D3 y N1–N6 relevantes.

**Riesgo:** variable; alto si se reactiva un Flow o se incorporan datos empresariales.

**Tests:** matriz de aceptación específica por decisión; regresión de invocadores.

**Videos:** usados; Flow conservado; KPI/estadísticas; cualquier escenario nuevo habilitado.

**Terminado:** cero bloqueos funcionales abiertos o cada exclusión formalmente aceptada.

**Orden:** alcance → configuración → implementación → QA.

**¿Antes de respuestas funcionales?** No.

## Lote 7 — regresión, videos y cierre documental

**Elementos:** los 45 elementos auditados y todas sus dependencias afectadas.

**Cambios propuestos:** ninguno funcional nuevo; ejecutar regresión, recopilar evidencia y actualizar matriz/cierre.

**Dependencias:** lotes autorizados terminados; perfiles y datos QA confirmados.

**Riesgo:** alto si se omite una entrada real o una versión inactiva invocada.

**Tests:** unitarios, integración, E2E, negativos, permisos, Softland y regresión Bavarian/Otobai.

**Videos:** todos los definidos en la auditoría, con fecha, Partial, perfil QA, entrada real, resultado y campos clave.

**Terminado:** 45 filas con evidencia, bloqueos resueltos/aceptados, Git–Partial reconciliado y aprobación funcional. Un deploy exitoso no basta.

**Orden:** pruebas automáticas → E2E → permisos → videos → cierre documental.

**¿Antes de respuestas funcionales?** No para cierre; el guion de pruebas sí puede prepararse.

## Lote recomendado para iniciar

**Lote 0**, limitado inicialmente a reconciliación de solo lectura y decisiones de fuente. Es el único lote que reduce riesgo sin requerir inventar datos funcionales. No debe sincronizar ni sobrescribir archivos hasta recibir aprobación específica posterior.
