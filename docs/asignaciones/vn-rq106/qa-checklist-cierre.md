# VN-RQ106 - QA/checklist de cierre del avance actual

Fecha: 2026-05-29

Alcance de este checklist:
- Boton `Registrar ingreso / anticipo` desde Opportunity.
- Modal LWC para registrar ingreso, evidencia y envio a Tesoreria.
- Resumen financiero read-only.
- Notificaciones al asesor ya implementadas en Sandbox.

Fuera de metrica Claudia/equipo:
- Integracion Salesforce -> Softland.
- Creacion real del anticipo en Softland.
- Obtencion real de PDF desde Softland.
- Reintentos, payloads finales y endpoints de integracion.

## 1. Boton Registrar ingreso / anticipo

| Prueba | Pasos | Resultado esperado | Evidencia esperada |
|---|---|---|---|
| Boton visible en Opportunity VN | Abrir una Opportunity VN en Sandbox | Accion `Registrar ingreso / anticipo` visible | Screenshot de action bar o menu de acciones |
| Boton visible en Opportunity VU | Abrir una Opportunity VU en Sandbox | Accion `Registrar ingreso / anticipo` visible | Screenshot de action bar o menu de acciones |
| Apertura del modal | Click en `Registrar ingreso / anticipo` | Se abre modal LWC sin error | Screenshot del modal abierto |
| Contexto correcto | Revisar seccion `Datos de oportunidad` | Muestra oportunidad, cliente, asesor y tipo de registro | Screenshot de seccion |
| Sin impacto en acciones legacy | Revisar que botones legacy sigan existiendo | No se removieron acciones existentes | Screenshot o comparacion visual |

## 2. Formulario, evidencia y envio a Tesoreria

| Prueba | Pasos | Resultado esperado | Evidencia esperada |
|---|---|---|---|
| Campos obligatorios vacios | Intentar guardar sin completar datos | El modal marca campos requeridos | Screenshot de validaciones |
| Monto invalido | Ingresar monto 0 o vacio | No permite guardar borrador | Screenshot de validacion |
| Tipo ingreso Abono | Completar formulario con `Tipo de ingreso = Abono` | No solicita vehiculo | Screenshot de formulario |
| Tipo ingreso Reserva de vehiculo con vehiculos | Elegir `Reserva de vehiculo` en Opportunity con vehiculos disponibles | Muestra selector de vehiculo | Screenshot del selector |
| Tipo ingreso Reserva sin vehiculos | Elegir `Reserva de vehiculo` sin vehiculos disponibles | Muestra advertencia y bloquea guardado | Screenshot de advertencia |
| Guardar borrador | Completar obligatorios y click `Guardar borrador` | Crea `Anticipo__c` en estado `Borrador` | Id del anticipo + screenshot de toast/estado |
| Evidencia visible despues de borrador | Crear borrador | Se muestra carga de archivos ligada al Anticipo | Screenshot de seccion Evidencia |
| Adjuntar evidencia | Cargar archivo en `Adjuntar evidencia` | Archivo queda asociado al Anticipo | Screenshot del archivo cargado o ContentDocumentLink |
| Enviar sin evidencia | Intentar enviar antes de cargar archivo | Boton queda deshabilitado o no permite envio | Screenshot de boton deshabilitado |
| Enviar a Tesoreria | Con evidencia cargada, click `Enviar a Tesoreria` | Estado cambia a `En validacion de Tesoreria` | Screenshot/toast + query del Anticipo |
| Evitar reenvio | Luego de enviar a Tesoreria | No permite enviar de nuevo | Screenshot de estado/boton |

## 3. Resumen financiero

| Prueba | Pasos | Resultado esperado | Evidencia esperada |
|---|---|---|---|
| Seccion visible | Abrir modal en Opportunity | Se muestra `Resumen financiero` | Screenshot de seccion |
| Valor total oportunidad | Comparar UI contra `Opportunity.Valor_Total_Oportunidad_FX__c` | Mismo valor mostrado en UI | Screenshot UI + query Salesforce |
| Total anticipos aprobados | Comparar UI contra `Opportunity.Total_Anticipos_Aprobados__c` | Mismo valor mostrado en UI | Screenshot UI + query Salesforce |
| Saldo pendiente | Comparar UI contra `Opportunity.Saldo_Pendiente__c` | Mismo valor mostrado en UI | Screenshot UI + query Salesforce |
| Moneda heredada | Revisar moneda en UI contra `Opportunity.CurrencyIsoCode` | UI muestra moneda de la Opportunity | Screenshot UI + query Salesforce |
| No recalculo en UI | Revisar comportamiento visual | Valores vienen de Salesforce; no se recalculan en JS | Referencia a Apex/SOQL o revision tecnica |

## 4. Notificaciones al asesor implementadas

Condicion actual en Sandbox:
- Flow `VN_RQ106_Notificaciones_Anticipo` v2 activo.
- Guarda temporal: solo continua si `Opportunity.Owner.Username = 'peseck89@gmail.com.redmotors.partial'`.
- Email sender: Org-Wide Email Address `info@redmotorscr.com`.
- Custom Notification Type: `Redmotors_Notification`.

| Escenario | Anticipo TEST usado | Accion | Resultado esperado | Evidencia esperada |
|---|---|---|---|---|
| Confirmada por Tesoreria | `ANT-01152` / `a4JNq000000X9J3MAK` | Cambiar `Estatus__c` a `Confirmada por Tesoreria` | Update exitoso, email + custom notification al asesor | Query estado final + email recibido/notificacion |
| Correccion requerida por Tesoreria | `ANT-01153` / `a4JNq000000X9J4MAK` | Cambiar `Estatus__c` a `Correccion requerida por Tesoreria` | Update exitoso, email + custom notification al asesor | Query estado final + email recibido/notificacion |
| Rechazada por Tesoreria | `ANT-01154` / `a4JNq000000X9J5MAK` | Cambiar `Estatus__c` a `Rechazada por Tesoreria` | Update exitoso, email + custom notification al asesor | Query estado final + email recibido/notificacion |
| Anticipo creado | `ANT-01155` / `a4JNq000000X9J6MAK` | Cambiar `Estatus__c` a `Anticipo creado` | Update exitoso, email + custom notification al asesor | Query estado final + email recibido/notificacion |
| Reserva rechazada | `ANT-01156` / `a4JNq000000X9J7MAK` | Cambiar `Estatus__c` a `Reserva rechazada` | Update exitoso, email + custom notification al asesor | Query estado final + email recibido/notificacion |

Resultado ya observado:
- Los cinco updates fueron exitosos.
- No hubo error de Flow devuelto en las transacciones.
- El rebote inicial por From `gmail.com` se corrigio usando Org-Wide sender `info@redmotorscr.com`.

## 5. Riesgos abiertos

| Riesgo | Impacto | Mitigacion |
|---|---|---|
| Guarda temporal de Claudia sigue activa | En produccion notificaria solo a Claudia si se despliega asi | Retirar o reemplazar antes de produccion |
| Textos inline no aprobados | Negocio puede pedir templates/formato oficial | Confirmar con Luis/Diego antes de cierre final |
| Destinatario Tesoreria no definitivo | No se puede cerrar notificacion a Tesoreria | Confirmar correo/usuario/cola/grupo/regla |
| PEV/Jefe Producto incompleto | No se puede cerrar aprobacion/rechazo de reserva por marca | Confirmar destinatarios por marca |
| Motivos/comentarios no definidos | Rechazo/correccion pueden carecer de contexto obligatorio | Confirmar campo y obligatoriedad |
| Produccion no modificada | Aun falta deploy productivo autorizado | Ejecutar deploy controlado solo con autorizacion |

## 6. Bloqueado por negocio

- Destinatario final de Tesoreria.
- Si los correos deben quedar inline en Flow o migrar a Email Templates.
- Si `Comentarios_Aprobacion_Rechazo__c` u otro campo debe ser obligatorio.
- Destinatarios PEV/Jefe Producto para Indian, Autos_Usados y Motos_Usados.
- Si cliente debe recibir correo y de que contacto se toma el email.
- Que hacer si cliente no tiene correo.

## 7. Bloqueado por Diego/Softland

Estos puntos no cuentan contra el avance de Claudia/equipo:
- Creacion real del anticipo en Softland.
- Confirmacion real de fondos desde Softland.
- Estado/campo exacto que marca error de integracion.
- Estado/campo exacto que marca error al obtener PDF.
- Link o archivo PDF real de Softland.
- Reintentos tecnicos, payloads y endpoints.

## 8. Metadata involucrada para futuro deploy

| Tipo | Metadata |
|---|---|
| Quick Action | `force-app/main/default/quickActions/Opportunity.VN_RQ106_Registrar_Ingreso_Anticipo.quickAction-meta.xml` |
| LWC | `force-app/main/default/lwc/vnRq106RegistrarIngresoAnticipo/` |
| Apex | `force-app/main/default/classes/VN_RQ106_AnticipoController.cls` |
| Apex Test | `force-app/main/default/classes/VN_RQ106_AnticipoControllerTest.cls` |
| Flow | `force-app/main/default/flows/VN_RQ106_Notificaciones_Anticipo.flow-meta.xml` |
| Permission Set | `force-app/main/default/permissionsets/VN_RQ106_Anticipo.permissionset-meta.xml` |
| Opportunity fields | `force-app/main/default/objects/Opportunity/fields/Total_Anticipos_Aprobados__c.field-meta.xml` |
| Opportunity fields | `force-app/main/default/objects/Opportunity/fields/Saldo_Pendiente__c.field-meta.xml` |
| Anticipo fields | `force-app/main/default/objects/Anticipo__c/fields/Tipo_Ingreso__c.field-meta.xml` |
| Anticipo fields | `force-app/main/default/objects/Anticipo__c/fields/Medio_Pago__c.field-meta.xml` |
| Anticipo fields | `force-app/main/default/objects/Anticipo__c/fields/Fecha_Ingreso__c.field-meta.xml` |
| Anticipo fields | `force-app/main/default/objects/Anticipo__c/fields/Referencia_Comprobante__c.field-meta.xml` |
| Anticipo fields | `force-app/main/default/objects/Anticipo__c/fields/Depositante__c.field-meta.xml` |
| Anticipo fields | `force-app/main/default/objects/Anticipo__c/fields/Identificacion_Depositante__c.field-meta.xml` |
| Anticipo fields | `force-app/main/default/objects/Anticipo__c/fields/Comentarios_Asesor__c.field-meta.xml` |
| Anticipo fields | `force-app/main/default/objects/Anticipo__c/fields/Comentarios_Aprobacion_Rechazo__c.field-meta.xml` |
| Anticipo field update | `force-app/main/default/objects/Anticipo__c/fields/Estatus__c.field-meta.xml` |
| Flexipages | `force-app/main/default/flexipages/Opportunity_Record_Page_VN.flexipage-meta.xml` |
| Flexipages | `force-app/main/default/flexipages/Opportunity_Record_Page_VU.flexipage-meta.xml` |

Nota para produccion:
- No desplegar el Flow con la guarda temporal de Claudia como configuracion final.
- No incluir documentos `docs/` en deploy Salesforce.
