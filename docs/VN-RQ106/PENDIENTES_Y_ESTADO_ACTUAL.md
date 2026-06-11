# VN-RQ106 - Pendientes y estado actual

Documento interno de control operativo. No usar como documento oficial de entrega sin revisión.

Fecha de actualización: 2026-06-11  
Proyecto: RedMotors VN-RQ106  
Ambiente trabajado: RedMotors Sandbox Partial  
Producción: sin cambios

## 1. Estado general

- Bloque A desplegado en RedMotors Sandbox Partial.
- Producción permanece sin cambios.
- Permission Set `VN_RQ106_Anticipo` configurado para perfiles QA.
- Se validaron 28 asignaciones activas del permission set.
- Opportunity BMW de prueba validada parcialmente.
- La Opportunity BMW fue revisada con datos mínimos y campos de responsables presentes.
- Usuario QA queda pausado para pruebas completas hasta cerrar Bloque B y validar el flujo completo.
- QA formal no debe marcarse como aprobado todavía.
- Opportunity QA técnica actual: `Opportunity QA Sandbox`.
- Anticipo QA técnica actual: `Anticipo QA Sandbox`.
- Estado actual del anticipo QA:
  - `Estatus__c = Borrador`.
  - `Estado_Aprobacion_Producto__c = Pendiente`.
  - `Identificador_Helios__c = vacío`.
- La Opportunity QA ya tiene `empresaQueFactura__c = Bavarian`.
- La cuenta relacionada tiene `Account.codigoSoftland__c` informado con el código Softland del cliente.
- La cuenta de facturación tiene `Cuenta_de_Facturaci_n__r.codigoSoftland__c` informado con el código Softland del cliente.

## 2. Hecho hoy

- Configuración de `VN_RQ106_Anticipo` para perfiles QA.
- Validación de 28 asignaciones activas.
- Validación de Opportunity BMW con Usuario QA Asesor.
- Confirmación por query de campos de responsables en Opportunity:
  - `DirectorVentas__c`
  - `GerenteSucursal__c`
  - `JefeSucursal__c`
- Generación y revisión de documentación técnica.
- Creación de contenido para copiar manualmente a Google Docs oficial.
- Análisis técnico de Bloque B.
- Implementación local inicial de Bloque B en el worktree, sin deploy ni validación en org.
- QA técnica Bloque B continuada con `Opportunity QA Sandbox`.
- Anticipo QA creado desde UI: `Anticipo QA Sandbox`.
- Borrador creado correctamente con `Estatus__c = Borrador`.
- Se cargó evidencia correctamente en el borrador.
- Se implementó mejora LWC para retomar borradores existentes en `vnRq106RegistrarIngresoAnticipo`.
- Dry-run de la mejora LWC en Sandbox exitoso: `0AfNq00000Xpni2KAB`.
- Deploy de la mejora LWC a Sandbox exitoso: `0AfNq00000Xpu8SKAR`.
- Opportunity QA actualizada en Sandbox con `empresaQueFactura__c = Bavarian`.
- Se diagnosticó bloqueo de envío a Tesorería por contrato JSON con Helios/Softland:
  - Error recibido: `SP_SF_CREAR_SOLICITUD_ANTICIPO expects parameter '@cliente', which was not supplied.`
  - `Account.codigoSoftland__c` informado con el código Softland del cliente.
  - Salesforce envía `codigoSoftland`.
  - Helios/Softland espera `cliente`.
  - Fix mínimo recomendado: agregar `cliente` al payload con el mismo valor de `codigoSoftland`.
- Se reemplazó localmente `SolicitudAprobacionTesoreria.cls` usando como base la versión activa real de Sandbox, no la versión mock local.
- Se corrigió el payload Salesforce para incluir:
  - `codigoSoftland = código Softland del cliente`.
  - `cliente = código Softland del cliente`.
- Dry-run del fix `cliente` exitoso en Sandbox: `0AfNq00000Xqka1KAB`.
- Deploy real del fix `cliente` a Sandbox exitoso:
  - Deploy Id: `0AfNq00000XqkyDKAR`.
  - Tests: `VN_RQ106_AnticipoControllerTest`.
  - Resultado: `35/35` exitosos.
  - Componentes desplegados: `SolicitudAprobacionTesoreria`, `VN_RQ106_AnticipoController`, `VN_RQ106_AnticipoControllerTest`.
- Validaciones UI posteriores:
  - Borrador existente se puede retomar desde el formulario.
  - Botón cambia a `Actualizar borrador`.
  - Evidencia se puede adjuntar.
  - Validaciones del formulario muestran `Listo` para campos obligatorios, evidencia, oportunidad activa, cliente relacionado, monto mayor a cero y preparado para Tesorería.
- Después del fix, Salesforce ya manda `cliente`, pero Helios/Softland mantiene el error funcional sobre `@cliente`.

## 3. Pendientes de implementación Bloque B

Estado operativo: los siguientes puntos ya tienen implementación local inicial en el worktree, pero siguen pendientes de validación técnica, pruebas Apex/UI y despliegue controlado a Sandbox. No están en Producción.

- Crear `Anticipo__c.Estado_Aprobacion_Producto__c`.
- Agregar FLS del nuevo campo al Permission Set `VN_RQ106_Anticipo`.
- Implementar aprobar reserva.
- Implementar rechazar reserva sin cambiar `Anticipo__c.Estatus__c`.
- Implementar reenvío de solicitud de reserva.
- Controlar visibilidad de botones por `Opportunity.JefeSucursal__c`.
- Enviar notificaciones a Opportunity Owner + `Opportunity.GerenteSucursal__c`, excluyendo al usuario ejecutor.
- Ajustar Flow `VN_RQ106_Notificaciones_Anticipo`.
- Actualizar tests relacionados.

Pendiente antes de considerar Bloque B cerrado:

- Revisar diff completo.
- Validar compilación Apex.
- Ejecutar tests de `VN_RQ106_AnticipoControllerTest` y `VN_RQ106_OppOverviewCtrlTest`.
- Validar Flow en Sandbox antes de cualquier pase.
- Validar UI del LWC con usuario autorizado y no autorizado.
- Confirmar que no se notifique al usuario ejecutor cuando también sea destinatario.
- Obtener respuesta del equipo de integración sobre el error Helios/Softland posterior al fix de Salesforce.
- Confirmar si backend Helios/Softland corrige el mapeo esperado para `cliente`.
- Reintentar envío a Tesorería de `Anticipo QA Sandbox` cuando el backend esté corregido o confirmado.
- Confirmar cambio de estatus e `Identificador_Helios__c`.
- Llevar el anticipo QA a `Confirmada por Tesorería`.
- Probar aprobar/rechazar/reenvío como `JefeSucursal__c`.

## 4. Decisiones funcionales ya tomadas

- El rechazo de reserva no cambia `Anticipo__c.Estatus__c`.
- El anticipo rechazado funcionalmente debe permanecer con `Estatus__c = Confirmada por Tesorería` si venía de ese estado.
- El usuario funcional que aprueba o rechaza reserva es `Opportunity.JefeSucursal__c`.
- Las notificaciones de aprobación/rechazo deben ir a Opportunity Owner + `Opportunity.GerenteSucursal__c`.
- Si el usuario que aprueba/rechaza coincide con un destinatario, no debe recibir su propia notificación.
- El reenvío debe permitir una nueva aprobación/rechazo.
- No probar aprobación/rechazo/reenvío con Usuario QA hasta cerrar desarrollo y validación técnica.

## 5. Pendientes por confirmar

- Textos finales de correo para rechazo de reserva.
- Textos finales de correo para reenvío de solicitud de reserva.
- Enlace Helios.
- Confirmar si el reenvío debe dejar `Estado_Aprobacion_Producto__c` en blanco o en `Pendiente`.
- Confirmar si la aprobación debe ejecutar una reserva física adicional o solo actualizar el estado funcional en Salesforce.
- Confirmar si habrá Email Templates finales o textos embebidos temporales.
- Confirmar criterios finales de evidencia para cierre QA.
- Confirmar con el equipo funcional/técnico si `cliente` debe salir siempre de `Opportunity.Account.codigoSoftland__c` o si debe priorizar `Opportunity.Cuenta_de_Facturaci_n__r.codigoSoftland__c` cuando exista.

## 6. Pendientes de documentación

- Revisar el documento generado por Claude y descartar si está corrupto o desalineado.
- Usar la versión local v2 revisada como fuente confiable.
- Completar Google Doc oficial pegando tablas desde el contenido local preparado.
- No marcar QA como aprobado.
- Mantener Producción como sin cambios.
- Agregar links finales de Drive cuando existan.
- Borrador local `ENTREGA_TECNICA_OFICIAL.md` actualizado al estado 2026-06-11 con avances Sandbox, fix `cliente`, bloqueo Helios/Softland y pendientes QA.
- Actualizar documentación oficial final después de resolver bloqueo Helios/Softland, validar flujo completo y cerrar Bloque B.
- Actualizar `IMPLEMENTATION_LOG.md` con el resultado final de Bloque B.
- Actualizar `ENTREGA_TECNICA_OFICIAL.md` cuando Bloque B esté validado.

## 7. Pendientes QA / Usuario QA

- Usuario QA puede apoyar con evidencia básica/no destructiva, pero las pruebas completas dependen de resolver el bloqueo Helios/Softland y cerrar la validación técnica de Bloque B.
- Videos deben subirse a Drive, carpeta o subcarpeta de Vh nuevos según la organización del equipo.
- Links de evidencia deben pegarse en la pestaña `Casos de prueba: Nuevos-BMW-Asesor (C-L)`.
- Usuario QA puede validar por ahora:
  - Abrir la Opportunity de prueba indicada por el equipo funcional.
  - Mostrar botón `Solicitudes anticipos`.
  - Abrir modal.
  - Validar que carga el overview.
  - Validar que la tabla de solicitudes se muestra.
  - Validar que no hay error visual en el modal.
- Usuario QA no debe ejecutar todavía:
  - Crear nuevo anticipo real.
  - Enviar a Tesorería.
  - Aprobar reserva.
  - Rechazar reserva.
  - Reenviar solicitud.
  - Evidencia final de flujo completo.
  - Pruebas destructivas sobre la Opportunity reservada para evidencia funcional.
- Motivo del bloqueo: el envío a Tesorería depende de confirmación Helios/Softland y actualmente la integración responde error funcional aunque Salesforce ya envía `cliente`.
- No probar aprobación de reserva hasta que Bloque B esté implementado, validado y habilitado para QA.
- No probar rechazo de reserva hasta que Bloque B esté implementado, validado y habilitado para QA.
- No probar reenvío de solicitud de reserva hasta que Bloque B esté implementado, validado y habilitado para QA.
- Validar primero:
  - Opportunity creada desde Ver inventario.
  - VIN presente.
  - Producto relacionado.
  - `JefeSucursal__c` completo.
  - `GerenteSucursal__c` completo.
  - Owner correcto.
  - Botón `Solicitudes anticipos` visible.
  - Modal abre sin error.

## 8. Pendientes de cierre de día

- Revisar `git diff`.
- Separar cambios de documentación vs metadata/código si aplica.
- Actualizar `IMPLEMENTATION_LOG.md`.
- Actualizar `ENTREGA_TECNICA_OFICIAL.md`.
- Revisar si `AGENTS.md` se mantiene fuera de commit.
- No hacer commit sin confirmación explícita.
- No hacer push sin confirmación explícita.
- Preparar resumen para el equipo funcional/técnico si corresponde.
- Mantener fuera de documentación oficial cualquier referencia a herramientas internas, rutas locales, ramas, commits o worktree.
- Respaldo local solicitado: `docs/VN-RQ106/backup_vn_rq106_20260610.patch`.
- Resumen de continuidad solicitado: `docs/VN-RQ106/CONTINUAR_MANANA_20260611.md`.

## 9. Estado actual del repositorio

Resumen del estado observado:

- Existen cambios locales en Apex, LWC, Flow, permission set y flexipages.
- Existen archivos no versionados relacionados con documentación, LWC quick action, quick action metadata y el nuevo campo de Bloque B.
- `AGENTS.md` aparece como archivo no versionado.
- No se hizo staging.
- No se hizo commit.
- No se hizo push.
- No se hizo deploy.
- No se hizo retrieve.
- Deploy real realizado solo a Sandbox durante la jornada: mejora LWC `vnRq106RegistrarIngresoAnticipo`, Id `0AfNq00000Xpu8SKAR`.
- Deploy real realizado solo a Sandbox durante la jornada 2026-06-11: fix `cliente` Tesorería, Id `0AfNq00000XqkyDKAR`.
- Producción permanece sin cambios.

## 10. Riesgos

- El Flow `VN_RQ106_Notificaciones_Anticipo` requiere validación en Sandbox antes de considerarse cerrado.
- Los textos finales de rechazo/reenvío todavía no están confirmados.
- La decisión sobre estado en reenvío debe confirmarse funcionalmente, aunque la propuesta técnica actual usa `Pendiente`.
- El comportamiento real con usuarios no administradores depende de FLS, permisos, layouts y acceso a registros.
- La evidencia formal todavía no está completa.
- Producción no debe tocarse hasta tener QA, evidencia y aprobación funcional.
- El envío a Tesorería sigue bloqueado aunque Salesforce ya envía `cliente`; la causa actual apunta a Helios/Softland/API o mapeo backend.
- El anticipo permanece en `Borrador` porque Helios/Softland no confirma la integración.
- No liberar QA completa a Usuario QA hasta que `Anticipo QA Sandbox` pueda pasar a Tesorería correctamente y quede validado el estado posterior.

## 11. Próximo orden recomendado

1. Enviar al equipo de integración el bloqueo actual de Helios/Softland indicando que Salesforce ya envía `cliente` con el código Softland del cliente.
2. Confirmar si backend corrige mapeo `cliente`.
3. Reintentar envío de `Anticipo QA Sandbox` a Tesorería.
4. Confirmar cambio de estatus e `Identificador_Helios__c`.
5. Llevar el anticipo a `Confirmada por Tesorería`.
6. Continuar validación UI con usuario `JefeSucursal__c` y usuario no autorizado.
7. Probar aprobación, rechazo y reenvío.
8. Validar notificaciones con Owner, Gerente y usuario ejecutor cuando se incluya Bloque B.2.
9. Preparar instrucciones finales para Usuario QA.
10. Actualizar Excel QA y documentación oficial Drive.
11. Completar links de Drive en Excel.
12. Preparar cierre para aprobación de pase.
