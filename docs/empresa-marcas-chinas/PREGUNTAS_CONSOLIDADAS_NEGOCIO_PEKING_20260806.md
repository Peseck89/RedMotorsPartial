# Preguntas consolidadas de negocio — PEKING

**Fecha de consolidación:** 6 de agosto de 2026

**Estado general:** pendientes de respuesta o asignación de responsable.

## Definiciones ya confirmadas — no volver a preguntar

- Omoda y Jaecoo pertenecen a PEKING.
- PEKING no aplica a vehículos usados.
- Softland utiliza la misma instancia y endpoints existentes; no se crea otra instancia.
- El contexto ERP es `RMPEKING` y los catálogos Softland deben incluir PEKING.
- Los Pricebooks esperados son `PEKING Local` y `PEKING Dólares`.
- Las bodegas oficiales todavía no están definidas.
- Datos legales, logos, correos y PDFs requieren definición de negocio.

## Ventas y cotización

| Sprint de origen | Componente o proceso afectado | Decisión requerida | Responsable esperado | Riesgo de asumir | Estado |
|---|---|---|---|---|---|
| Sprint 3, bloque 7 | Layouts y FlexiPages de Opportunity, Account y Quote | ¿Qué Layouts y páginas deben utilizar los Record Types Omoda y Jaecoo, por aplicación y perfil? | Negocio / responsable de Ventas | Mostrar campos o acciones incorrectos y confundir visibilidad con acceso. | PENDIENTE_NEGOCIO |
| Sprint 3, bloque 11 | `RM_Config.Default_Price_List_VN` y procesos VN | ¿Cuál es la regla comercial cuando no existe una selección explícita válida de Pricebook, considerando que los dos Pricebooks PEKING esperados ya están identificados? | Negocio / Ventas | Seleccionar otra Empresa o continuar sin Pricebook válido. | PENDIENTE_NEGOCIO |
| Sprint 3, bloque 9 | Validation Rules y ocho Approval Processes de descuento de Opportunity | ¿Qué reglas, umbrales y niveles de aprobación aplican a descuentos de Omoda y Jaecoo? | Negocio / Ventas / Finanzas | Bloquear ventas válidas o aprobar descuentos indebidos. | PENDIENTE_NEGOCIO |
| Sprint 2 y Sprint 3, bloque 9 | Quote, WorkOrder, Validation Rules y Approval Processes de centro de costo | ¿Qué reglas de centro de costo aplican a PEKING y qué rol funcional aprueba cada caso? | Negocio / Finanzas | Imputar o aprobar costos de forma incorrecta. | PENDIENTE_NEGOCIO |

## Taller y postventa

| Sprint de origen | Componente o proceso afectado | Decisión requerida | Responsable esperado | Riesgo de asumir | Estado |
|---|---|---|---|---|---|
| Sprint 2 | Inventario, localización, despacho y Quote→Work Order | ¿Cuáles son las bodegas oficiales de PEKING y cuál cumple cada función operativa? | Negocio / Operaciones / Softland | Reservar, localizar o despachar desde una bodega incorrecta. | PENDIENTE_NEGOCIO |
| Sprint 2 y Sprint 3 | Inventario, Community, WorkOrder, Event y roles | ¿Cuáles son las sucursales, territorios y talleres oficiales de PEKING y cómo se relacionan? | Negocio / Operaciones | Crear rutas, cobertura o visibilidad territorial incorrectas. | PENDIENTE_NEGOCIO |
| Sprint 2 | Reserva, apartado, despacho y devolución | ¿Qué reglas y estados aplican a reservas, cancelaciones y devoluciones PEKING? | Negocio / Operaciones | Liberar o retener inventario indebidamente. | PENDIENTE_NEGOCIO |
| Sprint 2 | `Work_Order_from_Quote` y `Work_Order_from_Quote_Selective` | ¿En qué condiciones se crea una Work Order desde Quote, qué líneas se transfieren y qué validaciones deben detener el proceso? | Negocio / Taller | Crear órdenes o líneas incompletas, duplicadas o para otra Empresa. | PENDIENTE_NEGOCIO |
| Sprint 2 | `aperturaCaseWorOrderEvent`, `ct_newCaseWorkOrderEvent`, Community y calendario | ¿Qué servicios, agendas, capacidades, asesores y mecánicos corresponden a cada sucursal o taller PEKING? | Negocio / Taller / Call Center | Ofrecer servicios o disponibilidad inexistentes. | PENDIENTE_NEGOCIO |
| Sprint 2 y Sprint 3, bloque 9 | `assetGarantiaLookupLwc`, `PROCESO_DE_APROB_GARANTIA` y aprobación de cita de taller | ¿Qué coberturas, criterios y roles funcionales aplican a garantías PEKING? | Negocio / Garantías / Taller | Aprobar o rechazar garantías con reglas de otra Empresa. | PENDIENTE_NEGOCIO |
| Sprint 2 | `SegregateWOLIs`, WOLI y cargos | ¿Qué reglas determinan la segregación de cargos y WOLIs para PEKING? | Negocio / Taller / Finanzas | Mezclar cargos, responsables o tratamientos contables. | PENDIENTE_NEGOCIO |

## Accesos

| Sprint de origen | Componente o proceso afectado | Decisión requerida | Responsable esperado | Riesgo de asumir | Estado |
|---|---|---|---|---|---|
| Sprint 3, bloque 9 | Los 15 roles existentes y cualquier rol nuevo | ¿Cuál es la jerarquía funcional de Ventas y Postventa PEKING y qué responsabilidades representa cada nivel? | Negocio / Seguridad | Otorgar visibilidad excesiva o impedir la operación. | PENDIENTE_NEGOCIO |
| Sprint 2 y Sprint 3 | Flows, componentes, Layouts y aprobaciones | ¿Cuáles son los accesos mínimos requeridos por función para operar PEKING? | Negocio / Seguridad / responsables de proceso | Confundir exposición visual con autorización real. | PENDIENTE_NEGOCIO |
| Sprint 2 | Campos concretos ya identificados en inventario, despacho, WorkOrder y Community | Cuando un proceso requiera campos restringidos, ¿qué Permission Set o perfil funcional debe habilitarlos y para qué población QA/operativa? | Seguridad / responsable funcional | Probar con permisos irreales o ampliar accesos innecesariamente. | PENDIENTE_RESPONSABLE |

## Documentos y datos operativos

| Sprint de origen | Componente o proceso afectado | Decisión requerida | Responsable esperado | Riesgo de asumir | Estado |
|---|---|---|---|---|---|
| Sprint 2 y Sprint 3, bloque 7 | PDFs, correos, Layouts y Community | ¿Cuáles son los logos, datos legales y textos oficiales de PEKING/Omoda/Jaecoo? | Negocio / Legal / Marca | Emitir documentos con identidad o información legal incorrecta. | PENDIENTE_NEGOCIO |
| Sprint 2 y Sprint 3, bloque 7 | `BMW_EnviarCorreoPresupuesto`, PDFs y acciones de plantillas | ¿Qué plantillas y remitentes oficiales deben usarse en correos y PDFs PEKING? | Negocio / Legal / Comunicaciones | Enviar documentos con formato, identidad o remitente no autorizados. | PENDIENTE_NEGOCIO |
| Sprint 2 | Mantenimiento, gastos, mano de obra, inventario y cotización | ¿Cuál es la fuente oficial de productos y precios PEKING para pruebas y operación? | Negocio / Comercial / Softland | Copiar productos o precios de otra Empresa. | PENDIENTE_NEGOCIO |
| Sprint 2 | Quote, WorkOrder, importación de plantillas y cambio de moneda | ¿Qué monedas y catálogos oficiales corresponden a cada proceso, sin redefinir los Pricebooks PEKING ya confirmados? | Negocio / Finanzas / Softland | Mezclar moneda, catálogo o precio. | PENDIENTE_NEGOCIO |
| Sprint 2 | Cotización, facturación, órdenes y documentos | Cuando aplique, ¿qué cuentas, términos comerciales y reglas de numeración oficiales debe utilizar PEKING? | Negocio / Finanzas / Legal | Generar documentos o registros operativos inválidos. | PENDIENTE_NEGOCIO |

## Softland

| Sprint de origen | Componente o proceso afectado | Decisión requerida | Responsable esperado | Riesgo de asumir | Estado |
|---|---|---|---|---|---|
| Sprint 3, bloque 11 | Configuración Softland | Sin compartir valores sensibles, ¿cuál es el tipo de metadata y nombre lógico de la configuración autoritativa existente? | Diego / responsable técnico Softland | Duplicar configuración o depender de un marcador ficticio. | PENDIENTE_DIEGO |
| Sprint 1 y Sprint 3, bloque 11 | Consumidores actuales de integración | ¿Qué procesos existentes deben consumir el contexto `RMPEKING` y cuál es la señal funcional esperada de selección correcta? | Diego / responsable técnico / negocio del proceso | Usar un contexto ERP legacy sin detectarlo. | PENDIENTE_DIEGO |
| Sprint 1 y Sprint 3, bloque 11 | Apex/batches previos y validaciones configurables | ¿Qué pendientes pertenecen al frente técnico de Sprint 1 y cuáles son validaciones configurables del bloque 11 de Sprint 3? | Diego / líder técnico | Absorber refactor previo dentro de Sprint 3 o dejar una validación sin responsable. | PENDIENTE_DIEGO |

Responder cada punto o indicar la persona responsable. Una respuesta funcional no autoriza por sí sola implementación, carga de datos ni cambios de seguridad.

## Reevaluación posterior por respuesta de Diego — 2026-08-06

Se conserva la redacción histórica de las 22 preguntas y se actualiza su estado sin asumir datos ni autorizaciones:

| # | Componente o proceso | Estado actualizado | Aplicación de la respuesta | Pendiente real |
|---:|---|---|---|---|
| 1 | Layouts/FlexiPages de Opportunity, Account y Quote | `SIGUE_PENDIENTE` | Sin cambio | Asignación de páginas y Layouts por Record Type/perfil |
| 2 | Default Pricebook VN | `SIGUE_PENDIENTE` | Sin cambio | Regla comercial cuando falta selección explícita |
| 3 | Descuentos y aprobaciones | `PARCIALMENTE_RESPONDIDA` | La regla general es igual a las áreas existentes | Umbrales, niveles y aprobadores nominales |
| 4 | Centros de costo | `PARCIALMENTE_RESPONDIDA` | La regla general es igual; no existen registros PEKING | Valores, referencia y responsable/aprobador |
| 5 | Bodegas | `SIGUE_PENDIENTE` | Sin cambio | Bodegas oficiales y función operativa |
| 6 | Sucursales, territorios y talleres | `PARCIALMENTE_RESPONDIDA` | Se confirma ausencia de registros territoriales PEKING | Valores y relación oficial de sucursales, territorios y talleres |
| 7 | Reservas, cancelaciones y devoluciones | `RESPONDIDA` | Se gestionan conforme a la Empresa enviada | QA integral pendiente por datos; no constituye autorización de creación |
| 8 | Quote → Work Order | `PARCIALMENTE_RESPONDIDA` | Procesos equivalentes deben operar por Empresa | Condiciones, líneas y validaciones específicas de Quote→WO |
| 9 | Servicios, agenda, asesores y mecánicos | `PARCIALMENTE_RESPONDIDA` | Se confirma ausencia de asesores/registros equivalentes PEKING | Servicios, capacidades, referencias y registros mínimos |
| 10 | Garantía | `SIGUE_PENDIENTE` | Sin cambio | Cobertura, criterios y responsables |
| 11 | Segregación de cargos y WOLIs | `PARCIALMENTE_RESPONDIDA` | Aplica la regla general existente | Criterios nominales, centros de costo, garantía y QA |
| 12 | Jerarquía y roles | `DEPENDENCIA_DIEGO` | Diego creará la jerarquía | Disponibilidad y evidencia; no volver a solicitar al negocio por ahora |
| 13 | Accesos mínimos | `SIGUE_PENDIENTE` | Sin cambio | Acceso mínimo por función |
| 14 | Profile/Permission Set para campos concretos | `DEPENDENCIA_DIEGO` | Diego creará perfiles | Coordinar alcance de campos y Permission Sets sin duplicar perfiles |
| 15 | Logos y datos legales | `SIGUE_PENDIENTE` | Sin cambio | Contenido oficial |
| 16 | Plantillas y remitentes | `SIGUE_PENDIENTE` | Sin cambio | Plantillas y remitentes oficiales |
| 17 | Productos y precios | `SIGUE_PENDIENTE` | Sin cambio | Fuente oficial |
| 18 | Monedas y catálogos | `SIGUE_PENDIENTE` | Sin cambio | Monedas y catálogos oficiales |
| 19 | Cuentas, términos y numeraciones | `SIGUE_PENDIENTE` | Sin cambio | Valores oficiales cuando apliquen |
| 20 | Configuración Softland autoritativa | `SIGUE_PENDIENTE` | Reservas/devoluciones no resuelven este mecanismo | Tipo y nombre lógico sin valores sensibles |
| 21 | Consumidores RMPEKING | `PARCIALMENTE_RESPONDIDA` | Reservas/devoluciones consumen la Empresa enviada | Resto de consumidores y señal verificable |
| 22 | Separación Sprint 1 / bloque 11 | `DEPENDENCIA_DIEGO` | Requiere delimitación técnica de Diego | Clasificación nominal de pendientes |

**Conteo:** 1 `RESPONDIDA`, 7 `PARCIALMENTE_RESPONDIDA`, 11 `SIGUE_PENDIENTE` y 3 `DEPENDENCIA_DIEGO`; total 22.

Jerarquía y perfiles no se vuelven a solicitar al negocio por ahora. La disponibilidad de datos QA, su referencia y cualquier autorización de creación permanecen pendientes.

## Aplicación de B9-0 — 2026-08-06

La pregunta general sobre si PEKING requiere reglas distintas ya no se repite. La revisión nominal de 94 Validation Rules identificó:

- 32 reglas que no requieren cambio técnico y solo necesitan regresión;
- 9 reglas que siguen bloqueadas por datos operativos;
- 4 reglas que siguen bloqueadas por aprobadores, responsables o criterios de aseguradora;
- 46 reglas que dependen directamente de perfiles a cargo de Diego;
- 3 reglas que no aplican a PEKING.

No quedó ninguna candidata técnica aislada. Permanecen vigentes únicamente las preguntas sobre datos, responsables y criterios concretos ya registradas; no se agrega una pregunta nueva ni se solicita a negocio información sobre controles internos.
