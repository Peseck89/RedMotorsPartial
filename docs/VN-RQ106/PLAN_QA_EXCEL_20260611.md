# VN-RQ106 - Plan de actualización QA Excel 2026-06-11

Documento borrador interno para actualizar el Excel QA cuando se libere el bloqueo Helios/Softland. No modifica el Excel.

## 1. Estado general QA

- QA funcional completa: **validada en Sandbox al 2026-06-12**.
- Bloqueo Helios/Softland: **resuelto**. Integración confirmada — identificador externo generado.
- Flujo completo (ingreso → Tesorería → reserva → aprobación/rechazo/reenvío): validado.
- Notificaciones del proceso: validadas en Sandbox.
- Hotfix Tesorería (Organization): validado por Paola/Jorge.
- Fix DotsContacto (Jefe de Sucursal): desplegado en Sandbox, pendiente confirmación final con Pedro.
- Correos QA adicionales Luis: aplicados en Sandbox (`0AfNq00000XtO57KAF`), pendiente confirmación recepción.
- Producción permanece sin cambios.
- **Pendiente bloqueante antes de Producción:** remover/reemplazar correos QA temporales del Flow.

## 2. Casos validados en Sandbox

- Botón `Solicitudes anticipos` visible.
- Modal abre correctamente.
- Overview carga.
- Borrador `Anticipo QA Sandbox` creado.
- Borrador existente se retoma y botón cambia a `Actualizar borrador`.
- Evidencia se adjunta.
- Validaciones previas a Tesorería en `Listo`.
- Payload Salesforce incluye `codigoSoftland` y `cliente` con el código Softland del cliente.
- Envío a Tesorería: exitoso — Helios genera identificador externo.
- `Identificador_Helios__c` recibido y almacenado.
- Código de anticipo visible en tabla desde `Identificador_Helios__c`.
- Texto `PDF Softland pendiente de generación` visible cuando no hay PDF.
- Modal se cierra automáticamente tras envío exitoso.
- Aprobación de reserva: estado → `Vehículo reservado`.
- Rechazo de reserva: `Estado_Aprobacion_Producto__c = Rechazada`.
- Reenvío: `Estado_Aprobacion_Producto__c` vuelve a `Pendiente`.
- Historial de aprobaciones: actualizado.
- Resumen financiero: actualizado.
- Correos/notificaciones del proceso: validados en Sandbox.
- Control de acciones por `JefeSucursal__c`: validado.
- Fix DotsContacto: desplegado — Flow `rellenarDatosContacto` oculto para Jefe de Sucursal.
- Correos QA adicionales Luis: aplicados en Sandbox.

## 3. Casos pendientes de confirmar

- Validación final con Pedro para Fix DotsContacto (deploy `0AfNq00000XtKntKAF`).
- Confirmación de recepción de correos QA adicionales por Luis/Oscar/Carlos.
- Configuración productiva final de destinatarios del Flow.
- PDF Softland generado por proceso externo (fuera del alcance técnico directo de Salesforce).

## 4. Cómo marcar en Excel cuando se actualice

| Tipo de caso | Estado sugerido | Observación sugerida |
|---|---|---|
| Casos visuales/no destructivos (botón, modal, overview) | `Pasó` con evidencia de Usuario QA | Evidencia validada en Sandbox. |
| Envío a Tesorería / integración Helios | `Pasó` | Validado internamente. Helios genera identificador externo. |
| Aprobar/rechazar/reenvío reserva | `Pasó` | Validado internamente por equipo técnico con usuario `JefeSucursal__c`. |
| Notificaciones/correos | `Pasó` en Sandbox | Validados con correos QA temporales. Destinatarios productivos pendientes de confirmar. |
| Evidencia final de flujo completo | `Pendiente evidencia formal` | Flujo validado; pendiente consolidar evidencia formal de Usuario QA. |
| Fix DotsContacto | `Pasó` en Sandbox | Pendiente confirmación final con Pedro. |
| PDF Softland | `Pendiente proceso externo` | Fuera del alcance técnico Salesforce. |

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

1. **[BLOQUEANTE]** Confirmar que correos QA temporales serán removidos o reemplazados antes de Producción. No actualizar Excel con resultado de correos hasta resolver destinatarios productivos.
2. Confirmar validación final con Pedro para Fix DotsContacto.
3. Confirmar recepción de correos QA adicionales por Luis/Oscar/Carlos.
4. Grabar evidencias formales del flujo completo con Usuario QA.
5. Asociar evidencia a cada caso del Excel (videos + capturas en Drive).
6. Confirmar configuración final productiva de correos/destinatarios.
7. Obtener visto bueno funcional de negocio antes de actualizar Excel con resultado final aprobado.

## 7. Nota de uso

Este documento es un plan de actualización. El Excel debe actualizarse solo cuando el equipo confirme que corresponde hacerlo y con evidencia asociada por caso.
