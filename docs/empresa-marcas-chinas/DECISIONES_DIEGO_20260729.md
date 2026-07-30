# Decisiones - Reunión Diego 29/07/2026 - Implementación bloque RMPEKING

Fecha del documento: 2026-07-29 (revisado el mismo día tras corrección de implementación no autorizada)
Rama: `feature/pc/redmotors-sprint1-diego-definiciones-20260729`
Base: `feature/pc/redmotors-empresa-marcas-chinas-sprint1-20260724` @ `bf1e260e020a2873ab5c1388ddfb05723cd99e47`
Fuentes usadas: instrucciones directas de Luis, respuestas explícitas de Diego (29/07/2026), documento original, manual, metadata vigente de Partial.

Normalización de nombres aplicada: Bavarian/RMBAVARIAN, Otobai/RMOTOBAI, PEKING/RMPEKING, Softland, Omoda, Jaecoo, Pricebook. Se ignoraron variantes de transcripción (Toby, Autobike, RMO, Omoa, Pertenecen).

**Nota de corrección (2026-07-29, primera pasada):** una implementación previa en este mismo bloque asumió, sin confirmación de Diego, el campo identificador de producto de PEKING en `precioProductoJSON` y agregó una excepción nueva para empresa nula/desconocida. Ambas suposiciones fueron revertidas (código y tests). Este documento refleja el estado revertido.

**Nota de actualización (2026-07-29, segunda pasada):** Diego confirmó expresamente que los seis catálogos Softland deben ejecutarse también para PEKING. En consecuencia, los 6 schedulers reales fueron actualizados para encolar explícitamente RMBAVARIAN y RMPEKING (ver punto 7). RMOTOBAI en estos mismos schedulers sigue **pendiente de Luis** (ver punto 12): la revisión real mostró que hoy solo ejecutan RMBAVARIAN, y agregar Otobai no estaba confirmado.

**Nota de limpieza final (2026-07-29, tercera pasada — previa al dry-run):** `precioProductoJSON.cls` y `precioProductoJSONTest.cls` fueron **restaurados completamente a `HEAD`**, incluyendo la rama de Pricebooks `PEKING Local`/`PEKING Dólares` que se había conservado en una pasada anterior. **`precioProductoJSON` permanece sin cambios hasta confirmar el identificador de producto que debe utilizar RMPEKING. Los nombres de Pricebook ya están confirmados, pero no son suficientes para implementar el flujo completo.** No se debía dejar en el árbol de trabajo una implementación parcial, no probada y excluida del manifest de validación. El diseño (nombres de Pricebook confirmados) queda documentado en el punto 3, pero **no** implementado en código en este bloque. `force-app/main/default/lwc/jsconfig.json` también fue restaurado a `HEAD` (era ruido EOL sin relación con este bloque).

## Confirmado (implementado en este bloque)

1. **PEKING usa la misma instancia, endpoints y servicios de Softland; código ERP `RMPEKING`.** Aplicado en los 6 catálogos (`BatchGetCatalogoSoftland` + 6 wrappers) parametrizando `compania` en la URL en vez de dejarla fija en `RMBAVARIAN`.
2. **Los seis catálogos deben ejecutarse también con RMPEKING.** La razón correcta de esta parametrización es que **Diego confirmó que PEKING utiliza los mismos servicios Softland y que los seis catálogos deben ejecutarse también con RMPEKING** — no es una conservación motivada por los Pricebooks de `precioProductoJSON` (eso es un hallazgo aparte, ver punto 3). Implementado vía parámetro `company` opcional en el constructor de cada batch wrapper (`BatchGetCategoriaClienteSoftland`, `BatchGetCentroCostoSoftland`, `BatchGetCondicionPagoSoftland`, `BatchGetCuentaContableSoftland`, `BatchGetImpuestoSoftland`, `BatchGetSubtipoDocumentoSoftland`) y, ahora, en los 6 schedulers reales (ver punto 7). El constructor sin argumento se mantiene por compatibilidad y sigue por defecto en `RMBAVARIAN`.

## `precioProductoJSON` — RMPEKING implementado (2026-07-29, octava pasada — resuelto por evidencia técnica)

3. **`precioProductoJSON`: Pricebook local `PEKING Local`, Pricebook dólares `PEKING Dólares` — confirmados por Diego, y ahora implementados en código junto con el identificador de producto.** **Actualización (ver punto 58 y siguientes):** la llave de producto para RMPEKING quedó **resuelta por evidencia técnica** (`Product2.CodigoProductoInterno__c = articulo + '-RMPEKING'`), por lo que la rama completa (identificación de producto + selección de Pricebook) ya fue implementada en `precioProductoJSON.cls` en la rama `feature/pc/redmotors-sprint1-precio-producto-peking-20260729`. Este punto queda superado; ver la sección "RMPEKING en `precioProductoJSON`: resuelto por evidencia técnica" al final del documento para el detalle completo.

## Revertido (suposición no autorizada — código deja de tocarse hasta respuesta específica)

4. ~~Empresa nula o desconocida en `precioProductoJSON` falla con `IllegalArgumentException`~~. **Revertido.** Diego no confirmó ningún cambio al comportamiento de errores existente. El bloque `if/else if` de identificación de producto vuelve a su forma original (solo `RMBAVARIAN`/`RMOTOBAI`); si `empresa` no coincide con ninguno, `prod` queda sin inicializar y el comportamiento es el mismo que ya existía en `main` antes de este bloque (no se modificó ni se corrigió ese comportamiento preexistente).
5. ~~Identificador de producto para PEKING = `CodigoProductoInterno__c = articulo + '-' + empresa`~~. **Revertido en su momento** porque se había replicado el patrón de RMOTOBAI sin confirmación de Diego ni evidencia técnica que lo respaldara — la reunión solo había confirmado código de empresa y nombres de Pricebook. **Esta suposición quedó posteriormente resuelta por evidencia técnica real** (investigación exhaustiva de solo lectura en Partial: `CodigoProductoInterno__c` es único global, el patrón `articulo-EMPRESA` se cumple al 100% en toda la población existente, `productJSON.cls` ya usa exactamente `articulo + '-RMPEKING'` desplegado en Partial, y `Codigo_de_Producto__c` presenta 11,840 colisiones reales entre RMBAVARIAN y RMOTOBAI). Ya **no** es una pregunta abierta — ver punto 18 y la sección final del documento.
6. Los tres tests nuevos de `precioProductoJSONTest` que dependían de las suposiciones anteriores (`testprecioProductoJSONPeking`, `testprecioProductoJSONEmpresaDesconocida`, `testprecioProductoJSONEmpresaNula`) fueron eliminados. **`precioProductoJSONTest.cls` es ahora 100% idéntico a `HEAD`** (restaurado en la limpieza final, ver nota arriba) — ya no conserva ningún caso relacionado con RMPEKING.

## RMPEKING en los 6 schedulers reales: CONFIRMADO e implementado

7. **Los 6 schedulers reales de los catálogos (`ScheduleGetCategoriaClienteSoftland`, `ScheduleGetCentroCostoSoftland`, `ScheduleGetCondicionPagoSoftland`, `ScheduleGetCuentaContableSoftland`, `ScheduleGetImpuestoSoftland`, `ScheduleGetSubtipoDocumentoSoftland`) fueron actualizados.** Antes solo invocaban `new BatchGetXxxSoftland()` (constructor sin argumento → defaultea a `RMBAVARIAN`). Ahora cada uno encola explícitamente:
   ```
   System.enqueueJob(new BatchGetXxxSoftland('RMBAVARIAN'));
   System.enqueueJob(new BatchGetXxxSoftland('RMPEKING'));
   ```
   Mismo patrón ya usado en `ScheduleGetBodegaSoftland`, `ScheduleGetActividadComercialSoftland` y `ScheduleGetAseguradoraSoftland` (que encolan Bavarian + Otobai), adaptado al alcance confirmado por Diego (Bavarian + PEKING). No se cambió el cron/frecuencia de ningún scheduler. No se creó ningún scheduler nuevo. El constructor sin argumento se conserva para no romper compatibilidad.
8. **RMOTOBAI no se agrega en estos 6 schedulers porque no forma parte del comportamiento actual de esos seis schedulers.** Antes de este cambio, ninguno de los 6 catálogos ejecutaba RMOTOBAI (solo RMBAVARIAN por default); agregarlo ahora sería ampliar el comportamiento existente fuera del alcance confirmado por Diego (que autorizó explícitamente PEKING, no Otobai, para estos seis). **PENDIENTE DE LUIS.** Si Luis confirma que también debe agregarse RMOTOBAI, el cambio sería una tercera línea `System.enqueueJob(new BatchGetXxxSoftland('RMOTOBAI'))` en cada uno de los 6 schedulers.

## Tests de catálogos y schedulers aislados

9. Los 6 test classes de los batch wrappers (`BatchGetCategoriaClienteSoftlandTest`, `BatchGetCentroCostoSoftlandTest`, `BatchGetCondicionPagoSoftlandTest`, `BatchGetCuentaContableSoftlandTest`, `BatchGetImpuestoSoftlandTest`, `BatchGetSubtipoDocumentoSoftlandTest`) usan `seeAllData=false` (no declaran `seeAllData=true`), mocks (`HttpCalloutMock`), y capturan el endpoint real invocado (`ExampleCalloutMock.capturedEndpoints`) para verificar explícitamente `compania=RMBAVARIAN` (caso default existente), `compania=RMOTOBAI` (caso nuevo, a nivel de wrapper — el constructor sigue aceptando cualquier compañía) y `compania=RMPEKING` (caso nuevo). No dependen de registros reales de Partial.
10. Los 6 test classes de los schedulers reales (`ScheduleGetCategoriaClienteSoftlandTest`, `ScheduleGetCentroCostoSoftlandTest`, `ScheduleGetCondicionPagoSoftlandTest`, `ScheduleGetCuentaContableSoftlandTest`, `ScheduleGetImpuestoSoftlandTest`, `ScheduleGetSubtipoDocumentoSoftTest`) verifican, tras `system.schedule` + `Test.stopTest()`, que el `CronExpression` del `CronTrigger` resultante no cambió (`'0 0 23 * * ?'`), y que existen **dos `AsyncApexJob` independientes de tipo `Queueable` para el wrapper correspondiente** (uno para RMBAVARIAN y uno para RMPEKING, según lo que el scheduler ya encola — ver punto 26 sobre la técnica exacta y por qué se reemplazó el enfoque anterior). Todos con `seeAllData=false`, mocks, sin datos reales de Partial. La verificación de `compania=` en el endpoint queda cubierta directamente por los 6 tests de los batch wrappers (punto 9), no se repite aquí.

## Bodega temporal

11. **Estrategia de la bodega definitiva para PEKING — sin resolver.** Se dejó preparado (sin versionar, sin ejecutar) `scripts/apex/create_temp_peking_bodega.apex`, que crearía únicamente un registro `Bodega__c` provisional marcado como temporal (`ID_EXTERNO_BODEGA__c = 'RMPEKING-TEMP-PARTIAL'`). Los campos usados (`Name`, `bodega__c`, `ID_EXTERNO_BODEGA__c`) se infirieron por uso existente en código (`BatchGetCatalogoSoftland.calloutBodega`, `TestDataFactory.createBodega`), **no** por metadata confirmada — el objeto `Bodega__c` no tiene metadata retrievida en este repo (`force-app/main/default/objects` no contiene `Bodega__c`). En su lugar se creó `manifest/sprint1-bodega-metadata-reconcile.xml` (solo referencia el `CustomObject Bodega__c`, sin ejecutar ningún retrieve ni CLI) para dejar preparado el retrieve real una vez Luis/Diego confirmen campos, obligatoriedad y relación con `Empresa__c`.

## Pendiente de Luis

12. **RMOTOBAI en los 6 schedulers de catálogos: PENDIENTE DE LUIS** (ver punto 8). RMPEKING en estos mismos schedulers ya está CONFIRMADO e implementado; lo que falta decidir es únicamente si además debe agregarse RMOTOBAI, hoy ausente.
13. Valores exactos de empresa, bodega y sucursal para `HttpCalloutCreateKit` (sin cambios en este bloque).
14. Valor funcional que representará PEKING en `BMW_Compania__c`.
15. Estrategia exacta para conservar/comentar lógica que todavía no va a Producción.
16. **Direcciones de correo de despacho/presupuestos para territorios de PEKING** (ver `EVIDENCIA_PDF_CORREOS_EMPRESA.md`, hallazgos 2 y 3): hoy `BMWServiceQuoteApprovalEmailInvocable.getInternalRecipients` y `savePDFfile.getRecipientEmail` no tienen ninguna rama para PEKING; un territorio de PEKING no mapeado hace que `savePDFfile.sendEmailPDFAttachmentWo` falle silenciosamente con `'Email Error'`.
17. Campos reales, obligatorios y relación exacta con Empresa para `Bodega__c` (ver punto 11), y valor temporal permitido.

## Pendiente de Diego / negocio

18. ~~Campo identificador del producto PEKING en `precioProductoJSON`~~ — **RESUELTO por evidencia técnica** (ver punto 5 y la sección final del documento). Ya no es una pregunta pendiente para Diego; no repetir esta pregunta.
19. **Texto de marca en correos ("BMW Service") y direcciones de distribución** (ver `EVIDENCIA_PDF_CORREOS_EMPRESA.md`, hallazgo 1): si `BMWServiceQuoteApprovalEmailInvocable` alguna vez debe cubrir Quotes de PEKING, el asunto y las direcciones deberían dejar de ser BMW-específicos.
20. Configuración de correo/territorio PEKING, acompañada por evidencia (ver puntos 16/19).
21. Datos legales de PDFs y correos cuando se identifiquen campos específicos.

## Fuera del alcance actual (no tocado en este bloque)

22. **Generación de pedidos (`QuoteSoftlandPedidoService`).** Hallazgo relevante: **no existe la condición binaria Bavarian/Otobai** que se asumía como punto de partida. El servicio ya resuelve la empresa de forma genérica vía `EmpresaResolver`/`EmpresaContext` (metadata `Empresa__c`), y `resolveLegacyCompanyCode`/`validateSupportedCompany` (líneas 162-192) ya incluyen `RMPEKING` explícitamente junto a `RMBAVARIAN` y `RMOTOBAI`. No hay código comentado pendiente de estrategia en este archivo. **No se requiere ninguna modificación adicional aquí** — se documenta el hallazgo para que Luis no espere una decisión sobre algo ya resuelto en una reconciliación previa (commit `6f8411d` y posteriores). Único gap detectado: no existe una clase de test dedicada `QuoteSoftlandPedidoServiceTest`; la cobertura de la rama RMPEKING dentro de este servicio no está verificada de forma directa.
23. Flows, `rm_vu_inventario`, `HttpCalloutCreateKit`, `BatchGetBodegaSoftland` (códigos definitivos), Sprint 2: sin cambios, según restricción explícita.
24. Plantillas Visualforce de PDF (`CaseChecklistPDFBeta`, `ChecklistMotosPDFBeta`, etc.) y otros componentes PDF de Sprint 1 (`cT_QuoteUsdPDFController`, `cT_QuoteCrcPDFController`): no revisados, fuera del punto de partida autorizado.

## Auditoría final del bloque autorizado (2026-07-29, tercera pasada — limpieza previa al dry-run)

25. **Resultado de `git diff --check`:** limpio (exit code 0, sin advertencias — tras restaurar `jsconfig.json` a `HEAD` ya no aparece ni la advertencia de conversión CRLF).
26. **`precioProductoJSON.cls` es ahora 100% idéntico a `HEAD`** (`git diff` vacío para este archivo). La rama de Pricebooks `PEKING Local`/`PEKING Dólares` que se había conservado en la pasada anterior fue revertida en la limpieza final (ver nota arriba y punto 3): no se debía dejar una implementación parcial (Pricebook sin identificador de producto), no probada y fuera del manifest de validación.
27. **`precioProductoJSONTest.cls` es 100% idéntico a `HEAD`** (`git diff` vacío).
28. **`BatchGetBodegaSoftland.cls`, `QuoteSoftlandPedidoService.cls` y `HttpCalloutCreateKit.cls`** no aparecen en `git diff --name-status`: idénticos a `HEAD`, sin cambios.
29. Manifest de validación creado: `manifest/sprint1-diego-definiciones-validation.xml` (API 67.0), con exactamente 25 `ApexClass`: 7 productivos + 6 schedulers + 12 tests reales del bloque autorizado. No incluye `BatchGetBodegaSoftland`, `precioProductoJSON`, scripts, PDFs/correos ni componentes de Sprint 2. Verificado que coincide exactamente (sin diferencias) con el conjunto de 25 clases que aparecen en `git diff --name-status`.
30. Sin cambios en Flow, LWC (componentes) o Aura. `force-app/main/default/lwc/jsconfig.json` fue restaurado a `HEAD` en la limpieza final (era ruido EOL sin relación con este bloque); ya no aparece en el diff.
31. RMOTOBAI confirmado ausente en los 6 schedulers (`grep RMOTOBAI` sobre los 6 archivos no arroja resultados).
32. **Conjunto funcional final: exactamente 25 archivos Apex modificados** (7 productivos + 6 schedulers + 12 tests), sin ningún archivo EOL-only ni inesperado en el diff.

## Dry-run 0AfAK000000xuNx0AI — corrección de tests (2026-07-29, cuarta pasada)

Resultado del dry-run: 25/25 componentes compilados, 18/24 pruebas aprobadas, **las 6 pruebas de schedulers fallaron**, `BatchGetCatalogoSoftland` con 48% de cobertura. Sin deploy.

33. **Causa raíz de la falla en los 6 tests de schedulers:** los tests originales guardaban los endpoints capturados en una variable de instancia del mock (`ExampleCalloutMock.capturedEndpoints`) y asumían que esa misma instancia era compartida por los `Queueable` encolados por el scheduler. Cada `Queueable` que se ejecuta al hacer `Test.stopTest()` corre en su propia transacción asíncrona; no hay garantía de que comparta el estado de la instancia de mock capturada por el test, por lo que la aserción sobre `capturedEndpoints` no reflejaba de forma confiable lo ocurrido en esas transacciones separadas.
34. **Corrección aplicada — evidencia vía `AsyncApexJob`:** cada uno de los 6 tests ahora consulta `AsyncApexJob` (`WHERE ApexClass.Name = 'BatchGetXxxSoftland' AND JobType = 'Queueable'`) y verifica `System.assertEquals(2, ...)`, confirmando que el scheduler efectivamente encoló **dos `Queueable` independientes** del wrapper correspondiente (uno para RMBAVARIAN, uno para RMPEKING, según el código ya confirmado del scheduler — no se vuelve a inspeccionar el endpoint aquí, eso ya lo cubren los `BatchGet*SoftlandTest`). Se mantiene la aserción de `CronExpression` sin cambios. No se modificó ningún productivo. No se agregó ningún `@TestVisible`.
35. **Cobertura de `BatchGetCatalogoSoftland` (48% en el dry-run):** ocurre porque el dry-run corrió solo los 12 tests del manifest funcional, y esa clase también es invocada por `BatchGetBodegaSoftland` (catálogo `Bodega`), cuya cobertura previa (87%) dependía de `BatchGetBodegaSoftlandTest`, excluida del set. `BatchGetBodegaSoftland.cls` y su test **no se modificaron** y no forman parte del manifest de los 25 componentes funcionales (siguen fuera de alcance, ver punto 23). Para la próxima validación, `BatchGetBodegaSoftlandTest` debe incluirse en la lista de **pruebas especificadas** (no en el manifest de deploy) únicamente para elevar la cobertura medida de `BatchGetCatalogoSoftland`.
36. **Lista de 13 clases de prueba para la próxima validación** (pruebas especificadas, no manifest — el manifest de deploy sigue con 25 `ApexClass`, sin `BatchGetBodegaSoftlandTest`):
    - `BatchGetCategoriaClienteSoftlandTest`
    - `BatchGetCentroCostoSoftlandTest`
    - `BatchGetCondicionPagoSoftlandTest`
    - `BatchGetCuentaContableSoftlandTest`
    - `BatchGetImpuestoSoftlandTest`
    - `BatchGetSubtipoDocumentoSoftlandTest`
    - `ScheduleGetCategoriaClienteSoftlandTest`
    - `ScheduleGetCentroCostoSoftlandTest`
    - `ScheduleGetCondicionPagoSoftlandTest`
    - `ScheduleGetCuentaContableSoftlandTest`
    - `ScheduleGetImpuestoSoftlandTest`
    - `ScheduleGetSubtipoDocumentoSoftTest`
    - `BatchGetBodegaSoftlandTest` (existente, sin cambios; incluida solo para cobertura de `BatchGetCatalogoSoftland`)

## Dry-run 0AfAK000000xu4c0AA — corrección de cobertura de `BatchGetCatalogoSoftland` (2026-07-29, quinta pasada)

Resultado del dry-run: 25/25 componentes compilados, **25/25 pruebas aprobadas**, único bloqueo: `BatchGetCatalogoSoftland` con **55.375%** de cobertura (mínimo exigido 75%). Sin deploy.

37. **Causa exacta del 55.375%:** incluir `BatchGetBodegaSoftlandTest` en la lista de pruebas especificadas (punto 36) subió la cobertura respecto al 48% anterior, pero no fue suficiente porque `BatchGetCatalogoSoftland.cls` contiene ramas de código para catálogos (`ActividadComercial`, `Aseguradora`, `Inventory`) que **ningún llamador real invoca**. Se verificó mediante `grep -rn "new BatchGetCatalogoSoftland(" force-app/main/default/classes/` que los **únicos 7 llamadores reales** son los 6 wrappers del bloque + `BatchGetBodegaSoftland`. Además, se confirmó (`grep` sobre todos los `*Test.cls`) que **ningún test existente en el repo referencia `BatchGetCatalogoSoftland` directamente** (ni sus métodos estáticos `calloutActividadComercial`, `calloutAseguradora`, `calloutInventory`, ni sus overloads sin `company`). Esas ramas quedan permanentemente sin cobertura mientras solo se ejecuten los wrappers reales.
38. **Líneas y ramas que faltaban (clasificación línea por línea de `BatchGetCatalogoSoftland.cls`):**
    - **Constructores:** el constructor de 1 argumento (`BatchGetCatalogoSoftland(String catalogName)`, líneas 19-21) y el de 3 argumentos (`BatchGetCatalogoSoftland(String catalogName, String groupNumber, String actualCurrency)`, líneas 28-32) **no los invoca ningún llamador real** — los 7 wrappers reales siempre usan el constructor de 2 argumentos (`catalogName, company`).
    - **`execute()` / selección de tipo de catálogo (líneas 44-64):** las ramas `ACTIVIDAD_COMERCIAL` (línea 44-45), `ASEGURADORA` (línea 46-47) e `INVENTORY` (línea 60-61) del `if/else if` nunca se alcanzan en producción ni en tests.
    - **Métodos de callout — ramas de Bodega, Actividad Comercial y Aseguradora:** `calloutBodega` (líneas 162-184) **ya estaba cubierto** por `BatchGetBodegaSoftlandTest` (llamador real). `calloutActividadComercial` (líneas 101-122, ~21 líneas) y `calloutAseguradora` (líneas 124-160, ~36 líneas) estaban **100% sin cobertura** — son las ramas más grandes descubiertas.
    - **`calloutInventory` (líneas 320-371, ~40 líneas):** también 100% sin cobertura; es el bloque más extenso de todos y el mayor contribuyente al porcentaje bajo. No tiene ningún llamador real (`BatchGetInventorySoftland` es una implementación totalmente independiente que no usa `BatchGetCatalogoSoftland`, ver punto 39).
    - **Overloads con `company` (los 6 métodos de 6 argumentos que delegan al de 7 con `DEFAULT_COMPANY`: `calloutCategoriaCliente` líneas 186-188, `calloutCentroCosto` líneas 212-214, `calloutCondicionPago` líneas 239-241, `calloutCuentaContable` líneas 265-267, `calloutImpuesto` líneas 292-294, `calloutSubtipoDocumento` líneas 373-375):** ninguno se invoca directamente — el `execute()` real siempre llama la variante de 7 argumentos.
    - **Manejo de errores:** los bloques `catch (System.CalloutException e) { ...; return e.getMessage(); }` de cada método de callout (y el `catch` propio de `execute()`, líneas 66-68) nunca se ejercitaban porque ningún mock existente fuerza una falla de callout.
    - **Manejo de respuesta exitosa:** ya cubierto para los 6 catálogos del bloque y para Bodega; faltaba para ActividadComercial/Aseguradora/Inventory (ver arriba).
    - **Código no relacionado con los seis catálogos modificados:** `usesHttpCalloutAuth`, `authenticateWithHttpCalloutAuth`, `getLegacyCatalog`, `parseRoot`, `dataRows`, `pageCount`, `value`, `decimalValue`, `upsertCatalog` — helpers compartidos, ya cubiertos indirectamente por los wrappers reales y por Bodega; no requerían tests adicionales.
39. **Tests existentes adicionales identificados (sin modificar):** se buscó explícitamente si `BatchGetActividadComercialSoftlandTest`, `BatchGetAseguradoraSoftlandTest` o `BatchGetInventorySoftlandTest` ejercitaban `BatchGetCatalogoSoftland`. **No lo hacen.** `BatchGetActividadComercialSoftland.cls`, `BatchGetAseguradoraSoftland.cls` y `BatchGetInventorySoftland.cls` son implementaciones **completamente independientes y autocontenidas** (tienen su propio método `calloutWS` con su propia lógica de parseo, sin ninguna referencia a `BatchGetCatalogoSoftland`) — probablemente versiones anteriores a la refactorización que creó `BatchGetCatalogoSoftland`. Por lo tanto sus tests, aunque existen y son válidos para sus propias clases, **no aportan cobertura** a `BatchGetCatalogoSoftland` y no se agregaron a ninguna lista de validación por ese motivo. El único test existente realmente relacionado y ya identificado es `BatchGetBodegaSoftlandTest` (punto 35/36).
40. **Test nuevo creado:** `force-app/main/default/classes/BatchGetCatalogoSoftlandTest.cls` (+ `.cls-meta.xml`). Los tests existentes (los 12 del bloque + `BatchGetBodegaSoftlandTest`) no podían superar el 75% porque, como se documenta en el punto 38, dejan permanentemente sin ejercitar ~100 líneas de código real (ActividadComercial + Aseguradora + Inventory + overloads muertos + manejo de errores). El test nuevo, `seeAllData=false`, sin datos reales de Partial, sin modificar código productivo:
    - prueba los 3 constructores (1, 2 y 3 argumentos);
    - ejecuta `execute()` completo para `ACTIVIDAD_COMERCIAL` (constructor de 2 args) y para `INVENTORY` (constructor de 3 args), y llama directamente `calloutAseguradora` vía `execute()` con `ASEGURADORA`;
    - comprueba la propagación de `company` (`RMPEKING`) en el endpoint real invocado para `ActividadComercial`, capturando el endpoint con un mock de instancia — válido aquí porque la llamada es síncrona dentro del mismo método de test, a diferencia del problema de los schedulers (punto 33), que era específico de `Queueable` asíncronos;
    - llama directamente los 6 overloads de 6 argumentos (`calloutCategoriaCliente`, `calloutCentroCosto`, `calloutCondicionPago`, `calloutCuentaContable`, `calloutImpuesto`, `calloutSubtipoDocumento` sin `company`) para cubrir su línea de delegación a `DEFAULT_COMPANY`;
    - prueba manejo de error controlado: un mock que lanza `System.CalloutException` directamente en `calloutActividadComercial` y `calloutAseguradora` (verificando que el método retorna `e.getMessage()`), y un mock que falla en la autenticación para comprobar que `execute()` no propaga la excepción (su propio `catch`);
    - no inventa tipos de catálogo nuevos: reutiliza exactamente los mismos catalogNames (`ACTIVIDAD_COMERCIAL`, `ASEGURADORA`, `INVENTORY`, y los 6 catálogos del bloque para los overloads) y reutiliza el mismo cuerpo JSON de ejemplo ya usado en `BatchGetBodegaSoftlandTest` (mismo fixture, no uno inventado).
41. **Cobertura estimada según las ramas cubiertas:** con las ramas de ActividadComercial (~21 líneas), Aseguradora (~36 líneas), Inventory (~40 líneas), los 6 overloads muertos (~6 líneas), los 2 constructores muertos (~8 líneas) y varios `catch` de manejo de error ahora ejercitados, se estima que el test nuevo agrega aproximadamente 100-115 líneas cubiertas adicionales sobre una clase de ~250-300 líneas ejecutables reales — llevando la cobertura estimada de `BatchGetCatalogoSoftland` de 55.375% a un rango de **85-95%**, por encima del objetivo mínimo de 80% y del preferible de 85%. La cifra exacta solo se conocerá en el próximo dry-run.
42. **Manifest actualizado:** `manifest/sprint1-diego-definiciones-validation.xml` pasó de 25 a **26** `ApexClass`, agregando únicamente `BatchGetCatalogoSoftlandTest`. No se agregó ningún componente productivo adicional.
43. **Lista final de pruebas para el próximo dry-run** (14 clases: las 12 del bloque + `BatchGetBodegaSoftlandTest` + `BatchGetCatalogoSoftlandTest`):
    - `BatchGetCategoriaClienteSoftlandTest`
    - `BatchGetCentroCostoSoftlandTest`
    - `BatchGetCondicionPagoSoftlandTest`
    - `BatchGetCuentaContableSoftlandTest`
    - `BatchGetImpuestoSoftlandTest`
    - `BatchGetSubtipoDocumentoSoftlandTest`
    - `ScheduleGetCategoriaClienteSoftlandTest`
    - `ScheduleGetCentroCostoSoftlandTest`
    - `ScheduleGetCondicionPagoSoftlandTest`
    - `ScheduleGetCuentaContableSoftlandTest`
    - `ScheduleGetImpuestoSoftlandTest`
    - `ScheduleGetSubtipoDocumentoSoftTest`
    - `BatchGetBodegaSoftlandTest` (existente, sin cambios; solo para cobertura)
    - `BatchGetCatalogoSoftlandTest` (nuevo; en el manifest de deploy y en la lista de pruebas)

## Cierre del bloque — deploy exitoso a Partial (2026-07-29, sexta pasada)

44. **Dry-run exitoso:** `0AfAK000000xtV80AI` — con la corrección de los 3 métodos de `BatchGetCatalogoSoftlandTest` (ver sección anterior, "Dry-run 0AfAK000000xupN0AQ"), el dry-run pasó completo antes de intentar el deploy real.
45. **Deploy exitoso a Partial:** `0AfAK000000xuXe0AI` — Org: RedMotors Partial Sandbox. Usuario: `peseck89@gmail.com.partial.redmotors`. Status: `Succeeded`. Código de salida CLI: `0`. **No hubo cambios en Producción** (el deploy fue únicamente a la sandbox Partial).
46. **Resultado final:** **26/26 componentes** desplegados, **37/37 pruebas aprobadas**, cobertura de `BatchGetCatalogoSoftland` **89%** (por encima del mínimo 75% y del objetivo 80/85% planteado), **los 6 wrappers y los 6 schedulers al 100%** de cobertura.
47. **Confirmación del alcance final desplegado:**
    - Los 6 schedulers (`ScheduleGetCategoriaClienteSoftland`, `ScheduleGetCentroCostoSoftland`, `ScheduleGetCondicionPagoSoftland`, `ScheduleGetCuentaContableSoftland`, `ScheduleGetImpuestoSoftland`, `ScheduleGetSubtipoDocumentoSoftland`) **conservan RMBAVARIAN y agregan RMPEKING** (`System.enqueueJob(new BatchGetXxxSoftland('RMBAVARIAN')); System.enqueueJob(new BatchGetXxxSoftland('RMPEKING'));`).
    - **RMOTOBAI no fue agregado** a estos 6 schedulers — sigue pendiente de confirmación de Luis (ver punto 12).
    - **`precioProductoJSON` continúa pendiente y sin cambios** respecto a `HEAD` — el identificador de producto para RMPEKING sigue sin confirmar por Diego (ver puntos 3, 5 y 18); no se desplegó ninguna rama de PEKING en esta clase.
    - **`scripts/apex/create_temp_peking_bodega.apex` no fue ejecutado** — sigue sin versionar y sin correr, a la espera de la metadata real de `Bodega__c` (ver punto 11 y `manifest/sprint1-bodega-metadata-reconcile.xml`). *(Superado por el cierre de la bodega temporal, ver sección siguiente — el script sí se ejecutó posteriormente, únicamente en Partial.)*

## Cierre documental — bodega temporal RMPEKING creada en Partial (2026-07-29, séptima pasada)

48. **Diego autorizó una bodega temporal para pruebas de PEKING en Partial.** No es un código oficial de Softland ni una definición de negocio definitiva — es exclusivamente un registro de prueba para permitir validaciones funcionales de PEKING en la sandbox Partial mientras se confirma la bodega/código Softland real (ver punto 11).
49. **El registro se creó correctamente en Partial.** Org: RedMotors Partial Sandbox. Usuario: `peseck89@gmail.com.partial.redmotors`. Objeto `Bodega__c`, Id `a2bAK0000000vvxYAA`:
    - `Name`: `PEKING TEMPORAL - PARTIAL - NO USAR EN PRODUCCION`
    - `CurrencyIsoCode`: `USD`
    - `Alias__c`: `PKT01`
    - `bodega__c`: `PKT01`
    - `ID_EXTERNO_BODEGA__c`: `RMPEKINGTEMP01`
    - `Bodega_vehiculos_nuevos__c`: `false`
    - `Sucursal__c`: no asignada
    - `CreatedDate`: `2026-07-29T22:56:44.000Z`, `CreatedBy`: Claudia Pérez
    - Cantidad final encontrada en Partial: 1 registro.
    - La creación se realizó únicamente en Partial, mediante Apex anónimo dinámico (no vía deploy de `scripts/apex/create_temp_peking_bodega.apex` directamente, ver punto 53). **No se tocó Producción.**
50. **`PKT01` y `RMPEKINGTEMP01` son valores provisionales** — no representan códigos oficiales de Softland ni de negocio. Quedan sujetos a reemplazo cuando Diego/negocio confirmen el código real de bodega para PEKING (ver punto 17).
51. **No existe relación directa entre `Bodega__c` y `Empresa`** en la metadata de este objeto — `Bodega__c` no tiene ningún campo de lookup/master-detail hacia `Empresa__c` u objeto equivalente. La vinculación entre bodega y empresa, si existe, se resuelve en otra parte del modelo (fuera del alcance de esta verificación).
52. **No se asignó `Sucursal__c`** en el registro porque no existe todavía una Sucursal de PEKING confirmada por negocio. El campo quedó sin valor deliberadamente, no por omisión accidental.
53. **La metadata recuperada (`force-app/main/default/objects/Bodega__c/`, vía `manifest/sprint1-bodega-metadata-reconcile.xml`) expone los campos `Sucursal__c` e `isPrincipal__c`**, pero al ejecutar `scripts/apex/create_temp_peking_bodega.apex` como Apex anónimo, esos campos **no fueron reconocidos mediante referencias estáticas** (`Bodega__c.Sucursal__c` / `Bodega__c.isPrincipal__c`) — el Apex anónimo dinámico no siempre resuelve referencias estáticas a metadata recién recuperada de la misma manera que una clase compilada y desplegada. Esto es una limitación observada del entorno de ejecución, no un hallazgo sobre la definición real de esos campos.
54. **Se utilizó Schema dinámico y `SObject.put()`** (en vez de asignación directa por referencia estática de campo) precisamente para evitar depender de esas referencias estáticas no resueltas, y así poder completar la creación del registro provisional sin bloquearse por el punto 53.
55. **El registro `a2bAK0000000vvxYAA` debe sustituirse o eliminarse** cuando negocio confirme los códigos oficiales de bodega para RMPEKING — no debe quedar como dato permanente ni usarse como referencia para integraciones reales.
56. **No se realizó ningún cambio en Producción** en este cierre — toda la actividad (recuperación de metadata, ejecución de Apex anónimo, creación del registro) ocurrió exclusivamente en RedMotors Partial Sandbox.
57. **Limpieza de worktree:** se eliminaron del árbol de trabajo local (sin versionar, nunca estuvieron en Git) `force-app/main/default/objects/Bodega__c/` (metadata recuperada, ya cumplió su propósito de permitir la ejecución del script) y `scripts/apex/` (contenía únicamente `create_temp_peking_bodega.apex`, ya ejecutado). Se conservan sin cambios `manifest/sprint1-bodega-metadata-reconcile.xml`, toda la documentación ya versionada, y el código funcional del bloque Softland.

## RMPEKING en `precioProductoJSON`: resuelto por evidencia técnica e implementado (2026-07-29, octava pasada)

Worktree: `C:\Users\dokur\Documents\Repositorios\RedMotors-Sprint1-PrecioProducto-Peking`
Rama: `feature/pc/redmotors-sprint1-precio-producto-peking-20260729` (creada desde `feature/pc/redmotors-empresa-marcas-chinas-sprint1-20260724` @ `42dbd15`).

58. **Decisión resuelta:** `Product2.CodigoProductoInterno__c = articulo + '-RMPEKING'` para la búsqueda de producto de RMPEKING en `precioProductoJSON`, con `PEKING Local` (CRC/local) y `PEKING Dólares` (USD/dólares) como Pricebooks. **No se solicita otra confirmación para esta llave** — queda resuelta por evidencia técnica, no por inferencia lógica:
    - `CodigoProductoInterno__c` es un campo **único a nivel de todo el org** (`unique=true`, `externalId=true` en el describe de `Product2`), a diferencia de `Codigo_de_Producto__c` (`unique=false`).
    - El patrón `CodigoProductoInterno__c = articulo + '-' + EMPRESA` se cumple al **100% en toda la población existente de Partial**, sin excepciones: 93,729/93,729 registros de RMBAVARIAN y 18,929/18,929 de RMOTOBAI con el campo poblado terminan exactamente en `-RMBAVARIAN` / `-RMOTOBAI` respectivamente. No es un patrón exclusivo de Otobai.
    - `productJSON.cls` (clase hermana de creación/actualización de productos) **ya implementa y tiene desplegada en Partial** (`LastModifiedDate` 2026-07-28, `Claudia Pérez`, confirmado idéntico byte a byte entre Git y Partial vía Tooling API) exactamente `CodigoProductoInterno__c = articulo + '-' + empresa` para RMPEKING, con su propio test (`testPekingDetieneAntesDeCrearProductoSinBodegaConfirmada`) que construye literalmente `articulo + '-RMPEKING'`.
    - `Codigo_de_Producto__c` presenta **11,840 colisiones reales** entre RMBAVARIAN y RMOTOBAI (mismo código en ambas empresas), lo que demuestra con datos reales que una búsqueda sin scope de empresa (como la rama RMBAVARIAN) sería ambigua para una tercera empresa.
    - Diego indicó proyectar para PEKING el comportamiento ya existente (mismos servicios Softland); esta indicación por sí sola **no** se interpretó como confirmación automática de la llave (se investigó exhaustivamente antes de decidir, ver informe de investigación de solo lectura del mismo día).
59. **Implementación en `precioProductoJSON.cls`:** se amplió la condición existente de `RMOTOBAI` para incluir `RMPEKING` (`else if(empresa=='RMOTOBAI' || empresa=='RMPEKING')`), reutilizando exactamente la misma construcción `String identificador = articulo+'-'+empresa;` y la misma consulta `WHERE CodigoProductoInterno__c = :identificador`. Se agregó una rama `else if(empresa == 'RMPEKING')` en la selección de Pricebooks (`PEKING Local` / `PEKING Dólares`), en paralelo a las de Bavarian/Otobai. **No se tocó la rama RMBAVARIAN. No se modificó el comportamiento de RMOTOBAI. No se agregó ninguna excepción nueva para empresa desconocida (mismo comportamiento preexistente). No se eliminó `Method()`. No se refactorizó nada fuera de este alcance. No se modificó `productJSON.cls`.**
60. **Tests agregados en `precioProductoJSONTest.cls`** (`seeAllData=false`, reutilizando el patrón real de la clase, sin datos reales de Partial): `testprecioProductoJSONPekingLocal` (Pricebook `PEKING Local`, moneda local), `testprecioProductoJSONPekingDolares` (Pricebook `PEKING Dólares`), `testprecioProductoJSONPekingNoColisionaConOtraEmpresa` (crea un `Product2` de RMOTOBAI con el mismo `Codigo_de_Producto__c` que uno de RMPEKING y verifica que `precioProductoJSON` actualiza únicamente el producto RMPEKING, dejando intacto el de la otra empresa — prueba directa de la colisión real encontrada en el punto 58). Los dos tests existentes (`testprecioProductoJSONBavarian`, `testprecioProductoJSONOtobai`) **no se modificaron**, confirmando que RMBAVARIAN y RMOTOBAI conservan su comportamiento.
61. **Manifest creado:** `manifest/sprint1-precio-producto-peking-validation.xml` (API 67.0), con exactamente 2 `ApexClass`: `precioProductoJSON` y `precioProductoJSONTest`.
62. **No se creó bodega, producto ni `PricebookEntry` real en Partial en esta fase.** No se ejecutó Salesforce CLI. No hubo deploy, commit ni push — solo cambios locales en el worktree aislado, pendientes de revisión.

## Corrección de Record Type en los tests PEKING (2026-07-29, novena pasada)

63. **Causa raíz confirmada del segundo dry-run fallido (`0AfAK000000xxVV0AY`):** `Product2.Empresa__c` sí contenía `RMPEKING` correctamente en los tres tests; el error `INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST` ocurría porque, al no especificarse `RecordTypeId`, Salesforce asigna el Record Type **por defecto del usuario de pruebas: "Vehiculos"** (`defaultRecordTypeMapping=true`), cuyo conjunto de valores restringidos de `Empresa__c` **solo incluye `RMBAVARIAN` y `RMOTOBAI`**. El texto "PEKING" del mensaje de error corresponde a la **etiqueta** (`<label>`) del valor `RMPEKING` en la metadata del campo, no a una transformación del dato — investigado y confirmado sin ejecutar ningún cambio (ver informe de investigación de solo lectura del mismo día).
64. **`RMPEKING` está habilitado únicamente en el Record Type `Producto Red Motors`** (DeveloperName `Producto_Red_Motors`, confirmado en `force-app/main/default/objects/Product2/recordTypes/Producto_Red_Motors.recordType-meta.xml`) de los 4 Record Types de `Product2` (`Vehiculos`, `Materiales`, `Producto Altica`, `Producto Red Motors`).
65. **Corrección aplicada:** los tres tests PEKING (`testprecioProductoJSONPekingLocal`, `testprecioProductoJSONPekingDolares`, `testprecioProductoJSONPekingNoColisionaConOtraEmpresa`) ahora asignan dinámicamente `RecordTypeId = getProductoRedMotorsRecordTypeId()` al `Product2` de RMPEKING, mediante un método privado que consulta `RecordType` por `SObjectType='Product2' AND DeveloperName='Producto_Red_Motors'` y afirma que existe exactamente uno. **No se usó ningún Id fijo de Record Type.** El producto distractor RMOTOBAI de la prueba de colisión no se modificó (es válido en los 4 Record Types).
66. **`productJSON.cls` mantiene un riesgo futuro separado**, no corregido en este bloque: solo asigna `RecordTypeId = 'Vehiculos'` explícitamente dentro de `applyVehicleFields` (productos vehículo); para productos no-vehículo nunca asigna `RecordTypeId`, por lo que también caería en el default "Vehiculos" si llegara a crear un producto RMPEKING. Hoy esto no se manifiesta porque `validateCompanyCanProcessWarehouses` bloquea la creación de productos RMPEKING antes de cualquier `insert`. **No se modificó `productJSON.cls` en este bloque.**

## Cierre del bloque — deploy exitoso a Partial (2026-07-29, décima pasada)

67. **Dry-run exitoso:** `0AfAK000000xxk10AA` — 2/2 componentes compilados, **5/5 pruebas aprobadas** (`testprecioProductoJSONBavarian`, `testprecioProductoJSONOtobai`, `testprecioProductoJSONPekingLocal`, `testprecioProductoJSONPekingDolares`, `testprecioProductoJSONPekingNoColisionaConOtraEmpresa`), cobertura de `precioProductoJSON` **90%**, código de salida `0`.
68. **Deploy exitoso a Partial:** `0AfAK000000xxqT0AQ` — Target Org `peseck89@gmail.com.partial.redmotors`. 2/2 componentes, 5/5 pruebas, cobertura 90%, código de salida `0`. **Producción no fue tocada** — el deploy fue únicamente contra la sandbox Partial.
69. **Resumen final del bloque RMPEKING en `precioProductoJSON` (ya desplegado en Partial):**
    - `Product2.CodigoProductoInterno__c = articulo + '-RMPEKING'` es la llave de búsqueda para RMPEKING (misma construcción que RMOTOBAI, ver punto 59).
    - Pricebooks `PEKING Local` (moneda local) y `PEKING Dólares` (dólares) asignados en la selección de Pricebook.
    - Los tres tests PEKING resuelven dinámicamente el Record Type de `Product2` vía `DeveloperName = 'Producto_Red_Motors'` (método `getProductoRedMotorsRecordTypeId()`, ver punto 65) — **no se usó ningún Id fijo de Record Type en ningún momento de este bloque**.
    - `testprecioProductoJSONPekingNoColisionaConOtraEmpresa` confirma con datos reales de prueba que un producto de **otra empresa** (RMOTOBAI) con el mismo `Codigo_de_Producto__c` que el `articulo` enviado **no se actualiza** — `precioProductoJSON` encuentra y actualiza únicamente el producto RMPEKING correcto vía `CodigoProductoInterno__c`.
    - `RMBAVARIAN`/`RMOTOBAI` conservan su comportamiento sin cambios; `productJSON.cls` no fue modificado.
    - **Producción no fue tocada** en ningún momento de este bloque.
