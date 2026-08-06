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

S3-0 fue ejecutado exclusivamente como conciliación de lectura. No existe un lote funcional autorizado para implementación; la [propuesta posterior](PROPUESTA_PRIMER_LOTE_FUNCIONAL_SPRINT3_20260806.md) permanece `CANDIDATO_PENDIENTE_APROBACION` y no contiene todavía un cambio funcional elegible.
