# VN-RQ106 - Matriz de evidencias QA fase actual

Fecha: 2026-06-01

Objetivo:
- Registrar la evidencia pendiente y tomada para la fase actual de VN-RQ106 en `RedMotorsSandbox`.
- Separar lo validable hoy de lo que depende de Diego/Softland/PDF real.

Ambiente:
- Sandbox: `RedMotorsSandbox`.
- Opportunity sugerida: `006Nq00000XbTo1IAF`.
- Produccion: no tocar.

## 1. Pantalla 1 Opportunity

| ID | Evidencia | Dato/escenario | Archivo o captura esperada | Estado |
|---|---|---|---|---|
| P1-01 | Componente visible VN | Opportunity VN | Screenshot primer pantallazo con `vnRq106OpportunityOverview` | Pendiente |
| P1-02 | Componente visible VU | Opportunity VU | Screenshot primer pantallazo con `vnRq106OpportunityOverview` | Pendiente |
| P1-03 | Encabezado y boton | Opportunity con action disponible | Screenshot con nombre Opportunity y `Registrar ingreso / anticipo` | Pendiente |
| P1-04 | Datos principales | Cliente, asesor, vehiculo/VIN si existe | Screenshot + query Opportunity/Product2 | Pendiente |
| P1-05 | Solicitudes de ingreso | Anticipos relacionados | Screenshot max 3 filas + query `Anticipo__c` | Pendiente |
| P1-06 | Anticipos de dinero | Anticipos aprobados/aplicados | Screenshot max 3 filas + query `Anticipo__c` | Pendiente |
| P1-07 | Resumen financiero | Campos financieros Opportunity | Screenshot panel derecho + query campos financieros | Pendiente |
| P1-08 | Estado anticipo/reserva | Estado actual | Screenshot panel estado | Pendiente |
| P1-09 | PDF/documentos | Placeholder Softland | Screenshot `Pendiente de integracion Softland` | Pendiente |
| P1-10 | Historial | Estados/comentarios/fechas disponibles | Screenshot max 2 eventos + query | Pendiente |
| P1-11 | Alertas/acciones | Correccion, error integracion, reintento | Screenshot alertas con `No disponible todavia` si aplica | Pendiente |

## 2. Pantalla 2 Formulario solicitud

| ID | Evidencia | Dato/escenario | Archivo o captura esperada | Estado |
|---|---|---|---|---|
| P2-01 | Orden de campos | Abrir quick action | Screenshot con orden completo del formulario | Pendiente |
| P2-02 | Sin identificacion depositante | Formulario completo | Screenshot donde no aparece identificacion | Pendiente |
| P2-03 | Cliente relacionado listo | Opportunity con `AccountId` | Screenshot indicador `Cliente relacionado` listo | Pendiente |
| P2-04 | Cliente relacionado faltante | Opportunity sin `AccountId` | Screenshot/toast de error funcional | Pendiente si hay data |
| P2-05 | Validaciones requeridas | Guardar sin datos | Screenshot validaciones | Pendiente |
| P2-06 | Guardar borrador | Datos validos | Screenshot toast + Id `Anticipo__c` + query | Pendiente |
| P2-07 | Evidencia obligatoria | Enviar sin archivo | Screenshot bloqueo o error | Pendiente |
| P2-08 | Adjuntar evidencia | Archivo real de prueba | Screenshot archivo + query `ContentDocumentLink` | Pendiente manual |
| P2-09 | Enviar a Tesoreria | Borrador con evidencia | Screenshot/toast + query estado | Pendiente manual |

## 3. Notificaciones

| ID | Escenario | Estatus disparador | Evidencia esperada | Estado |
|---|---|---|---|---|
| N-01 | Solicitud enviada a Tesoreria | `En validacion de Tesoreria` | Query estado + email/notificacion a Tesoreria | Pendiente |
| N-02 | Tesoreria aprueba | `Confirmada por Tesoreria` | Query estado + email/notificacion asesor | Pendiente |
| N-03 | Tesoreria rechaza | `Rechazada por Tesoreria` | Query estado + email/notificacion asesor | Pendiente |
| N-04 | Tesoreria solicita correccion | `Correccion requerida por Tesoreria` | Query estado + email/notificacion asesor | Pendiente |
| N-05 | Anticipo creado | `Anticipo creado` | Query estado + email/notificacion asesor | Pendiente |
| N-06 | Producto rechaza reserva | `Reserva rechazada` | Query estado + email/notificacion asesor/Jefe Producto | Pendiente |
| N-07 | Producto aprueba reserva | `Vehiculo reservado` | Query estado + email/notificacion asesor/Jefe Producto | Pendiente |

## 4. Permisos

| ID | Evidencia | Validacion | Archivo o captura esperada | Estado |
|---|---|---|---|---|
| PER-01 | Acceso Apex | Permission Set contiene acceso a ambos controllers | Query `SetupEntityAccess` o screenshot Setup | Pendiente captura |
| PER-02 | FLS requerido | Permission Set contiene FLS de Opportunity/Anticipo requerido | Query `FieldPermissions` o screenshot Setup | Pendiente captura |
| PER-03 | Sin FLS identificacion | `Identificacion_Depositante__c` no esta en permission set | Query `FieldPermissions` | Pendiente captura |
| PER-04 | Usuario no admin | Usuario final abre Pantalla 1 y Pantalla 2 | Screenshot usuario final | Pendiente manual |
| PER-05 | Files/evidencia | Usuario final adjunta archivo | Screenshot archivo + query `ContentDocumentLink` | Pendiente manual |

## 5. Evidencias fuera de alcance actual

| ID | Evidencia | Motivo |
|---|---|---|
| OUT-01 | PDF real Softland | Depende de integracion Softland/Diego |
| OUT-02 | Error PDF real | Depende de integracion Softland/Diego |
| OUT-03 | Error integracion real | Depende de integracion Softland/Diego |
| OUT-04 | Reintento real autorizado | Depende de definicion tecnica Diego/Softland |
| OUT-05 | Prueba en Produccion | Produccion esta fuera de alcance |

## 6. Convencion sugerida de archivos

Guardar capturas y queries fuera de metadata Salesforce, por ejemplo:
- `docs/asignaciones/vn-rq106/evidencias/2026-06-01/P1-01-pantalla1-vn.png`
- `docs/asignaciones/vn-rq106/evidencias/2026-06-01/P2-06-borrador-query.txt`
- `docs/asignaciones/vn-rq106/evidencias/2026-06-01/N-07-producto-aprueba-reserva.png`

Nota:
- No incluir credenciales, tokens ni datos sensibles innecesarios en capturas.
- No tocar Produccion para obtener evidencias de esta fase.
