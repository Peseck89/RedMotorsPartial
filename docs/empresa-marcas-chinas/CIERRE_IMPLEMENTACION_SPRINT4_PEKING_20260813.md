# RedMotors / PEKING - Cierre implementación Sprint 4

Fecha: 2026-08-13

Rama de trabajo: `feature/luis/peking-sprint4-implementacion-20260813`

HEAD base de esta continuación: `4b1b623ce27cfee91a52797da8dacc433d4953ad`

Alcance aplicado: cierre del núcleo formal restante de Sprint 4 sobre la rama ya entregada. Se revisaron los 13 campos/picklists, Record Types de `Opportunity`, `Lead`, `Order` y `Case`, y los Global Value Sets contemplados por el alcance oficial.

Restricciones respetadas: no Salesforce, no deploy, no DML, no Production, no Sprint 1/2, no Apex bloqueado por el otro Code, no volver a modificar los LWC ya cerrados salvo fallo demostrado.

## Resumen ejecutivo

No se encontraron gaps seguros de metadata que deban modificarse directamente en Git para este núcleo formal sin hacer retrieve desde Salesforce.

Lo que está versionado y forma parte del modelo actual ya quedó cubierto:

- `WorkOrder.empresaFactura__c` incluye `RMPEKING`.
- `Product2.Empresa__c` incluye `RMPEKING`.
- `TipoDeCargoConManoDeObra__c.Empresa__c` incluye `RMPEKING`.
- `Opportunity.Omoda` y `Opportunity.Jaecoo` existen y están activos.
- `Lead.Omoda` y `Lead.Jaecoo` existen y están activos.
- `RM_RecordTypeMapping.Lead_Omoda_to_Opp` y `RM_RecordTypeMapping.Lead_Jaecoo_to_Opp` existen y están activos.
- `Opportunity.Empresa_Operadora__c`, `WorkOrder.empresaFacturaCP__c` y `Plantilla_de_Presupuesto__c.Empresa_Operadora__c` son el camino vigente de lookup/configuración hacia `Empresa__c`.

Lo que no está versionado en la rama no se inventó. Crear XML de campos, Record Types de `Order`/`Case` o Global Value Sets sin la metadata fuente real puede romper el deploy por propiedades invisibles en Git, business/support process, dependencias de picklist, permisos o diferencias del campo productivo.

## 1. 13 campos/picklists oficiales

| # | Campo oficial | Estado | Evidencia en Git | Acción tomada | Nota de cierre |
|---:|---|---|---|---|---|
| 1 | `Quote.Compania__c` | PENDIENTE SOURCE / REQUIERE RETRIEVE | No existe `force-app/main/default/objects/Quote` en la rama. Flows lo referencian como campo legacy, pero las rutas nuevas resuelven Empresa desde `Opportunity.Empresa_Operadora__c`. | Ninguna. | No se agrega PEKING a ciegas. Requiere recuperar el campo real si negocio decide mantenerlo como picklist activo. |
| 2 | `Quote.empresaFactura__c` | PENDIENTE SOURCE / REQUIERE RETRIEVE | No existe `force-app/main/default/objects/Quote`. LWC como `busquedaDetallada`, `qoSearchDetailProduct` y `woSearchDetailProduct` lo importan como campo legacy. | Ninguna. | No hay XML base para modificar valores ni confirmar tipo/restricción. |
| 3 | `Opportunity.BMW_Compania__c` | NO APLICA POR LOOKUP EMPRESA | El campo legacy no está versionado. Sí existe `Opportunity/fields/Empresa_Operadora__c.field-meta.xml` como lookup a `Empresa__c`. Los Flows activos usan `Empresa_Operadora__c` y dejan el legacy solo como compatibilidad Bavarian/Otobai. | Ninguna. | No se debe reintroducir PEKING en este picklist si la ruta moderna ya usa lookup Empresa. |
| 4 | `Opportunity.empresaQueFactura__c` | PENDIENTE SOURCE / LEGACY | No está versionado. `Opportunity_Flow_V2` aún lo llena desde `$User.Empresa__c` en una ruta legacy, pero también guarda `Empresa_Operadora__c`. | Ninguna. | Requiere retrieve si se decide corregir el picklist legacy; preferible no ampliarlo si se puede retirar por lookup. |
| 5 | `Order.empresaQueFactura__c` | PENDIENTE SOURCE / REQUIERE RETRIEVE | No existe `force-app/main/default/objects/Order`. Código como `OrderBatch` obtiene empresa desde `Work_Order__r.empresaFactura__c`, no desde metadata versionada de Order. | Ninguna. | No se inventa el campo ni sus valores desde el PDF. |
| 6 | `WorkOrder.empresaFactura__c` | HECHO | `force-app/main/default/objects/WorkOrder/fields/empresaFactura__c.field-meta.xml` contiene `RMBAVARIAN`, `RMOTOBAI`, `RMPEKING`. | Ninguna. | Picklist legacy completo. El lookup `empresaFacturaCP__c` sigue siendo la fuente moderna cuando existe. |
| 7 | `User.Empresa__c` | PENDIENTE SOURCE / REQUIERE RETRIEVE | No existe `force-app/main/default/objects/User`. Flows lo usan como sugerencia/default, no como fuente final cuando hay selección explícita de Empresa. | Ninguna. | No se inventa campo estándar/custom de User sin XML real. |
| 8 | `Product2.Empresa__c` | HECHO | `force-app/main/default/objects/Product2/fields/Empresa__c.field-meta.xml` contiene `RMBAVARIAN`, `RMOTOBAI`, `RMPEKING`. `Product2/recordTypes/Producto_Red_Motors.recordType-meta.xml` también habilita los tres valores. | Ninguna. | Campo listo para PEKING en metadata versionada. |
| 9 | `CentroCosto__c.Empresa__c` | PENDIENTE SOURCE / NO BLOQUEO FUNCIONAL | No existe `force-app/main/default/objects/CentroCosto__c`. La decisión vigente indica reutilizar un centro de costo existente y mantener aprobadores por la lógica actual. | Ninguna. | No requiere inventar valor PEKING para cerrar Sprint 4; si negocio exige segregación futura, requiere retrieve y alcance separado. |
| 10 | `TipoDeCargoConManoDeObra__c.Empresa__c` | HECHO | `force-app/main/default/objects/TipoDeCargoConManoDeObra__c/fields/Empresa__c.field-meta.xml` contiene `RMBAVARIAN`, `RMOTOBAI`, `RMPEKING`. | Ninguna. | Metadata lista. La carga de registros catálogo/PricebookEntry es dato funcional, no DML en este bloque. |
| 11 | `Linea_Plantilla_de_Presupuesto__c.Empresa__c` | NO APLICA POR LOOKUP EMPRESA / SOURCE NO VERSIONADO | No existe metadata del objeto/campo. Las rutas actuales usan `Plantilla_de_Presupuesto__c.Empresa_Operadora__c` para resolver Empresa/Pricebook. | Ninguna. | No se debe recrear un picklist por línea si el modelo vigente resuelve desde la Plantilla/Empresa. |
| 12 | `ReciboUsado__c.Empresa__c` | PENDIENTE SOURCE / FUERA DE VN PEKING | No existe metadata del objeto/campo; solo Flows/clases de usados referencian `ReciboUsado__c`. | Ninguna. | No se modifica en Sprint 4 porque el alcance PEKING/Omoda/Jaecoo de VN no debe arrastrar usados sin autorización. |
| 13 | `Plantilla_de_Presupuesto__c.BMW_Compania__c` | NO APLICA POR LOOKUP EMPRESA | El campo legacy no está versionado. Sí existe `Plantilla_de_Presupuesto__c/fields/Empresa_Operadora__c.field-meta.xml` como lookup a `Empresa__c`. | Ninguna. | No reintroducir PEKING al picklist legacy; la ruta correcta es `Empresa_Operadora__c`. |

Campos modificados en esta continuación: ninguno.

Campos ya completos en Git: `WorkOrder.empresaFactura__c`, `Product2.Empresa__c`, `TipoDeCargoConManoDeObra__c.Empresa__c`.

Campos que no deben ampliarse con PEKING por el modelo actual: `Opportunity.BMW_Compania__c`, `Plantilla_de_Presupuesto__c.BMW_Compania__c`, y preferentemente `Linea_Plantilla_de_Presupuesto__c.Empresa__c` si la empresa se hereda desde la Plantilla.

Campos que requieren retrieve antes de cualquier cambio: `Quote.Compania__c`, `Quote.empresaFactura__c`, `Opportunity.empresaQueFactura__c`, `Order.empresaQueFactura__c`, `User.Empresa__c`, `CentroCosto__c.Empresa__c`, `ReciboUsado__c.Empresa__c`.

## 2. Record Types Omoda/Jaecoo

| Objeto | Estado | RT existentes en Git | RT creados en esta continuación | Evidencia | Siguiente acción |
|---|---|---|---|---|---|
| `Opportunity` | HECHO | `Omoda`, `Jaecoo` | Ninguno | `force-app/main/default/objects/Opportunity/recordTypes/Omoda.recordType-meta.xml`; `Jaecoo.recordType-meta.xml` | No duplicar. Validar asignación por perfil/app en QA. |
| `Lead` | HECHO | `Omoda`, `Jaecoo` | Ninguno | `force-app/main/default/objects/Lead/recordTypes/Omoda.recordType-meta.xml`; `Jaecoo.recordType-meta.xml` | No duplicar. |
| Lead -> Opportunity | HECHO | Mapping Omoda y Jaecoo activo | Ninguno | `force-app/main/default/customMetadata/RM_RecordTypeMapping.Lead_Omoda_to_Opp.md-meta.xml`; `Lead_Jaecoo_to_Opp.md-meta.xml` | Validación funcional de conversión en Partial. |
| `Order` | PENDIENTE SOURCE / NO CREADO | No existe `force-app/main/default/objects/Order` | Ninguno | El documento oficial dice que Order tenía solo BMW, pero la rama no trae XML de Order ni sus picklists/permisos. | Hacer retrieve de `Order` y sus RT reales antes de crear `Omoda`/`Jaecoo`; no crear RT a ciegas. |
| `Case` | PENDIENTE SOURCE / NO CREADO | No existe `force-app/main/default/objects/Case` | Ninguno | El documento oficial dice revisar RT por marca/tipo. La rama no trae XML de Case ni support process/business process. | Hacer retrieve de `Case`, support process y valores por RT antes de crear `Omoda`/`Jaecoo`. |

Record Types creados en esta continuación: ninguno.

Motivo: los faltantes reales de `Order` y `Case` no tienen metadata fuente en la rama. En especial `Case` puede depender de support process/business process; inventarlo desde Git sería más riesgoso que dejarlo documentado como gap de source.

## 3. Global Value Sets

| Elemento | Estado | Evidencia | Acción tomada | Siguiente acción |
|---|---|---|---|---|
| 3 GVS oficiales de marca | PENDIENTE SOURCE / NOMBRES EXACTOS NO VERSIONADOS | El PDF oficial solo indica agregar valores de marca/familia en `Family` y Global Value Sets de marca. La documentación interna conserva el pendiente como "tres GVS por identificar" y "41 GVS existen en Partial; tres objetivo no identificados aquí". En la rama no existe `force-app/main/default/globalValueSets`, `standardValueSets`, ni referencias `valueSetName`/`globalValueSet`. | Ninguna. | Retrieve dirigido de los 3 GVS reales o confirmación de sus API names antes de modificar. |
| `Product2.Family` por `Producto_Red_Motors` | REVISADO / NO MODIFICADO | `Product2/recordTypes/Producto_Red_Motors.recordType-meta.xml` contiene `Family = None`. | Ninguna. | No agregar `OMODA`, `JAECOO` o `PEKING` a `Family` sin semántica aprobada; marca/empresa/familia no son equivalentes. |
| `Product2.Empresa__c` | HECHO | Campo y RT `Producto_Red_Motors` ya permiten `RMPEKING`. | Ninguna. | QA de productos/datos PEKING; no DML en este bloque. |

GVS identificados/modificados: ninguno modificado. Los nombres técnicos exactos no están en Git ni en el PDF; por restricción de no Salesforce no se hizo retrieve ni consulta de org.

No se inventó un cuarto GVS ni valores ajenos.

## 4. LWC ya cerrados

No se rehicieron ni se volvieron a modificar los LWC cerrados en `4b1b623`.

Se mantienen como cambios previos de Sprint 4:

- `rm_vn_crear_opp_general`
- `rm_vn_crear_opp_home`
- `rm_vn_crear_opp_home_movil`
- `rm_vn_crear_opp_inventario`
- `rm_vn_get_record_opp_record_types`

## 5. Archivos modificados en esta continuación

- `docs/empresa-marcas-chinas/CIERRE_IMPLEMENTACION_SPRINT4_PEKING_20260813.md`

No se modificaron Apex, Flows, LWC, Aura, Layouts, Custom Fields, Record Types ni Global Value Sets en esta continuación.

## 6. Qué queda realmente pendiente

Pendiente por falta de source/retrieve, no por decisión de negocio:

1. Recuperar metadata real de `Quote` para revisar `Compania__c` y `empresaFactura__c`.
2. Recuperar metadata real de `Order` para revisar `empresaQueFactura__c` y crear solo los RT Omoda/Jaecoo que falten.
3. Recuperar metadata real de `Case` junto con support/business process para crear solo los RT Omoda/Jaecoo que falten.
4. Recuperar metadata real de `User.Empresa__c` si se decide mantenerlo como picklist/default operativo.
5. Recuperar metadata real de `CentroCosto__c.Empresa__c` si negocio exige segregación de centro de costo por Empresa; con la definición vigente de reutilizar centro de costo, no bloquea.
6. Recuperar metadata real de `ReciboUsado__c.Empresa__c` solo si se autoriza usados para PEKING.
7. Identificar por API name los 3 GVS reales de marca/familia/modelo antes de agregar Omoda/Jaecoo/PEKING.

No pendiente por definición de negocio en este bloque:

- bodega/territorio: datos QA provisionales;
- centro de costo: reutilizar existente;
- aprobadores: lógica existente por centro de costo;
- Pricebook default: dato de prueba;
- branding/razón social: prueba;
- garantía: validada sin cambio técnico.

## 7. Validaciones

- No Salesforce.
- No deploy.
- No DML.
- No Production.
- No Sprint 1/2.
- No Apex bloqueado por el otro Code.
- No LWC reabiertos.
- Búsqueda local en clon temporal de Git confirmó ausencia de `Quote`, `Order`, `Case`, `User`, `CentroCosto__c`, `Linea_Plantilla_de_Presupuesto__c`, `globalValueSets` y `standardValueSets` como metadata versionada.
- XML inspeccionado para `WorkOrder.empresaFactura__c`, `Product2.Empresa__c`, `TipoDeCargoConManoDeObra__c.Empresa__c`, `Plantilla_de_Presupuesto__c.Empresa_Operadora__c`, RT de `Opportunity`, RT de `Lead` y mappings `RM_RecordTypeMapping`.

## 8. Dictamen

El núcleo formal de Sprint 4 queda reconciliado en Git con una conclusión importante: no hay más cambio seguro que hacer sin retrieve de la metadata faltante.

Si el equipo quiere que esta rama sea deployable como paquete de implementación, puede integrarse tal cual con los LWC ya cerrados y este documento de cierre. Si además quieren cerrar físicamente `Quote`, `Order`, `Case` y los 3 GVS, el siguiente paso técnico no es inventar XML, sino recuperar esa metadata real de Partial y aplicar el mismo criterio: modificar solo gaps confirmados, sin reintroducir PEKING como hardcode cuando el lookup Empresa ya lo reemplazó.
