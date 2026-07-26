# Bloque 21 — Experiencia declarativa de Opportunity para Omoda y Jaecoo

Worktree: `C:\Users\dokur\Documents\Repositorios\RedMotors-Bloque21-Oportunidad-UI`
Rama: `feature/pc/redmotors-empresa-marcas-chinas-bloque21-oportunidad-ui-20260726`
Base: `origin/feature/pc/redmotors-empresa-marcas-chinas-sprint1-20260724` @ `a623f54`

Trabajo en paralelo con Codex (Bloque 20 — Lead/Tráfico PEKING, en worktree y rama
separados). Este bloque no tocó `Lead`, `RM_Lead_Trigger_Helper` ni
`RM_RecordTypeMapping__mdt`. Análisis local, sin `sf`, sin consulta a ningún org,
sin deploy ni dry-run.

## Estado: sin cambio implementado

Tras la investigación de Fase 1-3, **no se encontró ningún cambio declarativo que
cumpliera simultáneamente los dos requisitos de Fase 2: réplica exacta y
comprobable del patrón BMW, sin decisión comercial.** No se creó manifest, no se
modificó la bitácora central y no se ejecutó ningún cambio de metadata. Se
documenta el motivo exacto abajo, y se continúa con el análisis independiente de
`empresaFacturaCP__c` pedido en Fase 5.

## FASE 1 — Inventario de metadata de Opportunity versionada localmente

| Tipo de metadata | ¿Versionado localmente? | Detalle |
|---|---|---|
| Record Types (BMW, MINI, Polaris, Kawasaki) | **No** para BMW/MINI/Polaris/Kawasaki | Solo existen `Omoda.recordType-meta.xml` y `Jaecoo.recordType-meta.xml` en `force-app/main/default/objects/Opportunity/recordTypes/`. No hay ningún archivo de Record Type para las marcas históricas — nunca fueron recuperados a git. |
| Record Types (Omoda, Jaecoo) | Sí | Ambos activos, `businessProcess=Autos`, `compactLayoutAssignment=Vehiculos_Nuevos`, mismos 3 picklists restringidos (`ForecastCategoryName`, `LeadSource`, `Type`) con valores idénticos entre sí. |
| Layouts | **No**, para ningún objeto del repo | No existe carpeta `force-app/main/default/layouts/` en absoluto. |
| Compact Layouts | Parcialmente, vía RT | No hay archivos `.compactLayout-meta.xml` independientes, pero la asignación `Vehiculos_Nuevos` está embebida en el propio Record Type (ver arriba) y ya coincide para Omoda/Jaecoo. |
| Lightning Record Pages / FlexiPages | **No** | No existe carpeta `force-app/main/default/flexipages/`. |
| Business Process | Sí, vía RT | `Autos` embebido en ambos Record Types nuevos. Coincide con lo documentado en el cierre del Bloque 17. |
| List Views | **No** | No existe la carpeta `listViews` para ningún objeto en todo el repositorio. |
| Picklist values por Record Type | Sí, vía RT | Ver arriba; Omoda y Jaecoo son idénticos entre sí en los 3 picklists presentes. |
| Quick Actions | **No** | No hay archivos ni carpeta de Quick Actions en el repo. |
| Path / PathAssistant | **No** | No hay archivos `.pathAssistant-meta.xml`. |
| Perfiles (solo para entender asignaciones) | Sí, pero parciales | 146 perfiles versionados, pero cada uno contiene únicamente los fragmentos que un bloque anterior necesitó (p. ej. `Asesor de Ventas BMW.profile-meta.xml` solo trae 2 `fieldPermissions` y `userPermissions`; no trae `layoutAssignments` ni `recordTypeVisibilities`). No hay forma de comparar asignación de Layout por Record Type desde los perfiles locales. |
| Permission Set `Vehiculos_Nuevos_PS` | Sí, completo | Ya contiene `recordTypeVisibilities` con `Opportunity.BMW`, `Opportunity.Jaecoo` y `Opportunity.Omoda`, los tres `visible=true` (confirmado, trabajo del Bloque 17). |

## Comparación específica BMW vs Omoda / BMW vs Jaecoo

No es posible una comparación archivo-contra-archivo para BMW, porque **el
Record Type de BMW nunca fue versionado en este repositorio** (ni layouts, ni
FlexiPages, ni List Views, ni Quick Actions, para ningún Record Type, de ninguna
marca). La única evidencia disponible sobre la equivalencia BMW↔Omoda/Jaecoo es
textual, registrada en el cierre del Bloque 17 (`BITACORA_IMPLEMENTACION.md`,
sección 28): *"Opportunity.Omoda y Opportunity.Jaecoo fueron creados usando
Opportunity.BMW como plantilla técnica... Ambos Record Types quedan activos, con
Sales Process Autos, compact layout Vehiculos_Nuevos y los mismos
picklistValues de BMW."*

Con esa evidencia más la comparación directa Omoda↔Jaecoo (idénticos entre sí),
se concluye:

- **Business Process, Compact Layout y picklist values de Opportunity: ya
  completos y equivalentes a BMW.** No hay brecha que cerrar aquí.
- **Layout de página, Lightning Record Page, List Views y Quick Actions: no
  verificables localmente**, porque ninguno de los dos lados de la comparación
  (ni BMW ni Omoda/Jaecoo) tiene esos artefactos en git. No existe un "patrón
  BMW" local que copiar.

## FASE 2 — Por qué no se implementó nada

Los cambios autorizados por la tarea (List Views, asignación/visibilidad en una
Lightning Record Page ya existente, Compact Layout ya definido, valores de
picklist faltantes copia exacta de BMW, referencias declarativas a componentes
ya existentes) requieren, en todos los casos, un archivo local de BMW (u otra
marca ya operativa) para poder copiarlo de forma "exacta y comprobable". Ese
archivo no existe para ningún tipo de metadata excepto Record Type — y el
Record Type ya está resuelto desde el Bloque 17.

Inventar una List View, una asignación de FlexiPage o una Quick Action sin un
archivo local que replicar dejaría de ser una "réplica exacta y comprobable"
para convertirse en una decisión de diseño nueva (qué columnas, qué filtros,
qué componentes) — exactamente lo que la Fase 2 prohíbe ("no implementar
páginas nuevas con diseño diferente", "no modificar por consistencia estética
si no aporta funcionamiento real"). Y no se puede confirmar la réplica contra
el org porque esta tarea prohíbe expresamente consultar el org o usar `sf`.

## FASE 3 — Llamadores y dependencias (due diligence, sin cambio)

- No se encontró ninguna FlexiPage, Layout o Quick Action de Opportunity
  versionada que pudiera verse afectada, porque ninguna existe en git.
- Se confirmó que `RM_VN_GetOppRecordTypes_Ctrl.getRecordTypes()` y
  `RM_VN_Service.getOppVNRecordTypes()`/`addBrandFilter()` ya son
  dinámicos: enumeran Record Types activos de Opportunity excluyendo una
  lista negra fija (`Autos_Usados`, `Cartera_Madura`, `Motos_Usados`,
  `BMW_Taller`, `Harley_Davidson`, `Principal`, `Master`, `Mostrador`), sin
  lista blanca — Omoda y Jaecoo ya se incluyen automáticamente sin cambio de
  código.
- Se confirmó (grep dirigido, sin modificar nada) que existen 455 Flows
  versionados y varias decenas referencian Opportunity junto con nombres de
  marca (`BMW_Gestiona_Listas_de_Precios`, `Actualiza_tipo_de_registro_de_BMW_a_MINI`,
  etc.). Esto coincide con el hallazgo original del PDF de alcance ("el grep
  marcó 38 flows con coincidencias"). **No se modificó ningún Flow**: no está
  autorizado por esta tarea ("Flows nuevos" está expresamente prohibido, y
  modificar Flows existentes no está entre los cambios autorizados). Se deja
  documentado como riesgo heredado pendiente para un bloque futuro dedicado a
  Flows, fuera del alcance declarativo de Opportunity de este Bloque 21.
- No se encontró ninguna condición que hoy bloquee específicamente una
  réplica de UI para Omoda/Jaecoo más allá de la ausencia de archivos locales
  ya descrita — no hay Softland, sucursal, Pricebook no configurado o Flow
  identificado que dependa de un cambio propuesto, porque no se propuso ningún
  cambio de UI.

## FASE 5 — Análisis independiente: `empresaFacturaCP__c`

### Ubicación completa de usos

| Archivo | Rol |
|---|---|
| `force-app/main/default/objects/WorkOrder/fields/empresaFacturaCP__c.field-meta.xml` | Definición del campo |
| `force-app/main/default/triggers/WorkOrderTrigger.trigger` | Consumidor productivo (selección de Pricebook) |
| `force-app/main/default/classes/TrabajoController.cls` (`saveSubtrabajos`) | Consumidor productivo (validación de empresa antes de crear subtrabajos) |
| `force-app/main/default/classes/BMWVinScanTrabajoGenerator.cls` (2 métodos) | Consumidor productivo (validación de empresa antes de crear trabajos vía VIN Scan) |
| `WorkOrderTriggerTest.cls`, `TrabajoControllerTest.cls`, `BMWVinScanTrabajoGeneratorTest.cls`, `cT_QuoteCrcPDFController_test.cls` | Tests que ejercitan los casos anteriores |

### El campo

`WorkOrder.empresaFacturaCP__c`: Lookup a `Empresa__c`, no requerido,
`deleteConstraint=SetNull`. Descripción versionada: *"empresa configurable
utilizada para determinar el Pricebook del WorkOrder"*.

### Comportamiento cuando está vacío — **no es uniforme entre consumidores**

**`WorkOrderTrigger.trigger`** (líneas 33-51): el lookup tiene precedencia;
si está vacío, usa `empresaFactura__c` (picklist heredado). Si el código
resultante no coincide con ninguna de las seis combinaciones
empresa×moneda conocidas (`RMBAVARIAN`/`RMOTOBAI`/`RMPEKING` × CRC/USD),
**no lanza excepción: conserva silenciosamente el `Pricebook2Id` que el
registro ya tuviera.**

**`TrabajoController.saveSubtrabajos`** y **`BMWVinScanTrabajoGenerator`**
(ambos métodos): mismo orden de precedencia (lookup vía `EmpresaResolver`,
luego picklist heredado), pero si el código resultante no es uno de los tres
conocidos, **lanzan `EmpresaConfigurationException` de forma explícita**,
bloqueando la operación.

### Fallback confirmado

El fallback es el mismo en los tres consumidores: `WorkOrder.empresaFactura__c`
(picklist heredado), nunca `Opportunity.Empresa_Operadora__c` ni el Record Type
del WorkOrder — el campo no tiene ninguna relación directa con
`Empresa_Operadora__c` de Opportunity en ningún consumidor revisado.

### ¿Se puede deducir una única respuesta del código?

**La mecánica sí es 100% deducible** (precedencia lookup→picklist idéntica en
los tres). **La política de qué hacer ante ausencia/código desconocido no lo
es**, porque conviven dos comportamientos deliberados y diferentes:

1. `WorkOrderTrigger` conserva silenciosamente. Esta fue una decisión
   **explícita** de Luis, registrada como *"temporal, pendiente de
   confirmación final de Diego"* (`BITACORA_IMPLEMENTACION.md`, hito 31/36) —
   no es un olvido de código.
2. `TrabajoController`/`BMWVinScanTrabajoGenerator` (Bloques 14/15,
   posteriores) bloquean con excepción — siguiendo el principio general de
   "fail-closed" del `PLAN_IMPLEMENTACION_SPRINT1.md` (*"toda resolución debe
   terminar en contexto configurado o excepción"*).

Ambas reglas son técnicamente defendibles en **contextos distintos**:
`WorkOrderTrigger` corre en cada insert/update automático de `WorkOrder`
(incluyendo WorkOrders históricos que nunca tuvieron `empresaFacturaCP__c`
poblado); bloquear ahí arriesga romper silenciosamente guardados legítimos que
no tienen relación con la selección de Pricebook. Los otros dos corren en
acciones explícitas de UI, donde bloquear con un mensaje claro es la UX
esperada. Esta diferencia de contexto es, en sí misma, **una regla comercial
sobre tolerancia a riesgo de datos históricos**, no una ambigüedad de
implementación.

### Conclusión y recomendación

**No existe una única solución técnicamente evidente.** Hay dos reglas
válidas y ya implementadas, cada una razonable en su contexto, y la propia
bitácora registra que la definitiva para `WorkOrderTrigger` sigue pendiente de
la confirmación final de Diego. Siguiendo la instrucción explícita de esta
tarea, **no se implementa ningún cambio sobre `empresaFacturaCP__c`**.

Punto que requiere decisión externa (Diego): confirmar si
`WorkOrderTrigger` debe alinearse con el patrón "fail-closed" de
`TrabajoController`/`BMWVinScanTrabajoGenerator` (lanzar
`EmpresaConfigurationException` cuando la empresa no se puede resolver) o si
debe mantenerse indefinidamente el comportamiento actual de conservar el
Pricebook existente para WorkOrders sin empresa configurada.

## Entrega

- **Elementos declarativos de Opportunity ya completos:** Record Type, Business
  Process y Compact Layout de Omoda/Jaecoo (Bloque 17); `recordTypeVisibilities`
  en `Vehiculos_Nuevos_PS` (Bloque 17).
- **Elementos faltantes que no se pueden verificar ni replicar localmente:**
  Layout de página, Lightning Record Page, List Views, Quick Actions — ninguno
  está versionado en git para ninguna marca; requieren retrieve dirigido desde
  el org (fuera de alcance de esta tarea) antes de poder compararlos o
  replicarlos con seguridad.
- **Cambios implementados:** ninguno. Sin manifest nuevo. Sin cambio a
  `BITACORA_IMPLEMENTACION.md`.
- **Puntos que requieren decisión externa:** comportamiento final de
  `WorkOrderTrigger` ante empresa vacía/desconocida (Diego); todo lo ya
  registrado en `PENDIENTES_DECISION_BLOQUE20.md` (fuera del alcance de este
  bloque, propiedad de Codex).
- **Confirmación:** no se ejecutó Salesforce CLI, no se consultó ningún org, no
  se hizo deploy ni dry-run. No se tocó `Lead`, `RM_Lead_Trigger_Helper` ni
  `RM_RecordTypeMapping__mdt`. No se tocaron los worktrees de Bloque 18, Bloque
  19, Bloque 20 (ninguno de los dos: discovery ni el de Codex en curso), el
  hotfix de tráfico, ni VN-RQ106. No se modificó `sprint1` directamente.
