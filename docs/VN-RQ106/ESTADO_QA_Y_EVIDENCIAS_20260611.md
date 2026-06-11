# VN-RQ106 - Estado QA y evidencias 2026-06-11

Documento interno de control. No usar como documento oficial sin revisión.

## 1. Estado técnico actual

- Proyecto: RedMotors VN-RQ106.
- Sandbox: `RedMotorsSandbox`.
- Producción: sin cambios.
- Opportunity QA usada:
  - Id: Opportunity QA Sandbox.
  - Nombre: `Opportunity QA Sandbox`.
- Anticipo QA:
  - Id: Anticipo QA Sandbox.
  - Nombre: `Anticipo QA Sandbox`.
- Estado actual del anticipo:
  - `Estatus__c = En validación de Tesorería`.
  - `Estado_Aprobacion_Producto__c = Pendiente`.
  - `Identificador_Helios__c` generado por Helios/Softland.
- Datos confirmados en Opportunity/cuentas:
  - `empresaQueFactura__c = Bavarian`.
  - `Account.codigoSoftland__c` contiene el código Softland del cliente.
  - `Cuenta_de_Facturaci_n__r.codigoSoftland__c` contiene el código Softland del cliente.

## 2. Avances validados

- Borrador creado correctamente desde UI.
- Borrador existente se puede retomar desde el formulario.
- Botón cambia a `Actualizar borrador`.
- Evidencia se puede adjuntar.
- Validaciones visibles en formulario:
  - Campos obligatorios completos: Listo.
  - Evidencia presente: Listo.
  - Oportunidad activa: Listo.
  - Cliente relacionado: Listo.
  - Monto mayor a cero: Listo.
  - Preparado para Tesorería: Listo.
- Se corrigió el payload Salesforce para incluir:
  - `codigoSoftland = código Softland del cliente`.
  - `cliente = código Softland del cliente`.
- Envío inicial a Helios/Softland validado:
  - La solicitud ya no presenta error por parámetro `cliente`.
  - Helios genera identificador externo.
  - El anticipo queda en estado `En validación de Tesorería`.
  - La aprobación o rechazo posterior queda pendiente del proceso externo en Helios.
  - PDF Softland continúa pendiente hasta que el proceso externo avance.
- Deploy Sandbox del fix `cliente`:
  - Deploy Id: `0AfNq00000XqkyDKAR`.
  - Tests: `VN_RQ106_AnticipoControllerTest`.
  - Resultado: `35/35` exitosos.
  - Componentes: `SolicitudAprobacionTesoreria`, `VN_RQ106_AnticipoController`, `VN_RQ106_AnticipoControllerTest`.

## 3. Estado de integración Helios/Softland

- El envío inicial desde Salesforce hacia Helios/Softland ya fue validado correctamente.
- Salesforce envía `cliente` con el código Softland del cliente.
- Helios/Softland genera identificador externo.
- El anticipo queda en `En validación de Tesorería`.
- La aprobación o rechazo posterior queda pendiente del proceso externo en Helios.
- PDF Softland continúa pendiente hasta que el proceso externo avance.

## 3.1 Bloque B.2 — Notificaciones de reserva

- Se creó el documento `docs/VN-RQ106/BLOQUE_B2_NOTIFICACIONES_RESERVA.md`.
- Contenido documentado:
  - Correo de reenvío de solicitud de reserva.
  - Correo de producto/reserva rechazada.
  - Variables Salesforce sugeridas.
  - Pendientes funcionales.
  - Pendientes técnicos.
  - Criterios de aceptación.
- Estado: pendiente de implementación y QA.

## 4. Usuario QA puede comenzar solo evidencia básica/no destructiva

Casos permitidos:

1. Abrir Opportunity de prueba indicada por el equipo funcional.
2. Mostrar botón `Solicitudes anticipos`.
3. Abrir modal.
4. Validar que carga overview.
5. Validar que la tabla de solicitudes se muestra.
6. Validar que no hay error visual en el modal.

Condiciones:

- Usar solo Sandbox.
- No modificar registros.
- No crear nuevos anticipos.
- No ejecutar acciones de avance externo de Tesorería fuera del procedimiento autorizado.
- Registrar evidencia visual y observaciones.

## 5. Usuario QA no debe hacer todavía

Casos bloqueados:

1. Crear nuevo anticipo real.
2. Forzar avance del proceso externo de Tesorería.
3. Aprobar reserva.
4. Rechazar reserva.
5. Reenviar solicitud.
6. Evidencia final de flujo completo.
7. Pruebas destructivas sobre Opportunity reservada para evidencia funcional.

Motivo del bloqueo:

- El envío inicial a Helios/Softland ya genera identificador externo.
- El avance posterior de Tesorería, confirmación/rechazo y PDF Softland depende del proceso externo.

## 6. Pendientes para liberar QA completa a Usuario QA

1. Confirmar resultado posterior del proceso externo en Helios/Softland.
2. Confirmar cambio posterior a `Confirmada por Tesorería` o rechazo.
3. Confirmar generación de PDF Softland.
4. Probar aprobar/rechazar/reenvío como `JefeSucursal`.
5. Validar notificaciones Bloque B.2.
6. Preparar instrucciones finales para Usuario QA.
7. Actualizar Excel QA y documentación oficial Drive.

## 7. Estado de cierre

- Producción permanece sin cambios.
- No se debe marcar QA como aprobado.
- No se debe marcar flujo completo como validado.
- Evidencia básica puede avanzar solo si se mantiene dentro del alcance no destructivo.
