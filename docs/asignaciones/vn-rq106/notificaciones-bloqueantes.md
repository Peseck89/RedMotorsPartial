# VN-RQ106 - Notificaciones y Correos: Estado y Bloqueantes

Este documento consolida el análisis de notificaciones/correos para VN-RQ106.
Sirve como referencia operativa antes de implementar cualquier correo, Flow de notificación o EmailTemplate.

Fecha de análisis inicial: 2026-05-28
Última actualización: 2026-05-28 — respuestas de Diego incorporadas; base financiera confirmada.
Fuente de instrucción: Luis Sandoval / sesión PC.

---

## Decisión actual

No implementar correos ni Flows de notificación todavía.
Los bloqueantes de plantilla y correos PEV (Indian, Usados) siguen sin respuesta.
Además, las notificaciones deben separarse del bloque de campos y saldo pendiente:
primero confirmar e implementar los campos nuevos y la lógica de saldo, luego atacar las notificaciones.

Cuando se implemente: hacerlo en Flow Record-Triggered sobre `Anticipo__c.Estatus__c` (recomendación de Diego).

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

| # | Evento / Transición de estado | Destinatarios lógicos | Estado actualizado |
|---|---|---|---|
| 1 | `Borrador → En validación de Tesorería` (asesor envía) | Tesorería | Desbloqueado temporalmente: correo fijo "admin". Plantilla pendiente |
| 2 | `En validación de Tesorería → Confirmada por Tesorería` | Asesor (Owner) | Evento no implementado. Destinatario disponible |
| 3 | `En validación de Tesorería → Corrección requerida por Tesorería` | Asesor (Owner) | Evento no implementado. Destinatario disponible |
| 4 | `En validación de Tesorería → Rechazada por Tesorería` | Asesor (Owner) | Evento no implementado. Destinatario disponible |
| 5 | `→ Vehículo reservado` | Asesor + PEV por marca | Parcialmente disponible (flujo en DRAFT, faltan Indian y Usados) |
| 6 | `→ Reserva rechazada` | Asesor | No implementado |
| 7 | `→ Error de integración` | Diego / soporte técnico | Alcance Diego / Softland |
| 8 | `→ Anticipo creado` (Softland) | Asesor, posiblemente cliente | Alcance Diego / Softland |
| 9 | PDF disponible | Asesor | Alcance Diego / Softland. Plantilla de otro sistema |

---

## Destinatarios — estado actualizado

| Destinatario | Cómo se obtiene | Estado |
|---|---|---|
| Tesorería | Correo fijo "admin" por el momento | **Confirmado temporal por Diego** |
| Asesor / Opportunity Owner | `Opportunity.Owner.Email` | Disponible. No incluido aún en `sendToTreasury` |
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

## Bloqueantes que siguen activos

| Bloqueante | Detalle |
|---|---|
| Plantilla de correo | Diego indicó que parece salir de otro sistema. No implementar hasta aclarar |
| Correo PEV Indian | Sin correo definido en flujo ni confirmado por María/Diego |
| Correo PEV Autos_Usados | Sin correo definido |
| Correo PEV Motos_Usados | Sin correo definido |
| Cliente sin correo | ¿Se bloquea, se omite o se alerta? Sin respuesta de Diego/María |
| Tesorería a futuro | "Admin" es temporal. Aún puede cambiar a variable por sucursal/marca |

---

## Recomendación técnica — notificaciones por Flow

Diego confirmó: crear notificaciones siempre en Flow (no en Apex) para que sean más sencillas de ajustar.

Nota técnica para diseño posterior:
- No implementar Flows de notificación en este bloque de UI.
- Cubrir por Flow los cambios de `Anticipo__c.Estatus__c` listados en "Eventos que deben disparar notificaciones".
- Detectar transiciones con condición de cambio de estado para evitar reenvíos cuando se editen otros campos.
- Mantener los valores financieros como lectura desde Opportunity; las notificaciones no deben recalcular saldo en Flow salvo confirmación futura.

Mecanismo recomendado:
- Flow de tipo **Record-Triggered** sobre `Anticipo__c`
- Trigger: campo `Estatus__c` cambia a un valor específico
- Acción: elemento `Send Email` o `emailSimple` dentro del Flow
- Un Flow separado por grupo de transiciones o un Flow con ramificación por `Estatus__c`

Esto permite que María o Diego ajusten destinatarios y textos directamente en el Flow sin tocar Apex.

No crear el Flow todavía. Esperar a que se resuelvan plantilla y correos PEV faltantes.

---

## Saldo pendiente — base confirmada

Diego confirmó que la base para Saldo pendiente es `Opportunity.Valor_Total_Oportunidad_FX__c`.

Referencia técnica del campo fuente: `Opportunity.Valor_Total_Oportunidad_FX__c`.

Fórmula implementada en Salesforce: `Saldo_Pendiente__c = BLANKVALUE(Valor_Total_Oportunidad_FX__c, 0) - BLANKVALUE(Total_Anticipos_Aprobados__c, 0)`.

La UI del modal debe leer `Valor_Total_Oportunidad_FX__c`, `Total_Anticipos_Aprobados__c`, `Saldo_Pendiente__c` y `CurrencyIsoCode` desde Opportunity sin recalcularlos en JavaScript.
Esto se mantiene como bloque separado de notificaciones.

---

## Qué NO implementar todavía

- Ningún correo a Tesorería aunque el destinatario esté temporalmente definido — plantilla no aprobada.
- Ningún correo al cliente — mecanismo exacto de lookup de contacto sin confirmar.
- Ningún EmailTemplate — Diego indica que parece venir de otro sistema.
- No activar el flujo de reserva `Alerta_de_reserva_de_producto_de_Oportunidad` — VN-RQ106 no ejecuta reserva real todavía, y faltan correos PEV de Indian y Usados.
- No crear Custom Metadata de destinatarios — sin estructura aprobada.
- Nada de Softland, PDF ni error de integración — alcance Diego.
- No mezclar bloque de notificaciones con bloque de campos/saldo — implementar saldo primero.

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

## Archivos que tocar cuando se desbloqueen notificaciones

| Archivo | Cambio previsto |
|---|---|
| Nuevo Flow Record-Triggered sobre `Anticipo__c` | Trigger en cambio de `Estatus__c`. Ramificación por estado. Acción `Send Email` o `emailSimple`. Un Flow por grupo de estados o un Flow con branching. Crear solo cuando plantilla y correos PEV estén confirmados |
| `Alerta_de_reserva_de_producto_de_Oportunidad` | Agregar Indian, Autos_Usados, Motos_Usados y activar solo cuando VN-RQ106 implemente reserva real |
| `VN_RQ106_AnticipoController.cls` | Solo si se decide enviar alguna notificación desde Apex en lugar de Flow (no recomendado según Diego) |

---

## Nota sobre Softland / PDF / Error de integración

Todo lo relacionado con creación de anticipo en Softland, obtención de PDF, errores de integración y reintentos es alcance de Diego.
No implementar desde este equipo sin confirmación de Diego.
Diego indicó que la plantilla de correo parece salir de otro sistema — esperar aclaración antes de crear cualquier EmailTemplate.
Si se crea un campo o placeholder para el link del PDF, debe quedar sin lógica de llenado; Diego lo completa.
