# Resultado B7-0 — selección técnica de UI

**Fecha:** 6 de agosto de 2026

**Estado:** `COMPLETADO_COMO_ANALISIS`

## Pregunta resuelta

¿Existe un siguiente lote concreto de UI dentro del bloque 7?

**Resultado:** no existe todavía un B7-1 aislable. Los componentes que no requieren cambio quedan para regresión; el resto necesita una decisión de asignación funcional o una conciliación previa de drift.

## Universo B7-0

El universo se derivó exclusivamente de `MATRIZ_NOMINAL_S3_0_V4_20260806.csv`. No se repitió el inventario general.

| Tipo | Cantidad |
|---|---:|
| Layouts | 46 |
| FlexiPages | 27 |
| Quick Actions | 5 |
| **Total** | **78** |

## Conteo por clasificación

| Clasificación | Cantidad |
|---|---:|
| `SIN_CAMBIO_REQUIERE_REGRESION` | 10 |
| `CANDIDATO_AJUSTE_TECNICO` | 0 |
| `BLOQUEADO_ASIGNACION_FUNCIONAL` | 63 |
| `DEPENDENCIA_DIEGO` | 0 |
| `DRIFT_REQUIERE_CONCILIACION` | 1 |
| `NO_APLICA` | 4 |
| **Total** | **78** |

La trazabilidad nominal completa está en `MATRIZ_UI_B7_0_20260806.csv`.

## Sin cambio

### Layouts — 6

Los seis Layouts de Opportunity señalados previamente ya tienen asignaciones `ProfileLayout` explícitas tanto para Omoda como para Jaecoo. No se infiere que todos deban modificarse; la evidencia conduce al resultado contrario: no requieren adaptación técnica demostrada y quedan para regresión.

| Layout | Omoda | Jaecoo | Resultado |
|---|---:|---:|---|
| `Opportunity-Autos V1.3` | 36 perfiles | 36 perfiles | Sin cambio; regresión |
| `Opportunity-Autos V1.3 - Inventario` | 1 perfil | 1 perfil | Sin cambio; regresión |
| `Opportunity-Autos V1.4` | 5 perfiles | 5 perfiles | Sin cambio; regresión; incluye perfiles nominales de usados que deben permanecer aislados |
| `Opportunity-Autos V1.4 Sin Botones` | 1 perfil | 1 perfil | Sin cambio; regresión |
| `Opportunity-Opportunity Layout` | 117 perfiles | 117 perfiles | Sin cambio; regresión |
| `Opportunity-Vehiculos Nuevos V1.1` | 1 perfil | 1 perfil | Sin cambio; regresión |

La existencia de estas asignaciones no demuestra acceso efectivo ni autoriza nuevas asignaciones para los perfiles que Diego creará.

### FlexiPages — 3

- `Opportunity_Record_Page1`
- `Quote_Record_Page`
- `Quote_Record_Page2`

Sus activaciones demostradas son `APP_DEFAULT`, sin condición de Empresa, marca o Record Type. PEKING entra por la misma ruta genérica; requieren regresión, no modificación.

### Quick Actions — 1

- `Quote.BMW_Duplicar_Partidas_de_Presupuesto`

Está expuesta en el Layout y la FlexiPage genéricos de Quote, sin visibilidad por Empresa o Record Type demostrada. No requiere cambio técnico en el bloque 7; su ejecución requiere regresión posterior.

## Candidatos técnicos

No se encontró ningún componente que reúna simultáneamente asignación PEKING inequívoca, ausencia de drift, independencia de perfiles pendientes y prueba aislable. Por ello no se crea `PROPUESTA_LOTE_B7_1_UI_20260806.md`.

## Bloqueados por asignación funcional

Hay 63 componentes bloqueados:

| Tipo | Cantidad | Motivo dominante |
|---|---:|---|
| Layouts | 40 | No existe evidencia suficiente para escoger entre variantes legacy o asignarlas a PEKING |
| FlexiPages | 19 | No hay activación PEKING demostrada o existe una mezcla de default y Record Type que requiere decisión |
| Quick Actions | 4 | La exposición o el proceso funcional objetivo no permite afirmar aplicabilidad PEKING |

La lista nominal está en la matriz B7-0. No se inventaron asignaciones, visibilidad, perfiles ni páginas nuevas.

### Opportunity Record Page VN

La matriz de activaciones contiene 1,200 asignaciones `APP_PROFILE_RECORDTYPE` para Record Types legacy, pero ninguna para Omoda o Jaecoo. Esta ausencia por sí sola no autoriza copiar asignaciones de BMW/MINI: hace falta definir aplicación y perfil.

## Dependencias Diego

Ningún componente quedó clasificado directamente como `DEPENDENCIA_DIEGO`. En los componentes bloqueados, primero falta decidir qué Layout/FlexiPage corresponde. La futura asignación de los perfiles que Diego creará será una dependencia posterior, no una razón para seleccionar ahora un componente arbitrario.

## Drift

`Opportunity_Record_Page_VN` queda `DRIFT_REQUIERE_CONCILIACION`.

- Git y Partial existen.
- Partial contiene adicionalmente `Opportunity.Plan_del_cliente_save_PDF`.
- El drift no fue conciliado ni modificado en B7-0.
- Además, no existe activación Omoda/Jaecoo demostrada.

Antes de cualquier cambio debe resolverse el drift en un lote técnico separado y obtener la asignación funcional correspondiente.

## No aplica

- `Opportunity_Record_Page_VU`
- `Quote_Record_Page_VU`
- `Estadisticas_Inventario_Usados`
- `Ver_Inventario_Vehiculos_Usados`

La evidencia las identifica como páginas exclusivas de usados. Luis confirmó que PEKING no aplica a usados. Se conserva obligación de regresión para evitar impacto, sin adaptación PEKING.

## Quick Actions revisadas

| Acción | Resultado | Razón |
|---|---|---|
| `BMW_EnviarCorreoPresupuesto` | Bloqueada | Identidad, plantilla y remitente PEKING pendientes |
| `Quote.BMW_Duplicar_Partidas_de_Presupuesto` | Sin cambio | Exposición genérica demostrada |
| `Quote.BMW_ImportarPlantilla` | Bloqueada | Exposición y plantilla/proceso dependiente aún no resueltos |
| `WorkOrder.BMW_CambiarMoneda` | Bloqueada | Sin exposición demostrada y configuración funcional pendiente |
| `WorkOrder.BMW_ImportarPlantilla` | Bloqueada | Exposición parcial y plantilla/proceso pendientes |

## Conclusión

B7-0 queda completado como selección técnica. No existe B7-1 real con la evidencia actual. El siguiente paso no es implementar UI: es resolver la asignación funcional de Layouts/FlexiPages y conciliar `Opportunity_Record_Page_VN` sin sobrescribir su comportamiento vigente.

B9-1 permanece `IMPLEMENTADO_EN_PARTIAL_PENDIENTE_QA_FUNCIONAL` y no fue tocado.

No se consultó ni modificó Salesforce, Partial, Producción ni datos. No hubo retrieve, dry-run ni deploy.
