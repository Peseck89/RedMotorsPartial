# RedMotors / PEKING - Cierre implementación Sprint 4

Fecha: 2026-08-13

Rama de trabajo: `feature/luis/peking-sprint4-implementacion-20260813`

Base usada: `feature/luis/peking-entregas-consolidadas-20260813`

Alcance aplicado: Sprint 4 oficial del documento `DEV -Evaluación - Alcance - Inclusión de nueva Empresa- Marcaas chinas Redmotors`, limitado por la instrucción directa de Luis para este bloque. No se tocó Salesforce, no se hizo deploy, no DML, no Production, no PR y no merge.

## Resumen ejecutivo

Se cerraron los gaps seguros de LWC de Ventas Nuevas que todavía forzaban marca `BMW` desde wrappers autorizados y un typo funcional de filtro de color externo. Se corrigió además un typo interno de `isLoading` en el selector dinámico de Record Types de Opportunity.

No se agregaron hardcodes PEKING. Donde el repositorio ya usa `Empresa__c` / lookup a `Empresa__c`, no se reintrodujo picklist. Donde el XML no está versionado o la configuración funcional de comunidad/agenda no existe en Git, se dejó clasificado como gap/bloqueo real sin inventar metadata.

## 1. Picklists / campos oficiales

| Campo oficial | Estado inicial | Cambio realizado | Estado final | Evidencia | Pendiente/bloqueo real |
|---|---|---|---|---|---|
| `Quote.Compania__c` | No versionado en Git | Ninguno | FALTA SOURCE / REQUIERE RETRIEVE | No existe `force-app/main/default/objects/Quote` en la rama | Recuperar metadata antes de cambiar; no inventar picklist. |
| `Quote.empresaFactura__c` | No versionado en Git | Ninguno | FALTA SOURCE / REQUIERE RETRIEVE | No existe `force-app/main/default/objects/Quote` en la rama | Recuperar metadata antes de cambiar. |
| `Opportunity.BMW_Compania__c` | No versionado en Git; existe modelo nuevo `Opportunity.Empresa_Operadora__c` | Ninguno | YA RESUELTO POR MODELO EMPRESA para rutas nuevas / legacy no versionado | `Opportunity/fields/Empresa_Operadora__c.field-meta.xml` lookup a `Empresa__c`; `BMW_Compania__c` no está en source | No reintroducir PEKING al picklist si la ruta ya usa lookup. |
| `Opportunity.empresaQueFactura__c` | No versionado en Git | Ninguno | FALTA SOURCE / REQUIERE RETRIEVE | Campo no existe en source | Recuperar metadata antes de cambiar. |
| `Order.empresaQueFactura__c` | No versionado en Git | Ninguno | FALTA SOURCE / REQUIERE RETRIEVE | No existe `force-app/main/default/objects/Order` en la rama | Recuperar metadata antes de cambiar. |
| `WorkOrder.empresaFactura__c` | Versionado con `RMBAVARIAN`, `RMOTOBAI`, `RMPEKING` | Ninguno | REQUIERE VALOR PEKING - YA COMPLETO | `WorkOrder/fields/empresaFactura__c.field-meta.xml` incluye `RMPEKING` | Sin gap de metadata. Mantener lookup `empresaFacturaCP__c` como fuente moderna cuando aplique. |
| `User.Empresa__c` | No versionado en Git | Ninguno | FALTA SOURCE / REQUIERE RETRIEVE | No existe `force-app/main/default/objects/User` en la rama | Recuperar metadata antes de cambiar. |
| `Product2.Empresa__c` | Versionado con `RMBAVARIAN`, `RMOTOBAI`, `RMPEKING` | Ninguno | REQUIERE VALOR PEKING - YA COMPLETO | `Product2/fields/Empresa__c.field-meta.xml` incluye `RMPEKING` | Sin gap de metadata; posible deuda futura: migrar a lookup, fuera de este bloque. |
| `CentroCosto__c.Empresa__c` | No versionado en Git | Ninguno | FALTA SOURCE / REQUIERE RETRIEVE | No existe `force-app/main/default/objects/CentroCosto__c` en la rama | Centro de costo fue definido como reutilizable; no inventar campo. |
| `TipoDeCargoConManoDeObra__c.Empresa__c` | Versionado con `RMBAVARIAN`, `RMOTOBAI`, `RMPEKING` | Ninguno | REQUIERE VALOR PEKING - YA COMPLETO | `TipoDeCargoConManoDeObra__c/fields/Empresa__c.field-meta.xml` incluye `RMPEKING` | Sigue siendo catálogo/dato funcional; no crear registros por DML. |
| `Linea_Plantilla_de_Presupuesto__c.Empresa__c` | No versionado en Git | Ninguno | FALTA SOURCE / REQUIERE RETRIEVE | No existe `force-app/main/default/objects/Linea_Plantilla_de_Presupuesto__c` en la rama | Recuperar metadata antes de cambiar. |
| `ReciboUsado__c.Empresa__c` | No versionado en Git | Ninguno | FALTA SOURCE / REQUIERE RETRIEVE | No existe `force-app/main/default/objects/ReciboUsado__c` en la rama | Recuperar metadata antes de cambiar. |
| `Plantilla_de_Presupuesto__c.BMW_Compania__c` | Legacy no versionado; existe `Empresa_Operadora__c` lookup | Ninguno | YA RESUELTO POR MODELO EMPRESA / NO APLICA POR REFACTOR ACTUAL | `Plantilla_de_Presupuesto__c/fields/Empresa_Operadora__c.field-meta.xml` lookup a `Empresa__c`; `BMW_Compania__c` no está en source | No reintroducir PEKING al picklist si la selección se resuelve por `Empresa_Operadora__c`. |

Campos realmente modificados: ninguno. Los campos versionados ya tenían `RMPEKING`; los no versionados no se inventaron.

## 2. Record Types OMODA/JAECOO

| Objeto | Estado inicial | Cambio realizado | Estado final | Evidencia | Pendiente/bloqueo real |
|---|---|---|---|---|---|
| `Opportunity` | `Omoda` y `Jaecoo` ya existen, activos, business process `Autos`, compact layout `Vehiculos_Nuevos` | Ninguno | HECHO | `Opportunity/recordTypes/Omoda.recordType-meta.xml`, `Opportunity/recordTypes/Jaecoo.recordType-meta.xml` | Sin gap de RT. |
| `Lead` | `Omoda` y `Jaecoo` ya existen, activos, business process `Autos` | Ninguno | HECHO | `Lead/recordTypes/Omoda.recordType-meta.xml`, `Lead/recordTypes/Jaecoo.recordType-meta.xml` | Sin gap de RT. |
| `Lead -> Opportunity` | Mapping ya existe | Ninguno | HECHO | `customMetadata/RM_RecordTypeMapping.Lead_Omoda_to_Opp.md-meta.xml` y `Lead_Jaecoo_to_Opp.md-meta.xml`, ambos activos | Sin gap de metadata. |
| `Order` | No existe metadata de objeto/RT en Git | Ninguno | FALTA SOURCE / NO IMPLEMENTADO | No existe `force-app/main/default/objects/Order` | Requiere retrieve o definición de patrón funcional antes de crear RT. |
| `Case` | No existe metadata de objeto/RT en Git | Ninguno | FALTA SOURCE / NO IMPLEMENTADO | No existe `force-app/main/default/objects/Case` | Requiere retrieve o definición de patrón funcional antes de crear RT/support process. |

Record Types creados/completados en este bloque: ninguno; Opportunity y Lead ya estaban completos en Git. Order/Case no se inventaron.

## 3. Global Value Sets

| Actividad | Estado inicial | Cambio realizado | Estado final | Evidencia | Pendiente/bloqueo real |
|---|---|---|---|---|---|
| Identificar GVS de marca/familia/modelo | No hay `globalValueSets` ni `standardValueSets` en source | Ninguno | FALTA SOURCE / REQUIERE RETRIEVE | Búsqueda en repo: sin carpeta `globalValueSets`; sin referencias `valueSetName`/`globalValueSet` en metadata versionada | Recuperar los 3 GVS reales antes de modificar. No inventar valores ni nombres de GVS. |

GVS modificados: ninguno.

## 4. LWC/Aura autorizados de Sprint 4

| Componente | Estado inicial | Cambio realizado | Estado final | Evidencia | Pendiente/bloqueo real |
|---|---|---|---|---|---|
| `rm_vn_crear_opp_general` | Forzaba `@api brand = 'BMW'` y pasaba `brand="BMW"` a wrappers desktop/móvil | Se cambió a `@api brand = ''` y `brand={brand}` | HECHO | `rm_vn_crear_opp_general.js`, `rm_vn_crear_opp_general.html` | QA funcional pendiente en Partial por el equipo. |
| `rm_vn_crear_opp_home` | Forzaba `@api brand = 'BMW'` y pasaba `brand="BMW"` a `rm_vn_crear_opp` | Se cambió a `@api brand = ''` y `brand={brand}` | HECHO | `rm_vn_crear_opp_home.js`, `rm_vn_crear_opp_home.html` | QA funcional pendiente. |
| `rm_vn_crear_opp_home_movil` | Forzaba `@api brand = 'BMW'` y pasaba `brand="BMW"` a `rm_vn_crear_opp_movil` | Se cambió a `@api brand = ''` y `brand={brand}` | HECHO | `rm_vn_crear_opp_home_movil.js`, `rm_vn_crear_opp_home_movil.html` | QA funcional pendiente. |
| `rm_vn_get_record_opp_record_types` | Ya cargaba RT dinámicamente desde Apex, pero usaba typo `isloading` | Se normalizó a `isLoading` en wire/getter | HECHO | `rm_vn_get_record_opp_record_types.js`; Apex `RM_VN_GetOppRecordTypes_Ctrl` no excluye Omoda/Jaecoo | QA visual pendiente. |
| `rm_vn_crear_opp_inventario` | Tenía typo funcional `this.interexternalColornalColor = searchKey` | Se corrigió a `this.externalColor = searchKey` | HECHO | `rm_vn_crear_opp_inventario.js` | QA de filtro color externo pendiente. |
| `rm_vn_inventario` | Recibe `brand` dinámico y consulta Apex por marca; no fuerza BMW/Otobai | Ninguno | HECHO / SIN GAP LWC | `rm_vn_inventario.js` usa `@api brand` y lo pasa a Apex | QA funcional pendiente con marcas nuevas/datos. |
| `rm_vn_inventario_movil` | Igual que desktop: recibe `brand` dinámico | Ninguno | HECHO / SIN GAP LWC | `rm_vn_inventario_movil.js` usa `@api brand` | QA funcional pendiente. |
| `productSearcher` | No tiene rama PEKING; usa bodega por heurística de marca y default autos | Ninguno | PARCIAL / SIN CAMBIO SEGURO | `productSearcher.js` no fuerza Bavarian/Otobai para PEKING; marcas no moto caen a autos/BR01 | Bodega PEKING es provisional QA; validar funcionalmente con datos. |
| `quoliGridDespacho` | No existe como LWC/Aura con ese nombre en source | Ninguno | FALTA SOURCE / NO IMPLEMENTADO | No se encontró carpeta `lwc/quoliGridDespacho` ni `aura/quoliGridDespacho` | Requiere nombre real o retrieve. |
| `woliGridDespacho` | Existe LWC; no se confirmó gap PEKING seguro en JS bajo este bloque | Ninguno | REVISADO / SIN CAMBIO | Carpeta `lwc/woliGridDespacho` existe | QA/despacho funcional posterior. |
| `kpiSucursales` | Existe LWC, pero depende de definición/sucursal/visibilidad operativa | Ninguno | REVISADO / SIN CAMBIO | Carpeta `lwc/kpiSucursales` existe | Validar con visibilidad PEKING cuando exista dataset/sucursal. |
| `CommunityMenu` | Lista de marcas y servicios comunitarios están acoplados a configuración de citas/servicio | Ninguno | BLOQUEADO — SERVICIOS/AGENDA PEKING | `CommunityMenu.cmp` tiene lista BMW/MINI/Motorrad; controller invoca setup/calendarios por `marcaSel` | No inventar agenda/servicios de comunidad sin configuración versionada. |
| `CommunityControl` | Comunidad de citas/servicio | Ninguno | BLOQUEADO — SERVICIOS/AGENDA PEKING | Componente Aura existente | Misma dependencia de agenda/servicio PEKING. |
| `CommunityCalendar` | Comunidad de citas/servicio | Ninguno | BLOQUEADO — SERVICIOS/AGENDA PEKING | Componente Aura existente | Misma dependencia. |
| `customerCommunity_lwc` | Contenedor Aura de comunidad | Ninguno | BLOQUEADO — SERVICIOS/AGENDA PEKING | Componente Aura existente | Misma dependencia. |
| `callcenterCommunity_lwc` | Contenedor Aura de comunidad/callcenter | Ninguno | BLOQUEADO — SERVICIOS/AGENDA PEKING | Componente Aura existente | Misma dependencia. |
| `assetGarantiaLookupLwc` | No existe carpeta LWC/Aura con ese nombre en source | Ninguno | FALTA SOURCE / NO IMPLEMENTADO | No se encontró `lwc/assetGarantiaLookupLwc` | Requiere nombre real o retrieve. |
| `BusquedaDetalladaController` / `busquedaDetallada` | Sigue dependiendo de sucursal/visibilidad específica | Ninguno | BLOQUEADO — VISIBILIDAD/SUCURSAL PEKING | Bloque especial indicado por Luis; no implementar si falta definición | Mantener fuera de implementación hasta definición específica. |

LWC/Aura realmente modificados:

- `rm_vn_crear_opp_general`
- `rm_vn_crear_opp_home`
- `rm_vn_crear_opp_home_movil`
- `rm_vn_get_record_opp_record_types`
- `rm_vn_crear_opp_inventario`

## 5. Archivos modificados

- `force-app/main/default/lwc/rm_vn_crear_opp_general/rm_vn_crear_opp_general.js`
- `force-app/main/default/lwc/rm_vn_crear_opp_general/rm_vn_crear_opp_general.html`
- `force-app/main/default/lwc/rm_vn_crear_opp_home/rm_vn_crear_opp_home.js`
- `force-app/main/default/lwc/rm_vn_crear_opp_home/rm_vn_crear_opp_home.html`
- `force-app/main/default/lwc/rm_vn_crear_opp_home_movil/rm_vn_crear_opp_home_movil.js`
- `force-app/main/default/lwc/rm_vn_crear_opp_home_movil/rm_vn_crear_opp_home_movil.html`
- `force-app/main/default/lwc/rm_vn_get_record_opp_record_types/rm_vn_get_record_opp_record_types.js`
- `force-app/main/default/lwc/rm_vn_crear_opp_inventario/rm_vn_crear_opp_inventario.js`
- `docs/empresa-marcas-chinas/CIERRE_IMPLEMENTACION_SPRINT4_PEKING_20260813.md`

## 6. Validaciones

- No Salesforce, no deploy, no DML, no Production.
- No se tocaron Apex prohibidas: `CrearPlandeVenta`, `HttpCalloutGetProductRefPrices`, `ProductoLocalizacionHelper`, `QuoteSoftlandPedidoService`, `HttpCalloutCreateKit`.
- No se tocaron Flows de Sprint 2.
- No se modificó XML de metadata de campos/RT/GVS porque los gaps seguros no estaban versionados o ya estaban completos.
- Validación XML/metadata: no aplica a los archivos modificados de este commit; la metadata XML revisada quedó sin cambios.
- Jest: no se encontraron pruebas Jest específicas/versionadas para estos LWC en el alcance revisado.
- Apex tests: no aplica; no se tocó Apex.
- `git diff --check`: el checkout local se queda colgado incluso con `git status`; se validó el diff remoto por GitHub y se documenta la limitación operativa.

## 7. Trabajo fuera de alcance

No se implementó trabajo extra. Los siguientes puntos requieren fuente/retrieve/definición antes de codificar y, si se autorizan después, deben tratarse por separado:

- RT de `Order` y `Case` si no están en source.
- Los 3 GVS reales de marca/familia/modelo si no están en source.
- Comunidad de servicio/citas para PEKING si no existe configuración/versionado de agenda, servicios y sucursales.
- `BusquedaDetalladaController` / `busquedaDetallada` hasta definición específica de visibilidad/sucursal PEKING.
- Migración futura de picklists remanentes a lookups Empresa en objetos no versionados.

Si alguno de esos puntos no estaba contemplado en el alcance/horas originales, debe marcarse como:

`TRABAJO EXTRA — NO CONTEMPLADO EN EL ALCANCE/HORAS ORIGINALES`
