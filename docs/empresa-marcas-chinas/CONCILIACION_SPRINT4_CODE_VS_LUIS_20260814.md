# RedMotors / PEKING — Conciliación dirigida Sprint 4: Code vs. Luis/Codex

**Fecha:** 14 de agosto de 2026

**Naturaleza:** conciliación READ-ONLY. No se implementó, no se hizo deploy, no se hizo DML, no se modificó Salesforce, no se hizo cherry-pick ni merge.

**Fuentes usadas:**
1. Documento oficial de alcance: `DEV - Evaluación - Alcance - Inclusión de nueva Empresa- Marcas chinas Redmotors.docx.pdf`.
2. `docs/empresa-marcas-chinas/FUENTES_METADATA_SPRINT4_20260813.md` (nuestra metadata real, commit `9349880`).
3. `docs/empresa-marcas-chinas/CIERRE_IMPLEMENTACION_SPRINT4_PEKING_20260813.md` (nuestro cierre, commits `2765d2a`/`0ce0af7`).
4. `feature/luis/peking-sprint4-implementacion-20260813`, HEAD `c0736f5644eedc6e7778b497f2bb50588fa213fb`.
5. RedMotorsSandbox — solo consultas de lectura (`sf sobject describe`, grep de código versionado).

## 1. Order Record Types — conclusión y evidencia

**Conclusión: INTEGRAR `Order.Omoda` + `Order.Jaecoo`.**

Evidencia:

- **A. Qué exige el alcance oficial:** la tabla 2 del documento oficial dice literalmente sobre `Order`: *"Solo BMW | Falta incluso replicar para Otobai; hay que sumar las marcas nuevas"*. El propio documento oficial clasifica el estado actual de `Order` (un único RT `BMW` compartido) como una **falta/gap preexistente**, no como un diseño agnóstico intencional. La sección "Nuevos Record Types de Opportunity + réplicas Lead/Order/Case" confirma que Order está dentro del alcance de replicación de marca, igual que Lead.
- **B. Cómo se usa `Order.BMW` hoy:** es el único Record Type de `Order` en el org (confirmado por SOQL `RecordType` en el retrieve de `9349880`). Su XML no contiene ninguna condición de Empresa/Compañía — solo restringe el picklist `Status` (`Aprobado`/`Draft`) vía `compactLayoutAssignment: Formato_Personalizado`.
- **C. Picklists/configuración que contiene:** ninguna referencia a Empresa/Compañía; solo el picklist estándar `Status`.
- **D. Dependencias por RecordType DeveloperName/Id/Name:** se buscó en Apex (`grep` de `RecordType` + `Order` en `force-app/main/default/classes`) y en Flows (`<object>Order</object>` cruzado con `RecordType`). **No se encontró ninguna dependencia real** que lea o filtre por `Order.RecordType.DeveloperName = 'BMW'` — los únicos matches de "RecordType" + "Order" encontrados correspondían a `Task.RecordType` (`popUpBloqueClass.cls`) y a `Account.RecordType` dentro de `AbrirCerrarOrden.flow-meta.xml` (`GetCuentaFacturaci_n.RecordType.Name`), ninguno relacionado con el objeto `Order` en sí. Crear los 2 RT nuevos es una operación aditiva sin riesgo de romper lógica existente.
- **E. ¿OMODA/JAECOO necesitan RT propio aunque BMW sea técnicamente compartido?** Sí, según el alcance oficial (punto A) — el hecho de que `Order.BMW` sea técnicamente compartido hoy es precisamente el gap que el documento pide cerrar, no una razón para omitir los RT nuevos.

Los archivos de Luis (`2ce78ae`, `58559ac`) son clones mínimos y correctos de `Order.BMW`: mismo `compactLayoutAssignment`, mismas restricciones de `Status`, solo cambia `fullName`/`label`. No inventan lógica adicional — cumplen "replicar únicamente su configuración necesaria".

**Nota de autocrítica:** nuestra conclusión previa en `CIERRE_IMPLEMENTACION_SPRINT4_PEKING_20260813.md` ("Order: NO APLICA — el único RT ya es agnóstico y compartido") se basó únicamente en el estado actual observado, sin cruzar contra el documento oficial de alcance, que clasifica ese mismo estado como un gap pendiente. Queda corregida por esta conciliación.

## 2. Los 7 picklists — matriz de decisión

| Campo | En alcance oficial | Consumo activo demostrado | Valor PEKING faltante | Recomendación |
|---|---|---|---|---|
| `Quote.Compania__c` | Sí (tabla 1, fila 1: "Agregar nueva") | **Sí** — `CrearPlandeVenta.cls:201` escribe `newQuote.Compania__c = nombreCompania` ("Sincronizado con la Oportunidad"). | Sí | **INTEGRAR** — convención display-name (`PEKING`, igual que `Bavarian`/`Otobai`). Coincide con la implementación de Luis. |
| `Opportunity.empresaQueFactura__c` | Sí (tabla 1, fila 4: "Corregir typo + agregar nueva") | **Sí** — `http_Helper.cls:57` lo lee; `Opportunity_Flow_V2` lo asigna (línea 1735); `ReenviarEncuesta`/`ReenviarEncuestaOpp` lo leen; FLS habilitado en `Vehiculos_Nuevos_PS.permissionset-meta.xml`. | Sí | **INTEGRAR** valor (convención display-name `PEKING`) — **con alerta crítica**, ver sección 3. El typo `Otobay` que pide corregir el documento oficial **no fue corregido** por Luis (se dejó igual). |
| `Order.empresaQueFactura__c` | Sí (tabla 1, fila 5) | **Sí, alto** — `cls_DMLHelper.cls` (SOQL + DML), `doCalloutCancelarPedidoSoftland.cls` (parámetro directo de 2 callouts a Softland: `getGetStatusOrderCallout`/`getCancelOrderCallout`), `orderJSONData.cls` (`vOrder.compania`, payload JSON hacia el ERP). | Sí | **INTEGRAR** — prioridad alta, es la fuente directa de la integración ERP de Orders. Convención RM-prefijo (`RMPEKING`) confirmada correcta contra `RMOTOBAI`/`RMBAVARIAN` existentes. |
| `User.Empresa__c` | Sí (tabla 1, fila 7) | **Sí** — `Opportunity_Flow_V2`, `Opp_flow_V3`/`v4`/`V5`/`v6` (default vía `$User.Empresa__c`/`GetUser.Empresa__c`), `aperturaCaseWorOrderEvent` (fallback: `IF(ISBLANK(ServiceTerritory__r.Empresa__c), TEXT($User.Empresa__c), "")`). | Sí | **INTEGRAR** — convención display-name (`PEKING`). Coincide con Luis. |
| `ReciboUsado__c.Empresa__c` | Sí, listado en tabla 1 | Sí, pero **exclusivamente en flujos de usados** (`ReciboUsadosFlow`, `Alerta_Asesor_Recibo_Usado`, 6 flows de `Enviar_correo_Formalizacion*`, `Opportunity_Product_en_Recibo_de_Usados`, `Reenviar_formalizacion` — 10 flows en total). | Sí (técnicamente) | **NO INTEGRAR / NO APLICA POR ALCANCE DE NEGOCIO** — el consumo real es 100% de vehículos usados, y el alcance autorizado de PEKING/Omoda/Jaecoo en este Sprint es Venta Nueva. Integrar este valor sin autorización de negocio para usados excede el alcance vigente. |
| `Linea_Plantilla_de_Presupuesto__c.Empresa__c` | Sí, listado en tabla 1 | **No confirmado a nivel de campo** — el objeto aparece referenciado en 6 flows (`Actualiza_Alias_linea_de_plantilla`, `BMW_ImportarPlantilla`, `BMW_Importar_Plantilla_Orden_de_Trabajo`, `Obtener_PricebookEntry_en_Linea_de_Plantilla_de_Presupuesto`, `Opportunity_Flow`, `Opportunity_Flow_V2`), pero no se encontró ningún filtro/condición que use específicamente el campo `Empresa__c` de esta línea en ninguno de los tres flows inspeccionados en detalle. | Sí (técnicamente) | **NO INTEGRAR / NO APLICA** — sin evidencia de consumo activo del campo específico (distinto del objeto en general). Si se detecta uso real más adelante, requiere una pasada adicional dirigida antes de reabrir esta decisión. |
| `Plantilla_de_Presupuesto__c.BMW_Compania__c` | Sí (tabla 1, fila explícita: "usado por flows de importar plantilla") | **Sí, confirmado — hallazgo nuevo de esta conciliación.** `Opportunity_Flow_V2`, paso `BMW_ObtenerPlantillas` (línea ~2343), filtra `Plantilla_de_Presupuesto__c.BMW_Compania__c EqualTo BMW_ObtenerPresupuesto.Opportunity.BMW_Compania__c`. Este es un camino de selección de plantillas **distinto** del que ya corregimos en Sprint 3 (`Quote.BMW_ImportarPlantilla`, que usa `Empresa_Operadora__c`) — `Opportunity_Flow_V2` todavía depende del picklist legacy para este paso interno. | Sí | **INTEGRAR** — convención display-name (`PEKING`). Corrige la clasificación previa de Luis en `b0fc34c` ("NO APLICA POR LOOKUP EMPRESA"), que no había detectado este consumidor. Nota: agregar el valor de picklist no basta por sí solo — no existen registros reales de `Plantilla_de_Presupuesto__c` con `BMW_Compania__c = 'PEKING'` (mismo tipo de gap de catálogo ya documentado para los GVS `Familia`/`Modelo_de_Interes2` en el cierre de Sprint 4). |

## 3. Convención de valores — verificación por campo

No se normalizó ni corrigió ninguna convención. Por campo, la convención real usada por su(s) componente(s) consumidor(es):

| Campo | Convención real | Evidencia |
|---|---|---|
| `Quote.Compania__c` | Nombre visible (`Bavarian`, `Otobai`) | `CrearPlandeVenta.cls` asigna directamente el string sin traducción a código ERP. |
| `Opportunity.empresaQueFactura__c` | Nombre visible (`Bavarian`, `Otobay`) | `http_Helper.cls:57` compara contra el literal `'Bavarian'`, no contra un código `RM*`. |
| `Order.empresaQueFactura__c` | Código ERP con prefijo `RM` (`RMOTOBAI`, `RMBAVARIAN`) | `orderJSONData.cls`/`doCalloutCancelarPedidoSoftland.cls` pasan el valor tal cual a los endpoints de Softland, que esperan códigos `RM*`. |
| `User.Empresa__c` | Nombre visible (`Bavarian`, `Otobai`) | Los Flows lo usan como sugerencia de Empresa para resolver Pricebook/territorio, no como código ERP. |
| `Plantilla_de_Presupuesto__c.BMW_Compania__c` | Nombre visible (`Bavarian`, `Otobai`) | El filtro en `Opportunity_Flow_V2` lo compara directamente contra `Opportunity.BMW_Compania__c` (también nombre visible). |

Los 5 valores que Luis agregó (`PEKING` para los de nombre visible, `RMPEKING` para `Order.empresaQueFactura__c`) respetan exactamente la convención real de cada campo — no se detectó ningún caso de convención incorrecta.

## 4. Archivos de `c0736f5` recomendados para integrar

- `force-app/main/default/objects/Order/recordTypes/Omoda.recordType-meta.xml` (commit `2ce78ae`)
- `force-app/main/default/objects/Order/recordTypes/Jaecoo.recordType-meta.xml` (commit `58559ac`)
- `force-app/main/default/objects/Quote/fields/Compania__c.field-meta.xml` (commit `2055175`) — agrega `PEKING`
- `force-app/main/default/objects/Opportunity/fields/empresaQueFactura__c.field-meta.xml` (commit `d73e1f6`) — agrega `PEKING`
- `force-app/main/default/objects/Order/fields/empresaQueFactura__c.field-meta.xml` (commit `2719b47`) — agrega `RMPEKING`
- `force-app/main/default/objects/User/fields/Empresa__c.field-meta.xml` (commit `f142949`) — agrega `PEKING`
- `force-app/main/default/objects/Plantilla_de_Presupuesto__c/fields/BMW_Compania__c.field-meta.xml` (commit `5b78946`) — agrega `PEKING`

`force-app/main/default/objects/Order/recordTypes/BMW.recordType-meta.xml` (commit `bb24827`) no necesita traerse: ya existe, byte-idéntico, en nuestro commit `9349880`.

## 5. Archivos de `c0736f5` a NO integrar

- `force-app/main/default/objects/ReciboUsado__c/fields/Empresa__c.field-meta.xml` (commit `12193e7`) — fuera de alcance de negocio (usados no autorizado para PEKING en este Sprint).
- `force-app/main/default/objects/Linea_Plantilla_de_Presupuesto__c/fields/Empresa__c.field-meta.xml` (commit `d88edda`) — sin evidencia de consumo activo del campo.
- `force-app/main/default/globalValueSets/Marca_de_Interes.globalValueSet-meta.xml` (commit `c630523`) — comparado byte a byte contra nuestro archivo ya desplegado: **funcionalmente idéntico** (39 `customValue`, mismos `OMODA`/`JAECOO`, solo cambia el orden de inserción dentro del archivo). Ya cerrado en `0ce0af7` y desplegado (`0AfAK0000014p8D0AQ`); traerlo sería redundante.
- `docs/empresa-marcas-chinas/FUENTES_METADATA_SPRINT4_20260813.md` (commit `bba6338`) — superado por nuestra propia versión, que además identifica los 3 GVS reales por consumo de campo (no solo por nombre) y documenta 2 GVS decoy descartados con evidencia.
- `docs/empresa-marcas-chinas/CIERRE_IMPLEMENTACION_SPRINT4_PEKING_20260813.md` en cualquiera de sus versiones (`4b1b623`, `b0fc34c`, `c0736f5`) — superado por nuestra propia versión con evidencia real de Salesforce (Luis/Codex trabajó sin acceso al org en esas iteraciones).
- Los 5 LWC de `4b1b623` — ya integrados en nuestro commit `2765d2a`.

## 6. Qué coincide entre ambas implementaciones

- `WorkOrder.empresaFactura__c`, `Product2.Empresa__c`, `TipoDeCargoConManoDeObra__c.Empresa__c` ya tienen `RMPEKING` en Git — ambas partes lo confirmaron y ninguna lo modificó.
- `Opportunity.Omoda`/`Jaecoo` y `Lead.Omoda`/`Jaecoo` (Record Types) y sus mappings `RM_RecordTypeMapping` ya existen — ambas partes coinciden en no tocarlos.
- Ambas identificaron independientemente `Marca_de_Interes` (no el GVS literal `Marca`) como el GVS real de marca, y ambas agregaron `OMODA`/`JAECOO` con el mismo formato — convergencia total, sin necesidad de reconciliar contenido.
- Ambas dejaron `Familia` y `Modelo_de_Interes2` sin tocar por falta de datos fuente de catálogo.
- Ninguna de las dos creó Record Types de marca para `Case` — ambas coinciden (aunque por razones distintas: Luis por falta de acceso a Salesforce para retrieve, nosotros por falta de un patrón funcional único que replicar).
- `Quote.empresaFactura__c` y `CentroCosto__c.Empresa__c`: ambas partes confirman que no existen en el modelo actual y ninguna los creó.

## 7. Bloqueos reales que quedan

- **`http_Helper.cls:57`** — bug binario real y demostrado (`actualOpp.empresaQueFactura__c == 'Bavarian' ? 'RMBAVARIAN' : 'RMOTOBAI'`). Agregar `PEKING` al picklist de `Opportunity.empresaQueFactura__c` **no corrige este bug**: cualquier Opportunity PEKING seguirá enrutándose silenciosamente a `RMOTOBAI` en el JSON de Order hacia Softland. Requiere autorización explícita de cambio Apex (`else if`), fuera del alcance de este bloque read-only.
- **Typo `Otobay`** en `Opportunity.empresaQueFactura__c`: el documento oficial pide corregirlo explícitamente ("Corregir typo + agregar nueva"); ni Luis ni nosotros lo hemos corregido. Pendiente de autorización.
- **`Plantilla_de_Presupuesto__c` sin registros PEKING**: aun integrando `BMW_Compania__c = 'PEKING'` en el picklist, `Opportunity_Flow_V2` no encontrará plantillas reales hasta que existan registros de `Plantilla_de_Presupuesto__c` etiquetados para PEKING — mismo patrón de "PENDIENTE DE CATÁLOGO" ya documentado para las familias/modelos.
- **`Case` Record Types**: sigue sin equivalente funcional único de marca que replicar (confirmado en el cierre anterior, sin cambios en esta conciliación).
- **`rm_vn_crear_opp_inventario`**: sigue bloqueado por la dependencia Apex preexistente `RM_VN_CrearOportunidad_Ctrl.getProducts` (sin cambios en esta conciliación).

## Recomendación exacta del siguiente paso

Con autorización explícita, el siguiente bloque de implementación debería:

1. Traer los 7 archivos listados en la sección 4 (2 Record Types de `Order` + 5 campos con su valor `PEKING`/`RMPEKING` agregado), respetando exactamente el mismo alcance y convención ya verificados aquí — sin tocar `ReciboUsado__c.Empresa__c` ni `Linea_Plantilla_de_Presupuesto__c.Empresa__c`.
2. Dry-run + deploy a RedMotorsSandbox únicamente.
3. Dejar documentado, sin implementar, el bug de `http_Helper.cls:57` y el typo `Otobay` como un punto de decisión separado para Luis/Diego (requiere autorización de cambio Apex, no es un simple valor de picklist).
4. Dejar documentado que `Plantilla_de_Presupuesto__c` con `BMW_Compania__c = 'PEKING'` seguirá sin devolver resultados en `Opportunity_Flow_V2` hasta que existan registros de plantilla reales para PEKING (dato de catálogo, no de metadata).
