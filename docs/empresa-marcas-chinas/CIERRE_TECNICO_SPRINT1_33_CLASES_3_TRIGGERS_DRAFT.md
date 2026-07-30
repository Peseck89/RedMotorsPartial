# Cierre técnico Sprint 1 — 33 clases + 3 triggers (BORRADOR)

## Estado del documento

**BORRADOR.** No constituye cierre formal del Sprint 1 completo (ver "Pendientes" más abajo). Esta sesión (2026-07-30, cierre Luis — bloque final) sí ejecutó Salesforce CLI (dry-run y deploy real) exclusivamente contra Partial, e hizo commit del bloque de cierre. Producción no fue tocada en ningún momento.

### Validación de esta sesión (dry-run + deploy real, exclusivamente Partial)

- **Dry-run:** Deploy ID `0AfAK000000yN6b0AE`, target org `peseck89@gmail.com.partial.redmotors`, 4/4 componentes, 21/21 pruebas, `HttpCalloutCreateKit` 98% de cobertura, `TrabajoQuoteController` 93% de cobertura, código de salida 0.
- **Deploy real:** Deploy ID `0AfAK000000yNY10AM`, mismo target org, mismos resultados: 4/4 componentes, 21/21 pruebas, `HttpCalloutCreateKit` 98%, `TrabajoQuoteController` 93%, código de salida 0.
- Manifest usado: `manifest/sprint1-cierre-luis-definiciones-validation.xml` (`TrabajoQuoteController`, `TrabajoQuoteControllerTest`, `HttpCalloutCreateKit`, `HttpCalloutCreateKitTest`).
- **Producción no fue tocada** en ninguno de los dos pasos.

### Pendientes funcionales/de datos que continúan abiertos

- `Empresa__c` continúa sin registros y `Empresa_Operadora__c` no está poblado en las Opportunities actuales de Partial; la prueba funcional de la ruta principal (resolución vía `Empresa_Operadora__c`/`EmpresaResolver`) requiere datos/configuración de Empresa que todavía no existen en el org. Lo validado en esta sesión es cobertura de código y compilación/deploy, no el camino funcional principal end-to-end con datos reales.
- `ServicioCitas`, `ServicioCitasFieldService` y `RM_VN_CrearOportunidad_Ctrl` siguen documentados como hallazgos adicionales (ver tabla al final de este documento); no se implementaron en este bloque.

**Actualización de esta sesión (2026-07-30, cierre Luis):** Luis confirmó `TrabajoQuoteController` como la **clase 33**. Se corrigió `HttpCalloutCreateKit` (empresa/marca Omoda y Jaecoo → `RMPEKING`, tipo `V`) y se documentó que `TrabajoQuoteController` ya resolvía la empresa correctamente (Bloque 13, sin drift contra Partial) y solo necesitaba el comentario de fallback temporal. Ambas clases están confirmadas sin drift contra Partial (ver reconciliación al final de este documento). **Aclaración importante:** el "33/33 pruebas aprobadas" de la sección "Evidencia de ejecución" (Test Run `707AK00000HB6UY`) se refiere a **33 métodos de prueba** ejecutados en esa corrida enfocada de los `BatchGet*Softland`/`WorkOrderTrigger`, **no** a las 33 `ApexClass` del alcance de Luis — son dos conteos distintos que coinciden en el número por coincidencia numérica, no por relación causal. `HttpCalloutCreateKit` ya estaba confirmada como clase **28** desde la reconciliación anterior (fila 28 de la tabla) y no se cuenta dos veces.

**Actualización de sesión anterior:** se reconciliaron hacia Git, a partir de Partial, **9 componentes productivos** (`BatchGetCatalogoSoftland` + las 7 clases `BatchGet*Softland` + `WorkOrderTrigger`) y **7 tests** (uno por cada `BatchGet*Softland`). `BatchGetCatalogoSoftland` es una dependencia de soporte y **no cuenta** dentro del conteo de 33 clases de Luis. `precioProductoJSON`, `precioProductoJSONTest` y `productJSON` **no** se tocaron (instrucción explícita). No se modificó ningún Flow ni metadata fuera de las clases/tests/trigger listados.

**Estado de los siete batches (validados técnicamente, PEKING no cerrado):** Reconciliados con Partial y validados técnicamente — Test Run `707AK00000HB6UY`, 33/33 pruebas aprobadas, 100% de cobertura enfocada en cada uno de los 7 envoltorios. Soporte funcional para PEKING pendiente de definición de Diego porque seis catálogos conservan `RMBAVARIAN` y `BatchGetBodegaSoftland` conserva el fallback existente. Ver sección "Evidencia de ejecución" más abajo.

**Estado de `WorkOrderTrigger`:** Reconciliado con Partial y validado mediante `WorkOrderTriggerTest` — Test Run `707AK00000HB6UY`, cobertura enfocada 94%.

**Clase 33:** **confirmada por Luis — `TrabajoQuoteController`** (2026-07-30). Ver fila 33 de la tabla y sección "Candidatas" (actualizada).

Alcance exacto solicitado por Luis: **33 ApexClass + 3 ApexTrigger**. No se amplía a las 41 clases del alcance técnico total documentado en `PLAN_IMPLEMENTACION_SPRINT1.md` y `BITACORA_IMPLEMENTACION.md`.

**Corrección respecto a la versión anterior de este documento:** el conteo previo ("24 idénticas + productJSON + 8 con diferencias") era aritméticamente inconsistente (sumaba 33 sobre un universo de 32) y usaba un método de comparación (`bash [ "$a" == "$b" ]` sobre `$(...)`) que oculta diferencias de salto de línea final por diseño de la sustitución de comandos. Esta versión recalcula todo con `diff` byte a byte y checksums SHA-256, y corrige la cifra. Ver Fase 1. Esa clasificación (A/B/C/D/E de las 32 clases) describe el estado **al momento de la comparación**, antes de la reconciliación de esta sesión; se conserva sin cambios como registro histórico, y el estado post-reconciliación se documenta aparte en la Fase 2 y en la tabla de las 32 clases.

## Retrieve consolidado de Partial

Snapshot local temporal: `tmp-partial-33x3/` (no rastreado en Git, no debe incluirse en ningún commit). Verificado en esta sesión:

- 36 ApexClass recuperadas (32 confirmadas + 4 candidatas). Ninguna ausente.
- 3 ApexTrigger recuperados (ChanceAccountBavarian, ChanceAccountContado, WorkOrderTrigger). Ninguno ausente.

## FASE 1 — Clasificación corregida de las 32 clases confirmadas

### Método de comparación (checksum/normalización usada)

1. Se normalizó EOL con `tr -d '\r'` en ambos lados (Git y Partial) para no confundir CRLF/LF con una diferencia real.
2. Se calculó **SHA-256** del contenido normalizado de cada archivo (Git vs. Partial).
3. Para los pares con hash distinto, se generó `diff` línea a línea y se inspeccionó manualmente cada hunk (no solo el conteo de líneas).
4. Se aisló específicamente la diferencia de "salto de línea final de archivo" (EOF) recalculando el hash sobre el contenido con el/los saltos de línea finales completamente eliminados (`printf '%s'` en vez de `cat`), para separar ese artefacto de tooling de una diferencia de código real.

Este método reemplaza la comparación por sustitución de variables de bash usada en la versión anterior del documento, que trunca saltos de línea finales de forma silenciosa y podía enmascarar (o, en este caso, sobre-reportar de forma inconsistente) diferencias.

### Categorías (mutuamente excluyentes)

- **A.** Igualdad exacta Git/Partial.
- **B.** Diferencia exclusivamente cosmética.
- **C.** Git contiene código extra frente a Partial.
- **D.** Partial contiene implementación diferente o dependencias ausentes en Git.
- **E.** Otro caso técnico claramente explicado.

### Resultado

| Categoría | Cantidad |
|---|---:|
| A. Igualdad exacta Git/Partial | 23 |
| B. Diferencia exclusivamente cosmética | 1 |
| C. Git contiene código extra frente a Partial | 1 |
| D. Partial contiene implementación diferente o dependencias ausentes en Git | 7 |
| E. Otro caso técnico | 0 |
| **Total** | **32** |

### A. Igualdad exacta Git/Partial (23)

Dividida en dos subgrupos para transparencia total (ambos cuentan como "A", ninguno tiene diferencia de código):

**A.1 — Idénticas byte a byte (mismo SHA-256, 10 clases):** QuoteSoftlandPedidoService, servicioReservas, servicioEliminarReserva, OpportunityServiceInvoker, Registrar_Anticipo_Controller, savePDFfile, BMWServiceQuoteApprovalEmailInvocable, HttpCalloutCreateKit, QuoteService, QuoteSoftlandQueryService.

**A.2 — Idénticas en código, difieren solo en salto de línea final de archivo (EOF; artefacto de la herramienta de retrieve de Partial, que no siempre escribe el `\n` final — el mismo patrón ya visto en `jsconfig.json` al inicio de esta sesión; 13 clases):** BMW_LineaPlantillaEmpresa, ProductControllerTwo, ServicioReservaApartadoArticulosQuote, ServicioConsDispBodegaQuoli, ServicioEliminarReservaArticuloQuote, ServicioCrearSCQuote, QuoteController, cT_QuoteCrcPDFController, cT_QuoteUsdPDFController, UpdateCurrencyScheduler, BMW_ChangeCurrencyWOWOLI, ProductSearcherController, RM_VN_CambiarUbicacion_Ctrl.

### B. Diferencia exclusivamente cosmética (1)

- **productJSON**: una sola línea difiere (`activo = false;`), únicamente por tabulador vs. espacios de indentación. Cero impacto funcional. **No se justifica un commit solo por esto** (instrucción explícita de Luis).

### C. Git contiene código extra frente a Partial (1)

- **precioProductoJSON**: Git conserva un método `Method()` ausente en Partial. Ver Fase 4 para el análisis completo (diff exacto, llamadores, recomendación).

### D. Partial contiene implementación diferente o dependencias ausentes en Git (7)

- BatchGetCategoriaClienteSoftland, BatchGetCentroCostoSoftland, BatchGetCondicionPagoSoftland, BatchGetCuentaContableSoftland, BatchGetImpuestoSoftland, BatchGetSubtipoDocumentoSoftland, BatchGetBodegaSoftland. Ver Fase 2 para el análisis completo.

### E. Otro caso técnico (0)

Ninguna clase de las 32 cae en esta categoría.

## FASE 2 — Investigación de `BatchGetCatalogoSoftland`

### Búsqueda de referencias (punto 1 de la Fase 2)

| Ubicación | Resultado |
|---|---|
| `tmp-partial-33x3/` | La clase **no existe como archivo propio** (no fue parte de los 36 componentes solicitados). Se encontró **referenciada** dentro de las 7 clases `BatchGet*Softland` recuperadas, mediante `new BatchGetCatalogoSoftland(BatchGetCatalogoSoftland.<CONSTANTE>[, company]).execute(context);` |
| `force-app/` (Git) | Ninguna referencia. La clase no existe en este repositorio en ningún punto de su árbol actual. |
| Tests | Ninguna prueba en Git referencia `BatchGetCatalogoSoftland` directamente (no puede, porque la clase no existe en Git). |
| Documentación (`docs/`) | Sin menciones previas a esta sesión. |
| Historial Git (`git log --all -S"BatchGetCatalogoSoftland"`) | La cadena aparece en **commits de documentación** (no de código) de la rama `analysis/pc/redmotors-sprint1-reconcile-33x3-20260727` (worktree `RedMotors-Sprint1-Reconciliacion33`, explícitamente fuera de este hilo de trabajo). Se inspeccionó únicamente en modo lectura (`git show`, sin checkout) para no invadir ese hilo. |

**Hallazgo relevante para Luis (sin actuar sobre él):** esa rama externa concluyó, a partir del Manual (§7.1/Anexo A.1), que `BatchGetCatalogoSoftland` era un **nombre conceptual** usado por el documento original para agrupar una familia de **seis** clases de catálogo, y que *"no existe una clase con ese nombre"* en el org. La evidencia técnica directa obtenida en **esta** sesión contradice esa conclusión: `BatchGetCatalogoSoftland` **sí existe como clase Apex real** en Partial — se comprobó por su uso literal (`new BatchGetCatalogoSoftland(...)`) dentro de las 7 clases recuperadas. La discrepancia en la cantidad (6 vs. 7) tampoco se resolvió en esta sesión. Se documenta el contraste para que Luis/Diego lo resuelvan; no se adoptó la conclusión de la otra rama ni se modificó nada allí.

### Tests que cubren cada uno de los 8 componentes (punto 2 de la Fase 2)

| Componente | Test en Git | Notas |
|---|---|---|
| BatchGetCategoriaClienteSoftland | `BatchGetCategoriaClienteSoftlandTest` | Mock inline (`ExampleCalloutMock`, inner class del propio test) |
| BatchGetCentroCostoSoftland | `BatchGetCentroCostoSoftlandTest` | Mock inline |
| BatchGetCondicionPagoSoftland | `BatchGetCondicionPagoSoftlandTest` | Mock inline |
| BatchGetCuentaContableSoftland | `BatchGetCuentaContableSoftlandTest` | Mock inline |
| BatchGetImpuestoSoftland | `BatchGetImpuestoSoftlandTest` | Mock inline; nota: `servicioEliminarReserva.cls:11` menciona `BatchGetImpuestoSoftland` pero es una **línea comentada** (código muerto/comentario, no una dependencia real) |
| BatchGetSubtipoDocumentoSoftland | `BatchGetSubtipoDocumentoSoftlandTest` | Mock inline |
| BatchGetBodegaSoftland | `BatchGetBodegaSoftlandTest` | Mock inline |
| BatchGetCatalogoSoftland | **Sin test identificado.** No existe la clase en Git, y no se encontró ningún archivo de test con ese nombre en Partial (no se solicitó su retrieve) ni en la documentación. | Desconocido si existe en el org. |

**Hallazgo adicional (no solicitado explícitamente, pero relevante):** cada una de las 7 clases tiene una clase `Schedule*Softland` homóloga en Git (`ScheduleGetCategoriaClienteSoftland`, `ScheduleGetCentroCostoSoftland`, `ScheduleGetCondicionPagoSoftland`, `ScheduleGetCuentaContableSoftland`, `ScheduleGetImpuestoSoftland`, `ScheduleGetSubtipoDocumentoSoftland`, `ScheduleGetBodegaSoftland`) que la invoca como Queueable programado. No se incluyeron en el manifest porque no son tests ni mocks — se documentan aquí por trazabilidad.

### Manifest creado (punto 3 de la Fase 2)

`manifest/sprint1-batch-catalogo-helper-reconcile.xml` — incluye únicamente:

- `BatchGetCatalogoSoftland` (ApexClass, dependencia de soporte)
- Los 7 tests existentes en Git con referencia real confirmada a cada una de las 7 clases del alcance

No se incluyó ningún mock productivo separado porque **no existe evidencia directa** de que se requiera uno: los 7 tests usan mocks internos (`inner class`) auto-contenidos, no una clase de mock compartida.

**`BatchGetCatalogoSoftland` no cuenta como clase 33 ni altera el conteo de 33 entregado a Luis** — es una dependencia técnica de soporte para que las 7 clases del alcance compilen si se reconcilian hacia la versión de Partial, nada más.

### Análisis técnico de `BatchGetCatalogoSoftland` (snapshot `tmp-partial-batch-helper`)

| Aspecto | Resultado |
|---|---|
| Estructura | Clase pública única (`BatchGetCatalogoSoftland`), sin clases internas de dominio (solo `AuthorizationToken` como wrapper de token) |
| Interfaces implementadas | `Queueable`, `Database.AllowsCallouts` — igual que las 7 clases envoltorio que reemplaza |
| Constructores | 3 sobrecargas: `(String catalogName)`; `(String catalogName, String company)`; `(String catalogName, String groupNumber, String actualCurrency)` |
| Parámetros | `catalogName` (constante que selecciona el catálogo: `BODEGA`, `CATEGORIA_CLIENTE`, `CENTRO_COSTO`, `CONDICION_PAGO`, `CUENTA_CONTABLE`, `IMPUESTO`, `SUBTIPO_DOCUMENTO`, más `ACTIVIDAD_COMERCIAL`, `ASEGURADORA`, `INVENTORY` que **no** están en el alcance de las 7 del pedido de Luis); `company` (solo usado por Bodega/ActividadComercial/Aseguradora/Inventory); `groupNumber`/`actualCurrency` (solo Inventory) |
| Endpoints/servicios invocados | Dos estrategias de autenticación distintas según catálogo: (a) `HttpCalloutAuth` + `cls_AuthorizationJSON` para Bodega, ActividadComercial, Aseguradora, Inventory; (b) autenticación "legacy" vía `GET {url}/{ambiente}/oauth/token` para los 6 catálogos restantes, que además llaman `softlandAPI/Catalogs/get...` directamente |
| **Resolución de empresa** | **No homogénea.** Solo `Bodega` recibe `company` y lo usa (`ID_EXTERNO_BODEGA__c = company == 'RMOTOBAI' ? 'RMOTOBAI'+cod : cod`). Los 6 catálogos "legacy" (`CategoriaCliente`, `CentroCosto`, `CondicionPago`, `CuentaContable`, `Impuesto`, `SubtipoDocumento`) **no reciben `company` en absoluto** — el endpoint tiene `compania=RMBAVARIAN` **hardcodeado como literal de texto**, igual para las 7 clases del alcance excepto Bodega |
| **Comportamiento ante empresa nula, desconocida o PEKING** | Para Bodega: cualquier valor que no sea exactamente `'RMOTOBAI'` (incluye `null`, `'RMPEKING'`, `'RMBAVARIAN'` o cualquier otro) cae al mismo `else` — incluye pero no maneja PEKING explícitamente; **este es el mismo patrón de "company fallback" que se ha estado corrigiendo en otras clases de este Sprint** (ver commits recientes `fix(quote-*): prevent company fallback...`), y **sigue sin corregirse aquí**. Para los 6 catálogos legacy: no hay resolución de empresa posible, siempre consultan `RMBAVARIAN` sin importar el contexto — **PEKING no tiene soporte en ninguno de los 6**, no por fallback sino porque el parámetro ni siquiera existe en esas rutas |
| Manejo de errores | Uniforme: cada método de callout envuelve en `try/catch(System.CalloutException e)`, hace `System.debug(e)` y retorna `e.getMessage()` sin relanzar. `execute()` también atrapa `System.CalloutException` a nivel superior. `Database.upsert(records, externalIdField, false)` (allOrNone=false) registra fallas individuales por `System.debug`, no las relanza. No hay manejo para excepciones no-callout (NPE, límites, etc.) |
| Dependencias | Clases ya presentes en Git: `HttpCalloutAuth`, `cls_AuthorizationJSON`, `HttpCalloutActividadComercial`, `HttpCalloutAseguradora`, `HttpCalloutBodega`, `HttpCalloutInventory`, `BatchUpsertProduct2` — **todas confirmadas existentes en `force-app/`, ninguna faltante**. Custom Labels (`URLSoftland`, `ambienteSoftland`, `ClientIdSoftland`, `clientSecretSoftland`) y objetos personalizados (`Bodega__c`, `CategoriaCliente__c`, etc.) no están en el árbol de este repo, pero **tampoco lo estaban para las 7 clases viejas ya presentes** — este repo no mantiene un espejo completo de objects/labels, así que no es una dependencia nueva ni un riesgo introducido por la reconciliación |
| Cobertura mediante los 7 tests recuperados | Los 7 tests de `tmp-partial-batch-helper` **sí ejercitan la nueva clase compartida**: cada uno actualizó su mock interno para responder de forma distinta según el endpoint (`oauth/token` → token; catálogo → `Data`/`Paging`), lo cual es **necesario** porque la clase nueva hace dos llamadas HTTP distintas (auth + catálogo) donde antes cada clase vieja podía resolverlo con un mock más simple. Se confirmó que los 7 tests en Git ya no coincidían con la implementación nueva (diff real de 36-40 líneas cada uno) — **eran obsoletos frente a Partial**, no solo un capricho de estilo. |

**Conclusión de la Fase 1 — estado correcto, no cerrado funcionalmente para PEKING:**

> Git reconciliado con la implementación vigente de Partial. Operación existente preservada. Soporte funcional para PEKING pendiente de definición de Diego porque los seis catálogos usan RMBAVARIAN y BatchGetBodegaSoftland conserva el fallback existente.

No se inventó ninguna configuración de PEKING, endpoint, credencial ni código ERP: el comportamiento de `BatchGetCatalogoSoftland` es exactamente el que tenían las 7 clases viejas para Bodega (mismo fallback conocido, sin corregir), y los otros 6 catálogos tampoco tenían soporte de empresa en la versión vieja (estaban hardcodeados a una única compañía implícita en cada callout individual, sin parámetro `company` en ninguna versión — ni antes ni después del refactor). No hay pérdida de comportamiento por el refactor: es el mismo comportamiento de negocio, reorganizado en una clase compartida. **No se debe marcar esto como funcionalmente completo para PEKING.**

### Reconciliación ejecutada en esta sesión

Se copiaron, byte a byte, desde Partial hacia `force-app/main/default/classes/`:

- `BatchGetCatalogoSoftland.cls` + `.cls-meta.xml` (nuevo, desde `tmp-partial-batch-helper/`)
- `BatchGetCategoriaClienteSoftland.cls`, `BatchGetCentroCostoSoftland.cls`, `BatchGetCondicionPagoSoftland.cls`, `BatchGetCuentaContableSoftland.cls`, `BatchGetImpuestoSoftland.cls`, `BatchGetSubtipoDocumentoSoftland.cls`, `BatchGetBodegaSoftland.cls` + sus `.cls-meta.xml` (desde `tmp-partial-33x3/`)
- Los 7 tests: `BatchGetCategoriaClienteSoftlandTest.cls`, `BatchGetCentroCostoSoftlandTest.cls`, `BatchGetCondicionPagoSoftlandTest.cls`, `BatchGetCuentaContableSoftlandTest.cls`, `BatchGetImpuestoSoftlandTest.cls`, `BatchGetSubtipoDocumentoSoftlandTest.cls`, `BatchGetBodegaSoftlandTest.cls` + sus `.cls-meta.xml` (desde `tmp-partial-batch-helper/`, versiones más recientes necesarias para la implementación compartida)

Verificado post-copia: los 15 archivos `.cls` reconciliados son **idénticos byte a byte** a su fuente en Partial. No se introdujo ninguna mejora, corrección ni configuración adicional — se preservó exactamente el comportamiento vigente (incluido el fallback de empresa no corregido en Bodega y la ausencia total de soporte de empresa en los 6 catálogos legacy). **No se hizo commit todavía** (ver Fase 5).

## FASE 3 — `WorkOrderTrigger`

### Líneas y condiciones exactas añadidas en Partial

Diff exacto (contra la versión de Git, EOL normalizado):

```diff
@@ -91,6 +91,7 @@
                 // Procesar WorkOrders que no tienen usuario asociado
                 List<User> usersToCreate = new List<User>();
+                List<Contact> contactsToMarkAsCommunityUsers = new List<Contact>();
                 List<Peticion_de_envio__c> petitionsToInsert = new List<Peticion_de_envio__c>();

                 for (WorkOrder wo2 : workOrdersToProcess) {
@@ -114,6 +115,10 @@
                             IsActive = true
                         );
                         usersToCreate.add(newUser);
+                        contactsToMarkAsCommunityUsers.add(new Contact(
+                            Id = wo2.ContactId,
+                            Community_User__c = 'Yes'
+                        ));
                     }
                 }

@@ -121,14 +126,13 @@
                 if (!usersToCreate.isEmpty()) {
                     try {
                         insert usersToCreate;
+                        update contactsToMarkAsCommunityUsers;
                         System.debug('Statement after insert.');
                         Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                         //mail.setReplyTo('escsol1f@gmail.com');
                         //String correoEnviar = availableUsers[0].Asesor__r.Email;
-                        //String ccAddresses = 'antonio.dorantesperez@outlook.com';
-                        //correoEnviar = 'antonio.dorantesperez@outlook.com';
                         mail.setToAddresses(new String[]{correoCliente});
```

**Condición exacta:** dentro del bloque que crea un `User` de portal nuevo para el `Contact` de un `WorkOrder` que aún no tiene usuario asociado (rama `if (!usersToCreate.isEmpty())`, ya existente en Git). Por cada `newUser` agregado a `usersToCreate`, Partial también agrega un `Contact(Id = wo2.ContactId, Community_User__c = 'Yes')` a una lista nueva, y después del `insert usersToCreate;` hace `update contactsToMarkAsCommunityUsers;` en bloque (patrón bulk-safe, no DML dentro de loop).

Además, Partial eliminó dos líneas de comentario de depuración que Git conserva (`//String ccAddresses = 'antonio.dorantesperez@outlook.com';` y `//correoEnviar = 'antonio.dorantesperez@outlook.com';` — un correo personal hardcodeado en un comentario).

### Fecha o autor del cambio en Partial

**No determinable con las herramientas disponibles en esta sesión.** Un retrieve de metadata no trae historial de cambios ni autoría; eso vive en el Setup Audit Trail o en el historial de despliegues del org, y esta sesión tiene prohibido el uso de Salesforce CLI. Queda como pregunta abierta para Diego/Luis si se necesita precisión de fecha/autor.

### Commit o historial equivalente en Git

`git log --all -S"Community_User__c"` solo devuelve el **commit inicial** del repositorio (`35fe2e1`). El campo `Community_User__c` ya existía en el árbol desde el primer commit — pero **no** dentro de `WorkOrderTrigger`, sino en cinco Flows ya presentes en Git: `automateCommUser.flow-meta.xml`, `FindCommUser.flow-meta.xml`, `reenviosComunidad.flow-meta.xml`, `Send_Community.flow-meta.xml`, `Sen_Comuniity_Masivos.flow-meta.xml`. Esto confirma que `Community_User__c` es un campo real y activamente usado en automatizaciones existentes del org — no es un campo inventado ni accidental.

### Handler o clases invocadas

Ninguna. `WorkOrderTrigger` no usa un patrón Handler; toda la lógica (incluida la sección modificada) está inline dentro del propio trigger.

### Test relacionado (búsqueda por referencia real, no por nombre)

Se buscó por contenido (no por el nombre `WorkOrderTriggerTest`) cuáles clases realmente insertan/actualizan `WorkOrder` y ejercitan la rama de creación de `User` de portal para el `Contact`. `WorkOrderTriggerTest.cls` es la única clase que: (a) inserta y actualiza `WorkOrder` en múltiples escenarios (precedencia de lookup, selección de Pricebook, líneas, desbloqueo, tipo de cargo), y (b) específicamente ejercita la rama de creación de usuario nuevo, con aserciones sobre `createdUsers[0].ContactId` (líneas ~449-456). Ningún otro test del repositorio inserta un `WorkOrder` sin `User` asociado para forzar esa rama — las demás coincidencias de `insert/update WorkOrder` encontradas en la búsqueda amplia (`ProductControllerTest`, `QuoteControllerTest`, `WoliGridTest`, etc.) prueban objetos distintos que arrastran un WorkOrder de fixture, no la lógica de aprovisionamiento de portal en sí.

`WorkOrderTriggerTest` **no** asserta `Community_User__c` — porque esa lógica no existía en la versión de Git antes de esta sesión. No se creó `manifest/sprint1-workorder-trigger-tests-reconcile.xml` porque **no hizo falta**: la cobertura real ya existe en Git bajo `WorkOrderTriggerTest`, confirmada por referencia de contenido, no por convención de nombre. La versión de este test en Partial no fue recuperada en esta sesión (no estaba en el alcance solicitado), por lo que se desconoce si allí sí asserta `Community_User__c`.

### ¿Las evidencias previas de `WorkOrderTrigger` corresponden al mismo contenido recuperado?

Sí, con una precisión: el deploy real documentado en `BITACORA_IMPLEMENTACION.md` (hito 41, Bloque 4, `0AfAK000000vnon0AA`, 25/07/2026) y el trabajo de cobertura del hito 39 (creación de `User` + `Peticion_de_envio__c` asociados a un WorkOrder) corresponden exactamente a la sección de código que Partial extendió. Es decir: la funcionalidad base (creación de usuario de portal) sí fue trabajada y desplegada dentro de Sprint 1 y está documentada; la extensión específica de `Community_User__c` sobre esa misma sección **no está documentada en ningún bloque de la bitácora**, lo que indica que se agregó en Partial después de ese deploy, por una vía no registrada en este repositorio.

### ¿Actualización vigente o código accidental?

**Todo apunta a que es una actualización vigente e intencional, no código accidental:**

- Usa un campo real y activamente consumido por 5 Flows existentes (no un campo inventado).
- Es coherente con la lógica circundante ya trabajada y desplegada en Sprint 1 (aprovisionamiento de portal).
- Sigue un patrón bulk-safe correcto (acumula en lista, hace un solo `update` fuera del loop) — no parece un parche apresurado.
- Viene acompañado de una limpieza de comentarios de depuración con un correo personal hardcodeado, lo cual sugiere una pasada de revisión deliberada, no un accidente.

No se puede confirmar autoría/fecha exacta sin Setup Audit Trail (fuera de alcance de esta sesión).

### Reconciliación ejecutada en esta sesión

Con las cinco condiciones de la Fase 2 verificadas (bulk-safe; se ejecuta después de `insert usersToCreate;`; no altera otros escenarios del trigger — el diff solo toca la rama de creación de usuario nuevo; el campo `Community_User__c` existe y está activo; los 5 Flows que lo consumen están presentes en Git), se copió `force-app/main/default/triggers/WorkOrderTrigger.trigger` byte a byte desde `tmp-partial-33x3/triggers/WorkOrderTrigger.trigger`. Verificado post-copia: idéntico a la fuente de Partial. `WorkOrderTrigger.trigger-meta.xml` no requirió cambio (ya era idéntico, la única diferencia previa era de fin de línea CRLF/LF, normalizada automáticamente por Git).

**Estado final:** *"Reconciliado con Partial y validado mediante `WorkOrderTriggerTest`."* Test Run `707AK00000HB6UY`: `WorkOrderTriggerTest` corrió con éxito (parte de las 33/33 pruebas aprobadas) y `WorkOrderTrigger` quedó con 94% de cobertura enfocada. La verificación de contenido (archivo idéntico byte a byte a la fuente vigente) más esta ejecución real completan la validación.

**No se modificó `WorkOrderTriggerTest`** — agregar la aserción sobre `Community_User__c` es un cambio de test, no de reconciliación de trigger, y no se solicitó en esta fase. Queda como acción pendiente explícita antes de cualquier deploy real (ver Fase 4, lista de pruebas). **No se hizo commit todavía** (ver Fase 5).

## FASE 4 — `precioProductoJSON`

### 1. Diff exacto de `Method()`

Partial no tiene el método; Git conserva (líneas 173-247 del archivo actual en Git):

```apex
public static void Method() {
    Integer a = 1;
    Integer b = 2;
    ... (71 asignaciones secuenciales Integer, de `a` hasta `sss`) ...
    Integer sss = 71;
}
```

Es una secuencia de 71 asignaciones de variables `Integer` locales, sin ninguna sentencia SQL, DML, callout, ni asignación a variables de instancia/estáticas. No retorna valor, no muta estado de la clase.

### 2. Búsqueda completa de llamadores

**Corrección respecto a lo asumido inicialmente: `Method()` sí tiene un llamador.** Búsqueda `grep` en todo `force-app/`:

```
force-app/main/default/classes/precioProductoJSONTest.cls:56:  precioProductoJSON.Method();
```

Es el **único** llamador en todo el repositorio, y está dentro del propio test de la clase (`precioProductoJSONTest.cls`, dentro de un método `@isTest`). No hay ningún llamador desde código productivo.

Este patrón (`Method()` / `dummyMethod()` sin lógica real, invocado únicamente por su propio test) es un patrón repetido en **más de 25 clases distintas** de este mismo repositorio (`WoliGridController`, `WoliGridHelper`, `WoliGridQueryService`, `ServicioQuoliActualizaSC`, `ReservaOportunidadController`, etc.), todas con la misma convención: un método vacío o de relleno que el test invoca únicamente para inflar el porcentaje de cobertura de código exigido por Salesforce (75%). No es un caso aislado de `precioProductoJSON`; es una convención preexistente y extendida en este org.

### 3. ¿Partial eliminó solo código muerto o también algún comportamiento?

**Solo código muerto.** El método no contiene lógica de negocio, no accede a SObjects, no realiza callouts ni side effects fuera de su propio scope local. Su eliminación en Partial no quita ningún comportamiento observable del sistema.

### 4. Test relacionado

`precioProductoJSONTest.cls`. **Importante:** si en el futuro se reconcilia `precioProductoJSON.cls` para igualar Partial (quitando `Method()`), la línea 56 de `precioProductoJSONTest.cls` (`precioProductoJSON.Method();`) dejaría de compilar, porque el método ya no existiría. Cualquier reconciliación de la clase productiva **requiere también** tocar el test — algo que hoy está fuera de alcance (no se modifica nada en esta sesión) pero que debe quedar planificado junto con esa decisión.

### 5. Recomendación

Reconciliar es técnicamente seguro (cero pérdida de comportamiento) pero **no es solo un cambio de una clase**: implica tocar también el test. Se recomienda que Luis confirme si esto se aborda junto con la limpieza general de código muerto del org (patrón repetido en 25+ clases) o si se trata como un caso aislado de este cierre 33x3. **No se eliminó nada en esta sesión.**

## `productJSON` — diferencia cosmética

Confirmado: diferencia de un solo carácter (tabulador vs. espacios) en una línea, sin ningún efecto funcional. Clasificada como categoría **B**. **No se justifica un commit únicamente por esto**, por instrucción explícita.

## Clases confirmadas (33 de 33)

| N.º | Componente | Categoría | Test asociado | Dependencia externa | Acción pendiente |
|---|---|---|---|---|---|
| 1 | BMW_LineaPlantillaEmpresa | A (EOF) | BMW_LineaPlantillaEmpresa_Test | Ninguna identificada | Ninguna |
| 2 | QuoteSoftlandPedidoService | A (bytes) | TestServiciosQuote | Integración Softland | Ninguna |
| 3 | ProductControllerTwo | A (EOF) | ProductControllerTwoTest | Ninguna identificada | Ninguna |
| 4 | servicioReservas | A (bytes) | servicioReservasTest (+ Mock) | Reserva/apartado de bodega | Ninguna |
| 5 | ServicioReservaApartadoArticulosQuote | A (EOF) | SRAArticulosQuoteTest | Reserva/apartado de bodega | Ninguna |
| 6 | ServicioConsDispBodegaQuoli | A (EOF) | ServicioConsDispBodegaQuoliTest | Consulta de disponibilidad (Quoli) | Ninguna |
| 7 | servicioEliminarReserva | A (bytes) | servicioEliminarReservaTest (+ Mock) | Reserva/apartado de bodega | Ninguna |
| 8 | ServicioEliminarReservaArticuloQuote | A (EOF) | ServicioEliminarReservaArticuloQuoteTest | Reserva/apartado de bodega | Ninguna |
| 9 | ServicioCrearSCQuote | A (EOF) | ServicioCrearSCQuoteTest | Solicitud de compra sobre Quote | Ninguna |
| 10 | QuoteController | A (EOF) | QuoteControllerTest | Ninguna identificada | Ninguna |
| 11 | cT_QuoteCrcPDFController | A (EOF) | cT_QuoteCrcPDFController_test | Generación de PDF | Ninguna |
| 12 | cT_QuoteUsdPDFController | A (EOF) | cT_QuoteUsdPDFController_test | Generación de PDF | Ninguna |
| 13 | UpdateCurrencyScheduler | A (EOF) | UpdateCurrencySchedulerTest | Configuración de Pricebook por Empresa | Ninguna |
| 14 | BMW_ChangeCurrencyWOWOLI | A (EOF) | BMW_ChangeCurrencyWOWOLITest | Configuración de Pricebook/moneda | Ninguna |
| 15 | OpportunityServiceInvoker | A (bytes) | OpportunityServiceInvokerTest | Ninguna identificada | Ninguna |
| 16 | Registrar_Anticipo_Controller | A (bytes) | Registrar_Anticipo_Controller_Test (+ RegistrarAnticipoCasillasTst) | Registro de anticipos | Ninguna |
| 17 | savePDFfile | A (bytes) | savePDFfileTest | Generación/almacenamiento de PDF | Ninguna |
| 18 | BatchGetCategoriaClienteSoftland | D → **Reconciliado y validado técnicamente (100% cobertura enfocada, Test Run `707AK00000HB6UY`); PEKING no cerrado** | BatchGetCategoriaClienteSoftlandTest (reconciliado, ejecutado, pasó) | Softland; `compania=RMBAVARIAN` hardcodeado, sin parámetro de empresa | Pendiente de definición de Diego para PEKING |
| 19 | BatchGetCentroCostoSoftland | D → **Reconciliado y validado técnicamente (100% cobertura enfocada, Test Run `707AK00000HB6UY`); PEKING no cerrado** | BatchGetCentroCostoSoftlandTest (reconciliado, ejecutado, pasó) | Softland; `compania=RMBAVARIAN` hardcodeado, sin parámetro de empresa | Pendiente de definición de Diego para PEKING |
| 20 | BatchGetCondicionPagoSoftland | D → **Reconciliado y validado técnicamente (100% cobertura enfocada, Test Run `707AK00000HB6UY`); PEKING no cerrado** | BatchGetCondicionPagoSoftlandTest (reconciliado, ejecutado, pasó) | Softland; `compania=RMBAVARIAN` hardcodeado, sin parámetro de empresa | Pendiente de definición de Diego para PEKING |
| 21 | BatchGetCuentaContableSoftland | D → **Reconciliado y validado técnicamente (100% cobertura enfocada, Test Run `707AK00000HB6UY`); PEKING no cerrado** | BatchGetCuentaContableSoftlandTest (reconciliado, ejecutado, pasó) | Softland; `compania=RMBAVARIAN` hardcodeado, sin parámetro de empresa | Pendiente de definición de Diego para PEKING |
| 22 | BatchGetImpuestoSoftland | D → **Reconciliado y validado técnicamente (100% cobertura enfocada, Test Run `707AK00000HB6UY`); PEKING no cerrado** | BatchGetImpuestoSoftlandTest (reconciliado, ejecutado, pasó) | Softland; `compania=RMBAVARIAN` hardcodeado, sin parámetro de empresa | Pendiente de definición de Diego para PEKING |
| 23 | BatchGetSubtipoDocumentoSoftland | D → **Reconciliado y validado técnicamente (100% cobertura enfocada, Test Run `707AK00000HB6UY`); PEKING no cerrado** | BatchGetSubtipoDocumentoSoftlandTest (reconciliado, ejecutado, pasó) | Softland; `compania=RMBAVARIAN` hardcodeado, sin parámetro de empresa | Pendiente de definición de Diego para PEKING |
| 24 | BatchGetBodegaSoftland | D → **Reconciliado y validado técnicamente (100% cobertura enfocada, Test Run `707AK00000HB6UY`); PEKING no cerrado** | BatchGetBodegaSoftlandTest (reconciliado, ejecutado, pasó) | Softland; conserva el fallback de empresa existente (no `'RMOTOBAI'` → sin prefijo) | Pendiente de definición de Diego para PEKING |
| 25 | BMWServiceQuoteApprovalEmailInvocable | A (bytes) | Sin test identificado en Git | Envío de correo (email de Salesforce) | Localizar/crear test asociado |
| 26 | precioProductoJSON | **C** | precioProductoJSONTest | Ninguna identificada | Ver Fase 4 |
| 27 | productJSON | **B** | productJSONTest | Ninguna identificada | Ninguna (no amerita commit) |
| 28 | HttpCalloutCreateKit | A (bytes, ya confirmada; corregida en esta sesión) | HttpCalloutCreateKitTest | Callout HTTP externo | **Corregido (2026-07-30) y revisado de nuevo el mismo día:** Omoda/Jaecoo (`Opportunity.RecordType.Name`) ahora resuelven `RMPEKING`/tipo `V`. Se eliminó el `else` genérico hacia `RMOTOBAI`: los Record Types Otobai (Harley-Davidson, Indian, Kawasaki, KTM, Polaris) quedaron enumerados explícitamente; cualquier Record Type fuera de las tres listas (Bavarian/PEKING/Otobai) lanza `EmpresaConfigurationException` en vez de asumir Otobai. `Empresa_Operadora__c` sigue siendo la fuente principal; Record Type es fallback temporal. Sin cambios de endpoint, autenticación ni contrato del request (no se agregó bodega ni sucursal). |
| 29 | ProductSearcherController | A (EOF) | ProductSearcherControllerTest (+ Otobai variant) | Ninguna identificada | Ninguna |
| 30 | QuoteService | A (bytes) | QuoteServiceControllerTest / TestServiciosQuote | Ninguna identificada | Ninguna |
| 31 | QuoteSoftlandQueryService | A (bytes) | Sin test identificado en Git | Integración Softland | Localizar/crear test asociado |
| 32 | RM_VN_CambiarUbicacion_Ctrl | A (EOF) | RM_VN_CambiarUbicacion_Ctrl_Test | Ninguna identificada | Ninguna |
| 33 | TrabajoQuoteController | A (bytes, sin drift Git/Partial) | TrabajoQuoteControllerTest | Softland indirecta (via `EmpresaResolver`/`Empresa__c`) | **Confirmada por Luis (2026-07-30).** Fuente principal: `Opportunity.Empresa_Operadora__c` → `EmpresaResolver.resolve()` → `Empresa.Codigo_ERP__c` (validado contra `{'RMBAVARIAN','RMOTOBAI','RMPEKING'}`). `BMW_Compania__c` queda como fallback temporal solo mientras `Empresa_Operadora__c` esté vacío. Empresas desconocidas **no** caen silenciosamente en `RMOTOBAI`: tanto la rama `Empresa_Operadora__c` (código ERP no soportado) como la rama fallback (`BMW_Compania__c` sin match) lanzan `EmpresaConfigurationException`. Lógica extraída a `resolveEmpresaLegacy()` (`@TestVisible`) para prueba aislada. |

## Revisión final del fallback legacy de HttpCalloutCreateKit (2026-07-30)

Confirmación de Diego registrada aquí porque aplica directamente a esta clase (no a los seis catálogos/schedulers, que no se tocaron en este bloque):

- La autenticación/configuración de Softland usada por `HttpCalloutCreateKit` es la misma para las tres empresas (RMBAVARIAN/RMOTOBAI/RMPEKING) — no requiere endpoint, Named Credential ni credenciales distintas por empresa.
- Las incompatibilidades entre empresa de producto y empresa de bodega deben prevenirse por configuración y filtrado (fuera de este servicio), no agregando un bloqueo rígido dentro de `HttpCalloutCreateKit`. Esta clase no consulta ni valida bodega — no se agregó ninguna lógica de bodega/sucursal aquí, consistente con esa indicación.

Ver fila 28 de la tabla para el detalle técnico del cambio (enumeración explícita de Record Types Otobai + fallo controlado ante Record Type desconocido).

## Triggers (3 de 3)

| N.º | Componente | Categoría | Diferencia funcional real | Test asociado | Acción pendiente |
|---|---|---|---|---|---|
| 1 | ChanceAccountBavarian | A (bytes) | Ninguna | ChanceAccountBavarianTest | Ninguna |
| 2 | ChanceAccountContado | A (bytes) | Ninguna | ChanceAccountContadoTest | Ninguna |
| 3 | WorkOrderTrigger | D → **Reconciliado con Partial y validado mediante `WorkOrderTriggerTest`** (94% cobertura enfocada, Test Run `707AK00000HB6UY`) | Ya no aplica — Git ahora contiene, byte a byte, la marca `Contact.Community_User__c = 'Yes'` igual que Partial; ver Fase 3 | WorkOrderTriggerTest (identificado por referencia real, ejecutado, pasó) | Ninguna acción pendiente para esta reconciliación |

## Nota sobre triggers relacionados no incluidos en el conteo

`ChanceAccountOtobai` existe en Git local y en el manifest `empresa-marcas-chinas-sprint1-retrieve.xml`, pero **no forma parte del conteo de 3 triggers** solicitado por Luis y no se suma ni sustituye a ninguno de los tres anteriores.

## Hallazgos adicionales documentados (no forman parte del conteo de 33)

`TrabajoQuoteController` fue promovida de "candidata" a **clase 33 confirmada** (ver tabla principal). Las siguientes tres clases se conservan como **hallazgos adicionales pendientes de determinar si aplican** — no se implementan en este bloque, no se cuentan dentro de las 33, y no se vuelve a preguntar a Diego sobre puntos que ya están pendientes de su respuesta.

| Hallazgo | Conclusión resumida | Clasificación |
|---|---|---|
| ServicioCitasFieldService | Excluida explícitamente del conteo directo por `PLAN_IMPLEMENTACION_SPRINT1.md`; depende de decisión de negocio pendiente (FSL/portal en Sprint 1) | D |
| ServicioCitas | Misma decisión pendiente; además drift no documentado y masivo contra Partial | D (+E por el drift) |
| RM_VN_CrearOportunidad_Ctrl | Decisión previa ya documentada (`DESFASE_GIT_PARTIAL_TEST_TRAFICO.md`) de mantenerla fuera de Sprint 1 hasta sincronización aparte | D |

**Clase 33 confirmada:** `TrabajoQuoteController` (Luis, 2026-07-30). El ítem residual del fallback de empresa por defecto etiquetado "Siguiente sprint" en `PLAN_IMPLEMENTACION_SPRINT1.md:133` se mantiene documentado como pendiente de Sprint 2 y **no se toca** en este bloque; no invalida la confirmación de Luis sobre la clase en sí.

## Evidencia de ejecución — Test Run 707AK00000HB6UY

La ejecución enfocada de las pruebas listadas en la Fase 4 (propuestas en la iteración anterior de este documento) se completó en Partial:

- **Test Run ID:** `707AK00000HB6UY`
- **Tests Ran:** 33
- **Passed:** 33
- **Pass Rate:** 100%

**Cobertura enfocada por componente:**

| Componente | Cobertura |
|---|---:|
| BatchGetBodegaSoftland | 100% |
| BatchGetCategoriaClienteSoftland | 100% |
| BatchGetCentroCostoSoftland | 100% |
| BatchGetCondicionPagoSoftland | 100% |
| BatchGetCuentaContableSoftland | 100% |
| BatchGetImpuestoSoftland | 100% |
| BatchGetSubtipoDocumentoSoftland | 100% |
| BatchGetCatalogoSoftland | 87% |
| WorkOrderTrigger | 94% |

Esta cifra de cobertura es la de la **ejecución enfocada de esta reconciliación**, no la cobertura global de la org — no se usa ni se debe usar la cobertura global de la org como criterio de este cierre.

**`WorkOrderTrigger`:** Reconciliado con Partial y validado mediante `WorkOrderTriggerTest`.

**Los siete `BatchGet*Softland`:** Reconciliados con Partial y validados técnicamente. Soporte funcional para PEKING pendiente de definición de Diego porque seis catálogos conservan `RMBAVARIAN` y `BatchGetBodegaSoftland` conserva el fallback existente.

**`BatchGetCatalogoSoftland`:** Dependencia técnica de soporte, fuera del conteo de 33 clases.

**`ChanceAccountBavarian` y `ChanceAccountContado`:** Git y Partial coinciden. Fueron ejecutados incidentalmente durante la regresión (aparecen en la corrida de `WorkOrderTriggerTest` por dependencia de trigger compartida en los mismos escenarios de `WorkOrder`), pero esta corrida no representa validación funcional enfocada de esos triggers.

No se volvió a ejecutar Salesforce CLI ni pruebas adicionales en esta sesión — no hay nuevos cambios funcionales que lo requieran.

## Resumen de conteo (corregido)

- ApexClass confirmadas: **33 de 33** (clase 33 = `TrabajoQuoteController`, confirmada por Luis el 2026-07-30; sin drift Git/Partial).
- ApexTrigger confirmados: 3 de 3.
- Hallazgos adicionales documentados fuera del conteo: 3 (`ServicioCitasFieldService`, `ServicioCitas`, `RM_VN_CrearOportunidad_Ctrl`; ninguno implementado en este bloque).
- **Aclaración de conteos:** el "33/33" de este bullet (ApexClass) y el "33/33 pruebas aprobadas" del Test Run `707AK00000HB6UY` (más abajo) son dos números distintos que coinciden por coincidencia — el segundo cuenta métodos de prueba de la reconciliación de los `BatchGet*Softland`/`WorkOrderTrigger`, no clases.
- Clasificación de las 32 **al momento de la comparación** (antes de reconciliar): A = 23, B = 1 (`productJSON`), C = 1 (`precioProductoJSON`), D = 7 (`BatchGet*Softland`), E = 0. **Suma: 32.**
- Estado **después de la reconciliación de esta sesión**: A = 30 (23 originales + las 7 `BatchGet*Softland`, ahora idénticas en **contenido** a Partial), B = 1 (`productJSON`, sin tocar), C = 1 (`precioProductoJSON`, sin tocar), D = 0. **Suma: 32.** "Idéntico a Partial" es una verificación de **contenido** (diff byte a byte), no una validación funcional: el soporte para PEKING en estos 7 sigue sin cerrarse (ver aviso de PEKING más arriba) y ninguno de los 7 tests reconciliados se ejecutó todavía.
- Triggers **después de la reconciliación**: los 3 son idénticos en **contenido** a Partial. `WorkOrderTrigger` reconciliado con Partial y validado mediante `WorkOrderTriggerTest` (Test Run `707AK00000HB6UY`, 94% cobertura enfocada). `ChanceAccountBavarian` y `ChanceAccountContado`: Git y Partial coinciden; fueron ejecutados incidentalmente durante esta misma corrida (aparecen junto a `WorkOrderTriggerTest` por compartir escenarios de `WorkOrder`), pero esa corrida no representa validación funcional enfocada de esos dos triggers.
- Test Run de referencia para toda la evidencia de ejecución de este cierre: `707AK00000HB6UY` — 33/33 pruebas aprobadas, 100% pass rate. Ver sección "Evidencia de ejecución" para el detalle de cobertura por componente. No se usa la cobertura global de la org como criterio de este cierre.
- Manifests de este cierre: `manifest/sprint1-33x3-reconcile.xml` (36 ApexClass + 3 ApexTrigger del alcance 33x3) y `manifest/sprint1-batch-catalogo-helper-reconcile.xml` (dependencia de soporte `BatchGetCatalogoSoftland` + 7 tests; no altera el conteo de 33). No se creó `manifest/sprint1-workorder-trigger-tests-reconcile.xml` (no hizo falta: la cobertura ya existía en Git).

## Restricciones respetadas en este borrador

- No se amplía el alcance a las 41 clases del plan técnico total.
- No se toca Sprint 2.
- No se ejecutó Salesforce CLI ni se realizó deploy ni se tocó Producción.
- Se reconciliaron hacia Git, byte a byte desde Partial: `BatchGetCatalogoSoftland`, las 7 `BatchGet*Softland`, sus 7 tests, y `WorkOrderTrigger`. Ningún otro Apex, test, Flow o metadata fue tocado.
- Clase 33 confirmada por Luis (2026-07-30): `TrabajoQuoteController`. No se agregó ninguna otra clase al conteo.
- `BatchGetCatalogoSoftland` no se contó como clase 33 ni alteró el conteo de 33.
- No se modificó `precioProductoJSON` ni `precioProductoJSONTest` (instrucción explícita, sesión anterior).
- No se modificó `productJSON` por la diferencia cosmética (instrucción explícita, sesión anterior).
- No se inventó ninguna configuración de PEKING en la reconciliación de los batches; se preservó exactamente el fallback vigente en Partial (incluida su limitación conocida).
- No se copiaron carpetas `tmp-partial-*` hacia Git; `tmp-partial-33x3/` y `tmp-partial-batch-helper/` permanecen sin rastrear.
- No se hizo commit de nada en esta sesión (ni del borrador, ni de los manifests, ni de la reconciliación de código).
- No se amplió el conteo de 33 entregado a Luis.
- No se implementaron `ServicioCitasFieldService`, `ServicioCitas` ni `RM_VN_CrearOportunidad_Ctrl` en este bloque; quedan documentados como hallazgos adicionales.
- No se volvió a preguntar a Diego sobre puntos ya pendientes de su respuesta.
- `RMPEKING` permanece activo en Partial (código y, donde aplica, configuración de `Empresa__c`) para `TrabajoQuoteController` y `HttpCalloutCreateKit`; no se desactivó ni se removió soporte existente.
- No se declara el Sprint 1 completo ni se modifican los porcentajes de avance documentados en `BITACORA_IMPLEMENTACION.md`; esta sesión valida únicamente el bloque de cierre de Luis (clase 33 + `HttpCalloutCreateKit`).
