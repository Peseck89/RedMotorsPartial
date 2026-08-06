# Auditoría B9-0.1 — dependencia real de perfiles

**Fecha:** 6 de agosto de 2026

**Estado:** `COMPLETADO_COMO_ANALISIS`

## Alcance y resultado

Se revisaron exclusivamente las 46 Validation Rules que B9-0 había clasificado como `DEPENDENCIA_DIEGO`. No se reabrió el análisis de las otras 48 reglas salvo para conservarlas sin cambios en la matriz V2.

| Tipo de referencia a Profile | Cantidad | Dependencia real de Diego |
|---|---:|---|
| `PROFILE_GENERICO` | 34 | No |
| `PROFILE_FUNCIONAL_ESPECIFICO` | 6 | Sí |
| `PROFILE_ID_ESPECIFICO` | 1 | Sí |
| `MIXTO_PROFILE_ID_Y_RECORDTYPE` | 1 | Sí |
| `MIXTO_PROFILE_GENERICO_Y_RECORDTYPE` | 4 | No |
| **Total revisado** | **46** | **8 dependencias reales** |

Se reclasificaron 38 reglas: 34 referencias genéricas pasaron a `SIN_CAMBIO_REQUIERE_REGRESION` y 4 reglas mixtas pasaron a `CANDIDATO_AJUSTE_TECNICO`. Las 8 dependencias reales de Diego se conservaron.

## Nuevo conteo total

| Clasificación | Cantidad |
|---|---:|
| `SIN_CAMBIO_REQUIERE_REGRESION` | 66 |
| `CANDIDATO_AJUSTE_TECNICO` | 4 |
| `BLOQUEADO_DATOS_OPERATIVOS` | 9 |
| `BLOQUEADO_NEGOCIO` | 4 |
| `DEPENDENCIA_DIEGO` | 8 |
| `NO_APLICA` | 3 |
| **Total** | **94** |

## Dependencias reales de Diego

### Perfiles funcionales específicos — 6

- `Opportunity.Bloquear_Cambio_Owner_Perfiles_Online`: identifica perfiles Online.
- `Product2.Campos_no_editables_por_asesores`: identifica perfiles que contienen “Asesor”.
- `Product2.CamposEditables`: enumera nombres concretos de asesores de ventas Online BMW/MINI.
- `WorkOrder.Etapa_Espera_Taller`: enumera Asesor de Taller y Asistente de Taller.
- `WorkOrder.Etapas_Presupuesto_Aprobacion_y_Listo`: enumera Mecánico Líder, Asesor y Asistente de Taller.
- `WorkOrder.Etapas_Torre_y_Revision`: enumera Mecánico Líder.

### IDs específicos — 2

- `Opportunity.Avoid_opp_owner_change`: combina seis ProfileId fijos con una lista de Record Types legacy; requiere determinar si el perfil PEKING pertenece a las excepciones.
- `WorkOrder.Detalle_de_Estado_Listo`: contiene un ProfileId fijo y requiere resolver la pertenencia del perfil PEKING a esa excepción.

Los identificadores concretos se mantienen omitidos en la documentación. Su presencia fue verificada en la metadata temporal.

## Revisión expresa de cinco reglas

| Validation Rule | Record Types actuales | Referencia Profile | ¿Bloquea Diego? | Decisión funcional | Resultado |
|---|---|---|---|---|---|
| `Opportunity.Avoid_opp_owner_change` | BMW, MINI, Harley-Davidson, Kawasaki, Motorrad y Polaris | Lista de seis ProfileId fijos | Sí | La paridad no define pertenencia a la lista de excepciones | `DEPENDENCIA_DIEGO` |
| `Opportunity.Cambiar_a_Finalizado_Descuento` | BMW y MINI | Exclusión genérica `Profile.Name` contiene Admin | No | La misma validación de descuento fue confirmada; no requiere definir fórmula nueva | `CANDIDATO_AJUSTE_TECNICO` |
| `Opportunity.Cambiar_a_Finalizado_Formalizacion` | BMW y MINI | Exclusión genérica `Profile.Name` contiene Admin | No | La misma exigencia de formalización fue confirmada | `CANDIDATO_AJUSTE_TECNICO` |
| `Opportunity.Cambiar_Oportunidad_a_Finalizado_VH` | BMW y MINI | Exclusión genérica `Profile.Name` contiene Admin | No | La misma exigencia de vehículo reservado fue confirmada | `CANDIDATO_AJUSTE_TECNICO` |
| `Opportunity.Campo_Gustos_y_aficiones_Obligatorio` | BMW, MINI, Kawasaki, Motorrad y Polaris | Exclusión genérica de System Administrator | No | La misma obligatoriedad fue confirmada | `CANDIDATO_AJUSTE_TECNICO` |

Omoda y Jaecoo quedan fuera de las cinco fórmulas actuales. Los Record Types `Opportunity.Omoda` y `Opportunity.Jaecoo` existen, están activos y usan el Sales Process `Autos`, según la metadata versionada y la evidencia del bloque 17. Solo cuatro reglas pueden aislarse; `Avoid_opp_owner_change` sigue bloqueada por sus ProfileId.

## Candidatos técnicos

| Validation Rule | Exclusión actual | Elemento PEKING existente | Dato adicional | Pruebas mínimas |
|---|---|---|---|---|
| `Opportunity.Cambiar_a_Finalizado_Descuento` | Solo BMW/MINI | Record Types Omoda/Jaecoo | Ninguno para extender la misma condición | Finalizado con descuento aprobado/no aprobado; Admin y no Admin; regresión BMW/MINI |
| `Opportunity.Cambiar_a_Finalizado_Formalizacion` | Solo BMW/MINI | Record Types Omoda/Jaecoo | Ninguno | Finalizado con/sin formalización; Admin y no Admin; regresión BMW/MINI |
| `Opportunity.Cambiar_Oportunidad_a_Finalizado_VH` | Solo BMW/MINI | Record Types Omoda/Jaecoo | Ninguno | Finalizado con/sin vehículo reservado; Admin y no Admin; regresión BMW/MINI |
| `Opportunity.Campo_Gustos_y_aficiones_Obligatorio` | BMW/MINI/Kawasaki/Motorrad/Polaris | Record Types Omoda/Jaecoo | Ninguno | Oferta Conquista con/sin dato; Admin y no Admin; regresión de Record Types legacy |

No se define todavía la fórmula final porque puede expresarse mediante varias construcciones técnicamente válidas. La selección conserva exactamente la regla existente y no requiere aprobadores nuevos, centros de costo, garantía, Softland ni datos operativos oficiales.

## Controles

- Mencionar Admin no se trató como dependencia de Diego.
- Las referencias a perfiles funcionales y a ProfileId se evaluaron individualmente.
- Las reglas con datos operativos o decisiones de negocio no se desbloquearon.
- No se modificó Salesforce, metadata ni datos.
- No hubo deploy, dry-run ni consulta a Producción.
