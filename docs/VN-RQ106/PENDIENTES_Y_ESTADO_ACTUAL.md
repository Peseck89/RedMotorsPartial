# VN-RQ106 - Pendientes y estado actual

Documento interno de control operativo. No usar como documento oficial de entrega sin revisión.

Fecha de actualización: 2026-06-12
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
  - `Estatus__c = En validación de Tesorería`.
  - `Estado_Aprobacion_Producto__c = Pendiente`.
  - `Identificador_Helios__c` generado por Helios/Softland.
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
- Validación posterior de integración:
  - La solicitud ya no presenta error por parámetro `cliente`.
  - Helios/Softland genera identificador externo.
  - El anticipo queda en estado `En validación de Tesorería`.
  - La aprobación o rechazo posterior queda pendiente del proceso externo en Helios.
  - PDF Softland continúa pendiente hasta que el proceso externo avance.
- Se creó documentación funcional/técnica para Bloque B.2 Notificaciones de reserva:
  - `docs/VN-RQ106/BLOQUE_B2_NOTIFICACIONES_RESERVA.md`.

## 2.1 Hotfixes post-checkpoint 2026-06-12

### Hotfix Tesorería — error `sObject type 'Organization' is not supported`

- Problema: Al enviar anticipo a Tesorería aparecía `sObject type 'Organization' is not supported`. Ocurría al ejecutar `SELECT IsSandbox FROM Organization LIMIT 1` en un perfil sin acceso al objeto Organization.
- Causa: Consulta directa a Organization sin manejo de excepciones en `SoftlandEndpointService` y `SolicitudAprobacionTesoreria`.
- Clases ajustadas: `SoftlandEndpointService`, `SolicitudAprobacionTesoreria`.
- Solución: Se envolvió la consulta en try/catch con fallback por dominio: `System.Url.getOrgDomainUrl().toExternalForm().toLowerCase()` — detecta Sandbox si contiene `--` o `.sandbox.`.
- Deploy `SoftlandEndpointService`: `0AfNq00000XtJmzKAF`.
- Deploy `SolicitudAprobacionTesoreria`: `0AfNq00000XtBr5KAF`.
- Validación: Paola/Jorge reintentaron el envío con ANT-01228 — el error no volvió a aparecer.
- Estado: **Validado en Sandbox**.

### Fix visual DotsContacto — `rellenarDatosContacto` Jefe de Sucursal

- Problema: Al entrar como Jefe de Sucursal a una Opportunity aparecía `Se ha producido un fallo no gestionado en este flujo`.
- Diagnóstico: El componente `flowruntime:interview` con el Flow `rellenarDatosContacto` se mostraba a todos los perfiles cuando algún campo del contacto estaba vacío — sin filtro de perfil.
- Flow detectado: `rellenarDatosContacto` (Screen Flow, sin faultConnectors).
- Páginas afectadas: `Opportunity_Record_Page_VN`, `Opportunity_Record_Page_VU`.
- Solución: Se ajustó la `visibilityRule` del componente en ambas FlexiPages agregando criterios `NE` para perfiles Jefe de Sucursal:
  - `booleanFilter`: `(1 OR 2 OR 3 OR 4) AND 5 AND 6`
  - Criterio 5: `{!$User.Profile.Name} NE "Jefe de Sucursal BMW Escazú"`
  - Criterio 6: `{!$User.Profile.Name} NE "Jefe de Sucursal BMW Uruca"`
- Deploy Sandbox: `0AfNq00000XtKntKAF`.
- Pendiente: Validar con Pedro que el error ya no aparece al abrir Opportunity con perfil Jefe de Sucursal.
- Estado: **Desplegado en Sandbox — pendiente validación funcional final con Pedro**.

### Pendiente Luis — correos temporales Flow notificaciones

- Solicitud: Luis pidió agregar temporalmente `oaparicio@redmotorscr.com` y `cmora@redmotorscr.com` al Flow `VN_RQ106_Notificaciones_Anticipo`.
- Estado: **Pendiente — NO aplicado todavía**.
- Nota: Temporal para Sandbox. Estos correos deben removerse o reemplazarse por destinatarios funcionales confirmados antes de cualquier pase a Producción.

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
- Confirmar resultado posterior del proceso externo en Helios.
- Confirmar aprobación o rechazo posterior del anticipo desde el proceso externo.
- Llevar el anticipo QA a `Confirmada por Tesorería`.
- Probar aprobar/rechazar/reenvío como `JefeSucursal__c`.
- Validar notificaciones Bloque B.2.

## 4. Decisiones funcionales ya tomadas

- El rechazo de reserva no cambia `Anticipo__c.Estatus__c`.
- El anticipo rechazado funcionalmente debe permanecer con `Estatus__c = Confirmada por Tesorería` si venía de ese estado.
- El usuario funcional que aprueba o rechaza reserva es `Opportunity.JefeSucursal__c`.
- Las notificaciones de aprobación/rechazo deben ir a Opportunity Owner + `Opportunity.GerenteSucursal__c`.
- Si el usuario que aprueba/rechaza coincide con un destinatario, no debe recibir su propia notificación.
- El reenvío debe permitir una nueva aprobación/rechazo.
- No probar aprobación/rechazo/reenvío con Usuario QA hasta cerrar desarrollo y validación técnica.

## 5. Pendientes por confirmar

- Destinatarios exactos de correo para rechazo de reserva.
- Destinatarios exactos de correo para reenvío de solicitud de reserva.
- Texto para reserva aprobada, si aplica.
- Enlace Helios.
- Confirmar si el reenvío debe dejar `Estado_Aprobacion_Producto__c` en blanco o en `Pendiente`.
- Confirmar si la aprobación debe ejecutar una reserva física adicional o solo actualizar el estado funcional en Salesforce.
- Confirmar si la configuración final de correos en Producción usará plantillas administradas o textos embebidos en Flow.
- Confirmar criterios finales de evidencia para cierre QA.
- Confirmar con el equipo funcional/técnico si `cliente` debe salir siempre de `Opportunity.Account.codigoSoftland__c` o si debe priorizar `Opportunity.Cuenta_de_Facturaci_n__r.codigoSoftland__c` cuando exista.

## 6. Pendientes de documentación

- Revisar el borrador documental alterno y descartar si está corrupto o desalineado.
- Usar la versión local v2 revisada como fuente confiable.
- Completar Google Doc oficial pegando tablas desde el contenido local preparado.
- No marcar QA como aprobado.
- Mantener Producción como sin cambios.
- Agregar links finales de Drive cuando existan.
- Borrador local `ENTREGA_TECNICA_OFICIAL.md` actualizado al estado 2026-06-11 con avances Sandbox, fix `cliente`, bloqueo Helios/Softland y pendientes QA.
- Actualizar documentación oficial final después de resolver bloqueo Helios/Softland, validar flujo completo y cerrar Bloque B.
- Actualizar `IMPLEMENTATION_LOG.md` con el resultado final de Bloque B.
- Actualizar `ENTREGA_TECNICA_OFICIAL.md` cuando Bloque B esté validado.
- Incorporar `BLOQUE_B2_NOTIFICACIONES_RESERVA.md` como referencia para implementación futura de notificaciones.

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
- Motivo del bloqueo: el envío inicial a Helios/Softland ya fue validado, pero el avance posterior de Tesorería, confirmación/rechazo y PDF Softland dependen del proceso externo.
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

## 9.1 Cierre de correos VN-RQ106 — Sandbox 2026-06-12

Se desplegó y activó una nueva versión del Flow `VN_RQ106_Notificaciones_Anticipo` con textos corregidos según plantillas de negocio.

Deploy:

- Flow: `VN_RQ106_Notificaciones_Anticipo`.
- Deploy ID: `0AfNq00000Xt7U5KAJ`.

Correos validados funcionalmente:

1. `Solicitud enviada a Tesorería`
   - Incluye resumen de solicitud.
   - Incluye cliente, asesor, tipo de ingreso, monto, medio de pago, fecha de ingreso, referencia/comprobante, depositante, vehículo/VIN, Ticket Helios y enlace Helios.
2. `Vehículo reservado`
   - Incluye vendedor, oportunidad, cliente, vehículo, VIN, reservado por, fecha/hora de reserva y estado `Vehículo reservado`.
3. `Reserva rechazada`
   - Mantiene texto aprobado.
   - Se ajustaron negritas y formato.
4. Reenvío de solicitud de reserva
   - No tuvo plantilla adicional nueva.
   - Se mantiene sin cambio de texto.

Estado:

- Flow actualizado y validado en Sandbox.
- Correos corregidos según plantillas de negocio.
- Pendiente para Producción: confirmar destinatarios/configuración productiva final antes del pase.

## 10. Riesgos

- El Flow `VN_RQ106_Notificaciones_Anticipo` fue validado funcionalmente en Sandbox; queda pendiente confirmar configuración productiva de destinatarios.
- Los textos funcionales de correos principales quedaron validados; reenvío se mantiene sin plantilla adicional nueva.
- La decisión sobre estado en reenvío debe confirmarse funcionalmente, aunque la propuesta técnica actual usa `Pendiente`.
- El comportamiento real con usuarios no administradores depende de FLS, permisos, layouts y acceso a registros.
- La evidencia formal todavía no está completa.
- Producción no debe tocarse hasta tener QA, evidencia y aprobación funcional.
- El envío inicial a Tesorería ya genera identificador externo, pero la aprobación o rechazo posterior sigue dependiendo del proceso externo.
- PDF Softland continúa pendiente hasta que el proceso externo avance.
- No liberar QA completa a Usuario QA hasta que `Anticipo QA Sandbox` complete validación de Tesorería y quede validado el estado posterior.

## 12. Cierre funcional Sandbox 2026-06-12

### Qué quedó validado

- Envío desde cero con usuario asesor: exitoso.
- Corrección parámetro `@adjunto` aplicada por el equipo de integración: confirmada.
- Identificador Softland/Helios generado correctamente.
- Modal cierra automáticamente tras envío exitoso.
- Columna `Código de anticipo` muestra `Identificador_Helios__c`.
- Columna `Id Helios` eliminada (era duplicado).
- Columna `Evidencia` ya no aparece.
- Texto PDF: `PDF Softland pendiente de generación`.
- El usuario asesor, al no ser `JefeSucursal__c`, NO puede aprobar, rechazar ni reenviar.
- El usuario configurado como `JefeSucursal__c` SÍ puede aprobar, rechazar y reenviar.
- Ciclo completo validado: rechazo → reenvío → aprobación → `Vehículo reservado`.
- Historial y resumen financiero actualizados correctamente.

### Registros de prueba

| Campo | Valor |
|---|---|
| Opportunity | Opportunity QA Sandbox |
| Owner / Asesor | Usuario QA Asesor |
| JefeSucursal__c | Usuario QA JefeSucursal |
| Cliente | Cliente QA Sandbox |
| Anticipo QA principal | Vehículo reservado / Aprobada / USD 100,00 |
| Anticipo QA secundario | Confirmada por Tesorería / Pendiente / USD 210,00 |

### Deploys

| Descripción | Deploy Id |
|---|---|
| UI + Flow B.2 | 0AfNq00000Xscq5KAB |
| Apex: `Anticipo creado` + Id Helios | 0AfNq00000Xsg5hKAB |
| Texto PDF Softland | 0AfNq00000XshD3KAJ |
| Autorización solo JefeSucursal__c | 0AfNq00000XswX3KAJ |
| Código anticipo = Identificador_Helios__c | 0AfNq00000XsxePKAR |

### Pendientes después del cierre 2026-06-12

1. Confirmar destinatarios/configuración productiva final de correos.
2. Consolidar evidencia final de QA.
3. Confirmar comportamiento final de PDF Softland, si aplica dentro del alcance.
4. No subir documentación oficial hasta completar revisión final.

---

## 13. Estado oficial del proyecto VN-RQ106 al 2026-06-12

### Avances completados en Sandbox

1. Registro de solicitudes de ingreso/anticipo desde la oportunidad.
2. Adjuntar evidencia en la solicitud.
3. Envío exitoso de solicitud a Tesorería.
4. Generación y recepción del identificador externo de Helios/Softland.
5. Visualización de `Código de anticipo` usando `Identificador_Helios__c`.
6. Eliminación de columnas duplicadas/no requeridas en la tabla.
7. Mensaje correcto para PDF Softland pendiente de generación.
8. Cierre automático del modal posterior al envío exitoso.
9. Control funcional de aprobación/rechazo/reenvío por usuario autorizado.
10. Validación de que el asesor no ejecuta aprobación/rechazo/reenvío.
11. Validación de que el usuario autorizado por producto sí ejecuta aprobación/rechazo/reenvío.
12. Flujo de rechazo de reserva.
13. Flujo de reenvío de solicitud de reserva.
14. Flujo de aprobación de reserva.
15. Actualización del estado a `Vehículo reservado`.
16. Actualización del historial de aprobaciones.
17. Actualización del resumen financiero.
18. Validación de correos/notificaciones del proceso:
    - Validación de ingreso requerida.
    - Solicitud de aprobación de reserva.
    - Reserva rechazada.
    - Vehículo reservado.
19. Flow `VN_RQ106_Notificaciones_Anticipo` actualizado y validado en Sandbox con plantillas de negocio.

### Pendientes oficiales

1. Consolidar evidencia final de QA.
2. Confirmar aprobación funcional de negocio.
3. Definir configuración final de destinatarios para Producción.
4. Sustituir configuración de destinatarios de Sandbox por configuración final productiva antes del pase.
5. Confirmar comportamiento final del PDF Softland generado, si aplica dentro del alcance.
6. Preparar paquete final de documentación de entrega.
7. Preparar plan de pase a Producción.
8. Ejecutar validación post-deploy en Producción cuando se autorice el pase.

### Estado de ambientes

- Sandbox: funcionalidad completa validada.
- Producción: sin cambios. Requiere aprobación funcional, evidencia y plan de pase antes de cualquier despliegue.

---

## 11. Próximo orden recomendado

1. Confirmar resultado posterior del proceso externo en Helios/Softland.
2. Confirmar cambio posterior a `Confirmada por Tesorería` o rechazo.
3. Confirmar generación de PDF Softland.
4. Continuar validación UI con usuario `JefeSucursal__c` y usuario no autorizado.
5. Probar aprobación, rechazo y reenvío.
6. Implementar y validar notificaciones con Owner, Gerente y usuario ejecutor cuando se incluya Bloque B.2.
7. Preparar instrucciones finales para Usuario QA.
8. Actualizar Excel QA y documentación oficial Drive.
9. Completar links de Drive en Excel.
10. Preparar cierre para aprobación de pase.
