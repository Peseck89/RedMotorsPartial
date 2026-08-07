# Plan de QA funcional B9-1

**Fecha:** 6 de agosto de 2026

**Estado:** `DATOS_QA_NO_DISPONIBLES`

Las cuatro Validation Rules están implementadas y técnicamente verificadas en Partial. Este plan no autoriza crear o modificar Opportunities. Una consulta de solo lectura no encontró registros Omoda/Jaecoo inequívocamente identificados como QA, TEST o PRUEBA; una coincidencia nominal tampoco habría demostrado autorización de uso.

## Precondiciones comunes

- Opportunity QA proporcionada o creada por el flujo funcional autorizado, con Record Type Omoda o Jaecoo.
- Empresa PEKING explícita y datos comerciales completos provistos por negocio.
- Perfil QA no administrador, con permisos funcionales confirmados.
- Caso comparable BMW o MINI autorizado para regresión.
- Captura previa y posterior con Record Type, etapa y campos determinantes visibles, sin exponer datos sensibles.

## Matriz ejecutable

| Validation Rule | Escenario positivo | Escenario negativo | Regresión BMW/MINI | Datos mínimos y campos | Resultado esperado | Evidencia requerida |
|---|---|---|---|---|---|---|
| `Opportunity.Cambiar_a_Finalizado_Descuento` | Finalizar Omoda y Jaecoo con aprobación vigente satisfecha | Intentar finalizar con `Aprobador__c` informado y distinto de Vendedor, pero `DescuentoAprobado__c=false` o `Descuento_rechazado__c=true` | Repetir ambos casos en BMW y MINI | `StageName`, `Aprobador__c`, `DescuentoAprobado__c`, `Descuento_rechazado__c`, Record Type | Guarda cuando cumple; bloquea con el mensaje vigente cuando incumple | Video de ambos Record Types PEKING y regresión; captura del mensaje y valores determinantes |
| `Opportunity.Cambiar_a_Finalizado_Formalizacion` | Finalizar con `Envio_formalizacion_legal__c=true` | Intentar finalizar con `Envio_formalizacion_legal__c=false` | Repetir en BMW y MINI | `StageName`, `Envio_formalizacion_legal__c`, Record Type | Guarda con formalización; bloquea sin ella | Video positivo/negativo y regresión; captura del mensaje |
| `Opportunity.Cambiar_Oportunidad_a_Finalizado_VH` | Finalizar con `Tiene_Vehiculos_Reservados__c=true` y reserva obtenida por el proceso real | Intentar finalizar con `Tiene_Vehiculos_Reservados__c=false` | Repetir en BMW y MINI | `StageName`, `Tiene_Vehiculos_Reservados__c`, Record Type; vehículo/reserva QA autorizados | Guarda con reserva válida; bloquea sin ella | Video del proceso real de reserva y del bloqueo; trazabilidad del registro QA autorizado |
| `Opportunity.Campo_Gustos_y_aficiones_Obligatorio` | Pasar a Oferta con `Account.Gusto_y_aficiones__c` informado | Pasar a Oferta con el campo vacío y sin bypass vigente | Repetir en BMW y MINI; conservar Kawasaki/Motorrad/Polaris si existe caso autorizado | `StageName=Oferta`, `Account.Gusto_y_aficiones__c`, `Bypass_CheckIn_Validations_Until__c` y campos excluidos de cambios, Record Type | Guarda con dato; bloquea sin dato cuando corresponde | Video positivo/negativo, captura del Account y regresión |

## Controles negativos

- Un perfil administrador puede quedar exceptuado por la fórmula vigente; no usarlo como única evidencia.
- No alterar el bypass para forzar un resultado.
- No reutilizar una Opportunity real sin autorización inequívoca.
- No considerar suficiente una captura aislada: debe verse la transición intentada y el resultado.

## Criterio de terminado

B9-1 puede pasar de pendiente QA únicamente cuando existan evidencia positiva, negativa y de regresión para las cuatro reglas, usando registros y perfiles QA autorizados. El éxito técnico ya registrado no sustituye esta validación funcional.
