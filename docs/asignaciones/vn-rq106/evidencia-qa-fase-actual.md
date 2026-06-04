# VN-RQ106 - Matriz de evidencias QA fase actual

Fecha: 2026-06-02

Objetivo:
- Registrar la evidencia pendiente y tomada para la fase actual de VN-RQ106 en `RedMotorsSandbox`.
- Separar lo validable hoy de lo que depende de Diego/Softland/PDF real.

Ambiente:
- Sandbox: `RedMotorsSandbox`.
- Opportunity sugerida: `006Nq00000XbTo1IAF`.
- Prueba no admin completa: Andres Ramirez Rojas (`aramirez@redmotorscr.com.partial`) sobre Opportunity `006PH00000KnrndYAB` / `Ruben Jimenez-BMW-20/10/2024`.
- Anticipo QA creado: `a4JNq000000XQdFMAW` / `ANT-01168`, referencia `TEST-NOADMIN-ANDRES-002`.
- Produccion: no tocar.

Resultado QA no admin:
- Ejecutado exitosamente en `RedMotorsSandbox` con Andres.
- Se valido: Pantalla 1 visible, boton `Registrar ingreso / anticipo` visible, modal abre, contexto carga, cliente relacionado visible, campos financieros visibles, guardar borrador, cargar evidencia y enviar a Tesoreria.
- Anticipo final: `En validacion de Tesoreria`; tipo `Abono`; medio `Transferencia`; monto `1.00 USD`; depositante `Prueba QA Andres`.
- Evidencia asociada: 1 `ContentDocumentLink`.
- `Opportunity.Estado_Anticipo__c` quedo `Pendiente`.
- Permission set temporal de Andres fue retirado; Claudia conserva `VN_RQ106_Anticipo`.
- No se valido envio real de correo para Andres porque el Flow mantiene la guarda temporal de Claudia.

Pendiente pre-Produccion:
- Definir retiro/reemplazo de la guarda temporal de Claudia y ejecutar QA amplio de notificaciones reales cuando se autorice disparar correos.
- Validar endpoint real de `SolicitudAprobacionTesoreria` cuando Diego active el callout; hoy la integracion esta probada con mock 200.

Resultado QA post-integracion Tesoreria:
- Prueba visual ejecutada en `RedMotorsSandbox` con Andres Ramirez Rojas (`aramirez@redmotorscr.com.partial`).
- Opportunity: `006PH00000N1lalYAB` / `Adrian Lobo-BMW-10/12/2024`.
- Anticipo: `a4JNq000000XTknMAG` / `ANT-01169`, referencia `TEST-INTEGRACION-TESORERIA-001`.
- Datos: `Abono`, `Transferencia`, `1.00 USD`, fecha ingreso `2026-06-03`, depositante `Prueba integracion Tesoreria`.
- Estado final: `En validacion de Tesoreria`.
- Evidencia asociada: 1 `ContentDocumentLink`.
- `Opportunity.Estado_Anticipo__c = Pendiente`.
- `Account.codigoSoftland__c = C126213`; `ConsecutivoOportunidad__c = BMW-62416`.
- Validacion tecnica: `sendToTreasury` solo cambia a `En validacion de Tesoreria` despues de respuesta 200 de `SolicitudAprobacionTesoreria.realizarLlamada()`; actualmente esa respuesta es mock.
- No se persiste `idTransaccion` porque no hay campo definido.
- Permission set temporal de Andres fue retirado. Produccion no fue modificada.

Resultado QA cliente sin correo:
- Prueba visual ejecutada en `RedMotorsSandbox` con Andres Ramirez Rojas (`aramirez@redmotorscr.com.partial`).
- Opportunity: `006Nq00000Xn5DFIAZ` / `VN-RQ106 TEST Andres Sin Correo 2026-06-03-BMW-03/06/2026`.
- Anticipo: `a4JNq000000XU2XMAW` / `ANT-01170`, referencia `TEST-SIN-CORREO-ANDRES-001`.
- Datos: `Abono`, `Transferencia`, `1.00 USD`, fecha ingreso `2026-06-03`.
- Estado final: `En validacion de Tesoreria`; confirma que no se bloqueo Tesoreria por falta de correo cliente.
- Evidencia asociada: PDF `Reserva_ VN-RQ106_Envio automatico de correo de reserva`.
- Task/incidente: `00TNq00000SpX1rMAF`, subject `VN-RQ106: cliente sin correo`, owner Andres Ramirez Rojas, status `Open` / `Abierta`, relacionada a la Opportunity.
- La descripcion incluye `ANT-01170` y `a4JNq000000XU2XMAW`.
- Permission set temporal de Andres fue retirado; Claudia conserva `VN_RQ106_Anticipo`.
- Produccion no fue modificada.

Resultado QA validacion de totales:
- Data controlada creada en `RedMotorsSandbox` para validar que `Total_Anticipos_Aprobados__c` solo suma anticipos aceptados.
- Opportunity: `006Nq00000Xn0v9IAB` / `VN-RQ106 TEST Totales Account 2026-06-04-BMW-03/06/2026`.
- Valor total: `1000.00 USD`.
- Anticipos que suman: `ANT-01172` (`Aplicado`, `100.00 USD`) y `ANT-01173` (`Vehiculo reservado`, `50.00 USD`).
- Anticipos que no suman: `ANT-01174` (`Borrador`, `900.00 USD`), `ANT-01175` (`En validacion de Tesoreria`, `800.00 USD`), `ANT-01178` (`Correccion requerida por Tesoreria`, `750.00 USD`), `ANT-01176` (`Rechazada por Tesoreria`, `700.00 USD`) y `ANT-01177` (`Reserva rechazada`, `600.00 USD`).
- Resultado final: `Total_Anticipos_Aprobados__c = 150.00`, `Saldo_Pendiente__c = 850.00`, `Estado_Anticipo__c = Recibido`.
- Pantalla 1 / `Anticipos de dinero` muestra solo `Aplicado` y `Vehiculo reservado`.
- Video/evidencia compartido con Maria y Diego. Produccion no fue modificada.

## 1. Pantalla 1 Opportunity

| ID | Evidencia | Dato/escenario | Archivo o captura esperada | Estado |
|---|---|---|---|---|
| P1-01 | Componente visible VN | Opportunity VN | Screenshot primer pantallazo con `vnRq106OpportunityOverview` | Validado con Andres; captura formal pendiente |
| P1-02 | Componente visible VU | Opportunity VU | Screenshot primer pantallazo con `vnRq106OpportunityOverview` | Pendiente |
| P1-03 | Encabezado y boton | Opportunity con action disponible | Screenshot con nombre Opportunity y `Registrar ingreso / anticipo` | Validado con Andres; captura formal pendiente |
| P1-04 | Datos principales | Cliente, asesor, vehiculo/VIN si existe | Screenshot + query Opportunity/Product2 | Pendiente |
| P1-05 | Solicitudes de ingreso | Anticipos relacionados | Screenshot max 3 filas + query `Anticipo__c` | Pendiente |
| P1-06 | Anticipos de dinero | Anticipos aceptados (`Aplicado`, `Vehiculo reservado`) | Screenshot/video Pantalla 1 + query `Anticipo__c` | Validado con Opportunity `006Nq00000Xn0v9IAB`: muestra solo `ANT-01172` y `ANT-01173` |
| P1-07 | Resumen financiero | Campos financieros Opportunity | Screenshot/video panel derecho + query campos financieros | Validado con Opportunity `006Nq00000Xn0v9IAB`: valor total `1000.00`, total aprobado `150.00`, saldo `850.00` |
| P1-08 | Estado anticipo/reserva | Estado actual | Screenshot panel estado | Pendiente |
| P1-09 | PDF/documentos | Placeholder Softland | Screenshot `Pendiente de integracion Softland` | Pendiente |
| P1-10 | Historial | Estados/comentarios/fechas disponibles | Screenshot max 2 eventos + query | Pendiente |
| P1-11 | Alertas/acciones | Correccion, error integracion, reintento | Screenshot alertas con `No disponible todavia` si aplica | Pendiente |

## 2. Pantalla 2 Formulario solicitud

| ID | Evidencia | Dato/escenario | Archivo o captura esperada | Estado |
|---|---|---|---|---|
| P2-01 | Orden de campos | Abrir quick action | Screenshot con orden completo del formulario | Pendiente |
| P2-02 | Sin identificacion depositante | Formulario completo | Screenshot donde no aparece identificacion | Pendiente |
| P2-03 | Cliente relacionado listo | Opportunity con `AccountId` | Screenshot indicador `Cliente relacionado` listo | Validado con Andres; captura formal pendiente |
| P2-04 | Cliente relacionado faltante | Opportunity sin `AccountId` | Screenshot/toast de error funcional | Pendiente si hay data |
| P2-05 | Validaciones requeridas | Guardar sin datos | Screenshot validaciones | Pendiente |
| P2-06 | Guardar borrador | Datos validos | Screenshot toast + Id `Anticipo__c` + query | Validado con Andres: `ANT-01168` / `a4JNq000000XQdFMAW` |
| P2-07 | Evidencia obligatoria | Enviar sin archivo | Screenshot bloqueo o error | Pendiente |
| P2-08 | Adjuntar evidencia | Archivo real de prueba | Screenshot archivo + query `ContentDocumentLink` | Validado con Andres: 1 `ContentDocumentLink` |
| P2-09 | Enviar a Tesoreria | Borrador con evidencia | Screenshot/toast + query estado | Validado con Andres post-integracion: `ANT-01169`, mock 200, `En validacion de Tesoreria` |
| P2-10 | Integracion `SolicitudAprobacionTesoreria` | Enviar a Tesoreria despues de cargar evidencia | Query de Anticipo + Opportunity con `codigoSoftland__c` y `ConsecutivoOportunidad__c` | Validado con mock 200: `ANT-01169` |
| P2-11 | Cliente sin correo | Opportunity sin `CorreoElectronicoCliente__c` y sin `contacto__r.Email` | Query Anticipo + Task/incidente + evidencia | Validado: `ANT-01170` / Task `00TNq00000SpX1rMAF`; estado `En validacion de Tesoreria` |

## 3. Notificaciones

Alcance vigente segun feedback oficial de Maria del 2026-06-02 y PDF `ProyectoEnvioCorreoReserva`:
- Salesforce / Flow `VN_RQ106_Notificaciones_Anticipo` v6 solo maneja 3 notificaciones.
- Las notificaciones de Tesoreria aprueba/rechaza/correccion, `Anticipo creado`, Error PDF y Error integracion quedan fuera del Flow Salesforce porque las envia Helios/otro programa.
- El correo/notificacion al cliente sigue fuera del Flow Salesforce actual y depende de Helios/otro programa cuando aplique.
- El incidente de cliente sin correo no cambia el Flow; se genera desde Apex en `sendToTreasury` como Task al vendedor y Custom Notification best-effort.

| ID | Escenario | Estatus disparador | Evidencia esperada | Estado |
|---|---|---|---|---|
| N-01 | Solicitud enviada a Tesoreria | `En validacion de Tesoreria` | Query estado + evidencia de email a `grupo.cajas@redmotorscr.com` si se autoriza disparar | Estado validado con Andres; correo real no validado por guarda temporal de Claudia |
| N-02 | Producto rechaza reserva | `Reserva rechazada` | Query estado + email/notificacion asesor/Jefe Producto | Pendiente |
| N-03 | Producto aprueba reserva | `Vehiculo reservado` | Query estado + email/notificacion asesor/Jefe Producto | Pendiente |
| N-04 | Cliente sin correo | `sendToTreasury` con correo cliente ausente | Query Task/incidente + query Anticipo en `En validacion de Tesoreria` | Validado con `ANT-01170`; Task `00TNq00000SpX1rMAF` owner Andres |
| N-OUT-01 | Tesoreria aprueba/rechaza/correccion | `Confirmada por Tesoreria`, `Rechazada por Tesoreria`, `Correccion requerida por Tesoreria` | Evidencia Helios/otro programa, no Salesforce | Fuera de Flow Salesforce |
| N-OUT-02 | Anticipo creado | `Anticipo creado` | Evidencia Helios/otro programa, no Salesforce | Fuera de Flow Salesforce |
| N-OUT-03 | Error PDF / Error integracion | N/A Salesforce | Evidencia Diego/Softland/Helios si aplica | Fuera de alcance Salesforce |
| N-OUT-04 | Correo/notificacion al cliente | N/A Salesforce | Evidencia Helios/otro programa si aplica | Fuera de Flow Salesforce |

## 4. Permisos

| ID | Evidencia | Validacion | Archivo o captura esperada | Estado |
|---|---|---|---|---|
| PER-01 | Acceso Apex | Permission Set contiene acceso a ambos controllers | Query `SetupEntityAccess` o screenshot Setup | Pendiente captura |
| PER-02 | FLS requerido | Permission Set contiene FLS de Opportunity/Anticipo requerido | Query `FieldPermissions` o screenshot Setup | Pendiente captura |
| PER-03 | Sin FLS identificacion | `Identificacion_Depositante__c` no esta en permission set | Query `FieldPermissions` | Pendiente captura |
| PER-04 | Usuario no admin | Usuario final abre Pantalla 1 y Pantalla 2 | Screenshot usuario final | Validado con Andres; captura formal pendiente |
| PER-05 | Files/evidencia | Usuario final adjunta archivo | Screenshot archivo + query `ContentDocumentLink` | Validado con Andres: 1 `ContentDocumentLink` |
| PER-06 | Flujo completo no admin | Usuario no admin guarda borrador, carga evidencia real y envia a Tesoreria | Screenshot/toast + query `Anticipo__c` + query `ContentDocumentLink` + evidencia de notificacion si dispara | Validado con Andres; notificacion real no validada por guarda temporal |

## 5. Evidencias fuera de alcance actual

| ID | Evidencia | Motivo |
|---|---|---|
| OUT-01 | PDF real Softland | Depende de integracion Softland/Diego |
| OUT-02 | Error PDF real | Depende de integracion Softland/Diego; no lo envia el Flow Salesforce |
| OUT-03 | Error integracion real | Depende de integracion Softland/Diego; no lo envia el Flow Salesforce |
| OUT-04 | Reintento real autorizado | Depende de definicion tecnica Diego/Softland |
| OUT-05 | Prueba en Produccion | Produccion esta fuera de alcance |
| OUT-06 | Endpoint real `SolicitudAprobacionTesoreria` | Pendiente Diego; hoy `realizarLlamada()` devuelve mock 200 |
| OUT-07 | Persistencia de `idTransaccion` | No hay campo funcional definido; no se guarda en campos legacy |

## 6. Resultado no admin y pendiente pre-Produccion

La prueba completa con usuario no admin y evidencia real ya fue ejecutada exitosamente en Sandbox con Andres Ramirez Rojas.

Validacion observada:
- Pantalla 1 visible.
- Boton `Registrar ingreso / anticipo` visible.
- Modal abre.
- Contexto del formulario carga.
- Cliente relacionado visible.
- Campos financieros visibles.
- Guardar borrador.
- Cargar evidencia real.
- Enviar a Tesoreria.
- Confirmacion de `Anticipo__c` `ANT-01168` en `En validacion de Tesoreria`.
- Confirmacion de 1 `ContentDocumentLink`.
- Confirmacion de `Opportunity.Estado_Anticipo__c = Pendiente`.
- Confirmacion post-integracion de `ANT-01169` con `SolicitudAprobacionTesoreria.realizarLlamada()` mock 200 antes del estado `En validacion de Tesoreria`.
- Confirmacion cliente sin correo de `ANT-01170`: Task/incidente al vendedor, evidencia asociada y estado final `En validacion de Tesoreria`.
- Confirmacion totales: Opportunity `006Nq00000Xn0v9IAB` con `Total_Anticipos_Aprobados__c = 150.00`, `Saldo_Pendiente__c = 850.00`; Pantalla 1 muestra solo `ANT-01172` (`Aplicado`) y `ANT-01173` (`Vehiculo reservado`) en `Anticipos de dinero`.

Pendiente pre-Produccion:
- Retirar/reemplazar la guarda temporal de Claudia.
- Ejecutar QA amplio de notificaciones reales cuando se autorice disparar correos.
- Validar endpoint real de Tesoreria cuando Diego active el callout.

## 7. Convencion sugerida de archivos

Guardar capturas y queries fuera de metadata Salesforce, por ejemplo:
- `docs/asignaciones/vn-rq106/evidencias/2026-06-01/P1-01-pantalla1-vn.png`
- `docs/asignaciones/vn-rq106/evidencias/2026-06-01/P2-06-borrador-query.txt`
- `docs/asignaciones/vn-rq106/evidencias/2026-06-01/N-07-producto-aprueba-reserva.png`

Nota:
- No incluir credenciales, tokens ni datos sensibles innecesarios en capturas.
- No tocar Produccion para obtener evidencias de esta fase.
