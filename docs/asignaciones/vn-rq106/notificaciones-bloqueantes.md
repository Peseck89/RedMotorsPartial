# VN-RQ106 - Notificaciones y Correos: Estado y Bloqueantes

Este documento consolida el análisis de notificaciones/correos para VN-RQ106.
Sirve como referencia operativa antes de implementar cualquier correo, Flow de notificación o EmailTemplate.

Fecha de análisis inicial: 2026-05-28
Última actualización: 2026-05-29 — Flow de notificaciones al asesor probado en Sandbox.
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
| Tesorería | Correo fijo "admin" por el momento | **Confirmado temporal por Diego** |
| Asesor / Opportunity Owner | `Opportunity.Owner.Email` y `Opportunity.OwnerId` | Implementado y probado en `VN_RQ106_Notificaciones_Anticipo` v2 |
| Cliente | Contacto relacionado con la oportunidad (`OpportunityContactRole` o `Contact.Email`) | **Confirmado por Diego.** Mecanismo exacto por definir |
| Jefe de Producto / PEV por marca | Correos hardcoded en flujo existente (ver tabla abajo) | Confirmados para BMW/MINI/Motorrad/Kawasaki/Polaris. Flujo en DRAFT |
| Jefe de Sucursal | `Opportunity.JefeSucursal__r.Email` | Campo existe. Email no consultado en VN-RQ106 aún |
| Gerente de Sucursal | `Opportunity.GerenteSucursal__r.Email` | Campo existe. Email no consultado en VN-RQ106 aún |

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

## Pendientes bloqueados por negocio

| Bloqueante | Detalle |
|---|---|
| Tesorería destinatario real | Diego indicó usar "admin" temporalmente, pero falta definición final: usuario, correo fijo, cola, grupo o variable por sucursal/marca |
| PEV | Faltan destinatarios definitivos para Indian, Autos_Usados y Motos_Usados. Confirmar si los correos del flujo existente aplican a VN-RQ106 |
| Cliente | Falta definir lookup exacto del contacto relacionado, manejo de cliente sin correo y si aplica email, notificación o ambos |
| Error PDF | Alcance Diego / Softland. Falta definir evento, destinatario, plantilla y fuente del link o error |
| Error integración | Alcance Diego / Softland. Falta definir evento, destinatario técnico/operativo y contenido mínimo |
| Motivo/comentarios obligatorios | Falta confirmar si `Comentarios_Aprobacion_Rechazo__c` u otro campo debe ser obligatorio para rechazo/corrección/reserva rechazada |
| Plantilla de correo | Diego indicó que parece salir de otro sistema. No implementar templates definitivos hasta aclarar |
| Correo PEV Indian | Sin correo definido en flujo ni confirmado por María/Diego |
| Correo PEV Autos_Usados | Sin correo definido |
| Correo PEV Motos_Usados | Sin correo definido |
| Cliente sin correo | ¿Se bloquea, se omite o se alerta? Sin respuesta de Diego/María |
| Tesorería a futuro | "Admin" es temporal. Aún puede cambiar a variable por sucursal/marca |

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

## Qué NO implementar todavía

- No pasar a producción con la guarda temporal de Claudia.
- No implementar correo a Tesorería hasta confirmar destinatario final y plantilla.
- No implementar correo al cliente hasta definir el lookup exacto y comportamiento cuando no hay correo.
- No implementar PEV hasta confirmar Indian, Autos_Usados y Motos_Usados.
- No implementar Error PDF ni Error integración sin definición de Diego/Softland.
- No crear EmailTemplates definitivos si la plantilla seguirá viniendo de otro sistema.
- No crear Custom Metadata de destinatarios sin estructura aprobada.

---

## Preguntas pendientes para María/Diego

| # | Pregunta | Para quién | Estado |
|---|---|---|---|
| 1 | ¿Tesorería es correo fijo, variable, grupo o cola? | María | **Respondido por Diego: correo fijo "admin" por ahora** |
| 2 | ¿Correo del cliente, fuente? | María | **Respondido por Diego: contacto relacionado con la oportunidad** |
| 3 | ¿Qué pasa si cliente no tiene correo? | María / Diego | Pendiente |
| 4 | ¿Se necesita correo para Indian? ¿Cuál es el PEV de Indian? | María | Pendiente |
| 5 | ¿Los correos PEV del flujo existente son los definitivos para VN-RQ106? | María / Luis | Pendiente |
| 6 | ¿Plantilla de correo definida? ¿Tiene formato o sale de otro sistema? | Diego | **Respondido: parece que sale de otro sistema. Pendiente de aclaración** |
| 7 | ¿Correos PEV para Autos_Usados y Motos_Usados? | María | Pendiente |

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
