# RedMotors / PEKING - Cierre implementación Sprint 4

Fecha: 2026-08-14

Rama de trabajo: `feature/luis/peking-sprint4-implementacion-20260813`

HEAD remoto vigente al iniciar esta continuación: `b0fc34c25eabac6fc484f7aa44267df77d3ea715`

Fuente nueva autoritativa incorporada: commit `93498803398cea70ce62793f2ce7e1f4e991ccd8`, documento `docs/empresa-marcas-chinas/FUENTES_METADATA_SPRINT4_20260813.md`.

Alcance aplicado: cierre del núcleo formal restante de Sprint 4 con metadata real recuperada de Partial. Se trabajaron únicamente campos/picklists, Record Types de `Order`, y el Global Value Set determinable de marca. No se reabrieron Apex, Flows, LWC, Aura, Layouts ni Sprint 1/2/3.

Restricciones respetadas: no Salesforce, no deploy, no DML, no Production, no Apex, no Flows, no LWC reabiertos, no datos de catálogo inventados.

## 1. Campos/picklists oficiales

| # | Componente/API name | Estado | Valores/acción | Evidencia exacta |
|---:|---|---|---|---|
| 1 | `Quote.Compania__c` | HECHO | Se incorporó metadata fuente real y se agregó `PEKING` junto a `Bavarian`/`Otobai`. | `force-app/main/default/objects/Quote/fields/Compania__c.field-meta.xml` |
| 2 | `Quote.empresaFactura__c` | NO APLICA | NO EXISTE EN MODELO ACTUAL — NO CREAR SIN NECESIDAD FUNCIONAL DEMOSTRADA. | `FUENTES_METADATA_SPRINT4_20260813.md` confirma que en `Quote` no existe este campo ni variante cercana; `Quote.Compania__c` es el campo real. |
| 3 | `Opportunity.BMW_Compania__c` | NO APLICA | No se reintroduce PEKING en este picklist legacy porque la ruta vigente de Sprint 2 usa `Opportunity.Empresa_Operadora__c` como lookup/configuración. | Campo no está dentro del bloque nuevo de metadata recuperada; se conserva criterio de lookup Empresa. |
| 4 | `Opportunity.empresaQueFactura__c` | HECHO | Se incorporó metadata fuente real y se agregó `PEKING`, conservando el valor histórico `Otobay` tal como existe en la org. | `force-app/main/default/objects/Opportunity/fields/empresaQueFactura__c.field-meta.xml` |
| 5 | `Order.empresaQueFactura__c` | HECHO | Se incorporó metadata fuente real y se agregó `RMPEKING`, respetando que este campo usa códigos ERP (`RMBAVARIAN`, `RMOTOBAI`). | `force-app/main/default/objects/Order/fields/empresaQueFactura__c.field-meta.xml` |
| 6 | `WorkOrder.empresaFactura__c` | HECHO | Ya estaba completo en Git con `RMPEKING`; no se modificó. | `force-app/main/default/objects/WorkOrder/fields/empresaFactura__c.field-meta.xml` |
| 7 | `User.Empresa__c` | HECHO | Se incorporó metadata fuente real y se agregó `PEKING` junto a `Bavarian`/`Otobai`. | `force-app/main/default/objects/User/fields/Empresa__c.field-meta.xml` |
| 8 | `Product2.Empresa__c` | HECHO | Ya estaba completo en Git con `RMPEKING`; no se modificó. | `force-app/main/default/objects/Product2/fields/Empresa__c.field-meta.xml` |
| 9 | `CentroCosto__c.Empresa__c` | NO APLICA | NO EXISTE EN MODELO ACTUAL — NO CREAR SIN NECESIDAD FUNCIONAL DEMOSTRADA. | `FUENTES_METADATA_SPRINT4_20260813.md` confirma que `CentroCosto__c` no tiene campo de Empresa/Compañía; decisión vigente reutiliza centro de costo existente. |
| 10 | `TipoDeCargoConManoDeObra__c.Empresa__c` | HECHO | Ya estaba completo en Git con `RMPEKING`; no se modificó. | `force-app/main/default/objects/TipoDeCargoConManoDeObra__c/fields/Empresa__c.field-meta.xml` |
| 11 | `Linea_Plantilla_de_Presupuesto__c.Empresa__c` | HECHO | La metadata real confirmó que es picklist restringido, no lookup. Se agregó `RMPEKING`. | `force-app/main/default/objects/Linea_Plantilla_de_Presupuesto__c/fields/Empresa__c.field-meta.xml` |
| 12 | `ReciboUsado__c.Empresa__c` | HECHO | Se incorporó metadata fuente real y se agregó `RMPEKING`, respetando la convención de código ERP. | `force-app/main/default/objects/ReciboUsado__c/fields/Empresa__c.field-meta.xml` |
| 13 | `Plantilla_de_Presupuesto__c.BMW_Compania__c` | HECHO | La metadata real confirmó que es picklist restringido requerido, no lookup. Se agregó `PEKING`. | `force-app/main/default/objects/Plantilla_de_Presupuesto__c/fields/BMW_Compania__c.field-meta.xml` |

Campos modificados/incorporados en esta continuación:

- `Quote.Compania__c`: valor agregado `PEKING`.
- `Opportunity.empresaQueFactura__c`: valor agregado `PEKING`.
- `Order.empresaQueFactura__c`: valor agregado `RMPEKING`.
- `User.Empresa__c`: valor agregado `PEKING`.
- `ReciboUsado__c.Empresa__c`: valor agregado `RMPEKING`.
- `Linea_Plantilla_de_Presupuesto__c.Empresa__c`: valor agregado `RMPEKING`.
- `Plantilla_de_Presupuesto__c.BMW_Compania__c`: valor agregado `PEKING`.

## 2. Record Types

| Objeto | Estado | RT existentes/creados | Baseline usado | Evidencia exacta |
|---|---|---|---|---|
| `Opportunity` | HECHO | `Omoda`, `Jaecoo` ya existían y estaban activos. No se duplicaron. | No aplica. | `force-app/main/default/objects/Opportunity/recordTypes/Omoda.recordType-meta.xml`, `force-app/main/default/objects/Opportunity/recordTypes/Jaecoo.recordType-meta.xml` |
| `Lead` | HECHO | `Omoda`, `Jaecoo` ya existían y estaban activos. No se duplicaron. | No aplica. | `force-app/main/default/objects/Lead/recordTypes/Omoda.recordType-meta.xml`, `force-app/main/default/objects/Lead/recordTypes/Jaecoo.recordType-meta.xml` |
| Lead -> Opportunity | HECHO | Mapping `Lead_Omoda_to_Opp` y `Lead_Jaecoo_to_Opp` ya existía. | No aplica. | `force-app/main/default/customMetadata/RM_RecordTypeMapping.Lead_Omoda_to_Opp.md-meta.xml`, `force-app/main/default/customMetadata/RM_RecordTypeMapping.Lead_Jaecoo_to_Opp.md-meta.xml` |
| `Order` | HECHO | Se incorporó `BMW` como metadata fuente/baseline y se crearon `Omoda` y `Jaecoo`. | `Order.BMW`, único RT activo recuperado de Partial; sólo contiene `compactLayoutAssignment=Formato_Personalizado` y `Status=Aprobado/Draft`. | `force-app/main/default/objects/Order/recordTypes/BMW.recordType-meta.xml`, `Omoda.recordType-meta.xml`, `Jaecoo.recordType-meta.xml` |
| `Case` | BLOQUEADO | No se creó RT nuevo. | No existe Record Type de marca ni equivalente funcional único que replicar. | `FUENTES_METADATA_SPRINT4_20260813.md` lista 14 RT activos por función/tipo: `Autos`, `Autos_nuevos`, `Autos_usados`, `BMW_Service`, `Lifestyle_Autos`, `Lifestyle_Motos`, `Motos`, `Motos_nuevos`, `Motos_usados`, `Repuestos_autos`, `Repuestos_motos`, `Solicitudes_contabilidad_y_finanzas`, `Taller_de_Servicio_Autos`, `Taller_de_Servicio_Motos`. |

Detalle del bloqueo de `Case`:

BLOQUEADO — NO EXISTE RECORD TYPE DE MARCA/EQUIVALENTE FUNCIONAL ÚNICO QUE REPLICAR.

La metadata recuperada demuestra que `Case` está segmentado por función y tipo de vehículo, no por marca. Para OMODA/JAECOO lo técnicamente seguro es reutilizar la familia funcional `Autos*` existente hasta que negocio/arquitectura defina si realmente necesita Record Types de marca en `Case`.

## 3. Global Value Sets

| GVS/API name | Consumido por | Estado | Acción | Evidencia exacta |
|---|---|---|---|---|
| `Marca_de_Interes` | `Product2.Marca__c` | HECHO | Se incorporó metadata real y se agregaron `OMODA` y `JAECOO`. No se agregó `PEKING` porque este GVS representa marca, no empresa. | `force-app/main/default/globalValueSets/Marca_de_Interes.globalValueSet-meta.xml` |
| `Familia` | `Product2.Familia__c` | PENDIENTE DE CATÁLOGO | No se modificó. No hay familia OMODA/JAECOO derivable desde metadata/documentación sin inventar catálogo. | `FUENTES_METADATA_SPRINT4_20260813.md` confirma que el GVS real existe y no contiene OMODA/JAECOO; no hay valores aprobados para alta. |
| `Modelo_de_Interes2` | `Product2.Modelo_De_Inter_s__c` | PENDIENTE DE CATÁLOGO | No se modificó. No hay modelos OMODA/JAECOO derivables desde metadata/documentación sin inventar catálogo. | `FUENTES_METADATA_SPRINT4_20260813.md` confirma que el GVS real existe y no contiene OMODA/JAECOO; no hay valores aprobados para alta. |

GVS modificados:

- `Marca_de_Interes`: valores agregados `OMODA`, `JAECOO`.

GVS no modificados por restricción de no inventar catálogo:

- `Familia`.
- `Modelo_de_Interes2`.

No se creó un cuarto GVS ni se tocaron los GVS decoy `Marca`/`Modelo`.

## 4. LWC ya cerrados

No se rehicieron ni se volvieron a modificar los LWC cerrados previamente.

Se mantienen como cambios previos de Sprint 4:

- `rm_vn_crear_opp_general`
- `rm_vn_crear_opp_home`
- `rm_vn_crear_opp_home_movil`
- `rm_vn_crear_opp_inventario`
- `rm_vn_get_record_opp_record_types`

## 5. Archivos modificados/incorporados en esta continuación

Documentación:

- `docs/empresa-marcas-chinas/FUENTES_METADATA_SPRINT4_20260813.md`
- `docs/empresa-marcas-chinas/CIERRE_IMPLEMENTACION_SPRINT4_PEKING_20260813.md`

Campos/picklists:

- `force-app/main/default/objects/Quote/fields/Compania__c.field-meta.xml`
- `force-app/main/default/objects/Opportunity/fields/empresaQueFactura__c.field-meta.xml`
- `force-app/main/default/objects/Order/fields/empresaQueFactura__c.field-meta.xml`
- `force-app/main/default/objects/User/fields/Empresa__c.field-meta.xml`
- `force-app/main/default/objects/ReciboUsado__c/fields/Empresa__c.field-meta.xml`
- `force-app/main/default/objects/Linea_Plantilla_de_Presupuesto__c/fields/Empresa__c.field-meta.xml`
- `force-app/main/default/objects/Plantilla_de_Presupuesto__c/fields/BMW_Compania__c.field-meta.xml`

Record Types:

- `force-app/main/default/objects/Order/recordTypes/BMW.recordType-meta.xml`
- `force-app/main/default/objects/Order/recordTypes/Omoda.recordType-meta.xml`
- `force-app/main/default/objects/Order/recordTypes/Jaecoo.recordType-meta.xml`

Global Value Sets:

- `force-app/main/default/globalValueSets/Marca_de_Interes.globalValueSet-meta.xml`

## 6. Qué queda realmente pendiente

Pendiente de catálogo:

1. `Familia` (`Product2.Familia__c`): faltan valores de familia OMODA/JAECOO aprobados.
2. `Modelo_de_Interes2` (`Product2.Modelo_De_Inter_s__c`): faltan modelos OMODA/JAECOO aprobados.

Bloqueado:

1. `Case` Record Types OMODA/JAECOO: BLOQUEADO — NO EXISTE RECORD TYPE DE MARCA/EQUIVALENTE FUNCIONAL ÚNICO QUE REPLICAR.

No pendiente por definición de negocio en este bloque:

- bodega/territorio: datos QA provisionales;
- centro de costo: reutilizar existente;
- aprobadores: lógica existente por centro de costo;
- Pricebook default: dato de prueba;
- branding/razón social: prueba;
- garantía: validada sin cambio técnico.

## 7. Validaciones realizadas

- No Salesforce.
- No deploy.
- No DML.
- No Production.
- No Sprint 1/2/3.
- No Apex.
- No Flows.
- No LWC reabiertos.
- Se usó metadata fuente real recuperada en `93498803398cea70ce62793f2ce7e1f4e991ccd8`.
- Se respetó la convención real por campo: `PEKING` para picklists comerciales y `RMPEKING` para picklists que usan código ERP.
- Se validó que `Opportunity`/`Lead` ya tenían `Omoda`/`Jaecoo` y no se duplicaron.
- Se creó `Order.Omoda` y `Order.Jaecoo` únicamente copiando el baseline real `Order.BMW`.
- Se dejó `Case` bloqueado por falta de RT de marca/equivalente único.
- Se dejó `Familia` y `Modelo_de_Interes2` como pendiente de catálogo, sin inventar valores.

## 8. Dictamen

Sprint 4 queda implementado en Git en todo lo técnicamente determinable con la metadata real disponible.

El paquete está listo para que el equipo integre, despliegue y haga QA en Partial. Lo único que no queda cerrado por Git es lo que requiere catálogo real (`Familia`, `Modelo_de_Interes2`) o decisión de arquitectura/negocio (`Case` Record Types por marca vs reutilización funcional de `Autos*`).
