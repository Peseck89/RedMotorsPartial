# VN-RQ106 - Resumen tecnico-funcional

Fecha: 2026-06-01
Estado: Implementado en RedMotorsSandbox. Produccion sin cambios.

Este documento consolida que hace cada pantalla, que notificaciones quedaron implementadas, que permisos se ajustaron y que queda fuera de alcance o pendiente de feedback. Sirve como referencia rapida para revisiones, QA y handoff.

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
| Enviar a Tesoreria | Requiere evidencia cargada. Cambia estado de `Anticipo__c` a `En validacion de Tesoreria` |

---

## 3. Notificaciones implementadas

**Flow**: `VN_RQ106_Notificaciones_Anticipo`
**Metadata**: `force-app/main/default/flows/VN_RQ106_Notificaciones_Anticipo.flow-meta.xml`
**Tipo**: Record-Triggered Flow, after update sobre `Anticipo__c`
**Condicion**: ejecuta cuando cambia `Estatus__c`
**Sender email**: Org-Wide Email Address `info@redmotorscr.com`
**Custom Notification Type**: `Redmotors_Notification`

| Evento (`Estatus__c`) | Destinatario | Canal |
|---|---|---|
| `En validacion de Tesoreria` | Tesoreria — `admin@portalnetcr.com` (temporal) | Email inline |
| `Confirmada por Tesoreria` | Asesor / `Opportunity.Owner` | Email + Custom Notification |
| `Correccion requerida por Tesoreria` | Asesor / `Opportunity.Owner` | Email + Custom Notification |
| `Rechazada por Tesoreria` | Asesor / `Opportunity.Owner` | Email + Custom Notification |
| `Anticipo creado` | Asesor / `Opportunity.Owner` | Email + Custom Notification |
| `Reserva rechazada` | Asesor / `Opportunity.Owner` | Email + Custom Notification |
| `Vehiculo reservado` | Asesor + `Opportunity.JefeSucursal__c` (sin duplicar si son el mismo usuario) | Email + Custom Notification |

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

---

## 5. Fuera de alcance de esta fase

| Item | Motivo |
|---|---|
| PDF real de Softland | Depende de integracion Diego/Softland — no implementar sin definicion de Diego |
| Error de PDF real | Depende de integracion Diego/Softland |
| Error de integracion real / reintentos | Depende de definicion tecnica Diego/Softland |
| Correo grupal definitivo de Tesoreria | `admin@portalnetcr.com` es temporal; correo grupal pendiente de confirmar |
| Email Templates definitivas | Textos inline aprobados temporalmente; plantillas oficiales solicitadas pero pendientes |
| Deploy o prueba en Produccion | Produccion fuera de alcance hasta autorizacion formal |

---

## 6. Pendiente de feedback de Maria

| Pendiente | Detalle |
|---|---|
| Datos de `Indian` para PEV | `Indian` no tiene datos de ejemplo en Sandbox; confirmar si `JefeSucursal__c` aplica igual |
| Motivo/comentario obligatorio | Para rechazo, correccion requerida y reserva rechazada — "por validar"; no cambiar hasta confirmar |
| Correo al cliente: estado(s) disparadores | Comportamiento sin correo resuelto (no enviar). Falta definir en que estado(s) debe dispararse |
| Textos inline de notificaciones | Aprobados provisionalmente; validar si son definitivos o si migran a Email Templates |

---

## 7. Metadata de referencia

| Tipo | Archivo |
|---|---|
| LWC Pantalla 1 | `force-app/main/default/lwc/vnRq106OpportunityOverview/` |
| LWC Pantalla 2 | `force-app/main/default/lwc/vnRq106RegistrarIngresoAnticipo/` |
| Apex Pantalla 1 | `force-app/main/default/classes/VN_RQ106_OpportunityOverviewController.cls` |
| Apex Pantalla 2 | `force-app/main/default/classes/VN_RQ106_AnticipoController.cls` |
| Tests Pantalla 1 | `force-app/main/default/classes/VN_RQ106_OppOverviewCtrlTest.cls` |
| Tests Pantalla 2 | `force-app/main/default/classes/VN_RQ106_AnticipoControllerTest.cls` |
| Quick Action | `force-app/main/default/quickActions/Opportunity.VN_RQ106_Registrar_Ingreso_Anticipo.quickAction-meta.xml` |
| Flow notificaciones | `force-app/main/default/flows/VN_RQ106_Notificaciones_Anticipo.flow-meta.xml` |
| Permission Set | `force-app/main/default/permissionsets/VN_RQ106_Anticipo.permissionset-meta.xml` |
| Flexipage VN | `force-app/main/default/flexipages/Opportunity_Record_Page_VN.flexipage-meta.xml` |
| Flexipage VU | `force-app/main/default/flexipages/Opportunity_Record_Page_VU.flexipage-meta.xml` |

Nota: los documentos `docs/` no deben incluirse en deploys Salesforce. Produccion no fue modificada.
