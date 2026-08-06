# Resumen de corrección — Sprint 3

El plan anterior utilizó una versión incompleta del documento de alcance. La versión actualizada incorpora una tabla consolidada que cambia la distribución: no todo el trabajo declarativo o de cierre pertenece automáticamente a Sprint 3.

## Distribución correcta

Sprint 3 contiene explícitamente:

- bloque 7: Layouts, FlexiPages y Quick Actions;
- bloque 9: Validation Rules, Approval Processes y roles nuevos;
- bloque 11: Custom Metadata e integración Softland configurable.

No tienen Sprint escrito:

- bloque 8: List Views;
- bloque 12: Global Value Sets;
- bloque 13: Pricebooks y PricebookEntry;
- bloque 14: E2E y regresión.

Permanecen en Sprint 1 el objeto Empresa, Apex, triggers y la validación de campos, picklists y Record Types. Permanecen en Sprint 2 los Flows y LWC/Aura, incluidos los cinco Flows todavía bloqueados.

El bloque amplio de Profiles y Permission Sets está marcado NA. Los procesos exclusivos de usados no aplican a PEKING.

## Decisiones posteriores

La duda sobre una nueva instancia Softland quedó resuelta: se utilizarán la instancia y endpoints existentes con contexto RMPEKING. No deben inventarse bodegas, catálogos, precios, monedas, roles, aprobadores ni permisos.

## Primer lote

El primer lote es S3-0: conciliación de los tres bloques explícitos. Solo inventaría y compara en modo lectura; no modifica Salesforce.

No existe todavía un lote autorizado o listo para implementación. Primero deben cerrarse el inventario nominal, las asignaciones, los estados activos, la aplicabilidad PEKING y los bloqueos funcionales.

El plan anterior y su matriz preliminar se conservan únicamente para trazabilidad.
