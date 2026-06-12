# Entrega Tecnica Oficial - VN-RQ106 Ingresos y Anticipos

Documento oficial local de entrega tecnica y funcional para el requerimiento VN-RQ106. La informacion corresponde a validaciones realizadas en RedMotors Sandbox Partial. Produccion no ha sido modificada.

## 1. Objetivo

VN-RQ106 tiene como objetivo habilitar la gestion de solicitudes de ingreso y anticipo desde Opportunity, incorporando captura de datos de pago, evidencia, envio a Tesoreria, integracion con Helios/Softland, control de reserva de vehiculo y notificaciones del proceso.

El desarrollo permite centralizar desde la oportunidad el registro, seguimiento y decision funcional de reservas asociadas a anticipos, manteniendo trazabilidad del identificador externo generado por Helios/Softland y del estado de aprobacion de producto.

## 2. Alcance implementado

El alcance implementado en Sandbox incluye:

- Registro de solicitud de ingreso/anticipo desde Opportunity.
- Captura de datos de pago.
- Adjuntar evidencia de pago.
- Guardado y actualizacion de borradores.
- Retoma de borradores existentes desde el formulario.
- Envio de solicitud a Tesoreria.
- Recepcion de identificador Helios/Softland.
- Visualizacion de Codigo de anticipo.
- Visualizacion de estado PDF Softland como pendiente de generacion cuando no existe PDF disponible.
- Control de aprobacion, rechazo y reenvio de reserva.
- Actualizacion de estado del anticipo a `Vehiculo reservado` al aprobar la reserva.
- Historial de aprobaciones.
- Resumen financiero asociado a anticipos.
- Correos y notificaciones del proceso.

## 3. Componentes Salesforce involucrados

### Apex classes

| Componente | Uso |
|---|---|
| `VN_RQ106_AnticipoController` | Controla creacion, actualizacion, envio a Tesoreria, validaciones, aprobacion, rechazo y reenvio de reservas. |
| `VN_RQ106_OpportunityOverviewController` | Entrega datos del resumen de Opportunity y flags de visibilidad para acciones de reserva. |
| `VN_RQ106_AnticipoControllerTest` | Pruebas unitarias del controlador de solicitudes/anticipos. |
| `VN_RQ106_OppOverviewCtrlTest` | Pruebas unitarias del controlador de overview. |

### Lightning Web Components

| Componente | Uso |
|---|---|
| `vnRq106OpportunityOverview` | Muestra resumen de ingresos/anticipos, tabla de solicitudes, Codigo de anticipo, estado de aprobacion producto y acciones de reserva. |
| `vnRq106RegistrarIngresoAnticipo` | Formulario para registrar, actualizar, adjuntar evidencia y enviar solicitudes a Tesoreria. |
| `vnRq106SolicitudesAnticipos` | Contenedor modal asociado a la accion de Opportunity. |

### Flow

| Componente | Uso |
|---|---|
| `VN_RQ106_Notificaciones_Anticipo` | Gestiona correos/notificaciones del proceso de ingreso, Tesoreria y reserva. |

### Objeto y campos principales

| Objeto / Campo | Uso |
|---|---|
| `Anticipo__c` | Objeto principal de solicitudes de ingreso, anticipo y reserva. |
| `Anticipo__c.Estado_Aprobacion_Producto__c` | Estado funcional de aprobacion de producto/reserva: pendiente, aprobada o rechazada. |
| `Anticipo__c.Identificador_Helios__c` | Identificador externo devuelto por Helios/Softland. |
| `Anticipo__c.Estatus__c` | Estado operativo del anticipo dentro del proceso. |
| `Anticipo__c.Comentarios_Aprobacion_Rechazo__c` | Comentario asociado al rechazo de reserva. |
| `Opportunity.JefeSucursal__c` | Usuario autorizado para aprobar, rechazar o reenviar reserva. |
| `Opportunity.GerenteSucursal__c` | Responsable usado en logica de notificaciones. |
| `Opportunity.OwnerId` | Asesor/propietario de la oportunidad. |

### Quick Action

| Componente | Uso |
|---|---|
| `Opportunity.VN_RQ106_Solicitudes_Anticipos` | Accion `Solicitudes anticipos` disponible desde Opportunity. |

## 4. Reglas funcionales implementadas

- El asesor puede crear solicitud, guardar borrador, adjuntar evidencia y enviar a Tesoreria.
- El asesor no puede aprobar, rechazar ni reenviar reserva si no corresponde al usuario configurado como responsable funcional.
- La aprobacion, rechazo y reenvio de reserva quedan restringidos al usuario configurado en `Opportunity.JefeSucursal__c`.
- Una solicitud de tipo `Reserva de vehiculo` con estado `Confirmada por Tesoreria` puede pasar a decision de producto.
- Una solicitud de tipo `Reserva de vehiculo` con estado `Anticipo creado` tambien puede pasar a decision de producto si tiene `Identificador_Helios__c` informado.
- Para aprobacion/rechazo se requiere que `Estado_Aprobacion_Producto__c` este pendiente.
- Al aprobar la reserva:
  - `Estado_Aprobacion_Producto__c` queda en `Aprobada`.
  - `Estatus__c` queda en `Vehiculo reservado`.
- Al rechazar la reserva:
  - `Estado_Aprobacion_Producto__c` queda en `Rechazada`.
  - Se registra comentario de rechazo.
- Al reenviar la solicitud:
  - `Estado_Aprobacion_Producto__c` vuelve a `Pendiente`.
- El Codigo de anticipo mostrado corresponde al identificador Helios/Softland almacenado en `Identificador_Helios__c`.

## 5. Integracion Helios/Softland

El proceso de envio a Tesoreria integra Salesforce con Helios/Softland para registrar la solicitud de anticipo y recibir un identificador externo.

Comportamiento validado:

- Salesforce envia la solicitud a Tesoreria/Helios/Softland.
- Helios/Softland responde con un identificador externo cuando confirma la integracion.
- Salesforce almacena el identificador externo en `Anticipo__c.Identificador_Helios__c`.
- El identificador se muestra en pantalla como Codigo de anticipo.
- El enlace de consulta Helios se construye a partir del identificador externo.
- Cuando no existe PDF Softland generado, la pantalla muestra el estado como `PDF Softland pendiente de generacion`.

El alcance actual no modifica la generacion externa del PDF Softland. La visualizacion del PDF queda sujeta a que el proceso externo lo genere y disponibilice.

## 6. Correos/notificaciones

El Flow `VN_RQ106_Notificaciones_Anticipo` fue actualizado para homologar los textos con las plantillas de negocio.

Correos validados:

- Validacion de ingreso requerida / solicitud enviada a Tesoreria.
- Solicitud de aprobacion de reserva.
- Reserva rechazada.
- Vehiculo reservado.

Las plantillas incluyen informacion funcional del proceso, como datos de solicitud, cliente, asesor, tipo de ingreso, monto, medio de pago, fecha, referencia, depositante, vehiculo/VIN, Ticket Helios y enlaces correspondientes cuando aplican.

Los destinatarios y configuracion productiva final deben confirmarse antes del pase a Produccion.

## 7. Validaciones realizadas en Sandbox

Validaciones funcionales realizadas en RedMotors Sandbox Partial:

| Validacion | Resultado |
|---|---|
| Creacion de solicitud desde Opportunity | Validado |
| Guardado de borrador | Validado |
| Retoma y actualizacion de borrador existente | Validado |
| Adjuntar evidencia | Validado |
| Envio a Tesoreria | Validado |
| Recepcion de identificador Helios/Softland | Validado |
| Visualizacion de Codigo de anticipo | Validado |
| Ocultamiento de columna Evidencia en tabla principal | Validado |
| Texto `PDF Softland pendiente de generacion` | Validado |
| Visualizacion de acciones Aprobar/Rechazar para usuario autorizado | Validado |
| Rechazo de reserva | Validado |
| Reenvio de reserva | Validado |
| Aprobacion de reserva | Validado |
| Cambio de estado a `Vehiculo reservado` | Validado |
| Historial de aprobaciones | Validado |
| Resumen financiero | Validado |
| Correos/notificaciones | Validado en Sandbox |

## 8. Deploys relevantes en Sandbox

Los siguientes despliegues corresponden a validaciones realizadas en Sandbox y no representan un plan de pase a Produccion:

| Deploy Id | Alcance | Observacion |
|---|---|---|
| `0AfNq00000Xscq5KAB` | UI + Flow B.2 | Ajustes de interfaz y notificaciones para validacion Sandbox. |
| `0AfNq00000Xsg5hKAB` | Regla `Anticipo creado` + Id Helios | Permite decision de producto cuando existe anticipo creado con identificador Helios. |
| `0AfNq00000XshD3KAJ` | Texto PDF Softland | Actualiza texto visible a `PDF Softland pendiente de generacion`. |
| `0AfNq00000XswX3KAJ` | Autorizacion JefeSucursal | Restringe aprobacion/rechazo/reenvio al usuario configurado como `JefeSucursal__c`. |
| `0AfNq00000XsxePKAR` | Codigo de anticipo | Muestra Codigo de anticipo usando `Identificador_Helios__c`. |
| `0AfNq00000XsoT4KAJ` | Flow correos QA Sandbox | Validacion inicial de correos en Sandbox. |
| `0AfNq00000Xt7U5KAJ` | Homologacion final de plantillas de correo | Plantillas de correo ajustadas y validadas en Sandbox. |

Produccion permanece sin cambios.

## 9. Pendientes antes de Produccion

Antes de preparar el pase productivo deben completarse o confirmarse los siguientes puntos:

1. Confirmar destinatarios y configuracion final productiva de correos.
2. Sustituir configuracion temporal de Sandbox por configuracion final productiva, si aplica.
3. Consolidar evidencia final de QA.
4. Confirmar visto bueno funcional de negocio.
5. Confirmar alcance final de PDF Softland, si aplica.
6. Preparar plan de pase a Produccion.
7. Ejecutar validacion post-deploy en Produccion.

## 10. Conclusion

El desarrollo principal de VN-RQ106 quedo implementado y validado en RedMotors Sandbox Partial para el flujo de ingresos, anticipos, envio a Tesoreria, integracion con identificador Helios/Softland, control de reserva, resumen financiero y correos/notificaciones.

El pase a Produccion queda pendiente de aprobacion funcional, consolidacion de evidencia final, confirmacion de configuracion productiva y preparacion del plan de despliegue correspondiente.
