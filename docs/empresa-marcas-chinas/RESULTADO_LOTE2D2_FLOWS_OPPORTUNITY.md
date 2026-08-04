# Resultado Lote 2D2 — Flows de Opportunity

Fecha: 4 de agosto de 2026  
Ambiente: Salesforce Partial

## Alcance ejecutado

El sublote incluyó exclusivamente:

- Opp_Flow_V5, tomando como base funcional la versión activa 29.
- Opp_Flow_v6, tomando como base funcional la versión activa 79.

Los borradores que ocupaban los números 30 y 80 no se utilizaron como base. No se modificaron otros Flows, componentes, procesos de usados o despacho.

## Resultado

| Flow | Versión base | Versión activa resultante | Estado |
|---|---:|---:|---|
| Opp_Flow_V5 | 29 | 30 | Desplegado y activo |
| Opp_Flow_v6 | 79 | 80 | Desplegado y activo |

Las versiones resultantes reutilizan la numeración que tenían los borradores descartados, pero su contenido proviene de las versiones activas autorizadas 29 y 79 más los cambios descritos en este documento.

## Comportamiento implementado

### Empresa

- Las pantallas aplicables usan un lookup obligatorio basado en Opportunity.Empresa_Operadora__c.
- La Empresa seleccionada se persiste en Empresa_Operadora__c de la Opportunity.
- Opp_Flow_v6 exige la selección en sus rutas principal y de mostrador.
- BMW_Compania__c queda como compatibilidad temporal y solo recibe Bavarian u Otobai cuando el nombre coincide exactamente.
- PEKING y cualquier valor desconocido no se asignan al campo legacy ni caen por defecto en otra Empresa.

### Pricebook

- Ambos Flows invocan EmpresaPricebookResolver con Empresa, moneda y Pricebook actual.
- La consulta y las actualizaciones usan el Id devuelto por el resolver, no un nombre o Id fijo.
- EXITO conserva la continuación funcional vigente.
- NO_CONFIGURADO, SELECCION_REQUERIDA y ERROR muestran un mensaje controlado y detienen la ruta antes de continuar con un Pricebook2Id nulo o ambiguo.
- Las rutas no relacionadas con Empresa o Pricebook se conservaron.

## Validaciones y pruebas

- XML bien formado para ambos Flows.
- Validación estructural de metadata exitosa para los dos componentes.
- Dry-run exitoso: 0AfAK0000010RpG0AU.
- Pruebas de EmpresaPricebookResolver: 19 de 19 aprobadas, sin fallos.
- Cobertura vigente de EmpresaPricebookResolver: 97.9% (137 líneas cubiertas y 3 no cubiertas), conforme a la ejecución de dependencias compartidas.
- Deploy exitoso a Partial: 0AfAK0000010Smx0AE.
- Consulta posterior: Opp_Flow_V5 v30 y Opp_Flow_v6 v80 están activos.

La validación informó secciones legacy desconectadas de la antigua selección nominal de Pricebook. No pertenecen a una ruta ejecutable. Su eliminación física queda como limpieza posterior para no ampliar el cambio funcional autorizado.

## Escenarios cubiertos por pruebas relacionadas

- Lookup principal para PEKING sin fallback legacy.
- Compatibilidad controlada para Bavarian y Otobai.
- Empresa nula, inexistente o inactiva.
- Pricebook inexistente, inactivo o perteneciente a otra Empresa.
- Una opción válida y varias opciones válidas.
- Valor legacy desconocido sin selección de Empresa por defecto.

## Pendientes funcionales

- Ejecutar ambos Flows desde sus entradas reales con perfiles QA autorizados.
- Validar Bavarian, Otobai y PEKING con datos comerciales oficiales.
- Confirmar que sucursal, cuenta, territorio y respuestas Softland conservan el comportamiento previo.
- Validar mensajes de configuración ausente y selección ambigua.
- Confirmar regresión integral de las versiones base 29 y 79.

No se crearon datos para completar estos escenarios.

## Videos requeridos

1. Opp_Flow_V5: selección explícita, creación de Opportunity y Quote, y evidencia de Empresa_Operadora__c y Pricebook2Id.
2. Opp_Flow_v6 ruta principal: selección explícita y Pricebook resultante.
3. Opp_Flow_v6 ruta mostrador: selección explícita y Pricebook resultante.
4. Caso negativo con Empresa o Pricebook no configurado.
5. Caso con selección ambigua que confirme que no se elige un Pricebook arbitrariamente.

## Confirmaciones de alcance

- Solo se desplegaron los dos Flows de 2D2 en Salesforce Partial.
- No se modificaron Apex, LWC/Aura, datos ni recursos excluidos.
- Producción no fue consultada ni modificada.
- No se inició ningún sublote posterior.
