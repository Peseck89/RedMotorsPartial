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
