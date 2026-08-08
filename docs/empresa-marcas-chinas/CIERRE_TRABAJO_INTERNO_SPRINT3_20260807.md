# Cierre de trabajo interno autorizado — Sprint 3 (B7, B9, B11)

**Fecha:** 7 de agosto de 2026
**Org:** Partial (`RedMotorsSandbox`) exclusivamente. Producción no fue consultada.
**Rama:** `feature/pc/redmotors-empresa-marcas-chinas-sprint2-flows-components-20260728`
**HEAD de partida:** `5c43085` (verificado en el PRECHECK; branch sincronizada 0/0 con origin)

**Actualización (2026-08-07, tarde) — `RECORD_TYPES_OMODA_JAECOO_NO_HABILITADOS_PARA_USUARIOS_ACTIVOS`:** al preparar los datos QA persistentes para el Video 1 de evidencias UI (ver `PLAN_EVIDENCIAS_FINALES_SPRINT3_20260807.md`), se descubrió que **ningún usuario activo en Partial, incluido `System Administrator`, puede crear una Opportunity con Record Type Omoda o Jaecoo**. Confirmado dos veces por vías independientes: `sf data create record` y Apex anónimo en contexto de sistema, ambos con el mismo error `INVALID_CROSS_REFERENCE_KEY: Record Type ID: this ID value isn't valid for the user`. Esto es una restricción de **visibilidad de Record Type a nivel de Profile/Permission Set**, distinta y más profunda que la asignación de Layout ya documentada en la sección B7 de abajo. No es falta de datos QA, no es defecto de Layout, no es efecto secundario de automatización (el preflight de triggers/Flows de insert se completó y fue seguro; el bloqueo ocurre antes de que cualquier automatización se ejecute). Detalle completo en la sección "Hallazgo: visibilidad de Record Types Omoda/Jaecoo" más abajo. Responsable: Diego (Profiles/Permission Sets). No se modificó ningún Profile, Permission Set, Role, Layout assignment ni activación de FlexiPage.

**Este documento NO declara Sprint 3 terminado.** Agota el trabajo técnico interno autorizado y ejecutable con la información disponible hoy sobre B7, B9 y B11, usando exclusivamente los análisis y matrices ya existentes (`RESULTADO_B7_0_UI_20260806.md`, `MATRIZ_UI_B7_0_20260806.csv`, `RESULTADO_B9_0_VALIDATION_RULES_20260806.md`, `MATRIZ_VALIDATION_RULES_B9_0_V2_20260806.csv`, `RESULTADO_B9_AP0_APPROVAL_PROCESSES_20260806.md`, `RESULTADO_B11_0_1_CATALOGOS_SOFTLAND_20260806.md`, `RESULTADO_B11_1_CATALOGOS_SOFTLAND_20260806.md`, `RESULTADO_QA_FUNCIONAL_B9_1_20260807.md`). No se volvió a auditar el universo completo (563 componentes, 94 Validation Rules, 78 elementos UI).

Toda ejecución de este lote se hizo mediante `@IsTest` con `--dry-run`/check-only. **Cero deploys persistidos, cero datos reales, cero jobs programados, cero correos reales, cero aprobaciones persistentes.** Las clases Apex usadas para generar esta evidencia fueron temporales: se compilaron y ejecutaron en modo check-only y no quedaron desplegadas ni versionadas, siguiendo el mismo patrón ya usado en B9-1 y B11-1.

---

## Precheck

- Branch correcta confirmada.
- HEAD inicial `5c43085`, 0/0 respecto a `origin`.
- Se encontró un cambio inesperado no funcional (`force-app/main/default/lwc/jsconfig.json`, pérdida de salto de línea final) — descartado con `git checkout --` tras confirmación del usuario, antes de iniciar cualquier trabajo.

---

## Matriz autoritativa

| Requerimiento Sprint 3 | Componente/grupo | Estado actual | Cambio requerido | QA técnico | Evidencia | Pendiente | Tipo de pendiente | Responsable |
|---|---|---|---|---|---|---|---|---|
| B7 — Layouts Opportunity (6) | `Opportunity-Autos V1.3`, `Opportunity-Autos V1.3 - Inventario`, `Opportunity-Autos V1.4`, `Opportunity-Autos V1.4 Sin Botones`, `Opportunity-Opportunity Layout`, `Opportunity-Vehiculos Nuevos V1.1` | `SIN_CAMBIO_REQUIERE_REGRESION` (B7-0) | Ninguno — ya asignados a Omoda/Jaecoo | Metadata (asignaciones ProfileLayout) reconfirmada sin drift respecto a B7-0. Render/campos/acciones requiere navegador — no disponible en este entorno | `PLAN_REGRESION_UI_B7_20260806.md` (checklist preparado) | Evidencia visual Omoda/Jaecoo + comparación legacy con perfil QA autorizado por Diego | QA_MANUAL_VIDEO | QA / responsables UI (video), Diego (disponibilidad de perfiles) |
| B7 — FlexiPages APP_DEFAULT (3) | `Opportunity_Record_Page1`, `Quote_Record_Page`, `Quote_Record_Page2` | `SIN_CAMBIO_REQUIERE_REGRESION` (B7-0) | Ninguno — activación genérica sin condición de Empresa/Marca | Activación APP_DEFAULT reconfirmada sin drift. Carga/consola/errores requiere navegador | `PLAN_REGRESION_UI_B7_20260806.md` | Evidencia visual de carga Omoda/Jaecoo y regresión legacy | QA_MANUAL_VIDEO | QA / responsables UI |
| B7 — Quick Action genérica (1) | `Quote.BMW_Duplicar_Partidas_de_Presupuesto` | `SIN_CAMBIO_REQUIERE_REGRESION` (B7-0) | Ninguno — exposición genérica demostrada | No se identificó una vía Apex/Flow aislable sin UI para ejercer la duplicación | `PLAN_REGRESION_UI_B7_20260806.md` | Evidencia visual de exposición y ejecución en Quote PEKING | QA_MANUAL_VIDEO | QA / responsables UI |
| B7 — Drift `Opportunity_Record_Page_VN` | FlexiPage | `DRIFT_REQUIERE_CONCILIACION` (B7-0) → **`DRIFT_CONCILIADO_DOCUMENTALMENTE_PENDIENTE_ASIGNACION_FUNCIONAL`** | Ninguno ejecutado — solo documentación del drift | Comparación Git vs Partial repetida con API v61 (el intento inicial con v51 arrojó un falso drift masivo por diferencia de versión de metadata, descartado). Drift real confirmado: **ya no es únicamente** `Opportunity.Plan_del_cliente_save_PDF`. Hay además: (a) nombres de Profile en `visibilityRule` cambiados en Partial — "Asesor de Ventas MINI y Nuevos V2"/"Asesor de Ventas BMW y Nuevos V2" → "New Asesor Ventas", "Asesor de Taller V2" → "New Asesor Postventa"; (b) un `componentInstanceProperty` de label "Tabs" removido en un `flexipage:tabset`. No se sobrescribió Partial, no se retiró la Quick Action, no se activó Omoda/Jaecoo | Diff local descartado tras la comparación (`git checkout --`), nunca commiteado | (a) Confirmar con Diego si el renombramiento de perfiles ("New Asesor Ventas"/"New Asesor Postventa") es intencional y forma parte de su trabajo de jerarquía/perfiles; (b) decidir si el drift se concilia hacia Git o se documenta como comportamiento vigente de Partial; (c) asignación funcional de Omoda/Jaecoo a esta página | DIEGO + DECISION_FUNCIONAL | Diego (perfiles), Luis/Diego (asignación funcional) |
| B7 — resto (63 Layouts/FlexiPages/Quick Actions) | Ver `MATRIZ_UI_B7_0_20260806.csv` | `BLOQUEADO_ASIGNACION_FUNCIONAL` (B7-0) | No determinable sin decisión | No aplica — no se reclasificó, no se reabrió el universo de 78 | Sin cambios | Asignación exacta por aplicación/perfil/Record Type | DECISION_FUNCIONAL | Negocio / Ventas / Taller |
| B7 — no aplica (usados) | `Opportunity_Record_Page_VU`, `Quote_Record_Page_VU`, `Estadisticas_Inventario_Usados`, `Ver_Inventario_Vehiculos_Usados` | `NO_APLICA` (B7-0, confirmado por Luis: PEKING no aplica a usados) | Ninguno | Ninguno adicional requerido | B7-0 | Ninguno | NINGUNO | — |
| B9 — VR Centro de Costo (Quote) | `Quote.CentrodeCostoLlenoCuandoCostoFijo` | `BLOQUEADO_DATOS_OPERATIVOS` → **`QA_FUNCIONAL_COMPLETADO`** | Ninguno — fórmula neutral a Empresa/Marca/RecordType, sin cambio | QA aislado con Centro de Costo placeholder (`CentroCosto__c` de prueba, creado y revertido dentro de `@IsTest`), Opportunity/Quote Omoda: positivo (con Centro de Costo) y negativo (sin Centro de Costo, bloquea) | Validation ID `0AfAK0000012DIL0A2` (4/4 pruebas aprobadas) | Ninguno | NINGUNO | — |
| B9 — VR Centro de Costo (WorkOrder) | `WorkOrder.BMW_Centro_de_Costos_Obligatorio` | `BLOQUEADO_DATOS_OPERATIVOS` → **`QA_FUNCIONAL_COMPLETADO`** | Ninguno — fórmula neutral | QA aislado positivo/negativo con el mismo Centro de Costo placeholder | Validation ID `0AfAK0000012DIL0A2` | Ninguno | NINGUNO | — |
| B9 — VR Bodega Uruca | `Opportunity.Bodega_Vehiculos_Nuevos_Uruca` | `BLOQUEADO_DATOS_OPERATIVOS` → **`QA_FUNCIONAL_COMPLETADO`** | Ninguno | Confirmado empíricamente (perfil no administrador, para que la excepción de perfil no enmascare el resultado): la fórmula solo evalúa `RecordType.Name` BMW/MINI; Omoda no queda bloqueada por esta regla con bodega placeholder distinta, porque su RecordType no está en el `OR` de la fórmula | Validation ID `0AfAK0000012DS10AM` | Ninguno — regla confirmada sin impacto en PEKING | NINGUNO | — |
| B9 — VR Oportunidad Cerrada Ganada (legacy) | `Opportunity.BMW_OportunidadCerradaGanada` | `BLOQUEADO_DATOS_OPERATIVOS` → **`NO_APLICA_CONFIRMADO`** | Ninguno | Confirmado por lectura de metadata (sin necesidad de ejecución, regla inactiva no puede dispararse): `Estado_Activo=INACTIVA`; además su `OR(RecordType.Name)` solo incluye BMW/Kawasaki/MINI/Polaris/Motorrad — Omoda/Jaecoo no están en la lista | Fórmula recuperada de Partial el 2026-08-06 (`MATRIZ_VALIDATION_RULES_B9_0_V2_20260806.csv`, fila `S3-0-B9-VR-002`) | Ninguno | NINGUNO | — |
| B9 — VR reglaaprobacioncentroDeCosto (legacy) | `WorkOrder.reglaaprobacioncentroDeCosto` | `BLOQUEADO_DATOS_OPERATIVOS` → **`NO_APLICA_CONFIRMADO`** | Ninguno | Confirmado por lectura de metadata: `Estado_Activo=INACTIVA`, fórmula neutral a Empresa/Marca/RecordType | Misma matriz, fila `S3-0-B9-VR-010` | Ninguno | NINGUNO | — |
| B9 — VR Sucursal Obligatoria | `Opportunity.Campo_Sucursal_Obligatorio` | `BLOQUEADO_DATOS_OPERATIVOS` → **`QA_TECNICO_INTENTADO_SIN_RESULTADO_CONCLUYENTE`** | Ninguno propuesto — no se detectó defecto en la regla en sí | Se intentó QA aislado (perfil no administrador, Sucursal en blanco debía bloquear el cambio de etapa a "Oferta"). El bloqueo esperado **no ocurrió** en el escenario aislado. La fórmula depende de `NOT(ISCHANGED(alertEmail__c))` y `NOT(ISCHANGED(NombreProducto__c))` como excepciones — la hipótesis más probable es interferencia de otra automatización activa sobre `Opportunity` (Flows/triggers) que toca esos campos durante el mismo guardado, hallazgo consistente con el preflight de B9-1 (21 Flows activos con inicio en Opportunity) | Corrida check-only descartada tras el intento; no se dejó una aserción potencialmente engañosa en ningún artefacto | Aislar qué automatización activa cambia `alertEmail__c`/`NombreProducto__c` durante el cambio de etapa, para excluir su interferencia antes de repetir el QA de esta regla | DECISION_FUNCIONAL (requiere análisis técnico adicional fuera de este lote, no es un cambio autorizado ahora) | Desarrollo (análisis dirigido posterior) |
| B9 — VR MusthaveActivity | `Opportunity.MusthaveActivity` | `BLOQUEADO_DATOS_OPERATIVOS` → **`NO_APLICA_CONFIRMADO`** | Ninguno | Confirmado empíricamente (perfil no administrador, Omoda): `Flag_Vehiculo_Nuevo_FM__c` es un campo **fórmula** — `OR(RecordType.Name='BMW','MINI','Motorrad','Polaris','Kawasaki','Indian')` — que **no incluye Omoda ni Jaecoo**. Como ese campo es un término obligatorio del `AND` de la regla, `MusthaveActivity` nunca puede evaluar verdadero para PEKING; no es un bloqueo de datos, es una exclusión estructural igual que VR-002 y VAL-103 | Validation ID `0AfAK0000012DWr0AM` (1/1 prueba aprobada) | Ninguno | NINGUNO | — |
| B9 — Approval Processes de descuento (8) | `Opportunity.Aprobacion_descuento_*` (8 procesos) | `SIN_CAMBIO_REQUIERE_REGRESION` (B9-AP0) | Ninguno — metadata neutral a Empresa/Marca/RecordType, confirmado por lectura completa de los 8 `entryCriteria` | **Hallazgo nuevo:** se intentó envío real (`Approval.process`) en `@IsTest` para Omoda, Jaecoo y BMW con las combinaciones exactas de `Jefe__c/Gerente__c/Director__c` y sus lookups de aprobador (`JefeSucursal__c/GerenteSucursal__c/DirectorVentas__c`) decodificadas de las 8 fórmulas reales. Se descubrió que esos campos **se resetean por automatización activa** ligada a la jerarquía real del Owner, independientemente de lo que se fije manualmente en el insert — reproducido de forma idéntica para Omoda y BMW con 10% y 80% de descuento simulado (mismo resultado en ambas marcas). Esto confirma que **no es un gap específico de PEKING**, sino una dependencia general de jerarquía | Dos corridas diagnósticas check-only (mensajes de aserción con los valores reales observados); no se dejaron clases desplegadas | La submission real de los 8 procesos requiere un Owner con jerarquía de aprobadores poblada — exactamente el trabajo de jerarquía que Diego ya tiene asignado. No es una cuestión de "faltan usuarios de prueba": es una precondición estructural | DIEGO | Diego (jerarquía) |
| B9 — Approval Process Centro de Costo (Quote) | `Quote.CPAprobacionCargoInternoQuote` | `BLOQUEADO_DATOS_OPERATIVOS` → **`QA_FUNCIONAL_COMPLETADO`** (entrada/submission) | Ninguno | QA aislado: aprobador de Centro de Costo placeholder (Usuario ficticio creado y revertido en `@IsTest`) poblado en `CPAprobadorCentroDeCostos__c` → el proceso entra correctamente a `Pending` para una Opportunity/Quote Omoda | Validation ID `0AfAK0000012DIL0A2` | Aprobación/rechazo/recall reales requieren un aprobador real autorizado — no ejecutado, no corresponde a este lote sin esa definición | DATOS_OFICIALES (para el ciclo completo de aprobación) | Finanzas / negocio |
| B9 — Approval Process Centro de Costo (WorkOrder) | `WorkOrder.AprobacionCentroDeCostos` | `BLOQUEADO_DATOS_OPERATIVOS` → **`QA_FUNCIONAL_COMPLETADO`** (entrada/submission) | Ninguno | Mismo resultado que el proceso de Quote, con el mismo aprobador placeholder | Validation ID `0AfAK0000012DIL0A2` | Mismo pendiente que el proceso de Quote | DATOS_OFICIALES | Finanzas / negocio |
| B9 — Approval Process Garantía | `WorkOrder.PROCESO_DE_APROB_GARANTIA` | `BLOQUEADO_APROBADOR_NEGOCIO` (sin cambio) | Ninguno — explícitamente fuera de este lote | No se tocó ni se simuló resuelto, conforme al mandato | B9-AP0 | Cobertura, regla funcional y aprobador autorizado PEKING | NEGOCIO | Garantías / Taller |
| B9 — Approval Process Garantía (cita taller) | `WorkOrder.PROCESO_DE_APROB_GARANTIA_CITA_TALLER` | `BLOQUEADO_REGLA_NEGOCIO` (sin cambio) | Ninguno — explícitamente fuera de este lote | No se tocó ni se simuló resuelto | B9-AP0 | Decisión sobre proceso inactivo, cobertura, aprobador | NEGOCIO | Garantías / Taller |
| B9 — Roles / jerarquía | 15 Roles inventariados en B9-AP0 | `DEPENDENCIA_DIEGO_POR_JERARQUIA` (sin cambio) | Ninguno — no crear ni modificar | Se verificó que ningún Approval Process referencia directamente un Role como aprobador (B9-AP0), y el hallazgo nuevo de este lote (arriba, descuentos) refuerza que la ausencia de jerarquía bloquea QA real, no solo la creación de Roles | B9-AP0 + hallazgo de este lote | Creación y disponibilidad de jerarquía y perfiles | DIEGO | Diego |
| B9-1 (referencia, ya cerrado) | 4 Validation Rules de Opportunity | `QA_FUNCIONAL_COMPLETADO` | N/A — ya implementado y probado | No repetido en este lote (sin dependencia directa modificada) | Deploy `0AfAK0000012CZB0A2`; QA final `0AfAK0000012CcP0AU`; 15/15 escenarios | Ninguno | NINGUNO | — |
| B11 — Seis catálogos Softland + schedulers | 13 clases productivas + 13 pruebas | `RECONCILIADO_Y_VALIDADO_TECNICAMENTE` (B11-1, sin cambios nuevos este lote) | Ninguno — verificado documentalmente que sigue vigente (soporte RMPEKING, 6 catálogos, 13 clases reconciliadas, mocks/tests, mismo endpoint/instancia, cero schedulers activos, equivalencia Partial/Git) | No se repitieron las 36 pruebas — sin cambio nuevo en esos componentes en este lote | Test Run `707AK00000I2ACX` (36/36); Validation `0AfAK0000011hWz0AI` | Validación funcional de contenido real de catálogo | DATOS_OFICIALES | Negocio / Softland / QA |
| B11 — Bodega | `BatchGetBodegaSoftland`, `Bodega__c`, `ID_EXTERNO_BODEGA__c` | `BLOQUEADO_DATOS_OPERATIVOS` (B11-0.1) → **prueba aislada ejecutada; permanece `BLOQUEADO_ESTRATEGIA_CLAVE_BODEGA_PEKING`** | Ninguno — no se propone ni se aplica ninguna convención de clave | **Prueba aislada, reversible, con mock HTTP (sin callout real, sin datos persistentes):** se confirmó empíricamente que ejecutar `BatchGetBodegaSoftland('RMPEKING')` sobre un registro de bodega ya existente con clave `ID_EXTERNO_BODEGA__c` cruda (comportamiento real de `RMBAVARIAN` según el código) **actualiza el mismo registro** en lugar de crear uno separado — el código solo antepone prefijo de compañía para `RMOTOBAI` (`BatchGetCatalogoSoftland.cls` línea 173), nunca para `RMPEKING` ni `RMBAVARIAN` | Validation ID `0AfAK0000012DTd0AM` (1/1 prueba aprobada, colisión confirmada) | El placeholder permitió probar el **mecanismo** (que la colisión ocurre), no resuelve la **configuración oficial** (qué convención de clave separa PEKING de Bavarian, ni las bodegas oficiales PEKING). Inventar una convención ahora violaría la regla de no asumir alcance | BLOQUEADO_ESTRATEGIA_CLAVE_BODEGA_PEKING → NEGOCIO / DATOS_OFICIALES | Operaciones / Softland / negocio |
| B11 — Pricebook default | Consumidores de `PEKING Local` / `PEKING Dólares` | `PENDIENTE_DEFINICION_FUNCIONAL_PRICEBOOK_DEFAULT` (sin cambio) | Ninguno — no se implementó selección por defecto | No aplica — explícitamente fuera de alcance de este lote | — | Regla comercial de precedencia cuando no hay selección explícita | DECISION_FUNCIONAL | Ventas / negocio |
| B7 — Video 1 (Layouts Opportunity Omoda/Jaecoo) | Evidencia manual UI | `EJECUTABLE_AHORA` (según cierre inicial) → **`BLOQUEADO_POR_VISIBILIDAD_RECORDTYPE`** | Ninguno | Preflight de automatizaciones de insert completado y seguro (ver hallazgo abajo); la creación de la Opportunity Omoda/Jaecoo en sí falla antes de llegar a ejecutar ninguna automatización | `INVALID_CROSS_REFERENCE_KEY` reproducido por API y por Apex anónimo; registros QA creados, verificados sin efectos secundarios y eliminados tras el hallazgo (ver limpieza) | Habilitar Omoda/Jaecoo como Record Types visibles para al menos un Profile/Permission Set activo | DIEGO | Diego (Profiles/Permission Sets) |
| B7 — Video 2 (FlexiPages APP_DEFAULT) | Evidencia manual UI | `EJECUTABLE_AHORA` (según cierre inicial) → **`BLOQUEADO_POR_VISIBILIDAD_RECORDTYPE`** | Ninguno | Verificado técnicamente: la activación App Default de las 3 FlexiPages es genérica y no depende de Record Type, pero el objetivo del video exige abrir una Opportunity/Quote Omoda/Jaecoo, imposible de crear hoy | Misma evidencia que Video 1 (dependencia idéntica) | Mismo que Video 1 | DIEGO | Diego |
| B7 — Video 3 (Quick Action genérica de Quote) | Evidencia manual UI | `EJECUTABLE_AHORA` (según cierre inicial) → **`BLOQUEADO_POR_VISIBILIDAD_RECORDTYPE`** (dependencia transitiva) | Ninguno | Verificado técnicamente: `Quote` solo tiene Record Types `Taller`/`Nuevos` propios (sin restricción independiente para Omoda/Jaecoo); el bloqueo es exclusivamente porque el Quote de prueba necesita una Opportunity Omoda/Jaecoo como padre | Consulta directa de `RecordType` sobre `Quote`; misma evidencia base que Video 1 | Mismo que Video 1 | DIEGO | Diego |

---

## Hallazgo: visibilidad de Record Types Omoda/Jaecoo (`RECORD_TYPES_OMODA_JAECOO_NO_HABILITADOS_PARA_USUARIOS_ACTIVOS`)

**Qué es:** ningún usuario activo en Partial tiene los Record Types `Omoda` ni `Jaecoo` de `Opportunity` habilitados en su Profile/Permission Set, incluido el usuario `System Administrator` conectado (Claudia Pérez). No es una cuestión de asignación de Layout (eso ya estaba documentado en el precheck de UI del mismo día) — es una capa de seguridad anterior y más restrictiva: la visibilidad del propio Record Type.

**Qué NO es:**
- No es falta de datos QA — Diego ya autorizó placeholders y estos se prepararon correctamente para BMW.
- No es un defecto de los Layouts ni de las FlexiPages — nunca se llegó a evaluar Layout alguno porque la creación del registro falló antes.
- No es un efecto secundario de automatización — el preflight de triggers Apex (`AccountTrigger`→`AccountTriggerHandler`, `OpportunityTrigger`→`OpportunityTriggerHandler`, `OpportunityOriginTracking`) y de los 12 Flows activos con `RecordTriggerType` `Create`/`CreateAndUpdate` sobre `Account`/`Opportunity` se completó de forma exhaustiva y confirmó que un insert mínimo (sin `Sucursal__c`, `LeadSource`, `Trafico__c`, `contacto__c`, `RT_Lead__c`, `CreadaEnConversion__c`, campos de identificación/Softland en Account, ni `StageName='Cerrada Ganada'`) no dispara emails, callouts, reservas, pedidos, aprobaciones ni jobs. El error de Record Type ocurre en la capa de validación de acceso, antes de que cualquier trigger o Flow se ejecute.

**Evidencia técnica:**
1. `sf data create record` con `RecordTypeId` de Omoda → `INVALID_CROSS_REFERENCE_KEY: Record Type ID: this ID value isn't valid for the user: 012AK0000002McMYAU`.
2. `sf data create record` con `RecordTypeId` de Jaecoo → mismo error, `012AK0000002McLYAU`.
3. Apex anónimo ejecutado como el mismo usuario (contexto de sistema, no API REST) intentando el mismo insert de Omoda → **idéntico error**, descartando que fuera una particularidad del cliente CLI o de la API de datos.
4. La misma Opportunity con Record Type `BMW` (`0120P000000arDlQAI`) se creó sin ningún problema bajo el mismo usuario, confirmando que el bloqueo es específico de Omoda/Jaecoo y no un problema general de permisos del usuario.

**Registros QA usados para esta evidencia (ya eliminados, ver limpieza):**
- 3 Accounts: `QA_PEKING_UI_S3_20260807 - Omoda`, `- Jaecoo`, `- BMW Regresion`.
- 1 Opportunity: `QA_PEKING_UI_S3_20260807 - BMW Regresion-BMW-07/08/2026` (Record Type BMW; Omoda y Jaecoo nunca llegaron a crearse).

**Limpieza ejecutada (2026-08-07):**

| Registro | Id | Verificación previa | Acción |
|---|---|---|---|
| Account Omoda | `001AK00000PKBFYYA5` | 0 Contacts, 0 Opportunities relacionadas propias (aparte de la BMW en la cuenta BMW) | Eliminado |
| Account Jaecoo | `001AK00000PKDApYAP` | 0 Contacts | Eliminado |
| Account BMW Regresion | `001AK00000PKJuYYAX` | 1 Opportunity relacionada (la de este lote) | Eliminado tras eliminar la Opportunity |
| Opportunity BMW | `006AK00000JJ17BYAT` | 0 Tasks, 0 ProcessInstance, 0 Quotes, 0 OpportunityLineItems, 0 AsyncApexJob pendientes | Eliminado primero (hijo antes que padre) |

Verificación posterior: `SELECT COUNT(Id) FROM Account WHERE Name LIKE 'QA_PEKING_UI_S3_20260807%'` = 0; `SELECT COUNT(Id) FROM Opportunity WHERE Name LIKE 'QA_PEKING_UI_S3_20260807%'` = 0; `SELECT COUNT(Id) FROM AsyncApexJob WHERE CreatedDate = TODAY AND Status IN ('Queued','Preparing','Processing','Holding')` = 0. Cero registros residuales, cero jobs generados por este lote.

**Responsable de la resolución:** Diego, mediante ajuste de Profile(s) o Permission Set(s) para incluir Omoda y Jaecoo en los Record Types visibles de al menos un perfil activo (administrador o de negocio). Este equipo no modificó ni modificará Profiles, Permission Sets, Roles, Layout assignments ni activaciones de FlexiPage para resolverlo — está fuera del alcance autorizado de este lote.

---

## Resumen de hallazgos nuevos de este lote

1. **Drift de `Opportunity_Record_Page_VN` es mayor de lo documentado previamente.** No es solo `Plan_del_cliente_save_PDF`: hay cambios de nombres de Profile en reglas de visibilidad (posible señal de que el trabajo de jerarquía/perfiles de Diego ya inició en Partial de forma parcial) y una propiedad de label removida. No se sobrescribió Partial ni Git.
2. **Los 8 Approval Processes de descuento no pueden probarse de submission real sin la jerarquía de Diego.** Esto no estaba caracterizado con esta precisión antes: el bloqueo no es "faltan datos QA", es que los campos de entrada (`Jefe__c`/`Gerente__c`/`Director__c` y sus aprobadores) son recalculados por automatización ligada al Owner, confirmado idéntico en Omoda y en BMW.
3. **Tres Validation Rules antes bloqueadas por "datos operativos" (VR-007, VR-009, VAL-103) y dos Approval Processes de Centro de Costo quedan con QA funcional completo** usando exclusivamente placeholders autorizados por Diego (Centro de Costo y bodega de prueba), sin tocar datos reales.
4. **La colisión de clave externa de bodega (B11-0.1) quedó confirmada con una prueba automatizada**, no solo con lectura de código — refuerza que el bloqueo es real y no una sobreestimación.
5. **`Campo_Sucursal_Obligatorio` no bloqueó en el escenario aislado esperado**, revelando una posible interacción con otra automatización activa que no fue posible aislar en este lote sin exceder su alcance.
6. **`MusthaveActivity` no estaba realmente bloqueada por datos operativos** — el campo `Flag_Vehiculo_Nuevo_FM__c` que la activa es una fórmula que excluye estructuralmente a Omoda y Jaecoo (solo incluye BMW/MINI/Motorrad/Polaris/Kawasaki/Indian). Es el tercer caso de este tipo encontrado en este lote (junto a VR-002 y VAL-103), lo que sugiere que otras filas de la matriz de 94 Validation Rules marcadas "bloqueadas por datos" podrían en realidad ser exclusiones estructurales por RecordType/fórmula — una hipótesis a validar en un lote futuro, no una ampliación de alcance de este.

---

## Controles de seguridad aplicados

- Org: Partial exclusivamente. Producción no fue consultada ni modificada.
- Todo QA se ejecutó en `@IsTest` con datos transaccionales revertidos automáticamente, o en `--dry-run`/check-only sin persistir metadata.
- Ningún correo real fue enviado (Apex suprime correos salientes en contexto de prueba).
- Ningún aprobador real fue asignado — los usuarios usados como aprobadores placeholder fueron creados y revertidos dentro de `@IsTest` con direcciones `*.test.invalid`, nunca personas reales identificadas.
- Ninguna reserva, pedido, factura o aprobación quedó persistente.
- Ningún job ni scheduler fue programado o activado.
- No se creó ni modificó jerarquía, Roles ni perfiles.
- No se inventaron bodegas oficiales, centros de costo oficiales, asesores, territorios ni datos legales/comerciales.
- Todas las clases Apex usadas para generar esta evidencia fueron temporales (check-only) y no quedaron versionadas en el repositorio.

---

## Enlace con `PENDIENTES_REALES_CIERRE_SPRINT3_20260806.md`

Este documento reemplaza, para las filas donde hubo nueva evidencia, la fila equivalente de `PENDIENTES_REALES_CIERRE_SPRINT3_20260806.md`. Ese documento sigue vigente para todo lo no tocado en este lote (bloque 7 restante, garantía, catálogos con contenido real, Pricebook default, jerarquía).

---

## Criterio crítico

**A. ¿Queda algún cambio técnico autorizado de Sprint 3 que pueda implementarse ahora sin una respuesta externa?**

No. Ningún hallazgo de este lote apunta a un defecto de metadata que deba corregirse dentro del alcance autorizado. El único defecto técnico real detectado en Sprint 3 (`Campo_Gustos_y_aficiones_Obligatorio`, B9-1) ya fue corregido y desplegado en una pasada anterior. `Campo_Sucursal_Obligatorio` no mostró un defecto de fórmula confirmado — mostró un resultado inconcluyente que requiere análisis adicional antes de proponer cualquier cambio, y ese análisis no es un cambio autorizado por sí mismo.

**B. ¿Queda algún QA técnico automatizable que pueda ejecutarse ahora?**

No. `Opportunity.MusthaveActivity` (el único candidato identificado como pendiente durante este lote) ya se ejecutó: se confirmó `NO_APLICA_CONFIRMADO` (Validation ID `0AfAK0000012DWr0AM`) — es una exclusión estructural por fórmula, no un bloqueo de datos. Con esto, todo el QA automatizable identificado en el alcance de B7/B9/B11 fue intentado; lo que queda depende de evidencia manual (C) o de dependencias externas (D).

**C. ¿Queda alguna evidencia manual que pueda grabarse ahora?**

**Actualización (2026-08-07, tarde): No.** Al intentar preparar los datos QA persistentes para el Video 1, se descubrió que ningún usuario activo puede crear una Opportunity Omoda ni Jaecoo (`RECORD_TYPES_OMODA_JAECOO_NO_HABILITADOS_PARA_USUARIOS_ACTIVOS`, ver sección dedicada arriba). Los 3 videos de `PLAN_EVIDENCIAS_FINALES_SPRINT3_20260807.md` (Layouts de Opportunity, FlexiPages APP_DEFAULT, Quick Action genérica de Quote) quedan `BLOQUEADO_POR_VISIBILIDAD_RECORDTYPE` — los tres, verificado técnicamente y no asumido, incluyendo los dos que en principio no dependían de Record Type (Videos 2 y 3 dependen transitivamente de poder crear la Opportunity/Quote Omoda-Jaecoo que su objetivo exige comparar). Los datos QA usados para descubrir esto (3 Accounts + 1 Opportunity BMW) ya fueron eliminados tras confirmar cero efectos secundarios.

`EVIDENCIAS_UI_PLAN_FINAL_BLOQUEADAS_POR_DEPENDENCIA_EXTERNA`

**D. ¿Cuáles son exactamente los pendientes externos?**

1. Asignación funcional de 63 Layouts/FlexiPages/Quick Actions restantes del bloque 7.
2. Conciliación del drift de `Opportunity_Record_Page_VN` (renombramiento de perfiles + `Plan_del_cliente_save_PDF`) y su asignación funcional a Omoda/Jaecoo.
3. Jerarquía de aprobadores (Jefe/Gerente/Director) para que los 8 Approval Processes de descuento puedan probarse de submission real — no solo para B9 sino confirmado ahora como precondición técnica, no solo organizativa.
4. Centro de costo y aprobador oficiales para completar el ciclo de aprobación real de los 2 procesos de Centro de Costo (la entrada/submission ya quedó probada con placeholder).
5. Cobertura, regla funcional y aprobador autorizado de Garantía (2 Approval Processes).
6. Bodegas oficiales PEKING y una estrategia de clave externa que separe PEKING de Bavarian (la colisión quedó confirmada técnicamente, no resuelta).
7. Contenido oficial de los seis catálogos Softland para validación funcional real.
8. Regla comercial de Pricebook por defecto (PEKING Local vs. PEKING Dólares) cuando no hay selección explícita.
9. Análisis adicional (fuera de este lote) de qué automatización activa interfiere con `Campo_Sucursal_Obligatorio` antes de repetir su QA.
10. **(Agregado 2026-08-07, tarde)** Habilitar Omoda y Jaecoo como Record Types visibles en al menos un Profile/Permission Set activo — sin esto, los 3 videos de `PLAN_EVIDENCIAS_FINALES_SPRINT3_20260807.md` quedan `BLOQUEADO_POR_VISIBILIDAD_RECORDTYPE` y no puede crearse ningún dato QA persistente de Opportunity Omoda/Jaecoo, para evidencia ni para ningún otro propósito.

**E. ¿Quién debe resolver cada uno?**

- **Diego:** puntos 2 (perfiles), 3 (jerarquía) y 10 (visibilidad de Record Types).
- **Negocio / Ventas / Taller:** punto 1 (asignación de UI) y 8 (Pricebook default).
- **Finanzas / negocio:** punto 4 (centro de costo y aprobador oficiales).
- **Garantías / Taller:** punto 5.
- **Operaciones / Softland / negocio:** punto 6 (bodega).
- **Negocio / Softland / QA:** punto 7 (catálogos).
- **Desarrollo (interno, en un lote posterior autorizado):** punto 9.

Dado que **A = NO y B = NO**, sigue siendo válido declarar:

## `TRABAJO_TECNICO_INTERNO_AGOTADO`

**Confirmado vigente tras el hallazgo de visibilidad de Record Types (2026-08-07, tarde).** El hallazgo no reabre ni contradice A o B: no es un cambio técnico pendiente de nuestro lado (es una configuración de Profile/Permission Set que corresponde a Diego) ni un QA automatizable (ya se intentó exhaustivamente y el bloqueo se confirmó de forma definitiva por dos vías independientes). Lo que sí cambió es **C**, que pasa de SÍ a NO: los 3 videos de evidencia UI que antes parecían ejecutables ahora están `BLOQUEADO_POR_VISIBILIDAD_RECORDTYPE`.

Esto **no significa que Sprint 3 esté terminado.** No queda ningún video ejecutable ahora mismo (`EVIDENCIAS_UI_PLAN_FINAL_BLOQUEADAS_POR_DEPENDENCIA_EXTERNA`), y la lista de pendientes externos (D/E arriba) creció con el punto 10 (visibilidad de Record Types, responsable Diego), que no depende de trabajo técnico adicional nuestro.
