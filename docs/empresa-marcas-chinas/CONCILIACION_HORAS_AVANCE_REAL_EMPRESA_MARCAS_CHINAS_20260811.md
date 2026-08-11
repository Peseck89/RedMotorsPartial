# Conciliación de horas y avance real — Empresa / Marcas Chinas (PEKING)

**Fecha:** 11 de agosto de 2026 (revisión metodológica y actualización de Sprint 3 sobre la versión inicial del
mismo día).
**Alcance:** todo el proyecto Empresa / Marcas Chinas (Sprint 1, 2 y 3), no solo Sprint 3.
**No es el entregable Word final.** No se modificó Salesforce, no se hizo deploy, no se crearon ni borraron datos,
no se repitió ninguna auditoría técnica ya cerrada — este documento solo reconcilia horas y estado real contra
documentación ya existente.

---

## 1. Resumen ejecutivo

**Corrección metodológica sobre la versión anterior de este documento:** la primera versión presentaba 150h como
"51.2h completadas / 98.8h pendientes", tratando como "pendientes" 86h que en realidad pertenecen a bloques donde
la estimación original **no permite medir con precisión** cuánto está completo o pendiente (población real distinta
a la estimada, sin lista nominal de correspondencia, o sin base numérica de origen). Forzar esas 86h a la columna
"pendientes" implicaba afirmar algo que no se puede sostener con evidencia: que se sabe con precisión que esas
horas faltan, cuando lo correcto es decir que **no se puede cuantificar con precisión** cuánto de esas horas está
completo o pendiente. Esta versión corrige eso.

**Resultado correcto (Opción B — con bloques no cuantificables), de las 150h documentadas:**

| Categoría | Horas | % del total |
|---|---:|---:|
| A. Horas confirmadas completadas | **51.2h** | 34.1% |
| B. Horas confirmadas pendientes | **12.8h** | 8.5% |
| C. Horas no cuantificables con precisión | **86.0h** | 57.3% |
| **Total** | **150.0h** | **100%** |

Verificado con script: 51.2 + 12.8 + 86.0 = 150.0 ✓ (ver sección 2 para el detalle fila por fila y sección 7 para
el cálculo verificado).

**No se presenta un porcentaje global único de avance del proyecto**, porque el 57.3% de las horas (86h) no tiene
una base de medición precisa — un porcentaje calculado solo sobre A y B ("80% de 64h") describiría exclusivamente
los 3 bloques que sí son medibles (ítems 1, 4, 5), no el proyecto completo. Ese porcentaje parcial se muestra en la
sección 7, etiquetado explícitamente como parcial.

**Sprint 3 no se declara cerrado.**

---

## 2. Regla de cálculo utilizada

Regla confirmada por Luis: si un bloque estima N componentes/N horas y solo una parte está realmente completa, las
horas completadas se calculan **proporcionalmente** al trabajo realmente cerrado — nunca "horas trabajadas =
horas completadas", y nunca se conservan como completadas horas de Sprint 1/2 solo porque ya se reportaron antes.

Fórmula aplicada cuando el bloque lo permite:

```
horas completadas = horas estimadas × (unidades confirmadas completas / unidades totales del bloque)
horas pendientes  = horas estimadas − horas completadas
```

Un bloque se considera **prorrateable con precisión** (categorías A/B) solo si se cumplen las tres condiciones:
1. La estimación original define una cantidad numérica de componentes ("~N").
2. Existe una fuente actual que clasifica, por nombre, cada componente en completo/pendiente.
3. La población de la fuente actual coincide (o es razonablemente conciliable) con la población estimada
   originalmente.

**Corrección de esta versión:** si falta cualquiera de las tres condiciones, el bloque completo pasa a la
categoría **C (no cuantificable con precisión)** — no a "pendiente". La versión anterior de este documento
aplicaba correctamente esta regla en el análisis cualitativo de cada ítem (secciones 4-6), pero luego, en la tabla
de totales, forzaba esas mismas horas no prorrateables a la columna "pendientes". Esa inconsistencia interna es la
que se corrige aquí: **no cuantificable con precisión no es lo mismo que confirmado pendiente**, y tratarlas igual
exageraba artificialmente el número de horas "pendientes" con una precisión que la evidencia no respalda.

---

## 3. Tabla completa del alcance original

**Fuente:** `docs/empresa-marcas-chinas/DEV_Evaluacion_Alcance_Actualizada_20260805.docx` (extraída directamente del
XML del documento; el PDF original `DEV Evaluación...docx.pdf` no contiene esta tabla de horas, solo el análisis
técnico narrativo). Es la única fuente localizada con horas por bloque, Sprint asignado y cantidad de componentes.

| # | Requerimiento | Componentes estimados | Horas | Sprint asignado (original) |
|---|---|---|---:|---|
| 1 | Objeto configurable para manejo de marcas | Objeto + clases de soporte | 14h | Sprint 1 |
| 2 | Picklists/campos + fix typos | 13 campos | 4h | Sin Sprint asignado en el documento (nota original: "confirmar si se abordó en Sprint 1") |
| 3 | Record Types nuevos | 2 RT + 4-6 en otros objetos (Lead/Order/Case) | 10h | Sin Sprint asignado (misma nota) |
| 4 | Apex (incluye 8 clases Pricebook/Softland) | ~33 clases + 3 triggers | 30h | Sprint 1 |
| 5 | Flows (incluye 5 de Pricebook) | ~20 flows | 20h | Sprint 2 |
| 6 | LWC/Aura (incluye rm_vu_inventario) | ~16 componentes | 20h | Sprint 2 |
| 7 | Layouts/FlexiPages/Quick Actions | ~10+10+5 = 25 | 5h | Sprint 3 |
| 8 | List Views | ~25 base × variantes para 2 RT nuevos | 8h | Sin Sprint asignado |
| 9 | Validation Rules/Approval Processes + roles | ~7 VR + ~6 AP = 13 | 10h | Sprint 3 |
| 10 | Profiles/Permission Sets | ~40 a ajustar + ~10-15 nuevos | NA | NA |
| 11 | Custom Metadata/Integración Softland | RM_Config, mapeos, credenciales (sin conteo numérico) | 8h | Sprint 3 |
| 12 | Global Value Sets de marca | 3 GVS | 1h | Sin Sprint asignado |
| 13 | Crear y poblar 2 Pricebooks nuevos (dato) | Pricebook2 + PricebookEntry masivo | 10h | Sin Sprint asignado |
| 14 | Pruebas de integración end-to-end / regresión | Opp→Quote→WO→Factura, inventario, aprobaciones, Softland | 10h | Sin Sprint asignado |
| | **Total (excluye ítem 10, NA)** | | **150h** | |

**El documento original declara el total como un rango "144-150h".** La suma exacta y verificada de las cifras
visibles en la tabla es **150h** (calculada con script, no mentalmente — coincide con el extremo superior del
rango). **No existe en las fuentes revisadas una explicación documentada de cómo se llega a 144h** (el extremo
inferior). Se marca: **`INCONSISTENCIA_REQUIERE_REVISION`** — el origen exacto del extremo inferior del rango
(144h) no se pudo verificar con las fuentes disponibles en esta sesión. Se preserva el rango tal como el documento
lo declara, sin fabricar una explicación.

---

## 4. Cálculo fila por fila (con verificación por script)

Para cada fila: horas originales, método de medición, A (completadas cuantificables), B (pendientes
cuantificables), C (no cuantificables), y justificación. **A + B + C = horas originales en cada fila, sin
excepción** — verificado con script (sección 7).

| # | Requerimiento | Horas | Método de medición | A completadas | B pendientes | C no cuantificable | Justificación |
|---|---|---:|---|---:|---:|---:|---|
| 1 | Objeto configurable para marcas | 14h | Prorrateo 1/1 (bloque único, terminado) | 14.0 | 0.0 | 0.0 | `TERMINADO_REAL` — objeto y clases desplegados y en uso activo en Sprint 2/3 |
| 2 | Picklists/campos + fix typos | 4h | No prorrateable | 0.0 | 0.0 | 4.0 | Sin fuente que clasifique los 13 campos por nombre; sin evidencia de ejecución en ninguna fuente revisada — no se puede afirmar completado NI pendiente con precisión |
| 3 | Record Types nuevos (otros objetos) | 10h | No prorrateable | 0.0 | 0.0 | 10.0 | Opportunity/Lead confirmados con evidencia fuerte, pero el ítem original es un rango "4-6 objetos" sin lista nominal — no se puede fraccionar la estimación original con precisión |
| 4 | Apex ~33 clases + 3 triggers | 30h | Prorrateo 35/36 (fuente nominal, población coincide) | 29.2 | 0.8 | 0.0 | 32/33 clases + 3/3 triggers confirmados Git=Partial, Test Run 33/33; clase 33 nunca seleccionada |
| 5 | Flows ~20 | 20h | Prorrateo 8/20 (fuente nominal, población coincide exactamente) | 8.0 | 12.0 | 0.0 | 6 sin cambio técnico + 2 no aplica = 8 sin desarrollo pendiente; 12 modificar = desarrollo pendiente |
| 6 | LWC/Aura ~16 | 20h | No prorrateable | 0.0 | 0.0 | 20.0 | Población real auditada (25) no coincide con la estimada (~16); sin lista nominal de correspondencia. Único componente con autorización nominal confirmada: `rm_vu_inventario` (no se le asigna fracción de hora para no inventar denominador) |
| 7 | Layouts/FlexiPages/Quick Actions ~25 | 5h | No prorrateable | 0.0 | 0.0 | 5.0 | Población real (78) casi 3× la estimada (~25); sin lista nominal. 19/78 ya no requieren desarrollo (evidencia real), pero no se traduce a fracción de las 5h sin inventar correspondencia |
| 8 | List Views | 8h | No prorrateable | 0.0 | 0.0 | 8.0 | Sin evidencia de ejecución en ninguna fuente revisada |
| 9 | Validation Rules/Approval Processes | 10h | No prorrateable | 0.0 | 0.0 | 10.0 | Población real de AP (12) no coincide con la estimada (~6); VR sí 100% QA-completas (4/4) pero mezclar VR+AP en una sola fracción de horas inventaría precisión que no existe |
| 11 | Custom Metadata/Softland | 8h | No prorrateable | 0.0 | 0.0 | 8.0 | El bloque nunca se estimó por conteo de componentes — no hay base numérica de la cual partir |
| 12 | Global Value Sets de marca | 1h | No prorrateable | 0.0 | 0.0 | 1.0 | Sin evidencia de ejecución en ninguna fuente revisada |
| 13 | Pricebooks (dato) | 10h | No prorrateable | 0.0 | 0.0 | 10.0 | Los 2 Pricebook2 existen confirmados; la población masiva de PricebookEntry no tiene evidencia; no se puede dividir las 10h entre ambas sub-tareas sin inventar una proporción |
| 14 | Pruebas E2E/regresión | 10h | No prorrateable | 0.0 | 0.0 | 10.0 | Sin evidencia de ejecución end-to-end real en ninguna fuente revisada |
| | **Total** | **150h** | | **51.2** | **12.8** | **86.0** | Verificado: 51.2+12.8+86.0 = 150.0 |

Cálculo verificado con script (`python3`, no mentalmente):

```
Total horas originales: 150
Total A (completadas confirmadas): 51.2
Total B (pendientes confirmadas): 12.8
Total C (no cuantificables): 86.0
A+B+C: 150.0
Todas las filas cuadran individualmente: OK
```

**No se aproximó ninguna cifra para hacerla cuadrar.** Los únicos valores no enteros (29.2/0.8 en el ítem 4 y
8.0/12.0 en el ítem 5) provienen directamente de fracciones exactas (35/36 y 8/20) sobre horas enteras.

---

## 5. Sección Sprint 1

**Presupuesto comprometido:** 44h, confirmado en `CIERRE_SPRINT1_44H.md` como exactamente los ítems 1 (14h) + 4
(30h) de la tabla — ningún otro ítem de la tabla original formó parte del compromiso de 44h de Sprint 1.

### Ítem 1 — Objeto configurable para manejo de marcas (14h)

- **Qué se entregó:** objeto `Empresa__c`, clases `EmpresaContext`, `EmpresaResolver`,
  `EmpresaConfigurationException`, `EmpresaResolverTest` — desplegados y funcionando.
- **Qué sigue vigente:** el objeto y el resolver se usan activamente en todo el trabajo de Sprint 2 y 3 (por
  ejemplo, `Empresa_Operadora__c` en Opportunity, `Pricebook2.Empresa__c`).
- **Clasificación: `TERMINADO_REAL`.** A=14h, B=0h, C=0h.

### Ítem 4 — Apex, ~33 clases + 3 triggers (30h)

- **Qué se entregó:** 32 de 33 clases confirmadas (Git = Partial, categoría A) + 3 de 3 triggers confirmados.
  Ejecución de pruebas real: Test Run `707AK00000HB6UY`, **33/33 tests aprobados** (100% pass rate). Los 7
  `BatchGet*Softland` (parte de las 8 clases de Pricebook/Softland mencionadas en el propio ítem) fueron
  reconciliados a categoría A con cobertura al 100%.
- **Qué quedó pendiente:** la **clase 33 nunca fue seleccionada ni confirmada** — el borrador de cierre
  (`CIERRE_TECNICO_SPRINT1_33_CLASES_3_TRIGGERS_DRAFT.md`) se autodeclara explícitamente "BORRADOR. No constituye
  cierre formal." El soporte funcional de PEKING en los 7 `BatchGet*Softland` (6 de 7 con `RMBAVARIAN` fijo en el
  código) sigue **pendiente de una definición funcional de negocio** — pero esto es alcance del ítem 11 (Sprint 3),
  no de este ítem 4 (ver sección 8, dependencias NEGOCIO).
- **Clasificación: `PARCIAL`, prorrateable con precisión.** 33 clases + 3 triggers = 36 unidades. Confirmadas:
  32 + 3 = 35. Pendiente: 1 (clase 33). A = `30h × 35/36 = 29.2h`; B = `30h × 1/36 = 0.8h`. Verificado: 29.2+0.8=30.0 ✓.
- **Nota de cierre administrativo:** el propio `CIERRE_SPRINT1_44H.md` deja un checkbox sin marcar: *"Checkpoint
  con Luis: confirmar que acepta el cierre..."* — el cierre formal de Sprint 1 sigue pendiente de esa confirmación
  explícita, independientemente del avance técnico real calculado arriba.

### Ítems 2 y 3 — Picklists (4h) y Record Types en otros objetos (10h) — sin Sprint asignado

No formaron parte de las 44h comprometidas de Sprint 1 según `CIERRE_SPRINT1_44H.md` (que solo suma ítems 1+4=44h),
a pesar de que la tabla original trae la nota manual *"confirmar si se abordó en sprint 1 ya que pareció algo de
eso"* para ambos.

- **Ítem 3 (Record Types):** hay evidencia directa y confirmada de que los Record Types Omoda y Jaecoo **sí
  existen y funcionan** en Opportunity y Lead. No hay evidencia revisada sobre si también se replicaron en
  Order/Case (el propio ítem dice "4-6 en otros objetos", un rango, no una lista nominal) — impide prorratear.
- **Ítem 2 (Picklists):** no se encontró evidencia, en ningún documento revisado, de que los 13 campos/typos se
  hayan corregido específicamente.
- **Clasificación: `PENDIENTE_DE_VERIFICACION`, categoría C (no B).** No se afirma que estén completos (regla
  explícita: no asumir 100% por haberse reportado), pero tampoco se afirma con precisión que falten 14h — no existe
  fuente nominal que permita esa afirmación. A=0h, B=0h, C=14h (4h+10h).

**Total Sprint 1 (ítems 1+4, los únicos con presupuesto comprometido):**

| Estimadas | A completadas | B pendientes | C no cuantificable | Avance % (sobre lo medible) |
|---:|---:|---:|---:|---:|
| 44h | 43.2h | 0.8h | 0h | **98.2%** (44h totalmente medibles) |

Verificado: 43.2 + 0.8 + 0 = 44.0 ✓. Sprint 1 es el único bloque de presupuesto donde el 100% de las horas es
medible con precisión (A+B=44h, C=0h) — el 98.2% sí es un porcentaje defendible para este bloque específico.

---

## 6. Sección Sprint 2

**Presupuesto original:** ítem 5 (Flows, 20h) + ítem 6 (LWC/Aura, 20h) = 40h.

### Ítem 5 — Flows (20h, ~20 flows estimados)

**Fuente de estado actual:** `AUDITORIA_CIERRE_SPRINT2.md` / `MATRIZ_CIERRE_SPRINT2.csv` (2026-08-04). Población
auditada: **exactamente 20 Flows**, coincide con la estimación original ("~20") — cumple las 3 condiciones de
prorrateo con precisión.

| Clasificación | Cantidad |
|---|---:|
| SIN CAMBIO TÉCNICO (no requiere desarrollo adicional) | 6 |
| NO APLICA (fuera de alcance PEKING, confirmado) | 2 |
| MODIFICAR (desarrollo pendiente) | 12 |
| BLOQUEADO | 0 |
| **Total** | **20** |

**Por qué NO_APLICA cuenta como alcance cerrado (no como pendiente ni como excluido):** los 2 Flows marcados
"NO APLICA" ya fueron evaluados y confirmados como fuera del alcance funcional de PEKING — es decir, la pregunta
"¿este Flow necesita trabajo para Omoda/Jaecoo?" ya tiene respuesta definitiva (no) y no queda ninguna acción de
desarrollo abierta sobre ellos. Por eso se cuentan junto con "sin cambio técnico" como las 8 unidades que **no
tienen desarrollo pendiente**, distinto de dejarlos fuera del denominador (que inflaría artificialmente el % de
avance) o de contarlos como trabajo pendiente (que no es cierto — no hay nada que desarrollar en ellos).

**No se usa el ejemplo ilustrativo del pedido original de Luis ("15 completos, 5 pendientes")** — era un ejemplo
hipotético para explicar la fórmula, no un dato real. La matriz real y autoritativa confirma **8 de 20 sin trabajo
pendiente** (6 sin cambio técnico + 2 no aplica) y **12 de 20 con desarrollo todavía pendiente** (modificar).

**Cálculo:** A = `20h × 8/20 = 8.0h`; B = `20h × 12/20 = 12.0h`. Verificado: 8.0+12.0=20.0 ✓.

**Nota sobre "sin cambio técnico":** la propia auditoría aclara (`RESUMEN_EJECUTIVO_AUDITORIA_SPRINT2.md`): *"'Sin
cambio técnico' no significa validado funcionalmente ni cerrado."* Se cuenta aquí como horas de **desarrollo**
completadas (no se necesita programar nada más), no como QA funcional cerrado.

**Clasificación: `PARCIAL`, prorrateable con precisión.** A=8.0h, B=12.0h, C=0h.

### Ítem 6 — LWC/Aura (20h, ~16 componentes estimados)

**Población auditada real: 25 bundles** (20 LWC + 5 Aura) — no 16. Diferencia de población del 56% frente a la
estimación original, sin lista nominal documentada de cuáles 16 de esos 25 corresponden al alcance original.

| Clasificación | Cantidad |
|---|---:|
| SIN CAMBIO TÉCNICO | 4 |
| NO APLICA | 2 |
| MODIFICAR | 3 |
| BLOQUEADO | 16 |
| **Total** | **25** |

**Clasificación: `HORAS_NO_PRORRATEABLES_CON_PRECISION` → categoría C, no B.** A=0h, B=0h, C=20h.

**Qué sí puede decirse sin inventar (cualitativo, sin fracción de hora):** `rm_vu_inventario` es el único
componente con autorización y confirmación explícita por nombre (`REGLAS_ALCANCE_AUTORIZADO.md`). No se le asigna
una fracción de hora porque hacerlo obligaría a elegir un denominador (16 o 25) sin base documentada para esa
elección.

**Total Sprint 2 (ítems 5+6):**

| Estimadas | A completadas | B pendientes | C no cuantificable |
|---:|---:|---:|---:|
| 40h | 8.0h | 12.0h | 20.0h |

Verificado: 8.0+12.0+20.0 = 40.0 ✓. **No se presenta un % único para Sprint 2** — el ítem 5 (20h) es 100% medible
(40.0% de avance sobre esas 20h), pero el ítem 6 (20h) no lo es; combinarlos en un solo porcentaje escondería que
la mitad del bloque no tiene una base de medición precisa.

---

## 7. Sección Sprint 3 — estado actualizado (2026-08-11)

**Alcance original de Sprint 3, según la tabla del documento de 2026-08-05:** únicamente los ítems 7 (Layouts/
FlexiPages/Quick Actions, 5h), 9 (Validation Rules/Approval Processes + roles, 10h) y 11 (Custom Metadata/
Integración Softland, 8h) — **total 23h**. No se incorporan automáticamente elementos de RQ308 ni versiones
posteriores del alcance que no estén en esta tabla original.

### 7.A `Opportunity_Record_Page_VN` — decisión funcional RESUELTA

Diego confirmó (2026-08-11) que Omoda/Jaecoo deben reutilizar **`Opportunity_Record_Page_VN`** — no se crea una
página nueva. **Esta decisión funcional ya está `RESUELTA`, no pendiente de Diego.** Confirmado técnicamente: el
FlexiPage ya contiene, tanto en Git como en Partial, condiciones de visibilidad explícitas para Omoda/Jaecoo en 3
campos (verificado con un retrieve de solo lectura contra Partial, sin persistir cambios).

Lo que **sí** sigue entrelazado con trabajo que no está completamente rastreado en este repositorio parcial es la
**asignación final** de la página (qué App + Record Type + Perfil la usa) — esa asignación vive en metadata de
aplicaciones/perfiles que no están versionados en este repositorio parcial, y coincide con el área que Diego está
renombrando. Esto es un punto técnico de ejecución, no una decisión pendiente de tomar.

### 7.B Jerarquía Director/Gerente/Jefe de Sucursal — implementación técnica desplegada

Diego confirmó: crear la misma lógica de jerarquía para Omoda/Jaecoo que ya usan las marcas existentes, usando
temporalmente el usuario Admin en los tres niveles (Director/Gerente/Jefe) hasta que negocio confirme responsables
reales.

**Trabajo ejecutado (commit funcional `0f17c3a`):**
- `OpportunityTriggerHandler.cls` actualizado con ramas nuevas para Omoda y Jaecoo en `beforeInsert` y
  `beforeUpdate`, replicando exactamente el patrón ya usado por BMW/MINI/Polaris/Kawasaki/Motorrad/
  Harley-Davidson.
- 6 campos `Lookup(User)` nuevos en `Sucursal__c`: `DirectordeVentasOmoda__c`, `GerentedeSucursalOmoda__c`,
  `JefesdeSucursalOmoda__c`, `DirectordeVentasJaecoo__c`, `GerentedeSucursalJaecoo__c`, `JefesdeSucursalJaecoo__c`.
- Deploy exitoso a Partial (0 errores de componente).
- Regresión confirmada sin cambios: `OpportunityTriggerHandler_Test` 12/15 y `OpportunityTriggerHandler2_Test` 4/4,
  idéntico antes y después del deploy (las 3 fallas son un bug preexistente de codificación de caracteres en
  `TestDataFactory.cls`, no relacionado con este cambio).

**Estado correcto: `IMPLEMENTACION_TECNICA_DESPLEGADA` / `VALIDACION_EN_VIVO_PENDIENTE_PROPAGACION_SCHEMA`.**
**No se marca `QA_COMPLETADO` todavía** — falta poblar el Admin temporal en el registro de Sucursal y confirmar en
vivo que Omoda/Jaecoo resuelven Director/Gerente/Jefe, y que BMW/MINI no tienen regresión. Esto no se pudo
completar en esta sesión por el bloqueo descrito en 7.C.

**No se le asigna una fracción de horas del ítem 9** (Validation Rules/Approval Processes, 10h) — el trabajo de
jerarquía no estaba en la tabla de alcance original de 2026-08-05 con horas propias; se documenta como trabajo
real adicional, sin inventarle una cifra que el alcance original nunca le asignó (misma regla aplicada
anteriormente al ajuste de `Flag_Vehiculo_Nuevo_FM__c`).

### 7.C Bloqueo de propagación de schema — dependencia técnica temporal de Salesforce

A las 13:03 del 2026-08-11, una consulta SOQL estándar contra `Sucursal__c` seguía devolviendo
`No such column 'DirectordeVentasOmoda__c'`, mientras que `FieldDefinition` (Tooling API) confirma que los 6 campos
existen correctamente como `Lookup(User)`. Se descartó: caché local del CLI (no existe tal caché), reversión de
los campos (siguen existiendo), y error de versión de API.

**Clasificación: `DEPENDENCIA_TECNICA_TEMPORAL_SALESFORCE_SCHEMA_PROPAGATION`.** No se atribuye a Diego ni a
negocio — es una demora de propagación del lado de la plataforma Salesforce, ajena a la implementación.

**Pendiente en cuanto el schema se libere** (script ya preparado, sin necesidad de repetir el deploy):
1. Poblar los 6 campos del registro de Sucursal "Escazú" con el usuario Admin.
2. Validar Omoda (Director/Gerente/Jefe = Admin).
3. Validar Jaecoo (mismo resultado).
4. Confirmar regresión cero en BMW/MINI.
5. Confirmar que el `relatedUserField` de los Approval Processes de descuento resuelve aprobador correctamente.

### 7.D Approval Processes de descuento — lógica resuelta, QA en vivo pendiente de la jerarquía temporal

Confirmado técnicamente (retrieve de solo lectura de 1 de los 8 procesos): el aprobador se resuelve mediante
`assignedApprover type="relatedUserField"` apuntando directamente a `Opportunity.DirectorVentas__c` /
`GerenteSucursal__c`, y los criterios de entrada exigen que esos campos no estén vacíos. **Los 8 procesos son
neutrales a marca — no requieren ningún cambio específico para Omoda/Jaecoo.**

**Estado correcto: `LOGICA_RESUELTA` / `QA_EN_VIVO_PENDIENTE_JERARQUIA_TEMPORAL`.** Ya no falta decidir qué
jerarquía usar (eso se resolvió el 2026-08-11 con la definición de Diego) — lo único pendiente es que la
jerarquía temporal tenga datos (bloqueado por 7.C) para poder confirmar en vivo que el `relatedUserField` resuelve
al Admin temporal como aprobador.

**Approval Process de centro de costo (2, Quote y Work Order):** sin cambio — entrada a "Pendiente de aprobación"
ya confirmada dos veces con placeholders. Aprobación real pendiente de centro de costo/aprobador oficiales
(negocio).

**Approval Processes de garantía (2):** sin cambio — bloqueados por falta de definición funcional de negocio.

### 7.E UI — Layouts/FlexiPages/Quick Actions (estado más reciente, sin cambio desde la versión anterior)

Universo auditado: **78** (46 Layouts + 27 FlexiPages + 5 Quick Actions).

| Estado | Cantidad |
|---|---:|
| `SIN_CAMBIO_REQUIERE_REGRESION` | 10 |
| `RESUELTO_POR_EQUIVALENCIA_VENTAS_NUEVAS` | 8 |
| `RESUELTO_AJUSTE_VEHICULO_NUEVO_OMODA_JAECOO` (Quote_Record_Page_VN) | 1 |
| `BLOQUEADO_ASIGNACION_FUNCIONAL` (pendiente de negocio) | 54 |
| Tratado aparte en 7.A (`Opportunity_Record_Page_VN`, decisión ya resuelta) | 1 |
| `NO_APLICA` | 4 |
| **Total** | **78** |

**No se convierte 19/78 en una fracción de las 5h originales** — la estimación original (~25 componentes, 5h) no
tiene una base de correspondencia con el universo real de 78, así que cualquier fracción sería inventada. El
avance real (19 de 78 ya no requieren desarrollo) se reporta cualitativamente, no en horas.

### 7.F Validation Rules — sin cambio

4 de 4 Validation Rules `QA_FUNCIONAL_COMPLETADO` — 15/15 escenarios aprobados.

### 7.G Softland — sin cambio, solo pendientes reales

13 clases Apex reconocen `RMPEKING`, 36/36 pruebas automatizadas con mocks aprobadas. Sin conexión real a
Softland. Pendiente de negocio: contenido real de catálogo, bodegas oficiales y convención de clave externa
(colisión con Bavarian ya demostrada técnicamente), regla de Pricebook por defecto. **No se reinterpretan los
placeholders usados en pruebas como datos finales.**

### Total Sprint 3 (ítems 7+9+11 = 23h originales)

**Ninguno de los 3 ítems de Sprint 3 es prorrateable con precisión** contra su estimación original de horas.
A=0h, B=0h, C=23h. El avance cualitativo real (7.A a 7.G) es sustancial y verificado, pero no se traduce en una
cifra de horas sin inventar una correspondencia que la estimación original no define.

---

## 8. Totales — verificados con script (Opción B: A + B + C = 150h)

| Grupo | Horas estimadas | A completadas | B pendientes | C no cuantificable |
|---|---:|---:|---:|---:|
| Sprint 1 (ítems 1+4) | 44h | 43.2h | 0.8h | 0h |
| Sprint 2 (ítems 5+6) | 40h | 8.0h | 12.0h | 20.0h |
| Sprint 3 (ítems 7+9+11) | 23h | 0h | 0h | 23.0h |
| Sin Sprint asignado (ítems 2,3,8,12,13,14) | 43h | 0h | 0h | 43.0h |
| **Total consolidado** | **150h** | **51.2h** | **12.8h** | **86.0h** |

Verificación cruzada por script: Sprint1(44) + Sprint2(40) + Sprint3(23) + SinSprint(43) = 150 ✓; A+B+C por fila y
por grupo cuadra en todos los casos (ver sección 4 y script de la sección 1).

**Porcentaje parcial, solo sobre las horas medibles (A+B = 64h, ítems 1, 4 y 5):** 51.2h / 64h = **80.0%**. Este
porcentaje describe únicamente esos 3 bloques — no se extrapola al resto del proyecto.

**No existe un porcentaje único defendible para el 100% del proyecto**, porque 86h (57.3% del total) no tienen una
base de medición precisa. Esto no significa "0% de avance" en esas 86h — significa que el avance real (sustancial
en varios de esos bloques, ej. 4 VR 100% completas, 19/78 elementos UI resueltos, jerarquía Omoda/Jaecoo ya
implementada técnicamente) no se puede traducir en una fracción precisa de las horas originalmente estimadas.

---

## 9. Comparación contra horas históricamente reportadas

- **Sprint 1:** se reportó previamente como "19/19 = 100%" de su propio conteo interno de 19 requerimientos
  (`CIERRE_SPRINT1_44H.md`), aunque ese mismo documento deja un checkpoint de confirmación de Luis sin marcar. La
  conciliación de esta sesión da **98.2%** (43.2h de 44h) — una diferencia pequeña (1.8%) explicada por la clase
  33 nunca seleccionada.
- **Sprint 2:** no se encontró en la documentación revisada una cifra de horas "reportada como completada"
  específica para comparar. La propia auditoría de cierre declara textualmente que **"Sprint 2 no está
  completo"** — no hay una cifra optimista previa que corregir a la baja aquí.
- **Sprint 3:** no existe una cifra previa de horas "completadas" reportada formalmente para comparar. El estado
  técnico de hoy (Lightning Page resuelta funcionalmente, jerarquía desplegada técnicamente) es un avance real
  frente al corte del 10 de agosto, pero sigue sin traducirse en horas por las mismas razones de la sección 7.

---

## 10. Dependencias actuales — separadas por responsable

**DIEGO:**
- Únicamente el nombre final del perfil de Ventas Nuevas y la asignación concreta App/Record Type/Perfil de
  `Opportunity_Record_Page_VN`, en la medida en que el renombre de perfiles en curso todavía la afecte. La decisión
  funcional de reutilizar esta página ya está resuelta (7.A) y ya no es una pregunta abierta para Diego.

**NEGOCIO:**
- Responsables reales (Director/Gerente/Jefe de Sucursal) para Omoda/Jaecoo, para reemplazar el Admin temporal.
- Regla oficial de Pricebook por defecto (PEKING Local vs. PEKING Dólares).
- Asignación funcional de los 54 elementos UI restantes (Taller, otros segmentos, plantillas de correo/presupuesto).
- Centro de costo y aprobador oficiales para el ciclo real de aprobación.
- Bodegas oficiales de PEKING y convención de clave externa para Softland.
- Contenido real de los 6 catálogos Softland.
- Definición funcional y aprobador de los 2 Approval Processes de garantía.
- Definición funcional del soporte de PEKING en los 7 `BatchGet*Softland` (relacionado con las bodegas/catálogos
  oficiales de Softland, mismo bloque de decisión de negocio).
- Confirmación de la clase 33 (Sprint 1) y de los ítems 2/3 (picklists, Record Types en Order/Case).

**SALESFORCE / TÉCNICA TEMPORAL (no atribuible a Diego ni a negocio):**
- Propagación del caché de schema de los 6 campos nuevos de `Sucursal__c` — bloquea únicamente la población de
  datos y la validación en vivo de la jerarquía Omoda/Jaecoo (7.B/7.C). El código ya está desplegado y no requiere
  ningún cambio adicional.

**EQUIPO DESARROLLO (técnico, solo lo que queda después de liberar el schema o recibir las definiciones
anteriores):**
- Poblar el Admin temporal y correr la validación en vivo de la jerarquía Omoda/Jaecoo, en cuanto se libere el
  bloqueo de schema (7.C) — un solo paso, ya preparado, sin riesgo.
- Los 12 Flows "MODIFICAR" de Sprint 2 son desarrollo real pendiente, sujeto a la misma verificación de alcance
  autorizado que rige el resto del proyecto antes de tocarlos.

---

## 11. Evidencia utilizada

Documental (Sprint 1/2/3, ya citada en el cuerpo de este documento con archivo y línea/sección). Evidencia visual
externa disponible (no versionada en Git):
1. `Evidencia Sprint 3 - Opportunity Omoda - Venta Nueva PEKING.mp4`
2. `Evidencia Sprint 3 - Opportunity Jaecoo - Venta Nueva PEKING.mp4`
3. `Evidencia Sprint 3 - Opportunity BMW - Comparacion Venta Nueva.mp4`
4. `Evidencia Sprint 3 - Presupuesto Omoda - Agregar Extras.mp4`

Estos 4 videos respaldan el estado ya documentado de los 10 elementos UI "sin cambio" y del ajuste de
`Flag_Vehiculo_Nuevo_FM__c` — **no se usaron para recalcular ninguna hora**, solo como respaldo de estado. Los
videos reflejan el estado de la jerarquía **antes** de la implementación técnica del 2026-08-11 (Director/Gerente/
Jefe vacíos para Omoda/Jaecoo) — siguen siendo evidencia históricamente correcta de ese momento; no hace falta
regrabarlos para este documento, que ya explica el cambio posterior en la sección 7.B.

---

## 12. Notas sobre bloques donde no fue correcto prorratear (categoría C)

Resumen de los 10 ítems en categoría **C (no cuantificable con precisión)**, y por qué — **no son "pendientes
confirmadas"**, son bloques donde la evidencia disponible no permite afirmar con precisión ni que estén completos
ni que falten:

| Ítem | Horas (C) | Motivo exacto |
|---|---:|---|
| 2 (Picklists) | 4.0 | Sin evidencia de ejecución en ninguna fuente revisada |
| 3 (Record Types otros objetos) | 10.0 | Rango "4-6 objetos" sin lista nominal; solo Opportunity/Lead confirmados |
| 6 (LWC/Aura) | 20.0 | Población real (25) no coincide con estimada (~16); sin lista nominal de correspondencia |
| 7 (UI Layouts/FlexiPages/QA) | 5.0 | Población real (78) casi 3× la estimada (~25); sin lista nominal |
| 8 (List Views) | 8.0 | Sin evidencia de trabajo en ninguna fuente revisada |
| 9 (VR/AP) | 10.0 | Población real de AP (12) no coincide con estimada (~6); VR sí tiene evidencia completa cualitativa |
| 11 (Custom Metadata/Softland) | 8.0 | El bloque nunca se estimó por conteo de componentes, no hay base numérica |
| 12 (Global Value Sets) | 1.0 | Sin evidencia de ejecución en ninguna fuente revisada |
| 13 (Pricebooks — dato) | 10.0 | Creación de los 2 Pricebook2 confirmada; población masiva de PricebookEntry sin evidencia — no se puede separar sin inventar proporción |
| 14 (Pruebas E2E) | 10.0 | Sin evidencia de ejecución end-to-end real en ninguna fuente revisada |
| **Total C** | **86.0** | Verificado: suma exacta con script (sección 1) |

**Inconsistencia matemática detectada y no resuelta por aproximación:** el rango declarado "144-150h" del
documento original no concilia con la suma exacta verificada (150h) — ver sección 3. Se reporta como
`INCONSISTENCIA_REQUIERE_REVISION`, sin inventar una explicación.
