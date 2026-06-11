# VN-RQ106 - Plan de actualización QA Excel 2026-06-11

Documento borrador interno para actualizar el Excel QA cuando se libere el bloqueo Helios/Softland. No modifica el Excel.

## 1. Estado general QA

- QA funcional completa: bloqueada por Helios/Softland.
- QA parcial Sandbox: avances validados.
- Usuario QA puede hacer solo evidencia básica/no destructiva si se requiere.
- Usuario QA no debe hacer flujo completo todavía.
- Producción permanece sin cambios.
- El Excel QA no debe marcarse como aprobado mientras el flujo Tesorería/reserva no esté validado completo.

## 2. Casos validados internamente

- Botón `Solicitudes anticipos` visible.
- Modal abre correctamente.
- Overview carga.
- Borrador `Anticipo QA Sandbox` creado.
- Borrador existente se retoma.
- Botón cambia a `Actualizar borrador`.
- Evidencia se adjunta.
- Validaciones previas a Tesorería quedan en `Listo`.
- `empresaQueFactura__c = Bavarian`.
- Payload Salesforce incluye:
  - `codigoSoftland = código Softland del cliente`.
  - `cliente = código Softland del cliente`.

## 3. Casos bloqueados

- Enviar a Tesorería.
- Confirmar `Identificador_Helios__c`.
- Confirmar cambio de estatus posterior a Tesorería.
- Aprobar reserva.
- Rechazar reserva.
- Reenviar solicitud.
- Validar notificaciones.
- Evidencia final de flujo completo.

## 4. Cómo marcar temporalmente en Excel cuando se actualice

| Tipo de caso | Estado sugerido | Observación sugerida |
|---|---|---|
| Casos visuales/no destructivos | `Pasó` si Usuario QA evidencia botón/modal/overview | Evidencia básica en Sandbox. No valida flujo completo. |
| Casos de integración Tesorería | `Bloqueado` | `Bloqueado por respuesta Helios/Softland: Salesforce envía cliente con el código Softland del cliente, pero backend responde que SP_SF_CREAR_SOLICITUD_ANTICIPO no recibe @cliente.` |
| Casos aprobar/rechazar/reenvío | `Bloqueado` | Bloqueado hasta tener anticipo confirmado por Tesorería. |
| Casos Flow/notificaciones | `Pendiente Bloque B.2` | Flow de notificaciones pendiente de validación/cierre. |
| Evidencia final de flujo completo | `Bloqueado` | Depende de completar Tesorería y acciones de reserva. |

Reglas para evitar confusión:

- No marcar QA completa como `Pasó`.
- No marcar Producción como validada.
- No registrar pruebas destructivas sobre la Opportunity reservada para evidencia funcional.
- No adjuntar logs con base64, credenciales, tokens ni endpoints sensibles.

## 5. Evidencias sugeridas

- Screenshot/video del botón `Solicitudes anticipos`.
- Screenshot/video del modal abierto.
- Screenshot/video del overview con tabla.
- Screenshot del borrador `Anticipo QA Sandbox`.
- Screenshot de validaciones `Listo`.
- Screenshot/log request-response Helios sin base64 y sin datos sensibles.
- Screenshot de consulta o evidencia funcional confirmando `cliente/codigoSoftland`.

Nombres sugeridos:

- `TC-BMW-A01_Opportunity_Boton_Solicitudes_Anticipos_BMW`.
- `TC-BMW-A03_Opportunity_Modal_Solicitudes_Anticipos_BMW`.
- `TC-BMW-A04_Modal_Carga_Ingresos_Anticipos_BMW`.
- `TC-BMW-B01_Borrador_Anticipo_QA_Sandbox_Creado`.
- `TC-BMW-B02_Borrador_Anticipo_QA_Sandbox_Retomado`.
- `TC-BMW-B03_Validaciones_Tesoreria_Listo`.
- `TC-BMW-INT01_Bloqueo_Helios_Cliente`.

## 6. Pendientes para actualizar Excel final

1. Recibir respuesta del equipo de integración.
2. Confirmar si Helios/Softland corrige el mapeo de `cliente`.
3. Reintentar envío de `Anticipo QA Sandbox`.
4. Completar flujo Tesorería.
5. Confirmar `Identificador_Helios__c`.
6. Confirmar cambio de estatus posterior a Tesorería.
7. Ejecutar aprobación de reserva.
8. Ejecutar rechazo de reserva.
9. Ejecutar reenvío de solicitud.
10. Validar notificaciones.
11. Grabar evidencias finales.
12. Asociar evidencia a cada caso del Excel.

## 7. Nota de uso

Este documento es un plan de actualización. El Excel debe actualizarse solo cuando el equipo confirme que corresponde hacerlo y con evidencia asociada por caso.
