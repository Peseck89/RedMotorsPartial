# VN-RQ106 - Notificaciones y Correos: Estado y Bloqueantes

Este documento consolida el análisis de notificaciones/correos para VN-RQ106.
Sirve como referencia operativa antes de implementar cualquier correo, Flow de notificación o EmailTemplate.

Fecha de análisis inicial: 2026-05-28
Última actualización: 2026-05-29 — Respuestas de negocio recibidas; bloqueantes actualizados.
Fuente de instrucción: Luis Sandoval / sesión PC.

---

## Decisión actual

El bloque inicial de notificaciones al asesor ya quedó implementado por Flow y probado en `RedMotorsSandbox`.
Producción no fue modificada.

Flow activo en Sandbox:
- `VN_RQ106_Notificaciones_Anticipo`
- Versión activa: v2
- Objeto: `Anticipo__c`
- Tipo: Record-Triggered Flow after update
- Condición base: ejecutar cuando cambia `Estatus__c`
- Destinatario implementado: asesor / `Opportunity.Owner`
- Canales implementados: email simple y Custom Notification
- Custom Notification Type: `Redmotors_Notification`
- Remitente email: Org-Wide Email Address `info@redmotorscr.com`

El Flow conserva una guarda temporal de prueba:
- Solo continúa si `Opportunity.Owner.Username = 'peseck89@gmail.com.redmotors.partial'`.
- Esta guarda debe retirarse o ajustarse antes de una activación final para producción.

---

## Respuestas de Diego — 2026-05-28

| # | Pregunta original | Respuesta de Diego |
|---|---|---|
| 1 | ¿Tesorería es correo fijo, variable, grupo o cola? | Por el momento usar correo fijo "admin". |
| 2 | ¿Correo del cliente, fuente? | Tomarlo del contacto relacionado con la oportunidad. |
| 3 | ¿Qué pasa si cliente no tiene correo? | Sin respuesta explícita. Pendiente. |
| 4 | ¿Plantilla de correo definida? | Pendiente — parece que sale de otro sistema. No implementar todavía. |
| 5 | ¿Notificaciones en Flow o Apex? | Siempre en Flow para que sean más sencillas de ajustar. |
| 6 | ¿Base para Saldo pendiente / precio de venta? | Usar `Opportunity.Valor_Total_Oportunidad_FX__c`. |

---

## Respuestas recibidas — 2026-05-29

| # | Pregunta | Respuesta | Impacto |
|---|---|---|---|
| 1 | Destinatario Tesorería | Por el momento enviar a `admin@portalnetcr.com`. El correo grupal definitivo está pendiente. | **Desbloquea** la notificación de solicitud a Tesorería. Email temporal conocido; puede cambiar a futuro. |
| 2 | Plantillas de correo | Directo en el Flow por ahora. Las plantillas oficiales ya se solicitaron pero están pendientes. | **Desbloquea** todos los correos pendientes que esperaban confirmación de template. Textos inline aprobados. |
| 3 | Motivo/comentario obligatorio | Por validar. | Sigue bloqueado. No cambiar obligatoriedad en Flow ni Validation Rule hasta confirmación. |
| 4 | Jefe de Producto / PEV | Usar campos de jefe de sucursal indicados en la tabla de campos; cambia por Record Type. María puede pasar ejemplos. | **Parcialmente desbloquea** el diseño de PEV. Arquitectura confirmada: campo dinámico en Opportunity, no hardcoded. Falta confirmar campo exacto y ver ejemplos de María. |
| 5 | Cliente | Usar correo de contacto. Si no tiene correo, no se envía. | **Desbloquea** el comportamiento de cliente sin correo. Lógica de Flow: verificar email antes de enviar; si vacío, omitir rama. |

---

## Fuentes revisadas

| Fuente | Detalle |
|---|---|
| `docs/asignaciones/vn-rq106/requerimiento-campos.md` | Secciones 5 (bloqueantes), 7.1 (Tesorería), estados confirmados |
| `WORK_LOG.md` | Cierre de sesión 2026-05-27 |
| `CLAUDE.md` / `AI_HANDOFF.md` | Contexto general del proyecto |
| `VN_RQ106_AnticipoController.cls` | SOQL disponibles, métodos actuales, campos consultados |
| `Alerta_de_reserva_de_producto_de_Oportunidad.flow-meta.xml` | Flujo email existente para reserva (status DRAFT) |
| `Anticipo_Separar_Producto.flow-meta.xml` | Flujo que activa reserva de producto |
| `EnviarNotiAprobacion.cls` | Patrón HTML email Apex para descuentos (referencia de estructura) |
| `EnviarNotificacionDeAprobacion.cls` | Patrón email simple para descuentos |
| `VN_RQ106_Anticipo.permissionset-meta.xml` | Campos con permisos en Anticipo__c |
| `emailTemplates/` en repo | Vacío — no hay EmailTemplates en el repo local |
| `customMetadata/` en repo | Vacío — no hay Custom Metadata de destinatarios |
| Respuestas de Diego | 2026-05-28, incorporadas en este documento |

---

## Eventos que deben disparar notificaciones

| # | Estado de `Anticipo__c.Estatus__c` | Destinatario implementado | Canal | Estado actualizado |
|---|---|---|---|---|
| 1 | `Confirmada por Tesorería` | Asesor / `Opportunity.Owner` | Email + Custom Notification | Implementado y probado en Sandbox |
| 2 | `Corrección requerida por Tesorería` | Asesor / `Opportunity.Owner` | Email + Custom Notification | Implementado y probado en Sandbox |
| 3 | `Rechazada por Tesorería` | Asesor / `Opportunity.Owner` | Email + Custom Notification | Implementado y probado en Sandbox |
| 4 | `Anticipo creado` | Asesor / `Opportunity.Owner` | Email + Custom Notification | Implementado y probado en Sandbox |
| 5 | `Reserva rechazada` | Asesor / `Opportunity.Owner` | Email + Custom Notification | Implementado y probado en Sandbox |
| 6 | `Borrador → En validación de Tesorería` (asesor envía) | Tesorería | Pendiente | Bloqueado por destinatario/plantilla final |
| 7 | `→ Vehículo reservado` | Asesor + PEV por marca | Pendiente | Bloqueado por PEV Indian/Usados y diseño final |
| 8 | `→ Error de integración` | Diego / soporte técnico | Pendiente | Alcance Diego / Softland |
| 9 | Error PDF / PDF disponible | Asesor o soporte | Pendiente | Alcance Diego / Softland; plantilla de otro sistema |

---

## Prueba controlada en Sandbox — 2026-05-28/29

Data usada:

| Registro | Id | Detalle |
|---|---|---|
| Account | `001Nq00001Qj49dIAB` | `VN-RQ106 TEST Claudia` |
| Opportunity | `006Nq00000XbTo1IAF` | `VN-RQ106 TEST Claudia Opportunity`; owner `peseck89@gmail.com.redmotors.partial` |
| Quote | `0Q0Nq000003tMxRKAU` | Quote de prueba para cumplir `Opportunity.Synced_Quote__c` |

Anticipos de prueba:

| Anticipo | Id | Escenario | Estado final probado |
|---|---|---|---|
| `ANT-01152` | `a4JNq000000X9J3MAK` | `TEST Confirmada por Tesorería` | `Confirmada por Tesorería` |
| `ANT-01153` | `a4JNq000000X9J4MAK` | `TEST Corrección requerida por Tesorería` | `Corrección requerida por Tesorería` |
| `ANT-01154` | `a4JNq000000X9J5MAK` | `TEST Rechazada por Tesorería` | `Rechazada por Tesorería` |
| `ANT-01155` | `a4JNq000000X9J6MAK` | `TEST Anticipo creado` | `Anticipo creado` |
| `ANT-01156` | `a4JNq000000X9J7MAK` | `TEST Reserva rechazada` | `Reserva rechazada` |

Resultado:
- Los cinco updates de `Estatus__c` fueron exitosos.
- No hubo error de Flow devuelto en las transacciones.
- El rebote inicial de Gmail se corrigió en v2 usando remitente Org-Wide `info@redmotorscr.com`.
- Producción no fue modificada.

---

## Destinatarios — estado actualizado

| Destinatario | Cómo se obtiene | Estado |
|---|---|---|
| Tesorería | `admin@portalnetcr.com` — correo fijo temporal confirmado 2026-05-29 | **Desbloqueado temporal** — correo grupal definitivo pendiente |
| Asesor / Opportunity Owner | `Opportunity.Owner.Email` y `Opportunity.OwnerId` | Implementado y probado en `VN_RQ106_Notificaciones_Anticipo` v2 |
| Cliente | Candidato principal: `Opportunity.CorreoElectronicoCliente__c`. Alternativo: `Opportunity.contacto__r.Email`. Si no tiene correo, no se envía. | **Parcialmente desbloqueado por auditoría read-only 2026-05-29.** Falta confirmar prioridad cuando Opportunity, Contact y Account no coinciden. |
| Jefe de Producto / PEV por marca | Candidato: `Opportunity.JefeSucursal__c` / `Opportunity.JefeSucursal__r.Email`. Campo poblado dinámicamente por la lógica existente de sucursal/Record Type. | **Parcialmente desbloqueado por auditoría read-only 2026-05-29** — confirmar con María que este es el destinatario PEV/Jefe Producto del proyecto. |
| Jefe de Sucursal | `Opportunity.JefeSucursal__c` / `Opportunity.JefeSucursal__r.Email` | Campo existe y tiene datos reales en BMW, MINI, Motorrad, Polaris, Autos_Usados y Motos_Usados. Candidato PEV/Jefe Producto. |
| Gerente de Sucursal | `Opportunity.GerenteSucursal__c` / `Opportunity.GerenteSucursal__r.Email` | Candidato para fallback/autonotificación. No usar como PEV sin confirmación de negocio. |

### Auditoría read-only de campos PEV/Jefe Producto y cliente — 2026-05-29

Consultas realizadas solo en `RedMotorsSandbox`. No se modificó metadata, no hubo deploy, no hubo commit y no se tocó Producción.

| Tema | Resultado |
|---|---|
| Jefe Producto / PEV candidato | `Opportunity.JefeSucursal__c` / `Opportunity.JefeSucursal__r.Email`. |
| Gerente candidato fallback/autonotificación | `Opportunity.GerenteSucursal__c` / `Opportunity.GerenteSucursal__r.Email`. |
| Correo cliente candidato principal | `Opportunity.CorreoElectronicoCliente__c`. |
| Contacto alternativo | `Opportunity.contacto__r.Email`. |
| OpportunityContactRole | No usar como fuente primaria por baja cobertura frente a `Opportunity.CorreoElectronicoCliente__c` y `Opportunity.contacto__c`. |
| Account como referencia | `Account.PersonEmail`, `Account.CorreoElectronicoEmpresarial__c` y `Account.Invoice_Email__c` existen, pero quedan como datos de contraste hasta confirmar prioridad de negocio. |

Pendiente con María:
- Confirmar que `Opportunity.JefeSucursal__c` es el destinatario PEV/Jefe Producto para VN-RQ106.
- Confirmar si aplica igual para `Autos_Usados` y `Motos_Usados`.
- Confirmar qué hacer con `Indian`, porque el Record Type existe pero no hay datos de ejemplo en Sandbox.
- Confirmar prioridad del correo cliente cuando `Opportunity.CorreoElectronicoCliente__c`, `Opportunity.contacto__r.Email` y Account no coinciden.

### Correos PEV por marca (flujo `Alerta_de_reserva_de_producto_de_Oportunidad`, DRAFT)

| Record Type / Marca | Correo PEV |
|---|---|
| BMW | `PEV_ABMW@redmotorscr.com` |
| MINI | `PEV_AMINI@redmotorscr.com` |
| Motorrad | `PEV_MBMW@redmotorscr.com` |
| Kawasaki | `PEV_MKAWA@redmotorscr.com` |
| Polaris (default en flujo) | `PEV_MPOLARIS@redmotorscr.com` |
| Indian | **No definido — pendiente** |
| Autos_Usados | **No definido — pendiente** |
| Motos_Usados | **No definido — pendiente** |

---

## Pendientes bloqueados por negocio — actualizado 2026-05-29

| Bloqueante | Detalle | Estado |
|---|---|---|
| Tesorería correo grupal definitivo | `admin@portalnetcr.com` es temporal. El correo grupal definitivo está pendiente. | **Desbloqueado temporal** — implementable con email temporal |
| PEV campo exacto y ejemplos | Auditoría read-only deja como candidato `Opportunity.JefeSucursal__c` / `JefeSucursal__r.Email`. Falta confirmación final de María. | **Parcialmente desbloqueado** — no implementar en Flow hasta confirmar |
| PEV Indian / Autos_Usados / Motos_Usados | `Autos_Usados` y `Motos_Usados` tienen datos en `JefeSucursal__c`; `Indian` no tiene datos de ejemplo en Sandbox. Confirmar con María si aplica la misma regla. | **Parcialmente desbloqueado** — depende de confirmación de María |
| Cliente: lookup exacto del contacto y estado disparador | Candidato principal: `Opportunity.CorreoElectronicoCliente__c`; alternativo: `Opportunity.contacto__r.Email`. No usar `OpportunityContactRole` como fuente primaria por baja cobertura. Falta definir estado(s) y prioridad cuando hay discrepancias con Contact/Account. | **Parcialmente desbloqueado** |
| Cliente sin correo | Confirmado 2026-05-29: si no tiene correo, no se envía. | **Resuelto** |
| Plantilla de correo | Confirmado 2026-05-29: textos inline en Flow por ahora. Plantillas oficiales solicitadas pero pendientes. | **Desbloqueado temporal** |
| Motivo/comentarios obligatorios | Por validar. No cambiar obligatoriedad hasta confirmación. | **Sigue bloqueado** |
| Error PDF | Alcance Diego / Softland. Falta definir evento, destinatario y fuente del error. | **Sigue bloqueado** |
| Error integración | Alcance Diego / Softland. Falta definir evento, destinatario técnico y contenido mínimo. | **Sigue bloqueado** |

---

## Implementación técnica actual — notificaciones al asesor

Diego confirmó: crear notificaciones siempre en Flow (no en Apex) para que sean más sencillas de ajustar.

Flow implementado:
- `force-app/main/default/flows/VN_RQ106_Notificaciones_Anticipo.flow-meta.xml`
- Record-Triggered Flow sobre `Anticipo__c`
- After update
- Start condition: `Estatus__c` cambia
- Busca la Opportunity relacionada y su Owner
- Guarda temporal: `Opportunity.Owner.Username = 'peseck89@gmail.com.redmotors.partial'`
- Ramifica por los cinco estados probados del asesor
- Envía email con `emailSimple`
- Envía Custom Notification con `Redmotors_Notification`
- Remitente email configurado como Org-Wide Email Address `info@redmotorscr.com`

Notas para diseño posterior:
- Cubrir por Flow los cambios de `Anticipo__c.Estatus__c` listados en "Eventos que deben disparar notificaciones".
- Detectar transiciones con condición de cambio de estado para evitar reenvíos cuando se editen otros campos.
- Mantener los valores financieros como lectura desde Opportunity; las notificaciones no deben recalcular saldo en Flow salvo confirmación futura.
- Antes de producción, retirar o reemplazar la guarda temporal de Claudia.
- Antes de producción, confirmar si los textos inline son definitivos o si deben migrarse a Email Templates.

---

## Saldo pendiente — base confirmada

Diego confirmó que la base para Saldo pendiente es `Opportunity.Valor_Total_Oportunidad_FX__c`.

Referencia técnica del campo fuente: `Opportunity.Valor_Total_Oportunidad_FX__c`.

Fórmula implementada en Salesforce: `Saldo_Pendiente__c = BLANKVALUE(Valor_Total_Oportunidad_FX__c, 0) - BLANKVALUE(Total_Anticipos_Aprobados__c, 0)`.

La UI del modal debe leer `Valor_Total_Oportunidad_FX__c`, `Total_Anticipos_Aprobados__c`, `Saldo_Pendiente__c` y `CurrencyIsoCode` desde Opportunity sin recalcularlos en JavaScript.
Esto se mantiene como bloque separado de notificaciones.

---

## Qué NO implementar todavía — actualizado 2026-05-29

- No pasar a producción con la guarda temporal de Claudia.
- No implementar PEV en el Flow hasta recibir ejemplos de María y confirmar el campo exacto de Opportunity.
- No implementar correo al cliente hasta confirmar qué estado(s) lo disparan y qué lookup exacto del contacto usar.
- No implementar obligatoriedad de motivo/comentario hasta confirmación ("por validar").
- No implementar Error PDF ni Error integración sin definición de Diego/Softland.
- No crear EmailTemplates definitivos — los textos inline están aprobados por ahora.
- No crear Custom Metadata de destinatarios sin estructura aprobada.
- No cambiar el email de Tesorería de `admin@portalnetcr.com` sin nueva confirmación del equipo.

## Próximo cambio técnico seguro recomendado — 2026-05-29

**Objetivo**: agregar notificación de solicitud a Tesorería en el Flow existente.

**Alcance exacto**:
- Archivo: `force-app/main/default/flows/VN_RQ106_Notificaciones_Anticipo.flow-meta.xml`
- Cambio: agregar una nueva rama en el Flow que se dispare cuando `Estatus__c` cambia a `En validacion de Tesoreria`.
- Destinatario: correo fijo `admin@portalnetcr.com`.
- Canal: emailSimple con Org-Wide Sender `info@redmotorscr.com`.
- Texto: inline, sin EmailTemplate.
- Contenido sugerido del correo: número de anticipo, asesor, monto, fecha — tomados de los campos ya disponibles en el Flow.

**Lo que NO cambia en este paso**:
- No modificar lógica de Jefe de Producto/PEV.
- No agregar cliente.
- No cambiar la guarda temporal de Claudia (se mantiene para prueba controlada).
- No tocar producción.

**Antes de implementar**:
Conviene revisar los campos reales de Opportunity/Contacto en Sandbox para confirmar:
- Si María confirma `JefeSucursal__c` como destinatario PEV/Jefe Producto para VN-RQ106, incluyendo `Autos_Usados` y `Motos_Usados`.
- Qué hacer con `Indian`, ya que no hubo datos de ejemplo en Sandbox durante la auditoría.
- Prioridad del correo cliente cuando `Opportunity.CorreoElectronicoCliente__c`, `Opportunity.contacto__r.Email` y Account no coinciden.
- Esto no bloquea el cambio de Tesorería, pero ahorra trabajo en la siguiente iteración.

---

## Preguntas pendientes para María/Diego — actualizado 2026-05-29

| # | Pregunta | Para quién | Estado |
|---|---|---|---|
| 1 | ¿Tesorería es correo fijo, variable, grupo o cola? | Luis/equipo | **Resuelto temporal 2026-05-29**: usar `admin@portalnetcr.com`. Correo grupal definitivo pendiente. |
| 2 | ¿Correo del cliente, fuente? | Luis/equipo/María | **Parcialmente resuelto por auditoría read-only 2026-05-29**: candidato principal `Opportunity.CorreoElectronicoCliente__c`; alternativo `Opportunity.contacto__r.Email`; no usar `OpportunityContactRole` como fuente primaria. Falta confirmar prioridad si Opportunity, Contact y Account no coinciden. |
| 3 | ¿Qué pasa si cliente no tiene correo? | Luis/equipo | **Resuelto 2026-05-29**: si no tiene correo, no se envía. |
| 4 | ¿Plantilla de correo definida? | Luis/equipo | **Resuelto temporal 2026-05-29**: textos inline en Flow por ahora. Plantillas oficiales solicitadas pero pendientes. |
| 5 | ¿Cuál es el campo exacto para Jefe de Producto/PEV? ¿Puede María pasar ejemplos por Record Type? | María | **Pendiente** — auditoría read-only deja como candidato `Opportunity.JefeSucursal__c` / `JefeSucursal__r.Email`; confirmar si aplica para `Autos_Usados`, `Motos_Usados` y qué hacer con `Indian` sin datos de ejemplo. |
| 6 | ¿En qué estado(s) debe recibir correo el cliente? | Luis/equipo | **Pendiente** — comportamiento de no enviar sin correo ya confirmado, pero falta definir estado(s) disparadores. |
| 7 | ¿Motivo/comentario es obligatorio para rechazo, corrección y reserva rechazada? | Luis/equipo | **Pendiente** — "por validar". |
| 8 | Softland: ¿qué evento/campo confirma fondos y creación de anticipo? | Diego | **Pendiente** — alcance Diego/Softland. |
| 9 | PDF/error integración: ¿campo/estado disparador y destinatario? | Diego | **Pendiente** — alcance Diego/Softland. |

---

## Riesgos antes de producción

| Riesgo | Mitigación requerida |
|---|---|
| Guarda temporal limita notificaciones a Claudia | Retirar o reemplazar por regla final de alcance antes de producción |
| Destinatarios incompletos | Confirmar Tesorería, PEV, cliente y soporte antes de habilitar esos eventos |
| Textos inline no aprobados | Validar si se mantienen textos del Flow o si se migran a Email Templates |
| Sender/email domain | Mantener Org-Wide Email Address verificado; no enviar como usuarios Gmail/personales |
| Comentarios/motivos opcionales | Confirmar si deben ser obligatorios para rechazo, corrección y reserva rechazada |
| Producción no probada | Hacer validación/deploy controlado a producción solo con autorización formal |

---

## Archivos que tocar cuando se desbloqueen pendientes

| Archivo | Cambio previsto |
|---|---|
| `VN_RQ106_Notificaciones_Anticipo.flow-meta.xml` | Retirar o ajustar guarda temporal. Agregar ramas/destinatarios pendientes cuando negocio confirme datos |
| `Alerta_de_reserva_de_producto_de_Oportunidad` | Agregar Indian, Autos_Usados, Motos_Usados y activar solo cuando VN-RQ106 implemente reserva real |
| `VN_RQ106_AnticipoController.cls` | Solo si se decide enviar alguna notificación desde Apex en lugar de Flow (no recomendado según Diego) |

---

## Nota sobre Softland / PDF / Error de integración

Todo lo relacionado con creación de anticipo en Softland, obtención de PDF, errores de integración y reintentos es alcance de Diego.
No implementar desde este equipo sin confirmación de Diego.
Diego indicó que la plantilla de correo parece salir de otro sistema — esperar aclaración antes de crear cualquier EmailTemplate.
Si se crea un campo o placeholder para el link del PDF, debe quedar sin lógica de llenado; Diego lo completa.
