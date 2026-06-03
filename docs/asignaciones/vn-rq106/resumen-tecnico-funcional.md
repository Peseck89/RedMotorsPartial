# VN-RQ106 - Resumen tecnico-funcional

Fecha: 2026-06-02
Estado: Implementado en RedMotorsSandbox. Produccion sin cambios.

Este documento consolida que hace cada pantalla, que notificaciones quedaron implementadas, que permisos se ajustaron y que queda fuera de alcance o pendiente de feedback. Sirve como referencia rapida para revisiones, QA y handoff.

Resultado QA no admin:
- Se ejecuto exitosamente la prueba completa con Andres Ramirez Rojas (`aramirez@redmotorscr.com.partial`) en `RedMotorsSandbox`.
- Opportunity usada: `006PH00000KnrndYAB` / `Ruben Jimenez-BMW-20/10/2024`.
- Anticipo creado: `a4JNq000000XQdFMAW` / `ANT-01168`, referencia `TEST-NOADMIN-ANDRES-002`.
- Resultado: guardar borrador, cargar evidencia y enviar a Tesoreria funcionaron con usuario no admin.
- Estado final del anticipo: `En validacion de Tesoreria`; evidencia asociada: 1 `ContentDocumentLink`; `Opportunity.Estado_Anticipo__c = Pendiente`.
- Permission set temporal de Andres fue retirado; Claudia conserva `VN_RQ106_Anticipo`.
- No se valido envio real de correo para Andres porque el Flow mantiene la guarda temporal de Claudia.

Pendiente pre-Produccion:
- Retirar/reemplazar la guarda temporal de Claudia y ejecutar QA amplio de notificaciones reales cuando se autorice disparar correos.
- Validar endpoint real de `SolicitudAprobacionTesoreria` cuando Diego active el callout; actualmente `realizarLlamada()` devuelve mock 200.

Resultado QA post-integracion Tesoreria:
- Se ejecuto prueba visual post-integracion en `RedMotorsSandbox` con Andres Ramirez Rojas.
- Opportunity usada: `006PH00000N1lalYAB` / `Adrian Lobo-BMW-10/12/2024`.
- Anticipo creado: `a4JNq000000XTknMAG` / `ANT-01169`, referencia `TEST-INTEGRACION-TESORERIA-001`.
- Datos: `Abono`, `Transferencia`, `1.00 USD`, fecha ingreso `2026-06-03`, depositante `Prueba integracion Tesoreria`.
- Evidencia asociada: 1 `ContentDocumentLink`.
- Resultado: `sendToTreasury` llama `SolicitudAprobacionTesoreria.realizarLlamada()` antes de cambiar el estado a `En validacion de Tesoreria`.
- Integracion validada con mock 200; `Opportunity.Estado_Anticipo__c = Pendiente`, `Account.codigoSoftland__c = C126213`, `ConsecutivoOportunidad__c = BMW-62416`.
- Permission set temporal de Andres fue retirado. Produccion no fue modificada.

---

## 1. Pantalla 1 — Opportunity Overview

**LWC**: `vnRq106OpportunityOverview`
**Metadata**: `force-app/main/default/lwc/vnRq106OpportunityOverview/`
**Controller Apex**: `VN_RQ106_OpportunityOverviewController`
**Flexipages**: `Opportunity_Record_Page_VN.flexipage-meta.xml`, `Opportunity_Record_Page_VU.flexipage-meta.xml`
**Apps**: `LightningSalesConsole` (VN), `RM_App_VentasUsados` (VU)
**Record Types cubiertos**: BMW, MINI, Motorrad, Kawasaki, Indian, Polaris, Autos_Usados, Motos_Usados

Que muestra:

| Seccion | Contenido |
|---|---|
| Encabezado | Nombre de Opportunity y boton `Registrar ingreso / anticipo` (Quick Action) |
| Datos principales | Cliente, asesor, vehiculo/VIN si existe, precio de venta, estado oportunidad y estado de reserva |
| Solicitudes de ingreso | Hasta 3 registros `Anticipo__c` recientes; enlace a lista relacionada si hay mas |
| Anticipos de dinero | Hasta 3 anticipos aprobados/aplicados con numero, monto, fecha y estado |
| Resumen financiero | `Valor_Total_Oportunidad_FX__c`, `Total_Anticipos_Aprobados__c`, `Saldo_Pendiente__c` desde Opportunity — sin recalcular en JS |
| Estado anticipo/reserva | Estado actual de `Anticipo__c.Estatus__c` y estado de reserva/producto |
| PDF/documentos | Placeholder: texto `Pendiente de integracion Softland`; no intenta obtener PDF real |
| Historial | Hasta 2 eventos resumidos con estado/comentario/fecha |
| Alertas/acciones | Correccion solicitada, error de integracion y reintento; muestra `No disponible todavia` cuando no aplica |

---

## 2. Pantalla 2 — Formulario de solicitud

**LWC**: `vnRq106RegistrarIngresoAnticipo`
**Metadata**: `force-app/main/default/lwc/vnRq106RegistrarIngresoAnticipo/`
**Controller Apex**: `VN_RQ106_AnticipoController`
**Quick Action**: `Opportunity.VN_RQ106_Registrar_Ingreso_Anticipo`

Que hace:

| Paso | Comportamiento |
|---|---|
| Apertura | Se abre desde Quick Action `Registrar ingreso / anticipo` en la Opportunity |
| Validacion inicial | Verifica que la Opportunity tenga `AccountId` (cliente relacionado). Si falta, bloquea con error funcional |
| Orden de campos | Tipo de ingreso, Medio de pago, Fecha de ingreso, Referencia/comprobante, Depositante, Monto, Moneda, Vehiculo (solo si Reserva de vehiculo), Evidencia, Comentarios asesor |
| Campo retirado | `Identificacion_Depositante__c` no aparece en el formulario (retirado segun feedback) |
| Logica de vehiculo | Si `Tipo_Ingreso__c = Reserva de vehiculo`: muestra selector de vehiculo disponible. Si no aplica: oculta el campo |
| Guardar borrador | Crea `Anticipo__c` en estado `Borrador`. Valida campos requeridos antes de guardar |
| Adjuntar evidencia | El asesor carga archivo despues de crear el borrador; queda asociado al `Anticipo__c` via `ContentDocumentLink` |
| Enviar a Tesoreria | Requiere evidencia cargada. Antes de cambiar estado llama `SolicitudAprobacionTesoreria.realizarLlamada()`. Si responde codigo 200, cambia `Anticipo__c` a `En validacion de Tesoreria`; si falla, deja el registro en `Borrador` |

### Integracion Tesoreria

**Clase**: `SolicitudAprobacionTesoreria`
**Metadata**: `force-app/main/default/classes/SolicitudAprobacionTesoreria.cls`
**Punto de uso**: `VN_RQ106_AnticipoController.sendToTreasury(Id anticipoId)`

Mapeo actual:

| Campo solicitud | Fuente Salesforce |
|---|---|
| `salesforceRequestId` | `Anticipo__c.Id` |
| `codigoSoftland` | `Anticipo__c.Oportunidad__r.Account.codigoSoftland__c` |
| `consecutivoOpportunidad` | `Anticipo__c.Oportunidad__r.ConsecutivoOportunidad__c` |
| `monto` | `Anticipo__c.Monto__c` |
| `moneda` | `Anticipo__c.CurrencyIsoCode` |
| `fechaPago` | `Anticipo__c.Fecha_Ingreso__c` |
| `metodoPago` | `Anticipo__c.Medio_Pago__c` |
| `referenciaBancaria` | `Anticipo__c.Referencia_Comprobante__c` |
| `diferenteCliente` | `false` por ahora |
| `identificationDepositante` | `null` por ahora; VN-RQ106 dejo de usar identificacion depositante |
| `tipoIngreso` | `Anticipo__c.Tipo_Ingreso__c` |
| `comentarios` | `Anticipo__c.Comentarios_Asesor__c` |

Notas:
- `realizarLlamada()` actualmente devuelve mock 200 para probar logica de exito.
- No se persiste `idTransaccion` porque no hay campo funcional definido y no se debe reutilizar campo legacy.
- Cuando Diego active el endpoint real, se debe validar Named Credential/callout, respuesta real y manejo de errores.

---

## 3. Notificaciones implementadas

**Flow**: `VN_RQ106_Notificaciones_Anticipo`
**Metadata**: `force-app/main/default/flows/VN_RQ106_Notificaciones_Anticipo.flow-meta.xml`
**Tipo**: Record-Triggered Flow, after update sobre `Anticipo__c`
**Condicion**: ejecuta cuando cambia `Estatus__c`
**Sender email**: Org-Wide Email Address `info@redmotorscr.com`
**Custom Notification Type**: `Redmotors_Notification`
**Version activa en Sandbox**: v6

| Evento (`Estatus__c`) | Destinatario | Canal |
|---|---|---|
| `En validacion de Tesoreria` | Tesoreria — `grupo.cajas@redmotorscr.com` | Email inline |
| `Reserva rechazada` | Asesor / `Opportunity.Owner` + `Opportunity.JefeSucursal__c` sin duplicar | Email + Custom Notification |
| `Vehiculo reservado` | Asesor / `Opportunity.Owner` + `Opportunity.JefeSucursal__c` sin duplicar | Email + Custom Notification |

Feedback oficial de Maria del 2026-06-02 y PDF `ProyectoEnvioCorreoReserva`:
- Salesforce solo mantiene activas estas 3 notificaciones: solicitud enviada a Tesoreria, Producto aprueba reserva y Producto rechaza reserva.
- Tesoreria aprueba/rechaza/correccion, `Anticipo creado`, Error PDF y Error integracion quedan fuera del Flow Salesforce porque las envia Helios/otro programa.
- Error PDF, Error integracion, PDF real y logica Diego/Softland siguen fuera de alcance de esta fase.

Nota critica: el Flow conserva una **guarda temporal** que limita las notificaciones a `Opportunity.Owner.Username = 'peseck89@gmail.com.redmotors.partial'`. Esta guarda debe retirarse o reemplazarse por una regla de alcance final antes de cualquier deploy a Produccion.

---

## 4. Permisos ajustados — VN_RQ106_Anticipo

**Permission Set**: `VN_RQ106_Anticipo`
**Metadata**: `force-app/main/default/permissionsets/VN_RQ106_Anticipo.permissionset-meta.xml`

| Elemento | Ajuste |
|---|---|
| Apex: `VN_RQ106_AnticipoController` | Acceso habilitado |
| Apex: `VN_RQ106_OpportunityOverviewController` | Acceso habilitado |
| FLS `Anticipo__c.Identificacion_Depositante__c` | Retirado del permission set (no aparece en formulario) |
| FLS `Anticipo__c.Comentarios_Aprobacion_Rechazo__c` | Solo lectura — el asesor no puede editar desde este permiso |
| FLS campos del formulario (`Tipo_Ingreso__c`, `Medio_Pago__c`, `Fecha_Ingreso__c`, `Monto__c`, etc.) | Habilitados segun requerimiento |
| FLS Opportunity (campos financieros y de estado) | Habilitados para lectura en Pantalla 1 |

Nota tecnica: `Anticipo__c.Oportunidad__c` es Master-Detail requerido; Salesforce no permite configurar FLS para ese campo en permission sets. No es un pendiente funcional.

Validacion no admin completa:
- Usuario: Andres Ramirez Rojas (`aramirez@redmotorscr.com.partial`), perfil `Asesor de Ventas BMW y Nuevos V2`.
- Opportunity usada: `006PH00000KnrndYAB` / `Ruben Jimenez-BMW-20/10/2024`.
- Anticipo creado: `a4JNq000000XQdFMAW` / `ANT-01168`.
- Resultado observado: Pantalla 1 visible, boton visible, modal abre, contexto carga, cliente relacionado y campos financieros visibles; ademas se pudo guardar borrador, cargar evidencia y enviar a Tesoreria.
- Estado final: `En validacion de Tesoreria`.
- Evidencia: 1 `ContentDocumentLink`.
- Sincronizacion: `Opportunity.Estado_Anticipo__c = Pendiente`.
- Limpieza: permission set temporal retirado de Andres; Claudia conserva el permission set.
- Pendiente pre-Produccion: retirar/reemplazar guarda temporal de Claudia y validar notificaciones reales autorizadas.

---

## 5. Fuera de alcance de esta fase

| Item | Motivo |
|---|---|
| PDF real de Softland | Depende de integracion Diego/Softland — no implementar sin definicion de Diego |
| Error de PDF real | Depende de integracion Diego/Softland; no lo envia Salesforce en este Flow |
| Error de integracion real / reintentos | Depende de definicion tecnica Diego/Softland; no lo envia Salesforce en este Flow |
| Endpoint real `SolicitudAprobacionTesoreria` | Pendiente Diego; hoy `realizarLlamada()` usa mock 200 |
| Notificaciones Tesoreria aprueba/rechaza/correccion | Feedback Maria 2026-06-02: las envia Helios/otro programa, no Salesforce |
| `Anticipo creado` | Feedback Maria 2026-06-02: lo envia Helios/otro programa, no Salesforce |
| Email Templates definitivas | Textos inline en Flow para las 3 notificaciones activas; PDF/plantillas externas fuera del Flow Salesforce |
| Deploy o prueba en Produccion | Produccion fuera de alcance hasta autorizacion formal |
| Envio real de correo para usuarios distintos de Claudia | No validado porque el Flow mantiene la guarda temporal de Claudia |

---

## 6. Pendiente de feedback de Maria

| Pendiente | Detalle |
|---|---|
| Datos de `Indian` para PEV | `Indian` no tiene datos de ejemplo en Sandbox; confirmar si `JefeSucursal__c` aplica igual |
| Motivo/comentario obligatorio | Para reserva rechazada — "por validar"; no cambiar hasta confirmar |
| Correo al cliente | Fuera del Flow Salesforce actual segun feedback Maria 2026-06-02; lo cubre Helios/otro programa si aplica |
| Textos inline de notificaciones | Solo aplican a las 3 notificaciones activas en Salesforce |

---

## 7. Metadata de referencia

| Tipo | Archivo |
|---|---|
| LWC Pantalla 1 | `force-app/main/default/lwc/vnRq106OpportunityOverview/` |
| LWC Pantalla 2 | `force-app/main/default/lwc/vnRq106RegistrarIngresoAnticipo/` |
| Apex Pantalla 1 | `force-app/main/default/classes/VN_RQ106_OpportunityOverviewController.cls` |
| Apex Pantalla 2 | `force-app/main/default/classes/VN_RQ106_AnticipoController.cls` |
| Apex integracion Tesoreria | `force-app/main/default/classes/SolicitudAprobacionTesoreria.cls` |
| Tests Pantalla 1 | `force-app/main/default/classes/VN_RQ106_OppOverviewCtrlTest.cls` |
| Tests Pantalla 2 | `force-app/main/default/classes/VN_RQ106_AnticipoControllerTest.cls` |
| Quick Action | `force-app/main/default/quickActions/Opportunity.VN_RQ106_Registrar_Ingreso_Anticipo.quickAction-meta.xml` |
| Flow notificaciones | `force-app/main/default/flows/VN_RQ106_Notificaciones_Anticipo.flow-meta.xml` |
| Permission Set | `force-app/main/default/permissionsets/VN_RQ106_Anticipo.permissionset-meta.xml` |
| Flexipage VN | `force-app/main/default/flexipages/Opportunity_Record_Page_VN.flexipage-meta.xml` |
| Flexipage VU | `force-app/main/default/flexipages/Opportunity_Record_Page_VU.flexipage-meta.xml` |

Nota: los documentos `docs/` no deben incluirse en deploys Salesforce. Produccion no fue modificada.
