# Reglas de alcance autorizado — Empresa / Marcas Chinas

## Regla principal (OBLIGATORIA, vigente desde 2026-07-28)

> **SOLO SE PUEDE ANALIZAR PARA IMPLEMENTACIÓN, MODIFICAR, PROBAR, DESPLEGAR O CONTAR COMO AVANCE UN ELEMENTO QUE ESTÉ EXPLÍCITAMENTE AUTORIZADO POR LUIS O DIEGO.**

La existencia de un componente en documentos, el Manual, el repositorio, Partial, inventarios, dependencias, búsquedas o análisis de Code/Codex **no significa que forme parte del alcance autorizado.**

Esta regla aplica a todo el trabajo del proyecto Empresa / Marcas Chinas, en cualquier Sprint, en cualquier worktree, a partir de esta fecha. Reemplaza cualquier práctica anterior de tratar "candidato documentado" como equivalente a "alcance de trabajo".

## Reglas innegociables

### 1. Alcance autorizado prevalece sobre discovery

Cuando una búsqueda encuentre más elementos que los solicitados:

- no ampliar el alcance;
- no incorporarlos a lotes de ejecución;
- no contarlos como parte de un Sprint;
- no modificarlos;
- registrarlos únicamente como **"candidatos fuera del alcance confirmado"**.

### 2. Cantidades aproximadas no autorizan selección libre

Si Luis o Diego indican una cantidad aproximada (p. ej. "~20 Flows", "~16 componentes"), **no se eligen elementos del repositorio para completar esos números**. Solo se incluyen nombres respaldados por una instrucción o documento de alcance explícito.

### 3. Candidato no equivale a alcance — clasificación obligatoria

Todo componente debe clasificarse en una de estas cuatro categorías, sin excepción:

| Estado | Definición |
|---|---|
| **AUTORIZADO** | Existe confirmación directa de Luis o Diego, con nombre API exacto. Único estado que puede pasar a implementación. |
| **PENDIENTE DE CONFIRMACIÓN** | Existe evidencia documental (Manual, documento original, Partial, etc.) pero no autorización suficiente. |
| **FUERA DE ALCANCE** | No fue solicitado. |
| **DEPENDENCIA TÉCNICA** | Necesaria para compilar o probar un elemento AUTORIZADO, pero no suma en el conteo del Sprint. |

### 4. Prohibido inferir requerimientos

No se debe deducir que:

- un componente relacionado también debe modificarse;
- todos los elementos de una sección documental pertenecen al Sprint;
- una dependencia cuenta dentro de la cantidad autorizada;
- una implementación existente en Partial representa el requerimiento deseado;
- una similitud de nombre demuestra pertenencia al alcance.

### 5. Puerta obligatoria antes de implementar

Antes de tocar cualquier componente debe existir una tabla con:

- nombre API;
- instrucción o fuente que lo autoriza;
- texto exacto del requerimiento;
- Sprint;
- estado: AUTORIZADO;
- cambio solicitado.

Si falta uno de esos datos, ese elemento se detiene y se marca **PENDIENTE DE CONFIRMACIÓN**.

### 6. Orden de autoridad ante conflictos entre fuentes

1. Instrucción directa más reciente de Luis o Diego.
2. Tabla de alcance entregada por Luis.
3. Documento original del cliente.
4. Manual de desarrollo.
5. Metadata de Partial.
6. Documentos internos de Code/Codex.

Una fuente inferior nunca amplía ni sustituye una instrucción superior.

### 7. Code y Codex no definen alcance

Code y Codex pueden: buscar, comparar, detectar dependencias, encontrar riesgos, proponer preguntas.

Code y Codex **no pueden**: agregar elementos al Sprint, cambiar cantidades, elegir componentes dudosos, reinterpretar estimaciones, ni convertir candidatos en trabajo autorizado.

### 8. Regla de detención

Cuando el alcance de un elemento no sea concluyente: continuar con otros elementos ya autorizados, documentar la duda, preparar una pregunta concreta, y **no implementar el elemento dudoso**.

---

## Aplicación al Sprint 2 — Puerta de autorización (obligatoria antes de tocar código)

**Corrección de estado (2026-07-28, segunda revisión):** la versión anterior de esta tabla marcaba los 6 elementos como "AUTORIZADO". Eso era impreciso. El estado correcto es:

- `rm_vu_inventario`: **AUTORIZADO por nombre** por Luis (alcance confirmado), pero **falta extraer el cambio funcional exacto** — no puede pasar a implementación hasta completar esa columna.
- Los 5 Flows de Pricebook: Luis autorizó la **categoría**, no los 5 nombres individuales. Los nombres propuestos (`Opportunity_Flow`, `Opp_flow_v4`, `BMW_ImportarPlantilla`, `BMW_Gestiona_Listas_de_Precios`, `Obtener_PricebookEntry_en_Linea_de_Plantilla_de_Presupuesto`) permanecen **PENDIENTES DE VALIDACIÓN DOCUMENTAL nombre por nombre** — ver Fase 2 abajo. Ninguno pasa a implementación todavía.

### Fase 2 — Validación documental de los 5 nombres propuestos de Pricebook

Fuentes usadas exclusivamente: (1) instrucción de Luis, (2) documento original, (3) Manual. No se usó similitud de nombres como evidencia.

| Nombre API | Archivo y sección exacta | Texto que lo relaciona con Pricebook | Comportamiento actual descrito | Cambio requerido para Empresa/PEKING | Vínculo | Estado final |
|---|---|---|---|---|---|---|
| `Opportunity_Flow` | PDF original, §4 "Flows", fila 1 (columna izquierda: "Flow / Opportunity_Flow, Opp_flow_v4") | *"Decision Encuentra_Price_Book + Assignments Asigna_Bavarial_Local/Dolar, Asigna_Oto_Local/Otobai_Dolar"* | El Flow tiene una Decision literalmente llamada `Encuentra_Price_Book` que deriva en dos Assignments binarios (Bavarian Local/Dólar vs. Otobai Local/Dólar) | *"Agregar 2 reglas + 2 assignments para la compañía nueva (Local/Dólar)"* | **EXPLÍCITO** (nombre del Decision node y de los Assignments citado textualmente en la fuente) | **CANDIDATO PENDIENTE** — vínculo documental confirmado, pero falta confirmación de Luis/Diego por nombre y falta el "cambio solicitado" exacto (columna de la tabla-puerta) |
| `Opp_flow_v4` | PDF original, §4, misma fila que `Opportunity_Flow` (el documento agrupa ambos nombres en la misma celda de patrón) | Misma cita que `Opportunity_Flow` — el documento asocia explícitamente ambos flows al mismo Decision/Assignments | Mismo patrón que `Opportunity_Flow`, según agrupación explícita del documento (no inferido por parecido de nombre) | Mismo cambio que `Opportunity_Flow` | **EXPLÍCITO** (agrupación textual del documento, no similitud de nombre) | **CANDIDATO PENDIENTE** |
| `BMW_ImportarPlantilla` | PDF original, §4 y §10 | *"Fórmula EmpresaProductoMantenimiento: IF(CONTAINS(Pricebook.Name,"Otobai"),"RMOTOBAI","RMBAVARIAN")"* | Fórmula que lee `Pricebook.Name` y decide binariamente entre 2 códigos de empresa | *"Mismo problema de 'else' binario -- pasar a 3 vías"*; además RecordLookup sobre `Plantilla_de_Presupuesto__c.BMW_Compania__c`, requiere crear plantillas para la compañía nueva | **EXPLÍCITO** (fórmula citada textualmente) | **CANDIDATO PENDIENTE** |
| `BMW_Gestiona_Listas_de_Precios` | PDF original, §4, sección "Resto de la lista" (línea partida en el layout del PDF: "BMW_Gestiona_Listas_" / "de_Precios,"); también Manual, Anexo A.3 (línea de candidato, sin detalle) | El propio documento original dice explícitamente sobre este grupo: *"El grep marcó 38 flows con coincidencias; estos no se inspeccionaron línea por línea"* | **No descrito** — ninguna fuente detalla su lógica interna | **No descrito** — ninguna fuente indica qué cambiar | **INFERIDO únicamente por el nombre** (contiene "Listas_de_Precios"); el propio documento aclara que no fue inspeccionado — no hay comportamiento ni cambio documentado | **CANDIDATO PENDIENTE** — no hay evidencia funcional, solo existencia confirmada |
| `Obtener_PricebookEntry_en_Linea_de_Plantilla_de_Presupuesto` | Manual, Anexo A.3 (línea de candidato: "Active • RedPartial: identical"), sin aparición en el documento original | Ninguna — solo aparece como nombre en la lista de 47 candidatos del Manual | **No descrito** en ninguna fuente | **No descrito** en ninguna fuente | **INFERIDO únicamente por el nombre** (contiene "PricebookEntry") | **CANDIDATO PENDIENTE** — no hay evidencia funcional más allá del nombre |

**Resultado de Fase 2:** de los 5 nombres propuestos, **3 tienen vínculo documental explícito con Pricebook** (`Opportunity_Flow`, `Opp_flow_v4`, `BMW_ImportarPlantilla`) y **2 solo tienen coincidencia de nombre sin descripción funcional** (`BMW_Gestiona_Listas_de_Precios`, `Obtener_PricebookEntry_en_Linea_de_Plantilla_de_Presupuesto`). **Ninguno de los 5 queda en "AUTORIZADO Y CONFIRMADO"** todavía — la categoría fue autorizada por Luis, pero la confirmación nombre por nombre (con "cambio solicitado" explícito) sigue pendiente. **No se descartó ningún nombre** (ausencia de evidencia funcional no es evidencia de exclusión) y **no se sustituyó ninguno por otro** para completar la cifra de 5.

### Fase 3 — Validación de `rm_vu_inventario`

| Campo | Detalle |
|---|---|
| Instrucción directa de Luis que lo incluye | Mensaje de autorización de Sprint 2 (2026-07-28): *"~16 LWC/Aura... incluido rm_vu_inventario.js"*; reconfirmado en el mensaje de la regla de alcance: *"el único alcance confirmado para comenzar es: ... rm_vu_inventario"* |
| Archivos del componente (verificados en Git) | `force-app/main/default/lwc/rm_vu_inventario/rm_vu_inventario.js` (380 líneas), `rm_vu_inventario.html`, `rm_vu_inventario.js-meta.xml`, `columns.js` |
| Referencia exacta en el documento original | **No existe.** El documento original nombra `rm_vu_crear_opp` (§10, FlexiPage de inventario VU) y `rm_vn_inventario`/`rm_vn_inventario_movil` (§5, §10, mapeo de precios) — pero **no nombra `rm_vu_inventario`** en ningún punto del texto extraído |
| Referencia exacta en el Manual | Anexo A.4 "LWC y Aura (28)": `lwc/rm_vu_inventario/rm_vu_inventario` — listado explícitamente como candidato, sin descripción funcional adicional |
| Comportamiento actual (verificado leyendo el código, no por analogía con `rm_vn_inventario`) | Líneas 66-77 de `rm_vu_inventario.js`: array `priceBooks` hardcodeado con exactamente 2 opciones — `{label:'Bavarian Dólar', value:'Bavarian Dólar'}` y `{label:'Otobai Dólares', value:'Otobai Dólares'}` — usado como selector de Pricebook en la grilla de inventario de vehículos usados. `priceBookId` inicializa en `'Bavarian Dólar'` por defecto |
| Uso de Bavarian/Otobai | Confirmado por lectura directa del archivo: son las **únicas 2 opciones** del selector; no hay tercera opción ni lógica dinámica — es una lista estática de 2 elementos, no una consulta a Salesforce |
| Cambio explícitamente solicitado para Empresa/PEKING | **Ninguno.** Ni el documento original ni el Manual describen qué cambiar en este componente específico — solo se confirmó por nombre en la instrucción de Luis, sin especificar el cambio |
| Dependencias Apex (verificadas por import real en el código) | `RM_VU_Inventario_Ctrl` — 3 métodos importados: `getRecords`, `getTipoGasolina`, `getUsadoRecordTypeOptions` |
| Elementos que requieren respuesta de Diego | (1) ¿Se agrega una tercera opción al array `priceBooks` (p. ej. un Pricebook de PEKING) o el mecanismo de selección cambia por completo? (2) Si se agrega, ¿corresponde a los Pricebooks `PEKING Local`/`PEKING Dólares` ya creados en Sprint 1 (`UpdateCurrencyScheduler`, Bloque 3 — ver `BITACORA_IMPLEMENTACION.md`)? Ninguna fuente lo confirma. (3) ¿El Apex `RM_VU_Inventario_Ctrl` ya soporta una tercera compañía o también requiere cambios? — no se inspeccionó su código en esta sesión (dependencia técnica, fuera del alcance de esta validación) |
| Qué puede hacerse autónomamente | Documentar el hallazgo (ya hecho aquí) y preparar la pregunta concreta para Diego/Luis. **No** se puede definir ni implementar el cambio sin respuesta a las preguntas anteriores — hacerlo sería inferir un requerimiento, prohibido por la regla 4 |

### Tabla-puerta de autorización (corregida 2026-07-28, tercera revisión)

**Corrección de esta revisión:** el documento original del cliente es una fuente autoritativa válida (rango 2). Cuando el nombre **y** el cambio funcional están expresamente documentados en una fuente autoritativa, el elemento no requiere una confirmación adicional de Luis por nombre — la regla 6 (orden de autoridad) ya lo respalda. Bajo ese criterio, 3 de los 5 Flows de Pricebook pasan a **AUTORIZADO PARA IMPLEMENTACIÓN**. `rm_vu_inventario` está autorizado en alcance (por nombre, rango 1) pero **ninguna fuente define el cambio requerido** — no puede completar la puerta todavía.

| Componente | Tipo | Fuente superior que lo autoriza | Texto exacto | Sprint | Cambio solicitado | Dependencia externa | Estado |
|---|---|---|---|---|---|---|---|
| `Opportunity_Flow` | Flow | Documento original del cliente (rango 2), §4 | *"Decision Encuentra_Price_Book + Assignments Asigna_Bavarial_Local/Dolar, Asigna_Oto_Local/Otobai_Dolar"* → *"Agregar 2 reglas + 2 assignments para la compañía nueva (Local/Dólar)"* | Sprint 2 | Agregar 2 reglas + 2 assignments en la Decision `Encuentra_Price_Book` para la compañía nueva (Local y Dólar) | Ninguna Apex identificada; depende de que exista el `Pricebook2` de la compañía nueva (no confirmado) | **AUTORIZADO PARA IMPLEMENTACIÓN** |
| `Opp_flow_v4` | Flow | Documento original del cliente (rango 2), §4 (misma fila, agrupado explícitamente con `Opportunity_Flow`) | Misma cita que `Opportunity_Flow` | Sprint 2 | Mismo cambio que `Opportunity_Flow` | Misma que `Opportunity_Flow` | **AUTORIZADO PARA IMPLEMENTACIÓN** |
| `BMW_ImportarPlantilla` | Flow | Documento original del cliente (rango 2), §4 y §10 | *"cambiar el IF binario basado en Pricebook.Name a tres vías y soportar las plantillas de presupuesto de la nueva compañía"* | Sprint 2 | Expandir la Decision de nombre de Pricebook a 3 vías (compañía nueva, Local/Dólar); confirmar soporte de plantillas de presupuesto para la compañía nueva | Ninguna Apex identificada; depende de que exista el `Pricebook2` de la compañía nueva (no confirmado) | **AUTORIZADO PARA IMPLEMENTACIÓN** |
| `rm_vu_inventario` | LWC | Instrucción directa de Luis (rango 1) | *"incluido rm_vu_inventario.js"* / *"el único alcance confirmado para comenzar es: ... rm_vu_inventario"* | Sprint 2 | **No especificado por ninguna fuente** | `RM_VU_Inventario_Ctrl` (Apex) | **AUTORIZADO EN ALCANCE / CAMBIO FUNCIONAL PENDIENTE** — no modificar hasta resolver la pregunta documentada en Fase 3 (arriba) |
| `BMW_Gestiona_Listas_de_Precios` | Flow | Instrucción directa de Luis (categoría) — vínculo funcional NO confirmado | Solo nombre, sin descripción | Sprint 2 | No especificado | Desconocida | **PENDIENTE DE CONFIRMACIÓN** — no modificar, solo identificado por nombre |
| `Obtener_PricebookEntry_en_Linea_de_Plantilla_de_Presupuesto` | Flow | Instrucción directa de Luis (categoría) — vínculo funcional NO confirmado | Solo nombre, sin descripción | Sprint 2 | No especificado | Desconocida | **PENDIENTE DE CONFIRMACIÓN** — no modificar, solo identificado por nombre |

**Nota de precisión importante sobre `BMW_ImportarPlantilla`:** la cita del documento original ("Fórmula EmpresaProductoMantenimiento: IF(CONTAINS(Pricebook.Name,"Otobai"),...)") agrupaba a `BMW_ImportarPlantilla` con `PlanDeMantenimientoV2` en una sola fila. **Verificado por lectura directa del XML en Git: esa fórmula no existe dentro de `BMW_ImportarPlantilla.flow-meta.xml`.** El mecanismo real y verificado es distinto — ver "Fase 3 — Análisis estructural local" abajo. Se documenta como corrección, no se descarta el Flow (el cambio requerido sigue siendo válido: expandir un mecanismo binario Otobai/Bavarian a 3 vías, solo que el mecanismo es una Decision con reglas, no una fórmula `CONTAINS`).

### Fase 3 — Análisis estructural local (Lote 1 Pricebook)

Fuente: lectura directa de los archivos `.flow-meta.xml` en Git de este worktree. No se ejecutó Salesforce CLI, no se hizo retrieve, no se modificó ningún archivo.

#### `Opportunity_Flow` (3827 líneas, apiVersion 54.0, status Active)

- **Decision `Encuentra_Price_Book`:** compara `BMW_ObtenerPresupuesto.Opportunity.CurrencyIsoCode` (`CRC`/`USD`) **Y** `BMW_ObtenerPresupuesto.Opportunity.BMW_Compania__c` (`Otobai`/`Bavarian`, valores literales de texto) con lógica `and`. 4 reglas: Otobai+CRC, Otobai+USD, Bavarian+CRC, Bavarian+USD.
- **Assignments de cada regla:** `Asigna_Oto_Local`, `Asigna_Otobai_Dolar`, `Asigna_Bavarial_Local`, y la cuarta equivalente — cada una asigna un string literal (p. ej. `"Otobai Local"`) a la variable `PriceBookName` (tipo `String`, sin valor por defecto).
- **defaultConnector** (cuando `BMW_Compania__c` no es exactamente `Otobai` ni `Bavarian` — incluiría cualquier valor de una compañía nueva): va directo a `Obtener_PriceBook_Opp` **sin pasar por ningún Assignment** — `PriceBookName` queda vacío.
- **RecordLookup posterior:** busca `Pricebook2 WHERE Name = {!PriceBookName}` (`getFirstRecordOnly=true`). Con `PriceBookName` vacío, no encuentra ningún registro.
- **Decision `Price_Book_vac_o`:** verifica si el `Pricebook2Id` obtenido es nulo; si lo es, no hay una recuperación alternativa documentada en esta rama — **no es un fallback silencioso a Bavarian**, es una ausencia de asignación (comportamiento distinto al patrón "else binario cae en Bavarian" visto en Apex durante Sprint 1).
- **RecordLookups sobre objetos relacionados** (línea ~2042/2086) ya filtran dinámicamente por `BMW_ObtenerPresupuesto.Opportunity.BMW_Compania__c` (no hardcodeado) — si existiera un registro para la compañía nueva, ya se encontraría.
- **IDs hardcodeados detectados** (no relacionados con la rama de Pricebook, en otras partes del Flow): varios Record Type Id literales de 18 caracteres (prefijo `012...`) — **no se deben tocar ni reutilizar como referencia para la compañía nueva sin confirmación**.
- **Dependencias Apex:** ninguna `actionCalls` de tipo `apex` detectada en este Flow.

#### `Opp_flow_v4` (6301 líneas, apiVersion 54.0, status Active)

- Contiene la **misma Decision `Encuentra_Price_Book`** con los mismos nombres de regla y Assignment que `Opportunity_Flow` (`Asigna_Oto_Local`, `Asigna_Otobai_Dolar`, `Asigna_Bavarial_Local`) — mismo patrón de 4 reglas CurrencyIsoCode × BMW_Compania__c, verificado por inspección directa, no por similitud de nombre de archivo.
- **Diferencia relevante:** este Flow además tiene 3 `actionCalls` de tipo `apex`, ninguno relacionado con la rama de Pricebook: `ApiCreditWS` (clase Apex confirmada en Git), `creaCuentaWS` (clase Apex confirmada en Git), `ecflc__flowUserRecordType` (acción de un paquete gestionado externo, namespace `ecflc`, fuera de este repositorio — dependencia externa real).
- Mismos IDs de RecordType hardcodeados que en `Opportunity_Flow`, en otras secciones del Flow.

#### `BMW_ImportarPlantilla` (1223 líneas, apiVersion 55.0, status Active)

- **Decision `Determina_Nombre_Price_Book`:** mismo patrón conceptual — `BMW_ObtenerPresupuesto.CurrencyIsoCode` × `BMW_ObtenerPresupuesto.Opportunity.BMW_Compania__c` (`Otobai`/`Bavarian`) con `and`, 4 reglas → Assignments (`Asigna_Oto_Local`, `Asigna_Oto_Dolar`, `Asigna_Bavarian_Local`, `Asigna_Bavarian_Dolar`) que asignan strings literales a la variable `PriceBookName`.
- **defaultConnector** (compañía nueva, ningún branch coincide): va a `Obtiene_Price_Book_Pre` sin asignar `PriceBookName` — mismo comportamiento de "queda vacío" que en `Opportunity_Flow`, no fallback a Bavarian.
- **`Obtiene_Price_Book_Pre`:** RecordLookup `Pricebook2 WHERE Name = {!PriceBookName}`, luego `Price_Book_vac_o` → si `Pricebook2Id` es nulo, `Asigna_Price_Book` asigna ese Id nulo de vuelta al presupuesto (no hay recuperación alternativa).
- **RecordLookups sobre `Plantilla_de_Presupuesto__c`** (dos apariciones) **ya filtran dinámicamente** por `Obtener_Oportunidad.BMW_Compania__c` — no hardcodeado. Si existe una plantilla para la compañía nueva, ya se encontraría.
- **No se encontró ninguna fórmula `EmpresaProductoMantenimiento` ni expresión `CONTAINS(Pricebook.Name,...)` en este archivo** — corrección respecto a la cita del documento original, ver nota arriba.
- **Dependencias Apex:** ninguna `actionCalls` de tipo `apex` detectada.

#### Comparación estructural esperada contra Partial (preparada, no ejecutada)

Cuando se autorice el retrieve: comparar, para cada uno de los 3 Flows, (a) el número y contenido de `<rules>` dentro de la Decision de Pricebook (`Encuentra_Price_Book` / `Determina_Nombre_Price_Book`) — confirmar que Partial no tenga ya una 3ª regla que Git desconozca (mismo patrón de drift ya visto en Sprint 1 con `WorkOrderTrigger`); (b) el `status` (`Active`/`Draft`/`Obsolete`) de cada versión en Partial; (c) si existe algún `Pricebook2` real en Partial cuyo `Name` ya coincida con un patrón de 3 vías. No se ejecutó ningún retrieve para esto en esta sesión.

#### Confirmación de que el cambio puede hacerse sin inventar datos

Verificado para los 3 Flows: la estructura (Decision + Assignments + RecordLookup por Name) está completamente documentada y es replicable **sin inventar Pricebook IDs, nombres, registros de `Empresa__c` ni códigos ERP** — el patrón de las 4 reglas existentes ya muestra exactamente qué agregar (una 5ª y 6ª regla con la misma forma). **Lo que falta y bloquea la implementación real no es la mecánica del Flow, sino el dato de negocio:** el nombre exacto del `Pricebook2` (Local y Dólar) de la compañía nueva y el valor exacto que tomará `BMW_Compania__c` para esa compañía. Ninguna fuente disponible en este repositorio los define — inventarlos violaría la regla 4. Esto se documenta como pregunta pendiente, no se resuelve por inferencia.

**Actualización (2026-07-29, worktree `RedMotors-Sprint2-Pricebook-Flows-Peking`):** de las dos incógnitas de este párrafo, **los nombres de Pricebook ya quedaron confirmados** (`PEKING Local`, `PEKING Dólares` — mismos registros reales de `Pricebook2` verificados en Partial durante el bloque `precioProductoJSON` de Sprint 1). **El valor de `BMW_Compania__c` sigue sin resolver**, ahora con evidencia exhaustiva de solo lectura contra Partial (describe + datos reales + Record Types + contradicción encontrada en `QuoteSoftlandPedidoService.resolveLegacyCompanyCode`, que ya anticipa `RMPEKING` sin respaldo de picklist). **No se modificó ningún Flow en esta pasada.** Ver `EVIDENCIA_PRICEBOOK_FLOWS_PEKING_20260729.md` para el detalle completo y la pregunta pendiente exacta.

### Candidatos mantenidos fuera del alcance confirmado

Todo lo demás inventariado en `INVENTARIO_SPRINT2_FLOWS_COMPONENTES.md` queda reclasificado bajo esta regla:

| Grupo | Cantidad | Estado bajo esta regla |
|---|---:|---|
| `PlanDeMantenimientoV2` | 1 | PENDIENTE DE CONFIRMACIÓN — comparte patrón con `BMW_ImportarPlantilla` según el documento original, pero no está en los 5 autorizados ni en el Manual |
| Flows con patrón documentado, no autorizados (`Work_Order_from_Quote`, `Work_Order_from_Quote_Selective`, `SegregateWOLIs`, `ReciboUsadosFlow`) | 4 | PENDIENTE DE CONFIRMACIÓN |
| Flows candidatos del Manual sin patrón funcional documentado | 37 | PENDIENTE DE CONFIRMACIÓN (8 de ellos, marcados `Obsolete`, son candidatos débiles) |
| LWC/Aura con patrón documentado, no autorizados (`rm_vn_inventario`, `rm_vn_inventario_movil`, `rm_vn_crear_opp_inventario`, `productSearcher`, `busquedaDetallada`, `qoSearchDetailProduct`, `woSearchDetailProduct`, `localizacionDetails`, `assetGarantiaLookupLwc`, grupo Aura Community ×5) | 14 | PENDIENTE DE CONFIRMACIÓN |
| LWC/Aura candidatos sin patrón funcional documentado | 22 | PENDIENTE DE CONFIRMACIÓN |
| `kpiSucursales`, `cT_Estadisticas_Inventario_lwc` | 2 | PENDIENTE DE CONFIRMACIÓN — además ausentes del Git actual |
| `BatchGetCatalogoSoftland` y los 7 `BatchGet*Softland` | 8 | DEPENDENCIA TÉCNICA de Sprint 1, ya reconciliados — no cuentan en Sprint 2 |

**Ninguno de estos elementos avanza a implementación, prueba o despliegue hasta obtener autorización explícita por nombre.**

### Confirmación de detención de lotes no autorizados

`PLAN_EJECUCION_SPRINT2.md` (versión anterior a esta regla) organizaba 7 lotes por patrón funcional documentado, no por autorización. Bajo esta regla, corregida en esta segunda revisión:

- **Actualizado (tercera revisión):** dentro del Lote 1 (Pricebook), 3 de 5 Flows (`Opportunity_Flow`, `Opp_flow_v4`, `BMW_ImportarPlantilla`) alcanzaron **AUTORIZADO PARA IMPLEMENTACIÓN** — nombre y cambio funcional respaldados explícitamente por el documento original (rango 2). Los otros 2 (`BMW_Gestiona_Listas_de_Precios`, `Obtener_PricebookEntry_en_Linea_de_Plantilla_de_Presupuesto`) siguen PENDIENTE DE CONFIRMACIÓN — no modificar. `rm_vu_inventario` está AUTORIZADO EN ALCANCE pero con CAMBIO FUNCIONAL PENDIENTE — tampoco se modifica todavía. El manifest `manifest/sprint2-pricebook-flows-lote1.xml` cubre exclusivamente los 3 Flows autorizados para implementación.
- **Lote 4 (Inventario)** se reduce a únicamente `rm_vu_inventario` para efectos de investigación — sus 4 componentes hermanos (`rm_vn_inventario`, `rm_vn_inventario_movil`, `rm_vn_crear_opp_inventario`, `productSearcher`) quedan en PENDIENTE DE CONFIRMACIÓN y fuera de cualquier bloque de trabajo activo.
- **Lotes 2, 3, 5, 6 y 7 quedan congelados** — ninguno de sus componentes tiene siquiera autorización de categoría. No se continúa su preparación hasta recibir confirmación explícita.
- **No se investigan de nuevo los 48 Flows ni los 36 componentes completos del inventario.** El trabajo de investigación adicional se limita exclusivamente al bloque Pricebook + `rm_vu_inventario`.

Este documento actualiza la vigencia de `PLAN_EJECUCION_SPRINT2.md`; ese archivo no se reescribió para no perder el detalle de investigación ya hecho, pero **su estado operativo queda sustituido por esta tabla de autorización**.
