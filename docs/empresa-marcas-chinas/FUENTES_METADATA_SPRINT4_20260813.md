# Fuentes de metadata — Sprint 4 (retrieve dirigido)

**Fecha:** 13 de agosto de 2026

**Naturaleza:** retrieve de metadata fuente únicamente. No implementación, no cambio de valores, no deploy, no DML, no Production.

**Origen:** RedMotorsSandbox.

**Objetivo:** dejar en Git la metadata real que el Codex de Luis necesita para trabajar Sprint 4 (OMODA/JAECOO), sin interpretar ni resolver los gaps encontrados.

## 1. Campos recuperados

| Campo solicitado | Existe en org | Tipo | Valores actuales | Notas |
|---|---|---|---|---|
| `Quote.Compania__c` | Sí | Picklist restringido | `Bavarian`, `Otobai` | Sin PEKING/OMODA/JAECOO. |
| `Quote.empresaFactura__c` | **No existe** | — | — | Verificado por describe completo del objeto `Quote`; no hay ningún campo con ese nombre ni variante cercana (`Compania__c` es el único campo de empresa/compañía en `Quote`). |
| `Opportunity.empresaQueFactura__c` | Sí | Picklist restringido | `Otobay` (sic, así está escrito en el org), `Bavarian` | Sin PEKING/OMODA/JAECOO. |
| `Order.empresaQueFactura__c` | Sí | Picklist restringido | `RMOTOBAI` (label Otobai), `RMBAVARIAN` (label Bavarian) | Usa códigos ERP como `fullName`, a diferencia de `Opportunity.empresaQueFactura__c` que usa el nombre comercial. Inconsistencia de convención entre objetos. |
| `User.Empresa__c` | Sí | Picklist restringido | `Bavarian`, `Otobai` | Sin PEKING/OMODA/JAECOO. |
| `CentroCosto__c.Empresa__c` | **No existe** | — | — | Verificado por describe completo del objeto `CentroCosto__c` (18 campos totales); ningún campo contiene "Empresa" ni "Compania" en el nombre. |
| `ReciboUsado__c.Empresa__c` | Sí | Picklist restringido | `RMBAVARIAN`, `RMOTOBAI` | Sin PEKING/OMODA/JAECOO. |
| `Linea_Plantilla_de_Presupuesto__c.Empresa__c` | Sí | **Picklist restringido** (no lookup) | `RMBAVARIAN` (label Bavarian), `RMOTOBAI` (label Otobai) | La reconciliación de Sprint 3 lo daba por "NO APLICA por lookup Empresa"; la metadata real confirma que **no es un lookup**, es un picklist restringido igual que el resto. |
| `Plantilla_de_Presupuesto__c.BMW_Compania__c` | Sí | **Picklist restringido**, `required=true` (no lookup) | `Otobai`, `Bavarian` | Misma corrección de premisa que el campo anterior: no es un lookup a `Empresa__c`. |

Archivos retrieved (7 campos existentes): `force-app/main/default/objects/{Quote,Opportunity,Order,User,ReciboUsado__c,Linea_Plantilla_de_Presupuesto__c,Plantilla_de_Presupuesto__c}/fields/...field-meta.xml`.

## 2. Order — Record Types actuales

| API Name | Label | Activo |
|---|---|---|
| `BMW` | BMW | Sí |

**Es el único Record Type de `Order` en el org.** No existen variantes por marca (no hay `Otobai`, `Bavarian`, ni ningún otro). El propio RT no contiene ninguna referencia a Empresa/Compañía en su metadata (solo restringe valores del picklist `Status`: `Aprobado`, `Draft`). Patrón a reutilizar para OMODA/JAECOO: **el mismo RT genérico `BMW`**, no uno nuevo por marca — salvo que Luis/Diego definan lo contrario.

Archivo: `force-app/main/default/objects/Order/recordTypes/BMW.recordType-meta.xml`.

## 3. Case — Record Types actuales

| API Name | Label | Activo |
|---|---|---|
| `Autos` | Autos | Sí |
| `Autos_nuevos` | Autos nuevos | Sí |
| `Autos_usados` | Autos usados | Sí |
| `BMW_Service` | BMW Service | Sí |
| `Lifestyle_Autos` | Lifestyle Autos | Sí |
| `Lifestyle_Motos` | Lifestyle Motos | Sí |
| `Motos` | Motos | Sí |
| `Motos_nuevos` | Motos nuevos | Sí |
| `Motos_usados` | Motos usados | Sí |
| `Repuestos_autos` | Repuestos autos | Sí |
| `Repuestos_motos` | Repuestos motos | Sí |
| `Solicitudes_contabilidad_y_finanzas` | Solicitudes contabilidad y finanzas | Sí |
| `Taller_de_Servicio_Autos` | Taller de Servicio Autos | Sí |
| `Taller_de_Servicio_Motos` | Taller de Servicio Motos | Sí |

14 Record Types, todos activos. Están segmentados por **tipo de vehículo y función** (Autos/Motos × nuevos/usados/taller/repuestos/lifestyle), no por marca — no existe `Bavarian`/`Otobai`-named Case RT. El RT `Autos` (inspeccionado en detalle) no contiene ninguna referencia a Empresa/Compañía; solo restringe picklists estándar (`Origin`, `Priority`, `Reason`, `Type`). Dado que OMODA/JAECOO son marcas de autos, el patrón a reutilizar es la familia `Autos*` existente, no uno nuevo.

Archivos: `force-app/main/default/objects/Case/recordTypes/*.recordType-meta.xml` (14 archivos).

## 4. Global Value Sets — los 3 reales, confirmados por consumo de campo

La búsqueda por nombre literal ("Marca", "Modelo") **no identifica los GVS realmente activos**. Se trazó el consumo real siguiendo los campos picklist del objeto `Product2` (el catálogo de vehículos):

| GVS real (API Name) | Consumido por | # Valores | OMODA/JAECOO presentes |
|---|---|---|---|
| `Marca_de_Interes` | `Product2.Marca__c` | 37 | **No** |
| `Familia` | `Product2.Familia__c` (controlado por `Product2.Grupo__c`) | 188 | **No** |
| `Modelo_de_Interes2` | `Product2.Modelo_De_Inter_s__c` (controlado por `Product2.Familia__c`) | 765 | **No** |

Cadena de dependencia confirmada en `Product2`: `Categor_a_veh_culo__c` → `Grupo__c` (GVS `Categor_a`) → `Familia__c` (GVS `Familia`) → `Modelo_De_Inter_s__c` (GVS `Modelo_de_Interes2`). `Marca__c` (GVS `Marca_de_Interes`) no está encadenado como campo controlador de `Familia__c` — es independiente en la metadata revisada.

**Nota sobre nombres decoy:** existen además los GVS literalmente llamados `Marca` (5 valores: BMW, MINI, KAWASAKI, POLARIS, BMW MOTO) y `Modelo` (844 valores, nomenclatura de modelos BMW). Se retrieved ambos para descartarlos con evidencia, pero **no se encontró ningún campo picklist en `Product2` que los consuma** — no se los puede confirmar como activos para el catálogo. Se dejan versionados en Git por transparencia, no como parte de los "3 GVS reales" del punto 4.

Archivos: `force-app/main/default/globalValueSets/{Marca_de_Interes,Familia,Modelo_de_Interes2,Marca,Modelo}.globalValueSet-meta.xml`.

## 5. Qué falta realmente para Sprint 4

- Ninguno de los 3 GVS reales (`Marca_de_Interes`, `Familia`, `Modelo_de_Interes2`) tiene valores de OMODA ni JAECOO — el catálogo de vehículos no puede representar estas marcas hasta que se agreguen.
- `Quote.empresaFactura__c` y `CentroCosto__c.Empresa__c` **no existen** en el org — cualquier trabajo de Sprint 4 que asuma su existencia necesita replantearse contra los campos reales (`Quote.Compania__c` es el único de empresa en `Quote`; `CentroCosto__c` no tiene ningún campo de empresa/compañía).
- Todos los picklists de empresa/compañía revisados (`Quote.Compania__c`, `Opportunity.empresaQueFactura__c`, `Order.empresaQueFactura__c`, `User.Empresa__c`, `ReciboUsado__c.Empresa__c`, `Linea_Plantilla_de_Presupuesto__c.Empresa__c`, `Plantilla_de_Presupuesto__c.BMW_Compania__c`) están restringidos a `Bavarian`/`Otobai` únicamente — ninguno tiene PEKING ni OMODA/JAECOO.
- `Order` tiene un único Record Type genérico (`BMW`); `Case` tiene 14 Record Types por tipo de vehículo/función, ninguno por marca. No hay un "patrón por marca" ya existente que clonar — la reutilización parece ser del RT genérico, pendiente de confirmación de Luis/Diego.

## 6. Dependencias técnicas demostradas

- **Inconsistencia de convención de picklist:** el mismo concepto (Otobai) aparece como `fullName` de 3 formas distintas según el objeto: `"Otobai"` (`Quote.Compania__c`, `User.Empresa__c`), `"Otobay"` (`Opportunity.empresaQueFactura__c`, con error tipográfico), y `"RMOTOBAI"` (`Order.empresaQueFactura__c`, `ReciboUsado__c.Empresa__c`, `Linea_Plantilla_de_Presupuesto__c.Empresa__c`). Cualquier automatización de Sprint 4 que compare estos valores entre objetos debe considerar esta inconsistencia.
- **Premisa incorrecta en la reconciliación de Sprint 3:** `Linea_Plantilla_de_Presupuesto__c.Empresa__c` y `Plantilla_de_Presupuesto__c.BMW_Compania__c` se habían clasificado como "NO APLICA por lookup Empresa". La metadata real confirma que **ambos son picklists restringidos**, no lookups — no hay lookup a `Empresa__c` object en ninguno de los dos.
- **Cascada de catálogo confirmada:** `Product2` encadena Categoría → Grupo → Familia → Modelo de Interés, cada nivel controlado por el anterior vía `controllingField`/`controllingFieldValue`. Cualquier alta de OMODA/JAECOO en el catálogo debe respetar esta cascada completa (los 3 GVS reales), no solo agregar valores sueltos.

## 7. Archivos recuperados (todos vía `sf project retrieve start`, sin deploy)

- 7 campos de empresa/compañía (sección 1) + sus `.object-meta.xml` mínimos generados como efecto colateral del retrieve.
- 3 campos adicionales de `Product2` usados para trazar el consumo real de GVS: `Marca__c`, `Familia__c`, `Grupo__c`, `Modelo_De_Inter_s__c`.
- 1 Record Type de `Order` (`BMW`) + su `.object-meta.xml`.
- 14 Record Types de `Case` + su `.object-meta.xml`.
- 5 Global Value Sets: `Marca_de_Interes`, `Familia`, `Modelo_de_Interes2` (los 3 reales) + `Marca`, `Modelo` (descartados con evidencia, versionados por transparencia).

No se modificó ningún valor. No se ejecutó deploy. No se ejecutó DML. Producción no fue tocada.
