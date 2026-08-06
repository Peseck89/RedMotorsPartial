# Propuesta del primer lote funcional — Sprint 3

**Estado: CANDIDATO_PENDIENTE_APROBACION**

## Resultado de la evaluación

No se identificó todavía un conjunto de cambios funcionales que cumpla simultáneamente todas las condiciones para iniciar implementación. Los candidatos funcionales dependen de asignaciones no demostradas, criterios de negocio o configuración técnica pendiente.

## Única conciliación técnica aislable

| Componente | Motivo | Cambio potencial | Riesgo | Dependencia | Validación | Evidencia | Reversión |
|---|---|---|---|---|---|---|---|
| Opportunity_Record_Page_VN | Git y Partial difieren en una Quick Action; Partial representa el estado actual del ambiente. | Conciliar en Git la acción `Opportunity.Plan_del_cliente_save_PDF`, sin alterar visibilidad ni lógica PEKING. | Bajo a medio: una recuperación incorrecta podría eliminar contenido vigente o introducir metadata no revisada. | Confirmar asignación activa y aprobar la conciliación como base técnica. | Diff semántico, validación estructural y revisión de la página por Record Type. | Retrieve temporal y diff Git–Partial del 6 de agosto de 2026. | Restaurar la versión Git previa o el respaldo temporal de Partial. |

Esta conciliación no constituye un lote funcional PEKING y no está autorizada para ejecución. Su objetivo sería establecer una base versionada correcta antes de proponer cualquier cambio funcional.

## Condiciones para proponer el primer lote funcional real

- resolver las asignaciones activas de layouts y páginas;
- confirmar política de descuentos y aprobadores PEKING;
- definir el default VN escalable sin nombres fijos;
- confirmar identidad, moneda, plantillas y catálogos aplicables;
- identificar el mecanismo autoritativo de configuración Softland sin exponer secretos;
- volver a presentar los componentes nominales elegibles para aprobación.
