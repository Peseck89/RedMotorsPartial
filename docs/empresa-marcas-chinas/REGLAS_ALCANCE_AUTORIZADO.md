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

### Tabla-puerta de autorización (Fase 4 — estado real, ningún elemento listo para implementación)

| Componente | Tipo | Fuente superior que lo autoriza | Texto exacto | Sprint | Cambio solicitado | Dependencia externa | Estado |
|---|---|---|---|---|---|---|---|
| `rm_vu_inventario` | LWC | Instrucción directa de Luis (rango 1) | *"incluido rm_vu_inventario.js"* / *"el único alcance confirmado para comenzar es: ... rm_vu_inventario"* | Sprint 2 | **No especificado** — solo el componente está confirmado | `RM_VU_Inventario_Ctrl` (Apex) | **PENDIENTE DE CONFIRMACIÓN** — falta la columna "cambio solicitado" para completar la puerta |
| `Opportunity_Flow` | Flow | Instrucción directa de Luis (rango 1, categoría) + documento original (rango 2, vínculo explícito) | Categoría: *"5 Flows de Pricebook"*; vínculo: *"Decision Encuentra_Price_Book..."* | Sprint 2 | **No especificado** por Luis/Diego — solo descrito el problema, no la instrucción de cambio | Ninguna identificada | **PENDIENTE DE CONFIRMACIÓN** — falta confirmación de Luis/Diego por nombre exacto y "cambio solicitado" |
| `Opp_flow_v4` | Flow | Igual que `Opportunity_Flow` | Igual que `Opportunity_Flow` | Sprint 2 | No especificado | Ninguna identificada | **PENDIENTE DE CONFIRMACIÓN** |
| `BMW_ImportarPlantilla` | Flow | Instrucción directa de Luis (categoría) + documento original (vínculo explícito) | *"Fórmula EmpresaProductoMantenimiento: IF(CONTAINS(Pricebook.Name,..."* | Sprint 2 | No especificado | `Plantilla_de_Presupuesto__c.BMW_Compania__c` | **PENDIENTE DE CONFIRMACIÓN** |
| `BMW_Gestiona_Listas_de_Precios` | Flow | Instrucción directa de Luis (categoría) — vínculo funcional NO confirmado | Solo nombre, sin descripción | Sprint 2 | No especificado | Desconocida | **PENDIENTE DE CONFIRMACIÓN** — el más débil de los 5, requiere primero confirmar que sí pertenece a la categoría |
| `Obtener_PricebookEntry_en_Linea_de_Plantilla_de_Presupuesto` | Flow | Instrucción directa de Luis (categoría) — vínculo funcional NO confirmado | Solo nombre, sin descripción | Sprint 2 | No especificado | Desconocida | **PENDIENTE DE CONFIRMACIÓN** — igual que arriba |

**Ningún componente de esta tabla queda en "AUTORIZADO PARA IMPLEMENTACIÓN"** porque ninguno tiene las 8 columnas completas (a todos les falta, como mínimo, "Cambio solicitado"). Los 6 son PENDIENTE DE CONFIRMACIÓN. Esto es el estado correcto y esperado — no un error.

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

- **Ningún lote queda "activo completo".** El Lote 1 (Pricebook) y la parte de `rm_vu_inventario` del Lote 4 son los **únicos con alcance de categoría/nombre respaldado por Luis**, pero **todos sus componentes están en PENDIENTE DE CONFIRMACIÓN** en la tabla-puerta (falta "cambio solicitado" en los 6, y falta confirmación nombre por nombre en los 5 Flows). Se mantienen como el único bloque de trabajo en investigación activa — no como trabajo autorizado para implementar.
- **Lote 4 (Inventario)** se reduce a únicamente `rm_vu_inventario` para efectos de investigación — sus 4 componentes hermanos (`rm_vn_inventario`, `rm_vn_inventario_movil`, `rm_vn_crear_opp_inventario`, `productSearcher`) quedan en PENDIENTE DE CONFIRMACIÓN y fuera de cualquier bloque de trabajo activo.
- **Lotes 2, 3, 5, 6 y 7 quedan congelados** — ninguno de sus componentes tiene siquiera autorización de categoría. No se continúa su preparación hasta recibir confirmación explícita.
- **No se investigan de nuevo los 48 Flows ni los 36 componentes completos del inventario.** El trabajo de investigación adicional se limita exclusivamente al bloque Pricebook + `rm_vu_inventario`.

Este documento actualiza la vigencia de `PLAN_EJECUCION_SPRINT2.md`; ese archivo no se reescribió para no perder el detalle de investigación ya hecho, pero **su estado operativo queda sustituido por esta tabla de autorización**.
