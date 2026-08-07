# Resultado de corrección B9-1 — Gustos y aficiones

Fecha: 2026-08-07  
Org: Partial (`RedMotorsSandbox`)  
Componente: `Opportunity.Campo_Gustos_y_aficiones_Obligatorio`  
Estado: `B9-1 — QA_FUNCIONAL_COMPLETADO`

## Alcance ejecutado

Se modificó exclusivamente la fórmula de esta Validation Rule en dos puntos previamente validados:

1. El bypass nulo ahora permite que la regla continúe evaluándose; un bypass futuro conserva la excepción.
2. El vacío real de `Account.Gusto_y_aficiones__c` se evalúa mediante `TEXT(Account.Gusto_y_aficiones__c) = ""`.

No se modificaron las comparaciones de Record Type, las demás excepciones, el mensaje, la activación ni ninguna otra Validation Rule. `Por actualizar` continúa siendo un valor permitido.

## Trazabilidad de ejecución

| Paso | ID | Resultado |
|---|---|---|
| Retrieve baseline | `09SAK000003IOOj2AO` | Git y Partial equivalentes antes del cambio. |
| Check-only con 15 escenarios | `0AfAK0000012CUL0A2` | 15/15 aprobados; 0 errores. |
| Dry-run dirigido de la regla | `0AfAK00000126vC0AQ` | Exitoso; 1/1 componente. |
| Deploy dirigido | `0AfAK0000012CZB0A2` | Exitoso; únicamente la Validation Rule. |
| Retrieve posterior | `09SAK000003IG1R2AW` | Equivalencia exacta Git–Partial. |
| QA posterior al deploy | `0AfAK0000012CcP0AU` | 15/15 aprobados; 0 errores. |

## Matriz de QA final

| Record Type | `null` | Valor real |
|---|---|---|
| Omoda | BLOQUEA | PERMITE |
| Jaecoo | BLOQUEA | PERMITE |
| BMW | BLOQUEA | PERMITE |
| MINI | BLOQUEA | PERMITE |
| Kawasaki | BLOQUEA | PERMITE |
| Motorrad | BLOQUEA | PERMITE |
| Polaris | BLOQUEA | PERMITE |

Escenario adicional: Omoda con `Por actualizar` permite la transición a `Oferta`.

## Controles

- La prueba se ejecutó con clases temporales en check-only; no quedaron desplegadas.
- Los registros de prueba fueron creados dentro de `@IsTest` y revertidos automáticamente.
- No se modificaron datos reales.
- No se consultó ni modificó Producción.
- No se ejecutó ningún refactor adicional.
- La cobertura Apex no aplica a una Validation Rule; la evidencia funcional son los 15 escenarios dirigidos.

## Resultado

El defecto que permitía pasar a `Oferta` con el campo realmente en `null` quedó corregido y validado en Partial. Las rutas con valor real y con `Por actualizar` conservaron su comportamiento autorizado.

Estado final: `B9-1 — QA_FUNCIONAL_COMPLETADO`.
