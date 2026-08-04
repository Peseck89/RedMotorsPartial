# Resultado Lote 2A — Flows técnicamente ejecutables

Fecha de ejecución: 4 de agosto de 2026  
Ambiente: Salesforce Partial

## Resultado ejecutivo

Los tres Flows autorizados fueron modificados, validados y desplegados en Partial. La solución prioriza el lookup de Empresa, conserva un fallback temporal exclusivamente para Bavarian y Otobai y delega la selección del Pricebook a EmpresaPricebookResolver.

No se agregaron valores a picklists legacy, nombres ni identificadores fijos de Pricebooks. Ningún valor desconocido selecciona Bavarian u Otobai por defecto. Los estados NO_CONFIGURADO, SELECCION_REQUERIDA y ERROR detienen la ruta; solamente EXITO permite continuar.

| Flow | Versión anterior | Versión activa resultante | Resultado |
|---|---:|---:|---|
| PlanDeMantenimientoV2 | 23 | 24 | Desplegado y activo |
| CreateWoliFromExpense | 14 | 15 | Desplegado y activo |
| AgregarManoObra | 1 | 2 | Desplegado y activo |

## Cambios realizados

### PlanDeMantenimientoV2

- Usa Opportunity.Empresa_Operadora__c como fuente principal.
- Cuando el lookup está vacío, traduce únicamente Bavarian/Otobai a su código ERP y consulta una Empresa activa.
- Resuelve el Pricebook con la moneda y el Pricebook actual de la cotización.
- Busca PricebookEntry por el Pricebook resuelto, producto e indicador activo.
- Muestra un mensaje controlado y detiene el proceso si la Empresa, el Pricebook o la entrada del producto no son válidos.
- Conserva las rutas de selección de vehículo, términos, costo y creación del plan.

### CreateWoliFromExpense

- Sustituye la bifurcación Bavarian/else Otobai por WorkOrder.empresaFacturaCP__c y fallback controlado sobre empresaFactura__c.
- Resuelve el Pricebook usando la moneda y el Pricebook actual del Work Order.
- Busca una entrada activa para el producto de subcontrato dentro del Pricebook resuelto.
- Si el resultado no es EXITO o no existe la entrada, termina sin crear ni actualizar un Work Order Line Item con referencias nulas.
- Conserva las conversiones monetarias, categorías, impuestos y cálculos existentes.

### AgregarManoObra

- Usa WorkOrder.empresaFacturaCP__c como fuente principal y empresaFactura__c solo como fallback controlado.
- Sustituye los cuatro identificadores fijos por el resultado de EmpresaPricebookResolver.
- Solo consulta productos y entradas después de obtener EXITO.
- Muestra un error controlado para Empresa ausente/desconocida, Pricebook no configurado o selección ambigua.
- Conserva la selección de mano de obra, cantidades/UT, descuentos y creación de líneas.

## Estados controlados

| Estado | Comportamiento |
|---|---|
| EXITO | Continúa con el Pricebook devuelto y valida la entrada del producto. |
| NO_CONFIGURADO | Detiene la ruta; no continúa con identificadores nulos. |
| SELECCION_REQUERIDA | Detiene la ruta; no elige una opción arbitraria. |
| ERROR | Detiene la ruta y evita fallback hacia otra Empresa. |

PEKING solo se resuelve cuando el lookup de Empresa está informado explícitamente. Un valor legacy desconocido se traduce a vacío y termina de forma controlada.

## Validaciones ejecutadas

- XML bien formado y nombres de elementos únicos en los tres Flows.
- Búsqueda estática sin IDs de Pricebook, nombres fijos de Pricebook ni decisiones binarias de Empresa.
- Validación de metadata de los tres Flows: exitosa.
- Dry-run: 0AfAK0000010Qzd0AE.
- Deploy a Partial: 0AfAK0000010R1F0AU.
- Pruebas incluidas en validación y deploy: 45/45 aprobadas.
- Ejecución adicional con cobertura: 46/46 aprobadas, ejecución 707AK00000Hrffj.
- Cobertura de la ejecución seleccionada: 58%; cobertura general informada por el ambiente: 41%.
- EmpresaPricebookResolver: 137 líneas cubiertas y 3 no cubiertas (97.9%).
- Consulta posterior a despliegue: las versiones 24, 15 y 2 están activas.

La validación informó nodos legacy desconectados en CreateWoliFromExpense y AgregarManoObra. Son avisos informativos: no forman parte de una ruta ejecutable y sus valores fijos fueron eliminados. Su retiro físico puede evaluarse como limpieza posterior, separado del cambio funcional.

## Escenarios cubiertos por pruebas automatizadas relacionadas

- Bavarian y Otobai conservan resolución por lookup y fallback temporal.
- PEKING se resuelve por lookup principal.
- Empresa ausente, inexistente o inactiva retorna error controlado.
- Empresa sin Pricebook retorna NO_CONFIGURADO.
- Varias opciones válidas retornan SELECCION_REQUERIDA.
- Valor legacy desconocido no selecciona una Empresa por defecto.
- Procesamiento masivo sin consultas dentro del ciclo principal.

## Bloqueos y evidencias pendientes

No queda un bloqueo técnico conocido en estos tres Flows. Falta validación funcional positiva con datos oficiales:

- Empresa PEKING activa y vinculada al registro funcional usado en QA.
- Pricebook comercial aprobado y activo para la moneda del escenario.
- Productos SAD001, SUB y productos de mano de obra con entradas activas en el Pricebook correspondiente.
- Gastos, Work Orders, cotizaciones y planes aptos para ejecutar las rutas reales.

No se crearon datos para suplir estas condiciones.

## Videos requeridos

1. PlanDeMantenimientoV2: ejecución positiva por Empresa y evidencia de que la entrada pertenece al Pricebook correcto; ejecución negativa sin configuración.
2. CreateWoliFromExpense: creación/actualización Expense → WOLI para Bavarian, Otobai y PEKING; evidencia del PricebookEntry final; caso negativo sin Pricebook.
3. AgregarManoObra: selección y creación de mano de obra para las tres Empresas; caso de selección ambigua o sin configuración.

Cada evidencia debe mostrar el lookup de Empresa, moneda, Pricebook, PricebookEntry y resultado final, sin exponer datos sensibles.

## Alcance respetado

- Solo se desplegaron los tres Flows autorizados.
- No se modificaron otros Flows, componentes, despacho ni procesos de usados.
- No se modificaron datos.
- Producción no fue consultada ni modificada durante este lote.

