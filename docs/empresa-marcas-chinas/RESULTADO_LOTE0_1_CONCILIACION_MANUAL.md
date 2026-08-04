# Resultado Lote 0.1 — conciliación manual Git–Partial

## Alcance y criterio

Se compararon los 13 bundles autorizados contra la extracción de solo lectura de `RedMotorsSandbox` obtenida en el Lote 0. Partial se tomó como base técnica. No se consultó Producción, no se desplegó metadata, no se modificaron datos ni Flows y no se añadió lógica PEKING.

La historia de los once conflictos no mostró cambios posteriores documentados de Sprint 2 que justificaran conservar archivos divergentes de Git. Se conservaron archivos auxiliares y descriptores de Git cuando eran equivalentes a Partial. Dos recursos se detuvieron porque Partial exige dependencias ausentes del repositorio.

## Resultado por bundle

| Bundle | Git original | Partial original | Archivos afectados | Partial conservado | Git conservado | Git descartado y motivo | Dependencias | Riesgo | Resultado final | Validación | Pendiente |
|---|---|---|---|---|---|---|---|---|---|---|---|
| `kpiSucursales` | Ausente | 4 archivos | CSS, HTML, JS, XML | Bundle completo | Ninguno | Ninguno | `KPIEstadoTallerController.getKPIs` | Alto: sucursales literales | Incorporado sin cambio funcional | Estructura, XML, import y contenido | Lote 1/6: Empresa y catálogo oficial |
| `cT_Estadisticas_Inventario_lwc` | Ausente | 3 archivos | HTML, JS, XML | Bundle completo | Ninguno | Ninguno | `cT_Registro_Avaluos_ctrl.obtenerEstadisticasTodosModelos`; FlexiPage `Estadisticas_Inventario_Usados` | Bajo para PEKING: usados | Incorporado sin cambio funcional | Estructura, XML, import y FlexiPage | Revisar clasificación en el cierre documental; no se alteró en este lote |
| `productSearcher` | Divergente | Vigente | HTML, JS | Contrato/rutas actuales | XML y CSS equivalentes | HTML/JS anteriores sin evidencia Sprint 2 | `ProductSearcherController`, `SampleLookupController`, Record Types, bodega | Alto | Conciliado con Partial | Imports, propiedades, eventos, XML | Lote 1/3: Empresa dinámica |
| `busquedaDetallada` | Divergente | Vigente | HTML, JS | Selección/navegación actuales | XML equivalente | HTML/JS anteriores sin evidencia Sprint 2 | `BusquedaDetalladaController`; componentes detalle | Alto | Conciliado con Partial | Imports, `@api`/`@wire`, hijos, XML | Lote 1: Pricebooks por Empresa |
| `qoSearchDetailProduct` | Divergente | Vigente | HTML, JS | Flujo Quote, bodegas y referencias | XML equivalente | HTML/JS anteriores sin evidencia Sprint 2 | `WoliGridController2`; `pricebookReferenceDetails`; `solicitudCompra` | Alto | Conciliado con Partial | Imports, parámetros, hijos, XML | Lote 4/6: `empresaFactura` y bodega |
| `woSearchDetailProduct` | Divergente | Vigente | HTML, JS | Flujo Work Order y referencias | XML equivalente | HTML/JS anteriores sin evidencia Sprint 2 | `WoliGridController`; `pricebookReferenceDetails`; `solicitudCompraWO` | Alto | Conciliado con Partial | Imports, parámetros, hijos, XML | Lote 4/6: Empresa y bodegas |
| `pricebookReferenceDetails` | Divergente | Vigente | JS | Consulta actual Softland | HTML y XML equivalentes | JS anterior sin evidencia Sprint 2 | `WoliGridController.getSoftlandPriceReferences` | Alto | Conciliado con Partial | Import, propiedades, XML | Lote 1/6: Empresa/ERP |
| `CommunityMenu` | Divergente | Vigente | CMP, CSS, controller, helper | Navegación/agenda vigentes | Auradoc y descriptor equivalentes | Versión anterior eliminaba conducta vigente | Apex, eventos, sucursal, calendario | Crítico | Conciliado con Partial | Acciones, atributos, eventos, descriptor | Lote 5/6: configuración y texto legal |
| `CommunityControl` | Divergente | Vigente | CMP, controller, helper | Control/agenda vigentes | CSS, design, renderer, SVG, auradoc y descriptor equivalentes | Versión anterior sin evidencia Sprint 2 | Apex, eventos, sucursal, calendario | Crítico | Conciliado con Partial | Acciones, atributos, eventos, descriptor | Lote 5/6: catálogo y sucursales |
| `customerCommunity_lwc` | Divergente | Vigente | CMP | Marcado/rutas vigentes | Ocho archivos auxiliares equivalentes | CMP anterior sin evidencia Sprint 2 | Apex, eventos, `CommunityCalendar` | Crítico | Conciliado con Partial | Atributos, eventos, descriptor | Lote 5/6: operación PEKING |
| `callcenterCommunity_lwc` | Divergente | Vigente | CMP | Marcado/rutas vigentes | Ocho archivos auxiliares equivalentes | CMP anterior sin evidencia Sprint 2 | Apex, eventos, `CommunityCalendar` | Crítico | Conciliado con Partial | Atributos, eventos, descriptor | Lote 5/6: reglas call center |
| `quoliGridDespacho` | Divergente | Vigente | Ninguno | Ninguno: detenido | Bundle Git intacto | Ninguno | `QuoliGridController`, `savePDFfile`; falta `woliGridDespachoDatatable` | Alto | **No conciliado** | Dependencias y relación padre–hijo | Autorizar/recuperar dependencia antes de Lote 4 |
| `woliGridDespacho` | Divergente | Vigente | Ninguno | Ninguno: detenido | Bundle Git intacto | Ninguno | Faltan `WoliGridDespachoSelectionController` y `woliGridDespachoDatatable` | Alto | **No conciliado** | Dependencias Apex y padre–hijo | Autorizar/recuperar dependencias antes de Lote 4 |

## Validaciones

- Inventario de archivos y comparación contra Partial normalizando CRLF/LF y salto final.
- Revisión de imports/métodos Apex, parámetros, `@api`, `@wire`, `@track`, eventos y relaciones padre–hijo.
- Lectura XML de `.js-meta.xml`, targets y propiedades expuestas.
- Revisión estática disponible. `node --check` no admite decoradores LWC y rechazó `@track` antes de evaluar el módulo; no se tomó como fallo del bundle.
- Verificación de que los 20 Flows no cambiaron y no se añadió lógica PEKING.

## Conclusión

Nueve conflictos quedaron conciliados y dos bundles ausentes quedaron versionados. `quoliGridDespacho` y `woliGridDespacho` siguen detenidos por dependencias no versionadas. La base permite iniciar Lote 1 en recursos conciliados, excluyendo despacho hasta resolver esas dependencias.
