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
  - `Estatus__c = Borrador`.
  - `Estado_Aprobacion_Producto__c = Pendiente`.
  - `Identificador_Helios__c = vacío`.
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
- Deploy Sandbox del fix `cliente`:
  - Deploy Id: `0AfNq00000XqkyDKAR`.
  - Tests: `VN_RQ106_AnticipoControllerTest`.
  - Resultado: `35/35` exitosos.
  - Componentes: `SolicitudAprobacionTesoreria`, `VN_RQ106_AnticipoController`, `VN_RQ106_AnticipoControllerTest`.

## 3. Bloqueo actual

- Al enviar a Tesorería, Salesforce sí manda `cliente`.
- Helios/Softland sigue respondiendo:
  - `SP_SF_CREAR_SOLICITUD_ANTICIPO expects parameter '@cliente', which was not supplied.`
- Conclusión operativa:
  - El bloqueo actual ya no es dato Salesforce ni Apex básico.
  - El bloqueo parece estar en Helios/Softland/API o mapeo backend.
  - El anticipo permanece en `Borrador` porque Helios/Softland no confirma la integración.

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
- No enviar a Tesorería.
- Registrar evidencia visual y observaciones.

## 5. Usuario QA no debe hacer todavía

Casos bloqueados:

1. Crear nuevo anticipo real.
2. Enviar a Tesorería.
3. Aprobar reserva.
4. Rechazar reserva.
5. Reenviar solicitud.
6. Evidencia final de flujo completo.
7. Pruebas destructivas sobre Opportunity reservada para evidencia funcional.

Motivo del bloqueo:

- El envío a Tesorería depende de confirmación Helios/Softland.
- Actualmente la integración responde error funcional aunque Salesforce ya envía `cliente`.

## 6. Pendientes para liberar QA completa a Usuario QA

1. Respuesta del equipo de integración sobre error Helios/Softland.
2. Confirmar si backend corrige mapeo `cliente`.
3. Reintentar envío de `Anticipo QA Sandbox`.
4. Confirmar cambio de estatus e `Identificador_Helios__c`.
5. Llevar anticipo a estado `Confirmada por Tesorería`.
6. Probar aprobar/rechazar/reenvío como `JefeSucursal`.
7. Preparar instrucciones finales para Usuario QA.
8. Actualizar Excel QA y documentación oficial Drive.

## 7. Estado de cierre

- Producción permanece sin cambios.
- No se debe marcar QA como aprobado.
- No se debe marcar flujo completo como validado.
- Evidencia básica puede avanzar solo si se mantiene dentro del alcance no destructivo.
