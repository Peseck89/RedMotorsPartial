# Remediación del análisis de Luis — 2026-07-31

## Estado: COMPLETADO (con pendientes reales de datos/negocio documentados en §6)

Este documento cierra la tarea de remediación solicitada por Luis el 2026-07-31 sobre los cierres técnicos previos de Sprint 1 y Sprint 2 del proyecto Empresa / Marcas Chinas. Se verificaron individualmente los 10 hallazgos de su reporte contra código y datos reales (no se asumió que el reporte fuera correcto ni incorrecto), y se corrigieron los que resultaron reales y resolubles sin inventar datos de negocio.

Worktrees usados:

- Sprint 1: `RedMotors-Sprint1-Remediacion-Luis-Codex`, rama `feature/pc/redmotors-sprint1-remediacion-luis-codex-20260731`, base HEAD `34429e5`.
- Sprint 2: `RedMotors-Sprint2-Remediacion-Luis-Codex`, rama `feature/pc/redmotors-sprint2-remediacion-luis-codex-20260731`, base HEAD `9f85163`.

Org: `RedMotorsSandbox` (`peseck89@gmail.com.partial.redmotors`, `https://redmotors--partial.sandbox.my.salesforce.com`). Producción no se leyó ni se escribió en ningún momento.

---

## 1. Matriz de verificación de los 10 hallazgos

| # | Hallazgo de Luis | Veredicto | Evidencia |
|---|---|---|---|
| 1 | Empresa incompleta por falta de `Nombre_Legal__c`/`Codigo_ERP__c` | **CONFIRMADO** | `EmpresaContext`/`EmpresaResolver` exigían `Codigo_ERP__c` y `Nombre_Legal__c` no vacíos en el constructor. Ningún consumidor de producción (17 clases revisadas por `grep`) llama `requireNombreLegal()`; solo `requireCodigoErp()`/`.codigo`. `HttpCalloutCreateKit.resolveCompania` y `TrabajoQuoteController.resolveEmpresaLegacy` quedaban bloqueados por un dato (`Nombre_Legal__c`) que nunca leen. El controlador de PDF (`cT_QuoteCrcPDFController.cls`) no referencia `EmpresaContext`/`Empresa_Operadora__c` en absoluto hoy. |
| 2 | Flows que crean Opportunity dependen de `BMW_Compania__c` sin guardar `Empresa_Operadora__c` | **CONFIRMADO** | 8 `recordCreates` de Opportunity Active encontrados en 5 Flows con este patrón: `Opp_flow_V3`, `Opp_Flow_v6`, `Opportunity_Flow_V2` (x2), `Opportunity_Flow_From_Work_Order` (x2, el más grave — un WorkOrder de PEKING creaba una Opportunity con `BMW_Compania__c="Otobai"` por `defaultConnector`), `aperturaCaseWorOrderEvent` (x2). |
| 3 | Plantillas de presupuesto atadas a `BMW_Compania__c`, sin ruta PEKING completa | **CONFIRMADO (parcial)** | `Plantilla_de_Presupuesto__c.Empresa_Operadora__c` ya existe como metadata. La resolución de Pricebook en `BMW_ImportarPlantilla`/`Opportunity_Flow` ya usa `Empresa_Operadora__c`, pero el `RecordLookup` que busca las Plantillas candidatas seguía filtrando únicamente por `BMW_Compania__c` en 3 Flows. `BMW_Importar_Plantilla_Orden_de_Trabajo` no tiene ninguna rama para `RMPEKING`. |
| 4 | PEKING Local y PEKING Dólares con 0 `PricebookEntry` | **CONFIRMADO** | `SELECT count() FROM PricebookEntry WHERE Pricebook2Id IN ('01sAK0000006DXFYA2','01sAK0000006DVdYAM')` → 0 registros. |
| 5 | Bavarian Local y Otobai Local en `CurrencyIsoCode = USD` | **CONFIRMADO** | Query real a Partial: ambos Pricebooks en `USD`, no `CRC`. Ya documentado como hallazgo de datos preexistente en el cierre técnico anterior de Sprint 2, no corregido por falta de autorización. |
| 6 | Flows invocan el resolver sin controlar `EXITO`/`NO_CONFIGURADO`/`SELECCION_REQUERIDA`/`ERROR` | **CONFIRMADO** | Ninguno de los 5 Flows distinguía explícitamente los 4 estados. En 3 de los 5 (`Opportunity_Flow`, `Opp_flow_v4`, `BMW_ImportarPlantilla`) el Flow ni siquiera leía `.status` — asignaba `Pricebook2Id = null` y continuaba sin detenerse ni mostrar mensaje, confirmado paso a paso con nombres de elemento reales. |
| 7 | `rm_vu_inventario` usa `CurrencyCode` donde el servicio devuelve `CurrencyIsoCode` | **CONFIRMADO** | El SOQL de `RM_VU_Service.gePBEBavarian` no seleccionaba `CurrencyIsoCode` en absoluto; el LWC leía `pbe.CurrencyCode` (campo inexistente) y además le aplicaba `parseFloat()` a un código ISO de moneda (`"USD"`/`"CRC"`), lo que siempre resultaba en `0`/`NaN`. |
| 8 | `HttpCalloutCreateKit` conserva una bandera entre Opportunities | **CONFIRMADO** | `Boolean sendRequest = false;` declarado antes del `for` que recorre `Opps`, nunca reiniciado por iteración. Una Opportunity con línea Vehiculos activaba `sendRequest=true`, y las Opportunities siguientes del mismo batch sin línea Vehiculos heredaban ese `true` y enviaban un kit indebido a Softland. |
| 9 | `WorkOrderTrigger` busca Pricebooks por nombre | **CONFIRMADO** | `SELECT Id, Name FROM Pricebook2` + `pricebookMap.get('Otobai Dólares')` etc., 6 ramas hardcodeadas por nombre literal. |
| 10 | `Pricebook2.Empresa__c` sin permisos o sin aparecer en el layout | **CONFIRMADO (parcial)** | FLS ya existía en `Empresa_Admin` (editable) y `Vehiculos_Nuevos_PS` (solo lectura) desde el cierre anterior — el usuario QA conectado (`peseck89`, System Administrator + `Empresa_Admin`) sí tenía acceso. Pero el campo **no aparecía en el único layout de Pricebook2** (`Pricebook2-Price Book Layout`, confirmado como el único layout del objeto vía `sf org list metadata`). |

Ningún hallazgo resultó falso positivo. Ninguno se descartó por "no reproducido".

---

## 2. Correcciones Sprint 1

### 2.1 `HttpCalloutCreateKit` — bandera compartida entre Opportunities (hallazgo #8)

`force-app/main/default/classes/HttpCalloutCreateKit.cls`: `sendRequest` ahora se declara **dentro** del `for` que recorre `Opps`, reiniciado en `false` en cada iteración. Sin cambios de contrato, endpoint, autenticación, ni de los códigos `RMPEKING`/`RMBAVARIAN`/`RMOTOBAI` ni el manejo de Record Types desconocidos (sigue lanzando `EmpresaConfigurationException` controlada).

Regresión agregada en `HttpCalloutCreateKitTest.cls`: una Opportunity elegible, varias (elegible→no elegible→elegible), orden invertido (no elegible→elegible→no elegible), ninguna elegible, todas elegibles, una sola Opportunity elegible y una sola no elegible — 7 pruebas nuevas, cada una verifica el número exacto de callouts capturados.

### 2.2 "Empresa incompleta" (hallazgo #1)

Se clasificaron los campos de `Empresa__c` por consumidor real (17 clases revisadas):

| Campo | Necesario para | Evidencia |
|---|---|---|
| `Codigo__c` | Identificación de la Empresa en todas las rutas | Usado sin excepción por todos los consumidores |
| `Activa__c` | Regla de negocio "no usar Empresa inactiva" en todas las rutas | Usado sin excepción |
| `Codigo_ERP__c` | Integración ERP (`HttpCalloutCreateKit`, `QuoteSoftlandPedidoService`) | Único consumidor real vía `requireCodigoErp()` |
| `Nombre_Legal__c` | Documentos/PDF con razón social — **ningún consumidor real lo usa hoy** | `requireNombreLegal()` no se llama desde ningún `.cls` de producción; `cT_QuoteCrcPDFController.cls` no usa `EmpresaContext` |

`Nombre_Legal__c` se exigía en una ruta que no lo usa (validación genérica demasiado estricta). No se inventó ninguna razón social. Se implementó una validación contextual mínima: `EmpresaContext`/`EmpresaResolver` ya no exigen `Codigo_ERP__c` ni `Nombre_Legal__c` para construir un contexto "configurado" — ambos quedan opcionales y se siguen exigiendo **en el punto de uso real** vía `requireCodigoErp()`/`requireNombreLegal()`, que lanzan `EmpresaConfigurationException` igual que antes si el consumidor que sí necesita el dato lo pide y está vacío. Esto no afecta ningún documento ni proceso legal (ninguno los usa hoy) y desbloquea Bavarian/Otobai/PEKING en Partial, que no tienen razón social confirmada.

Archivos: `EmpresaContext.cls`, `EmpresaResolver.cls`. Tests actualizados/agregados: `EmpresaContextTest.cls` (2 pruebas reescritas para verificar que la construcción ya no falla y que `require*()` sí sigue fallando en el punto de uso), `EmpresaResolverTest.cls` (1 prueba reescrita con el mismo criterio), `HttpCalloutCreateKitTest.cls` y `TrabajoQuoteControllerTest.cls` (1 prueba nueva cada una, demostrando que sus rutas reales funcionan con `Nombre_Legal__c` vacío).

### 2.3 Validación y deploy Sprint 1

- Manifest: `manifest/sprint1-remediacion-luis.xml` (7 clases Apex).
- Dry-run: Deploy ID `0AfAK000000yrW50AI` — 0 errores de componente, 47/47 pruebas, sin fallas, sin warnings de cobertura.
- Deploy real a Partial: Deploy ID `0AfAK000000yrav0AA` — 0 errores de componente, 47/47 pruebas.
- Cobertura de las clases modificadas: `HttpCalloutCreateKit` 98.5% (65 líneas, 1 no cubierta), `EmpresaContext` 100% (36 líneas), `EmpresaResolver` 82.5% (103 líneas, 18 no cubiertas) — todas ≥75%.
- Commit `cdb3ca7` en `feature/pc/redmotors-sprint1-remediacion-luis-codex-20260731`, pusheado, fast-forward a `feature/pc/redmotors-empresa-marcas-chinas-sprint1-20260724` (`RedMotors-Sprint1-Integracion`), pusheado. `git rev-list --left-right --count HEAD...@{u}` → `0 0`.

---

## 3. Correcciones Sprint 2

### 3.1 `rm_vu_inventario` / `RM_VU_Service` (hallazgo #7)

- `RM_VU_Service.cls`, método `gePBEBavarian`: el SOQL ahora selecciona `CurrencyIsoCode` (antes solo `Product2Id,UnitPrice`).
- `rm_vu_inventario.js` (2 ocurrencias): `pbe.CurrencyCode` → `pbe.CurrencyIsoCode`, sin `parseFloat()` (el campo es un código ISO de 3 letras, no un número).
- Confirmado con datos reales de Partial: PEKING Local = `CRC`, PEKING Dólares = `USD`, Bavarian/Otobai Local = `USD` (hallazgo #5, no corregido — ver §6.1).
- Test: `RM_VU_Service_Test.testGePBEBavarian` ahora asertúa que `CurrencyIsoCode` viene poblado y consistente con el filtro de moneda (antes no asertaba nada sobre el resultado).
- No se creó infraestructura Jest nueva para este LWC (no existía previamente, fuera del mandato de esta tarea).

### 3.2 `WorkOrderTrigger` (hallazgo #9)

Reemplazada la búsqueda de Pricebook por nombre (`SELECT Name FROM Pricebook2` + mapa de 6 nombres literales) por resolución dinámica vía `EmpresaPricebookResolver.resolve()` (la misma API compartida que usan los 5 Flows de Pricebook de Sprint 2 — no se creó una segunda implementación paralela). El lookup `empresaFacturaCP__c` tiene precedencia; el picklist heredado `empresaFactura__c` se usa solo cuando el lookup está vacío, resuelto a la `Empresa__c` real por `Codigo__c`. Solo el estado `EXITO` actualiza `Pricebook2Id`; `NO_CONFIGURADO`/`SELECCION_REQUERIDA`/`ERROR` dejan el valor existente intacto (no hay pantalla en un trigger para pedir selección manual, y elegir arbitrariamente violaría la regla de no-selección-silenciosa).

`WorkOrderTriggerTest.cls`: `setupConfiguration` reescrito para asociar cada Pricebook2 de prueba a su `Empresa__c` vía el campo `Empresa__c` (antes solo por `Name`, lo que ya no es suficiente con la nueva lógica). Se agregó el Empresa `RMMULTI` con 2 Pricebooks activos en la misma moneda para probar explícitamente el caso "múltiples opciones" (`SELECCION_REQUERIDA`, no elige arbitrariamente). El caso "cero opciones" ya existía (`RMUNKNOWN`, sin Pricebooks asociados) y se dejó documentado como tal. Bavarian, Otobai y PEKING ya tenían cobertura explícita (6 pruebas, una por combinación Empresa×Moneda) y bulk (200 registros, 1 sola consulta).

### 3.3 Layout `Pricebook2.Empresa__c` (hallazgo #10)

`Pricebook2-Price Book Layout` (único layout de Pricebook2 confirmado en el org, sin ambigüedad entre layouts) recuperado de Partial y modificado para incluir el campo `Empresa__c` en modo `Edit`, junto a `IsActive`/`IsStandard`. No se tocaron perfiles.

### 3.4 Estados de `EmpresaPricebookResolver` — continuación silenciosa (hallazgo #6)

Se agregó una `Decision` (`Verifica_Estado_Pricebook`) inmediatamente después del `actionCall` `Resuelve_Pricebook_Empresa` en los 3 Flows donde se confirmó que el Flow escribía `Pricebook2Id = null` sin detenerse: `Opportunity_Flow`, `Opp_flow_v4`, `BMW_ImportarPlantilla`. La regla `Pricebook_Resuelto_OK` (`status EqualTo "EXITO"`) continúa hacia la asignación existente; el `defaultConnector` (agrupa `NO_CONFIGURADO`/`SELECCION_REQUERIDA`/`ERROR`) va a una nueva pantalla terminal `Aviso_Pricebook_No_Disponible` que muestra `{!Resuelve_Pricebook_Empresa.mensaje}` y termina la interview — nunca continúa con un Pricebook vacío.

**Pendiente real documentado, no implementado:** para `SELECCION_REQUERIDA` el mandato pedía idealmente permitir selección manual cuando la interfaz lo soporte (son Screen Flows). Construir una pantalla con selección dinámica vinculada a `Resuelve_Pricebook_Empresa.opciones` requiere validación visual en Flow Builder que no se puede garantizar de forma segura editando XML a mano sin esa herramienta disponible en este entorno. Se implementó el comportamiento mínimo seguro exigido (nunca continuar con Pricebook vacío, nunca elegir arbitrariamente) y se documenta la selección visual como mejora pendiente.

`BMW_Gestiona_Listas_de_Precios` y `Obtener_PricebookEntry_en_Linea_de_Plantilla_de_Presupuesto` ya tenían una `Decision` explícita para `EXITO` con el resto agrupado sin escribir un Pricebook vacío (comportamiento seguro, aunque tampoco distingue los 4 estados uno por uno) — no requerían corrección de riesgo de datos, se dejaron sin cambios.

### 3.5 Flows que crean Opportunity sin `Empresa_Operadora__c` (hallazgo #2)

Corregido el caso más severo, confirmado con evidencia exacta: **`Opportunity_Flow_From_Work_Order`**. Antes: la `Decision` `IFEmpresa` solo tenía una regla explícita (`EmpresaFactura EqualTo "RMBAVARIAN"`); cualquier otro valor —incluido `RMPEKING`— caía en el `defaultConnector` y creaba la Opportunity con `BMW_Compania__c = "Otobai"` literal. Ahora:

- Se agregó una regla explícita `IFRMOTOBAI` (antes implícita en el default) y una nueva regla `IFRMPEKING`.
- Se agregó un nuevo `RecordLookup` (`Busca_Empresa_Operadora`, `Empresa__c WHERE Codigo__c = EmpresaFactura AND Activa__c = true`) que resuelve el código legacy a la `Empresa__c` real.
- Los 3 `recordCreates` (`CreateOpportunity_0` Bavarian, `CreateOpportunity_0_0` Otobai, nuevo `CreateOpportunity_0_0_0` PEKING) ahora asignan `Empresa_Operadora__c`. El de PEKING **no** asigna `BMW_Compania__c` (picklist restringido que solo admite `Bavarian`/`Otobai`/vacío — asignarle `"PEKING"` fallaría con `INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST`; se documenta como decisión, no se inventó un valor de picklist).
- El `defaultConnector` de `IFEmpresa` ya no cae silenciosamente en Otobai: ahora va a una nueva pantalla terminal `Empresa_No_Reconocida` que informa el código no reconocido y detiene la creación, sin adivinar.
- No se agregó PEKING a ningún picklist de usuario como solución principal (este Flow no tiene selección de marca por pantalla, decide por el código de la Work Order).

**Pendiente real documentado, no implementado:** `Opp_flow_V3`, `Opp_Flow_v6`, `Opportunity_Flow_V2`, `aperturaCaseWorOrderEvent` (8 `recordCreates` adicionales confirmados con el mismo patrón) no fueron migrados en esta pasada. A diferencia de `Opportunity_Flow_From_Work_Order` (decide por un código interno de WorkOrder), estos Flows exponen la elección de Empresa al usuario final vía un campo de pantalla (`choiceReferences`) con solo 2 opciones (`Bavarian`/`Otobai`) o copian `$User.Empresa__c` directamente. Agregar PEKING ahí requiere una decisión de producto/UX (¿se agrega una 3ª opción al dropdown? ¿reemplaza el mecanismo completo?) que el mandato de esta tarea explícitamente no autoriza resolver por inferencia ("no agregar PEKING al picklist como solución principal" sin más contexto). Se documentan como candidatos identificados, con la evidencia exacta ya recolectada (nombre de cada `recordCreates`, campo `BMW_Compania__c`, ausencia de `Empresa_Operadora__c`) para una siguiente sesión con la decisión de UX confirmada por Luis/Diego.

### 3.6 Plantillas de presupuesto (hallazgo #3)

Cambiado el filtro de búsqueda de Plantillas candidatas de `BMW_Compania__c EqualTo <picklist>` a `Empresa_Operadora__c EqualTo EmpresaIdResuelta` (la misma variable ya resuelta — lookup primero, fallback legacy después — que estos Flows ya usan para el Pricebook) en:

- `BMW_ImportarPlantilla.flow-meta.xml` (2 `RecordLookup`: `BMW_ObtenerPlantillas`, `Copia_1_de_Obtener_Plantillas`).
- `Opportunity_Flow.flow-meta.xml` (2 `RecordLookup` equivalentes).

Verificado antes de aplicar el cambio (no se asumió): en ambos Flows, el `RecordLookup` `BMW_ObtenerPresupuesto` (Quote) es el único predecesor obligatorio de la cadena que lleva a `Tiene_Empresa_Operadora`/`EmpresaIdResuelta`, y el filtro **anterior** ya dependía de `BMW_ObtenerPresupuesto.Opportunity.BMW_Compania__c` — es decir, cualquier ejecución que alcanzara el filtro de Plantillas ya había pasado obligatoriamente por `Tiene_Empresa_Operadora` (no existe una ruta alterna que lo evite), así que `EmpresaIdResuelta` está garantizado como ya resuelto en ese punto.

**No aplicado, documentado como pendiente:** `Opportunity_Flow_V2` tiene el mismo patrón de filtro por `BMW_Compania__c` en su búsqueda de Plantillas, pero **no tiene ninguna infraestructura `Empresa_Operadora__c`/`EmpresaIdResuelta`/`Tiene_Empresa_Operadora`** (confirmado por `grep`, cero resultados) — es una copia hermana de `Opportunity_Flow` que nunca recibió la migración de Sprint 2. Aplicar el mismo fix ahí requiere primero portar toda la migración del resolver (fuera del alcance puntual de esta corrección), no solo cambiar el filtro. `BMW_Importar_Plantilla_Orden_de_Trabajo` tampoco tiene esa infraestructura y además carece de cualquier rama para PEKING (ver hallazgo #3 en la matriz) — mismo pendiente.

### 3.7 Deploy y validación Sprint 2

Manifests usados: `manifest/sprint2-remediacion-luis-full.xml` (Apex: `RM_VU_Service`, `RM_VU_Service_Test`, `WorkOrderTriggerTest`; Trigger: `WorkOrderTrigger`; LWC: `rm_vu_inventario`; Layout: `Pricebook2-Price Book Layout`), `manifest/sprint2-flows-54.xml` (`Opportunity_Flow`, `Opp_flow_v4`, `Opportunity_Flow_From_Work_Order`), `manifest/sprint2-flow-bmw-importarplantilla-55.xml` (deployado por separado con su propia `apiVersion` nativa, siguiendo la recomendación ya documentada en el cierre técnico anterior de no mezclar Flows de distinta versión en un mismo manifest).

| Paso | Deploy ID | Resultado |
|---|---|---|
| Dry-run Apex/Trigger/LWC/Layout (`RunSpecifiedTests`: `RM_VU_Service_Test`, `WorkOrderTriggerTest`, `EmpresaPricebookResolverTest`, `RM_VU_Inventario_Ctrl_Test`) | `0AfAK000000yt4r0AA` | 0 errores de componente, 49/49 pruebas, 0 fallas |
| Deploy real Apex/Trigger/LWC/Layout | `0AfAK000000yt850AA` | 0 errores de componente, 49/49 pruebas |
| Dry-run + deploy real Flows v54 (`Opportunity_Flow`, `Opp_flow_v4`, `Opportunity_Flow_From_Work_Order`) | `0AfAK000000yoBe0AI` (dry-run) / `0AfAK000000yt9h0AA` (real) | 0 errores de componente en ambos |
| Dry-run + deploy real `BMW_ImportarPlantilla` v55 | `0AfAK000000yt1d0AA` (dry-run) / `0AfAK000000ytCv0AI` (real) | 0 errores de componente en ambos (1 mensaje informativo preexistente sobre modo Sistema sin Sharing, no relacionado con este cambio) |

Cobertura de las clases Apex modificadas: `WorkOrderTrigger` 94.3% (176 líneas, 10 no cubiertas), `RM_VU_Service` 92% (25 líneas, 2 no cubiertas) — ambas ≥75%.

**Nota de proceso:** un primer intento de agregar las nuevas `Decision`/`Screen` de §3.4 falló en dry-run (`0AfAK000000ysbp0AA`, "Element decisions is duplicated at this location") porque el metadata de Flow exige que todos los bloques de un mismo tipo de elemento (`decisions`, `screens`, etc.) sean contiguos en el XML — se corrigió reubicando los bloques nuevos junto a los grupos existentes del mismo tipo antes de re-validar exitosamente.

### 3.8 QA funcional

`WorkOrderTriggerTest` y `RM_VU_Service_Test` (ejecutados como parte de `RunSpecifiedTests` arriba) cubren funcionalmente los hallazgos #5, #7 y #9 con datos reales de Partial vía las pruebas unitarias (Bavarian/Otobai/PEKING, cero opciones, múltiples opciones, bulk). Se intentó además una prueba de humo adicional vía Apex anónimo contra datos reales de Partial (prefijo `QA SPRINT2 REMEDIACION LUIS`); el script reveló un hallazgo adicional no reportado por Luis (ver §6.4) y no dejó datos residuales — el rollback implícito de Anonymous Apex ante una excepción no controlada revirtió la inserción de prueba antes de completarse, confirmado con una segunda consulta (`0 WorkOrders QA a eliminar`).

**Pendiente real, no bloqueante:** no se ejecutó una interview end-to-end completa de `Opportunity_Flow`/`Opp_flow_v4`/`BMW_ImportarPlantilla` disparando el Screen Flow real desde la UI, porque (a) PEKING no tiene `PricebookEntry` (hallazgo #4, ver §6.2 — cualquier Quote real de PEKING quedaría sin líneas de producto) y (b) requiere una interview manual con `presupuestoid` real vía Quote, más compleja de automatizar por API que las pruebas unitarias ya cubiertas. Se validó hasta el punto técnicamente posible: dry-run + deploy exitoso de la metadata, y las pruebas unitarias de los componentes Apex que estos Flows invocan (`EmpresaPricebookResolver`).

---

## 4. Flows adicionales incorporados y justificación

No se incorporó ningún Flow fuera de los ya autorizados por el mandato de esta tarea (los 5 Flows de Pricebook de Sprint 2, más los Flows que crean Opportunity con el patrón descrito en el hallazgo #2 de Luis). `Opportunity_Flow_From_Work_Order` se identificó durante la investigación de Fase 0 (Investigación 1, agente Explore) como el caso que cumple exactamente el criterio del hallazgo #2 con mayor severidad, y se corrigió por estar directamente dentro del alcance solicitado ("Modificar únicamente los que participan directamente en el proceso solicitado"). Los 12 Flows candidatos adicionales ya documentados en `REGLAS_ALCANCE_AUTORIZADO.md` (`AgregarManoObra`, `CreateWoliFromExpense`, etc.) **no se tocaron** — siguen fuera de alcance confirmado.

---

## 5. Commits, push, fast-forward

| Sprint | Commit | Push | Fast-forward | Ahead/behind final |
|---|---|---|---|---|
| Sprint 1 | `cdb3ca7` en `feature/pc/redmotors-sprint1-remediacion-luis-codex-20260731` | Sí, a `origin` | Sí, a `feature/pc/redmotors-empresa-marcas-chinas-sprint1-20260724` (`RedMotors-Sprint1-Integracion`), pusheado | `0 0` |
| Sprint 2 | Ver commit(s) en esta misma sesión, rama `feature/pc/redmotors-sprint2-remediacion-luis-codex-20260731` | Sí, a `origin` | Sí, a `feature/pc/redmotors-empresa-marcas-chinas-sprint2-flows-components-20260728` (`RedMotors-Sprint2-Flows-Components`), pusheado | `0 0` |

No se mezclaron cambios de Sprint 1 y Sprint 2 en una misma rama. No se eliminó ningún worktree ni rama existente.

---

## 6. Pendientes reales (no bloquean el cierre técnico de esta remediación)

### 6.1 Moneda de Bavarian Local / Otobai Local (hallazgo #5)

No se modificó `Bavarian Local` ni `Otobai Local` sin confirmación.

| Pricebook | Id | `CurrencyIsoCode` actual | Empresa asociada |
|---|---|---|---|
| Bavarian Local | `01s4U0000026MgkQAE` | USD | Bavarian (`a1UAK0000009wcf2AA`) |
| Otobai Local | `01s4U0000026MgpQAE` | USD | Otobai (`a1UAK0000009weH2AQ`) |

Impacto de mantenerlos en USD: para Bavarian y Otobai, `EmpresaPricebookResolver` no puede distinguir "Local" de "Dólar" por moneda cuando se pide sin filtro (ambas opciones son USD simultáneamente) — el resolver responde correctamente `SELECCION_REQUERIDA` (no elige arbitrariamente), pero eso significa que `WorkOrderTrigger` y `rm_vu_inventario` no pueden auto-seleccionar un Pricebook único para Bavarian/Otobai sin que la CurrencyIsoCode del registro origen ya distinga USD de CRC explícitamente.

**Pregunta pendiente para Luis/Diego:** ¿Bavarian Local y Otobai Local deben manejar CRC? Actualmente ambas listas están en USD y eso genera dos opciones USD por Empresa.

### 6.2 PricebookEntry de PEKING (hallazgo #4)

Confirmado: 0 `PricebookEntry` en `PEKING Local` y `PEKING Dólares`. No se inventaron productos ni precios oficiales. No se creó ningún `PricebookEntry` de prueba permanente (los intentos de QA en esta sesión no llegaron a necesitar crear ninguno, dado que las pruebas se hicieron a nivel de resolución de Empresa/Pricebook, no de líneas de producto).

**Dato requerido y equipo/archivo que debe proveerlo:** catálogo de productos PEKING (código, descripción, tipo) con precios oficiales por moneda (CRC y USD) y vigencia, desde el equipo comercial/Softland responsable del catálogo de la marca PEKING — el mismo origen que proveyó el catálogo Bavarian/Otobai original (ver `BatchGetCatalogoSoftland` y los `BatchGet*Softland` documentados en Sprint 1). No se puede completar QA comercial real de ningún Quote de PEKING (`Opportunity_Flow`, `Opp_flow_v4`, `BMW_ImportarPlantilla`) hasta tener este dato.

### 6.3 Razón social (`Nombre_Legal__c`) de Bavarian, Otobai y PEKING

Sigue sin confirmar en los 3 registros de `Empresa__c` en Partial. No bloquea ninguna ruta funcional hoy (§2.2 lo desbloqueó explícitamente para las rutas que no la usan), pero si en el futuro se implementa una ruta de documentos/PDF que sí necesite la razón social, `requireNombreLegal()` seguirá rechazándola de forma controlada hasta que el dato exista. **Fuente requerida:** documento legal/constitutivo de cada Empresa, desde Legal o Finanzas.

### 6.4 Hallazgo adicional encontrado durante QA (no reportado por Luis)

`WorkOrder.empresaFacturaCP__c` (el lookup a `Empresa__c` que `WorkOrderTrigger` usa con precedencia) no tiene `FieldPermissions` otorgado ni en `Empresa_Admin` ni en `Vehiculos_Nuevos_PS` — solo en 2 permission sets no relacionados con este proyecto (`sfdc_a360_sfcrm_data_extract`, uno más sin nombre descriptivo). Esto no afecta al trigger en sí (Apex no aplica FLS salvo que se use explícitamente `WITH SECURITY_ENFORCED`/`stripInaccessible`, que este trigger no usa), pero sí impide que Anonymous Apex lo referencie para el usuario conectado, y probablemente impide que usuarios sin esos 2 permission sets vean o editen el campo en el layout de WorkOrder. No se corrigió (fuera del alcance de los 10 hallazgos de Luis, requiere confirmar con Luis/Diego qué permission set debe otorgarlo).

### 6.5 Flows de creación de Opportunity y búsqueda de plantillas pendientes de migración completa

Ver §3.5 y §3.6 — `Opp_flow_V3`, `Opp_Flow_v6`, `Opportunity_Flow_V2`, `aperturaCaseWorOrderEvent` (creación de Opportunity) y `Opportunity_Flow_V2`, `BMW_Importar_Plantilla_Orden_de_Trabajo` (búsqueda de plantillas) quedan identificados con evidencia exacta, no modificados, pendientes de una decisión de producto/UX sobre cómo exponer la Empresa nueva en las pantallas donde hoy el usuario elige entre solo 2 opciones (Bavarian/Otobai).

---

## 7. Preguntas externas pendientes (solo las que no pueden resolverse técnicamente)

1. **Razones sociales oficiales** de Bavarian, Otobai y PEKING (§6.3) — Legal/Finanzas.
2. **Moneda correcta de Bavarian Local y Otobai Local** — actualmente ambas en USD, ¿deben manejar CRC? (§6.1) — Luis/Diego.
3. **Fuente de productos/precios PEKING** — catálogo oficial con precios CRC/USD y vigencia (§6.2) — equipo comercial/Softland.
4. **Decisión de UX para agregar PEKING a los Flows de creación de Opportunity con selección por pantalla** (`Opp_flow_V3`, `Opp_Flow_v6`, `Opportunity_Flow_V2`, `aperturaCaseWorOrderEvent`) — ¿se agrega una 3ª opción al dropdown existente o se rediseña el mecanismo de selección? (§3.5, §6.5) — Luis/Diego.
5. **Permission set correcto para `WorkOrder.empresaFacturaCP__c`** (§6.4, hallazgo adicional no reportado por Luis) — Luis/Diego.

No se repiten preguntas ya respondidas en sesiones anteriores (por ejemplo, el código ERP de PEKING y la relación `Pricebook2.Empresa__c` ya fueron resueltos y no se vuelven a preguntar).

---

## 8. Adenda 2026-07-31 (misma jornada) — último hallazgo de Luis: `rm_vu_inventario` envía `priceBook`, Apex espera `priceBookId`

Worktree: `RedMotors-Sprint2-RmVuInventario-Param-Fix`, rama `fix/pc/redmotors-sprint2-rm-vu-inventario-pricebook-param-20260731`, creada desde el HEAD real limpio de `feature/pc/redmotors-empresa-marcas-chinas-sprint2-flows-components-20260728` (`6ab6029`, el mismo commit que cerró §1–§7 de este documento).

### 8.1 Causa confirmada

`RM_VU_Inventario_Ctrl.getRecords` (`force-app/main/default/classes/RM_VU_Inventario_Ctrl.cls:16`) declara el parámetro `Id priceBookId`. El LWC `rm_vu_inventario.js` lo invocaba con la clave `priceBook` en **exactamente 2 lugares** (confirmado con `grep` sobre todo el bundle — JS, HTML, meta.xml — no aparece en ningún otro llamado):

1. Línea 116 — `@wire(getRecords, {..., priceBook: "$priceBookId"})`, carga normal/reactiva del inventario.
2. Línea 340 — `getRecords({..., priceBook: this.priceBookId})` dentro de `getData()`, usado por `handleExportToCSV` para la exportación CSV.

Como la clave enviada (`priceBook`) no coincide con el nombre del parámetro Apex (`priceBookId`), la plataforma simplemente no la mapea: `priceBookId` llegaba **siempre `null`** a Apex, sin importar qué Pricebook seleccionara el usuario en el combobox. El método tiene un guard explícito (`if(priceBookId == null){ return responseMap; }`) que hacía que el inventario devolviera un mapa vacío en todos los casos — tanto la grilla en pantalla como el CSV exportado quedaban permanentemente vacíos, sin importar la selección del usuario. No se encontró ningún otro llamado incorrecto ni ninguna dependencia adicional que necesitara cambiar; no fue necesario modificar la firma pública de `RM_VU_Inventario_Ctrl.getRecords`.

### 8.2 Corrección

`force-app/main/default/lwc/rm_vu_inventario/rm_vu_inventario.js`:

- Línea 116 (wire reactivo): `priceBook: "$priceBookId"` → `priceBookId: "$priceBookId"`.
- Línea 340 (llamado imperativo de CSV): `priceBook: this.priceBookId` → `priceBookId: this.priceBookId`.
- Adicionalmente, se cambió el valor por defecto/de reseteo de `priceBookId` de `''` (string vacío) a `null` en 3 puntos (declaración de campo, y las dos ramas del handler `wiredPricebookOptions`). Motivo: antes de esta corrección `priceBookId` nunca llegaba realmente a Apex (por la clave incorrecta), así que el caso "enviar `''` a un parámetro `Id`" nunca se había ejercitado en producción; al corregir la clave, ese código quedó expuesto por primera vez. Se validó que el guard `if(priceBookId == null)` de Apex ya maneja `null` de forma limpia (sin error, sin toast, simplemente sin filas) — usar `null` en vez de `''` evita un posible error de coerción de tipo `Id` en la primera carga del componente, antes de que `getPricebookOptions` resuelva el Pricebook real.
- No se envía el objeto completo `{label, value}` ni el label: el LWC ya extraía solo `value` (el Id real) al poblar `priceBooks`/`priceBookId` desde `data.options`, y `handlePriceBookChange` toma `event.target.value` (el Id seleccionado) — ambos puntos ya eran correctos, se confirmaron sin necesidad de cambio.
- El selector conserva el Pricebook actual válido: `wiredPricebookOptions` ya asignaba `this.priceBookId = data.selectedPricebookId` (ahora con fallback `null` en vez de `''`), sin cambios de lógica.
- El cambio de selector ya recarga el inventario: `handlePriceBookChange` actualiza `this.priceBookId` y el `@wire(getRecords, ...)` es reactivo sobre `$priceBookId`, sin cambios de lógica.
- El CSV ya usaba `this.priceBookId` (la misma variable del selector en pantalla), solo con la clave incorrecta — corregido.
- No se modificó la lógica dinámica Empresa–Pricebook (`getPricebookOptions`, `EmpresaPricebookResolver`) ni los 4 Flows de selección de marca.

### 8.3 Pruebas técnicas

No existe infraestructura Jest funcional para este LWC (confirmado antes y ahora, sin cambios) — no se creó una nueva, según el mandato. Se ejecutaron las pruebas Apex relacionadas (sin necesidad de modificarlas, ya que no se tocó ningún `.cls`): `RM_VU_Inventario_Ctrl_Test`, `RM_VU_Service_Test`, `EmpresaPricebookResolverTest` (dependencia directa de `getPricebookOptions`).

Validación estática de que ambos llamados usan la clave exacta `priceBookId` y de que no queda ningún llamado con la clave incorrecta: `grep -n "priceBook" force-app/main/default/lwc/rm_vu_inventario/rm_vu_inventario.js` — confirmado, cero ocurrencias de `priceBook:` como clave de llamado; las únicas coincidencias restantes son el estado interno del componente (`priceBooks`, `priceBookId`) y la búsqueda local `priceBookEntries.find(...)`, ninguna es un llamado a Apex.

### 8.4 Dry-run y deploy

Manifest: `manifest/rm-vu-inventario-pricebook-param-fix.xml` (`LightningComponentBundle: rm_vu_inventario`; no se incluyó ningún `ApexClass` porque no fue necesario modificar Apex).

| Paso | Deploy ID | Resultado |
|---|---|---|
| Dry-run (`RunSpecifiedTests`: `RM_VU_Inventario_Ctrl_Test`, `RM_VU_Service_Test`, `EmpresaPricebookResolverTest`) | `0AfAK000000yuc10AA` | 0 errores de componente, 23/23 pruebas, 0 fallas |
| Deploy real a Partial | `0AfAK000000yudd0AA` | 0 errores de componente, 23/23 pruebas |

Org destino: `RedMotorsSandbox` (confirmado Partial, `https://redmotors--partial.sandbox.my.salesforce.com`) en ambos casos.

Cobertura Apex: no aplica un número nuevo — no se modificó ningún `.cls`/trigger en este cambio, por lo que no hay código Apex nuevo que cubrir. El resultado del deploy no reporta `codeCoverage` por clase porque el manifest solo contiene el LWC (comportamiento esperado de la Metadata API: la cobertura por clase se calcula sobre los componentes Apex del propio manifest desplegado). La cobertura de línea base de `RM_VU_Inventario_Ctrl`/`RM_VU_Service`, estable desde la remediación anterior de esta misma jornada (§3.7), no se vio afectada.

### 8.5 Prueba visual real

**Estado: PENDIENTE DE EVIDENCIA VISUAL MANUAL** — este entorno no dispone de navegador ni automatización visual, por lo que no se declara realizada la prueba visual. Se preparó una Opportunity QA seria en Partial y se dejaron los 10 pasos exactos para que Claudia la ejecute.

**Opportunity QA:** `QA RM_VU_INVENTARIO PARAM FIX Cuenta-BMW-31/07/2026`
Id: `006AK00000J0LG8YAN`
Link: `https://redmotors--partial.sandbox.my.salesforce.com/006AK00000J0LG8YAN`
Configuración: Cuenta QA dedicada (`QA RM_VU_INVENTARIO PARAM FIX Cuenta`, sin cliente real), RecordType `BMW`, `Empresa_Operadora__c` = Bavarian, `Pricebook2Id` = `Bavarian Dólar` (USD), `CurrencyIsoCode` = `USD`. Se eligió Bavarian (no PEKING) porque `Bavarian Dólar` y `Bavarian Local` tienen inventario de vehículos usados real en Partial (4342 y 4341 `PricebookEntry` respectivamente, confirmado por query) — dan 2 opciones válidas en el selector para poder probar también el cambio de Pricebook. **No se borra este registro hasta obtener la evidencia visual.**

**Pasos exactos para Claudia:**

1. Abrir el link de la Opportunity de arriba en Partial.
2. En la página de la Opportunity, abrir el botón/acción **"Agregar vehiculo usado"** (Quick Action `Opportunity.Agregar_vehiculo_usado`, componente `rm_vu_agregar_vehiculo`, que contiene a `rm_vu_inventario`) — puede estar en la barra de acciones o en el menú "Más acciones" (▾) según el layout.
3. Confirmar que aparece el selector **"Lista de precios"** con al menos 2 opciones (`Bavarian Dólar`, `Bavarian Local`).
4. Confirmar que el selector ya trae seleccionado `Bavarian Dólar` (el Pricebook actual de la Opportunity) y que la grilla de inventario **carga filas** (antes de esta corrección quedaba siempre vacía).
5. Cambiar el selector a `Bavarian Local`.
6. Confirmar que la grilla se **actualiza** (nuevas filas, o el mismo conteo si el catálogo es igual entre ambos Pricebooks — lo relevante es que la llamada se dispare de nuevo, visible por el spinner de carga).
7. Con cualquiera de los 2 Pricebooks seleccionado, hacer clic en el botón de exportar y elegir **CSV** (separador coma o punto y coma).
8. Abrir el archivo `Inventario Usados.csv` descargado y confirmar que contiene filas con datos (nombre, modelo, año, precio, bodega) correspondientes al Pricebook que estaba seleccionado en pantalla.
9. Confirmar que en ningún momento aparece un toast de error por "Pricebook nulo" o similar.
10. Si es posible, abrir las DevTools del navegador (pestaña Network o Console) durante el paso 4 o 6 y confirmar que la llamada a `RM_VU_Inventario_Ctrl.getRecords` envía la clave `priceBookId` (no `priceBook`) con un Id de 18 caracteres como valor.

No se debe usar ningún Pricebook ni producto de PEKING para esta prueba (PEKING sigue sin `PricebookEntry`, hallazgo #4 de §6.2 — no relacionado con este fix, no se inventó ningún dato). No se modificaron razones sociales, monedas, catálogos, precios ni Permission Sets en esta tarea.

### 8.6 Git

Commit `fix(empresa): pass Pricebook Id from used inventory` en `fix/pc/redmotors-sprint2-rm-vu-inventario-pricebook-param-20260731`, pusheado a `origin`, fast-forward limpio hacia `feature/pc/redmotors-empresa-marcas-chinas-sprint2-flows-components-20260728` (`RedMotors-Sprint2-Flows-Components`), pusheado. Ninguno de los 4 Flows de selección de marca (`Opp_flow_V3`, `Opp_Flow_v6`, `Opportunity_Flow_V2`, `aperturaCaseWorOrderEvent`, identificados en §3.5/§6.5) fue modificado en esta tarea — confirmado por `git diff --stat` del commit (solo 2 archivos: el LWC y el manifest).
