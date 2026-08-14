# Conciliación List Views, Permisos y Postventa PEKING

Fecha: 2026-08-14

Rama base autoritativa: `feature/pc/redmotors-empresa-marcas-chinas-sprint2-flows-components-20260728`

Base SHA usado: `0ce0af7c820efafff51b26363c86c6521e866199`

Rama de trabajo: `feature/luis/peking-listviews-permissions-postventa-20260814`

Restricción aplicada: solo Git/documentación. No se ejecutó deploy, no DML, no consulta/modificación en Salesforce y no se tocó Production.

Nota de fuente: el checkout local no tiene `.git` utilizable para estado/commit, por lo que la rama y el archivo se prepararon contra GitHub remoto. La revisión de contenido se hizo contra la rama base indicada.

## Resumen ejecutivo

No implementé cambios funcionales porque los gaps reales de este bloque no cumplen todas las condiciones de implementación segura en Git: faltan List Views nominales no versionadas, faltan Lightning/FlexiPages de WorkOrder/Case, y los permisos productivos requieren saber qué perfiles/permission sets se asignarán a usuarios reales. Sí queda una matriz ejecutable para que Code recupere únicamente la metadata faltante y cierre con cambios concretos.

Resultado corto:

| Bloque | Estado | Decisión |
| --- | --- | --- |
| Opportunity List Views Omoda/Jaecoo | HECHO | Ya existen 8 vistas nominales por Record Type. No tocar. |
| List Views Lead/Quote/Order/WorkOrder/Case/Product2 | METADATA NO DISPONIBLE | Recuperar desde Partial antes de decidir variantes. No inventar. |
| Permission Sets Empresa/Venta Nueva QA | PARCIAL | Existen permisos útiles, pero varios son temporales QA y no son solución productiva. |
| Profiles productivos | METADATA DISPONIBLE PARCIAL / REQUIERE DECISIÓN DE ASIGNACIÓN | No modificar masivamente sin matriz de perfiles destino. |
| WorkOrder empresa lookup | HECHO/PARCIAL | Campo `empresaFacturaCP__c` existe y varios flows ya lo propagan; falta asegurar permisos productivos y datos PEKING. |
| Citas/Field Service | ADICIONAL / CONDICIONADO A DATOS | Funciona por calendarios/territorios; si se pide separación por Empresa formal es trabajo extra. |
| Trabajos / mano de obra | PARCIAL | PEKING está permitido en código, pero depende de datos `TipoDeCargoConManoDeObra__c`, productos y PBEs. Migrar catálogo a lookup es extra. |

## A. LIST VIEWS

| OBJETO | API NAME | ESTADO | CAMBIO REQUERIDO | MOTIVO |
| --- | --- | --- | --- | --- |
| Opportunity | `Oportunidades_abiertas_Omoda` | HECHO | Ninguno. No tocar. | Metadata versionada. Filtro por `OPPORTUNITY.RECORDTYPE = Opportunity.Omoda` y `STAGE_NAME != Cerrada Ganada,Cerrada Perdida`; `filterScope=Mine`; compartida con `Asesor_de_Ventas_BMW_y_Nuevos_V2` y `Asesor_de_Ventas_Online_BMW_y_Nuevos_V2`. |
| Opportunity | `Oportunidades_abiertas_Jaecoo` | HECHO | Ninguno. No tocar. | Metadata versionada. Filtro equivalente por `Opportunity.Jaecoo`; compartida con los mismos grupos de Venta Nueva. |
| Opportunity | `Oportunidades_ganadas_Omoda` | HECHO | Ninguno. No tocar. | Metadata versionada. `filterScope=Everything`; filtros `StageName = Cerrada Ganada` y `RecordType = Opportunity.Omoda`. |
| Opportunity | `Oportunidades_ganadas_Jaecoo` | HECHO | Ninguno. No tocar. | Metadata versionada. `filterScope=Everything`; filtros `StageName = Cerrada Ganada` y `RecordType = Opportunity.Jaecoo`. |
| Opportunity | `Oportunidades_Perdidas_Omoda` | HECHO | Ninguno. No tocar. | Metadata versionada. `filterScope=Mine`; filtros `StageName = Cerrada Perdida`, `RecordType = Opportunity.Omoda`, `CreatedDate > 1/1/2025 12:00 AM`. |
| Opportunity | `Oportunidades_Perdidas_Jaecoo` | HECHO | Ninguno. No tocar. | Metadata versionada. `filterScope=Mine`; filtros equivalentes para `Opportunity.Jaecoo`. |
| Opportunity | `Todas_Oportunidades_Perdidas_Omoda` | HECHO CON OBSERVACIÓN | Validar sharing en QA, no modificar sin decisión. | Metadata versionada. `filterScope=Team`; filtros correctos para Omoda. El XML no trae `sharedTo`, por lo que conviene validar visibilidad real antes de Producción. |
| Opportunity | `Todas_Oportunidades_Perdidas_Jaecoo` | HECHO CON OBSERVACIÓN | Validar sharing en QA, no modificar sin decisión. | Metadata versionada. `filterScope=Team`; filtros correctos para Jaecoo. El XML no trae `sharedTo`, por lo que conviene validar visibilidad real antes de Producción. |
| Lead | `Lead.*` | METADATA NO DISPONIBLE | Recuperar List Views desde Partial. | En Git no existe `force-app/main/default/objects/Lead/listViews`. No se puede listar nominalmente sin retrieve. |
| Quote | `Quote.*` | METADATA NO DISPONIBLE | Recuperar List Views desde Partial. | En Git no existe `force-app/main/default/objects/Quote/listViews`. No inventar variantes. |
| Order | `Order.*` | METADATA NO DISPONIBLE | Recuperar List Views desde Partial. | En Git no existe `force-app/main/default/objects/Order/listViews`. No mezclar con RT de Sprint 4. |
| WorkOrder | `WorkOrder.*` | METADATA NO DISPONIBLE | Recuperar List Views desde Partial. | En Git no existe `force-app/main/default/objects/WorkOrder/listViews`. Necesario para taller/postventa. |
| Case | `Case.*` | METADATA NO DISPONIBLE | Recuperar List Views desde Partial. | En Git no existe `force-app/main/default/objects/Case/listViews`. Necesario si hay vistas de casos/taller por sucursal/empresa. |
| Product2 / inventario | `Product2.*` | METADATA NO DISPONIBLE | Recuperar List Views desde Partial. | En Git no existe `force-app/main/default/objects/Product2/listViews`. No se puede confirmar si inventario queda visible automáticamente por Pricebook/Empresa. |

Conclusión List Views: lo único nominalmente HECHO en Git son las 8 vistas de Opportunity para Omoda/Jaecoo. Cualquier otra vista del estimado oficial requiere retrieve previo; no hay base segura para crear o modificar List Views desde Git en este bloque.

## B. PROFILES / PERMISSION SETS

| PERFIL/PS | COMPONENTE | ACCESO ACTUAL | CAMBIO | ESTADO |
| --- | --- | --- | --- | --- |
| `Empresa_Admin` | `Empresa__c`, `Pricebook2.Empresa__c`, `ServiceTerritory.Empresa__c`, `EmpresaContext`, `EmpresaResolver`, `EmpresaPricebookResolver` | Acceso de administración completo: `Empresa__c` create/read/edit; campos `Activa__c`, `Codigo_ERP__c`, `Nombre_Legal__c`, `Pricebook2.Empresa__c`, `ServiceTerritory.Empresa__c`; clases Empresa habilitadas. | Ninguno para administradores/configuración. Validar asignación a responsables reales. | PERMISO YA SUFICIENTE |
| `Empresa_Consulta_Flows` | `Empresa__c`, `ServiceTerritory.Empresa__c` | Tiene read sobre `Empresa__c` y read sobre `ServiceTerritory.Empresa__c`. No trae FLS explícito para `Empresa__c.Codigo_ERP__c`, `Empresa__c.Activa__c` ni `Empresa__c.Nombre_Legal__c`. | Si este PS será productivo/runtime para Flows o usuarios de taller, agregar lectura a campos de Empresa usados por resolvers; antes confirmar assignees. | REQUIERE AJUSTE |
| `Vehiculos_Nuevos_PS` | Venta Nueva: Opportunity/Quote/Pricebook/RT Omoda-Jaecoo | Trae acceso a `Opportunity.Empresa_Operadora__c` como readable/no editable, `Pricebook2.Empresa__c` readable/no editable, record type visibility para `Opportunity.BMW`, `Opportunity.Omoda`, `Opportunity.Jaecoo`, y acceso a objetos de Venta Nueva. | No tocar para este bloque. Si los usuarios necesitan seleccionar empresa explícitamente, revisar editable de `Opportunity.Empresa_Operadora__c` contra UX ya definida en Sprint 2/4. | PERMISO YA SUFICIENTE CON OBSERVACIÓN |
| `QA_PEKING_S3_RecordType_Access` | Lead/Opportunity Omoda-Jaecoo | Descripción y contenido lo enfocan a QA: visibilidad RT `Lead.Omoda`, `Lead.Jaecoo`, `Opportunity.Omoda`, `Opportunity.Jaecoo`. | No promover como solución productiva. Tras QA, mover permisos a PS/perfiles productivos definidos. | TEMPORAL DE QA |
| `WorkOrder_Empresa_Factura_QA` | `WorkOrder.empresaFacturaCP__c`, WorkOrder | Descripción explícita: “QA TEMPORAL — NO PROMOVER A PRODUCCIÓN”. Otorga read/edit al lookup `WorkOrder.empresaFacturaCP__c` y create/read/edit de WorkOrder. | Crear/ajustar permiso productivo real para postventa si usuarios finales deben ver/editar empresa factura. No usar este PS en Producción. | TEMPORAL DE QA / REQUIERE SOLUCIÓN PRODUCTIVA |
| `Plan_Mantenimiento_QLI_QA` | `QuoteLineItem.Quote_Line_Item__c`, `QuoteLineItem.esRegalia__c` | PS temporal QA para dataset/plan de mantenimiento. | No promover como solución productiva; validar si estos campos requieren permisos definitivos en perfiles VN/Taller. | TEMPORAL DE QA |
| `Empresa_Codigo_ERP_QA` | `Empresa__c.Codigo_ERP__c` | PS temporal QA para lectura de código ERP. | No promover como solución productiva; consolidar lectura dentro de `Empresa_Consulta_Flows` o PS productivo. | TEMPORAL DE QA |
| `Event_Who_QA` | `Event.WhoId`, `Task.WhoId` | PS temporal QA para lectura de WhoId. | No promover como solución productiva. Revisar sólo si flujos de citas/tareas productivos requieren este acceso. | TEMPORAL DE QA |
| Perfiles Venta Nueva: `Asesor de Ventas BMW y Nuevos V2`, `Asesor de Ventas Online BMW y Nuevos V2`, `Admin Vh V2`, `Admin Vh V2 A1`, jefaturas/gerencias VN relacionadas | Opportunity/Lead/Quote/Pricebook, RT Omoda-Jaecoo, campos `Empresa_Operadora__c` | Metadata de perfiles está versionada, pero no se revisó/alteró perfil por perfil porque no hay matriz de usuarios destino ni decisión de si se resuelve por perfiles o Permission Sets. | Recuperar/confirmar matriz de asignación productiva. Preferible concentrar PEKING en Permission Sets productivos, no editar ~40 perfiles uno por uno salvo obligación. | METADATA DISPONIBLE / REQUIERE DECISIÓN DE ASIGNACIÓN |
| Perfiles Postventa/Taller: `Admin Taller`, `Asesor de Taller`, `Asesor de Taller V2`, `Asesor de servicio PIN`, `Creadores de citas`, `Creadores de citas PIN`, `Recepcion MINI`, `Recepcion Mixtos`, `Garantías`, `Mecánico`, `Repuestos`, `Servicio al cliente`, `Torre de Control`, `Torre de Control UR`, `ZZadmin FIELD SERVICE zz` | WorkOrder, Case, Event, ServiceTerritory, WorkOrderLineItem, campos de empresa factura | Metadata de perfiles está versionada, pero los accesos PEKING productivos de `WorkOrder.empresaFacturaCP__c`, `ServiceTerritory.Empresa__c`, `Empresa__c` y objetos de calendario no están conciliados por perfil. | Definir si se ajustan perfiles o se crea un PS productivo de Postventa PEKING. No usar PS QA como solución final. | REQUIERE AJUSTE / METADATA DISPONIBLE PARCIAL |
| Perfiles integración: `API Only`, `API Only Altica`, `Salesforce API Only System Integrations` | Softland/API/citas según usuario de integración real | Metadata versionada parcial. No se confirmó cuál usuario ejecuta cada integración/Flow/REST. | No modificar sin identificar usuario de integración. Si integra PEKING, validar acceso a `Empresa__c`, `Codigo_ERP__c`, `Pricebook2.Empresa__c`, `WorkOrder.empresaFacturaCP__c`, `ServiceTerritory.Empresa__c`. | BLOQUEADO POR ASIGNACIÓN TÉCNICA |
| `Product2` / Pricebook PEKING | `Product2.Empresa__c`, `Pricebook2.Empresa__c`, PricebookEntry | `Empresa_Admin` y `Vehiculos_Nuevos_PS` traen parte del acceso. No se comprobó acceso productivo para perfiles de repuestos/taller. | Revisar perfiles/PS de Repuestos y Taller antes de QA end-to-end de bodega/inventario. | REQUIERE AJUSTE |
| Custom Metadata / `RM_RecordTypeMapping__mdt` | Lead → Opportunity Omoda/Jaecoo | Mappings existentes en Git para Omoda/Jaecoo. | Ninguno en este bloque. No mezclar con clases extras. | PERMISO/CONFIG YA SUFICIENTE |

Conclusión permisos: hay piezas listas para QA y administración, pero no hay cierre productivo de permisos. El gap exacto no es “crear 40 permisos”; es definir y aplicar un modelo productivo para: lectura de `Empresa__c` y campos ERP/activo/legal, edición/lectura de `WorkOrder.empresaFacturaCP__c`, lectura de `ServiceTerritory.Empresa__c`, RT Omoda/Jaecoo en perfiles destino, y acceso a Pricebooks/Productos PEKING según rol.

## C. POSTVENTA

| COMPONENTE | DENTRO ALCANCE | ESTADO | CAMBIO | BLOQUEO/EXTRA |
| --- | --- | --- | --- | --- |
| `WorkOrder.empresaFacturaCP__c` | DENTRO DEL ALCANCE | HECHO | Ninguno en metadata de campo. El lookup existe con label “Empresa que Factura” y referencia a `Empresa__c`. | Falta permiso productivo; hoy `WorkOrder_Empresa_Factura_QA` es temporal. |
| `WorkOrder.empresaFactura__c` | DENTRO DEL ALCANCE COMO LEGACY | HECHO/PARCIAL | Mantener como compatibilidad legacy; no reemplazar sin refactor transversal. | Debe derivarse desde `Empresa__c.Codigo_ERP__c`, no ser fuente principal. |
| Work Order Lightning/FlexiPages | DENTRO DEL ALCANCE SI HAY UI POSTVENTA | METADATA NO DISPONIBLE | Recuperar FlexiPages/acciones reales de WorkOrder desde Partial antes de decidir cambios. | En Git sólo existe `Opportunity_Record_Page_VN.flexipage-meta.xml`; no hay FlexiPage WorkOrder versionada. |
| WorkOrder layouts / Quick Actions | DENTRO DEL ALCANCE SI HAY UI POSTVENTA | METADATA NO DISPONIBLE | Recuperar layouts/actions reales de WorkOrder/Case. | En Git sólo hay layouts de Opportunity y Pricebook2, no WorkOrder/Case. |
| `Work_Order_from_Quote` | DENTRO DEL ALCANCE | YA CERRADO / NO REABRIR | Ninguno en este bloque. | Evidencia: crea WorkOrder asignando `empresaFacturaCP__c = Datos_Opp.Empresa_Operadora__c` y `empresaFactura__c` desde código ERP derivado. Mantiene fallback Bavarian/Otobai sólo si no hay lookup. |
| `Work_Order_from_Quote_Selective` | DENTRO DEL ALCANCE | YA CERRADO / NO REABRIR | Ninguno en este bloque. | Evidencia equivalente: asigna `empresaFacturaCP__c = Datos_Opp.Empresa_Operadora__c` al crear WorkOrder. |
| `aperturaCaseWorOrderEvent` | DENTRO DEL ALCANCE POSTVENTA/CITAS | PARCIAL | No cambiar todavía. QA con datos PEKING y recuperar UI/acciones si faltan. | Ya usa `recordEvent.ServiceTerritory__r.Empresa__c` para `WorkOrder.empresaFacturaCP__c` y `Opportunity.Empresa_Operadora__c`; fallback conserva `RMBAVARIAN/RMOTOBAI` y nombres de pricebook legacy si el territorio no tiene Empresa. Contiene `RecordTypeId` fijo de Opportunity/Quote; corregir IDs fijos sería otro cambio técnico dirigido. |
| `ct_newCaseWorkOrderEvent` | DENTRO DEL ALCANCE POSTVENTA/CITAS | PARCIAL | No cambiar todavía. QA con datos PEKING. | Ya asigna `empresaFacturaCP__c` desde `ServiceTerritory.Empresa__c`; si el territorio no tiene Empresa cae a ERP default Bavarian/Otobai. Requiere datos de ServiceTerritory PEKING antes de declarar HECHO. |
| `PlanDeMantenimientoV2` | DENTRO DEL ALCANCE POSTVENTA/PRESUPUESTO | PARCIAL | No modificar en este bloque. Validar catálogo/PBE PEKING. | Evidencia: usa `EmpresaPricebookResolver` con `EmpresaIdResuelta`; fallback legacy por `Opportunity.BMW_Compania__c` sólo cubre Bavarian/Otobai. PEKING funciona si la Quote/Opp ya trae `Empresa_Operadora__c` y existen productos/PBEs activos. |
| `SegregateWOLIs` | DENTRO DEL ALCANCE SI HAY GARANTÍA | YA CERRADO / NO REABRIR | Ninguno. | Garantía N3 ya fue validada sin cambio técnico. El flow segrega por tipos de cargo/porcentajes y permisos BSI; no hay requisito vivo de rama PEKING. |
| `ServicioCitas` | ADICIONAL / NO LISTADO EXPLÍCITAMENTE | PARCIAL CON DATOS | No implementar dentro de este bloque. | TRABAJO EXTRA — NO CONTEMPLADO EN EL ALCANCE/HORAS ORIGINALES si se exige separación formal por Empresa. La clase opera por `User` calendario (`Calendario_Marca__c`, `Calendario_tipo_vehiculo__c`) y nombres de sucursal/servicio, no por `Empresa__c`. Puede funcionar con calendarios Omoda/Jaecoo si los datos existen. |
| `ServicioCitasFieldService` | ADICIONAL / NO LISTADO EXPLÍCITAMENTE | PARCIAL CON DATOS | No implementar dentro de este bloque. | TRABAJO EXTRA — NO CONTEMPLADO EN EL ALCANCE/HORAS ORIGINALES si se pide rediseño por Empresa. Usa FSL, `ServiceTerritory`, `Work_Type__c`, `Hora_global__c`, `AsesorxCalendario__c` y calendarios por marca/tipo; no hay lookup Empresa como contrato principal. |
| `TrabajoController` | DENTRO DEL ALCANCE SOLO PARA USO PEKING EXISTENTE | PARCIAL | No modificar aquí. Crear/validar datos de mano de obra PEKING. | Código acepta `RMPEKING` y resuelve por `empresaFacturaCP__c` cuando existe; busca `TipoDeCargoConManoDeObra__c.Empresa__c = empresa`. Si falta catálogo/PBE PEKING falla con “Tipo de cargo sin mano de obra definida”. Migrar `TipoDeCargoConManoDeObra__c.Empresa__c` de picklist a lookup es TRABAJO EXTRA si negocio pide escalabilidad de “trabajos”. |
| `TrabajoQuoteController` | DENTRO DEL ALCANCE SOLO PARA USO PEKING EXISTENTE | PARCIAL | No modificar aquí. Crear/validar datos de mano de obra PEKING. | Código acepta `RMPEKING`, usa `Empresa_Operadora__c` cuando existe y consulta `TipoDeCargoConManoDeObra__c`. Depende de catálogo/PBE PEKING; fallback legacy sólo cubre Bavarian/Otobai. |
| `BMWVinScanTrabajoGenerator` | DENTRO DEL ALCANCE SOLO PARA USO PEKING EXISTENTE | PARCIAL | No modificar aquí. Crear/validar datos de mano de obra PEKING. | Código acepta `RMPEKING` y usa lookup si existe; depende de tipos de trabajo, `TipoDeCargoConManoDeObra__c`, producto mano de obra y PricebookEntry PEKING. |
| `WoliGridController` | DENTRO DEL ALCANCE COMO UI/API DE WOLI | PARCIAL | Ningún cambio seguro en este bloque. | Delega precio/localización a `HttpCalloutGetProductRefPrices` y `ProductoLocalizacionHelper`; búsqueda depende de WorkOrder Pricebook y bodegas por territorio. Requiere datos PEKING de pricebook/bodega/territorio. |
| `WoliGridController2` | DENTRO DEL ALCANCE COMO UI/API DE WOLI | PARCIAL | Ningún cambio seguro en este bloque. | Mismo patrón que `WoliGridController`, usando helper/query service 2. No contiene discriminación directa de PEKING. |
| `WoliGridQueryService` | DENTRO DEL ALCANCE COMO SOPORTE WOLI | PARCIAL | Ningún cambio seguro en este bloque. | Busca productos por `Pricebook2Id` de WorkOrder/Quote y bodegas por `BodegaxTerritorio__c`. PEKING depende de configuración de Pricebook, PBE, productos y bodegas por territorio. |
| `WoliGridQueryService2` | DENTRO DEL ALCANCE COMO SOPORTE WOLI | PARCIAL | Ningún cambio seguro en este bloque. | Misma dependencia de datos/configuración que `WoliGridQueryService`. |

Conclusión Postventa: no hay un cambio Git único que cierre todo Postventa sin recuperar más metadata y sin datos QA. Lo implementable ya visible está parcialmente resuelto por `ServiceTerritory.Empresa__c`, `WorkOrder.empresaFacturaCP__c` y `EmpresaPricebookResolver`. Lo que falta cerrar no es hardcodear PEKING, sino datos de territorio/bodega/pricebook/PBE/mano de obra, permisos productivos, y metadata UI faltante.

## Metadata que debe recuperar Code

### List Views faltantes

Usar retrieve directo desde Partial para listar nominalmente y no inventar variantes:

```bash
sf project retrieve start --target-org RedPartial \
  --metadata "ListView:Lead.*" \
  --metadata "ListView:Quote.*" \
  --metadata "ListView:Order.*" \
  --metadata "ListView:WorkOrder.*" \
  --metadata "ListView:Case.*" \
  --metadata "ListView:Product2.*"
```

Si el wildcard de `sf` falla por tipo `ListView`, usar `package.xml` con:

```xml
<types>
  <members>Lead.*</members>
  <members>Quote.*</members>
  <members>Order.*</members>
  <members>WorkOrder.*</members>
  <members>Case.*</members>
  <members>Product2.*</members>
  <name>ListView</name>
</types>
```

### WorkOrder / Case UI faltante

Primero listar nombres reales, porque Git no trae FlexiPages ni layouts de WorkOrder/Case:

```bash
sf org list metadata --target-org RedPartial --metadata-type FlexiPage --json
sf org list metadata --target-org RedPartial --metadata-type Layout --json
sf org list metadata --target-org RedPartial --metadata-type QuickAction --json
```

Luego recuperar sólo lo relacionado con WorkOrder/Case/Taller, por ejemplo:

```bash
sf project retrieve start --target-org RedPartial \
  --metadata "CustomObject:WorkOrder" \
  --metadata "CustomObject:Case" \
  --metadata "FlexiPage:<NOMBRE_REAL_WORKORDER>" \
  --metadata "FlexiPage:<NOMBRE_REAL_CASE_TALLER>" \
  --metadata "Layout:WorkOrder-<NOMBRE_REAL_LAYOUT>" \
  --metadata "Layout:Case-<NOMBRE_REAL_LAYOUT>" \
  --metadata "QuickAction:WorkOrder.<ACCION_REAL>" \
  --metadata "QuickAction:Case.<ACCION_REAL>"
```

### Perfiles productivos a conciliar

La metadata de perfiles existe, pero falta decidir cuáles son target productivo. Recuperar/validar como mínimo estos perfiles relacionados con Venta Nueva/Postventa:

```bash
sf project retrieve start --target-org RedPartial \
  --metadata "Profile:Asesor de Ventas BMW y Nuevos V2" \
  --metadata "Profile:Asesor de Ventas Online BMW y Nuevos V2" \
  --metadata "Profile:Admin Vh V2" \
  --metadata "Profile:Admin Taller" \
  --metadata "Profile:Asesor de Taller" \
  --metadata "Profile:Asesor de Taller V2" \
  --metadata "Profile:Asesor de servicio PIN" \
  --metadata "Profile:Creadores de citas" \
  --metadata "Profile:Creadores de citas PIN" \
  --metadata "Profile:Garantías" \
  --metadata "Profile:Mecánico" \
  --metadata "Profile:Repuestos" \
  --metadata "Profile:Servicio al cliente" \
  --metadata "Profile:Torre de Control" \
  --metadata "Profile:Torre de Control UR" \
  --metadata "Profile:ZZadmin FIELD SERVICE zz"
```

Campos/permisos mínimos a verificar en esos perfiles o en un Permission Set productivo:

- `Empresa__c` read.
- `Empresa__c.Activa__c` read.
- `Empresa__c.Codigo_ERP__c` read.
- `Empresa__c.Nombre_Legal__c` read sólo donde se genere documento/legal.
- `Opportunity.Empresa_Operadora__c` read/edit según UX vigente.
- `WorkOrder.empresaFacturaCP__c` read/edit según proceso.
- `WorkOrder.empresaFactura__c` read.
- `ServiceTerritory.Empresa__c` read.
- `Pricebook2.Empresa__c` read.
- Record Types `Lead.Omoda`, `Lead.Jaecoo`, `Opportunity.Omoda`, `Opportunity.Jaecoo` en perfiles destino.

### Datos/configuración que no se deben inventar desde metadata

Estos no son commits de metadata; se validan/cargan como datos QA o configuración administrada:

- `Empresa__c` PEKING activa con `Codigo_ERP__c` y `Nombre_Legal__c` de prueba.
- `ServiceTerritory.Empresa__c` para territorios PEKING.
- `Pricebook2.Empresa__c` para Pricebooks PEKING Local/Dólares.
- `PricebookEntry` activo para productos PEKING, mano de obra y planes de mantenimiento.
- `BodegaxTerritorio__c` y `Bodega__c` para territorio/bodega PEKING.
- `TipoDeCargoConManoDeObra__c` con `Empresa__c = RMPEKING` para los tipos de cargo/tipo vehículo usados.
- Calendarios de `User` con `FirstName = Calendario`, `Calendario_activo_chatbot__c = true`, `Calendario_Marca__c` compatible con Omoda/Jaecoo y `Calendario_tipo_vehiculo__c` compatible.
- `AsesorxCalendario__c`, `Hora_global__c`, `OperatingHours`, `WorkType`, recursos FSL y no disponibilidades para Field Service.

## Lista exacta de componentes que requieren implementación o decisión

### Requieren implementación después de retrieve/decisión

1. List Views no versionadas de `Lead`, `Quote`, `Order`, `WorkOrder`, `Case`, `Product2` si el retrieve demuestra filtros Bavarian/Otobai/BMW/MINI/Motorrad que excluyen Omoda/Jaecoo/PEKING.
2. Permission Set productivo para consulta de Empresa/WorkOrder/Postventa, o ajuste controlado de perfiles productivos destino.
3. UI WorkOrder/Case/FlexiPages/Quick Actions sólo si el retrieve demuestra que `empresaFacturaCP__c`, `ServiceTerritory.Empresa__c` o acciones PEKING no son visibles/ejecutables.
4. Datos QA de Postventa: territorio, bodega, pricebook/PBE, mano de obra, calendarios y recursos.

### No deben volver a tocarse en este bloque

1. `Work_Order_from_Quote`.
2. `Work_Order_from_Quote_Selective`.
3. Las 8 Opportunity List Views Omoda/Jaecoo ya versionadas.
4. Sprint 4: picklists, Order Record Types, Global Value Sets y LWC.
5. Apex de la rama `feature/luis/peking-apex-urgentes-20260813`.
6. `ServicioCitas` y `ServicioCitasFieldService` sin autorización económica/funcional explícita, porque si se pide rediseño por Empresa es trabajo extra.

## Orden recomendado de cierre

1. Recuperar List Views faltantes y WorkOrder/Case UI desde Partial.
2. Definir matriz de permisos productiva: perfiles destino vs Permission Set productivo.
3. Crear/ajustar permisos productivos mínimos para Empresa, ServiceTerritory, WorkOrder y Pricebook.
4. Cargar/validar datos QA PEKING de territorio, bodega, pricebook, PBE, mano de obra y calendarios.
5. QA end-to-end Postventa:
   - Event/Case → WorkOrder.
   - Quote → WorkOrder.
   - Agregar mano de obra/trabajos.
   - WOLI grid: búsqueda, disponibilidad, localización/precio Softland.
   - Segregación sin garantía PEKING.
6. Sólo si QA demuestra fallo de código, abrir cambio puntual en el componente exacto; no reabrir Sprints 1-4 por conteo estimado.

## Cambios implementados en esta rama

Sólo se agrega este documento:

- `docs/empresa-marcas-chinas/CONCILIACION_LISTVIEWS_PERMISOS_POSTVENTA_20260814.md`

No se modificó metadata funcional, Apex, Flow, LWC, Layout, Profile ni Permission Set.