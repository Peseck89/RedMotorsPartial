# VN-RQ106 - QA/checklist de cierre de fase actual

Fecha: 2026-06-02

Alcance de este checklist:
- Pantalla 1 Opportunity Salesforce con LWC `vnRq106OpportunityOverview`.
- Pantalla 2 Formulario solicitud con LWC `vnRq106RegistrarIngresoAnticipo`.
- Quick Action `Registrar ingreso / anticipo`.
- Notificaciones del Flow `VN_RQ106_Notificaciones_Anticipo`.
- Permission Set `VN_RQ106_Anticipo`.

Ambiente de validacion:
- Sandbox: `RedMotorsSandbox`.
- Opportunity base sugerida: `006Nq00000XbTo1IAF`.
- Prueba no admin completa realizada con Andres Ramirez Rojas (`aramirez@redmotorscr.com.partial`) sobre Opportunity `006PH00000KnrndYAB` / `Ruben Jimenez-BMW-20/10/2024`.
- Anticipo QA creado: `a4JNq000000XQdFMAW` / `ANT-01168`, referencia `TEST-NOADMIN-ANDRES-002`.
- Produccion: fuera de alcance, no tocar.

Resultado QA no admin:
- Validado exitosamente en `RedMotorsSandbox` con Andres: Pantalla 1 visible, boton visible, modal abierto, contexto cargado, cliente relacionado, campos financieros visibles, guardar borrador, cargar evidencia y enviar a Tesoreria.
- Anticipo final: `En validacion de Tesoreria`, monto `1.00 USD`, tipo `Abono`, medio `Transferencia`, depositante `Prueba QA Andres`.
- Evidencia asociada: 1 `ContentDocumentLink`.
- `Opportunity.Estado_Anticipo__c` quedo `Pendiente`.
- Permission set temporal de Andres fue retirado; Claudia conserva `VN_RQ106_Anticipo`.
- No se valido envio real de correo para Andres porque el Flow mantiene la guarda temporal de Claudia.

Pendiente pre-Produccion:
- Definir y ejecutar el retiro/reemplazo de la guarda temporal de Claudia para activar QA amplio o alcance final de notificaciones.
- Validar notificaciones reales solo cuando se autorice disparar correos.

Fuera de alcance de esta fase:
- PDF real Softland.
- Integracion Diego / Softland real.
- Error PDF real.
- Error integracion real.
- Deploy o prueba en Produccion.

## 1. Pantalla 1 Opportunity Salesforce

| Prueba | Pasos | Resultado esperado | Evidencia esperada | Estado |
|---|---|---|---|---|
| Componente visible en Opportunity VN | Abrir una Opportunity VN en Sandbox | `vnRq106OpportunityOverview` aparece como bloque principal superior | Screenshot primer pantallazo | Validado con Andres; evidencia formal pendiente |
| Componente visible en Opportunity VU | Abrir una Opportunity VU en Sandbox | `vnRq106OpportunityOverview` aparece como bloque principal superior | Screenshot primer pantallazo | Pendiente QA visual |
| Encabezado | Abrir Pantalla 1 | Muestra nombre de Opportunity y boton `Registrar ingreso / anticipo` | Screenshot encabezado | Validado con Andres; evidencia formal pendiente |
| Datos principales | Revisar seccion de datos | Muestra cliente, vehiculo/VIN si existe, precio de venta, estado oportunidad/reserva y asesor | Screenshot + query de Opportunity/Product2 si aplica | Pendiente QA |
| Solicitudes de ingreso | Revisar lista/resumen | Muestra maximo 3 solicitudes recientes y texto `Ver mas en lista relacionada` si hay mas | Screenshot + query de `Anticipo__c` | Pendiente QA |
| Anticipos de dinero | Revisar lista/resumen | Muestra maximo 3 anticipos aprobados/aplicados con numero, monto, fecha y estado | Screenshot + query de `Anticipo__c` | Pendiente QA |
| Resumen financiero | Revisar panel derecho | Muestra valor total, total anticipos aprobados y saldo pendiente desde Opportunity | Screenshot + query de campos financieros | Validado con Andres; evidencia formal pendiente |
| Estado anticipo/reserva | Revisar panel derecho | Muestra estado actual de anticipo y estado reserva/producto disponible | Screenshot + query | Pendiente QA |
| PDF/documentos placeholder | Revisar tarjeta PDF/documentos | Muestra `Pendiente de integracion Softland`; no intenta obtener PDF real | Screenshot | Pendiente QA |
| Historial | Revisar seccion historial | Muestra maximo 2 eventos resumidos con estado/comentario/fecha disponible | Screenshot + query de `Anticipo__c` | Pendiente QA |
| Alertas/acciones | Revisar panel derecho | Muestra correccion solicitada, error integracion y reintento como disponible/no disponible segun datos; reintento dice `No disponible todavia` | Screenshot | Pendiente QA |

## 2. Pantalla 2 Formulario solicitud

| Prueba | Pasos | Resultado esperado | Evidencia esperada | Estado |
|---|---|---|---|---|
| Orden de campos | Abrir quick action | Orden: Tipo de ingreso, Medio de pago, Fecha de ingreso, Referencia/comprobante, Depositante, Monto, Moneda, Vehiculo si reserva, Evidencia, Comentarios asesor | Screenshot formulario | Modal abierto con Andres; evidencia formal pendiente |
| Sin identificacion depositante | Revisar formulario completo | No aparece `Identificacion solicitante` ni `Identificacion depositante` | Screenshot formulario | Pendiente QA |
| Cliente relacionado listo | Abrir Opportunity con `AccountId` | UI marca `Cliente relacionado` como listo | Screenshot validacion | Validado con Andres; evidencia formal pendiente |
| Cliente relacionado faltante | Abrir Opportunity sin `AccountId` o probar dato controlado | UI/Apex bloquean creacion con error funcional | Screenshot/toast o resultado Apex | Pendiente si hay data |
| Campos requeridos | Intentar guardar sin obligatorios | UI bloquea o muestra validaciones requeridas | Screenshot validaciones | Pendiente QA |
| Tipo ingreso Abono | Seleccionar tipo distinto a reserva | No solicita vehiculo | Screenshot | Pendiente QA |
| Tipo ingreso Reserva de vehiculo | Seleccionar `Reserva de vehiculo` con vehiculos disponibles | Muestra selector de vehiculo | Screenshot selector | Pendiente QA |
| Reserva sin vehiculo | Intentar guardar reserva sin vehiculo | Bloquea guardado con mensaje funcional | Screenshot/toast | Pendiente QA |
| Guardar borrador | Completar obligatorios y guardar | Crea `Anticipo__c` en estado `Borrador` | Id Anticipo + screenshot toast + query | Validado con Andres: `ANT-01168` / `a4JNq000000XQdFMAW` |
| Evidencia obligatoria | Intentar enviar borrador sin evidencia | No permite enviar a Tesoreria | Screenshot/toast | Pendiente QA |
| Adjuntar evidencia | Cargar archivo despues de crear borrador | Archivo queda asociado al `Anticipo__c` | Screenshot archivo + query `ContentDocumentLink` | Validado con Andres: 1 `ContentDocumentLink` |
| Enviar a Tesoreria | Con evidencia cargada, enviar | Estado cambia a `En validacion de Tesoreria` | Screenshot/toast + query Anticipo | Validado con Andres: `En validacion de Tesoreria` |

## 3. Notificaciones

Condiciones actuales:
- Flow `VN_RQ106_Notificaciones_Anticipo` v6 activo en Sandbox — 3 eventos implementados en Salesforce segun feedback oficial de Maria del 2026-06-02 y PDF `ProyectoEnvioCorreoReserva`.
- Sender configurado: Org-Wide Email Address `info@redmotorscr.com`.
- Custom Notification Type: `Redmotors_Notification`.
- Guarda temporal activa: solo notifica si `Opportunity.Owner.Username = 'peseck89@gmail.com.redmotors.partial'`. Retirar antes de deploy productivo.
- Jefe de Producto: `Opportunity.JefeSucursal__c`, confirmado por Maria, sin hardcodear correo.

Eventos implementados:
- `En validacion de Tesoreria` → Tesoreria (`grupo.cajas@redmotorscr.com`), email inline.
- `Reserva rechazada` → Asesor + JefeSucursal__c (sin duplicar), email + Custom Notification.
- `Vehiculo reservado` → Asesor + JefeSucursal__c (sin duplicar), email + Custom Notification.

Fuera del Flow Salesforce por feedback Maria 2026-06-02:
- Tesoreria aprueba / `Confirmada por Tesoreria`.
- Tesoreria rechaza / `Rechazada por Tesoreria`.
- Tesoreria solicita correccion / `Correccion requerida por Tesoreria`.
- `Anticipo creado`.
- Error PDF y Error integracion.
- Estas notificaciones las envia Helios/otro programa, no Salesforce.

| Escenario | Disparador | Destinatarios esperados | Resultado esperado | Evidencia esperada | Estado |
|---|---|---|---|---|---|
| Solicitud enviada a Tesoreria | `Anticipo__c.Estatus__c = En validacion de Tesoreria` | `grupo.cajas@redmotorscr.com` | Email inline con asunto `Validacion de ingreso requerida - Cliente - Monto Moneda` | Query estado + evidencia de correo si se autoriza disparar | Pendiente QA |
| Producto rechaza reserva | `Reserva rechazada` | Asesor/owner y Jefe Producto si aplica | Email + custom notification | Query + evidencia de correo/notificacion | Pendiente QA |
| Producto aprueba reserva | `Vehiculo reservado` | Asesor/owner y Jefe Producto si aplica, sin duplicar si son el mismo usuario | Email + custom notification | Query + evidencia de correo/notificacion | Pendiente QA |

## 4. Permisos

Estado implementado en Sandbox:
- Permission Set `VN_RQ106_Anticipo` ajustado.
- Acceso Apex agregado a:
  - `VN_RQ106_AnticipoController`.
  - `VN_RQ106_OpportunityOverviewController`.
- FLS de `Anticipo__c.Identificacion_Depositante__c` retirado del permission set.
- `Anticipo__c.Comentarios_Aprobacion_Rechazo__c` queda solo lectura.

| Prueba | Pasos | Resultado esperado | Evidencia esperada | Estado |
|---|---|---|---|---|
| Acceso Apex Pantalla 1 | Usuario con permission set abre Opportunity | No aparece error de Apex al cargar `vnRq106OpportunityOverview` | Screenshot o log sin error | Validado con Andres; evidencia formal pendiente |
| Acceso Apex Pantalla 2 | Usuario con permission set abre quick action | Modal carga contexto sin error de Apex | Screenshot modal | Validado con Andres; evidencia formal pendiente |
| FLS Opportunity | Revisar con usuario no admin | Ve resumen financiero y estados de Opportunity | Screenshot + confirmacion de usuario | Validado con Andres; evidencia formal pendiente |
| FLS Anticipo formulario | Crear borrador con usuario no admin | Puede guardar campos requeridos del formulario | Id Anticipo + screenshot | Validado con Andres: `ANT-01168` |
| Sin FLS identificacion depositante | Revisar permission set o UI | `Identificacion_Depositante__c` no esta en FLS del permission set y no aparece en formulario | Query/Setup screenshot + formulario | Implementado, evidencia pendiente |
| Comentario aprobacion solo lectura | Revisar FLS | Asesor no edita `Comentarios_Aprobacion_Rechazo__c` desde este permiso | Query/Setup screenshot | Implementado, evidencia pendiente |
| Evidencia/Files | Usuario final adjunta archivo | Archivo se carga y queda asociado al `Anticipo__c` | Screenshot + query `ContentDocumentLink` | Validado con Andres: 1 `ContentDocumentLink` |

Nota tecnica:
- `Anticipo__c.Oportunidad__c` es Master-Detail requerido; Salesforce no permite desplegar FLS para ese campo en permission set. No queda como pendiente funcional del permission set.

## 5. Evidencia minima esperada

| Bloque | Evidencia minima |
|---|---|
| Pantalla 1 | Screenshot VN, screenshot VU, screenshot panel derecho, query de Opportunity, query de `Anticipo__c` |
| Pantalla 2 | Screenshot formulario ordenado, screenshot sin identificacion, screenshot cliente relacionado, query de borrador |
| Evidencia | Screenshot archivo cargado, query `ContentDocumentLink` |
| Envio Tesoreria | Screenshot/toast, query estado `En validacion de Tesoreria` |
| Notificaciones | Query estado por escenario, captura de email o campana de notificacion |
| Permisos | Screenshot/query de permission set, prueba con usuario no admin/usuario final |
| Pre-Produccion obligatorio | Retirar/reemplazar guarda temporal de Claudia y ejecutar QA amplio de notificaciones reales cuando se autorice disparar correos |

## 6. Riesgos abiertos

| Riesgo | Impacto | Mitigacion |
|---|---|---|
| Guarda temporal de Claudia sigue activa | No es configuracion final para Produccion y evita validar correo real para Andres | Retirar/reemplazar antes de deploy productivo y ejecutar QA amplio autorizado |
| Prueba end-to-end no admin ya ejecutada | Riesgo de permisos DML/Files reducido para el escenario validado | Mantener evidencia de `ANT-01168`; repetir solo si cambia metadata o permisos |
| Correos reales no validados para Andres | La guarda temporal de Claudia bloquea notificaciones para otros owners | Validar notificaciones reales tras retirar/reemplazar la guarda y con autorizacion para disparar correos |
| Textos inline de las 3 notificaciones activas pueden requerir ajuste menor | Negocio puede pedir ajustes de redaccion | Validar con Maria/Luis |
| Notificaciones retiradas del Flow Salesforce | QA podria esperar evidencias de 7 eventos anteriores | Aclarar que Helios/otro programa envia Tesoreria aprueba/rechaza/correccion, Anticipo creado, Error PDF y Error integracion |
| Softland/Diego fuera de alcance | PDF real, reintentos y errores reales no pueden cerrarse ahora | Documentar como pendiente externo |

## 7. Metadata de referencia

| Tipo | Metadata |
|---|---|
| Flexipage | `force-app/main/default/flexipages/Opportunity_Record_Page_VN.flexipage-meta.xml` |
| Flexipage | `force-app/main/default/flexipages/Opportunity_Record_Page_VU.flexipage-meta.xml` |
| LWC Pantalla 1 | `force-app/main/default/lwc/vnRq106OpportunityOverview/` |
| LWC Pantalla 2 | `force-app/main/default/lwc/vnRq106RegistrarIngresoAnticipo/` |
| Quick Action | `force-app/main/default/quickActions/Opportunity.VN_RQ106_Registrar_Ingreso_Anticipo.quickAction-meta.xml` |
| Apex Pantalla 1 | `force-app/main/default/classes/VN_RQ106_OpportunityOverviewController.cls` |
| Apex Pantalla 2 | `force-app/main/default/classes/VN_RQ106_AnticipoController.cls` |
| Apex Tests | `force-app/main/default/classes/VN_RQ106_OppOverviewCtrlTest.cls` |
| Apex Tests | `force-app/main/default/classes/VN_RQ106_AnticipoControllerTest.cls` |
| Flow | `force-app/main/default/flows/VN_RQ106_Notificaciones_Anticipo.flow-meta.xml` |
| Permission Set | `force-app/main/default/permissionsets/VN_RQ106_Anticipo.permissionset-meta.xml` |

Nota:
- No incluir documentos `docs/` en deploy Salesforce.
- No tocar Produccion sin autorizacion explicita.
