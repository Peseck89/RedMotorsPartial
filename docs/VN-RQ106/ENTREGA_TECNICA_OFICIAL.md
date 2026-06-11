# RedMotors VN-RQ106 - Entrega Técnica Salesforce

Documento local de preparación para entrega técnica. La información marcada como pendiente no debe considerarse aprobada hasta completar validación funcional y QA.

## 1. Información general

- Proyecto: RedMotors VN-RQ106.
- Ambiente trabajado: RedMotors Sandbox Partial.
- Alias de trabajo: `RedMotorsSandbox`.
- Producción: sin cambios.
- Estado QA: parcial, no aprobado.
- Estado de integración Tesorería/Helios/Softland: bloqueado por respuesta backend pendiente de revisión.

## 2. Resumen funcional

VN-RQ106 permite gestionar ingresos, anticipos y reservas de vehículo desde Opportunity.

El alcance funcional incluye:

- Creación y consulta de solicitudes de ingreso/anticipo.
- Registro de reserva de vehículo.
- Adjuntar evidencia de pago.
- Validaciones previas al envío a Tesorería.
- Envío de solicitud a Tesorería/Helios/Softland.
- Aprobación y rechazo de reserva por usuario responsable.
- Reenvío de solicitud de reserva.
- Consulta de estado y evidencia desde Opportunity.

## 3. Componentes modificados o creados

| Tipo | Nombre API / Técnico | Acción | Descripción del cambio | Estado |
|---|---|---|---|---|
| Apex | `VN_RQ106_AnticipoController` | Modificado | Controla creación/actualización de borradores, envío a Tesorería, validaciones, aprobación/rechazo/reenvío de reserva y armado del payload de integración. | Desplegado parcialmente en Sandbox. |
| Apex | `VN_RQ106_OpportunityOverviewController` | Modificado | Expone datos del overview y flags de visibilidad para acciones de reserva según usuario responsable y estado. | Desplegado parcialmente en Sandbox. |
| Apex | `SolicitudAprobacionTesoreria` | Modificado | Clase de integración con Tesorería/Helios/Softland. Se agregó `cliente` al payload conservando `codigoSoftland`. | Desplegado en Sandbox. |
| Apex Test | `VN_RQ106_AnticipoControllerTest` | Modificado | Cubre creación, actualización, envío a Tesorería, payload `cliente`, aprobación, rechazo, reenvío y casos negativos. | Ejecutado en Sandbox. |
| Apex Test | `VN_RQ106_OppOverviewCtrlTest` | Modificado | Cubre flags y consulta de overview para Opportunity. | Pendiente de validación final con Bloque B completo. |
| Lightning Web Component | `vnRq106OpportunityOverview` | Modificado | Overview reutilizable en modal, tabla de solicitudes, acciones de aprobación/rechazo/reenvío y visibilidad según flags. | Desplegado parcialmente en Sandbox. |
| Lightning Web Component | `vnRq106RegistrarIngresoAnticipo` | Modificado | Permite retomar borradores existentes, actualizar borrador, adjuntar evidencia y enviar a Tesorería cuando cumple validaciones. | Desplegado en Sandbox. |
| Lightning Web Component | `vnRq106SolicitudesAnticipos` | Nuevo | Contenedor modal para acceder a solicitudes de anticipos desde Opportunity. | Desplegado en Sandbox. |
| Quick Action | `Opportunity.VN_RQ106_Solicitudes_Anticipos` | Nuevo | Botón `Solicitudes anticipos` en Opportunity. | Desplegado en Sandbox. |
| Flexipage | `Opportunity_Record_Page_VN` | Modificada | Agrega acción `Solicitudes anticipos` y retira overview embebido de la vista principal. | Desplegado en Sandbox. |
| Flexipage | `Opportunity_Record_Page_VU` | Modificada | Agrega acción `Solicitudes anticipos` y retira overview embebido de la vista principal. | Desplegado en Sandbox. |
| Permission Set | `VN_RQ106_Anticipo` | Modificado | Permisos y FLS requeridos para VN-RQ106, incluyendo campo de aprobación de producto. | Configurado y validado parcialmente en Sandbox. |
| Campo | `Anticipo__c.Estado_Aprobacion_Producto__c` | Nuevo | Picklist para controlar aprobación funcional de producto/reserva. | Desplegado parcialmente en Sandbox. |
| Flow | `VN_RQ106_Notificaciones_Anticipo` | Pendiente | Notificaciones relacionadas con aprobación/rechazo/reenvío. | Pendiente de validación y cierre. |

## 4. Objetos y campos involucrados

| Objeto | Campo | Uso | Estado |
|---|---|---|---|
| `Opportunity` | `OwnerId` | Propietario de la oportunidad; destinatario funcional de notificaciones. | Existente. |
| `Opportunity` | `JefeSucursal__c` | Usuario responsable de aprobar/rechazar reserva. | Existente y confirmado. |
| `Opportunity` | `GerenteSucursal__c` | Destinatario funcional de notificaciones. | Existente y confirmado. |
| `Opportunity` | `DirectorVentas__c` | Campo de responsable disponible en Opportunity. | Existente y confirmado. |
| `Opportunity` | `empresaQueFactura__c` | Empresa requerida para preparar envío a Tesorería. | Existente; validado en QA con valor `Bavarian`. |
| `Opportunity` | `Cuenta_de_Facturaci_n__c` | Cuenta de facturación asociada a la oportunidad. | Existente; valor Softland validado en QA. |
| `Account` | `codigoSoftland__c` | Código de cliente usado para `codigoSoftland` y `cliente` en payload. | Existente; validado en QA con el código Softland del cliente. |
| `Anticipo__c` | `Tipo_Ingreso__c` | Distingue reserva de vehículo y otros ingresos. | Existente. |
| `Anticipo__c` | `Estatus__c` | Estado operativo del anticipo. | Existente. |
| `Anticipo__c` | `Estado_Aprobacion_Producto__c` | Estado funcional de aprobación de reserva/producto. | Nuevo. |
| `Anticipo__c` | `Comentarios_Aprobacion_Rechazo__c` | Comentario obligatorio en rechazo. | Existente. |
| `Anticipo__c` | `Comentarios_Asesor__c` | Comentarios del asesor en la solicitud. | Existente. |
| `Anticipo__c` | `Producto__c` | Vehículo/producto asociado a la reserva. | Existente. |
| `Anticipo__c` | `Identificador_Helios__c` | Identificador devuelto por Helios/Softland. | Existente; pendiente de confirmación en QA final. |
| `Product2` | Campos de vehículo/VIN/reserva | Determinan vehículos disponibles para reserva. | Existente. |

## 5. Cambios funcionales implementados

- Botón/modal `Solicitudes anticipos` en Opportunity.
- Reutilización de overview dentro del modal.
- Retiro del overview embebido de la vista principal.
- Consulta de solicitudes/anticipos desde Opportunity.
- Creación de borrador de anticipo/reserva.
- Retomar borradores existentes desde el formulario.
- Botón dinámico `Actualizar borrador` cuando ya existe borrador.
- Adjuntar evidencia al anticipo.
- Validaciones previas al envío a Tesorería:
  - Campos obligatorios completos.
  - Evidencia presente.
  - Oportunidad activa.
  - Cliente relacionado.
  - Monto mayor a cero.
  - Preparado para Tesorería.
- Campo de aprobación producto para separar decisión funcional de reserva del `Estatus__c`.
- Acciones de aprobar, rechazar y reenviar reserva.
- Rechazo de reserva sin cambiar `Anticipo__c.Estatus__c`.
- Reenvío de reserva reinicia estado de aprobación producto.
- Payload de Tesorería ahora incluye `cliente` y conserva `codigoSoftland`.

## 6. Permisos y accesos

- Permission Set involucrado: `VN_RQ106_Anticipo`.
- Se validaron 28 asignaciones activas en Sandbox.
- Perfiles QA cubiertos:
  - Asesor de Ventas BMW y Nuevos V2.
  - Asesor de Ventas Kawa - Polaris y Nuevos V2.
  - Asesor de Ventas Motorrad-Kawa-Polaris y Nuevos V2.
  - Asesor Ventas Autos Usados.
  - Asesor Ventas Motos Usados v2.
- FLS relevante:
  - Lectura/edición de campos requeridos en `Anticipo__c`.
  - Acceso al nuevo campo `Estado_Aprobacion_Producto__c`.
  - Lectura de responsables de Opportunity requeridos para visibilidad y validaciones.

Pendiente de validación final:

- Validación no-admin completa con evidencia.
- Confirmación de comportamiento por usuario autorizado y no autorizado en UI.

## 7. Integración Tesorería / Helios / Softland

La integración de envío a Tesorería usa `SolicitudAprobacionTesoreria` para preparar y enviar la solicitud a Helios/Softland.

Campos relevantes confirmados en QA:

- `codigoSoftland = código Softland del cliente`.
- `cliente = código Softland del cliente`.
- Empresa que factura: `Bavarian`.
- Anticipo QA: `Anticipo QA Sandbox`.

Estado actual:

- Salesforce ya arma y envía el payload con `cliente`.
- Helios/Softland sigue respondiendo:
  - `SP_SF_CREAR_SOLICITUD_ANTICIPO expects parameter '@cliente', which was not supplied.`
- El anticipo permanece en `Borrador` porque Helios/Softland no confirma la integración.

Conclusión:

- El bloqueo actual no corresponde a dato faltante confirmado en Salesforce ni a mapeo básico Apex.
- Queda pendiente revisión de integración Helios/Softland/API/backend por el equipo de integración o responsable técnico correspondiente.

## 8. Deploys Sandbox relevantes

| Fecha | Ambiente | Alcance | Resultado | Id | Tests |
|---|---|---|---|---|---|
| 2026-06-10 | RedMotors Sandbox Partial | Bloque A: validación técnica de modal, Quick Action, LWC overview y Flexipages VN/VU | Exitoso | `0AfNq00000Xp6pxKAB` | No aplica por cambio UI/metadata declarativa. |
| 2026-06-10 | RedMotors Sandbox Partial | Bloque A: despliegue botón/modal `Solicitudes anticipos` | Exitoso | `0AfNq00000Xp7UHKAZ` | No aplica por cambio UI/metadata declarativa. |
| 2026-06-10 | RedMotors Sandbox Partial | Bloque B parcial: campo nuevo, permission set, Apex, LWC overview y tests relacionados, excluyendo Flow | Exitoso | `0AfNq00000XpoJ7KAJ` | `VN_RQ106_AnticipoControllerTest`, `VN_RQ106_OppOverviewCtrlTest`. |
| 2026-06-10 | RedMotors Sandbox Partial | Mejora diagnóstico de errores en guardado de borrador | Exitoso | Pendiente de referencia en cierre documental | `VN_RQ106_AnticipoControllerTest`. |
| 2026-06-10 | RedMotors Sandbox Partial | LWC retomar borrador existente `vnRq106RegistrarIngresoAnticipo` | Exitoso | `0AfNq00000Xpu8SKAR` | `NoTestRun`. |
| 2026-06-11 | RedMotors Sandbox Partial | Fix `cliente` para Tesorería: `SolicitudAprobacionTesoreria`, `VN_RQ106_AnticipoController`, `VN_RQ106_AnticipoControllerTest` | Exitoso | `0AfNq00000XqkyDKAR` | `35/35` exitosos. |

Producción no fue modificada en ninguno de los despliegues indicados.

## 9. Estado QA actual

Opportunity QA:

- Id: Opportunity QA Sandbox.
- Nombre: `Opportunity QA Sandbox`.

Anticipo QA:

- Id: Anticipo QA Sandbox.
- Nombre: `Anticipo QA Sandbox`.
- `Estatus__c = Borrador`.
- `Estado_Aprobacion_Producto__c = Pendiente`.
- `Identificador_Helios__c = vacío`.

Validaciones realizadas:

| Validación | Resultado | Observación |
|---|---|---|
| Borrador creado | OK | Creado desde UI. |
| Retomar borrador | OK | El formulario carga el borrador existente. |
| Botón `Actualizar borrador` | OK | Se muestra cuando existe borrador. |
| Adjuntar evidencia | OK | Evidencia cargada correctamente. |
| Empresa que Factura | OK | `empresaQueFactura__c = Bavarian`. |
| Código Softland | OK | Código Softland del cliente validado en Sandbox. |
| JSON con `cliente` | OK | Salesforce envía `cliente` con el código Softland del cliente. |
| Envío Helios/Softland | Bloqueado | Backend responde error sobre `@cliente`. |
| QA completa | Pendiente | No marcar como aprobado. |

## 10. Riesgos y limitaciones

- QA formal no está completa.
- Producción permanece sin cambios y no debe tocarse hasta cierre QA y aprobación funcional.
- Helios/Softland bloquea el avance del flujo completo.
- Mientras Tesorería no confirme el envío, no se puede validar transición a `Confirmada por Tesorería`.
- Aprobación, rechazo y reenvío requieren que el anticipo llegue al estado previo esperado.
- Flow de notificaciones sigue pendiente de validación final.
- Textos finales de correos de rechazo y reenvío siguen pendientes de confirmación.
- Evidencias oficiales y Excel QA siguen pendientes.

## 11. Usuario QA / evidencias

Usuario QA puede comenzar solo evidencia básica/no destructiva:

1. Abrir la Opportunity de prueba indicada por el equipo funcional.
2. Mostrar botón `Solicitudes anticipos`.
3. Abrir modal.
4. Validar que carga overview.
5. Validar que la tabla de solicitudes se muestra.
6. Validar que no hay error visual en el modal.

Usuario QA no debe ejecutar todavía:

1. Crear nuevo anticipo real.
2. Enviar a Tesorería.
3. Aprobar reserva.
4. Rechazar reserva.
5. Reenviar solicitud.
6. Evidencia final de flujo completo.
7. Pruebas destructivas sobre Opportunity reservada para evidencia funcional.

Motivo:

- El envío a Tesorería depende de confirmación Helios/Softland y actualmente la integración responde error funcional aunque Salesforce ya envía `cliente`.

## 12. Pendientes

1. Obtener respuesta del equipo de integración sobre error Helios/Softland.
2. Confirmar si backend corrige mapeo `cliente`.
3. Reintentar envío a Tesorería de `Anticipo QA Sandbox`.
4. Confirmar `Identificador_Helios__c`.
5. Confirmar cambio de estatus posterior al envío.
6. Llevar anticipo a `Confirmada por Tesorería`.
7. Probar aprobar reserva.
8. Probar rechazar reserva.
9. Probar reenvío de solicitud.
10. Validar notificaciones.
11. Completar QA Excel.
12. Subir evidencias oficiales a Drive.
13. Preparar instrucciones finales para Usuario QA.
14. Ordenar cambios locales y preparar commit cuando sea autorizado.

## 13. Estado actual

- Sandbox contiene avances desplegados y validados parcialmente.
- Producción permanece sin cambios.
- QA completa está pendiente.
- Integración Tesorería/Helios/Softland está bloqueada por revisión backend.
- Este documento debe actualizarse después de resolver el bloqueo de integración y completar evidencia QA.
