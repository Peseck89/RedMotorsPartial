# Lotes propuestos de remediación — Sprint 2

Los lotes son pequeños, ordenados y aún no autorizados para ejecución. Apex, campos y Permission Sets se tratan como dependencias; no cuentan dentro de los 25 bundles.

## Lote 0 — reconciliación segura Git–Partial

**Elementos:** los 11 bundles con contenido distinto; `kpiSucursales`; `cT_Estadisticas_Inventario_lwc`; referencia productiva de `Opp_Flow_V5` v29 y `Opp_Flow_v6` v79. `Carga_MO_26_Lavado_a_Caso` queda excluido: no tiene definición activa en Producción.

**Cambios propuestos:** ninguno funcional. Comparar recurso por recurso, identificar propietario/cambio vigente, documentar decisión autoritativa y preparar una base reconciliada. Incorporar bundles faltantes solo si Luis lo confirma.

**Dependencias:** inventario de invocadores y dependencias. La vigencia productiva y las bases v29/v79 ya están confirmadas; los Draft v30/v80 se ignoran.

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

## Lote 2 — Flows activos, dividido por bloqueo real

La depuración del Lote 2.1 confirmó la vigencia de los doce Flows y eliminó las preguntas obsoletas de vigencia. La ejecución se divide así:

### Sublote 2A — Pricebook/PBE con guardas seguras

**Elementos:** `PlanDeMantenimientoV2`, `CreateWoliFromExpense`, `AgregarManoObra`.

**Estado:** `EJECUTABLE_TÉCNICAMENTE` con aprobación específica. Puede retirar IDs/nombres fijos, adoptar `EmpresaPricebookResolver` y detener estados no exitosos sin inventar datos. N1 solo bloquea QA positivo PEKING y cierre funcional.

### Sublote 2B — Quote→Work Order

**Elementos:** `Work_Order_from_Quote`, `Work_Order_from_Quote_Selective`.

**Estado:** `REQUIERE_NEGOCIO` (N2: bodega, territorio, reserva/despacho/taller).

### Sublote 2C — segregación y garantía

**Elemento:** `SegregateWOLIs`.

**Estado:** la sustitución del Id fijo por DeveloperName es `EJECUTABLE_TÉCNICAMENTE`. El comportamiento de garantía/segregación para PEKING permanece `REQUIERE_NEGOCIO` (N3).

### Sublote 2D1 — Opportunity sin divergencia de versión

**Elementos:** `Opp_flow_V3`, `Opportunity_Flow_V2`.

**Estado:** `EJECUTABLE_TÉCNICAMENTE`. Ambos deben presentar selección explícita de Empresa. En `Opportunity_Flow_V2`, la selección explícita prevalece sobre `$User.Empresa__c`.

### Sublote 2D2 — Opportunity con active/latest distintos

**Elementos:** `Opp_Flow_V5`, `Opp_Flow_v6`.

**Estado:** `EJECUTABLE_TÉCNICAMENTE`. `Opp_Flow_V5` parte exclusivamente de v29 activa e ignora v30 Draft; `Opp_Flow_v6` parte exclusivamente de v79 activa e ignora v80 Draft. Ambos deben presentar selección explícita de Empresa.

### Sublote 2E — Caso, Work Order y evento

**Elementos:** `aperturaCaseWorOrderEvent`, `ct_newCaseWorkOrderEvent`.

**Estado:** la UX de `aperturaCaseWorOrderEvent` está resuelta mediante selección explícita de Empresa. Ambos Flows permanecen `REQUIERE_NEGOCIO` (N4: servicios, agenda, sucursales y territorios).

**Riesgo general:** alto; afecta Opportunity, Quote, Work Order, WOLI, Event y PricebookEntry.

**Tests comunes:** Bavarian/Otobai; PEKING explícito; empresa desconocida/ausente; Pricebook incompatible o ambiguo; estado no exitoso sin escritura; regresión de rutas no empresariales.

**Videos:** por sublote y solo cuando existan datos funcionales confirmados.

**Terminado:** ninguna ruta residual selecciona otra Empresa; pruebas negativas completas y positivas con datos confirmados.

**Orden actualizado:** 2A completado → 2D1/2D2 → corrección técnica de Record Type en 2C → 2B/2C funcional/2E después de respuestas de negocio.

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

**Sublote 2D**, dividido en dos despliegues pequeños y sujeto a autorización específica:

1. **2D1:** `Opp_flow_V3` v28 y `Opportunity_Flow_V2` v6.
2. **2D2:** `Opp_Flow_V5` desde v29 activa y `Opp_Flow_v6` desde v79 activa; v30/v80 Draft se ignoran.

Es el siguiente lote totalmente ejecutable porque ya están confirmadas la selección explícita de Empresa, la precedencia frente a `$User.Empresa__c` y las versiones base. Debe conservar las rutas vigentes, resolver Pricebook mediante Empresa y detener estados no configurados sin inventar datos.

Como tarea independiente posterior puede ejecutarse la sustitución del Record Type Id de `SegregateWOLIs` por DeveloperName. La lógica funcional de garantía/segregación permanece bloqueada por N3.
