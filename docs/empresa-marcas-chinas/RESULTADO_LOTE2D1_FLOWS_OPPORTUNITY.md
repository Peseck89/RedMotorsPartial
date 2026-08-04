# Resultado Lote 2D1 — Flows de Opportunity

Fecha: 4 de agosto de 2026  
Ambiente: Salesforce Partial

## Alcance ejecutado

El sublote incluyó exclusivamente:

- Opp_flow_V3, tomando como base la versión activa 28.
- Opportunity_Flow_V2, tomando como base la versión activa 6.

No se modificaron los Flows disponibles para 2D2 ni recursos de Work Order, segregación, agenda, servicios, usados, despacho o componentes.

## Resultado

| Flow | Versión anterior | Versión activa resultante | Estado |
|---|---:|---:|---|
| Opp_flow_V3 | 28 | 29 | Desplegado y activo |
| Opportunity_Flow_V2 | 6 | 7 | Desplegado y activo |

## Comportamiento implementado

### Selección de Empresa

- Las pantallas aplicables presentan un lookup obligatorio de Empresa basado en Opportunity.Empresa_Operadora__c.
- La Empresa elegida se persiste explícitamente en la Opportunity.
- Opportunity_Flow_V2 exige selección tanto en la ruta general como en la ruta de mostrador.
- La Empresa seleccionada prevalece sobre User.Empresa__c. El valor del usuario no se usa para sobrescribir el lookup.
- BMW_Compania__c se conserva únicamente como compatibilidad temporal: recibe Bavarian u Otobai cuando el nombre seleccionado coincide exactamente; PEKING y valores desconocidos no se escriben en el campo legacy.

### Resolución de Pricebook

- Después de crear la cotización, ambos Flows invocan EmpresaPricebookResolver con Empresa, moneda y Pricebook actual.
- La consulta del Pricebook usa el Id devuelto por el resolver, no Name ni un identificador fijo.
- EXITO continúa la ruta existente.
- NO_CONFIGURADO, SELECCION_REQUERIDA y ERROR muestran un mensaje controlado y detienen la ruta antes de actualizar Pricebook2Id.
- PEKING no cae por defecto en Bavarian u Otobai.
- Las rutas no relacionadas con Empresa/Pricebook se conservaron.

## Validaciones y pruebas

- XML bien formado y nombres internos únicos.
- Validación de metadata exitosa para los dos Flows.
- Dry-run exitoso: 0AfAK0000010Ryw0AE.
- Pruebas directas de EmpresaPricebookResolver: 19/19 aprobadas.
- Cobertura acumulada de EmpresaPricebookResolver: 137 líneas cubiertas y 3 no cubiertas (97.9%).
- Deploy exitoso a Partial: 0AfAK0000010Si50AE.
- Consulta posterior: Opp_flow_V3 v29 y Opportunity_Flow_V2 v7 están activos.

Un dry-run previo, 0AfAK0000010SYP0A2, validó ambos componentes pero falló por tres métodos preexistentes de OpportunityTriggerHandler_Test. Los datos de esa prueba contienen valores con codificación inválida para picklists restringidos de Sucursal y Categoría de vehículo. El fallo no fue causado por 2D1 y no se modificó la clase.

La validación también informó nodos legacy desconectados de la antigua selección nominal de Pricebook. No forman parte de una ruta ejecutable y ya no contienen nombres fijos. Su eliminación física queda como limpieza posterior para evitar ampliar este cambio funcional.

## Escenarios cubiertos por pruebas relacionadas

- Empresa principal explícita.
- Bavarian y Otobai mediante compatibilidad controlada.
- PEKING mediante lookup, sin fallback legacy.
- Empresa nula, inexistente o inactiva.
- Pricebook inexistente o de otra Empresa.
- Varias opciones válidas.
- Valor desconocido sin selección empresarial por defecto.

## Pendientes funcionales

- Ejecutar ambos Flows desde sus entradas reales con perfiles QA autorizados.
- Validar Bavarian, Otobai y PEKING con datos comerciales oficiales.
- Confirmar que sucursal, territorio, cuenta y respuesta Softland conservan su comportamiento.
- En Opportunity_Flow_V2, ejecutar un caso donde la Empresa del usuario sea distinta de la Empresa seleccionada.
- Validar mensajes de configuración ausente y selección ambigua.

No se crearon datos para completar estos escenarios.

## Videos requeridos

1. Opp_flow_V3: selección explícita de Empresa, creación de Opportunity/Quote y evidencia de Empresa_Operadora__c y Pricebook2Id.
2. Opportunity_Flow_V2 ruta general: misma evidencia y caso de usuario con Empresa distinta.
3. Opportunity_Flow_V2 ruta mostrador: selección explícita y Pricebook resultante.
4. Caso negativo por Empresa o Pricebook no configurado.

## Confirmaciones de alcance

- Solo se desplegaron los dos Flows de 2D1.
- No se modificaron Apex, LWC/Aura, datos ni los recursos excluidos.
- Producción no fue consultada ni modificada.
- 2D2 no fue iniciado.

