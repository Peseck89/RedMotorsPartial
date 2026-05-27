# VN-RQ106 - Requerimiento de Campos

Este documento consolida las decisiones y campos de trabajo para VN-RQ106: confirmacion de ingresos, anticipos y reserva de vehiculos.

La finalidad es servir como fuente documental previa a la implementacion. No define APIs finales ni autoriza cambios de metadata por si mismo.

## 1. Decisiones confirmadas

- Se usa el objeto existente `Anticipo__c`.
- Se usa el campo existente `Anticipo__c.Estatus__c` para los estados del proceso.
- No se crea objeto nuevo.
- No se usa Approval Process estandar de Salesforce.
- La evidencia del pago debe quedar asociada a `Anticipo__c`.
- Softland, PDF de Softland, wrappers finales, endpoints y reintentos tecnicos son alcance de Diego.
- El requerimiento aplica para los record types:
  - `BMW`
  - `MINI`
  - `Motorrad`
  - `Kawasaki`
  - `Indian`
  - `Polaris`
  - `Autos_Usados`
  - `Motos_Usados`
- Apps confirmadas:
  - Ventas: `LightningSalesConsole`
  - Ventas Usados: `RM_App_VentasUsados`

## 2. Campos existentes detectados

| Campo | Objeto | Tipo detectado | Uso actual / nota |
|---|---|---|---|
| `Estatus__c` | `Anticipo__c` | Picklist | Estado actual del anticipo. Valores actuales detectados: `Abierto`, `Aplicado`, `Cancelado`. Luis confirmo usar este campo para VN-RQ106. |
| `Identificador__c` | `Anticipo__c` | Text | Identificador actual del pago/anticipo. Pendiente confirmar si equivale a referencia/comprobante del requerimiento. |
| `Monto__c` | `Anticipo__c` | Currency | Monto del anticipo. |
| `Oportunidad__c` | `Anticipo__c` | Master-Detail a `Opportunity` | Relaciona el anticipo con la oportunidad. |
| `Producto__c` | `Anticipo__c` | Lookup a `Product2` | Vehiculo/producto asociado al anticipo/reserva. |
| `Flag_Anticipo_Asociado__c` | `Anticipo__c` | Checkbox | Indica que el anticipo ha sido enviado a Softland segun help text existente. |
| `Estado_Anticipo__c` | `Opportunity` | Picklist | Campo existente en Opportunity. No sustituye la decision confirmada de usar `Anticipo__c.Estatus__c` para VN-RQ106. |
| `ValorTotal__c` | `Opportunity` | Roll-Up Summary | Suma `OpportunityLineItem.TotalPrice`. Posible referencia financiera, pendiente validar formula final. |
| `Valor_Total_Oportunidad_FX__c` | `Opportunity` | Formula Currency | Calcula valor total oportunidad menos regalias. Posible base para saldo pendiente, pendiente confirmar. |
| `Importetotaldelnegocio__c` | `Opportunity` | Roll-Up Summary | Suma `OpportunityLineItem.Preciodefacturacion__c`. Posible base financiera, pendiente confirmar. |
| `JefeSucursal__c` | `Opportunity` | Lookup a `User` | Destinatario/contexto de aprobaciones/notificaciones segun Opportunity. |
| `GerenteSucursal__c` | `Opportunity` | Lookup a `User` | Destinatario/contexto de aprobaciones/notificaciones segun Opportunity. |
| `SucursalId__c` | `Opportunity` | Lookup a `Sucursal__c` | Contexto de sucursal. |
| `Sucursal__c` | `Opportunity` | Picklist | Sucursal existente en Opportunity. |
| `Synced_Quote__c` | `Opportunity` | Lookup a `Quote` | Presupuesto sincronizado. El flujo actual de anticipo depende de presupuesto sincronizado. |
| `Tiene_Vehiculos_Reservados__c` | `Opportunity` | Checkbox | Indicador existente de vehiculos reservados. |
| `Vehiculos_Reservados__c` | `Opportunity` | Text | Texto existente con vehiculos reservados. |
| `Notificar_reserva_veh_culo__c` | `Opportunity` | Checkbox | Indicador existente para notificacion de reserva vehiculo. |

## 3. Campos pendientes por crear segun requerimiento

Los API names siguientes son solo sugeridos y quedan pendientes de aprobacion. No deben implementarse hasta confirmar nombres, tipos, obligatoriedad y comportamiento con Luis, Maria o Diego.

| Campo requerido | Objeto sugerido | API sugerido pendiente | Tipo sugerido | Picklist / valores | Nota |
|---|---|---|---|---|---|
| Tipo de ingreso | `Anticipo__c` | `Tipo_Ingreso__c` | Picklist | Pendiente. `Reserva` esta confirmado como condicion para reservar vehiculo. Otros valores quedan pendientes. | Necesario para distinguir reserva de abono/complemento y evitar reservar vehiculo indebidamente. |
| Medio de pago | `Anticipo__c` | `Medio_Pago__c` | Picklist | Pendiente | Valores exactos pendientes de confirmacion. |
| Fecha de ingreso | `Anticipo__c` | `Fecha_Ingreso__c` | Date o DateTime | N/A | Pendiente confirmar si requiere hora. |
| Referencia/comprobante | `Anticipo__c` | Pendiente | Text | N/A | No crear si se confirma que `Identificador__c` cubre este dato. |
| Depositante | `Anticipo__c` | `Depositante__c` | Text | N/A | Pendiente confirmar si debe ser texto libre o relacion a otro registro. |
| Identificacion depositante | `Anticipo__c` | `Identificacion_Depositante__c` | Text | N/A | Pendiente confirmar formato y validaciones. |
| Evidencia | `Anticipo__c` | Pendiente | Files relacionado o campo visible pendiente | N/A | Confirmado que debe quedar en `Anticipo__c`; pendiente definir si solo Files o tambien campo visible. |
| Comentarios asesor | `Anticipo__c` | `Comentarios_Asesor__c` | Long Text Area | N/A | Comentarios de quien registra/envia la solicitud. |
| Motivo rechazo | `Anticipo__c` | `Motivo_Rechazo__c` | Picklist o Long Text Area | Pendiente | Confirmar si existe catalogo de motivos. |
| Comentarios aprobacion/rechazo | `Anticipo__c` | `Comentarios_Aprobacion_Rechazo__c` | Long Text Area | N/A | Pendiente confirmar si debe separarse en comentarios de aprobacion y comentarios de rechazo. |
| Total anticipos aprobados | `Opportunity` | `Total_Anticipos_Aprobados__c` | Roll-Up Summary Currency o calculo Apex pendiente | N/A | Debe considerar solo anticipos aprobados/confirmados. Tipo exacto pendiente. |
| Saldo pendiente | `Opportunity` | `Saldo_Pendiente__c` | Formula Currency o calculo Apex pendiente | N/A | Debe restar anticipos aprobados/confirmados del total de oportunidad. Base financiera pendiente. |
| PDF/link anticipo | `Anticipo__c` | Pendiente | URL/Text/File pendiente | N/A | Marcar como alcance Diego si viene de Softland/PDF real. No implementar desde este equipo sin confirmacion. |

## 4. Estados VN-RQ106 confirmados para `Anticipo__c.Estatus__c`

Luis confirmo que los nuevos estados del proceso deben trabajarse sobre `Anticipo__c.Estatus__c`; no crear un campo nuevo de estado.

Estados del documento:

- `Borrador`
- `En validacion de Tesoreria`
- `Correccion requerida por Tesoreria`
- `Rechazada por Tesoreria`
- `Confirmada por Tesoreria`
- `Anticipo en creacion`
- `Anticipo creado`
- `PDF de anticipo pendiente`
- `Pendiente reserva de vehiculo`
- `Vehiculo reservado`
- `Reserva rechazada`
- `Error de integracion`

Valores actuales que deben preservarse hasta revision:

- `Abierto`
- `Aplicado`
- `Cancelado`

No borrar, renombrar ni reemplazar `Abierto`, `Aplicado` o `Cancelado` sin revisar dependencias en Apex, Flow, LWC, validation rules y datos existentes.

## 5. Bloqueantes

- Confirmar valores exactos de picklist para Tipo de ingreso.
- Confirmar valores exactos de Medio de pago.
- Confirmar si `Anticipo__c.Identificador__c` equivale a referencia/comprobante.
- Confirmar si evidencia sera solo Files relacionado a `Anticipo__c` o tambien un campo visible.
- Confirmar tipo exacto de Total anticipos aprobados y Saldo pendiente.
- Confirmar destinatarios finales de Tesoreria: correo fijo, grupo, cola o logica por sucursal.
- Definir como agregar nuevos valores a `Anticipo__c.Estatus__c` sin romper `Abierto`, `Aplicado` y `Cancelado`.

## 6. Notas de dependencias conocidas

- `Registrar_Anticipo_Controller` crea anticipos actualmente con `Estatus__c = 'Aplicado'` y ejecuta logica Softland/reserva.
- `Anticipo_Separar_Producto` depende de `Estatus__c = 'Aplicado'` para marcar producto reservado.
- Existen validaciones sobre cambios de `Estatus__c`, `Monto__c`, `Identificador__c`, `Producto__c` y `Oportunidad__c`.
- Los LWC actuales `registrar_Anticipo` y `registrar_Anticipo_Usados` usan la ruta actual de consulta/aplicacion de anticipo y no representan aun el flujo VN-RQ106 completo.

