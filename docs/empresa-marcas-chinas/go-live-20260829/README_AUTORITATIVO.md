# Go-Live RedMotors 29-08-2026 — Contexto autoritativo

## Propósito

Este directorio es la fuente durable de contexto para preparar y ejecutar el pase conjunto a Producción de:

- Proyecto A: Jerarquización de Roles, Consolidación de Perfiles, Visibilidad (OWD) y refactor a Custom Permissions.
- Proyecto B: Empresa / Marcas Chinas PEKING — OMODA / JAECOO.

La ventana prevista es el sábado 29 de agosto de 2026 a partir de la 1:00 p. m. El objetivo inmediato es dejar el pase preparado y validado entre miércoles 26 y jueves 27, liberando el viernes salvo blocker real.

## Regla principal

**Ningún agente debe modificar Producción basándose únicamente en memoria de conversación, memoria del modelo, un resumen previo o una inferencia.**

Antes de cualquier tarea del go-live, Code/Codex/Claude debe leer, en este orden:

1. `README_AUTORITATIVO.md`
2. `ESTADO_ACTUAL.md`
3. `REGLAS_PRODUCCION.md`
4. `FUENTES_Y_PRECEDENCIA.md`
5. `PLAN_TRABAJO_20260826_20260831.md`
6. `RESPONSABILIDADES_Y_QA.md`
7. `CONTRADICCIONES_Y_GATES.md`
8. la fuente original específica relacionada con la tarea dentro de `sources/originals/`

Para modificaciones técnicas también debe ejecutar el precheck de `AGENT_PRECHECK.md`.

## Principio fail-closed

Si un agente no puede leer estas fuentes, no puede verificar el ambiente, o encuentra una contradicción entre fuentes que cambia alcance, datos, seguridad, orden de despliegue o comportamiento productivo, debe **detener la mutación** y reportar la contradicción. No debe escoger silenciosamente una interpretación.

## Qué es autoritativo y qué no

Las instrucciones del 26/08/2026 y sus aclaraciones posteriores prevalecen sobre cierres históricos cuando redefinen el go-live. El reporte de Codex `NO GO` es una auditoría técnica previa que debe reconciliarse; **no es el veredicto final ni el inventario oficial por sí solo**.

## Fuente integrada

La reunión y el Plan de Pase indican que Partial contiene cambios fusionados de ambos proyectos. No se debe fabricar una versión “solo PEKING” o “solo Jerarquización” des-fusionando manualmente archivos compartidos que no hayan existido ni sido probados así.

## Actualización de este contexto

Toda decisión nueva de María, Diego, Luis, Sandra, QA o negocio que cambie el pase debe registrarse en `DECISION_LOG.md` con fecha/hora, fuente y efecto. No borrar decisiones anteriores: marcar `SUPERSEDED` cuando corresponda.
