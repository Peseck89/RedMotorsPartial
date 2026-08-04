# Resumen ejecutivo de auditoría — Sprint 2

## Dictamen

La población conciliada contiene exactamente **45 elementos**: **20 Flows** y **25 bundles** (**20 LWC y 5 Aura**). No se contabilizan clases Apex, triggers, campos, layouts ni Permission Sets como bundles. Esos artefactos aparecen únicamente como dependencias.

| Clasificación | Flow | LWC | Aura | Total |
|---|---:|---:|---:|---:|
| MODIFICAR | 12 | 3 | 0 | 15 |
| SIN CAMBIO TÉCNICO | 6 | 3 | 1 | 10 |
| NO APLICA | 2 | 2 | 0 | 4 |
| BLOQUEADO | 0 | 12 | 4 | 16 |
| **Total** | **20** | **20** | **5** | **45** |

Sprint 2 no puede cerrarse técnicamente mientras existan lógica empresarial binaria, Pricebooks nominales, versiones de Flow sin reconciliar y bundles desplegados sin trazabilidad o con contenido diferente. Otros elementos ya son técnicamente compatibles, pero todavía requieren datos y decisiones externas para validación funcional completa.

## 15 elementos MODIFICAR

Todos son P0 y riesgo alto. Dentro de la misma prioridad se ordenan primero los que pueden seleccionar Empresa, Pricebook o Record Type incorrectos y después los que requieren reconciliación previa.

| Orden | Elemento | Tipo | Motivo exacto | Acción previa |
|---:|---|---|---|---|
| 1 | `Work_Order_from_Quote_Selective` | Flow | Empresa nueva puede caer en ruta Bavarian/Otobai residual | Definir comportamiento seguro sin default empresarial |
| 2 | `Work_Order_from_Quote` | Flow | Bifurcación binaria no escalable | Resolver por `Empresa_Operadora__c` |
| 3 | `CreateWoliFromExpense` | Flow | Ruta residual o PricebookEntry ausente para PEKING | Resolver Empresa del WO y Pricebook dinámico |
| 4 | `aperturaCaseWorOrderEvent` | Flow | Compañía binaria y Pricebook por nombre | Configuración explícita por Empresa |
| 5 | `ct_newCaseWorkOrderEvent` | Flow | No existe ruta empresarial configurable | Derivar Empresa del registro principal |
| 6 | `SegregateWOLIs` | Flow | Record Type Id fijo y lógica Otobai | DeveloperName/configuración aprobada |
| 7 | `PlanDeMantenimientoV2` | Flow | PricebookEntry sin contexto empresarial demostrado | Validar pertenencia del Pricebook a Empresa |
| 8 | `AgregarManoObra` | Flow | Assignments Bavarian/Otobai para PricebookEntry | Resolver Empresa del WO |
| 9 | `Opp_Flow_V5` | Flow | Git Draft; Partial activa v29 y latest v30 inactiva; Pricebooks nominales | Decidir vigencia y reconciliar versiones |
| 10 | `Opp_Flow_v6` | Flow | Partial activa v79 y latest v80 inactiva; lógica nominal | Decidir versión autoritativa |
| 11 | `Opp_flow_V3` | Flow | Pricebooks y compañía binarios | Confirmar vigencia frente a v4/v6 |
| 12 | `Opportunity_Flow_V2` | Flow | Empresa del usuario puede gobernar en lugar de la oportunidad | Confirmar vigencia y regla usuario–Empresa |
| 13 | `busquedaDetallada` | LWC | Pricebooks activos sin filtro empresarial visible; contenido distinto | Reconciliar y filtrar/validar por Empresa |
| 14 | `productSearcher` | LWC | Contrato `preciosBavarian`/`pbeBavarian`; contenido distinto | Reconciliar y neutralizar contrato empresarial |
| 15 | `rm_vn_crear_opp_inventario` | LWC | Contrato idéntico en ambos lados pero acoplado a Bavarian | Definir Empresa fuente y precio dinámico |

## 10 elementos SIN CAMBIO TÉCNICO

“Sin cambio técnico” no significa validado funcionalmente ni cerrado.

| Elemento | Tipo | Justificación | Evidencia disponible | Pendiente de validación |
|---|---|---|---|---|
| `Opportunity_Flow` | Flow | Resolver dinámico; no usa nombre/Id fijo ni default Bavarian | Git Active; Partial activa/latest v28 | Monedas y Pricebooks oficiales; E2E |
| `Opp_flow_v4` | Flow | Pricebook se selecciona por Empresa | Git Active; Partial activa/latest v19 | Softland, sucursal y regresión |
| `BMW_ImportarPlantilla` | Flow | Detiene ruta cuando no resuelve Pricebook | Git Active; Partial activa/latest v16 | Bodega/territorio y E2E de plantilla |
| `BMW_Gestiona_Listas_de_Precios` | Flow | Fallback legacy acotado; no convierte desconocida en Bavarian | Git Active; Partial activa/latest v7 | Fecha de retiro del fallback |
| `Obtener_PricebookEntry_en_Linea_de_Plantilla_de_Presupuesto` | Flow | No busca PricebookEntry sin resolución exitosa | Git Active; Partial activa/latest v3 | Productos y precios oficiales |
| `Opportunity_Flow_From_Work_Order` | Flow | Ruta PEKING explícita y asignación del lookup Empresa | Git Active; Partial activa/latest v16 | Mapeo Empresa–Record Type–territorio |
| `rm_vn_crear_opp_general` | LWC | No contiene decisión binaria propia | Contenido idéntico | Dependencias invocadas y E2E |
| `rm_vn_crear_opp_home` | LWC | Contenedor; decisión empresarial pertenece a hijos | Contenido idéntico | Regresión de composición |
| `rm_vn_crear_opp_home_movil` | LWC | Contenedor móvil sin selección propia de Empresa/Pricebook | Contenido idéntico | Regresión móvil |
| `CommunityCalendar` | Aura | Recibe capacidad/sucursal; no decide Empresa o Pricebook | Contenido idéntico | Datos oficiales desde componentes padre |

## 16 elementos BLOQUEADO

| Elemento | Tipo | Bloqueo consolidado | Naturaleza |
|---|---|---|---|
| `quoliGridDespacho` | LWC | Diff y reglas de despacho/bodega | Técnico + funcional |
| `woliGridDespacho` | LWC | Diff y reglas de despacho/bodega | Técnico + funcional |
| `kpiSucursales` | LWC | Solo en Partial; alcance PEKING no confirmado | Trazabilidad + alcance |
| `cT_Estadisticas_Inventario_lwc` | LWC | Solo en Partial; alcance PEKING no confirmado | Trazabilidad + alcance |
| `rm_vn_inventario` | LWC | Empresa se resuelve en Apex/Softland; faltan bodegas/permisos | Técnico + funcional |
| `rm_vn_inventario_movil` | LWC | Comparte contrato y bloqueo de inventario VN | Técnico + funcional |
| `assetGarantiaLookupLwc` | LWC | Regla de garantía empresarial reside en dependencia Apex | Funcional |
| `rm_vn_get_record_opp_record_types` | LWC | Mapeo Empresa–Record Type no confirmado | Funcional |
| `qoSearchDetailProduct` | LWC | `empresaFactura`, bodega principal y diff | Técnico + funcional |
| `woSearchDetailProduct` | LWC | `empresaFactura`, nombre “Apartados” y diff | Técnico + funcional |
| `localizacionDetails` | LWC | `empresaFactura` y localizaciones Softland | Funcional |
| `pricebookReferenceDetails` | LWC | `empresaFactura`, precios y JS distinto | Técnico + funcional |
| `CommunityMenu` | Aura | Diff, IDs/sucursales y texto legal | Técnico + legal/funcional |
| `CommunityControl` | Aura | Diff y catálogo de servicios/sucursales | Técnico + funcional |
| `customerCommunity_lwc` | Aura | Diff y operación de comunidad | Técnico + funcional |
| `callcenterCommunity_lwc` | Aura | Diff y operación de call center | Técnico + funcional |

## 4 elementos NO APLICA

| Elemento | Motivo confirmado | Estado/acción |
|---|---|---|
| `ReciboUsadosFlow` | Proceso exclusivo de vehículos usados; Luis confirmó que PEKING no aplica | Activo v3 en Producción; no extender para PEKING |
| `rm_vu_inventario` | Componente exclusivo de vehículos usados | No extender ni probar con PEKING |
| `rm_vu_crear_opp` | Componente exclusivo de vehículos usados | No extender ni probar con PEKING |
| `Carga_MO_26_Lavado_a_Caso` | No tiene definición activa en Producción | Latest v4 Obsolete; no trabajar ni reactivar |

## Resultado de la verificación en Producción

La evidencia fue una consulta Tooling API de solo lectura a `FlowDefinition` en `RedMotorsProd` el 2026-08-04.

### Activos que requieren modificación

`PlanDeMantenimientoV2` v23, `Work_Order_from_Quote_Selective` v7, `Work_Order_from_Quote` v9, `SegregateWOLIs` v51, `Opp_Flow_V5` v29, `Opp_flow_V3` v28, `Opp_Flow_v6` v79, `Opportunity_Flow_V2` v6, `CreateWoliFromExpense` v14, `aperturaCaseWorOrderEvent` v20, `ct_newCaseWorkOrderEvent` v54 y `AgregarManoObra` v1.

### Activos que no requieren cambio técnico

`Opportunity_Flow` v25, `Opp_flow_v4` v16, `BMW_ImportarPlantilla` v13, `BMW_Gestiona_Listas_de_Precios` v2, `Obtener_PricebookEntry_en_Linea_de_Plantilla_de_Presupuesto` v1 y `Opportunity_Flow_From_Work_Order` v15.

### Activo fuera de alcance PEKING

`ReciboUsadosFlow` v3, por ser proceso exclusivo de usados.

### Inactivo que no se trabajará

`Carga_MO_26_Lavado_a_Caso`: sin versión activa; latest v4 Obsolete.

## 11 conflictos de contenido Git–Partial

No se detectó ningún bundle de los 25 que falte en Partial. Los siguientes 11 existen en ambos lados y tienen contenido distinto.

| Bundle | Tipo de diferencia | Recursos identificados | Fuente autoritativa recomendada |
|---|---|---|---|
| `productSearcher` | Contenido distinto | HTML, JS | Reconciliar recurso por recurso; Partial como evidencia de ejecución y Git como historial. Decisión de Diego antes de elegir |
| `quoliGridDespacho` | Contenido distinto | HTML, JS | Igual; no sobrescribir Partial |
| `woliGridDespacho` | Contenido distinto | HTML, JS | Igual; no sobrescribir Partial |
| `busquedaDetallada` | Contenido distinto | HTML, JS | Igual; preservar además la corrección empresarial verificable |
| `qoSearchDetailProduct` | Contenido distinto | HTML, JS | Igual; validar contrato con dependencias antes de elegir |
| `woSearchDetailProduct` | Contenido distinto | HTML, JS | Igual; validar lógica de bodega antes de elegir |
| `pricebookReferenceDetails` | Contenido distinto | JS | Comparación dirigida del JS y contrato `empresaFactura` |
| `CommunityMenu` | Contenido distinto | CMP, controller, helper, CSS | Partial para comportamiento desplegado; contenido legal solo con aprobación oficial |
| `CommunityControl` | Contenido distinto | CMP, controller, helper | Partial para comportamiento; Git para trazabilidad; decisión explícita por recurso |
| `customerCommunity_lwc` | Contenido distinto | CMP | Reconciliar solo CMP, sin reemplazar el bundle completo |
| `callcenterCommunity_lwc` | Contenido distinto | CMP | Reconciliar solo CMP, sin reemplazar el bundle completo |

La evidencia autorizada no reporta “dependencia distinta” ni “versión distinta” para estos bundles; reporta archivos fuente distintos. Tampoco permite atribuir automáticamente toda la autoridad a Git o a Partial.

## Bundles faltantes en Git

### `kpiSucursales`

- Ubicación: Partial, bundle LWC con 4 recursos.
- Ruta metadata esperada en Git: `force-app/main/default/lwc/kpiSucursales`; no existe.
- Dependencias/referencias: la auditoría solo registra “Apex/campos de sucursal pendientes de reconciliación”; no ofrece nombres verificables.
- Última modificación: **no disponible en las tres fuentes autorizadas**.
- Riesgo de recuperación: alto. Incorporarlo sin validar propietario, dependencia, alcance y fecha podría versionar una variante no autoritativa o arrastrar contratos no revisados.
- Recomendación: no recuperar todavía. Primero Luis confirma alcance/versionado; después Diego autoriza una reconciliación de solo lectura y define la fuente.

### `cT_Estadisticas_Inventario_lwc`

- Ubicación: Partial, bundle LWC con 3 recursos.
- Ruta metadata esperada en Git: `force-app/main/default/lwc/cT_Estadisticas_Inventario_lwc`; no existe.
- Dependencias/referencias: la auditoría solo registra “Apex/campos de inventario pendientes”; no ofrece nombres verificables.
- Última modificación: **no disponible en las tres fuentes autorizadas**.
- Riesgo de recuperación: alto por falta de trazabilidad, dependencias confirmadas y alcance empresarial.
- Recomendación: no recuperar todavía. Requiere confirmación de alcance de Luis y estrategia de reconciliación de Diego.

## Qué impide el cierre

### Impedimentos técnicos

- 11 bundles con fuente distinta entre Git y Partial.
- 2 bundles desplegados sin versión Git.
- Flows con lógica Bavarian/Otobai y Pricebooks por nombre.
- Record Type Id fijo en `SegregateWOLIs`.
- Diferencia entre versiones activas de Producción y versiones posteriores Draft en Partial para `Opp_Flow_V5` y `Opp_Flow_v6`; la remediación debe dirigirse al comportamiento activo sin activar Drafts.
- Contratos empresariales ambiguos: `empresaFactura`, `preciosBavarian`, contexto de `recordId` y selección global de Pricebooks.

### Impedimentos solo funcionales o de evidencia

- Monedas, Pricebooks, catálogos, productos y precios oficiales.
- Bodegas, sucursales, territorios, servicios y permisos.
- Garantía, usados, mantenimiento, mano de obra, despacho y reserva PEKING.
- Códigos/mapeos y respuestas Softland.
- Datos legales de comunidad.
- Opportunities QA provenientes del flujo real y videos/capturas con perfiles QA.

Estos últimos no justifican inventar configuración; bloquean la validación funcional completa aunque una solución técnica sea diseñable.
