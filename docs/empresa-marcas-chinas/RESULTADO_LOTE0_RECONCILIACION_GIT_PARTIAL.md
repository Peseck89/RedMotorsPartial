# Resultado Lote 0 — Reconciliación Git–Partial

## Dictamen

El Lote 0 se ejecutó como análisis de solo lectura. Se compararon exactamente 20 Flows y 25 bundles auditados contra `RedMotorsSandbox`.

- Los **20 Flows son semánticamente equivalentes** entre Git y Partial. Nueve coinciden directamente y once presentan únicamente reordenamiento/serialización XML sin diferencia en el conjunto de valores funcionales.
- Doce bundles coinciden por recurso.
- Once bundles existen en ambos lados y tienen diferencias funcionales reales.
- Dos bundles existen únicamente en Partial y deben incorporarse posteriormente al repositorio para recuperar trazabilidad, sin modificación funcional.
- No se sobrescribió ningún archivo de metadata en la rama, no se modificaron datos y no se hizo deploy.

## Método

1. Se creó y publicó el checkpoint documental autorizado antes de iniciar la reconciliación.
2. La metadata de Partial se recuperó en formato Metadata API a una ubicación temporal externa al proyecto.
3. Se compararon archivos ignorando diferencias de fin de línea y, adicionalmente, espacios para separar formato de cambios funcionales.
4. Para Flows se compararon también las hojas XML por contexto/nombre/valor, ignorando el orden de serialización de nodos.
5. Para bundles se revisaron imports Apex/schema, componentes hijos, métodos, contratos, hardcodes y fecha de última modificación disponible en Partial.
6. No se consultó Producción durante este lote.

## Resultado de los 20 Flows

| Resultado | Flows | Decisión |
|---|---|---|
| Idénticos directamente | `Work_Order_from_Quote`, `ReciboUsadosFlow`, `Opp_Flow_V5`, `Opp_flow_V3`, `Opportunity_Flow_V2`, `CreateWoliFromExpense`, `ct_newCaseWorkOrderEvent`, `AgregarManoObra`, `Carga_MO_26_Lavado_a_Caso` | Conservar Git |
| Mismos valores funcionales; distinto orden/serialización XML | `Opportunity_Flow`, `Opp_flow_v4`, `BMW_ImportarPlantilla`, `BMW_Gestiona_Listas_de_Precios`, `Obtener_PricebookEntry_en_Linea_de_Plantilla_de_Presupuesto`, `Opportunity_Flow_From_Work_Order`, `PlanDeMantenimientoV2`, `Work_Order_from_Quote_Selective`, `SegregateWOLIs`, `Opp_Flow_v6`, `aperturaCaseWorOrderEvent` | Conservar Git; no generar ruido sustituyendo por el XML serializado de Partial |

La conciliación no cambia la clasificación funcional de la auditoría: los Flows activos con lógica binaria o Pricebook no empresarial siguen requiriendo remediación en el lote correspondiente. “Semánticamente equivalente Git–Partial” solo confirma que no existe deriva entre ambos ambientes para la versión recuperada.

## Bundles sin conflicto

Los siguientes doce bundles coinciden por recurso y deben conservar su versión Git como base: `rm_vu_inventario`, `rm_vn_crear_opp_inventario`, `rm_vn_inventario`, `rm_vn_inventario_movil`, `assetGarantiaLookupLwc`, `rm_vu_crear_opp`, `rm_vn_get_record_opp_record_types`, `rm_vn_crear_opp_home`, `rm_vn_crear_opp_home_movil`, `rm_vn_crear_opp_general`, `localizacionDetails` y `CommunityCalendar`.

## Decisión recurso por recurso para los 11 conflictos

En los once casos, el historial disponible de Git para el bundle corresponde a la línea base inicial del repositorio, mientras Partial registra modificaciones posteriores. Por eso Partial es la base recomendada, pero **no debe copiarse automáticamente**: cada fila requiere conciliación manual y pruebas de su dependencia.

| Recurso exacto | Diferencia | Git | Partial | Tipo | Base recomendada | Riesgo de conservar Git | Riesgo de conservar Partial | Acción siguiente |
|---|---|---|---|---|---|---|---|---|
| `productSearcher/productSearcher.html` y `.js` | Cambia lookup libre de bodega por combobox/códigos; reorganiza filtros y lógica de resultados | Línea base inicial; contrato `preciosBavarian` y lookup `Bodega__c` | Modificado 2026-06-17; agrega filtro de bodega controlado y constantes como `BR01` | Funcional | Partial, con conciliación manual | Perder correcciones activas de filtros/bodega | Conservar códigos de bodega no confirmados y comportamiento aún acoplado a Bavarian | Partir de Partial; revisar con `ProductSearcherController` y reemplazar hardcodes solo en lote funcional autorizado |
| `quoliGridDespacho/quoliGridDespacho.html` y `.js` | Datatable especializado, territorio de servicio, visibilidad de selección de inventario y manejo de estado | Línea base inicial | Modificado 2026-05-30; usa componente datatable hijo, `Quote.Opportunity.BMW_TallerDeServicio__r.Name` y reglas por territorio | Funcional/dependencias | Partial, conciliación manual | Romper despacho actual y perder selector por ubicación | Preservar listas fijas de territorios Otobai/Bavarian y dependencia no versionada en este lote | Reconciliar junto con datatable hijo, Apex y reglas de taller en Lote 4 |
| `woliGridDespacho/woliGridDespacho.html` y `.js` | Cambia controlador de guardado; agrega persistencia de selecciones, territorio y validaciones async | Línea base inicial | Modificado 2026-05-30; depende de `WoliGridDespachoSelectionController`, ServiceTerritory y datatable hijo | Funcional/dependencias | Partial, conciliación manual | Perder la lógica activa de selección/despacho | Incorporar contrato Apex sin revisar o mantener territorios fijos | Reconciliar en Lote 4 con sus dependencias y pruebas de reserva/despacho |
| `busquedaDetallada/busquedaDetallada.html` y `.js` | Agrega actualización de precios Softland, selección de PBE y control por perfil | Línea base inicial | Modificado 2026-04-24; añade `updateFreshPriceFromSoftland`, perfil y UI de actualización | Funcional/dependencias | Partial, conciliación manual | Perder actualización activa y control de selección | Preservar filtro por perfil y Pricebooks sin aislamiento empresarial suficiente | Usar Partial como base; en lote funcional agregar validación Empresa/Pricebook del lado servidor |
| `qoSearchDetailProduct/qoSearchDetailProduct.html` y `.js` | Reestructura modal y detalle; agrega actualización de precio, perfil y operación de MO | Línea base inicial | Modificado 2026-07-01; añade `updateFreshPriceFromSoftland` y controles asociados | Funcional/dependencias | Partial, conciliación manual | Perder funcionalidad activa reciente | Mantener contrato ambiguo `empresaFactura` y dependencias no reconciliadas | Conciliar con `WoliGridController2`, `pricebookReferenceDetails` y `localizacionDetails` en Lote 4 |
| `woSearchDetailProduct/woSearchDetailProduct.html` y `.js` | Reestructura modal/tabla y agrega actualización Softland/control de perfil | Línea base inicial | Modificado 2026-04-24; añade actualización de precio y refresco de tabla | Funcional/dependencias | Partial, conciliación manual | Perder comportamiento activo de taller/actualización | Mantener `empresaFactura` y lógica de bodega por nombre | Conciliar con `WoliGridController` y dependencias en Lote 4 |
| `pricebookReferenceDetails/pricebookReferenceDetails.js` | Pasa de carga imperativa simple a wire de perfil, columnas dinámicas y manejo de respuesta/error Softland | Línea base inicial | Modificado 2026-03-11; normaliza resultados y maneja errores | Funcional/dependencias | Partial, conciliación manual | Perder manejo de errores y normalización activos | Conservar control por perfil y contrato `empresaFactura` sin definición empresarial estable | Partir de Partial y reemplazar el contrato en Lote 1/4 |
| `CommunityMenu` (`.cmp`, controller, helper, CSS) | Diff amplio de estructura, navegación, UI y lógica; no es solo reindentado | Línea base inicial | Modificado 2026-07-05; cientos de cambios funcionales además de formato | Funcional crítico | Partial, conciliación manual estricta | Sobrescribir la experiencia actualmente desplegada | Incorporar hardcodes de sucursales/usuarios/texto legal sin validación o perder comportamiento accidentalmente | No sustituir el bundle completo; revisar cada recurso y probar Community en Lote 5 |
| `CommunityControl` (`.cmp`, controller, helper) | Modal con scroll/controles, spinner y cambios de cálculo/navegación de fechas | Línea base inicial | Modificado 2026-07-07; corrige interacción/calendario | Funcional | Partial, conciliación manual | Reintroducir problemas de modal/calendario | Adoptar lógica activa sin regresión de fechas/citas | Partir de Partial y probar calendario/citas en Lote 5 |
| `customerCommunity_lwc/customerCommunity_lwc.cmp` | Mueve el contador respecto de los controles de confirmación | Línea base inicial | Modificado 2025-10-28; cambio pequeño de orden UI | Funcional de presentación | Partial | Revertir el orden desplegado del contador | Bajo; posible dependencia CSS/JS del orden DOM | Incorporar el CMP de Partial en conciliación manual y ejecutar smoke test de cita |
| `callcenterCommunity_lwc/callcenterCommunity_lwc.cmp` | Agrega scroll al modal y reubica contador/controles | Línea base inicial | Modificado 2025-10-28; ajustes de usabilidad | Funcional de presentación | Partial | Reintroducir desbordamiento de modal | Bajo/medio; cambio del DOM puede afectar selectores | Incorporar el CMP de Partial en conciliación manual y probar confirmación de cita |

## `kpiSucursales`

### Metadata recuperada

- `kpiSucursales.js`
- `kpiSucursales.html`
- `kpiSucursales.css`
- `kpiSucursales.js-meta.xml`
- API 65.0; expuesto para Home, App y Record Page.
- Última modificación disponible en Partial: 2026-03-05.

### Dependencias y referencias

- Apex: `KPIEstadoTallerController.getKPIs`.
- Referencia entrante detectada: bundle `kpiEstadoTaller`.
- No se detectó referencia directa desde FlexiPage en la evidencia de dependencia consultada.
- No usa `Empresa__c` ni `Empresa_Operadora__c`.
- Tiene lista fija de sucursales: Uruca, Pinares, Escazú, Motorrad y Otobai.

### Decisión

Debe incorporarse posteriormente al repositorio **sin cambio funcional** para mantener versionamiento interno y poder auditar su relación con `kpiEstadoTaller`. Su incorporación no lo autoriza para PEKING. Antes de una modificación funcional se requiere definir sucursales y reglas de KPI por Empresa; no debe agregarse PEKING ni una sucursal por inferencia.

Riesgo de no incorporarlo: continuar con un componente desplegado sin trazabilidad interna. Riesgo de incorporarlo sin control: normalizar como oficial una lista fija de sucursales que todavía no está validada para la arquitectura multiempresa.

## `cT_Estadisticas_Inventario_lwc`

### Metadata recuperada

- `cT_Estadisticas_Inventario_lwc.js`
- `cT_Estadisticas_Inventario_lwc.html`
- `cT_Estadisticas_Inventario_lwc.js-meta.xml`
- API 65.0; expuesto para App, Record, Home y Community Page.
- Última modificación disponible en Partial: 2026-01-26.

### Dependencias y referencias

- Apex: `cT_Registro_Avaluos_ctrl.obtenerEstadisticasTodosModelos`.
- Referencia directa desde FlexiPage: `Estadisticas_Inventario_Usados`.
- No se detectaron referencias directas a Empresa, Pricebook, bodega, sucursal, territorio o Softland en el bundle.
- Su FlexiPage confirma que pertenece al dominio de inventario de usados.

### Decisión

Debe incorporarse posteriormente al repositorio, sin cambio funcional, para recuperar trazabilidad. Permanece `NO APLICA` para PEKING porque Luis confirmó que los componentes exclusivos de usados no deben soportarlo. No debe mezclarse con los cambios funcionales VN/PEKING.

Riesgo de no incorporarlo: no poder versionar ni revisar un componente usado por una FlexiPage activa. Riesgo de incorporarlo como parte funcional PEKING: contradecir la decisión de alcance de usados.

## Clasificación final de decisiones

### Recuperar desde Partial en una acción posterior aprobada

- `kpiSucursales` completo.
- `cT_Estadisticas_Inventario_lwc` completo.

La recuperación posterior debe ser un commit de trazabilidad sin cambios funcionales y con sus dependencias documentadas.

### Conservar Git

- Los 20 Flows, porque son semánticamente equivalentes y reemplazarlos solo introduciría ruido de serialización.
- Los doce bundles sin conflicto listados arriba.
- Ninguno de los once bundles en conflicto debe conservarse como base exclusiva de Git, porque Partial contiene cambios posteriores.

### Conciliación manual obligatoria

Los once bundles conflictivos: `productSearcher`, `quoliGridDespacho`, `woliGridDespacho`, `busquedaDetallada`, `qoSearchDetailProduct`, `woSearchDetailProduct`, `pricebookReferenceDetails`, `CommunityMenu`, `CommunityControl`, `customerCommunity_lwc` y `callcenterCommunity_lwc`.

En todos se recomienda Partial como punto de partida técnico, pero el resultado debe construirse y probarse por recurso; no copiar el bundle completo sin revisar dependencias.

## Riesgos antes de cambios funcionales

1. Los bundles de despacho dependen de controladores/componentes adicionales que no formaban parte de los 25 bundles y deben conciliarse como dependencias, no contarse como alcance nuevo.
2. Los componentes de búsqueda y referencias preservan contratos ambiguos (`empresaFactura`) y controles por perfil.
3. `productSearcher` agrega códigos de bodega fijos que no deben considerarse configuración oficial.
4. Community contiene el diff de mayor tamaño, hardcodes operativos y texto legal; un reemplazo completo tiene riesgo crítico.
5. La equivalencia de Flows con Partial no valida su lógica PEKING; únicamente descarta deriva de fuente.
6. Los dos bundles recuperables aún no están en Git y no deben desplegarse: ya existen en Partial; la acción futura es solo versionarlos.

## Lote recomendado después del Lote 0

Se recomienda un **Lote 0.1 de incorporación y conciliación técnica**, todavía sin lógica PEKING:

1. Incorporar los dos bundles faltantes exactamente como están en Partial.
2. Conciliar primero los cambios pequeños: `customerCommunity_lwc`, `callcenterCommunity_lwc` y `pricebookReferenceDetails`.
3. Conciliar por dominio los bundles de búsqueda y despacho junto con sus dependencias.
4. Dejar `CommunityMenu` y `CommunityControl` para una revisión separada de alto riesgo.

Después de esa base versionada y probada, continuar con el Lote 1 de resolución dinámica de Empresa. Ninguna de estas recomendaciones autoriza aún la modificación de metadata.

## Confirmaciones de seguridad

- Producción no fue consultada ni tocada durante el Lote 0.
- Partial se utilizó únicamente para retrieve y consultas de metadata de solo lectura.
- No se modificaron datos.
- No se hizo deploy, activación, desactivación ni implementación PEKING.
- La metadata temporal no se copió al árbol de fuente.

