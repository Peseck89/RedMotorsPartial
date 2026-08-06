# Auditoría de cobertura S3-0.1 — 2026-08-06

**Estado:** `S3-0 — EN_PROGRESO_CON_BRECHAS_DE_COBERTURA`

## Objetivo y límites

Esta revisión posterior conserva como histórico el resultado del commit `5316bea` y demuestra el universo revisado de los bloques 7, 9 y 11. Solo se consultó `RedMotorsSandbox` en lectura; los retrieves se hicieron fuera del worktree. No se modificó Salesforce, no hubo deploy ni dry-run y no se consultó Producción.

## Universo revisado

| Tipo | Universo Partial | Incluidos | Excluidos | Criterio |
|---|---:|---:|---:|---|
| Layout | 61 | 46 | 15 | Opportunity, Account, Product2, Quote y WorkOrder con campos/dependencias relevantes; se excluyeron usados y variantes operacionales ajenas. |
| FlexiPage | 25 | 23 | 2 | Se revisaron todas las variantes `Opportunity_Record_Page*` y `Quote_Record_Page*`; se excluyeron VN/VU exclusivamente de usados. |
| Quick Action referenciada | 50 | 5 | 45 | Las cinco acciones de la fuente son el alcance nominal; 45 referencias adicionales se registran para demostrar el universo, no para ampliar alcance. |
| Validation Rule | 383 | 94 | 289 | Se incluyeron todas las reglas de Opportunity (52), Quote (4), WorkOrder (34) y Product2 (4). Las restantes pertenecen a otros objetos. |
| Approval Process | 18 | 12 | 6 | Se incluyeron los procesos de descuento, Quote, centro de costo y garantía; seis procesos de objetos financieros/auxiliares quedaron nominalmente excluidos. |
| Role | 15 | 15 | 0 | Los 15 son el universo completo devuelto por Partial, no una muestra. No se encontró ni se infirió un rol PEKING. |
| Candidato Softland | 11 | 0 | 11 | Solo se revisaron nombres y tipos no sensibles; ninguno demuestra ser el mecanismo autoritativo. |

El archivo `UNIVERSO_Y_CRITERIOS_SELECCION_S3_0_20260806.csv` contiene 563 filas y el motivo individual de inclusión o exclusión.

## Hallazgos del bloque 7

- La base anterior contenía cuatro Layouts; Partial devolvió 61 candidatos en los cinco objetos solicitados. Se seleccionaron 46 y se documentaron 15 exclusiones.
- La base anterior contenía cinco FlexiPages, dos de ellas ajenas al patrón solicitado. Se revisaron las 25 variantes del patrón: 16 de Opportunity y 9 de Quote. Veintitrés permanecen candidatas hasta demostrar asignación; dos VU son exclusivas de usados.
- La metadata recuperada demuestra contenido, pero no la asignación efectiva por aplicación, perfil y Record Type. Por eso ninguna variante nueva queda autorizada para cambio.
- `Opportunity_Record_Page_VN` conserva el único drift conocido Git–Partial; no está autorizada su conciliación en esta tarea.
- Las cinco Quick Actions nominales no son el universo de acciones referenciadas. Se detectaron 45 referencias custom adicionales, registradas como exclusiones para evitar ampliación silenciosa.

## Hallazgos del bloque 9

- Las 383 Validation Rules de Partial quedaron registradas. Las 94 pertenecientes a los cuatro objetos objetivo entraron a la matriz V2; 289 se excluyeron por objeto.
- Estado activo/inactivo se conservó como evidencia. Una regla inactiva no se trató como inexistente: queda en regresión y no como cambio funcional autorizado.
- Los 18 Approval Processes quedaron nominalmente registrados: 12 dentro del inventario y 6 fuera por objeto/dominio.
- Los 15 roles son el universo completo de `Role` devuelto por Partial. La existencia de una jerarquía legacy no autoriza crear roles ni asignaciones PEKING.

## Correcciones del bloque 11 y de clasificación

- `Mecanismo_configurable_endpoints_Softland` es un placeholder de investigación, no un componente nominal confirmado. Su clasificación es `PENDIENTE_IDENTIFICAR_COMPONENTE_AUTORITATIVO`.
- Se revisaron, sin leer valores ni secretos, cinco nombres de Named Credential, tres de External Credential y dos tipos de configuración. Ninguno acredita el mecanismo Softland.
- `Quote.BMW_ImportarPlantilla` pasa a `DEPENDENCIA_OTRO_SPRINT` porque depende de plantillas oficiales y del Flow bloqueado de Sprint 2.
- Los mappings legacy se separan entre `NO_APLICA` cuando son exclusivos de usados y `REQUIERE_REGRESION` cuando deben demostrar que no afectan el comportamiento vigente.
- Los elementos con `Aplica_PEKING = Por determinar` que necesitan una decisión externa no quedan como validación libre: se clasifican `BLOQUEADO_NEGOCIO`.
- Los componentes presentes solo en Partial mantienen `NO_COMPARABLE`; no se declaran conciliados contra Git.

## Conteos nominales y limitaciones

La matriz V2 contiene 226 filas: 225 componentes/registros nominales y un placeholder de investigación. Por tipo: 94 Validation Rules, 47 Layouts, 26 FlexiPages, 18 Approval Processes, 17 Custom Metadata records, 15 Roles, 5 Quick Actions, 3 registros Empresa y 1 placeholder.

La cohorte histórica de 65 componentes que solo existían en Partial permanece sin modificación. La ampliación de inventario eleva a 219 las filas V2 sin contraparte Git o con datos no versionables; no implica autorización para recuperarlas al repositorio.

Persisten estas limitaciones:

- no se demostró la asignación efectiva de Layouts/FlexiPages por perfil y Record Type;
- no se identificó el componente autoritativo Softland;
- las reglas y procesos con efecto PEKING requieren decisión/QA nominal;
- no existe baseline Git para la mayoría de la metadata seleccionada.

## Conclusión

S3-0 no puede cerrarse. Su estado correcto es `EN_PROGRESO_CON_BRECHAS_DE_COBERTURA`. La cobertura del universo ya está documentada, pero falta versionamiento controlado, evidencia de asignación y decisiones funcionales. No existe lote funcional listo ni autorización sobre `Opportunity_Record_Page_VN`.

## Corrección posterior S3-0.2 — 2026-08-06

Los CSV anteriores se conservan como resultado histórico de `c3f253c`. Las versiones corregidas son `UNIVERSO_Y_CRITERIOS_SELECCION_S3_0_V2_20260806.csv` y `MATRIZ_NOMINAL_S3_0_V3_20260806.csv`.

S3-0.2 eliminó 175 contradicciones de inclusión/exclusión, normalizó 19 nombres de Layout con `%2E`, recalculó existencia Git y fusionó el duplicado semántico de `Product2-Product Layout V1.1`. El conteo vigente es 224 componentes nominales y un placeholder.

La evidencia de `ProfileLayout` produjo 4,735 combinaciones relevantes y seis Layouts relacionados nominalmente con Record Types Omoda/Jaecoo/PEKING; 14 Layouts seleccionados quedaron explícitamente sin asignación demostrada. La metadata de aplicaciones/objetos produjo 1,580 activaciones de FlexiPage; ninguna vincula explícitamente una página del universo con esos Record Types. Diecisiete páginas no tienen asignación demostrada. Las cinco acciones nominales presentan diez exposiciones declaradas; `WorkOrder.BMW_CambiarMoneda` no tiene exposición demostrada.

La existencia continúa separada de activación y de acceso efectivo. El estado permanece `S3-0 — EN_PROGRESO_CON_BRECHAS_DE_COBERTURA`; no existe lote funcional listo.

## Cierre posterior S3-0.3 — 2026-08-06

Las tres inconsistencias residuales quedaron corregidas en `MATRIZ_NOMINAL_S3_0_V4_20260806.csv` y `MATRIZ_ASIGNACIONES_UI_S3_0_V2_20260806.csv`. El estado vigente pasa a `S3-0 — COMPLETADO_COMO_ANALISIS_CON_LIMITACIONES`.

El conteo final es 225 componentes nominales únicos más un placeholder, con 27 FlexiPages. `Opportunity_Record_Page_VU` quedó registrada una sola vez como exclusiva de usados y `NO_APLICA` para PEKING. Seis Approval Processes excluidos quedaron alineados con `Aplica_PEKING = No`.

Los 4,735 ProfileLayouts corresponden a 4,735 asignaciones distintas: 4,655 con perfil resuelto y 80 asociadas a seis referencias estables no sensibles. No se encontraron duplicados reales. Este cierre no implementa funcionalidad ni autoriza baseline, `Opportunity_Record_Page_VN` o un lote funcional.
