# Resumen de preparación — Sprint 3

Sprint 3 puede comenzar con el alcance original de PortalNet, tal como autorizó Luis. El inicio no significa que Sprint 2 esté cerrado: siguen pendientes cinco Flows de postventa y esas correcciones no se incorporan a este plan.

## Qué incluye el alcance original

El alcance pendiente se concentra en layouts, páginas Lightning, acciones rápidas, vistas, accesos, Custom Metadata, Softland, valores globales, Pricebooks, entradas de precio y pruebas E2E/regresión. La matriz también inventaría Validation Rules y Approval Processes porque pueden afectar la separación por Empresa, pero el documento inicial no enumera reglas ni procesos concretos que deban crearse.

## Qué ya está cubierto

Ya existen y fueron atendidos los Record Types Omoda/Jaecoo, la página 'Opportunity_Record_Page_VN', ocho vistas de Opportunity, los mappings Lead→Opportunity, campos y permisos base de Empresa y la resolución dinámica Empresa–Pricebook. Estos elementos requieren evidencia o regresión, no una segunda implementación.

Los recursos exclusivos de vehículos usados quedan fuera de la adaptación PEKING.

## Qué puede iniciar

Puede comenzar de inmediato un inventario dirigido de layouts, FlexiPages, Quick Actions, List Views, Validation Rules, Approval Processes y accesos. También puede validarse lo ya desplegado y preparar la regresión técnica con escenarios negativos.

El primer lote recomendado es **S3-0 — Inventario y conciliación declarativa**. No modifica Salesforce y deja una lista exacta de diferencias antes de autorizar cambios.

## Qué está bloqueado

Siguen faltando definiciones oficiales de experiencia de Account y Quote por Empresa; plantillas, remitente, identidad legal y logos; moneda, productos, precios y catálogos; bodegas y configuración Softland; sucursales, territorios, talleres y acceso; servicios, garantías, aprobadores y reglas de postventa.

Sin estas decisiones no deben configurarse PricebookEntry, variantes de Work Order, accesos ni aprobaciones.

## Qué es ampliación no autorizada

Las reglas detalladas del requerimiento v0.13 —inmutabilidad, derivación, auditoría, seguridad ampliada, reproceso, notificaciones, carga inicial, conciliación, UAT/Go-No-Go formal y mejora transversal de productos— no entran automáticamente a Sprint 3. La diferenciación de “trabajos a realizar” por Empresa también queda fuera porque el documento inicial la señala como adicional.

## Evidencia que debe producirse

Cada frente necesita inventario nominal, comparación Git–Partial, asignaciones, pruebas por perfil QA, escenarios positivos y negativos, regresión Bavarian/Otobai/PEKING y videos de los recorridos aprobados. Los datos positivos deben ser oficiales; no se deben crear Opportunities ni configuración comercial artificial para completar evidencia.

Sprint 3 solo podrá cerrarse cuando todo el alcance original haya sido revisado y sustentado, incluso cuando la conclusión de una fila sea “sin cambio”, “completado previamente”, “no aplica” o “bloqueado”.
