# Resultado QA funcional B9-1

**Fecha:** 7 de agosto de 2026

**Estado:** `B9-1 — QA_FUNCIONAL_PARCIAL`

## Alcance

Se validaron exclusivamente estas cuatro Validation Rules de Opportunity:

1. `Opportunity.Cambiar_a_Finalizado_Descuento`
2. `Opportunity.Cambiar_a_Finalizado_Formalizacion`
3. `Opportunity.Cambiar_Oportunidad_a_Finalizado_VH`
4. `Opportunity.Campo_Gustos_y_aficiones_Obligatorio`

No se ejecutaron procesos completos de Quote, Work Order, reserva, inventario, Softland o facturación.

## Preflight de seguridad

El usuario técnico de la org tiene perfil administrador y las cuatro reglas contienen excepciones para administrador. Por ello se descartó DML directo o Execute Anonymous: habría producido evidencia funcional inválida.

La inspección de solo lectura identificó:

- siete triggers Apex activos sobre Opportunity;
- 21 Flows activos con inicio record-triggered sobre Opportunity;
- 20 Workflow Rules de Opportunity, todas inactivas;
- automatizaciones capaces de enviar correo, crear registros o invocar Apex, pero condicionadas a cambios distintos de los escenarios B9-1, como Cerrada Ganada/Perdida, descuento aprobado, notificación de reserva o Test Drive.

La prueba se aisló en contexto Apex `@IsTest` con un usuario de perfil no administrador. Los datos ficticios se generaron con el prefijo `QA_PEKING_B9_1_20260807`; el contexto de prueba revirtió automáticamente todas las transacciones y no ejecutó efectos externos reales.

## Evidencia técnica

La última validación dirigida fue:

| Evidencia | Resultado |
|---|---|
| Validation ID | `0AfAK0000012Ah30AE` |
| Clase temporal evaluada | `B9_1_ValidationRulesFunctionalTest` |
| Compilación | Exitosa; 0 errores de componente |
| Métodos | 5 solicitados; 4 aprobados y 1 fallido |
| Metadata desplegada | Ninguna; fue un dry-run |

La clase temporal no se conservó ni se desplegó porque una aserción funcional falló. La evidencia reproducible queda en el Validation ID y en la matriz siguiente.

## Resultados por regla

| Regla | Omoda positivo | Omoda negativo | Jaecoo positivo | Jaecoo negativo | BMW regresión | Estado |
|---|---|---|---|---|---|---|
| `Cambiar_a_Finalizado_Descuento` | PASS | PASS; bloqueó con el mensaje esperado | PASS | PASS; bloqueó con el mensaje esperado | PASS positivo y negativo | `QA_FUNCIONAL_COMPLETADO` |
| `Cambiar_a_Finalizado_Formalizacion` | PASS | PASS; bloqueó con el mensaje esperado | PASS | PASS; bloqueó con el mensaje esperado | PASS positivo y negativo | `QA_FUNCIONAL_COMPLETADO` |
| `Cambiar_Oportunidad_a_Finalizado_VH` | PASS con booleano test-only; sin reserva real | PASS; bloqueó con el mensaje esperado | PASS con booleano test-only; sin reserva real | PASS; bloqueó con el mensaje esperado | PASS positivo y negativo | `QA_DE_VALIDATION_RULE_COMPLETADO`; no E2E |
| `Campo_Gustos_y_aficiones_Obligatorio` | PASS positivo | **FAIL:** permitió Oferta con el campo vacío | BLOQUEADO_NO_EJECUTADO tras la aserción fallida | BLOQUEADO_NO_EJECUTADO | BLOQUEADO_NO_EJECUTADO | `QA_FUNCIONAL_FALLIDO` |

Conteo de escenarios regla/Record Type:

- PASS: 19.
- FAIL: 1.
- BLOQUEADOS/NO EJECUTADOS: 4.

## Valores mínimos utilizados

- Record Types: Omoda, Jaecoo y BMW exclusivamente para regresión legacy.
- Empresa test-only: código ERP `RMPEKING` y nombre con el prefijo autorizado.
- Etapas: `Oportunidad Calificada`, `Finalizado` y `Oferta`.
- Descuento: `Aprobador__c=Gerente`, aprobado/no aprobado según el escenario y no rechazado.
- Formalización: booleano true/false según el escenario.
- Vehículo reservado: booleano test-only true/false; no se creó reserva, vehículo, VIN, producto o inventario.
- Gusto y aficiones: un valor activo existente para el positivo y valor realmente vacío para el negativo.
- Test Drive: valor existente `No`, utilizado únicamente para satisfacer otra Validation Rule activa.
- Regresión BMW: valor de bodega ya definido por la Validation Rule legacy; no se creó ni modificó una bodega.

## Hallazgo funcional

`Campo_Gustos_y_aficiones_Obligatorio` permitió que una Opportunity Omoda pasara a Oferta aunque la Account relacionada conservaba `Gusto_y_aficiones__c` vacío. La precondición de cuenta vacía se comprobó antes del update. El resultado esperado era el mensaje:

> Para pasar a "Oferta" por favor llenar el campo “Gusto y aficiones” que se encuentra en la sección "Otra información" de la cuenta.

No se modificó la regla para investigar o corregir la causa. Antes de completar B9-1 se requiere autorizar un análisis técnico específico de esa fórmula y repetir Omoda, Jaecoo y regresión legacy.

## Limpieza y efectos externos

Consultas posteriores confirmaron:

- Opportunities QA persistentes: 0.
- Accounts QA persistentes: 0.
- Empresas QA persistentes: 0.
- Users QA persistentes: 0.
- Vehículos/VINes QA: no creados.
- Clase temporal desplegada: 0.
- Jobs activos o pendientes: 0.
- Correos enviados: ninguno.
- Callouts reales: ninguno.
- Reservas, pedidos o aprobaciones: ninguno.

## Conclusión

B9-1 no puede pasar a `QA_FUNCIONAL_COMPLETADO`. Tres reglas tienen evidencia positiva, negativa y de regresión suficiente a nivel de Validation Rule. `Campo_Gustos_y_aficiones_Obligatorio` conserva un fallo funcional y escenarios pendientes.

Sprint 3 no se declara cerrado.
