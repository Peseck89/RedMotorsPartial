# VN-RQ106 - Matriz final de notificaciones pendientes

Fecha: 2026-05-29

Contexto: el documento oficial estima 10h para "Notificaciones y correos aprobaciones y rechazos".
Produccion no fue modificada.

Estado probado en Sandbox:
- Flow `VN_RQ106_Notificaciones_Anticipo` v2 activo en `RedMotorsSandbox`.
- Correos al asesor enviados desde Org-Wide Email Address `info@redmotorscr.com`.
- Custom Notifications enviadas con `Redmotors_Notification`.
- Guarda temporal de prueba: solo notifica si `Opportunity.Owner.Username = 'peseck89@gmail.com.redmotors.partial'`.
- Escenarios al asesor probados sin error de Flow: `Confirmada por Tesoreria`, `Correccion requerida por Tesoreria`, `Rechazada por Tesoreria`, `Anticipo creado`, `Reserva rechazada`.

## Matriz para Luis/Diego

| Notificacion/correo solicitado | Estado actual | Que falta definir | Pregunta exacta | Recomendacion tecnica rapida |
|---|---|---|---|---|
| Solicitud a Tesoreria cuando asesor envia anticipo | Bloqueado | Destinatario real, canal y plantilla. Diego menciono "admin" temporal, pero no es definicion final | Luis/Diego: para Tesoreria, usamos correo fijo, usuario, cola, grupo publico o regla por sucursal/marca? Cual es el email/Id definitivo? | Agregar rama en el Flow al pasar a `En validacion de Tesoreria`; usar emailSimple con Org-Wide Sender y destinatario configurable |
| Aprobacion de Tesoreria | Implementado y probado | Retirar guarda temporal antes de produccion; confirmar texto final | Luis/Diego: el texto inline actual al asesor es suficiente o debe usar plantilla oficial? | Mantener rama `Confirmada por Tesoreria` en el Flow; solo ajustar texto/template y quitar guarda temporal |
| Rechazo de Tesoreria | Implementado y probado | Confirmar si motivo/comentario es obligatorio y que campo usar | Luis/Diego: al rechazar, debe ser obligatorio capturar motivo? Usamos `Comentarios_Aprobacion_Rechazo__c`? | Mantener rama `Rechazada por Tesoreria`; agregar validacion/requirement de motivo si negocio lo confirma |
| Correccion requerida por Tesoreria | Implementado y probado | Confirmar si comentario de correccion es obligatorio y quien puede editar/corregir | Luis/Diego: para correccion, que comentario debe recibir el asesor y en que campo queda registrado? | Mantener rama `Correccion requerida por Tesoreria`; usar el mismo campo de comentarios si se confirma |
| Creacion de anticipo por Softland / confirmacion de fondos | Implementado y probado para asesor en estado `Anticipo creado`; pendiente definicion Softland | Evento exacto que actualiza el estado, destinatarios adicionales y si cliente recibe correo | Diego: cuando Softland confirma fondos/crea anticipo, que sistema/campo actualiza `Estatus__c` y quien debe recibir aviso ademas del asesor? | Mantener rama `Anticipo creado`; agregar cliente/Tesoreria solo si Diego confirma evento y destinatarios |
| Error al obtener PDF anticipo | Bloqueado | Estado/campo que representa error PDF, destinatario, texto y link/log de error | Diego: que estado o campo indicara error al obtener PDF y quien debe recibir la alerta? | Crear rama separada por estado/campo de error PDF; no implementar hasta tener fuente del error |
| Error de integracion | Bloqueado | Evento tecnico, destinatarios de soporte/operacion, contenido minimo y reintentos | Diego: que campo/estado indicara error de integracion, quien lo atiende y que datos deben ir en el correo? | Crear rama tecnica separada; preferir notificacion a grupo/cola o correo de soporte configurable |
| Jefe de Producto aprueba o rechaza reserva | Parcialmente bloqueado | PEV/Jefe de Producto final por marca, especialmente Indian, Autos_Usados y Motos_Usados; definir aprobacion/rechazo | Luis/Diego: cuales son los destinatarios PEV/Jefe de Producto por marca y que estados exactos disparan aprobacion/rechazo de reserva? | Extender Flow o integrar con flujo de reserva existente; no activar PEV hasta confirmar todos los destinatarios |
| Reserva rechazada | Implementado y probado para asesor | Confirmar si tambien debe avisar a PEV/Tesoreria y si requiere motivo obligatorio | Luis/Diego: reserva rechazada notifica solo al asesor o tambien a PEV/Tesoreria? Debe incluir motivo obligatorio? | Mantener rama `Reserva rechazada`; agregar destinatarios solo con definicion de negocio |

## Preguntas bloqueantes

1. Tesoreria: cual es el destinatario definitivo y si debe ser correo fijo, usuario, cola, grupo o regla por sucursal/marca?
2. Plantillas: los correos pueden quedar inline en Flow o requieren Email Templates/formato oficial?
3. Comentarios/motivos: rechazo, correccion y reserva rechazada deben exigir motivo obligatorio? En que campo?
4. Cliente: debe recibir correo en algun evento? De que contacto se toma el email y que pasa si no tiene correo?
5. PEV/Jefe de Producto: cuales son los destinatarios definitivos para BMW, MINI, Motorrad, Kawasaki, Polaris, Indian, Autos_Usados y Motos_Usados?
6. Softland: que evento/campo confirma fondos y creacion de anticipo? Quien actualiza el estado?
7. PDF/error integracion: que campo/estado dispara cada error y quien debe recibir la alerta?

## Cierre parcial de esta semana

Se puede cerrar como completado:
- Flow de notificaciones al asesor creado y activo en Sandbox.
- Cinco escenarios al asesor probados sin error de Flow.
- Sender corregido con Org-Wide Email Address `info@redmotorscr.com`.
- Produccion sin cambios.
- Pendientes de Tesoreria, PEV, cliente, PDF, integracion y motivos documentados para decision de negocio.
