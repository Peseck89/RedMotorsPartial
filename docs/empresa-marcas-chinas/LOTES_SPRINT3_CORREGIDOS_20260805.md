# Lotes corregidos — Sprint 3

> Luis autorizó exclusivamente la ejecución de S3-0 el 6 de agosto de 2026. Esta autorización no comprende ningún lote funcional.

Fecha de corte: 5 de agosto de 2026.

No existe un lote funcional listo para implementación. Los estados de este documento son CANDIDATO, BLOQUEADO y PENDIENTE_CONFIRMAR_SPRINT.

## S3-0 — Conciliación del Sprint 3 explícito

**Estado: ANALISIS_EJECUTADO_CON_LIMITACIONES**

- **Incluye:** bloque 7; bloque 9; bloque 11.
- **Componentes:** Layouts, FlexiPages, cinco Quick Actions; Validation Rules, Approval Processes y 15 roles; RM_Config, mappings y configuración Softland.
- **Objetivo:** inventario exacto, comparación de metadata versionada/Partial, estado activo, aplicabilidad PEKING, dependencia de Record Types, exclusión de usados y evidencia.
- **No incluye:** Apex, Flows, LWC/Aura, PricebookEntry, creación masiva de List Views, perfiles masivos, ejecución E2E ni extras TD-RQ308.
- **Dependencias:** acceso de lectura a Partial y fuente actualizada.
- **Riesgo:** bajo, al no modificar Salesforce.
- **Validación:** retrieve temporal, Tooling API, asignaciones y referencias.
- **Evidencia:** matriz nominal y decisión por componente.
- **Condición para comenzar:** repositorio limpio y manifest limitado.
- **Condición para cerrar:** todos los componentes reales de los bloques 7, 9 y 11 quedan clasificados con evidencia.
- **Reversión:** total; es un lote de análisis.

S3-0 produjo una [matriz nominal](MATRIZ_NOMINAL_S3_0_20260806.csv) de 72 componentes y un [resultado de conciliación](RESULTADO_S3_0_CONCILIACION_20260806.md). No se marca `COMPLETADO_COMO_ANALISIS` porque siguen pendientes evidencia de asignaciones activas y la identificación del mecanismo autoritativo de configuración Softland.

## S3-1 — UI declarativa aplicable a PEKING

**Estado: CANDIDATO**

- **Incluye:** diferencias demostradas de layouts, FlexiPages y Quick Actions después de S3-0.
- **Excluye:** páginas y componentes exclusivos de usados.
- **Dependencias:** asignaciones de Record Types, identidad documental, monedas y plantillas oficiales.
- **Riesgo:** medio por exposición y activación.
- **Validación:** pruebas por Record Type y perfil QA.
- **Condición para comenzar:** lista exacta aprobada y ausencia de bloqueos funcionales por componente.
- **Condición para cerrar:** diff, validación, QA y reversión documentados.
- **Reversión:** alta con metadata previa recuperada.

No está listo para implementación porque S3-0 aún no ha demostrado la lista final.

## S3-2 — Validation Rules

**Estado: BLOQUEADO**

- **Incluye:** reglas activas e inactivas realmente relacionadas con Empresa, Marca, Pricebook, descuento o centro de costo.
- **Dependencias:** criterios PEKING de descuento, cuenta y centro de costo.
- **Riesgo:** alto; una regla incorrecta puede bloquear transacciones.
- **Validación:** positivos/negativos por Empresa y estado activo.
- **Condición para comenzar:** fórmula y criterio aprobados por regla.
- **Reversión:** alta si cada regla se despliega de forma aislada.

No se crearán exactamente siete reglas por estimación.

## S3-3 — Approval Processes y roles

**Estado: BLOQUEADO**

- **Incluye:** ocho aprobaciones activas de Opportunity, una de Quote, tres candidatas de WorkOrder y la jerarquía de 15 roles.
- **Dependencias:** sucursales, responsables, descuentos, garantía y seguridad.
- **Riesgo:** alto por aprobadores fijos, acceso y operación.
- **Validación:** matriz de aprobadores, perfiles QA, estados activo/inactivo y no cruce entre Empresas.
- **Condición para comenzar:** jerarquía y responsables oficiales.
- **Reversión:** media; requiere respaldo por proceso/rol.

No se crearán exactamente seis procesos ni roles inventados.

## S3-4 — Custom Metadata y configuración Softland

**Estado: BLOQUEADO**

- **Incluye:** RM_Config.Default_Price_List_VN, mappings ya existentes y mecanismo configurable de Softland.
- **Dependencias:** decisión del default VN y mapa autoritativo de configuración.
- **Riesgo:** alto si PEKING hereda Bavarian o se duplica una instancia.
- **Validación:** RMBAVARIAN, RMOTOBAI y RMPEKING; errores controlados; ninguna exposición de secretos.
- **Condición para comenzar:** decisión comercial y confirmación técnica de Diego.
- **Reversión:** alta para Custom Metadata; depende del mecanismo de configuración.

Los mappings Omoda/Jaecoo están técnicamente cubiertos, pero el lote completo no está listo.

## S3-P1 — List Views

**Estado: PENDIENTE_CONFIRMAR_SPRINT**

El bloque 8 no tiene Sprint escrito. Las ocho vistas Opportunity Omoda/Jaecoo preexistentes se conservan como evidencia, pero no autorizan creación masiva adicional.

## S3-P2 — Global Value Sets

**Estado: PENDIENTE_CONFIRMAR_SPRINT**

El bloque 12 no tiene Sprint escrito. Antes de cualquier cambio deben identificarse los tres GVS exactos y su uso.

## S3-P3 — Pricebooks y PricebookEntry

**Estado: PENDIENTE_CONFIRMAR_SPRINT**

El bloque 13 no tiene Sprint escrito. La estructura técnica previa no autoriza cargar productos, precios o monedas.

## S3-P4 — E2E y regresión

**Estado: PENDIENTE_CONFIRMAR_SPRINT**

El bloque 14 no tiene Sprint escrito. Sigue siendo necesario para el cierre general, pero no se declara ejecutado ni absorbido por Sprint 3.

## Decisión de inicio

S3-0 fue ejecutado exclusivamente como conciliación de lectura. La auditoría posterior del 2026-08-06 corrigió su estado a `S3-0 — EN_PROGRESO_CON_BRECHAS_DE_COBERTURA`. No existe un lote funcional autorizado; la [propuesta posterior](PROPUESTA_PRIMER_LOTE_FUNCIONAL_SPRINT3_20260806.md) queda `SIN_LOTE_FUNCIONAL_LISTO`.

Antes de cualquier lote funcional debe aprobarse el baseline Git–Partial específico descrito en `PLAN_BASELINE_GIT_PARTIAL_SPRINT3_20260806.md`. Esta condición no autoriza `Opportunity_Record_Page_VN`, retrieves al worktree, dry-run ni deploy.

### Corrección S3-0.2 — 2026-08-06

La integridad nominal quedó corregida a 224 componentes únicos más un placeholder. La selección de baseline se redujo a candidatos con evidencia en `MATRIZ_ASIGNACIONES_UI_S3_0_20260806.csv`; no se autoriza recuperar 219 componentes ni iniciar funcionalidad. S3-0 permanece `EN_PROGRESO_CON_BRECHAS_DE_COBERTURA` por asignaciones no demostradas, decisiones funcionales y mecanismo Softland pendiente.

### Cierre S3-0.3 — 2026-08-06

S3-0 queda `COMPLETADO_COMO_ANALISIS_CON_LIMITACIONES`: inventario nominal e integridad terminados, sin implementación. Ningún lote funcional está listo. La siguiente decisión es revisar las preguntas pendientes de negocio y la identificación del mecanismo Softland.

B0-UI-1 continúa propuesto y no autorizado. `Opportunity_Record_Page_VN` también continúa sin autorización. El cierre analítico no habilita baseline, retrieve al worktree, dry-run ni deploy.

### Decisión de alcance confirmada por Luis — 2026-08-06

| Bloque/lote | Estado vigente |
|---|---|
| 7, 9 y 11 | Único alcance expresamente asignado a Sprint 3 |
| S3-P1 — bloque 8 | `FUERA_DE_SPRINT3_CONFIRMADO` |
| Bloque 10 — Profiles/Permission Sets amplios | `NA`; fuera de Sprint 3 |
| S3-P2 — bloque 12 | `FUERA_DE_SPRINT3_CONFIRMADO` |
| S3-P3 — bloque 13 | `FUERA_DE_SPRINT3_CONFIRMADO` |
| S3-P4 — bloque 14 | `FUERA_DE_SPRINT3_CONFIRMADO` |

Los frentes excluidos no están cancelados ni fuera del proyecto; simplemente no se ejecutan en Sprint 3. S3-0 permanece `COMPLETADO_COMO_ANALISIS_CON_LIMITACIONES`. S3-1 a S3-4 siguen sin autorización funcional.

La siguiente decisión es revisar las preguntas consolidadas de negocio y Softland. B0-UI-1 continúa propuesto y no autorizado, y `Opportunity_Record_Page_VN` continúa sin autorización.

### Reevaluación por respuesta de Diego — 2026-08-06

- S3-1 sigue sin autorización; la respuesta no define asignaciones de Layouts/FlexiPages ni datos de identidad.
- S3-2 reduce el bloqueo general: PEKING debe mantener las reglas existentes. Cada Validation Rule debe inspeccionarse nominalmente; las fórmulas con marcas, Record Types, perfiles o datos específicos no quedan desbloqueadas automáticamente.
- S3-3 sigue bloqueado para implementación. La lógica general queda confirmada, pero aprobadores, centros de costo y garantía siguen pendientes. Jerarquía y perfiles son `DEPENDENCIA_DIEGO` y no forman un lote propio del equipo.
- S3-4 sigue bloqueado: reservas y devoluciones por Empresa no definen el mecanismo autoritativo de Softland.

No se identifica un lote funcional nuevo que tenga baseline suficiente, datos independientes y prueba aislada completa. Solo queda habilitada una revisión nominal preparatoria, no una implementación.

### B9-0 — revisión nominal de Validation Rules — 2026-08-06

B9-0 quedó `COMPLETADO_COMO_ANALISIS`: se revisaron exactamente 94 Validation Rules. El resultado fue 32 sin cambio técnico con regresión pendiente, 9 bloqueadas por datos operativos, 4 bloqueadas por negocio, 46 dependencias de Diego y 3 no aplicables a PEKING. No existe todavía una candidata técnica aislada, por lo que B9-1 no se propone ni se autoriza.

La evidencia nominal está en `MATRIZ_VALIDATION_RULES_B9_0_20260806.csv` y `RESULTADO_B9_0_VALIDATION_RULES_20260806.md`. Ninguna regla fue modificada.

### Corrección B9-0.1 — dependencia real de perfiles

La revisión específica de las 46 dependencias corrigió el resultado: 34 eran referencias genéricas de Admin y no dependen de Diego; 4 combinaban una excepción Admin genérica con Record Types legacy y son candidatas técnicas; 8 sí dependen de perfiles funcionales o ProfileId.

B9-1 queda `CANDIDATO_PENDIENTE_REVISION` con cuatro Validation Rules de Opportunity. Requiere baseline interno desde Partial y autorización posterior; no fue implementado.

### Resultado B9-1 — 2026-08-06

B9-1 quedó `IMPLEMENTADO_EN_PARTIAL_PENDIENTE_QA_FUNCIONAL`. Se versionó el baseline y se agregaron Omoda/Jaecoo únicamente a las cuatro Validation Rules aprobadas. El dry-run y el deploy a Partial fueron exitosos, y el retrieve posterior resultó equivalente a Git.

El QA técnico está completo. Continúan pendientes las pruebas funcionales positivas, negativas y de regresión con datos QA autorizados; por ello el lote no está cerrado ni validado funcionalmente.

### B7-0 — selección técnica de UI — 2026-08-06

B7-0 quedó `COMPLETADO_COMO_ANALISIS` sobre 78 componentes ya inventariados: 46 Layouts, 27 FlexiPages y 5 Quick Actions. Diez no requieren cambio y quedan para regresión; 63 están bloqueados por asignación funcional; 1 presenta drift Git–Partial y 4 no aplican por ser de usados.

No existe un B7-1 aislable y no se propone lote funcional. `Opportunity_Record_Page_VN` requiere primero una conciliación técnica separada y una decisión de asignación; no fue modificado. B9-1 conserva su estado `IMPLEMENTADO_EN_PARTIAL_PENDIENTE_QA_FUNCIONAL`.
