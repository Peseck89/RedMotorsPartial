# Resultado — bloque N2/N3/N4: configuración provisional basada en Bavarian

**Fecha:** 12 de agosto de 2026
**Org:** `RedMotorsSandbox` (Partial)
**Rama:** `feature/pc/redmotors-empresa-marcas-chinas-sprint2-flows-components-20260728`
**Commit base:** `5d34f4c`
**Criterio aplicado:** autorización directa de Luis (sesión activa, 2026-08-12): *"Cuando falte una definición específica de Pekín, utilizar Bavarian como baseline, crear el equivalente necesario para pruebas si corresponde y documentarlo expresamente como provisional."*

Sprint 2 sigue sin declararse cerrado. Este bloque cubre exclusivamente los 5 Flows N2/N3/N4 y la revisión de QA de los 7 Flows ya modificados en Lotes 2A/2D1/2D2.

## Reconciliación de nombres (Fase 1, previo a cualquier cambio)

Los 5 Flows N2/N3/N4 fueron verificados contra `force-app/main/default/flows/` y `MATRIZ_CIERRE_SPRINT2.csv`:

| Nombre en el mandato | Nombre API real verificado | Corrección |
|---|---|---|
| `Work_Order_from_Quote_Selective` | `Work_Order_from_Quote_Selective` | Sin cambio |
| `Work_Order_from_Quote` | `Work_Order_from_Quote` | Sin cambio |
| `SegregateWOLIs` | `SegregateWOLIs` | Sin cambio |
| `aperturaCaseWorkOrderEvent` | **`aperturaCaseWorOrderEvent`** | El nombre real no lleva "Work", es "Wor" — verificado en Git, no es un typo a corregir |
| `ct_newCaseWorkOrderEvent` | `ct_newCaseWorkOrderEvent` | Sin cambio |

Los "8 Flows ya modificados" del mandato son en realidad **7**, verificados contra `git log` (commits `9cc04d0`, `d731d51`, `abb03f3`) y `RESULTADO_LOTE2A_FLOWS_TECNICOS.md` / `RESULTADO_LOTE2D1_FLOWS_OPPORTUNITY.md` / `RESULTADO_LOTE2D2_FLOWS_OPPORTUNITY.md`: `PlanDeMantenimientoV2`, `CreateWoliFromExpense`, `AgregarManoObra`, `Opp_flow_V3`, `Opportunity_Flow_V2`, `Opp_Flow_V5`, `Opp_Flow_v6`. No se encontró un octavo Flow modificado en ningún commit ni documento — se documenta esta corrección de conteo en vez de inventar un octavo nombre.

## Fase 1 — Dependencias exactas por Flow

Investigación de solo lectura (XML + SOQL en `RedMotorsSandbox`) sobre cada uno de los 5 Flows.

### Work_Order_from_Quote y Work_Order_from_Quote_Selective (estructuralmente idénticos)

- Única lógica por Empresa: Decision `revisar_Empresa_Factura` (`Datos_Opp.BMW_Compania__c EqualTo "Otobai"` → `RMOTOBAI`; default → `RMBAVARIAN`), escrita en `WorkOrder.empresaFactura__c`.
- Bodega/territorio/reserva/despacho/devolución/taller **no se deciden dentro de estos Flows** — son pass-through de campos ya poblados en la Opportunity/QuoteLineItem (`Datos_Opp.BMW_TallerDeServicio__c`, `recorrer_items.BMW_Bodega__c`, `Datos_de_Quote.Pricebook2Id`). El único gate propio es `territorio_no_vacio` (detiene si `BMW_TallerDeServicio__r.Id` es nulo, igual para las 3 empresas).
- Sin Ids hardcodeados en ningún punto del XML.
- **Clasificación: DEPENDENCIA_TECNICA.** `WorkOrder.empresaFactura__c` ya tiene `RMPEKING` activo en el picklist. `Opportunity.Empresa_Operadora__c` (lookup a `Empresa__c`, ya usado como fuente principal en los 7 Flows ya modificados) existe y es la vía correcta.

### SegregateWOLIs

- Único gate por Empresa: `GetWorkOrder.empresaFactura__c EqualTo "RMOTOBAI"`, que habilita el campo de pantalla `GarantiaOtobai` y termina asignándose a `tipoCargo__c.Garantia_Otobai__c`.
- **Verificado por describe de `tipoCargo__c`: no existe ningún campo de garantía equivalente para Bavarian.** `Garantia_Otobai__c` es un concepto exclusivo de Otobai (marcas de motocicleta KAWASAKI/POLARIS para ruteo de reclamos de garantía), sin contraparte Bavarian que sirva de baseline.
- **Clasificación: REGLA_DE_NEGOCIO / DATO_OFICIAL_DESCONOCIDO.** El criterio "usar Bavarian como baseline" no es aplicable a este mecanismo específico porque Bavarian no tiene un mecanismo de garantía equivalente que copiar. No se inventó ninguna política de garantía para Pekín.
- **Hallazgo adicional, fuera de alcance de este bloque (no corregido):** un `RecordType.Id` literal (`0124U00000111E8QAI`, Account/`Aseguradora`) en el `queryCondition` de un lookup de pantalla. Es un bug de Id dependiente de ambiente, idéntico para las 3 empresas — no relacionado con la decisión de Pekín. Se documenta, no se corrige en este bloque (mismo criterio aplicado al hallazgo preexistente de `Decimal.valueOf(precio_empleado)` en el bloque anterior).

### aperturaCaseWorOrderEvent y ct_newCaseWorkOrderEvent (mismo patrón)

- Único gate por Empresa: Decision `IFEventoOtobai` — `ServiceTerritory.Name Contains "otobai"` → rama Otobai; **cualquier otro valor** (no solo "Bavarian") → rama por defecto que escribe `empresaFactura__c = "RMBAVARIAN"`.
- **Verificado: `ServiceTerritory` no tiene ningún campo `Empresa__c` ni relación con el objeto `Empresa__c`.** La diferenciación por compañía es puramente una convención de texto en `Name`. Verificado además que la mayoría de territorios de Bavarian (Uruca, Pinares, Escazú, Motorrad) **no** llevan "Bavarian" en el nombre — solo 1-2 de 26 lo hacen. Es decir, la rama "default" no es realmente "la rama Bavarian", es "todo lo que no diga Otobai".
- `$User.Empresa__c` (usado en la creación de Opportunity dentro de `aperturaCaseWorOrderEvent`) tiene picklist con solo `Bavarian`/`Otobai` activos, sin valor para Pekín.
- Los `RecordType.Id` hardcodeados presentes en `aperturaCaseWorOrderEvent` (Opportunity `0124U00000111OTQAY`, Quote `012PH00000FwbD7YAJ`) son **idénticos en ambas ramas** (Otobai y default) — no son un hardcode relacionado con Empresa, no requieren corrección.
- **Clasificación: REGLA_DE_NEGOCIO / DATO_OFICIAL_DESCONOCIDO.** No existe una convención de nombres de `ServiceTerritory` inferible de Bavarian que permita construir una tercera rama correcta sin adivinar. Agregar una rama para Pekín exige (a) decidir la convención real de nombres/territorios de Pekín y (b) una decisión de diseño (¿tercera rama de texto, o campo estructural en `ServiceTerritory`?) que corresponde a Luis/Diego, no a esta sesión. No se modificó ninguno de los dos Flows.

## Fase 2 — Comparación contra Bavarian (resumen)

| Dependencia | Configuración real de Bavarian | ¿Aplicable como baseline para Pekín? |
|---|---|---|
| `Empresa_Operadora__c` (Opportunity) | Lookup a `Empresa__c`, ya usado como fuente principal en los 7 Flows migrados | Sí — mecanismo genérico, funciona igual para las 3 empresas |
| `WorkOrder.empresaFactura__c` | Picklist con `RMBAVARIAN` activo | Sí — `RMPEKING` ya está activo también |
| `ServiceTerritory` de Bavarian | Sin campo `Empresa__c`; la mayoría sin "Bavarian" en el nombre | No — no hay un patrón limpio que copiar |
| `Garantia_Otobai__c` | No existe equivalente en Bavarian | No — no hay baseline que usar |
| Productos `SAD001`/`SUB` (Mano de Obra) | Product2 únicos, compartidos por todas las empresas; solo el `PricebookEntry` varía por Pricebook de Empresa | Sí — agregar `PricebookEntry` de Pekín sobre el mismo Product2, sin duplicar el producto |

## Fase 3 — Datos provisionales creados en `RedMotorsSandbox`

| Tipo | Nombre/Id | Empresa | Motivo | Baseline usado | Provisional | Uso en QA |
|---|---|---|---|---|---|---|
| PricebookEntry | `01uAK000000YRDtYAO` (Product `SAD001`/"BSI" × Pricebook `PEKING Local`) | PEKING | Desbloquear QA positivo de `PlanDeMantenimientoV2`/`CreateWoliFromExpense`/`AgregarManoObra` (N1) | Bavarian y Otobai ya tienen `PricebookEntry` de `SAD001` con `UnitPrice=1` (placeholder nominal, no precio comercial real) | Sí — `UnitPrice=1`, mismo patrón nominal ya usado por Bavarian/Otobai para este producto | `PlanDeMantenimientoV2` |
| PricebookEntry | `01uAK000000YRFVYA4` (`SAD001` × `PEKING Dólares`) | PEKING | Ídem | Ídem | Sí | `PlanDeMantenimientoV2` |
| PricebookEntry | `01uAK000000YRH7YAO` (`SUB` × `PEKING Local`) | PEKING | Ídem, `CreateWoliFromExpense` | Ídem | Sí | `CreateWoliFromExpense`, `AgregarManoObra` |
| PricebookEntry | `01uAK000000YRFWYA4` (`SUB` × `PEKING Dólares`) | PEKING | Ídem | Ídem | Sí | `CreateWoliFromExpense`, `AgregarManoObra` |
| ServiceTerritory | `0HhAK0000000sbV0AQ` — "PEKING TEMPORAL - NO PRODUCCION" | PEKING | Permitir superar el gate `territorio_no_vacio` de `Work_Order_from_Quote`/`_Selective` en pruebas técnicas | Estructura mínima (`Name` + `OperatingHoursId`) igual a cualquier `ServiceTerritory` de Bavarian; se reutilizó el `OperatingHours` genérico "8-5pm" ya existente (no ligado a ninguna sucursal real) para no inventar un horario oficial | Sí — nombre explícitamente marca "TEMPORAL - NO PRODUCCION"; **no representa una decisión real de sucursal/territorio de Pekín**, es solo un valor técnico para que el Flow no se detenga en el gate | `Work_Order_from_Quote`, `Work_Order_from_Quote_Selective` (dato técnico prerrequisito, no resuelve N2 de fondo) |

**No se creó** ningún registro para `SegregateWOLIs`, `aperturaCaseWorOrderEvent` ni `ct_newCaseWorkOrderEvent`: como se documentó en Fase 1, no existe un patrón Bavarian inferible para esos tres, así que crear datos ahí sin resolver antes la lógica del Flow no aportaría evidencia real — solo generaría una falsa sensación de cobertura.

**Nota sobre el registro provisional preexistente:** ya existía en el Sandbox un `Bodega__c` "PEKING TEMPORAL - PARTIAL - NO USAR EN PRODUCCION" (`a2bAK0000000vvxYAA`, creado 2026-07-29), consistente con este mismo criterio aplicado en una sesión anterior. No se creó un duplicado.

## Fase 4 — Clasificación y cambios en los 5 Flows

| Flow | Clasificación | Cambio aplicado |
|---|---|---|
| `Work_Order_from_Quote` | **B — necesitaba cambio técnico** | Nueva Decision `Tiene_Empresa_Operadora`: si `Datos_Opp.Empresa_Operadora__c` no es nulo, usa `Datos_Opp.Empresa_Operadora__r.Codigo_ERP__c` (funciona para Bavarian, Otobai, Pekín y cualquier Empresa futura sin rama nueva). Si el lookup está vacío, cae exactamente al mecanismo legacy existente (`revisar_Empresa_Factura`, Bavarian/Otobai sin cambios). **No se agregó ninguna rama literal `"RMPEKING"` ni se tocó el picklist restringido `BMW_Compania__c`.** Desplegado: v9 → **v10** (activo). |
| `Work_Order_from_Quote_Selective` | **B — necesitaba cambio técnico** | Mismo cambio, idéntico patrón. Desplegado: v7 → **v8** (activo). |
| `SegregateWOLIs` | **C — sigue bloqueado** | Sin cambios. Bloqueo real: no existe mecanismo Bavarian de garantía que sirva de baseline para Pekín (ver Fase 1). Pendiente de negocio: política de garantía/segregación para Pekín. |
| `aperturaCaseWorOrderEvent` | **C — sigue bloqueado** | Sin cambios. Bloqueo real: la diferenciación por Empresa se hace por convención de nombre en `ServiceTerritory` (objeto sin campo `Empresa__c`), sin patrón Bavarian limpio que extender. Pendiente de negocio + diseño: convención real de sucursales/territorios de Pekín. |
| `ct_newCaseWorkOrderEvent` | **C — sigue bloqueado** | Sin cambios. Mismo bloqueo que el anterior. |

## Validación técnica y pruebas

- **Deploy:** `Work_Order_from_Quote.flow-meta.xml` y `Work_Order_from_Quote_Selective.flow-meta.xml`, dry-run exitoso seguido de deploy real contra `RedMotorsSandbox` (apiVersion 56.0, nativo de ambos Flows). Ambos componentes desplegados con éxito, versiones activas confirmadas por Tooling API (`Work_Order_from_Quote` v10, `Work_Order_from_Quote_Selective` v8).
- **QA técnico dirigido** (Apex anónimo con `Savepoint`/`rollback`, sin dejar datos de prueba permanentes):
  - `EmpresaPricebookResolver.resolveForEmpresa` para PEKING + CRC → `EXITO`, `PEKING Local`. Para PEKING + USD → `EXITO`, `PEKING Dólares`.
  - `PricebookEntry` de `SAD001` sobre `PEKING Local` y de `SUB` sobre `PEKING Dólares`: encontrados (1 cada uno) — confirma que `PlanDeMantenimientoV2`/`CreateWoliFromExpense`/`AgregarManoObra` ya pueden completar su ruta positiva para Pekín.
  - Regresión Bavarian: `PricebookEntry` de `SAD001` sobre `Bavarian Local` sigue existiendo sin cambios (1 registro, igual que antes de este bloque).
  - **Prueba directa de la expresión usada en el Flow:** se creó una Opportunity de prueba con `Empresa_Operadora__c` apuntando al registro PEKING; `Empresa_Operadora__r.Codigo_ERP__c` resolvió exactamente a `"RMPEKING"` — la misma expresión (`Datos_Opp.Empresa_Operadora__r.Codigo_ERP__c`) que ahora usa la nueva Decision de ambos Flows.
  - Se confirmó que una Opportunity solo con `BMW_Compania__c='Bavarian'` (sin `Empresa_Operadora__c`) deja ese lookup en `null`, exactamente la condición que activa el fallback legacy sin cambios.
  - Todos los registros de prueba (Account/Opportunity) fueron revertidos con `Database.rollback()`. **Efecto colateral no reversible detectado:** la inserción de la Opportunity de prueba disparó automatización existente de alerta de duplicados que envía correo de forma síncrona (no cubierto por el rollback). No se expuso información sensible ni de clientes reales — es una notificación interna del propio sistema de alertas del org. Se documenta por transparencia.
- **Screen Flows (interacción real vía UI):** consistente con el criterio ya aplicado en `RESULTADO_LOTE2A_FLOWS_TECNICOS.md`/`RESULTADO_LOTE2D1_FLOWS_OPPORTUNITY.md`/`RESULTADO_LOTE2D2_FLOWS_OPPORTUNITY.md` (que tampoco ejecutaron los Screen Flows completos por API), la ejecución interactiva completa de `Work_Order_from_Quote`/`_Selective` queda como QA manual pendiente (video), no como bloqueo del cambio técnico.

## Revisión de QA de los 7 Flows ya modificados (Lotes 2A/2D1/2D2)

| Flow | ¿Necesitaba datos nuevos? | Estado tras este bloque |
|---|---|---|
| `PlanDeMantenimientoV2` | Sí — `PricebookEntry` de `SAD001` en Pricebooks PEKING | **Desbloqueado técnicamente** para QA positivo (confirmado por Apex, ver arriba). QA interactivo completo (video) sigue pendiente. |
| `CreateWoliFromExpense` | Sí — `PricebookEntry` de `SUB` en Pricebooks PEKING | **Desbloqueado técnicamente.** QA interactivo pendiente. |
| `AgregarManoObra` | Sí — cualquier producto `tipoProducto__c='Mano de Obra'` con `PricebookEntry` en Pricebooks PEKING (reutiliza `SAD001`/`SUB`) | **Desbloqueado técnicamente.** QA interactivo pendiente. |
| `Opp_flow_V3` | No — su ruta de éxito nunca consulta `Product2`/`PricebookEntry` | Ya estaba desbloqueado; sin cambios en este bloque. |
| `Opp_Flow_V5` | No — ídem | Ya estaba desbloqueado; sin cambios. |
| `Opp_Flow_v6` | No — ídem | Ya estaba desbloqueado; sin cambios. |
| `Opportunity_Flow_V2` | No para la ruta principal — la rama opcional "crear presupuesto desde plantilla" sí requeriría catálogo de `Plantilla_de_Presupuesto__c`, pero es evitable seleccionando "No" en esa pantalla durante el QA | Ruta principal desbloqueada; rama opcional queda fuera de este bloque (no se fabricó catálogo de plantillas). |

## Resultado por empresa

- **Bavarian:** sin cambios de comportamiento en ningún Flow tocado. Confirmado por Apex (PricebookEntry existente intacto, resolver retorna el mismo estado que antes).
- **Otobai:** sin cambios de comportamiento. El fallback legacy de `Work_Order_from_Quote`/`_Selective` (rama `Otobai`/`RMOTOBAI`) no se tocó.
- **Pekín:** `Work_Order_from_Quote` y `Work_Order_from_Quote_Selective` ahora resuelven `empresaFactura__c` correctamente vía `Empresa_Operadora__c` (confirmado técnicamente). `PlanDeMantenimientoV2`, `CreateWoliFromExpense` y `AgregarManoObra` ya tienen los `PricebookEntry` necesarios para completar su ruta positiva. `SegregateWOLIs`, `aperturaCaseWorOrderEvent` y `ct_newCaseWorkOrderEvent` permanecen genuinamente bloqueados por decisiones de negocio que no tienen equivalente Bavarian del cual partir.

## Riesgos y pendientes reales

1. **N3 (garantía/segregación) y N4 (servicios/agenda/sucursal) siguen sin resolver** — no por falta de tiempo, sino porque no existe un patrón Bavarian aplicable sin inventar información oficial. Requieren decisión explícita de Luis/Diego, documentada como pendiente en `PREGUNTAS_BLOQUEOS_SPRINT2.md`.
2. **QA interactivo (video) de las 2 rutas Quote→WO y de los 3 Flows de mantenimiento/gastos/mano de obra sigue pendiente** — este bloque desbloqueó los prerrequisitos técnicos y de datos, no reemplaza la ejecución manual con interview real.
3. **Hallazgo adicional no corregido:** `RecordType.Id` literal en `SegregateWOLIs` (bug de ambiente, no relacionado con Pekín).
4. **`Opportunity.BMW_Compania__c` y `$User.Empresa__c` siguen sin valor "Pekín" en sus picklists** — irrelevante para los 2 Flows corregidos en este bloque (usan el lookup `Empresa_Operadora__c`, no el picklist), pero sigue siendo la causa raíz del bloqueo de `aperturaCaseWorOrderEvent`/`ct_newCaseWorkOrderEvent` en su creación de Opportunity.
5. El `ServiceTerritory` provisional creado (`0HhAK0000000sbV0AQ`) es exclusivamente un valor técnico para no detener el gate de las 2 rutas Quote→WO en pruebas — **no representa ninguna decisión real de sucursal, taller o territorio de Pekín** y no debe usarse como tal.

## Archivos modificados

- `force-app/main/default/flows/Work_Order_from_Quote.flow-meta.xml`
- `force-app/main/default/flows/Work_Order_from_Quote_Selective.flow-meta.xml`
- `docs/empresa-marcas-chinas/README_CONTEXTO_ACTIVO.md` (puntero)
- `docs/empresa-marcas-chinas/RESULTADO_BLOQUE_N2N3N4_PEKING_20260812.md` (este documento)

No se modificó `SegregateWOLIs.flow-meta.xml`, `aperturaCaseWorOrderEvent.flow-meta.xml` ni `ct_newCaseWorkOrderEvent.flow-meta.xml`.

## Cierre del bloque

Sprint 2 **no** se declara cerrado. Quedan pendientes, sin iniciar automáticamente: N3, N4, QA interactivo (video) de los 5+7 Flows involucrados, Community/Aura, y cualquier otro bloque no mencionado aquí.
