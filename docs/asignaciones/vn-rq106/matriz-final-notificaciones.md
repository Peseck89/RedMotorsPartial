# VN-RQ106 - Matriz final de notificaciones pendientes

Fecha: 2026-05-29
Ultima actualizacion: 2026-06-02 — feedback oficial de Maria y PDF `ProyectoEnvioCorreoReserva`: Salesforce conserva 3 notificaciones; el resto lo envia Helios/otro programa.

Contexto: el documento oficial estima 10h para "Notificaciones y correos aprobaciones y rechazos".
Produccion no fue modificada.

Estado probado en Sandbox:
- Flow `VN_RQ106_Notificaciones_Anticipo` v6 activo en `RedMotorsSandbox`.
- Correos al asesor enviados desde Org-Wide Email Address `info@redmotorscr.com`.
- Custom Notifications enviadas con `Redmotors_Notification`.
- Guarda temporal de prueba: solo notifica si `Opportunity.Owner.Username = 'peseck89@gmail.com.redmotors.partial'`.
- Escenarios Salesforce vigentes: `En validacion de Tesoreria`, `Vehiculo reservado`, `Reserva rechazada`.
- Escenarios anteriores probados como antecedente, pero retirados del Flow Salesforce por feedback 2026-06-02: `Confirmada por Tesoreria`, `Correccion requerida por Tesoreria`, `Rechazada por Tesoreria`, `Anticipo creado`.

## Respuestas recibidas — 2026-05-29

| # | Pregunta | Respuesta | Estado |
|---|---|---|---|
| 1 | Destinatario Tesoreria | Antecedente 2026-05-29: usar `admin@portalnetcr.com` temporalmente. Actualizado por feedback Maria 2026-06-02: usar `grupo.cajas@redmotorscr.com`. | **Resuelto para Salesforce v6** |
| 2 | Plantillas de correo | Directo en el Flow por ahora. Las plantillas oficiales ya se solicitaron, pero estan pendientes. | **Desbloqueado temporal** |
| 3 | Motivo/comentario obligatorio | Por validar. | **Sigue bloqueado** |
| 4 | Jefe de Producto / PEV | Usar campos de jefe de sucursal indicados en la tabla de campos; cambia por Record Type. Maria puede pasar ejemplos. | **Parcialmente desbloqueado** — falta confirmar campo exacto y ver ejemplos de Maria |
| 5 | Cliente | Usar correo de contacto. Si no tiene correo, no se envia. | **Desbloqueado** |

## Matriz para Luis/Diego/Maria

| Notificacion/correo solicitado | Estado actual | Que falta definir | Proxima accion | Recomendacion tecnica |
|---|---|---|---|---|
| Solicitud a Tesoreria cuando asesor envia anticipo | **Implementado en Salesforce Sandbox** — rama activa en Flow v6 al pasar a `En validacion de Tesoreria`; email a `grupo.cajas@redmotorscr.com`, Org-Wide Sender `info@redmotorscr.com`, texto inline | Retirar guarda temporal antes de produccion | Validar QA en Sandbox | Mantener rama Salesforce |
| Aprobacion de Tesoreria | **Fuera del Flow Salesforce** por feedback Maria 2026-06-02 | Lo envia Helios/otro programa | No evidenciar en Salesforce | No reactivar rama `Confirmada por Tesoreria` salvo nueva instruccion oficial |
| Rechazo de Tesoreria | **Fuera del Flow Salesforce** por feedback Maria 2026-06-02 | Lo envia Helios/otro programa | No evidenciar en Salesforce | No reactivar rama `Rechazada por Tesoreria` salvo nueva instruccion oficial |
| Correccion requerida por Tesoreria | **Fuera del Flow Salesforce** por feedback Maria 2026-06-02 | Lo envia Helios/otro programa | No evidenciar en Salesforce | No reactivar rama `Correccion requerida por Tesoreria` salvo nueva instruccion oficial |
| Creacion de anticipo por Softland / confirmacion de fondos | **Fuera del Flow Salesforce** por feedback Maria 2026-06-02 | Lo envia Helios/otro programa | No evidenciar en Salesforce | No reactivar rama `Anticipo creado` salvo nueva instruccion oficial |
| Error al obtener PDF anticipo | **Fuera del Flow Salesforce** | Alcance Diego/Softland/Helios | Evidencia externa si aplica | No implementar en Salesforce |
| Error de integracion | **Fuera del Flow Salesforce** | Alcance Diego/Softland/Helios | Evidencia externa si aplica | No implementar en Salesforce |
| Jefe de Producto / PEV aprueba reserva (`Vehiculo reservado`) | **Implementado en Salesforce Sandbox** — asesor + `Opportunity.JefeSucursal__c` sin duplicar | Retirar guarda temporal antes de produccion | Validar QA en Sandbox | Mantener rama Salesforce |
| Reserva rechazada | **Implementado en Salesforce Sandbox** — asesor + `Opportunity.JefeSucursal__c` sin duplicar | Motivo obligatorio: **por validar** si negocio lo requiere | Validar QA en Sandbox | Mantener rama Salesforce |
| Correo al cliente | **Fuera del Flow Salesforce** por feedback Maria 2026-06-02 | Lo envia Helios/otro programa si aplica | No evidenciar en Salesforce | No agregar rama en este Flow |

## Preguntas bloqueantes — estado actualizado

| # | Pregunta | Estado |
|---|---|---|
| 1 | Tesoreria destinatario definitivo | **Resuelto 2026-06-02**: `grupo.cajas@redmotorscr.com` para la rama Salesforce de solicitud enviada a Tesoreria. |
| 2 | Plantillas: inline en Flow o Email Templates? | **Resuelto temporal**: inline en Flow por ahora. Plantillas oficiales solicitadas pero pendientes. |
| 3 | Comentarios/motivos obligatorios para reserva rechazada | **Sigue bloqueado**: por validar. |
| 4 | Cliente: en que evento recibe correo y lookup exacto del contacto | **Fuera Salesforce** por feedback 2026-06-02; Helios/otro programa lo cubre si aplica. |
| 5 | Jefe de Producto / PEV: campos y ejemplos por Record Type | **Resuelto 2026-06-01**: Maria confirmo `Opportunity.JefeSucursal__c` como destinatario. Implementado en Flow para `Vehiculo reservado`. Pendiente verificar datos de `Indian` en Sandbox. |
| 6 | Softland: evento/campo confirma fondos y creacion de anticipo | **Fuera Salesforce**: alcance Diego/Softland/Helios. |
| 7 | PDF/error integracion: campo/estado disparador y destinatario | **Fuera Salesforce**: alcance Diego/Softland/Helios. |

## Cierre de fase actual — actualizado 2026-06-02

Cerrado como completado:
- Flow de notificaciones Salesforce v6 activo en Sandbox con 3 escenarios.
- Notificacion a Tesoreria al pasar a `En validacion de Tesoreria` implementada (`grupo.cajas@redmotorscr.com`, texto inline).
- Notificacion de aprobacion de reserva (`Vehiculo reservado`) implementada: asesor + `JefeSucursal__c` sin duplicar.
- Notificacion de rechazo de reserva (`Reserva rechazada`) implementada: asesor + `JefeSucursal__c` sin duplicar.
- Sender corregido con Org-Wide Email Address `info@redmotorscr.com`.
- Produccion sin cambios.
- Feedback Maria 2026-06-02 incorporado: Helios/otro programa envia las notificaciones fuera del Flow Salesforce.

Sigue bloqueado para siguiente iteracion:
- Motivo/comentario obligatorio para reserva rechazada: por validar.
- PDF y error de integracion: alcance Diego/Softland/Helios, fuera de Salesforce.
- Datos reales de `Indian` en Sandbox para validar PEV.
- Guarda temporal de Claudia: retirar antes de deploy productivo.
