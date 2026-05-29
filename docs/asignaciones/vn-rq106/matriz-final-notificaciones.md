# VN-RQ106 - Matriz final de notificaciones pendientes

Fecha: 2026-05-29
Ultima actualizacion de respuestas: 2026-05-29 — respuestas recibidas de Luis/equipo.

Contexto: el documento oficial estima 10h para "Notificaciones y correos aprobaciones y rechazos".
Produccion no fue modificada.

Estado probado en Sandbox:
- Flow `VN_RQ106_Notificaciones_Anticipo` v2 activo en `RedMotorsSandbox`.
- Correos al asesor enviados desde Org-Wide Email Address `info@redmotorscr.com`.
- Custom Notifications enviadas con `Redmotors_Notification`.
- Guarda temporal de prueba: solo notifica si `Opportunity.Owner.Username = 'peseck89@gmail.com.redmotors.partial'`.
- Escenarios al asesor probados sin error de Flow: `Confirmada por Tesoreria`, `Correccion requerida por Tesoreria`, `Rechazada por Tesoreria`, `Anticipo creado`, `Reserva rechazada`.

## Respuestas recibidas — 2026-05-29

| # | Pregunta | Respuesta | Estado |
|---|---|---|---|
| 1 | Destinatario Tesoreria | Por el momento enviar a `admin@portalnetcr.com`. El correo grupal definitivo esta pendiente. | **Desbloqueado temporal** |
| 2 | Plantillas de correo | Directo en el Flow por ahora. Las plantillas oficiales ya se solicitaron, pero estan pendientes. | **Desbloqueado temporal** |
| 3 | Motivo/comentario obligatorio | Por validar. | **Sigue bloqueado** |
| 4 | Jefe de Producto / PEV | Usar campos de jefe de sucursal indicados en la tabla de campos; cambia por Record Type. Maria puede pasar ejemplos. | **Parcialmente desbloqueado** — falta confirmar campo exacto y ver ejemplos de Maria |
| 5 | Cliente | Usar correo de contacto. Si no tiene correo, no se envia. | **Desbloqueado** |

## Matriz para Luis/Diego

| Notificacion/correo solicitado | Estado actual | Que falta definir | Proxima accion | Recomendacion tecnica |
|---|---|---|---|---|
| Solicitud a Tesoreria cuando asesor envia anticipo | **Desbloqueado temporal** — `admin@portalnetcr.com` confirmado para ahora | Correo grupal definitivo pendiente. Texto inline aprobado por ahora. | Agregar rama en el Flow al pasar a `En validacion de Tesoreria` con email a `admin@portalnetcr.com` | Agregar rama en el Flow al pasar a `En validacion de Tesoreria`; usar emailSimple con Org-Wide Sender; texto inline |
| Aprobacion de Tesoreria | Implementado y probado | Retirar guarda temporal antes de produccion. Texto inline aprobado para ahora. | Mantener; retirar guarda cuando se apruebe para produccion | Mantener rama `Confirmada por Tesoreria`; solo quitar guarda temporal |
| Rechazo de Tesoreria | Implementado y probado | Motivo/comentario obligatorio: **por validar** | Esperar confirmacion de si es obligatorio | Mantener rama `Rechazada por Tesoreria`; agregar validacion solo si negocio confirma |
| Correccion requerida por Tesoreria | Implementado y probado | Motivo/comentario obligatorio: **por validar** | Esperar confirmacion de si es obligatorio | Mantener rama `Correccion requerida por Tesoreria`; no cambiar hasta confirmar |
| Creacion de anticipo por Softland / confirmacion de fondos | Implementado para asesor en estado `Anticipo creado`; Softland pendiente | Evento exacto que actualiza el estado; destinatarios adicionales; correo a cliente | Esperar confirmacion de Diego/Softland | Mantener rama `Anticipo creado`; agregar cliente/Tesoreria solo si Diego confirma evento |
| Error al obtener PDF anticipo | Bloqueado | Estado/campo que representa error PDF, destinatario y fuente del error | Diego/Softland define | Crear rama separada; no implementar hasta tener fuente del error |
| Error de integracion | Bloqueado | Evento tecnico, destinatarios, contenido minimo | Diego/Softland define | Crear rama tecnica separada; preferir notificacion a grupo/cola configurable |
| Jefe de Producto / PEV aprueba o rechaza reserva | **Parcialmente desbloqueado** — usar campo `JefeSucursal__c` (u equivalente) en Opportunity por Record Type | Campo exacto a usar; ejemplos de Maria para confirmacion; Indian/Usados sin definicion | Revisar campos reales en Sandbox; esperar ejemplos de Maria | No implementar PEV hasta ver ejemplos de Maria y confirmar campo exacto |
| Reserva rechazada | Implementado y probado para asesor | Motivo obligatorio: **por validar**. Confirmar si avisa a PEV/Tesoreria. | Esperar confirmacion | Mantener rama `Reserva rechazada`; agregar destinatarios solo con definicion |
| Correo al cliente | **Desbloqueado** — usar correo de contacto; si no tiene, no se envia | Definir en que estado(s) se envia; lookup exacto del contacto | Confirmar estado(s) disparadores y que contacto usar | Agregar rama en el Flow para el estado correspondiente; verificar campo de email del contacto relacionado |

## Preguntas bloqueantes — estado actualizado

| # | Pregunta | Estado |
|---|---|---|
| 1 | Tesoreria destinatario definitivo | **Resuelto temporal**: `admin@portalnetcr.com`. Correo grupal definitivo pendiente. |
| 2 | Plantillas: inline en Flow o Email Templates? | **Resuelto temporal**: inline en Flow por ahora. Plantillas oficiales solicitadas pero pendientes. |
| 3 | Comentarios/motivos obligatorios para rechazo, correccion y reserva rechazada | **Sigue bloqueado**: por validar. |
| 4 | Cliente: en que evento recibe correo y lookup exacto del contacto | **Parcialmente resuelto**: usar correo de contacto; si no tiene, no enviar. Falta confirmar estado(s) disparadores y que contacto relacionado usar. |
| 5 | Jefe de Producto / PEV: campos y ejemplos por Record Type | **Parcialmente resuelto**: usar campos de jefe de sucursal que cambian por Record Type. Falta ver ejemplos de Maria y confirmar campo exacto. |
| 6 | Softland: evento/campo confirma fondos y creacion de anticipo | **Sigue bloqueado**: alcance Diego/Softland. |
| 7 | PDF/error integracion: campo/estado disparador y destinatario | **Sigue bloqueado**: alcance Diego/Softland. |

## Cierre parcial de esta semana

Se puede cerrar como completado:
- Flow de notificaciones al asesor creado y activo en Sandbox.
- Cinco escenarios al asesor probados sin error de Flow.
- Sender corregido con Org-Wide Email Address `info@redmotorscr.com`.
- Produccion sin cambios.
- Respuestas de Tesoreria, plantillas y cliente recibidas el 2026-05-29 e incorporadas.

Desbloqueado para siguiente iteracion tecnica:
- Notificacion de solicitud a Tesoreria: se puede agregar al Flow con `admin@portalnetcr.com` y texto inline.
- Comportamiento de cliente sin correo: si no tiene, no se envia.
- Plantillas: confirmar que todos los correos van inline sin esperar EmailTemplates.

Sigue bloqueado para siguiente iteracion:
- Motivo/comentario obligatorio: por validar.
- Campo exacto de Jefe de Producto/PEV por Record Type: esperar ejemplos de Maria.
- PDF y error de integracion: alcance Diego/Softland.
