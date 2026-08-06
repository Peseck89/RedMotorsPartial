# Resultado B9-1 — Validation Rules de Opportunity

**Fecha:** 6 de agosto de 2026

**Estado:** `B9-1 — IMPLEMENTADO_EN_PARTIAL_PENDIENTE_QA_FUNCIONAL`

## Objetivo

Extender a los Record Types Omoda y Jaecoo exactamente cuatro Validation Rules existentes de Opportunity, conservando sin rediseño el comportamiento vigente de los Record Types legacy.

## Componentes

1. `Opportunity.Cambiar_a_Finalizado_Descuento`
2. `Opportunity.Cambiar_a_Finalizado_Formalizacion`
3. `Opportunity.Cambiar_Oportunidad_a_Finalizado_VH`
4. `Opportunity.Campo_Gustos_y_aficiones_Obligatorio`

## Baseline

Las cuatro reglas fueron recuperadas individualmente desde `RedMotorsSandbox` a un proyecto temporal externo al repositorio. Se verificaron `fullName`, `active`, `errorConditionFormula`, `errorMessage`, ausencia de `errorDisplayField` y demás propiedades presentes.

El baseline coincidió semánticamente con la evidencia B9-0.1: cuatro reglas activas, sin Omoda ni Jaecoo y sin drift material. Se versionó y publicó en un checkpoint técnico separado antes de la modificación.

El retrieve previo al deploy se demoró y agotó tiempo. Como control complementario de solo lectura, Tooling API confirmó las cuatro reglas activas y con `LastModifiedDate` anterior al baseline; por tanto no existía una modificación posterior al checkpoint. No se sobrescribió ningún archivo con ese control.

## Cambio conceptual aplicado

| Regla | Mecanismo conservado | Ajuste exclusivo |
|---|---|---|
| `Cambiar_a_Finalizado_Descuento` | `$RecordType.DeveloperName` dentro del mismo `OR` BMW/MINI | Se agregaron Omoda y Jaecoo |
| `Cambiar_a_Finalizado_Formalizacion` | `$RecordType.DeveloperName` dentro del mismo `OR` BMW/MINI | Se agregaron Omoda y Jaecoo |
| `Cambiar_Oportunidad_a_Finalizado_VH` | `$RecordType.DeveloperName` dentro del mismo `OR` BMW/MINI | Se agregaron Omoda y Jaecoo |
| `Campo_Gustos_y_aficiones_Obligatorio` | `RecordType.Name` dentro de la misma cadena de alternativas legacy | Se agregaron Omoda y Jaecoo |

No cambiaron perfiles, excepciones Admin, campos, umbrales, mensajes, `errorDisplayField`, estado activo ni comportamiento legacy.

## Dry-run

- Org: `RedMotorsSandbox`.
- ID: `0AfAK0000011gB70AI`.
- Estado: `Succeeded`.
- Componentes: 4 de 4 Validation Rules.
- Errores de componente: 0.
- Pruebas Apex: no aplicables al paquete; 0 ejecutadas, 0 fallos.
- Warnings funcionales: ninguno reportado.

## Deploy a Partial

- Org: `RedMotorsSandbox`.
- ID: `0AfAK0000011gCj0AI`.
- Timestamp de finalización: `2026-08-06T22:35:36Z`.
- Estado: `Succeeded`.
- Componentes desplegados: 4 de 4.
- Errores de componente: 0.
- Pruebas Apex: no aplicables al paquete; 0 ejecutadas, 0 fallos.

No se incluyó Opportunity completo, Record Types, Profiles, Permission Sets ni otra metadata.

## Verificación post-deploy

El retrieve posterior fue exitoso con ID `09SAK000003GhKD2A0`. La comparación semántica contra Git confirmó equivalencia 4/4:

- Omoda y Jaecoo incluidos una vez en la condición correspondiente;
- BMW y MINI conservados;
- Kawasaki, Motorrad y Polaris conservados donde ya existían;
- `active=true` conservado;
- mensajes conservados;
- ausencia de `errorDisplayField` conservada;
- excepciones de Profile/Admin y demás campos sin cambios.

## QA técnico

`COMPLETADO`

- XML válido y parseable.
- Diff limitado a las condiciones de Record Type.
- Dry-run exitoso.
- Deploy exitoso.
- Retrieve posterior equivalente.
- Sin drift post-deploy.

## QA funcional

`QA_FUNCIONAL_PENDIENTE`

No se crearon ni modificaron oportunidades o datos de negocio. Quedan pendientes estos escenarios seguros con registros QA autorizados:

| Regla | Positivo | Negativo | Regresión |
|---|---|---|---|
| `Cambiar_a_Finalizado_Descuento` | Omoda/Jaecoo finaliza cuando cumple la aprobación vigente | Bloquea cuando no la cumple | BMW/MINI |
| `Cambiar_a_Finalizado_Formalizacion` | Omoda/Jaecoo finaliza con formalización enviada | Bloquea sin formalización | BMW/MINI |
| `Cambiar_Oportunidad_a_Finalizado_VH` | Omoda/Jaecoo finaliza con vehículo reservado conforme a la regla | Bloquea sin la condición vigente | BMW/MINI |
| `Campo_Gustos_y_aficiones_Obligatorio` | Omoda/Jaecoo avanza con el dato requerido | Bloquea cuando corresponde y falta el dato | BMW/MINI/Kawasaki/Motorrad/Polaris |

`Cambiar_Oportunidad_a_Finalizado_VH` conserva riesgo alto hasta completar la prueba funcional.

## Riesgos y pendientes

- El éxito técnico no demuestra comportamiento funcional con registros reales.
- Falta evidencia positiva, negativa y de regresión para las cuatro reglas.
- No debe declararse B9-1 completado, cerrado ni validado funcionalmente hasta obtener esa evidencia.
- Los bloqueos de las otras Validation Rules no forman parte de B9-1 y permanecen sin cambios.

## Seguridad de alcance

- Solo se utilizó `RedMotorsSandbox`.
- Producción no fue consultada ni modificada.
- No se modificaron datos, perfiles, jerarquía, Approval Processes, Flows, Apex, LWC/Aura ni Custom Metadata.
- No se modificó ninguna Validation Rule fuera de las cuatro autorizadas.
- Sprint 3 no fue ampliado.
