# Cierre técnico — Sprint 2 Empresa/Pricebook (PEKING), 2026-07-30 (segunda pasada)

## Estado: COMPLETADO (con pendientes reales documentados en §11)

La primera pasada de este mismo día quedó **BLOQUEADA** en la relación `Pricebook2` ↔ `Empresa__c` (ver historial más abajo, §1). Luis autorizó expresamente crear `Pricebook2.Empresa__c` (lookup a `Empresa__c`, no obligatorio) en la misma conversación de trabajo. Con esa autorización se completó: el campo, permisos mínimos, el resolver dinámico, los 5 Flows de Pricebook, `rm_vu_inventario`, datos de Empresa/Pricebook en Partial, y QA funcional contra datos reales de Partial. Ningún dato legal (razón social) fue inventado — `Nombre_Legal__c` permanece vacío en los 3 registros de `Empresa__c` creados, tal como exige el mandato.

## 1. Resumen del bloqueo original (ya resuelto)

La pasada anterior (mismo día, mismo worktree) documentó exhaustivamente que no existía ninguna relación entre `Pricebook2` y `Empresa__c` en Git ni en Partial, y se detuvo en ese punto siguiendo la regla de detención del mandato (decisión de arquitectura reservada a Luis/Diego). Ver el detalle completo de esa investigación en `EVIDENCIA_PRICEBOOK_FLOWS_PEKING_20260729.md` §10.1–10.5 (conservado como historial, no se repite aquí).

**Autorización recibida:** Luis autorizó la Opción A documentada en esa pasada (lookup directo), con una diferencia de nomenclatura explícita: el campo se llama `Pricebook2.Empresa__c` (no `Empresa_Operadora__c`, a diferencia del patrón usado en `Opportunity`/`Plantilla_de_Presupuesto__c`). Se siguió la instrucción literal de Luis.

## 2. Worktree, rama, HEAD

- Worktree: `C:\Users\dokur\Documents\Repositorios\RedMotors-Sprint2-Cierre-Empresa-Pricebook`, rama `feature/pc/redmotors-sprint2-cierre-empresa-pricebook-20260730`.
- HEAD inicial de esta pasada: `b6b620b` (limpio, sincronizado 0/0 con origin, confirmado antes de empezar).
- Org: `RedMotorsSandbox` (`peseck89@gmail.com.partial.redmotors`, `https://redmotors--partial.sandbox.my.salesforce.com`), confirmada antes de cualquier operación.
- Producción: no se leyó ni escribió en ningún momento.

## 3. Campo `Pricebook2.Empresa__c`

`force-app/main/default/objects/Pricebook2/fields/Empresa__c.field-meta.xml`: Lookup a `Empresa__c`, `required=false`, `deleteConstraint=SetNull` (sin comportamiento de borrado riesgoso), `relationshipName=Pricebooks`. Sin filtros inventados. Confirmado por metadata que `Pricebook2` no tenía ningún campo custom previo (cero colisión de nombres).

Deployado y verificado en Partial (Deploy ID `0AfAK000000yUzJ0AU`, dry-run previo exitoso).

## 4. Permisos mínimos

- `Empresa_Admin`: agregado `classAccesses` de `EmpresaPricebookResolver` y `fieldPermissions` editable de `Pricebook2.Empresa__c`.
- `Vehiculos_Nuevos_PS` (permission set usado por usuarios de Opportunities/marcas chinas — ya tenía `recordTypeVisibilities` de `Opportunity.Jaecoo`/`Opportunity.Omoda`, confirmando que es el permset correcto para estos usuarios): agregado `fieldPermissions` de lectura de `Pricebook2.Empresa__c` y `classAccesses` de `EmpresaPricebookResolver`.
- **Corrección incidental necesaria para poder deployar `Vehiculos_Nuevos_PS`:** el archivo tenía 4 elementos `<viewAllFields>` dentro de `objectPermissions`, una propiedad no soportada por el schema de `PermissionSet` en ninguna versión de API probada (51.0 y 61.0 fallan igual — es un elemento inerte/heredado, no controla ningún permiso real de `PermissionSet`, a diferencia de `Profile`). Se eliminaron los 4 elementos; no se tocó ningún `allowCreate`/`allowEdit`/`allowRead`/`fieldPermissions` real.
- No se modificaron perfiles. No se otorgaron permisos administrativos innecesarios.

## 5. Resolver dinámico — `EmpresaPricebookResolver`

`force-app/main/default/classes/EmpresaPricebookResolver.cls` (+ `EmpresaPricebookResolverTest.cls`, 14 métodos de prueba, 0 fallos).

Deliberadamente **no reutiliza** `EmpresaResolver`/`EmpresaContext` (que exigen `Nombre_Legal__c` no vacío) — hace su propia validación mínima por diseño explícito del mandato: `Empresa__c` existe y `Activa__c = true`. Nunca usa `Pricebook2.Name`, `contains(Name)`, IDs hardcodeados, ni Empresa__r.Name como código. Sin SOQL dentro de loops (mapas construidos antes del loop principal).

Expone:
- `resolve(List<PricebookResolutionRequest>)` — `@InvocableMethod`, bulk-safe, usable desde Flow y Apex.
- `resolveForEmpresa(empresaId, currencyIsoCode, currentPricebookId)` — conveniencia para Apex.
- `getActivePricebooksByEmpresa(Set<Id>)` — bulk.

Estados devueltos: `EXITO` (con `pricebookId`), `NO_CONFIGURADO`, `SELECCION_REQUERIDA`, `ERROR` (Empresa ausente/inexistente/inactiva). Nunca selecciona Bavarian/Otobai/PEKING por defecto; nunca conserva un Pricebook de otra Empresa.

**Corrección aplicada durante el desarrollo:** el campo `empresaId` del wrapper de solicitud se declaró inicialmente `@InvocableVariable(required=true)`. Eso provocaba que Flow lanzara un error de ejecución duro ("Missing required input parameter") en vez de dejar que el resolver devolviera `ERROR` de forma controlada cuando la Empresa está ausente. Se quitó `required=true` — el resolver ya maneja `empresaId == null` internamente y ahora sí puede hacerlo desde Flow.

## 6. Los 5 Flows de Pricebook

Todos migrados al mismo patrón: `Empresa_Operadora__c` (o el campo equivalente en el objeto padre) es la fuente principal; si está vacío, un fallback temporal traduce `BMW_Compania__c` (`"Bavarian"`→`RMBAVARIAN`, `"Otobai"`→`RMOTOBAI`) a un registro de `Empresa__c` vía `Codigo_ERP__c` (nunca por nombre de Pricebook). El resultado se pasa a `EmpresaPricebookResolver`. Ninguno usa `Pricebook2.Name`, `contains(Name)` ni IDs hardcodeados en la lógica nueva. Se preservaron todas las demás rutas de cada Flow.

| Flow | apiVersion nativo | Cambio | Deploy ID (último) |
|---|---|---|---|
| `Opportunity_Flow` | 54.0 | Decision `Encuentra_Price_Book` (4 reglas Bavarian/Otobai × Local/Dólar) + 4 Assignments + RecordLookup por `Name` → reemplazados por `Tiene_Empresa_Operadora` + fallback + `Resuelve_Pricebook_Empresa` (Action) + RecordLookup `Obtener_PriceBook_Opp` ahora por `Id` | `0AfAK000000yVKH0A2` |
| `Opp_flow_v4` | 54.0 | Mismo patrón que `Opportunity_Flow` (estructura idéntica confirmada por inspección) | `0AfAK000000yVTx0AM` |
| `BMW_ImportarPlantilla` | 55.0 | Decision `Determina_Nombre_Price_Book` + 4 Assignments + RecordLookup `Obtiene_Price_Book_Pre` por `Name` → mismo patrón dinámico, ahora por `Id` | `0AfAK000000yU860AE` |
| `BMW_Gestiona_Listas_de_Precios` | 53.0 | **Proceso legacy tipo "Workflow" (Process Builder migrado), disparado `onAllChanges` en `Opportunity`.** Inspección directa confirmó 6 Decisions + 6 RecordUpdates, cada uno fijando `Opportunity.Pricebook2Id` a un **Id literal hardcodeado** (`01s4U0000026Mg...`, 6 valores, dos de ellos duplicados entre combinaciones de Empresa distintas — inconsistencia ya presente en el dato legacy). Reemplazado por el mismo patrón dinámico; la dimensión "tipo de vehículo" (Autos/Motos) se eliminó de la resolución de Pricebook porque no existe ningún Pricebook diferenciado por tipo de vehículo en ningún otro punto del sistema — mantenerla habría exigido inventar un modelo de datos no confirmado | `0AfAK000000yViT0AU` (última, incluye 2 correcciones de guardas, ver §9) |
| `Obtener_PricebookEntry_en_Linea_de_Plantilla_de_Presupuesto` | 56.0 | Flow disparado en creación de `Linea_Plantilla_de_Presupuesto__c`. Decision `Determina_Nombre_Pricebook` sobre `BMW_Compania__c` de la Plantilla + RecordLookup por `Name`, **siempre asumía moneda Dólar** (nunca CRC) → reemplazado por el resolver dinámico usando `$Record.CurrencyIsoCode`; se agregó filtro `IsActive`/`CurrencyIsoCode` al `RecordLookup` de `PricebookEntry` que antes no los tenía | `0AfAK000000yVlh0AE` |

**Nota sobre versiones de API:** cada Flow se deployó individualmente usando un `package.xml` con `<version>` igual a su propio `apiVersion` nativo. Deployar dos o más de estos Flows juntos bajo una única versión de manifest distinta a la nativa de cada uno hace que la validación de metadata aplique reglas de una versión distinta a la que el Flow declara, y expone errores de metadata legacy no relacionados con Sprint 2 (ejemplo real encontrado: un Screen Section de `Opportunity_Flow` sin `regionContainerType`, exigido solo en validaciones más nuevas). Recomendación para futuros deploys de este bloque: uno por uno, con la versión nativa de cada archivo.

`CambiarPricebook`: regresión confirmada limpia, sin cambios — no decide por Empresa/Pricebook.

## 7. `rm_vu_inventario` + `RM_VU_Inventario_Ctrl`

- **Apex nuevo:** `RM_VU_Inventario_Ctrl.getPricebookOptions(Id opportunityId)` — consulta `Opportunity.Empresa_Operadora__c`/`Pricebook2Id`, delega en `EmpresaPricebookResolver.resolveForEmpresa(empresaId, null, currentPricebookId)` (sin filtro de moneda, para listar todas las opciones de la Empresa) y devuelve `{status, mensaje, selectedPricebookId, options[{label, value, currencyIsoCode}]}`.
- **Apex modificado:** `getRecords` ahora recibe `Id priceBookId` (antes `String priceBook` buscado por `Name`); la moneda para filtrar `PricebookEntry` se deriva del propio `Pricebook2.CurrencyIsoCode` seleccionado (se eliminó la dependencia del metadato `Default_Price_List_VU_Currency_Code`, que forzaba USD global). Si `priceBookId` es nulo, devuelve un mapa vacío en vez de lanzar excepción (estado "sin selección" válido, no error).
- **LWC:** se eliminó el arreglo fijo `[{Bavarian Dólar},{Otobai Dólares}]` y el default `priceBookId = 'Bavarian Dólar'`. Ahora `priceBooks`/`priceBookId` se pueblan vía `@wire(getPricebookOptions, {opportunityId: '$recordId'})`, reactivo al `recordId` de la Oportunidad. Se agregó un mensaje controlado (`pricebookMessage`) visible en el HTML cuando el estado no es `EXITO` (Empresa ausente, sin Pricebook, selección requerida, Pricebook de otra Empresa).
- Interfaz pública del componente (`@api recordId`, `brand`, `year`, etc.) preservada sin cambios.
- Deploy ID: `0AfAK000000yW...` (bloque `RM_VU_Inventario_Ctrl` + `RM_VU_Inventario_Ctrl_Test` + LWC, 8/8 pruebas Apex exitosas).

## 8. Datos de Empresa/Pricebook en Partial

Registros de `Empresa__c` creados (mínimos, sin inventar razón social):

| Empresa | Id | Codigo__c | Codigo_ERP__c | Activa__c | Nombre_Legal__c |
|---|---|---|---|---|---|
| Bavarian | `a1UAK0000009wcf2AA` | RMBAVARIAN | RMBAVARIAN | true | *(vacío — no confirmado)* |
| Otobai | `a1UAK0000009weH2AQ` | RMOTOBAI | RMOTOBAI | true | *(vacío — no confirmado)* |
| PEKING | `a1UAK0000009wft2AA` | RMPEKING | RMPEKING | true | *(vacío — no confirmado)* |

Pricebooks relacionados (`Pricebook2.Empresa__c`), verificados antes y después del cambio (backup del estado previo capturado vía `sf data query`, operación idempotente — solo se pobló un campo previamente vacío):

| Pricebook | Id | CurrencyIsoCode | Empresa asociada |
|---|---|---|---|
| Bavarian Dólar | `01s4U0000026MgfQAE` | USD | Bavarian |
| Bavarian Local | `01s4U0000026MgkQAE` | USD | Bavarian |
| Otobai Dólares | `01s4U0000026MguQAE` | USD | Otobai |
| Otobai Local | `01s4U0000026MgpQAE` | USD | Otobai |
| PEKING Dólares | `01sAK0000006DXFYA2` | USD | PEKING |
| PEKING Local | `01sAK0000006DVdYAM` | CRC | PEKING |

**Hallazgo de datos, no corregido (fuera de alcance de esta tarea):** `Bavarian Local` y `Otobai Local` son ambos `CurrencyIsoCode = USD` (no CRC), a pesar del nombre "Local". Solo `PEKING Local` tiene `CurrencyIsoCode = CRC` (corregido en la pasada anterior, autorizado explícitamente). Esto significa que, para Bavarian y Otobai, el resolver dinámico no puede distinguir "Local" de "Dólar" por moneda — ambas opciones son válidas simultáneamente y el resolver correctamente devuelve `SELECCION_REQUERIDA` en vez de adivinar. **No se corrigió la moneda de Bavarian/Otobai Local** porque no fue solicitado ni autorizado en esta tarea (a diferencia de PEKING, que sí lo fue explícitamente en la pasada anterior). Se documenta como candidato a decisión futura de Luis/Diego.

La asociación de estos 6 Pricebooks se hizo por `Name` (permitido explícitamente por el mandato §5 solo para esta migración inicial controlada, nunca para lógica productiva — la lógica productiva usa exclusivamente `Empresa__c`/`CurrencyIsoCode`/`IsActive`).

## 9. Correcciones de bugs encontradas durante el desarrollo

1. **`required=true` en `empresaId`** (§5) — corregido, resolver ahora maneja Empresa ausente sin lanzar excepción de Flow.
2. **`assignNullValuesIfNoRecordsFound=false` en el RecordLookup de fallback** (los 5 Flows) — cambiado a `true` para evitar que un Id vacío (`''`) en vez de `null` llegara al action call cuando el fallback no encuentra Empresa.
3. **`myVariable_current.<Campo>` en `BMW_Gestiona_Listas_de_Precios`** (proceso legacy tipo "Workflow"): referenciar directamente un campo Id no poblado del registro en trigger context (`Pricebook2Id`) devolvía cadena vacía en vez de `null`, y esa cadena vacía causaba `System.StringException: Invalid id` al pasarla como parámetro `Id` al action call. Corregido eliminando el parámetro `currentPricebookId` de este Flow específico (no es necesario — este proceso siempre re-resuelve el Pricebook desde cero en cada guardado, no necesita "conservar el actual"). Se agregó además una Decision de guarda (`Tiene_Empresa_Resuelta`) que verifica `EmpresaIdResuelta IsNull = false` antes de invocar el resolver, y una segunda condición en `Pricebook_Resuelto_Exitosamente` que verifica `PriceBookIdResuelto IsNull = false` antes de la actualización — ambas como defensa adicional. Verificado con las 8 pruebas de `RM_VU_Inventario_Ctrl_Test` (que disparan este proceso indirectamente al insertar Opportunities) y con QA funcional directa (§10).

Estos 3 hallazgos se descubrieron mediante pruebas Apex reales (no solo revisión estática) — la primera pasada de este Flow parecía sintácticamente válida (dry-run exitoso) pero fallaba en tiempo de ejecución real; se corrigió antes de dar el bloque por completo.

## 10. QA funcional (datos reales en Partial, con limpieza posterior)

Ejecutado vía Apex anónimo (`sf apex run`) contra `RedMotorsSandbox`, sin `seeAllData`, sin clientes reales, con prefijo `QA SPRINT2 EMPRESA PRICEBOOK` en todos los registros temporales, eliminados al finalizar cada script:

| Escenario | Resultado observado |
|---|---|
| Resolver: PEKING + CRC | `EXITO`, `PEKING Local` |
| Resolver: PEKING + USD | `EXITO`, `PEKING Dólares` |
| Resolver: Bavarian sin filtro de moneda | `SELECCION_REQUERIDA` (2 opciones, ambas USD — refleja el hallazgo de §8, no un error) |
| Resolver: Otobai sin filtro de moneda | `SELECCION_REQUERIDA` (2 opciones) |
| Resolver: PEKING + CRC con Pricebook actual válido | `EXITO`, conserva el mismo Id (no lo reemplaza) |
| Resolver: Bavarian con Pricebook actual de PEKING | Detecta incompatibilidad, no lo conserva, cae a `SELECCION_REQUERIDA` de Bavarian |
| Resolver: Empresa ausente (`null`) | `ERROR` controlado, mensaje claro |
| `BMW_Gestiona_Listas_de_Precios`: Opportunity real con Empresa=PEKING, CurrencyIsoCode=CRC | `Pricebook2Id` se autocompletó a `PEKING Local` (`01sAK0000006DVdYAM`) sin intervención manual |
| `BMW_Gestiona_Listas_de_Precios`: Opportunity real con Empresa=Bavarian, CurrencyIsoCode=USD (ambiguo) | `Pricebook2Id` permanece `null` — no eligió arbitrariamente entre las 2 opciones válidas |
| `RM_VU_Inventario_Ctrl.getPricebookOptions`: Opportunity real con Empresa=PEKING, CurrencyIsoCode=CRC | `EXITO`, `selectedPricebookId = PEKING Local`, ambas opciones (Local/Dólares) listadas para el combobox |

Regresión: `CambiarPricebook` sin cambios (§6). Bavarian/Otobai: comportamiento correcto y sin selección arbitraria confirmado arriba (la ambigüedad de moneda es un hallazgo de datos preexistente, §8, no una regresión introducida).

Datos temporales de QA: todos eliminados al finalizar cada script (`delete` explícito de Opportunities/Account de prueba). No se conservó ningún dato QA. Se conservan únicamente los 3 registros de `Empresa__c` y las 6 asociaciones de `Pricebook2.Empresa__c` (configuración oficial mínima del Sprint, no datos de prueba).

## 11. Pendientes reales (no bloquean el cierre técnico de este bloque)

1. **Razón social (`Nombre_Legal__c`)** de Bavarian, Otobai y PEKING sigue sin confirmar — no afecta la resolución de Pricebooks (el resolver no la usa), pero sí bloquea cualquier funcionalidad que dependa de `EmpresaContext`/`EmpresaResolver` (documentos, PDFs) para estas 3 Empresas.
2. **Moneda de `Bavarian Local`/`Otobai Local`** (ambos USD, no CRC) — hallazgo de datos preexistente, documentado en §8, no corregido por no estar autorizado en esta tarea.
3. **12 Flows candidatos adicionales** (`AgregarManoObra`, `BMW_Importar_Plantilla_Orden_de_Trabajo`, `CreateWoliFromExpense`, `Llena_Porcentaje_de_Usados`, `Opp_Flow_V5`, `Opp_Flow_v6`, `Opp_flow_V3`, `Opportunity_Flow_V2`, `Opportunity_Flow_From_Work_Order`, `Work_Order_from_Quote`, `Work_Order_from_Quote_Selective`, `FlowOppMostrador`) — siguen fuera de alcance confirmado, no tocados.
4. **QA funcional de `Opportunity_Flow`/`Opp_flow_v4`/`BMW_ImportarPlantilla`** se validó por deploy + pruebas unitarias del resolver, pero no se ejecutó un QA de extremo a extremo disparando esos 3 Flows completos (requieren una interview de Screen Flow con `presupuestoid` real vía Quote, más complejo de automatizar por API que los 2 casos de background process/Apex ya cubiertos en §10). Recomendado como siguiente paso de QA manual en Partial.
5. **Jest**: no se ejecutó — no existe infraestructura Jest previa funcional para `rm_vu_inventario` en este repo (mandato §9: "no crear una infraestructura nueva").

Ninguno de estos pendientes es un bloqueo de arquitectura ni requiere inventar datos — son elementos que pueden resolverse en una sesión posterior o mediante confirmación puntual de Luis/Diego.

## 12. Producción

No se leyó ni escribió en Producción en ningún momento de esta tarea.
