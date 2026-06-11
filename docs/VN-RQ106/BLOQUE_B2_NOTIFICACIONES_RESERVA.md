# VN-RQ106 — Bloque B.2 Notificaciones de reserva

## Objetivo

Documentar los correos funcionales requeridos para el flujo de aprobación, rechazo y reenvío de reserva de vehículo.

## Estado

Pendiente de implementación y QA.

Los textos funcionales de reenvío y rechazo ya están definidos.

La activación/despliegue queda pendiente hasta validar destinatarios, disparadores y pruebas completas.

## Correo 1 — Reenvío de solicitud de reserva

### Propósito

Solicitar nuevamente aprobación para reservar un nuevo VIN dentro de la misma oportunidad.

### Disparador funcional esperado

Cuando una reserva fue rechazada y se requiere reenviar solicitud de aprobación para un nuevo VIN.

### Texto funcional

Asunto sugerido:

Solicitud de aprobación para reserva de nuevo VIN

Cuerpo:

Estimado/a [Nombre],

Se requiere su aprobación para reservar el nuevo VIN [Nuevo VIN] en la misma oportunidad [Nombre o número de oportunidad].

Solicitado por: [Nombre del vendedor]

Link de la oportunidad: [Link de la oportunidad]

El anticipo asociado ya fue registrado y aprobado por Tesorería, con el siguiente detalle:

- Número de anticipo: [Número de anticipo]
- Monto: [Monto del anticipo]
- Referencia: [Referencia del anticipo]
- Fecha de registro: [Fecha de registro]

Quedo atento/a a su aprobación para continuar con el proceso de reserva.

Saludos,

[Nombre del vendedor]

### Variables Salesforce sugeridas

- [Nombre] -> Usuario destinatario.
- [Nuevo VIN] -> Producto/Vehículo/VIN asociado a la solicitud.
- [Nombre o número de oportunidad] -> `Opportunity.Name`.
- [Nombre del vendedor] -> `Opportunity.Owner.Name`.
- [Link de la oportunidad] -> URL del registro `Opportunity`.
- [Número de anticipo] -> `Anticipo__c.Name`.
- [Monto del anticipo] -> `Anticipo__c.Monto__c` o campo equivalente.
- [Referencia del anticipo] -> `Anticipo__c.Referencia_Comprobante__c` o campo equivalente.
- [Fecha de registro] -> `Anticipo__c.Fecha_Ingreso__c` o campo equivalente.

## Correo 2 — Producto / reserva rechazada

### Propósito

Notificar al vendedor que la solicitud de aprobación de reserva fue rechazada, incluyendo motivo y detalle de la reserva.

### Disparador funcional esperado

Cuando el estado de aprobación de producto/reserva cambia a Rechazada.

### Texto funcional

Asunto sugerido:

Solicitud de reserva rechazada

Cuerpo:

Estimado/a [Nombre del vendedor],

La solicitud de aprobación de reserva para la oportunidad [Nombre o número de oportunidad] fue rechazada.

Motivo del rechazo:

[Indicar motivo del rechazo]

Detalle de la reserva:

- Cliente: [Nombre del cliente]
- VIN solicitado: [VIN]
- Oportunidad: [Nombre o número de oportunidad]
- Link de la oportunidad: [Link de la oportunidad]

Por favor realizar la gestión correspondiente o corregir la información indicada para que la solicitud pueda ser enviada nuevamente a aprobación.

Saludos,

[Nombre del Jefe de Producto]

### Variables Salesforce sugeridas

- [Nombre del vendedor] -> `Opportunity.Owner.Name`.
- [Nombre o número de oportunidad] -> `Opportunity.Name`.
- [Indicar motivo del rechazo] -> `Anticipo__c.Comentarios_Aprobacion_Rechazo__c`.
- [Nombre del cliente] -> `Opportunity.Account.Name`.
- [VIN solicitado] -> Producto/Vehículo/VIN asociado a la solicitud.
- [Link de la oportunidad] -> URL del registro `Opportunity`.
- [Nombre del Jefe de Producto] -> `Opportunity.JefeSucursal__r.Name` o usuario aprobador/rechazador según definición funcional.

## Pendientes funcionales

- Confirmar destinatarios exactos de cada correo.
- Confirmar si el correo de reenvío se envía al Jefe de Producto/JefeSucursal.
- Confirmar si el correo de rechazo se envía únicamente al vendedor o también a GerenteSucursal.
- Confirmar texto para reserva aprobada, si aplica.
- Confirmar si se requiere notificación interna adicional además del correo.
- Confirmar si el disparador será Flow o Apex.

## Pendientes técnicos

- Revisar Flow `VN_RQ106_Notificaciones_Anticipo`.
- Quitar cualquier destinatario temporal de pruebas antes de activar.
- Validar condiciones de colección/destinatarios.
- Evitar notificar al usuario que ejecuta la acción.
- Probar en Sandbox antes de cualquier pase.

## Criterio de aceptación

- El correo de reenvío se envía con datos correctos de oportunidad, VIN, vendedor y anticipo.
- El correo de rechazo se envía con motivo de rechazo, cliente, VIN y link de oportunidad.
- No se envían correos duplicados.
- No se envía correo al usuario ejecutor si está dentro de los destinatarios excluidos.
- No existen destinatarios temporales de prueba.
- El comportamiento queda validado en Sandbox con evidencia.
