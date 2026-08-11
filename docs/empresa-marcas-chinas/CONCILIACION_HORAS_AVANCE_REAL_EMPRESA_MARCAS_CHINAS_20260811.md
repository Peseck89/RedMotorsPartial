# Conciliación de horas y avance real — Empresa / Marcas Chinas (PEKING)

**Fecha:** 11 de agosto de 2026
**Alcance:** todo el proyecto Empresa / Marcas Chinas (Sprint 1, 2 y 3), no solo Sprint 3.
**No es el entregable Word final.** No se modificó Salesforce, no se hizo deploy, no se crearon ni borraron datos,
no se repitió ninguna auditoría técnica ya cerrada — este documento solo reconcilia horas y estado real contra
documentación ya existente.

---

## 1. Resumen ejecutivo

De las **150 horas** documentadas en la tabla de horas del alcance actualizado (el documento declara un rango
"144-150h"; ver sección 3 sobre por qué existe ese rango y por qué no se puede resolver con precisión), el avance
equivalente real conciliado es de **51.2 horas completadas** y **98.8 horas pendientes**, verificado
matemáticamente (51.2 + 98.8 = 150.0).

De esas 150h, solo **64h están en bloques donde el prorrateo por componente es matemáticamente defendible sin
inventar** (Objeto configurable, Apex, Flows) — ahí el avance real es **80.0%** (51.2h de 64h). Las **86h
restantes** (57.3% del total) están en bloques donde la estimación original no tiene una base de prorrateo
precisa y verificable (poblaciones distintas a lo estimado, sin lista nominal, o sin evidencia de trabajo
documentado) — se marcan `HORAS_NO_PRORRATEABLES_CON_PRECISION` o `PENDIENTE_DE_VERIFICACION` y se describen
cualitativamente, sin forzar una cifra.

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

Un bloque se considera **prorrateable con precisión** solo si se cumplen las tres condiciones:
1. La estimación original define una cantidad numérica de componentes ("~N").
2. Existe una fuente actual que clasifica, por nombre, cada componente en completo/pendiente.
3. La población de la fuente actual coincide (o es razonablemente conciliable) con la población estimada
   originalmente.

Si falta cualquiera de las tres, el bloque se marca `HORAS_NO_PRORRATEABLES_CON_PRECISION` y se describe
cualitativamente en vez de forzar una fracción.

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
inferior). La diferencia (6h) no coincide limpiamente con ningún subconjunto de ítems marcados como inciertos (los
ítems 2+3, marcados "confirmar si se abordó en Sprint 1", suman 14h, no 6h). **Se marca:
`INCONSISTENCIA_REQUIERE_REVISION` — el origen exacto del extremo inferior del rango (144h) no se pudo verificar
con las fuentes disponibles en esta sesión.** Se preserva el rango tal como el documento lo declara, sin fabricar
una explicación.

---

## 4. Sección Sprint 1

**Presupuesto comprometido:** 44h, confirmado en `CIERRE_SPRINT1_44H.md` como exactamente los ítems 1 (14h) + 4
(30h) de la tabla — ningún otro ítem de la tabla original formó parte del compromiso de 44h de Sprint 1.

### Ítem 1 — Objeto configurable para manejo de marcas (14h)

- **Qué se entregó:** objeto `Empresa__c`, clases `EmpresaContext`, `EmpresaResolver`,
  `EmpresaConfigurationException`, `EmpresaResolverTest` — desplegados y funcionando.
- **Qué sigue vigente:** el objeto y el resolver se usan activamente en todo el trabajo de Sprint 2 y 3 (por
  ejemplo, `Empresa_Operadora__c` en Opportunity, `Pricebook2.Empresa__c`).
- **Qué quedó pendiente:** nada específico de este ítem — el soporte funcional de PEKING dentro de Softland es un
  ítem aparte (ítem 11, Sprint 3), no de este bloque.
- **Clasificación: `TERMINADO_REAL`.**
- **Horas:** 14h completadas / 0h pendientes.

### Ítem 4 — Apex, ~33 clases + 3 triggers (30h)

- **Qué se entregó:** 32 de 33 clases confirmadas (Git = Partial, categoría A) + 3 de 3 triggers confirmados.
  Ejecución de pruebas real: Test Run `707AK00000HB6UY`, **33/33 tests aprobados** (100% pass rate). Los 7
  `BatchGet*Softland` (parte de las 8 clases de Pricebook/Softland mencionadas en el propio ítem) fueron
  reconciliados a categoría A con cobertura al 100%.
- **Qué sigue vigente:** la reconciliación Git-Partial y la cobertura de pruebas.
- **Qué quedó pendiente:** la **clase 33 nunca fue seleccionada ni confirmada** — el borrador de cierre
  (`CIERRE_TECNICO_SPRINT1_33_CLASES_3_TRIGGERS_DRAFT.md`) se autodeclara explícitamente "BORRADOR. No constituye
  cierre formal." Además, 7 componentes del plan original de 44h (`QuoteSoftlandPedidoService`,
  `servicioReservas`, `OpportunityServiceInvoker`, `Registrar_Anticipo_Controller`, y 3 más) nunca se tocaron —
  documentado como reemplazados, con autorización de Luis, por trabajo de "igual o mayor valor" de otros bloques
  (no se penaliza este bloque por eso, según la regla de "no penalizar por trabajo adicional fuera del alcance").
  El soporte funcional de PEKING en los 7 `BatchGet*Softland` (6 de 7 con `RMBAVARIAN` fijo en el código) sigue
  **pendiente de definición de Diego** — pero esto es alcance del ítem 11 (Sprint 3), no de este ítem 4.
- **Clasificación: `PARCIAL`.**
- **Cálculo:** 33 clases + 3 triggers = 36 unidades. Confirmadas: 32 + 3 = 35. Pendiente: 1 (clase 33).
  `30h × 35/36 = 29.2h completadas`; `30h × 1/36 = 0.8h pendientes`. Verificado: 29.2 + 0.8 = 30.0 ✓.
- **Nota de cierre administrativo:** el propio `CIERRE_SPRINT1_44H.md` deja un checkbox sin marcar: *"Checkpoint
  con Luis: confirmar que acepta el cierre..."* — el cierre formal de Sprint 1 sigue pendiente de esa confirmación
  explícita, independientemente del avance técnico real calculado arriba.

### Ítems 2 y 3 — Picklists (4h) y Record Types en otros objetos (10h) — sin Sprint asignado, estado incierto

Estos dos ítems **no formaron parte de las 44h comprometidas de Sprint 1** según `CIERRE_SPRINT1_44H.md` (que solo
suma ítems 1+4=44h), a pesar de que la tabla original trae la nota manual *"confirmar si se abordó en sprint 1 ya
que pareció algo de eso"* para ambos. No se encontró en la documentación revisada una confirmación explícita de si
se ejecutaron o no.

- **Ítem 3 (Record Types):** hay evidencia directa y confirmada de que los Record Types Omoda y Jaecoo **sí
  existen y funcionan** en Opportunity y Lead (usados extensivamente durante todo Sprint 3 — Ids
  `012AK0000002McMYAU`/`012AK0000002McLYAU` en Opportunity, `012AK0000002NGgYAM`/`012AK0000002NGfYAM` en Lead). No
  hay evidencia revisada en esta sesión sobre si los Record Types también se replicaron en Order/Case (el propio
  ítem dice "4-6 en otros objetos", un rango, no una lista nominal).
- **Ítem 2 (Picklists):** no se encontró evidencia, en ningún documento revisado, de que los 13 campos/typos se
  hayan corregido específicamente.
- **Clasificación: `PENDIENTE_DE_VERIFICACION`** para ambos — no se asume completado por falta de evidencia (regla
  explícita: no asumir 100% por haberse reportado), pero tampoco se afirma que no se hizo. Se tratan de forma
  conservadora como pendientes para el total, dejando constancia de que Record Types (Opportunity/Lead) sí tiene
  evidencia parcial fuerte a favor.
- **Horas:** 0h completadas confirmadas / 14h (4h+10h) pendientes o sin verificar.

**Total Sprint 1 (ítems 1+4, los únicos con presupuesto comprometido):**

| Estimadas | Completadas | Pendientes | Avance % |
|---:|---:|---:|---:|
| 44h | 43.2h | 0.8h | **98.2%** |

Verificado: 43.2 + 0.8 = 44.0 ✓

---

## 5. Sección Sprint 2

**Presupuesto original:** ítem 5 (Flows, 20h) + ítem 6 (LWC/Aura, 20h) = 40h.

### Ítem 5 — Flows (20h, ~20 flows estimados)

**Fuente de estado actual:** `AUDITORIA_CIERRE_SPRINT2.md` / `MATRIZ_CIERRE_SPRINT2.csv` (2026-08-04) — la
auditoría de cierre más reciente, que reemplaza inventarios y planes anteriores. Población auditada: **exactamente
20 Flows**, coincide con la estimación original ("~20") — este bloque **sí es prorrateable con precisión**.

Clasificación real, por nombre, de los 20:

| Clasificación | Cantidad |
|---|---:|
| SIN CAMBIO TÉCNICO (no requiere desarrollo adicional) | 6 |
| NO APLICA (fuera de alcance PEKING, confirmado) | 2 |
| MODIFICAR (desarrollo pendiente) | 12 |
| BLOQUEADO | 0 |
| **Total** | **20** |

**Importante — no copiar el ejemplo ilustrativo del pedido ("15 completos, 5 pendientes"):** ese número era
hipotético. La matriz real confirma **8 de 20 sin trabajo pendiente** (6 sin cambio técnico + 2 no aplica) y **12
de 20 con desarrollo todavía pendiente** (modificar). Es un resultado distinto al ejemplo, y es el que se usa.

**Cálculo:** `20h × 8/20 = 8.0h completadas`; `20h × 12/20 = 12.0h pendientes`. Verificado: 8.0 + 12.0 = 20.0 ✓.

**Nota sobre "sin cambio técnico":** la propia auditoría aclara (`RESUMEN_EJECUTIVO_AUDITORIA_SPRINT2.md`): *"'Sin
cambio técnico' no significa validado funcionalmente ni cerrado."* Se cuenta aquí como horas de **desarrollo**
completadas (no se necesita programar nada más), no como QA funcional cerrado — esa distinción se mantiene
también en la clasificación de Sprint 3.

**Clasificación: `PARCIAL`, prorrateable con precisión.**

### Ítem 6 — LWC/Aura (20h, ~16 componentes estimados)

**Población auditada real: 25 bundles** (20 LWC + 5 Aura) — no 16. Esto es una diferencia de población del 56%
frente a la estimación original, y **no existe en ninguna fuente revisada una lista nominal de cuáles 16 de esos
25 corresponden al alcance original estimado** — la propia `REGLAS_ALCANCE_AUTORIZADO.md` documenta que Luis
autorizó la categoría ("~16 LWC/Aura"), no los 16 nombres individuales, y que solo `rm_vu_inventario` tiene
autorización y confirmación explícita por nombre.

Clasificación real de los 25 auditados (`AUDITORIA_CIERRE_SPRINT2.md`):

| Clasificación | Cantidad |
|---|---:|
| SIN CAMBIO TÉCNICO | 4 |
| NO APLICA | 2 |
| MODIFICAR | 3 |
| BLOQUEADO | 16 |
| **Total** | **25** |

**Clasificación: `HORAS_NO_PRORRATEABLES_CON_PRECISION`.**

**Por qué:** no se cumple la condición 3 de la regla de prorrateo (la población de 25 no coincide con la
estimación de ~16, y no hay lista nominal documentada que reconcilie cuáles de los 25 son parte del compromiso
original). Forzar una fracción sobre 16 usando datos de una población de 25 inventaría una correspondencia que no
existe en ninguna fuente.

**Qué sí puede cuantificarse sin inventar:** `rm_vu_inventario` es el único componente con autorización y
confirmación explícita por nombre (`REGLAS_ALCANCE_AUTORIZADO.md`, actualización 2026-07-30: "AUTORIZADO Y
CONFIRMADO e implementado"). Es 1 de 25 (o, si se usa el denominador original, 1 de ~16). El resto de la
implementación de este bloque (19.375h a 20h, según qué denominador se use) **no tiene evidencia de cierre
verificable sin inventar la correspondencia** — se deja como pendiente/sin verificar en su totalidad, salvo ese
único componente.

**Horas:** 0h completadas de forma prorrateable (se documenta cualitativamente que 1 componente nominal está
confirmado, sin forzar una fracción de hora) / 20h pendientes o sin verificar con precisión.

**Total Sprint 2 (ítems 5+6):**

| Estimadas | Completadas (prorrateables) | Pendientes/sin verificar | Avance % |
|---:|---:|---:|---:|
| 40h | 8.0h | 32.0h | Solo calculable sobre el ítem 5 (prorrateable): **40.0%** de esas 20h. El total de 40h no tiene un % único defendible porque el ítem 6 no es prorrateable con precisión. |

---

## 6. Sección Sprint 3

**Alcance original de Sprint 3, según la tabla del documento de 2026-08-05:** únicamente los ítems 7 (Layouts/
FlexiPages/Quick Actions, 5h), 9 (Validation Rules/Approval Processes + roles, 10h) y 11 (Custom Metadata/
Integración Softland, 8h) — **total 23h**. No se incorporan automáticamente elementos de RQ308 ni versiones
posteriores del alcance que no estén en esta tabla original.

### Ítem 7 — Layouts/FlexiPages/Quick Actions (5h, ~25 componentes estimados: 10+10+5)

**Población real auditada (B7-0, 2026-08-06, y B7-1, 2026-08-10): 78 componentes** (46 Layouts + 27 FlexiPages + 5
Quick Actions) — casi el triple de la estimación original (~25). Estado más actual, tras la reconciliación con el
criterio de Ventas Nuevas (`RESULTADO_B7_1_RECONCILIACION_VENTAS_NUEVAS_20260810.md`):

| Estado | Cantidad |
|---|---:|
| `SIN_CAMBIO_REQUIERE_REGRESION` (ya funcionan, evidencia visual ya grabada) | 10 |
| `RESUELTO_POR_EQUIVALENCIA_VENTAS_NUEVAS` | 8 |
| `RESUELTO_AJUSTE_VEHICULO_NUEVO_OMODA_JAECOO` (Quote_Record_Page_VN) | 1 |
| `BLOQUEADO_ASIGNACION_FUNCIONAL` (pendiente de negocio) | 54 |
| `DRIFT_REQUIERE_CONCILIACION` (`Opportunity_Record_Page_VN`, pendiente de Diego) | 1 |
| `NO_APLICA` | 4 |
| **Total** | **78** |

**Clasificación: `HORAS_NO_PRORRATEABLES_CON_PRECISION`.** La población real (78) no coincide con la estimación
original (~25) y no existe una lista nominal documentada que indique cuáles 25 del universo actual corresponden al
compromiso original de 5h. Forzar 5h/78 inventaría una correspondencia inexistente.

**Qué sí puede decirse sin inventar:** 19 de los 78 (10 sin cambio + 8 equivalencia Ventas Nuevas + 1 Quote ajuste)
ya no requieren desarrollo adicional, y los 10 principales ya tienen evidencia visual grabada y aprobada
(`EVIDENCIAS_NEGOCIO_SPRINT3_20260810.md` sección 6). 54 siguen genuinamente bloqueados por decisión de negocio, 1
depende de Diego. Esto es progreso real y verificable, solo que no se traduce en una fracción de las 5h originales
sin inventar la correspondencia de población.

### Ítem 9 — Validation Rules / Approval Processes + roles (10h, ~7 VR + ~6 AP = 13 estimados)

**Población real:** 4 Validation Rules modificadas (no ~7 — no se encontró documentación de otras 3 VR en alcance
PEKING), y **12 Approval Processes reales identificados** en el trabajo de Sprint 3 (8 de descuento + 2 de centro
de costo + 2 de garantía) — no ~6. Otra vez, población distinta a la estimación.

Estado real, por sub-bloque:

- **Validation Rules (4 de 4):** `QA_FUNCIONAL_COMPLETADO` — 15/15 escenarios aprobados por regla, confirmado en
  `RESULTADO_QA_FUNCIONAL_B9_1_20260807.md` y `RESULTADO_CORRECCION_CAMPO_GUSTOS_B9_1_20260807.md`.
- **Approval Processes de descuento (8):** lógica funcional `RESUELTA` — no requieren desarrollo específico de
  PEKING (son neutrales a marca); el envío real de aprobación depende de que Diego termine la jerarquía de
  aprobadores (`PENDIENTE_IMPLEMENTACION_JERARQUIA_DIEGO`) — dependencia externa, no trabajo técnico pendiente.
- **Approval Process de centro de costo (2, Quote y Work Order):** entrada a "Pendiente de aprobación" ya
  confirmada dos veces con placeholders (`CIERRE_TRABAJO_INTERNO_SPRINT3_20260807.md`,
  `RESULTADO_QA_PLACEHOLDERS_SPRINT3_20260810.md`). Aprobación real pendiente de centro de costo/aprobador
  oficiales (negocio).
- **Approval Processes de garantía (2):** bloqueados por falta de definición funcional de negocio — no se tocó,
  fuera de alcance a propósito.

**Clasificación: `HORAS_NO_PRORRATEABLES_CON_PRECISION`** para la fracción exacta de las 10h originales (la
población de AP reales, 12, no coincide con la estimación ~6, y mezclar VR+AP en una sola fracción sin una base
nominal clara inventaría precisión que no existe). **Lo que sí es un hecho verificado sin ambigüedad:** las 4
Validation Rules están 100% completas y QA-cerradas; los 8 AP de descuento tienen su lógica resuelta y solo
dependen de un tercero (Diego); los 2 AP de garantía están genuinamente bloqueados por negocio.

### Ítem 11 — Custom Metadata / Integración Softland (8h, sin conteo numérico de componentes en el original)

Este ítem no tiene una cantidad de componentes ("~N") en la tabla original — se describe narrativamente
("RM_Config, mapeos, credenciales"), por lo que no existe una base numérica de la cual partir para prorratear por
componente sin inventar una subdivisión que el documento original no define.

**Clasificación: `HORAS_NO_PRORRATEABLES_CON_PRECISION`** (no por población distinta, sino porque el bloque nunca
fue estimado por conteo de componentes).

**Estado real, cualitativo:** 13 clases Apex reconocen el código `RMPEKING` (`RESULTADO_B11_1_CATALOGOS_SOFTLAND_20260806.md`),
36/36 pruebas automatizadas con mocks aprobadas para los 6 catálogos (sin conexión real a Softland). Pendiente de
negocio: contenido real de catálogo, bodegas oficiales de PEKING y convención de clave externa (la colisión de
clave con Bavarian ya fue demostrada técnicamente), y regla de Pricebook por defecto.

### Total Sprint 3 (ítems 7+9+11 = 23h originales)

**Ninguno de los 3 ítems de Sprint 3 es prorrateable con precisión** contra su estimación original de horas,
porque los tres tienen poblaciones reales distintas a lo estimado o carecen de base numérica. Se reporta el
avance cualitativo verificado (arriba), no una cifra de horas para Sprint 3.

**Adicional — no cuenta en el total de horas de Sprint 3 porque no está en la tabla original de 2026-08-05:** el
ajuste técnico de `Flag_Vehiculo_Nuevo_FM__c` (agregar Omoda/Jaecoo como vehículo nuevo) fue un hallazgo y
corrección de esta ronda, no un ítem con horas propias en el documento de alcance original — se documenta como
trabajo adicional real, sin inventarle una cifra de horas que el alcance original nunca le asignó.

---

## 7-9. Totales (verificados con script, ver sección 1 para el resumen)

| Grupo | Horas estimadas | Horas completadas (equivalente) | Horas pendientes (equivalente) |
|---|---:|---:|---:|
| Total original (excluye ítem 10, NA) | 150h | — | — |
| Bloques prorrateables con precisión (ítems 1, 4, 5) | 64h | 51.2h | 12.8h |
| Bloques `HORAS_NO_PRORRATEABLES_CON_PRECISION` o `PENDIENTE_DE_VERIFICACION` (ítems 2,3,6,7,8,9,11,12,13,14) | 86h | 0h (no forzado; ver detalle cualitativo por ítem en secciones 4-6) | 86h (tratado conservador) |
| **Total consolidado** | **150h** | **51.2h** | **98.8h** |

Verificación: 51.2 + 98.8 = 150.0 ✓ (calculado con script, no mentalmente — ver sección 14 del pedido original).

**Importante sobre la fila "no prorrateables":** las 86h no se declaran "0% de avance real" — significan que **no
existe una base documentada para traducir el avance real (que en varios de estos ítems es sustancial, ej. las 4 VR
100% completas, o los 19 elementos UI ya resueltos) en una fracción precisa de las horas originalmente estimadas**,
porque las poblaciones reales no coinciden con las estimadas. El avance cualitativo de cada uno está documentado
en las secciones 4-6.

---

## 10. Comparación contra horas históricamente reportadas

- **Sprint 1:** se reportó previamente como "19/19 = 100%" de su propio conteo interno de 19 requerimientos
  (`CIERRE_SPRINT1_44H.md`), aunque ese mismo documento deja un checkpoint de confirmación de Luis sin marcar. La
  conciliación de esta sesión da **98.2%** (43.2h de 44h) — una diferencia pequeña (1.8%) explicada por la clase
  33 nunca seleccionada. No es una contradicción grave, pero sí una corrección real: no se puede decir 100% sin
  la clase 33 resuelta.
- **Sprint 2:** no se encontró en la documentación revisada una cifra de horas "reportada como completada"
  específica para comparar. Lo más cercano es la declaración del 2026-07-30 de que 6 componentes (5 Flows +
  `rm_vu_inventario`) quedaban "AUTORIZADO Y CONFIRMADO e implementados" — la auditoría posterior (2026-08-04) los
  reclasifica como "SIN CAMBIO TÉCNICO", que es consistente (no contradictorio), pero aclara expresamente que
  "sin cambio técnico" no equivale a "cerrado funcionalmente". La propia auditoría de cierre declara textualmente
  que **"Sprint 2 no está completo"** — no hay una cifra optimista previa que corregir a la baja aquí; la fuente
  más reciente ya es la más conservadora.
- **Sprint 3:** no existe una cifra previa de horas "completadas" reportada formalmente para comparar — el trabajo
  de Sprint 3 se ha documentado por estado de componente (resuelto/bloqueado/pendiente), no por horas, hasta este
  documento.

---

## 11. Dependencias actuales

**DIEGO:**
- Nombre final del perfil de Ventas Nuevas para `Opportunity_Record_Page_VN` (drift de perfiles renombrados).
- Confirmación de si el renombre de perfiles ya visto es su trabajo en curso.
- Jerarquía de aprobadores (Director/Gerente/Jefe de Sucursal) para Omoda/Jaecoo — bloquea el QA final de los 8
  Approval Processes de descuento.
- Definición del soporte funcional de PEKING en los 7 `BatchGet*Softland` (Sprint 1, ítem 4/11).

**NEGOCIO:**
- Regla oficial de Pricebook por defecto (PEKING Local vs. PEKING Dólares).
- Asignación funcional de los 54 elementos UI restantes (Taller, otros segmentos, plantillas de correo/presupuesto).
- Centro de costo y aprobador oficiales para el ciclo real de aprobación.
- Bodegas oficiales de PEKING y convención de clave externa para Softland.
- Contenido real de los 6 catálogos Softland.
- Definición funcional y aprobador de los 2 Approval Processes de garantía.
- Confirmación de la clase 33 (Sprint 1) y de los ítems 2/3 (picklists, Record Types en Order/Case).

**EQUIPO DESARROLLO (técnico, no bloqueado por terceros):**
- Ninguno identificado en esta conciliación — todo el trabajo técnico automatizable, dentro del alcance
  autorizado, ya se ejecutó. Los 12 Flows "MODIFICAR" de Sprint 2 son desarrollo real pendiente, pero antes de
  tocarlos requieren la misma verificación de alcance autorizado que ya rige el resto del proyecto (no se incluyen
  aquí como "trabajo seguro" sin esa confirmación).

---

## 12. Evidencia utilizada

Documental (Sprint 1/2/3, ya citada en el cuerpo de este documento con archivo y línea/sección). Evidencia visual
externa disponible (no versionada en Git):
1. `Evidencia Sprint 3 - Opportunity Omoda - Venta Nueva PEKING.mp4`
2. `Evidencia Sprint 3 - Opportunity Jaecoo - Venta Nueva PEKING.mp4`
3. `Evidencia Sprint 3 - Opportunity BMW - Comparacion Venta Nueva.mp4`
4. `Evidencia Sprint 3 - Presupuesto Omoda - Agregar Extras.mp4`

Estos 4 videos respaldan el estado ya documentado de los 10 elementos UI "sin cambio" y del ajuste de
`Flag_Vehiculo_Nuevo_FM__c` — **no se usaron para recalcular ninguna hora**, solo como respaldo de estado.

---

## 13. Notas sobre bloques donde no fue correcto prorratear

Resumen de los 10 ítems marcados `HORAS_NO_PRORRATEABLES_CON_PRECISION` o `PENDIENTE_DE_VERIFICACION`, y por qué:

| Ítem | Motivo exacto |
|---|---|
| 2 (Picklists, 4h) | Sin evidencia de ejecución en ninguna fuente revisada |
| 3 (Record Types otros objetos, 10h) | Rango "4-6 objetos" sin lista nominal; solo Opportunity/Lead confirmados |
| 6 (LWC/Aura, 20h) | Población real (25) no coincide con estimada (~16); sin lista nominal de correspondencia |
| 7 (UI Layouts/FlexiPages/QA, 5h) | Población real (78) casi 3× la estimada (~25); sin lista nominal |
| 8 (List Views, 8h) | Sin evidencia de trabajo en ninguna fuente revisada |
| 9 (VR/AP, 10h) | Población real de AP (12) no coincide con estimada (~6); VR sí tiene evidencia completa cualitativa |
| 11 (Custom Metadata/Softland, 8h) | El bloque nunca se estimó por conteo de componentes, no hay base numérica |
| 12 (Global Value Sets, 1h) | Sin evidencia de ejecución en ninguna fuente revisada |
| 13 (Pricebooks — dato, 10h) | Creación de los 2 Pricebook2 confirmada; población masiva de PricebookEntry sin evidencia — no se puede separar sin inventar qué fracción de las 10h corresponde a cada sub-tarea |
| 14 (Pruebas E2E, 10h) | Sin evidencia de ejecución end-to-end real en ninguna fuente revisada |

**Inconsistencia matemática detectada y no resuelta por aproximación:** el rango declarado "144-150h" del
documento original no concilia con la suma exacta verificada (150h) — ver sección 3. Se reporta como
`INCONSISTENCIA_REQUIERE_REVISION`, sin inventar una explicación.
