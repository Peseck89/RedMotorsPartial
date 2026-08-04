# Preguntas consolidadas para desbloquear Sprint 2

Las 16 filas todavía bloqueadas se agrupan por decisión compartida. No se repiten preguntas ni se reabren las decisiones ya confirmadas sobre Flows activos en Producción y exclusión de usados para PEKING.

## Para Luis

### L1. Bundles solo en Partial

**Pregunta:** ¿`kpiSucursales` y `cT_Estadisticas_Inventario_lwc` forman parte del producto vigente y deben incorporarse al control de versiones para Sprint 2?

**Desbloquea:** `kpiSucursales`, `cT_Estadisticas_Inventario_lwc` y la conciliación exacta de los 25 bundles.

**Alternativa recomendada:** si son vigentes, incorporarlos primero en un lote exclusivo de reconciliación, sin cambios funcionales; si no lo son, documentar exclusión/retiro con evidencia de invocadores.

## Para Diego

### D1. Autoridad de los 11 conflictos de fuente

**Pregunta:** Para cada recurso distinto de `productSearcher`, `quoliGridDespacho`, `woliGridDespacho`, `busquedaDetallada`, `qoSearchDetailProduct`, `woSearchDetailProduct`, `pricebookReferenceDetails`, `CommunityMenu`, `CommunityControl`, `customerCommunity_lwc` y `callcenterCommunity_lwc`, ¿qué lado contiene el comportamiento vigente que debe preservarse?

**Desbloquea:** 11 conflictos y los lotes de inventario, despacho, búsquedas y Community.

**Alternativa recomendada:** decisión por archivo, no por bundle; Partial conserva evidencia de ejecución y Git conserva historial. Construir una versión reconciliada solo después de aprobar el diff.

### D2. Contrato empresarial compartido

**Pregunta:** ¿`empresaFactura` representa un lookup Empresa, un código ERP u otro identificador, y cuál será el contrato estable de reemplazo para `qoSearchDetailProduct`, `woSearchDetailProduct`, `localizacionDetails` y `pricebookReferenceDetails`?

**Desbloquea:** esos cuatro LWC y sus dependencias `WoliGridController`/`WoliGridController2`.

**Alternativa recomendada:** usar Id de `Empresa__c`/`Empresa_Operadora__c` como entrada primaria y resolver `Codigo_ERP__c` únicamente en la capa de integración.

### D3. Record Types sin Id fijo

**Pregunta:** ¿Qué mecanismo aprobado debe reemplazar el Record Type Id fijo de `SegregateWOLIs`, y cómo debe relacionarse Empresa con Record Type en `rm_vn_get_record_opp_record_types` y `ReciboUsadosFlow`?

**Desbloquea:** `SegregateWOLIs` y `rm_vn_get_record_opp_record_types`.

**Alternativa recomendada:** DeveloperName estable más configuración por Empresa/proceso; nunca Id de org ni inferencia por nombre comercial.

## Para negocio

### N1. Configuración comercial mínima

**Pregunta:** ¿Cuáles son las asociaciones oficiales Empresa–moneda–Pricebook–catálogo/producto/precio aplicables a PEKING para mantenimiento, mano de obra, gastos, inventario y plantillas?

**Desbloquea:** `PlanDeMantenimientoV2`, `CreateWoliFromExpense`, `AgregarManoObra`, `rm_vn_crear_opp_inventario`, `productSearcher`, `pricebookReferenceDetails`, los cinco Flows ya técnicamente compatibles y sus pruebas E2E.

**Alternativa recomendada:** registrar asociaciones en configuración gobernada por `Empresa__c`; sin respuesta, devolver “no configurado” y no seleccionar un Pricebook alterno.

### N2. Operación de bodega, despacho y taller

**Pregunta:** ¿Qué bodegas, territorios, reglas de bodega principal/apartados, reserva, despacho, devolución, taller y mano de obra aplican oficialmente a PEKING?

**Desbloquea:** `quoliGridDespacho`, `woliGridDespacho`, `qoSearchDetailProduct`, `woSearchDetailProduct`, `rm_vn_inventario`, `rm_vn_inventario_movil`, `Work_Order_from_Quote`, `Work_Order_from_Quote_Selective`, `aperturaCaseWorOrderEvent`, `ct_newCaseWorkOrderEvent` y `BMW_ImportarPlantilla` para QA completo.

**Alternativa recomendada:** configuración explícita por Empresa; si una función no aplica, bloquearla con mensaje controlado.

### N3. Garantía y segregación

**Pregunta:** ¿Qué reglas funcionales aprobadas aplican a PEKING para garantía y segregación de cargos/WOLI?

**Desbloquea:** `assetGarantiaLookupLwc` y `SegregateWOLIs`.

**Alternativa recomendada:** política por Empresa y proceso; ausencia de configuración equivale a “no disponible”, nunca a heredar Otobai/Bavarian.

### N4. Softland

**Pregunta:** ¿Cuáles son los mapeos ERP y operaciones Softland autorizadas para PEKING en inventario, localizaciones, referencias de precio, despacho y creación de cuentas?

**Desbloquea:** `rm_vn_inventario`, `rm_vn_inventario_movil`, `localizacionDetails`, `pricebookReferenceDetails`, `quoliGridDespacho`, `woliGridDespacho`, `Opp_flow_v4` y componentes de búsqueda.

**Alternativa recomendada:** resolver el código ERP desde Empresa en la capa de integración y manejar falta de configuración como error controlado.

### N5. Community, citas y legal

**Pregunta:** ¿Qué sucursales, servicios, usuarios operativos, capacidades, reglas de citas y textos legales aprobados corresponden a PEKING?

**Desbloquea:** `CommunityMenu`, `CommunityControl`, `customerCommunity_lwc`, `callcenterCommunity_lwc` y la validación integrada de `CommunityCalendar`.

**Alternativa recomendada:** externalizar servicios/capacidades por Empresa; mantener PEKING oculto hasta recibir contenido operativo y legal aprobado.

### N6. Permisos QA y funcionales

**Pregunta:** ¿Qué perfiles QA y permisos funcionales deben usar inventario, cambio de bodega, despacho, garantía, usados y Community para PEKING?

**Desbloquea:** QA de `rm_vn_inventario`, `rm_vn_inventario_movil`, despacho, garantía, usados y Community.

**Alternativa recomendada:** mínimo privilegio por función y evidencia con perfiles QA, sin crear permisos por analogía.

## Cobertura de los 16 bloqueos

Las preguntas anteriores cubren los 16 elementos bloqueados. `ReciboUsadosFlow`, `rm_vu_inventario`, `rm_vu_crear_opp` y `Carga_MO_26_Lavado_a_Caso` no son bloqueos: están clasificados `NO APLICA`. Un mismo elemento bloqueado puede requerir una decisión técnica y otra funcional; por eso los grupos no son mutuamente excluyentes. Ninguna respuesta autoriza implementación.
