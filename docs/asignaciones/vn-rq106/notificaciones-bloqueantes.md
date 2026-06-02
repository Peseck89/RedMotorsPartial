# VN-RQ106 - Notificaciones y Correos: Estado y Bloqueantes

Este documento consolida el análisis de notificaciones/correos para VN-RQ106.
Sirve como referencia operativa antes de implementar cualquier correo, Flow de notificación o EmailTemplate.

Fecha de análisis inicial: 2026-05-28
Última actualización: 2026-06-02 — feedback oficial de María y PDF `ProyectoEnvioCorreoReserva`: Salesforce conserva solo 3 notificaciones; el resto lo envía Helios/otro programa.
Fuente de instrucción: Luis Sandoval / María / sesión PC.

---

## Decisión actual — 2026-06-02

El Flow de Salesforce quedó reducido a las 3 notificaciones que María confirmó como responsabilidad de nuestro lado/Salesforce.
Producción no fue modificada.

Flow activo en Sandbox:
- `VN_RQ106_Notificaciones_Anticipo`
- Versión activa: v6
- Objeto: `Anticipo__c`
- Tipo: Record-Triggered Flow after update
- Condición base: ejecutar cuando cambia `Estatus__c`
- Eventos Salesforce activos:
  - `En validación de Tesorería` / solicitud enviada a Tesorería.
  - `Vehículo reservado` / Producto aprueba reserva.
  - `Reserva rechazada` / Producto rechaza reserva.
- Canales implementados: email simple y Custom Notification, segun la rama.
- Custom Notification Type: `Redmotors_Notification`
- Remitente email: Org-Wide Email Address `info@redmotorscr.com`

Fuera del Flow Salesforce por feedback María 2026-06-02:
- Tesorería aprueba / `Confirmada por Tesorería`.
- Tesorería rechaza / `Rechazada por Tesorería`.
- Tesorería solicita corrección / `Corrección requerida por Tesorería`.
- `Anticipo creado`.
- Error PDF y Error integración.
- Estas notificaciones las envía Helios/otro programa, no Salesforce.

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
| 1 | Destinatario Tesorería | Antecedente 2026-05-29: usar `admin@portalnetcr.com` temporalmente. Actualizado por feedback Maria 2026-06-02: usar `grupo.cajas@redmotorscr.com`. | La notificación de solicitud a Tesorería queda con correo grupal en Flow v6. |
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

## Eventos que disparan notificaciones en Salesforce

| # | Estado de `Anticipo__c.Estatus__c` | Destinatario implementado | Canal | Estado actualizado |
|---|---|---|---|---|
| 1 | `En validación de Tesorería` (asesor envía) | Tesorería `grupo.cajas@redmotorscr.com` | Email | Implementado en Sandbox v6, texto inline, Org-Wide Sender `info@redmotorscr.com` |
| 2 | `Vehículo reservado` | Asesor + `JefeSucursal__c` | Email + Custom Notification | Implementado en Sandbox v6 — sin duplicar si son el mismo usuario |
| 3 | `Reserva rechazada` | Asesor + `JefeSucursal__c` | Email + Custom Notification | Implementado en Sandbox v6 — sin duplicar si son el mismo usuario |

## Eventos fuera del Flow Salesforce

| Evento | Motivo |
|---|---|
| `Confirmada por Tesorería` | Feedback María 2026-06-02: lo envía Helios/otro programa |
| `Corrección requerida por Tesorería` | Feedback María 2026-06-02: lo envía Helios/otro programa |
| `Rechazada por Tesorería` | Feedback María 2026-06-02: lo envía Helios/otro programa |
| `Anticipo creado` | Feedback María 2026-06-02: lo envía Helios/otro programa |
| Error PDF / PDF disponible | Alcance Diego/Softland/PDF real o Helios/otro programa |
| Error integración | Alcance Diego/Softland/PDF real o Helios/otro programa |

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

Resultado histórico:
- Los cinco updates de `Estatus__c` fueron exitosos.
- No hubo error de Flow devuelto en las transacciones.
- El rebote inicial de Gmail se corrigió en v2 usando remitente Org-Wide `info@redmotorscr.com`.
- Producción no fue modificada.
- Nota 2026-06-02: esos cinco escenarios fueron antecedentes de QA; ya no todos siguen activos en Salesforce. El Flow v6 conserva solo `Reserva rechazada`, `Vehículo reservado` y `En validación de Tesorería`.

---

## Destinatarios — estado actualizado

| Destinatario | Cómo se obtiene | Estado |
|---|---|---|
| Tesorería | `grupo.cajas@redmotorscr.com` | Implementado en `VN_RQ106_Notificaciones_Anticipo` v6 para solicitud enviada a Tesoreria |
| Asesor / Opportunity Owner | `Opportunity.Owner.Email` y `Opportunity.OwnerId` | Implementado en v6 para Producto aprueba/rechaza reserva |
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

## Pendientes bloqueados / fuera de Salesforce — actualizado 2026-06-02

| Bloqueante | Detalle | Estado |
|---|---|---|
| Tesorería correo grupal | `grupo.cajas@redmotorscr.com` implementado en Flow v6. | **Implementado en Salesforce Sandbox** |
| PEV campo exacto y ejemplos | `Opportunity.JefeSucursal__c` / `JefeSucursal__r.Email` confirmado por María 2026-06-01. | **Implementado** — `Vehiculo reservado` notifica a asesor + `JefeSucursal__c` sin duplicar |
| PEV Indian / Autos_Usados / Motos_Usados | `JefeSucursal__c` aplica para todos los Record Types. `Indian` sin datos de ejemplo en Sandbox; aplica la misma lógica dinámica. | **Implementado** — confirmar con datos reales de `Indian` cuando estén disponibles |
| Cliente: lookup exacto del contacto y estado disparador | Sale del Flow Salesforce por feedback Maria 2026-06-02; si aplica lo envia Helios/otro programa. | **Fuera Salesforce** |
| Plantilla de correo | Textos inline solo para las 3 notificaciones activas en Salesforce. PDF/plantillas externas fuera del Flow. | **Resuelto para alcance Salesforce** |
| Motivo/comentarios obligatorios | Solo relevante para reserva rechazada si negocio lo exige; no cambiar obligatoriedad hasta confirmación. | **Pendiente funcional menor** |
| Error PDF | Alcance Diego / Softland / Helios. | **Fuera Salesforce** |
| Error integración | Alcance Diego / Softland / Helios. | **Fuera Salesforce** |

---

## Implementación técnica actual — Flow Salesforce v6

Diego confirmó: crear notificaciones siempre en Flow (no en Apex) para que sean más sencillas de ajustar.

Flow implementado:
- `force-app/main/default/flows/VN_RQ106_Notificaciones_Anticipo.flow-meta.xml`
- Record-Triggered Flow sobre `Anticipo__c`
- After update
- Start condition: `Estatus__c` cambia
- Busca la Opportunity relacionada y su Owner
- Guarda temporal: `Opportunity.Owner.Username = 'peseck89@gmail.com.redmotors.partial'`
- Ramifica solo por `Reserva rechazada`, `Vehiculo reservado` y `En validacion de Tesoreria`
- Envía email con `emailSimple`
- Envía Custom Notification con `Redmotors_Notification`
- Remitente email configurado como Org-Wide Email Address `info@redmotorscr.com`

Notas para diseño posterior:
- No reactivar en Salesforce las ramas retiradas el 2026-06-02 salvo nueva instruccion oficial.
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

## Qué NO implementar en Salesforce — actualizado 2026-06-02

- No pasar a producción con la guarda temporal de Claudia — retirar antes de deploy productivo.
- No reactivar notificaciones de Tesoreria aprueba/rechaza/correccion ni `Anticipo creado`; las envia Helios/otro programa.
- No implementar Error PDF ni Error integración en Salesforce; alcance Diego/Softland/Helios.
- No crear EmailTemplates definitivos para eventos fuera del Flow Salesforce.
- No crear Custom Metadata de destinatarios sin estructura aprobada.
- No agregar PEV para `Indian` hasta tener datos de ejemplo reales en Sandbox.

## Cambios técnicos implementados — actualizado 2026-06-02

El Flow `VN_RQ106_Notificaciones_Anticipo` fue ajustado en `RedMotorsSandbox` a v6 activa.

**Notificación a Tesorería (`En validacion de Tesoreria`)**:
- Rama agregada en `VN_RQ106_Notificaciones_Anticipo.flow-meta.xml`.
- Destinatario: `grupo.cajas@redmotorscr.com`.
- Canal: emailSimple con Org-Wide Sender `info@redmotorscr.com`.
- Texto inline, sin EmailTemplate.

**Notificación de aprobación de reserva (`Vehiculo reservado`)**:
- Rama agregada en `VN_RQ106_Notificaciones_Anticipo.flow-meta.xml`.
- Destinatarios: asesor (`Opportunity.Owner`) + `Opportunity.JefeSucursal__c` (sin duplicar si son el mismo usuario).
- Canal: Email + Custom Notification `Redmotors_Notification`.
- Campo `JefeSucursal__c` confirmado por María como destinatario Jefe Producto.

**Notificación de rechazo de reserva (`Reserva rechazada`)**:
- Rama activa en `VN_RQ106_Notificaciones_Anticipo.flow-meta.xml`.
- Destinatarios: asesor (`Opportunity.Owner`) + `Opportunity.JefeSucursal__c` (sin duplicar si son el mismo usuario).
- Canal: Email + Custom Notification `Redmotors_Notification`.

**Ramas retiradas del Flow Salesforce por feedback María 2026-06-02**:
- `Confirmada por Tesorería`.
- `Corrección requerida por Tesorería`.
- `Rechazada por Tesorería`.
- `Anticipo creado`.
- Error PDF / Error integración no están implementadas en Salesforce.

**Guarda temporal sigue activa**:
- `Opportunity.Owner.Username = 'peseck89@gmail.com.redmotors.partial'`
- Retirar o reemplazar antes de deploy productivo.

---

## Preguntas pendientes para María/Diego — actualizado 2026-05-29

| # | Pregunta | Para quién | Estado |
|---|---|---|---|
| 1 | ¿Tesorería es correo fijo, variable, grupo o cola? | Luis/equipo/María | **Resuelto 2026-06-02**: usar `grupo.cajas@redmotorscr.com` para la solicitud enviada a Tesoreria. |
| 2 | ¿Correo del cliente, fuente? | Luis/equipo/María | **Parcialmente resuelto por auditoría read-only 2026-05-29**: candidato principal `Opportunity.CorreoElectronicoCliente__c`; alternativo `Opportunity.contacto__r.Email`; no usar `OpportunityContactRole` como fuente primaria. Falta confirmar prioridad si Opportunity, Contact y Account no coinciden. |
| 3 | ¿Qué pasa si cliente no tiene correo? | Luis/equipo | **Resuelto 2026-05-29**: si no tiene correo, no se envía. |
| 4 | ¿Plantilla de correo definida? | Luis/equipo | **Resuelto temporal 2026-05-29**: textos inline en Flow por ahora. Plantillas oficiales solicitadas pero pendientes. |
| 5 | ¿Cuál es el campo exacto para Jefe de Producto/PEV? ¿Puede María pasar ejemplos por Record Type? | María | **Resuelto 2026-06-01** — María confirmó `Opportunity.JefeSucursal__c` como destinatario Jefe Producto; implementado en Flow para `Vehiculo reservado`. Pendiente verificar datos reales de `Indian` en Sandbox. |
| 6 | ¿En qué estado(s) debe recibir correo el cliente? | Luis/equipo | **Fuera Salesforce por feedback 2026-06-02** — lo cubre Helios/otro programa si aplica. |
| 7 | ¿Motivo/comentario es obligatorio para reserva rechazada? | Luis/equipo | **Pendiente** — "por validar". |
| 8 | Softland: ¿qué evento/campo confirma fondos y creación de anticipo? | Diego | **Fuera Salesforce** — Helios/otro programa. |
| 9 | PDF/error integración: ¿campo/estado disparador y destinatario? | Diego | **Fuera Salesforce** — alcance Diego/Softland/Helios. |

---

## Riesgos antes de producción

| Riesgo | Mitigación requerida |
|---|---|
| Guarda temporal limita notificaciones a Claudia | Retirar o reemplazar por regla final de alcance antes de producción |
| Destinatarios incompletos | Para Salesforce ya quedan Tesoreria, Owner y JefeSucursal__c; cliente/soporte quedan fuera por Helios/otro programa |
| Textos inline no aprobados | Validar si se mantienen textos del Flow o si se migran a Email Templates |
| Sender/email domain | Mantener Org-Wide Email Address verificado; no enviar como usuarios Gmail/personales |
| Comentarios/motivos opcionales | Confirmar si deben ser obligatorios para reserva rechazada |
| Producción no probada | Hacer validación/deploy controlado a producción solo con autorización formal |

---

## Archivos que tocar cuando se desbloqueen pendientes

| Archivo | Cambio previsto |
|---|---|
| `VN_RQ106_Notificaciones_Anticipo.flow-meta.xml` | Retirar o ajustar guarda temporal antes de produccion. No reactivar ramas retiradas salvo nueva instruccion oficial |
| `Alerta_de_reserva_de_producto_de_Oportunidad` | Agregar Indian, Autos_Usados, Motos_Usados y activar solo cuando VN-RQ106 implemente reserva real |
| `VN_RQ106_AnticipoController.cls` | Solo si se decide enviar alguna notificación desde Apex en lugar de Flow (no recomendado según Diego) |

---

## Nota sobre Softland / PDF / Error de integración

Todo lo relacionado con creación de anticipo en Softland, obtención de PDF, errores de integración y reintentos es alcance de Diego/Softland/Helios.
No implementar desde este equipo sin nueva confirmación oficial.
María confirmó el 2026-06-02 que las notificaciones fuera de las 3 ramas Salesforce las envía Helios/otro programa.
Si se crea un campo o placeholder para el link del PDF, debe quedar sin lógica de llenado; Diego lo completa.
