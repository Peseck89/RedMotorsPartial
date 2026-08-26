# Estado actual — 26-08-2026

## Ventana

- Preparación/validación: miércoles 26 y jueves 27 de agosto.
- Viernes 28: idealmente libre salvo blocker real.
- Deploy: sábado 29, a partir de la 1:00 p. m.
- QA Producción: sábado y/o domingo.
- Lunes 31: negocio en feriado en Costa Rica; María, Diego y QA probarán; nosotros (Claudia + Luis) debemos estar disponibles para corregir incidentes.

## Responsabilidad operativa

Para este go-live, cualquier tarea asignada a **Claudia** o **Luis** se trata como responsabilidad conjunta “nosotros”.

## Estado técnico confirmado previo a la reunión

- Sprint 5 técnicamente cerrado en Partial.
- RQ329 quedó desbloqueado en Partial para QLI; la protección de Quote origen solo consulta continuó funcionando.
- OMODA/JAECOO validados en Partial hasta Work Order.
- `Enviado_a_la_orden__c` corregido y validado en los Flows de Work Order.
- FLS Empresa reconciliado para la población funcional identificada en Partial.
- `Opportunity_Flow_From_Work_Order` reconciliado y activo en v18 en Partial.
- Git de Sprint 5 y Empresa/FLS fue sincronizado 0/0 al cierre de esas tareas.
- Producción no fue modificada durante esos cierres.

## Auditoría Codex posterior

Codex emitió `NO GO` con un inventario candidato de 130 componentes, 276/303 tests PASS y 27 FAIL, sin paquete Copado creado ni Validate Only. Este resultado se conserva como **auditoría previa** y debe reconciliarse con el pase conjunto oficial; no debe usarse como veredicto final ni como inventario único.

## Estado del pase conjunto

Todavía no se declara GO. El gate real exige, como mínimo:

- inventario conjunto reconciliado;
- dependencias PEKING/Jerarquización reconciliadas;
- QA Partial asignado a nosotros suficientemente completado;
- paquetes Copado preparados en el orden acordado;
- tests realmente requeridos identificados y en estado aceptable;
- Validate Only verde contra Producción;
- data de Producción documentada/scriptable;
- revisión de Diego donde corresponda;
- plan de backup/rollback listo.
