# Propuesta B9-1 — Validation Rules

**Estado:** `CANDIDATO_PENDIENTE_REVISION`

**Fecha:** 6 de agosto de 2026

Este documento propone un lote; no autoriza implementación, baseline, dry-run ni deploy.

## Alcance candidato

| API name | Problema actual | Ajuste conceptual | Razón funcional | Riesgo | Prueba positiva | Prueba negativa | Regresión | Reversión |
|---|---|---|---|---|---|---|---|---|
| `Opportunity.Cambiar_a_Finalizado_Descuento` | La condición enumera BMW y MINI; Omoda/Jaecoo quedan fuera | Incluir los Record Types PEKING en la misma condición | Diego confirmó paridad de reglas; la excepción Admin es genérica | Medio: bloqueo incorrecto de etapa/descuento | Omoda/Jaecoo finaliza cuando cumple aprobación | Debe bloquear cuando el descuento no cumple | BMW y MINI; Admin/no Admin | Restaurar fórmula y estado previos |
| `Opportunity.Cambiar_a_Finalizado_Formalizacion` | La condición enumera BMW y MINI | Incluir Omoda/Jaecoo sin cambiar el criterio de formalización | Paridad confirmada | Medio: impedir o permitir finalización indebida | Finalizar con formalización enviada | Bloquear sin formalización | BMW y MINI; Admin/no Admin | Restaurar fórmula y estado previos |
| `Opportunity.Cambiar_Oportunidad_a_Finalizado_VH` | La condición enumera BMW y MINI | Incluir Omoda/Jaecoo sin cambiar el criterio de reserva | Paridad confirmada; reservas operan por Empresa enviada | Alto: finalizar sin vehículo reservado | Finalizar con vehículo reservado | Bloquear sin vehículo reservado | BMW y MINI; Admin/no Admin | Restaurar fórmula y estado previos |
| `Opportunity.Campo_Gustos_y_aficiones_Obligatorio` | Enumera cinco Record Types legacy y omite Omoda/Jaecoo | Incluir los dos Record Types en la misma obligatoriedad | Paridad confirmada; no requiere valores nuevos | Bajo/medio: bloquear captura incompleta o flujo válido | Oferta Conquista con dato informado | Bloquear Oferta Conquista sin dato | Cinco Record Types legacy; Admin/no Admin | Restaurar fórmula y estado previos |

## Dependencias y orden

1. Recuperar como baseline interno las cuatro reglas desde Partial fuera del worktree y verificar `fullName`, estado activo y fórmula.
2. Presentar el diff conceptual y seleccionar una construcción técnica única para incluir Omoda/Jaecoo.
3. Incorporar el baseline autorizado al repositorio antes de editar.
4. Modificar únicamente las cuatro reglas.
5. Ejecutar validación estructural, pruebas positivas/negativas y regresión.
6. Realizar dry-run y deploy a Partial solo bajo autorización posterior.

Las cuatro reglas existen en Partial y no estaban versionadas en Git durante S3-0. B9-1 no debe iniciar hasta aprobar el baseline y el lote.

## Criterio de terminado propuesto

- Omoda y Jaecoo reciben exactamente la misma validación que los Record Types legacy indicados.
- La excepción genérica de administradores se conserva.
- No se alteran umbrales, aprobadores, datos, mensajes ni estados de activación.
- Las pruebas positivas, negativas y de regresión pasan en Partial.
- La evidencia identifica la regla y el escenario sin datos sensibles.
