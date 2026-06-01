# VN-RQ106 - Matriz final de notificaciones pendientes

Fecha: 2026-05-29
Ultima actualizacion: 2026-06-01 — notificacion a Tesoreria y Vehiculo reservado implementadas; estado de matriz actualizado.

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
| Solicitud a Tesoreria cuando asesor envia anticipo | **Implementado en Sandbox** — rama activa en Flow al pasar a `En validacion de Tesoreria`; email a `admin@portalnetcr.com`, Org-Wide Sender `info@redmotorscr.com`, texto inline | Correo grupal definitivo pendiente antes de deploy productivo. | Validar QA en Sandbox; confirmar correo grupal antes de produccion | Implementado; correo definitivo pendiente |
| Aprobacion de Tesoreria | Implementado y probado | Retirar guarda temporal antes de produccion. Texto inline aprobado para ahora. | Mantener; retirar guarda cuando se apruebe para produccion | Mantener rama `Confirmada por Tesoreria`; solo quitar guarda temporal |
| Rechazo de Tesoreria | Implementado y probado | Motivo/comentario obligatorio: **por validar** | Esperar confirmacion de si es obligatorio | Mantener rama `Rechazada por Tesoreria`; agregar validacion solo si negocio confirma |
| Correccion requerida por Tesoreria | Implementado y probado | Motivo/comentario obligatorio: **por validar** | Esperar confirmacion de si es obligatorio | Mantener rama `Correccion requerida por Tesoreria`; no cambiar hasta confirmar |
| Creacion de anticipo por Softland / confirmacion de fondos | Implementado para asesor en estado `Anticipo creado`; Softland pendiente | Evento exacto que actualiza el estado; destinatarios adicionales; correo a cliente | Esperar confirmacion de Diego/Softland | Mantener rama `Anticipo creado`; agregar cliente/Tesoreria solo si Diego confirma evento |
| Error al obtener PDF anticipo | Bloqueado | Estado/campo que representa error PDF, destinatario y fuente del error | Diego/Softland define | Crear rama separada; no implementar hasta tener fuente del error |
| Error de integracion | Bloqueado | Evento tecnico, destinatarios, contenido minimo | Diego/Softland define | Crear rama tecnica separada; preferir notificacion a grupo/cola configurable |
| Jefe de Producto / PEV aprueba reserva (`Vehiculo reservado`) | **Implementado en Sandbox** — `Opportunity.JefeSucursal__c` confirmado por Maria 2026-06-01; asesor + JefeSucursal__c sin duplicar | Verificar datos reales de `Indian` en Sandbox cuando esten disponibles | Validar QA en Sandbox | Implementado con logica dinamica por Record Type |
| Reserva rechazada | Implementado y probado para asesor | Motivo obligatorio: **por validar**. Confirmar si avisa a PEV/Tesoreria. | Esperar confirmacion | Mantener rama `Reserva rechazada`; agregar destinatarios solo con definicion |
| Correo al cliente | **Desbloqueado** — usar correo de contacto; si no tiene, no se envia | Definir en que estado(s) se envia; lookup exacto del contacto | Confirmar estado(s) disparadores y que contacto usar | Agregar rama en el Flow para el estado correspondiente; verificar campo de email del contacto relacionado |

## Preguntas bloqueantes — estado actualizado

| # | Pregunta | Estado |
|---|---|---|
| 1 | Tesoreria destinatario definitivo | **Resuelto temporal**: `admin@portalnetcr.com`. Correo grupal definitivo pendiente. |
| 2 | Plantillas: inline en Flow o Email Templates? | **Resuelto temporal**: inline en Flow por ahora. Plantillas oficiales solicitadas pero pendientes. |
| 3 | Comentarios/motivos obligatorios para rechazo, correccion y reserva rechazada | **Sigue bloqueado**: por validar. |
| 4 | Cliente: en que evento recibe correo y lookup exacto del contacto | **Parcialmente resuelto**: usar correo de contacto; si no tiene, no enviar. Falta confirmar estado(s) disparadores y que contacto relacionado usar. |
| 5 | Jefe de Producto / PEV: campos y ejemplos por Record Type | **Resuelto 2026-06-01**: Maria confirmo `Opportunity.JefeSucursal__c` como destinatario. Implementado en Flow para `Vehiculo reservado`. Pendiente verificar datos de `Indian` en Sandbox. |
| 6 | Softland: evento/campo confirma fondos y creacion de anticipo | **Sigue bloqueado**: alcance Diego/Softland. |
| 7 | PDF/error integracion: campo/estado disparador y destinatario | **Sigue bloqueado**: alcance Diego/Softland. |

## Cierre de fase actual — actualizado 2026-06-01

Cerrado como completado:
- Flow de notificaciones al asesor creado y activo en Sandbox (5 escenarios probados).
- Notificacion a Tesoreria al pasar a `En validacion de Tesoreria` implementada (`admin@portalnetcr.com`, texto inline).
- Notificacion de aprobacion de reserva (`Vehiculo reservado`) implementada: asesor + `JefeSucursal__c` sin duplicar.
- Sender corregido con Org-Wide Email Address `info@redmotorscr.com`.
- Produccion sin cambios.
- Respuestas de Tesoreria, plantillas, cliente y PEV recibidas e incorporadas.

Sigue bloqueado para siguiente iteracion:
- Motivo/comentario obligatorio para rechazo, correccion y reserva rechazada: por validar.
- Correo al cliente: comportamiento sin correo resuelto; falta definir estado(s) disparadores y lookup exacto.
- PDF y error de integracion: alcance Diego/Softland.
- Correo grupal definitivo de Tesoreria: `admin@portalnetcr.com` es temporal.
- Datos reales de `Indian` en Sandbox para validar PEV.
- Guarda temporal de Claudia: retirar antes de deploy productivo.
