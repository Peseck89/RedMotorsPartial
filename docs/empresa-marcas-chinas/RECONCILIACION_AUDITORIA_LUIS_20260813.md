# Reconciliación read-only — Auditoría técnica de Luis (Codex) vs. estado actual

**Fecha del documento:** 13 de agosto de 2026
**Naturaleza:** documento consolidado de análisis. No implementa nada, no autoriza nada por sí mismo. Debe revisarse antes de convertir cualquier hallazgo en trabajo.

---

# 1. Resumen ejecutivo

La auditoría técnica de Luis (documento "Analisis empresa Codex de Luis.md") fue reconciliada punto por punto contra el estado real del repositorio y de `RedMotorsSandbox` (Partial) al 13 de agosto de 2026. La ejecución completa fue **read-only**: no se modificó ningún archivo de Salesforce, no hubo DML, no hubo deploy, no se ejecutó ningún Flow, no hubo commits durante el análisis.

Hallazgos principales:

1. **Bug confirmado — `Pricebook2.Name = Id`** en los 4 Flows Opportunity ya marcados "QA OK" (`Opp_flow_V3`, `Opp_Flow_V5`, `Opp_Flow_v6`, `Opportunity_Flow_V2`). La ruta de recálculo de Pricebook sobre un Quote ya existente compara el campo `Name` de `Pricebook2` contra un **Id** devuelto por el resolver — una comparación que nunca puede coincidir. El resultado (`Id` siempre nulo) se asigna directamente a `Opportunity.Pricebook2Id` y `Quote.Pricebook2Id`. **Afecta a Bavarian y Otobai también, no solo a PEKING**, y está dentro de Flows ya autorizados de Sprint 2 (F12–F15).
2. **P0 de Luis confirmado vigente** — `Work_Order_from_Quote` (F09) y `Work_Order_from_Quote_Selective` (F08) siguen sin propagar `WorkOrder.empresaFacturaCP__c` (el lookup canónico a `Empresa__c`) al crear la Orden de Trabajo; solo llenan el campo texto legacy `empresaFactura__c`. Esto deja sin fuente de Empresa a los Flows dependientes (`CreateWoliFromExpense`, `AgregarManoObra`), que ya usan ese lookup como fuente principal.
3. **Aproximadamente 63–64 clases Apex** citadas por la auditoría de Luis fueron revisadas una por una. Ninguna está nombrada en `MATRIZ_CIERRE_SPRINT2.csv` ni en la tabla de autorización de `REGLAS_ALCANCE_AUTORIZADO.md` — es decir, **ninguna corrección en esas clases puede ejecutarse sin autorización explícita nueva de Luis o Diego**, sin importar su severidad técnica.
4. **Discrepancias encontradas contra la propia auditoría de Luis**: `HttpCalloutCreateKit` no contiene ninguna lógica de Omoda/Jaecoo/RMPEKING (la auditoría afirma que sí la resuelve); cuatro clases citadas por la auditoría no existen en este repositorio Git (dos viven solo en Partial, dos no se localizaron en ningún lado); varias versiones de Flow citadas por Luis ya reflejan remediaciones posteriores a la fecha de la auditoría.

Este documento consolida la totalidad del análisis, no solo el resumen ejecutivo.

---

# 2. Metodología y fuentes

| Campo | Valor |
|---|---|
| Repositorio | `C:\Users\dokur\Documents\Repositorios\RedMotors-Sprint2-Flows-Components` |
| Rama | `feature/pc/redmotors-empresa-marcas-chinas-sprint2-flows-components-20260728` |
| HEAD al iniciar la reconciliación | `5d3057d` |
| Estado de la rama | Sincronizada con `origin` (0 ahead / 0 behind) al iniciar |
| Org consultada | `RedMotorsSandbox` (Partial) — vía `sf` CLI, exclusivamente lectura (SOQL/describe/Tooling API) |
| Alcance de ejecución | Estrictamente read-only: sin edición de archivos, sin DML, sin deploy, sin ejecución de Flows, sin commits durante el análisis |
| Auditoría fuente | Documento "Analisis empresa Codex de Luis.md" (auditoría técnica de Luis, generada por Codex) |
| Documentación de contraste | `MATRIZ_CIERRE_SPRINT2.csv`, `REGLAS_ALCANCE_AUTORIZADO.md`, `README_CONTEXTO_ACTIVO.md`, `CIERRE_TECNICO_SPRINT2_20260813.md`, `CIERRE_FUNCIONAL_SPRINT2_POST_RESPUESTA_LUIS_20260813.md`, `RESULTADO_PREPARACION_QA_P0_20260812.md`, `RESULTADO_REMEDIACION_OPP_FLOW_V5_TALLER_20260812.md`, `RESULTADO_PRECHECK_REGRESIONES_20260812.md`, y el historial completo de commits de la rama |
| Método de investigación | Verificación directa (lectura de metadata/código actual, trazado de grafo de conectores desde `<start>` en los Flows, consultas SOQL/describe read-only) + 6 subagentes de investigación read-only en paralelo para las ~64 clases Apex, cada uno con instrucción explícita de no modificar nada |

**Versiones activas consultadas (Tooling API, read-only, 2026-08-13):**

| Flow | Versión citada por Luis | Versión activa confirmada hoy |
|---|---:|---:|
| `Work_Order_from_Quote` | v10 | v10 |
| `Work_Order_from_Quote_Selective` | v8 | v8 |
| `Work_Order_On_Create_Create_OPP_and_Quote_and_Update_WO_Values` | v13 | v13 (existe solo en Partial, no en Git) |
| `aperturaCaseWorOrderEvent` | v20 | **v21** (activa) |
| `ct_newCaseWorkOrderEvent` | v54 | **v55** (activa) |
| `BMW_Importar_Plantilla_Orden_de_Trabajo` | v11 | v11 (no confirmado como Sprint 2) |
| `Opp_flow_V3` | v30 | v30 |
| `Opp_Flow_V5` | v33 | v33 |
| `Opp_Flow_v6` | v82 | v82 |
| `Opportunity_Flow_V2` | v8 | v8 |
| `Opp_flow_v4` | v19 | v16 (según `MATRIZ_CIERRE_SPRINT2.csv` F02) — discrepancia de versión, ver sección 7 |
| `Opportunity_Flow` | v28 | v25 (según `MATRIZ_CIERRE_SPRINT2.csv` F01) — discrepancia de versión, ver sección 7 |

---

# 3. Matriz COMPLETA de hallazgos de Flows

| Hallazgo Luis | Componente | Versión auditada | Versión actual | Estado actual | Clasificación | Evidencia | Sprint/bloque | ¿Acción inmediata? |
|---|---|---|---|---|---|---|---|---|
| Lee `Opportunity.Empresa_Operadora__c`, pero al crear la OT no llena `WorkOrder.empresaFacturaCP__c`. PEKING pierde su lookup al llegar a la OT. | `Work_Order_from_Quote` | v10 | v10 | Confirmado por lectura directa del XML: `Crear_la_Ot` solo asigna `empresaFactura__c` (texto, resuelto dinámicamente desde bloque anterior); nunca asigna `empresaFacturaCP__c` | **C — sigue vigente** | `Work_Order_from_Quote.flow-meta.xml`, nodo `Crear_la_Ot`, campo `empresaFactura__c` únicamente | F09, dentro de N2 (Sprint 2 autorizado) | Requiere autorización explícita para el cambio, aunque esté en alcance |
| Tiene exactamente el mismo problema | `Work_Order_from_Quote_Selective` | v8 | v8 | Igual — mismo patrón exacto confirmado | **C — sigue vigente** | `Work_Order_from_Quote_Selective.flow-meta.xml`, nodo `Crear_la_Ot` | F08, dentro de N2 | Requiere autorización |
| Su ruta correcta depende de `WorkOrder.empresaFacturaCP__c`. Si la OT no trae ese lookup, solo tienen fallback Bavarian/Otobai y PEKING no puede resolverse. | `AgregarManoObra` v4, `CreateWoliFromExpense` v16 | v4/v16 | v4/v16 | **Superado** — ambos Flows ya ejecutaron QA funcional con dataset donde `empresaFacturaCP__c` se fijó manualmente vía DML de prueba, precisamente porque los Flows creadores de OT no lo propagan; ambos quedaron **QA FUNCIONAL OK — PEKING** | **E — superado por cambio posterior (QA ejecutado con workaround manual)** | `RESULTADO_PREPARACION_QA_P0_20260812.md` | F16/F19, ya cerrados funcionalmente | No — la causa raíz en los Flows de creación de OT sigue pendiente (ver fila de `Work_Order_from_Quote`) |
| Decide Bavarian/Otobai según territorio, busca Pricebooks por nombre y deja Bavarian como default. | `Work_Order_On_Create_Create_OPP_and_Quote_and_Update_WO_Values` | v13 | v13 activa en Sandbox | **No existe en este Git.** Confirmado vía Tooling API read-only que existe y está activa en Partial en v13 (coincide exactamente con la versión citada por Luis), pero nunca fue traído a este repositorio. Ya señalado en julio de 2026 como `missing_in_compare` en el inventario original de Sprint 2 | **H — fuera del alcance explícito del Sprint actual** | Consulta `FlowDefinition` vía Tooling API, `INVENTARIO_SPRINT2_FLOWS_COMPONENTES.md` sección "Elementos dudosos" | No forma parte de los 20 Flows autorizados de Sprint 2 | No |
| Bifurcación Otobai/default Bavarian, Pricebooks por nombre, crea Opportunity/OT sin lookup Empresa. Requiere propagación de Empresa y definición de negocio para PEKING. | `aperturaCaseWorOrderEvent` | v20 | **v21 activa** | **Superado parcialmente** — N4 ya se implementó técnicamente: nuevo lookup `ServiceTerritory.Empresa__c`, resolución de código ERP desde `Empresa__r.Codigo_ERP__c`, fallback legacy `RMBAVARIAN`/`RMOTOBAI` conservado solo para territorios sin Empresa, sin rama literal PEKING. QA funcional todavía pendiente | **E — superado por versión posterior (validación técnica OK, QA funcional pendiente)** | `CIERRE_FUNCIONAL_SPRINT2_POST_RESPUESTA_LUIS_20260813.md` sección N4; deploy `0AfAK0000014VRF0A2` | F17, bloqueo de negocio N4 (QA pendiente) | No — requiere QA funcional dirigido, no cambio de código nuevo |
| Misma lógica binaria Otobai/Bavarian. PEKING no tiene ruta válida ni lookup canónico. | `ct_newCaseWorkOrderEvent` | v54 | **v55 activa** | Igual que el anterior | **E — superado por versión posterior** | Igual | F18, bloqueo de negocio N4 | No |
| Solo reconoce `RMBAVARIAN` y `RMOTOBAI`; PEKING queda sin Empresa de Orden de Trabajo. Debe tomar la Empresa de la OT, no del código legacy. | `BMW_Importar_Plantilla_Orden_de_Trabajo` | v11 | v11 | Existe en Git, pero **no está en los 20 Flows autorizados**. Ya registrado en `REGLAS_ALCANCE_AUTORIZADO.md` (actualización 2026-07-30) como uno de los "12 candidatos adicionales... quedan registrados como candidatos, no se tocan" | **H — fuera del alcance explícito del Sprint actual** | grep confirmado: `Decisions Empresa_Otobai/Empresa_Bavarian sobre BMW_Compania__c`; `REGLAS_ALCANCE_AUTORIZADO.md` líneas de la sección "candidatos mantenidos fuera del alcance confirmado" | No autorizado | No |
| Aunque guardan `Empresa_Operadora__c`, conservan decisiones Bavarian/Otobai, valores por defecto desde `$User.Empresa__c` y Pricebooks fijos. Además, hay una búsqueda que compara `Pricebook2.Name` contra un Id devuelto por el resolver; debe asignarse el Id directamente. | `Opp_flow_V3` | v30 | v30 | **Parcialmente vigente.** El nodo legacy `Encuentra_Price_Book` (decisiones Bavarian/Otobai) está confirmado **sin conectores entrantes** — código muerto, no ejecuta. El hallazgo de "Pricebook2.Name vs Id" **sí está vigente** — ver sección 4 para el detalle completo | **D — parcialmente vigente** | Trazado de grafo de conectores desde `<start>`; grep de `Obtener_PriceBook_Opp` y `Coloca_PB_en_Quote` | F13, ya remediado en su mayoría (QA de creación OK) | El defecto de Pricebook2.Name=Id sí requiere autorización |
| Mismo hallazgo | `Opp_Flow_V5` | v33 | v33 | Igual — nodo legacy muerto confirmado; bug de Pricebook2.Name=Id vigente. Adicionalmente, el defecto de la rama Taller (creaba Opportunity sin `Empresa_Operadora__c`) **ya fue corregido** en este mismo Flow, en v31-v33 | **D — parcialmente vigente** (mixto: rama Taller ya corregida, bug de recálculo de Pricebook sigue vigente) | `RESULTADO_REMEDIACION_OPP_FLOW_V5_TALLER_20260812.md`; grep de este bloque | F12, QA FUNCIONAL OK — creación y navegación | El bug de Pricebook2.Name=Id sí requiere autorización |
| Mismo hallazgo | `Opp_Flow_v6` | v82 | v82 | Igual — nodo legacy muerto confirmado en ambas rutas (principal y Mostrador); bug de Pricebook2.Name=Id vigente | **D — parcialmente vigente** | Trazado de grafo de dos rutas; grep de este bloque | F14, validación técnica OK / QA diferido | El bug sí requiere autorización |
| Mismo hallazgo | `Opportunity_Flow_V2` | v8 | v8 | Igual — nodo legacy muerto confirmado en ambas rutas (general y Mostrador); bug de Pricebook2.Name=Id vigente | **D — parcialmente vigente** | Trazado de grafo; grep de este bloque | F15, validación técnica OK / QA diferido | El bug sí requiere autorización |
| Crean Opportunities usando el campo legacy, pero no siempre escriben `Empresa_Operadora__c`. Deben persistir el lookup antes de resolver Pricebook o crear Quote. | `Opp_flow_v4` | v19 (citada por Luis) | **v16** (según `MATRIZ_CIERRE_SPRINT2.csv` F02) | La matriz autoritativa de Sprint 2 clasifica este Flow como **REVISADO SIN CAMBIO** (F02) — ya usa resolución dinámica por Empresa. No se encontró evidencia directa de que "no siempre" escriba `Empresa_Operadora__c`; sería necesario un análisis de datos reales adicional para confirmar o descartar esa afirmación específica | **I — no confirmado, requiere evidencia adicional** | `MATRIZ_CIERRE_SPRINT2.csv` fila F02 | F02, revisado sin cambio | No — no autorizado, y el hallazgo específico no está confirmado |
| Mismo hallazgo | `Opportunity_Flow` | v28 (citada por Luis) | **v25** (según `MATRIZ_CIERRE_SPRINT2.csv` F01) | Igual — clasificado **REVISADO SIN CAMBIO** (F01) por la matriz autoritativa | **I — no confirmado** | `MATRIZ_CIERRE_SPRINT2.csv` fila F01 | F01, revisado sin cambio | No |

---

# 4. Detalle del bug Pricebook2.Name = Id

Confirmado por lectura directa del XML actual de los 4 Flows. El patrón es **idéntico** en los cuatro.

## Mecanismo común (aplica a los 4 Flows)

- **Recurso que devuelve el Id:** la acción Apex `Resolver_Pricebook_Empresa` (invoca `EmpresaPricebookResolver`) retorna, entre otros campos, `pricebookId` — un **Id de Salesforce** del `Pricebook2` correcto para la Empresa/moneda resueltas.
- **Comparación incorrecta:** el `RecordLookup` `Obtener_PriceBook_Opp` filtra `Pricebook2 WHERE Name EqualTo {!Resolver_Pricebook_Empresa.pricebookId}` — es decir, compara el campo de texto `Name` contra un valor que es un **Id**, nunca un nombre. Esta condición **nunca puede ser verdadera** para ningún registro de `Pricebook2`.
- **Consecuencia funcional:** `Obtener_PriceBook_Opp` retorna siempre cero registros. Su salida `Obtener_PriceBook_Opp.Id` queda siempre `null`.
- **Cuándo se ejecuta esa ruta:** no es la ruta de creación inicial de Opportunity/Quote (que usa `Resolver_Pricebook_Empresa.pricebookId` directamente y por eso el QA de creación fue exitoso). Es una ruta **posterior**, activada cuando el Flow vuelve a abrir un Quote ya existente por su Id (`presupuestoid`) a través del RecordLookup `BMW_ObtenerPresupuesto`, y reintenta resolver/actualizar su Pricebook — típicamente un paso de "recálculo" más adelante en la misma interview.
- **Por qué el QA anterior pudo pasar:** todo el QA documentado (`RESULTADO_REMEDIACION_OPP_FLOW_V5_TALLER_20260812.md`, `RESULTADO_QA_REMEDIACION_OPP_FLOW_V3_20260812.md`, etc.) validó específicamente la **creación** de Opportunity y Quote, que usa `Resolver_Pricebook_Empresa.pricebookId` de forma directa en `CreateOpportunity`/`CreateQuote`. Ninguno de esos QA ejerció el camino de recálculo posterior (`BMW_ObtenerPresupuesto → Obtener_PriceBook_Opp`), por lo que el defecto nunca se manifestó en la evidencia recolectada.

## Detalle por Flow

### `Opp_flow_V3` (v30 activa)

| Campo | Detalle |
|---|---|
| Nodo exacto | `Obtener_PriceBook_Opp` (RecordLookup), alimentado por `BMW_ObtenerPresupuesto → Resolver_Pricebook_Empresa → Validar_Estado_Pricebook (regla EXITO) → Obtener_PriceBook_Opp` |
| Recurso que devuelve el Id | `Resolver_Pricebook_Empresa.pricebookId` |
| Comparación incorrecta | `Pricebook2.Name EqualTo Resolver_Pricebook_Empresa.pricebookId` |
| Consecuencia funcional | `Obtener_PriceBook_Opp.Id` siempre `null` |
| Dónde se usa el resultado nulo | `Coloca_PB_en_Quote`: `BMW_ObtenerPresupuesto.Pricebook2Id = Obtener_PriceBook_Opp.Id`; y un `recordUpdate` sobre Opportunity que también asigna `Pricebook2Id = Obtener_PriceBook_Opp.Id` |
| Impacto PEKING | El Quote/Opportunity quedaría con `Pricebook2Id = null` si esta ruta se ejecuta después de la creación inicial |
| Impacto Bavarian/Otobai | **Idéntico** — el bug no distingue empresa; cualquier empresa que pase por esta ruta de recálculo queda igualmente afectada |
| Corrección técnica mínima propuesta | Eliminar el `RecordLookup` `Obtener_PriceBook_Opp` y asignar directamente `Resolver_Pricebook_Empresa.pricebookId` donde hoy se usa `Obtener_PriceBook_Opp.Id` |
| ¿Requiere nuevo QA? | Sí — un QA específico de la ruta de recálculo/reapertura de Quote existente, para las 3 empresas |

### `Opp_Flow_V5` (v33 activa)

| Campo | Detalle |
|---|---|
| Nodo exacto | `Obtener_PriceBook_Opp`, mismo patrón de alimentación |
| Recurso que devuelve el Id | `Resolver_Pricebook_Empresa.pricebookId` |
| Comparación incorrecta | `Pricebook2.Name EqualTo Resolver_Pricebook_Empresa.pricebookId` |
| Consecuencia funcional | `Obtener_PriceBook_Opp.Id` siempre `null` |
| Dónde se usa el resultado nulo | Misma estructura de asignación posterior a la resolución (conector `Price_Book_vac_o`) |
| Impacto PEKING | Igual que arriba — no afecta la ruta de creación ya validada (v33, QA FUNCIONAL OK), sí afectaría un recálculo posterior |
| Impacto Bavarian/Otobai | Idéntico, sin distinción de empresa |
| Corrección técnica mínima propuesta | Igual — usar el Id del resolver directamente |
| ¿Requiere nuevo QA? | Sí, específico de la ruta de recálculo |

### `Opp_Flow_v6` (v82 activa)

| Campo | Detalle |
|---|---|
| Nodo exacto | `Obtener_PriceBook_Opp`, presente en ambas rutas (principal y Mostrador) |
| Recurso que devuelve el Id | `Resolver_Pricebook_Empresa.pricebookId` |
| Comparación incorrecta | `Pricebook2.Name EqualTo Resolver_Pricebook_Empresa.pricebookId` |
| Consecuencia funcional | `Obtener_PriceBook_Opp.Id` siempre `null` |
| Impacto PEKING | Igual — no afecta la creación ya validada |
| Impacto Bavarian/Otobai | Idéntico |
| Corrección técnica mínima propuesta | Igual |
| ¿Requiere nuevo QA? | Sí, para ambas rutas (principal y Mostrador) |

### `Opportunity_Flow_V2` (v8 activa)

| Campo | Detalle |
|---|---|
| Nodo exacto | `Obtener_PriceBook_Opp`, con dos conectores de salida observados (`Tiene_Precio_De_Venta` y `Price_Book_vac_o` según la rama) |
| Recurso que devuelve el Id | `Resolver_Pricebook_Empresa.pricebookId` |
| Comparación incorrecta | `Pricebook2.Name EqualTo Resolver_Pricebook_Empresa.pricebookId` |
| Consecuencia funcional | `Obtener_PriceBook_Opp.Id` siempre `null` |
| Impacto PEKING | Igual — no afecta la creación ya validada (general/Taller); Mostrador no ha sido QA'd todavía |
| Impacto Bavarian/Otobai | Idéntico |
| Corrección técnica mínima propuesta | Igual |
| ¿Requiere nuevo QA? | Sí |

**No se implementó ninguna corrección.** Este es un hallazgo para autorización, no una acción ejecutada.

---

# 5. Detalle N2 — propagación Empresa

## `Work_Order_from_Quote` (v10 activa)

| Campo | Detalle |
|---|---|
| Nodo Create WorkOrder | `Crear_la_Ot` (RecordCreate, objeto `WorkOrder`) |
| Valor actual de `empresaFactura__c` | Se asigna dinámicamente desde una variable (`RMOTOBAI`, nombre heredado) que a su vez se resuelve vía `Empresa_Operadora__r.Codigo_ERP__c` (corregido en un bloque anterior de este mismo proyecto) o, si el lookup está vacío, vía el fallback legacy Bavarian/Otobai — funciona correctamente para las 3 empresas |
| Ausencia de `empresaFacturaCP__c` | **Confirmada.** No existe ninguna `inputAssignment` para ese campo en `Crear_la_Ot`. Grep del archivo completo no encuentra ninguna referencia a `empresaFacturaCP__c` |
| Fuente correcta disponible | `Opportunity.Empresa_Operadora__c`, ya leída por el Flow como `Datos_Opp.Empresa_Operadora__c` para resolver `empresaFactura__c` — el mismo valor podría propagarse directamente al lookup |
| Impacto downstream | `CreateWoliFromExpense` y `AgregarManoObra` (ambos ya QA FUNCIONAL OK) usan `WorkOrder.empresaFacturaCP__c` como fuente principal de Empresa; si esa Orden de Trabajo no la trae, ambos Flows caen a su fallback legacy Bavarian/Otobai únicamente — PEKING no se resolvería para una OT creada por este Flow sin el workaround manual ya documentado en el dataset QA |
| Corrección mínima propuesta | Agregar una `inputAssignment` en `Crear_la_Ot`: `empresaFacturaCP__c = Datos_Opp.Empresa_Operadora__c` |
| Estado respecto al cierre Sprint 2 | Dentro de F09, bloqueado formalmente por N2 (definición de bodega/territorio/reserva/despacho/taller). Esta propagación específica es **técnicamente independiente** de esa definición de negocio — podría corregirse sin esperar la respuesta N2 |

## `Work_Order_from_Quote_Selective` (v8 activa)

| Campo | Detalle |
|---|---|
| Nodo Create WorkOrder | `Crear_la_Ot` (idéntico patrón) |
| Valor actual de `empresaFactura__c` | Igual que arriba |
| Ausencia de `empresaFacturaCP__c` | Confirmada, idéntico patrón |
| Fuente correcta disponible | Igual — `Datos_Opp.Empresa_Operadora__c` |
| Impacto downstream | Igual |
| Corrección mínima propuesta | Igual |
| Estado respecto al cierre Sprint 2 | Dentro de F08, mismo bloqueo N2 |

---

# 6. Matriz COMPLETA de clases Apex

Todas las clases citadas por la auditoría de Luis, sin omitir ninguna, aunque estén fuera de alcance.

| Clase | Hallazgo Luis | Estado actual | ¿Bloquea PEKING hoy? | Clasificación | Sprint/bloque | Corrección necesaria | Prioridad | Evidencia |
|---|---|---|---|---|---|---|---|---|
| `QuoteSoftlandPedidoService` | Mapeo quemado Bavarian/Otobai/PEKING; lista cerrada de compañías válidas | Ruta primaria ya usa `EmpresaResolver.resolve(Empresa_Operadora__c)`; solo el fallback legacy (`resolveLegacyCompanyCode`, activo solo si el lookup está vacío) y el validador `validateSupportedCompany` siguen con literal `RMPEKING` | No, mientras el lookup esté poblado | **D** | No autorizado | Hacer el fallback configurable/temporal; abrir la lista cerrada | Media | `QuoteSoftlandPedidoService.cls` líneas 146-192; `git log` commit `c320138` |
| `HttpCalloutGetProductRefPrices` | Podría enviar Bavarian por defecto | Envía `'RMBAVARIAN'` literal siempre; versión dinámica comentada en el código; llamadores (`WoliGridController`/`2`) pasan la empresa real pero se ignora | **Sí** | **C** | No autorizado | Usar el parámetro `empresaFactura` ya recibido | **Alta** | `HttpCalloutGetProductRefPrices.cls:18-19` |
| `HttpCalloutGetProductFreshRefPrices` | Fallback a Bavarian | `'RMBAVARIAN'` solo como fallback si `compania` viene vacío; **sin llamador vivo** en todo el repo (solo su propia prueba) | No | **G** | No autorizado | Ninguna urgente; código muerto | Baja | `HttpCalloutGetProductFreshRefPrices.cls:14` |
| `ProductoLocalizacionHelper` | Igual patrón | `compania` recibido como parámetro pero ignorado; `bodyMap.put('compania','RMBAVARIAN')` fijo | **Sí** | **C** | No autorizado | Usar el parámetro recibido | **Alta** | `ProductoLocalizacionHelper.cls:11,32` |
| `http_Helper` | Binario Bavarian/Otobai sin PEKING | `generateOrderJSON`: `empresaQueFactura__c=='Bavarian'?'RMBAVARIAN':'RMOTOBAI'`; **sin llamador vivo** de ese método (solo `generateAccountJSON`, sin lógica de empresa, sí se usa) | No | **G** | No autorizado | Ninguna urgente; código muerto | Baja | `http_Helper.cls:57` |
| `BatchGetCatalogoSoftland` | Prefijo de bodega solo para Otobai | **Ya corregido y validado** — prefijo derivado genéricamente del código de compañía | No | **A** | Ya ejecutado, remediación técnica (commit `5d34f4c`) | Ninguna | — | `RESULTADO_PRECHECK_REGRESIONES_20260812.md` |
| `ScheduleGetCatalogoSoftland` | (nombrada en la auditoría) | **No existe** esa clase — solo `BatchGetCatalogoSoftland` | N/A | **I** | N/A | Verificar con Luis a qué clase se refería | — | Búsqueda de archivo, sin resultados |
| `ScheduleGetCategoriaClienteSoftland` | No debe tener lista fija de empresas | **Nunca sincronizó Otobai**, ni antes ni después del trabajo PEKING — confirmado por historial Git completo desde el commit inicial | No | **E** | Ya investigado (2026-08-12), no es regresión | Ninguna | — | `RESULTADO_PRECHECK_REGRESIONES_20260812.md` |
| `ScheduleGetCentroCostoSoftland` | Igual | Igual | No | **E** | Igual | Ninguna | — | Igual |
| `ScheduleGetCondicionPagoSoftland` | Igual | Igual | No | **E** | Igual | Ninguna | — | Igual |
| `ScheduleGetCuentaContableSoftland` | Igual | Igual | No | **E** | Igual | Ninguna | — | Igual |
| `ScheduleGetImpuestoSoftland` | Igual | Igual | No | **E** | Igual | Ninguna | — | Igual |
| `ScheduleGetSubtipoDocumentoSoftland` | Igual | Igual | No | **E** | Igual | Ninguna | — | Igual |
| `QuoteService` | (agrupada en el patrón general) | **Ya corregido y validado** — resuelve vía `Empresa_Operadora__c`/`EmpresaResolver`; el bloqueo de bodega PEKING es un gate de negocio deliberado (`PEKING_BODEGA_MESSAGE`), no un fallback silencioso | No silenciosamente | **A** | Reconciliado en cierre técnico Sprint 1 (`c320138`) | Ninguna técnica | — | `QuoteService.cls:37-100` |
| `productJSON` | (agrupada) | **Ya corregido y validado** — soporta las 3 empresas; es el patrón de referencia usado para `precioProductoJSON` | No | **A** | Reconciliado Sprint 1 | Ninguna | — | `productJSON.cls:377-407` |
| `precioProductoJSON` | (agrupada) | **Ya corregido y validado** | No | **A** | Ya ejecutado (commit `5d34f4c`) | Ninguna | — | `precioProductoJSON.cls:40-70` |
| `ProductSearcherController` | (agrupada) | Rama "mano de obra" ya resuelve las 3 empresas; rama "vehículo" sigue llamando incondicionalmente al servicio Bavarian | Parcial — solo rama vehículo | **D** | No autorizado (LWC consumidor `C02` es `PENDIENTE DE CONFIRMACIÓN`) | Extender la rama vehículo al mismo patrón | Media | `ProductSearcherController.cls:95,106,152-158` |
| `ServicioConsDispBodegaQuoli` | Binario Bavarian/Otobai | **Ya corregido y validado** (commit `a0dbcf8`) — resuelve vía `Empresa_Operadora__c`; PEKING bloqueado con excepción controlada por falta de dato de bodega | No silenciosamente | **A** | Ya remediado | Ninguna técnica | — | `ServicioConsDispBodegaQuoli.cls:266-270` |
| `ServicioCrearSCQuote` | Igual | **Ya corregido y validado** (commit `5999793`) | No silenciosamente | **A** | Ya remediado | Ninguna | — | `ServicioCrearSCQuote.cls:221-245` |
| `ServicioEliminarReservaArticuloQuote` | Igual | **Ya corregido y validado** (commit `1e73956`) | No silenciosamente | **A** | Ya remediado | Ninguna | — | `ServicioEliminarReservaArticuloQuote.cls:301-327` |
| `ServicioReservaApartadoArticulosQuote` | Igual | **Ya corregido y validado** (commit `73b5d57`, con prueba dedicada `lookupPekingDoesNotFallbackToOtobai`) | No silenciosamente | **A** | Ya remediado | Ninguna | — | `ServicioReservaApartadoArticulosQuote.cls:294-320` |
| `servicioEliminarReserva` | Igual | **Ya corregido y validado** | No silenciosamente | **A** | Reconciliado Sprint 1 | Ninguna | — | `servicioEliminarReserva.cls:18-22,75-82` |
| `servicioReservas` | Igual | **Ya corregido y validado** | No silenciosamente | **A** | Reconciliado Sprint 1 | Ninguna | — | `servicioReservas.cls:49-50,103-110` |
| `ServicioEliminarReservaArticulo` | `"compania":"RMBAVARIAN"` encontrado | **Falso positivo** — literal solo dentro de un mock de prueba; lógica real usa `workOrder.EmpresaFactura__c` dinámicamente | No | **E** | No era hallazgo real | Ninguna | — | `ServicioEliminarReservaArticulo.cls:71` (mock), línea 37 (real) |
| `ServicioReservaApartadoArticulos` | Igual | **Falso positivo**, mismo caso | No | **E** | No era hallazgo real | Ninguna | — | `ServicioReservaApartadoArticulos.cls:101` (mock), línea 67 (real) |
| `RM_VN_CambiarUbicacion_Ctrl` | (grupo de controllers) | Normaliza Bavarian/Otobai; PEKING explícitamente rechazado con excepción controlada | Bloqueo intencional, no silencioso | **H** (+ F, bloqueo de negocio de fondo) | No autorizado | Ninguna sin definición de negocio | — | `getCompanyName()` L102-104 |
| `BMW_LineaPlantillaEmpresa` | Igual | Fallback binario Bavarian/Otobai cuando `Empresa_Operadora__c` es null; sin rama PEKING, cae en excepción genérica | Sí, si el lookup está vacío | **H** | No autorizado | Agregar manejo explícito de PEKING en el fallback | — | L27-31 |
| `ProductControllerTwo` | Igual | Fallback binario; valores no mapeados pasan sin cambio | Parcial | **H** | No autorizado | Ninguna | — | `resolveCompanyCode()` L440-446 |
| `QuoterController` | Igual | Mapa hardcodeado compañía→nombre de Pricebook (incluye PEKING); no es lookup dinámico por Empresa+moneda; fallback legacy binario | No — PEKING está en el mapa | **H** | No autorizado | Migrar a resolución dinámica | — | L10-14, L223-226 |
| `BusquedaDetalladaController` | Igual | Lookup de Pricebook por `Name LIKE 'Bavarian%'/'Otobai%'`; sin rama PEKING | **Sí** — sin cobertura PEKING | **H** | No autorizado | Agregar rama o migrar a resolución por Empresa | — | L10-19 |
| `CrearPlandeVenta` | Igual | Switch cerrado de RecordType; cualquier marca no reconocida (no solo PEKING) cae silenciosamente en Otobai; múltiples Ids hardcodeados (Pricebook/Account/RecordType/CentroCosto) | **Sí, y también para cualquier marca desconocida** | **H** (hallazgo más severo técnicamente del grupo) | No autorizado | Reemplazar el switch cerrado por resolución configurable | — | L65-77, Ids en L58,61,67,69,73,75,81-85,98,100,125,156,161,173 |
| `OpportunityServiceInvoker` | Igual | Resolver legacy por `Pricebook2.Name`; PEKING explícitamente bloqueado con excepción controlada | Bloqueo intencional | **H** (+ F de fondo) | No autorizado | Ninguna sin definición de negocio | — | L105-106 |
| `Registrar_Anticipo_Controller` | Igual | Mismo patrón que el anterior | Bloqueo intencional | **H** (+ F) | No autorizado | Ninguna sin definición de negocio | — | L255-258 |
| `SolicitudAprobacionTesoreria` | Igual | **No existe en este Git** — solo en Partial (`ApexClass.Id=01pPH0000040TUNYA2`, confirmado read-only). Ternario cerrado Bavarian/Otobay→RMBAVARIAN/RMOTOBAI, `null` silencioso para cualquier otro valor | Sí — degrada silenciosamente a `null` | **H** (+ drift Git/Partial) | No autorizado, drift a documentar | Sincronizar a Git primero, luego evaluar corrección | — | Consulta Tooling API read-only |
| `VN_RQ106_AnticipoController` | Igual | **No existe en este Git** — solo en Partial (`Id=01pPH0000040TUOYA2`). If/else cerrado, rechaza explícitamente cualquier otro valor | Bloqueo intencional (excepción) | **H** (+ drift Git/Partial) | No autorizado, drift a documentar | Sincronizar a Git primero | — | Consulta Tooling API read-only |
| `WoliGridController` | Igual | `empresaFactura` pasado como String opaco, sin literal de compañía en esta clase | No hay lógica de empresa aquí | **H** | No autorizado | Ninguna | — | L38,45 |
| `WoliGridController2` | Igual | Mismo patrón de paso directo | No | **H** | No autorizado | Ninguna | — | L16,23 |
| `TrabajoQuoteController` | Igual (también depende de `TipoDeCargoConManoDeObra__c`, ver sección 8) | Conjunto cerrado `{'RMBAVARIAN','RMOTOBAI','RMPEKING'}` cuando el lookup está poblado; fallback legacy binario sin rama PEKING | Parcial | **H** | No autorizado | Ninguna sin autorización | — | L196-209 |
| `TrabajoController` | Igual (también depende de `TipoDeCargoConManoDeObra__c`) | Guarda de lista cerrada, ya incluye `RMPEKING` — no bloquea | No | **H** | No autorizado | Ninguna | — | L213-217/104-108 |
| `BMWVinScanTrabajoGenerator` | Igual (también depende de `TipoDeCargoConManoDeObra__c`) | Misma guarda de lista cerrada (aparece dos veces), ya incluye `RMPEKING` | No | **H** | No autorizado | Ninguna | — | L104-108, L565-567 |
| `EmpresaPricebookResolver` | "Funciona correctamente cuando recibe el lookup Empresa, pero conserva un mapa legacy Bavarian/Otobai; no agregar PEKING, hay que retirar ese fallback" | Confirmado — `LEGACY_COMPANY_TO_ERP_CODE` sigue solo `BAVARIAN`/`OTOBAI`; usado solo cuando `empresaId` es null (fallback), nunca bloquea la ruta principal de PEKING | No | **G** | No autorizado (es dependencia técnica de varios Flows autorizados, pero la clase en sí no está nombrada) | Retirar el fallback legacy cuando el negocio lo autorice | — | L8-12 |
| `HttpCalloutCreateKit` | "Hoy resuelve Omoda/Jaecoo hacia RMPEKING y tipo V. Falta sacar la relación Marca/Record Type→Empresa a configuración" | **Contradice la auditoría** — no se encontró ninguna referencia a Omoda, Jaecoo ni RMPEKING; es un binario Bavarian/Otobai puro | **Sí** — cualquier Opportunity Omoda/Jaecoo se clasificaría como `RMOTOBAI` | **C** (defecto activo, no solo deuda futura) | No autorizado | Agregar manejo real de Omoda/Jaecoo→RMPEKING | **Alta** (contradicción severa con la auditoría) | L56, L61-62 — sin ningún string "Omoda"/"Jaecoo"/"RMPEKING" en todo el archivo |
| `BMW_ChangeCurrencyWOWOLI` | Ya contempla PEKING, no escalable | Confirmado — mapas incluyen `'PEKING Local'`/`'PEKING Dólares'` explícitamente | No | **G** | No autorizado | Migrar a configuración cuando se agregue una 4ª empresa | — | L2-18 |
| `QuoteController` | Igual | Igual patrón, PEKING incluido | No | **G** | No autorizado | Igual | — | L2-18 |
| `UpdateCurrencyScheduler` | Igual | SOQL y `if/elseif` incluyen PEKING explícitamente | No | **G** | No autorizado | Igual | — | L5, L28-35 |
| `cT_QuoteCrcPDFController` | Igual | `elseif` incluye PEKING | No | **G** | No autorizado | Igual | — | L96-97 |
| `cT_QuoteUsdPDFController` | Igual | Igual | No | **G** | No autorizado | Igual | — | L77-78 |
| `ServicioEnvioEncuestaSoftland` | "Schedulers no deben tener lista fija de empresas" | No es Schedulable en sí (invocado desde Flow); `compania` recibido del llamador, default `'RMBAVARIAN'` solo si viene vacío | No | **E** | Ya investigado, no es la regresión de los schedulers | Ninguna | — | L18, L83 |
| `BatchOppActivityUploader` | Ya contempla PEKING, no escalable | **Contradice el marco de "deuda futura"** — hardcodea `'Bavarian Motors CR SA'` como distribuidor incondicionalmente para cualquier Task/Event | **Sí** — branding/legal incorrecto hoy, no solo a futuro | **C** | No autorizado | Resolver distribuidor por Empresa | **Alta** (defecto de datos activo) | L99, L110, L142 |
| `cT_QuotePDFEmail` | Igual | Branches solo por `marca__c`, no por Empresa; todas las ramas hardcodean "BAVARIAN MOTORS CR S.A.", dirección/URLs BMW en el PDF emitido | **Sí** — branding incorrecto hoy para cualquier empresa no-Bavarian | **C** | No autorizado | Resolver branding por Empresa | **Alta** | L120, L166, L210, L254 |
| `BMWServiceQuoteApprovalEmailInvocable` | Igual | Lista hardcodeada de sucursales para destinatarios internos; territorio no reconocido simplemente omite ese destinatario específico, no falla | No — degrada sin bloquear | **G** | No autorizado | Migrar a configuración | — | `getInternalRecipients()` L235-249 |
| `ServicioCitas` | "No habilitar agregando PEKING a un if; definir primero si comparte operación" | Sin lógica de empresa real; solo traducción de etiqueta "Otobai" en sucursal | No hay lógica que bloquee — pendiente de decisión de negocio | **D** | No autorizado | Ninguna sin decisión de negocio | — | L165, L210, L559, L596, L1195 |
| `ServicioCitasFieldService` | Igual | Mismo patrón | Igual | **D** | No autorizado | Igual | — | L305, L355, L540, L569, L984, L1878, L2047, L2068 |
| `CT_nuevaCita_controller` | Igual | Igual | Igual | **D** | No autorizado | Igual | — | L493-497 |
| `cT_nuevaCitaGarantia_controller` | Igual | Igual | Igual | **D** | No autorizado | Igual | — | L496 |
| `getHorasCitasFlow` | Igual | Igual | Igual | **D** | No autorizado | Igual | — | L53-57, L323 |
| `savePDFfile` | Igual | Ruteo de correo por sucursal hardcodeado; sin entrada PEKING; retorna `null` sin coincidencia | Config incompleta, degrada a `null` | **D** | No autorizado | Ninguna sin catálogo oficial de sucursales | — | L263, L273 |
| `KPIEstadoTallerController` | Igual | **Sin ninguna lógica de Empresa/marca en todo el archivo** — inclusión cuestionable en este grupo de la auditoría | No aplica | **G** | No autorizado | Ninguna | — | Revisión completa del archivo |
| `RQ329_INS_CounterService` | Igual | **No se localizó en el repositorio** — glob/búsqueda de nombre exacto sin resultados | No confirmable | **I** | No autorizado | Verificar con Luis el nombre/repo correcto | — | Búsqueda exhaustiva sin resultados |
| `OrderBatch` | Igual | Resuelve dinámicamente desde `Work_Order__r.empresaFactura__c`; el único literal `RMBAVARIAN` está dentro de `Test.isRunningTest()`, no en producción | No | **G** | No autorizado | Ninguna urgente | — | L35, L37 |
| `OpportunityOriginService` | "No bloquean PEKING hoy, deuda técnica" | **No existe en este repositorio/rama** — cero coincidencias en cualquier búsqueda | No confirmable | **I** | No autorizado | Verificar con Luis el nombre/repo/rama correcto | — | Glob y grep exhaustivos, sin resultados |
| `RM_OpportunityPreCloseService` | Igual | **No existe en este repositorio/rama** | No confirmable | **I** | No autorizado | Igual | — | Igual |
| `OpportunityTriggerHandler` | Igual | Omoda y Jaecoo ya hardcodeados como 2 de 9 ramas literales de `RecordType.Name` (junto a BMW, Polaris, MINI, Kawasaki, Motorrad, Harley-Davidson, KTM comentado); sin `else` — un RecordType no reconocido (ej. futuro PEKING propio) simplemente no asigna Director/Gerente/Jefe, no bloquea el guardado | No — degrada silenciosamente sin bloquear | **G** | No autorizado | Migrar a configuración cuando se agregue una nueva marca | — | L116-420, especialmente L395-420 |
| `ct_traficoOrigenWeb` | Igual | **Sin ninguna referencia** a Bavarian/Otobai/RMBAVARIAN/RMOTOBAI/RMPEKING/Omoda/Jaecoo/PEKING en las 307 líneas | No aplica | **G** | No autorizado | Ninguna | — | Revisión completa del archivo |

## 6.1 Corrección técnica inmediata

Defecto real, activo, silencioso, sin bloqueo de negocio de por medio — pero **ninguna está autorizada todavía**:

- `HttpCalloutGetProductRefPrices` — ignora el parámetro de empresa recibido.
- `ProductoLocalizacionHelper` — mismo patrón.
- `HttpCalloutCreateKit` — sin manejo de Omoda/Jaecoo/PEKING, contradice la auditoría.
- `BatchOppActivityUploader` — branding Bavarian incondicional.
- `cT_QuotePDFEmail` — branding Bavarian incondicional en PDFs emitidos.

## 6.2 Corrección necesaria pero no bloquea el cierre actual

- `ProductSearcherController` (rama vehículo) — el LWC que lo consume no está autorizado.
- `BusquedaDetalladaController` — sin cobertura PEKING en el lookup de Pricebook por nombre.
- `CrearPlandeVenta` — severidad técnica alta, pero no está en ninguna ruta del cierre de Sprint 2.
- `QuoteSoftlandPedidoService` — fallback y validador, solo relevante cuando el lookup está vacío.

## 6.3 Deuda técnica / arquitectura futura

`EmpresaPricebookResolver`, `BMW_ChangeCurrencyWOWOLI`, `QuoteController`, `UpdateCurrencyScheduler`, `cT_QuoteCrcPDFController`, `cT_QuoteUsdPDFController`, `BMWServiceQuoteApprovalEmailInvocable`, `KPIEstadoTallerController`, `OrderBatch`, `OpportunityTriggerHandler`, `ct_traficoOrigenWeb`, `HttpCalloutGetProductFreshRefPrices` (código muerto), `http_Helper` (código muerto).

## 6.4 Fuera del alcance autorizado actual

Todas las clases marcadas **H** en la tabla — la gran mayoría del grupo de 15 controllers (`RM_VN_CambiarUbicacion_Ctrl`, `BMW_LineaPlantillaEmpresa`, `ProductControllerTwo`, `QuoterController`, `OpportunityServiceInvoker`, `Registrar_Anticipo_Controller`, `SolicitudAprobacionTesoreria`, `VN_RQ106_AnticipoController`, `WoliGridController`, `WoliGridController2`, `TrabajoQuoteController`, `TrabajoController`, `BMWVinScanTrabajoGenerator`). Ninguna aparece en `MATRIZ_CIERRE_SPRINT2.csv` ni en `REGLAS_ALCANCE_AUTORIZADO.md`.

## 6.5 No confirmadas / no localizadas

- `ScheduleGetCatalogoSoftland` — no existe, posible confusión de nombre con `BatchGetCatalogoSoftland`.
- `RQ329_INS_CounterService` — no localizada en el repositorio.
- `OpportunityOriginService` — no localizada.
- `RM_OpportunityPreCloseService` — no localizada.

---

# 7. Discrepancias con la auditoría de Luis

### `HttpCalloutCreateKit`

- **Qué afirma la auditoría:** "hoy resuelve Omoda/Jaecoo hacia `RMPEKING` y tipo `V`, que corresponde a lo solicitado. Lo pendiente es sacar la relación Marca/Record Type → Empresa → tipo de vehículo de Apex y moverla a configuración."
- **Qué existe realmente:** el código actual contiene únicamente un binario `List<String> rmbavarian = {'BMW','MINI','Motorrad'}` con `rmbavarian.contains(...) ? 'RMBAVARIAN' : 'RMOTOBAI'`. No existe ningún string `"Omoda"`, `"Jaecoo"` ni `"RMPEKING"` en todo el archivo.
- **Evidencia:** `HttpCalloutCreateKit.cls` líneas 56, 61-62; búsqueda exhaustiva de los tres strings citados sin resultados.
- **Conclusión:** una Opportunity de Omoda o Jaecoo (marcas PEKING) se clasificaría hoy incorrectamente como `RMOTOBAI`, tipo `M` — lo opuesto a lo que afirma la auditoría.

### Clases citadas que no existen en este repositorio

- `OpportunityOriginService`
- `RM_OpportunityPreCloseService`
- `ScheduleGetCatalogoSoftland` (posible confusión con `BatchGetCatalogoSoftland`)
- `RQ329_INS_CounterService`

### Clases que viven únicamente en Partial (no en Git)

- `SolicitudAprobacionTesoreria` (`ApexClass.Id=01pPH0000040TUNYA2`, confirmado vía Tooling API read-only)
- `VN_RQ106_AnticipoController` (`Id=01pPH0000040TUOYA2`)
- `Work_Order_On_Create_Create_OPP_and_Quote_and_Update_WO_Values` (Flow, `v13` activa en Partial, confirmado vía Tooling API)

### Versiones de Flow desactualizadas o divergentes en la auditoría

- `Opp_flow_v4`: auditoría cita v19; `MATRIZ_CIERRE_SPRINT2.csv` (F02) registra v16 como la versión activa reconciliada.
- `Opportunity_Flow`: auditoría cita v28; `MATRIZ_CIERRE_SPRINT2.csv` (F01) registra v25.
- `aperturaCaseWorOrderEvent`: auditoría cita v20; activa hoy es v21 (N4 ya desplegado).
- `ct_newCaseWorkOrderEvent`: auditoría cita v54; activa hoy es v55.
- `Opp_flow_V3`, `Opp_Flow_V5`, `Opp_Flow_v6`, `Opportunity_Flow_V2`: las versiones citadas por Luis (v30/v33/v82/v8) **sí coinciden** con las activas — la auditoría de Luis es posterior a las remediaciones de navegación/Taller de estos 4 Flows, no anterior.

### Hallazgos superados por cambios posteriores

- Los 6 `ScheduleGet*Softland` — la auditoría los agrupa como si hubieran perdido soporte de Otobai; investigación exhaustiva (2026-08-12) confirmó que **nunca lo tuvieron**, desde el commit inicial del repositorio.
- `aperturaCaseWorOrderEvent`/`ct_newCaseWorkOrderEvent` — N4 ya se implementó técnicamente (`ServiceTerritory.Empresa__c`) después de la fecha implícita de gran parte del análisis de la auditoría.
- La rama Taller de `Opp_Flow_V5` (creaba Opportunity sin `Empresa_Operadora__c`) — ya remediada, con QA funcional OK confirmado en v33.

---

# 8. TipoDeCargoConManoDeObra__c

| Aspecto | Hallazgo |
|---|---|
| Campo `Empresa__c` | Picklist restringido, valores `RMBAVARIAN`/`RMOTOBAI`/`RMPEKING` (label "PEKING"), los tres activos. Sin cambios desde la auditoría |
| Configuraciones por empresa (hoy) | `RMBAVARIAN=12`, `RMOTOBAI=3`, `RMPEKING=0` — total 15 filas. El "0 PEKING" persiste sin cambios al 2026-08-13 |
| Consumidores Apex | `TrabajoQuoteController.saveTrabajo`, `TrabajoController.saveSubtrabajos`, `BMWVinScanTrabajoGenerator` (dos métodos) — los tres consultan por el valor **string literal** de `Empresa__c` (no por Id/lookup) y toman el primer resultado sin `ORDER BY` |
| Duplicados | Confirmado: `RMBAVARIAN / BSI / Motocicleta` tiene exactamente 2 filas (verificado vía `GROUP BY ... HAVING COUNT(Id) > 1`) |
| PEKING | Las tres clases consumidoras ya resuelven `empresa` vía `EmpresaResolver.resolve(...)` (o fallback legacy) y validan explícitamente contra un conjunto de 3 vías que incluye `RMPEKING` — es decir, el código **sí funcionaría** para PEKING si existieran filas, pero no existen |
| Dependencia de PBE | Distinta y separada de este catálogo — `AgregarManoObra` (Flow) no usa `TipoDeCargoConManoDeObra__c` en absoluto; resuelve productos de mano de obra directamente vía `Product2.tipoProducto__c = 'Mano de Obra'` + `PricebookEntry`. Confirmado por grep sin coincidencias en el Flow |
| Qué es funcional inmediato | El picklist ya soporta PEKING (**A** — ya corregido, nada que hacer) |
| Qué es deuda técnica | Migrar los 3 consumidores de comparación por string a lookup por Id (`EmpresaCatalogo__c → Empresa__c`) — recomendación de mediano plazo de Luis, clasificada **G** |
| Qué requeriría nuevo alcance | Configurar las combinaciones PEKING de tipo de cargo/tipo de vehículo/producto/Pricebook y crear los PBE correspondientes — requiere definición de negocio, clasificado **H** (no autorizado, no está en `MATRIZ_CIERRE_SPRINT2.csv` ni en `REGLAS_ALCANCE_AUTORIZADO.md`); la clave única para evitar duplicados como el de Bavarian sigue **vigente** (**C**) independientemente de la definición de negocio |

Ni el objeto ni las 3 clases consumidoras están nombrados en ningún documento de alcance autorizado de Sprint 2.

---

# 9. Hallazgos todavía vigentes

| Hallazgo vigente | Riesgo | Sprint/bloque | Dependencia | Próximo paso recomendado |
|---|---|---|---|---|
| `Pricebook2.Name = Id` en 4 Flows Opportunity (recálculo de Pricebook) | **Alto** — afecta Bavarian y Otobai también, en Flows ya "QA OK" | Dentro de Sprint 2, Flows ya autorizados (F12-F15) | Ninguna de negocio, puramente técnico | Autorización explícita para reemplazar el `RecordLookup` por asignación directa del Id |
| `Work_Order_from_Quote`/`_Selective` no propagan `empresaFacturaCP__c` | Medio — WorkOrders quedan sin el lookup canónico que Flows dependientes usan como fuente principal | F08/F09, dentro de N2 | Técnicamente independiente del bloqueo de negocio N2 | Autorización explícita para agregar la asignación al crear la OT |
| `HttpCalloutGetProductRefPrices` / `ProductoLocalizacionHelper` ignoran el parámetro de empresa recibido | Medio — datos de precio/ubicación incorrectos silenciosamente | No autorizado | Ninguna | Solicitar autorización por nombre si se considera prioritario |
| `HttpCalloutCreateKit` sin manejo de Omoda/Jaecoo/PEKING (contradice la auditoría) | Medio — Opportunities Omoda/Jaecoo se clasifican como Otobai | No autorizado | Ninguna | Reportar la discrepancia a Luis; solicitar autorización si se confirma prioridad |
| `BatchOppActivityUploader` / `cT_QuotePDFEmail` hardcodean razón social Bavarian | Medio — branding/legal incorrecto para cualquier empresa no-Bavarian | No autorizado | Decisión de negocio sobre razón social PEKING | Esperar definición de negocio antes de tocar código |
| `CrearPlandeVenta`: marca no reconocida cae en Otobai + Ids hardcodeados | Medio-alto en severidad técnica | No autorizado | Ninguna | Reportar severidad; requiere autorización explícita |
| `QuoteSoftlandPedidoService`: fallback legacy y validador siguen con literal PEKING | Bajo — solo afecta cuando el lookup está vacío | No autorizado | Ninguna | Baja prioridad, la ruta principal ya funciona |
| `TipoDeCargoConManoDeObra__c`: 0 filas PEKING, duplicado Bavarian sin clave única | Bajo hoy (el fallback solo se usa cuando falta mano de obra directa) | No autorizado, requiere catálogo oficial | Definición de negocio de combinaciones PEKING | Esperar definición de negocio |
| Drift Git/Partial: `SolicitudAprobacionTesoreria`, `VN_RQ106_AnticipoController`, `Work_Order_On_Create_Create_OPP_and_Quote_and_Update_WO_Values` existen en Partial pero no en Git | Bajo (trazabilidad, no funcional) | Fuera de Sprint 2 | Ninguna | Considerar sincronizar Git↔Partial en un bloque de mantenimiento separado |

---

# 10. Impacto en Sprint 2

## Sí pertenece al Sprint 2 ya autorizado

- El bug de `Pricebook2.Name = Id` — está dentro de `Opp_flow_V3` (F13), `Opp_Flow_V5` (F12), `Opp_Flow_v6` (F14), `Opportunity_Flow_V2` (F15), los cuatro parte de los 20 Flows autorizados.
- La falta de propagación de `empresaFacturaCP__c` — está dentro de `Work_Order_from_Quote` (F09) y `Work_Order_from_Quote_Selective` (F08), parte de los 20 Flows autorizados, dentro del bloqueo N2.
- N4 (`aperturaCaseWorOrderEvent` F17, `ct_newCaseWorkOrderEvent` F18) — ya desplegado técnicamente, QA funcional pendiente; sigue siendo bloqueo de negocio formal hasta esa QA.
- N3 (`SegregateWOLIs` F10) — sigue como bloqueo de negocio, pendiente de confirmación de Diego.

## No pertenece a Sprint 2

- Las ~63 clases Apex de la auditoría (con la excepción de las ya remediadas bajo el gate de "remediación técnica" en bloques anteriores: `precioProductoJSON`, `BatchGetCatalogoSoftland`, `ServicioConsDispBodegaQuoli`, `ServicioCrearSCQuote`, `ServicioEliminarReservaArticuloQuote`, `ServicioReservaApartadoArticulosQuote`).
- `Work_Order_On_Create_Create_OPP_and_Quote_and_Update_WO_Values` y `BMW_Importar_Plantilla_Orden_de_Trabajo` — ambos fuera de los 20 Flows.
- `TipoDeCargoConManoDeObra__c` y sus 3 clases consumidoras.

## Requiere autorización técnica (no definición de negocio)

- Corregir el bug de `Pricebook2.Name = Id`.
- Propagar `empresaFacturaCP__c` en `Work_Order_from_Quote`/`_Selective`.

## Requiere definición de negocio

- N2 (bodega/territorio/reserva/despacho/taller oficiales de PEKING).
- N3 (política de garantía PEKING, confirmación de Diego).
- N4 (servicios/agenda/sucursales/territorios oficiales de PEKING).
- Catálogo `TipoDeCargoConManoDeObra__c` para PEKING.
- Razón social/branding oficial de PEKING (relevante para `BatchOppActivityUploader`, `cT_QuotePDFEmail`, `QuoteSoftlandPedidoService`).

No se amplió el alcance de Sprint 2 en ningún punto de este documento.

---

# 11. Impacto en Sprint 3 / Sprint 4 / otros

Ningún hallazgo de este documento se asigna automáticamente a otro Sprint. Clasificación de dónde correspondería evaluarse, sin convertir nada en trabajo:

- **Clases Apex fuera de alcance (grupos 6.1–6.5):** requieren primero una decisión de Luis/Diego sobre si se incorporan a un bloque de "deuda técnica Apex" — podría ser Sprint 2 tardío, Sprint 3, o un bloque de mantenimiento independiente. No hay evidencia suficiente para asignarlas a un Sprint específico.
- **`TipoDeCargoConManoDeObra__c` (catálogo PEKING + refactor a lookup):** depende de la definición de negocio de mano de obra PEKING, que no está atada a ningún Sprint específico documentado.
- **Drift Git/Partial (3 componentes):** es trabajo de mantenimiento/trazabilidad, no de un Sprint funcional — candidato a un bloque de sincronización separado.
- **Branding/razón social PEKING (`BatchOppActivityUploader`, `cT_QuotePDFEmail`):** depende de una decisión legal/comercial que tampoco está atada a un Sprint específico en la documentación revisada.

---

# 12. Conclusiones

**Qué debe corregirse ahora (con autorización):**
- El bug de `Pricebook2.Name = Id` en los 4 Flows Opportunity — es el hallazgo de mayor riesgo real, afecta datos de producción de las 3 empresas dentro de Flows ya autorizados.
- La propagación de `empresaFacturaCP__c` en `Work_Order_from_Quote`/`_Selective` — P0 original de Luis, confirmado vigente, técnicamente independiente del bloqueo de negocio N2.

**Qué debe esperar:**
- Todo lo que depende de definición de negocio: N2, N3, N4, catálogo de mano de obra PEKING, razón social/branding oficial.

**Qué está fuera de alcance:**
- Las ~63 clases Apex de la auditoría no nombradas en la matriz autoritativa de Sprint 2 (secciones 6.1–6.5).
- Los 2 Flows fuera de los 20 autorizados (`Work_Order_On_Create_Create_OPP_and_Quote_and_Update_WO_Values`, `BMW_Importar_Plantilla_Orden_de_Trabajo`).
- `TipoDeCargoConManoDeObra__c` y sus consumidores.

**Qué debe preguntarse a Luis/Diego:**
1. ¿`HttpCalloutCreateKit` realmente resuelve Omoda/Jaecoo en algún otro punto no localizado, o la auditoría se refería a un cambio planeado/otro ambiente?
2. ¿Se autoriza nombrar explícitamente el bug de `Pricebook2.Name = Id` y la falta de propagación de `empresaFacturaCP__c` como remediación técnica prioritaria, dado que ambos están dentro de Flows ya autorizados?
3. Para las clases Apex fuera de alcance: ¿alguna se incorpora formalmente a Sprint 2, o se difieren completas a un bloque de "deuda técnica Apex" posterior?
4. ¿Qué corresponde hacer con los componentes que solo existen en Partial y no en Git (`SolicitudAprobacionTesoreria`, `VN_RQ106_AnticipoController`, `Work_Order_On_Create_Create_OPP_and_Quote_and_Update_WO_Values`)?

**Qué hallazgos de la auditoría ya no son válidos:**
- Los 6 `ScheduleGet*Softland` — nunca perdieron soporte de Otobai; nunca lo tuvieron.
- La rama Taller de `Opp_Flow_V5` sin `Empresa_Operadora__c` — ya corregida.
- `aperturaCaseWorOrderEvent`/`ct_newCaseWorkOrderEvent` como binario sin lookup de Empresa — N4 ya desplegado técnicamente (QA funcional pendiente, no ausencia de mecanismo).
- La premisa de que `HttpCalloutCreateKit` ya resuelve Omoda/Jaecoo — contradicha por el código actual.

No se implementó nada. No hubo deploy, DML, ni modificación de metadata funcional en la generación de este documento.
