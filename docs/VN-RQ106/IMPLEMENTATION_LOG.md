# RedMotors VN-RQ106 - Implementation Log

> DOCUMENTO INTERNO DE TRABAJO — NO ENTREGAR A NEGOCIO / QA / LÍDERES FUNCIONALES
>
> Este archivo es para trazabilidad operativa interna del desarrollo. No usar como documento oficial de entrega.

## Encabezado del proyecto

- Proyecto: RedMotors VN-RQ106
- Tema: Ingresos, anticipos y reserva de vehiculos
- Fecha: 2026-06-10
- Rama: `feature/pc/redmotors-vn-rq106-anticipo-ui-20260527`
- Org de trabajo: `RedMotorsSandbox`
- Produccion: no tocar

## Reglas de seguridad

- No documentar credenciales.
- No documentar tokens.
- No imprimir `access_token`.
- No abrir ni versionar clases sensibles sin sanitizacion previa:
  - `ExternalAuthService`
  - `SoftlandEndpointService`
  - `SolicitudAprobacionTesoreria`
- No mostrar ni registrar valores equivalentes a `clientId`, `clientSecret`, passwords, bearer tokens o archivos PDF en base64.

## Fuentes funcionales

- Documentacion oficial del proyecto VN-RQ106.
- Transcripcion de sesiones/reuniones.
- Mensajes del equipo funcional.
- Mensajes del equipo técnico.
- Respuesta funcional corregida del 10/06/2026 11:27 a. m.

## Decisiones funcionales confirmadas

- Pantalla 1 se elimina de Opportunity.
- Se accede desde boton `Solicitudes anticipos`.
- El boton abre un modal.
- Aprobar/rechazar reserva si es alcance original.
- Reenvio es alcance adicional estimado en 9 horas.
- En Partial no aplicar filtros de visibilidad por ahora.
- Estado de aprobacion producto sera campo nuevo en `Anticipo__c`.
- Al rechazar, `Anticipo__c.Estatus__c` permanece `Confirmada por Tesoreria`.
- Ticket Helios usa el Id Helios.
- Enlace Helios sigue pendiente de confirmacion.

## Configuracion de QA Sandbox

- Se configuraron destinatarios controlados para validación en Sandbox.
- No corresponden a la configuración productiva final.
- Deben sustituirse por destinatarios funcionales confirmados antes de cualquier pase a Producción.
- La configuración final debe seguir la documentación y los mensajes del equipo.

## Bloque A implementado localmente

- Objetivo: boton/modal `Solicitudes anticipos`.
- Estado: implementado localmente, pendiente dry-run/deploy.
- Descripcion:
  - Se creo un nuevo LWC quick action para Opportunity.
  - El quick action abre modal nativo de Salesforce.
  - El modal reutiliza `c-vn-rq106-opportunity-overview` pasando `record-id`.
  - `vnRq106OpportunityOverview` mantiene su logica existente y agrega modo modal para ocultar la accion interna `Registrar ingreso / anticipo`.
  - La accion `Opportunity.VN_RQ106_Solicitudes_Anticipos` se agrego a las Lightning Record Pages VN y VU.
  - El overview incrustado se retiro de las flexipages VN y VU; el LWC existente no fue eliminado.

### Archivos creados

- `force-app/main/default/lwc/vnRq106SolicitudesAnticipos/vnRq106SolicitudesAnticipos.html`
- `force-app/main/default/lwc/vnRq106SolicitudesAnticipos/vnRq106SolicitudesAnticipos.js`
- `force-app/main/default/lwc/vnRq106SolicitudesAnticipos/vnRq106SolicitudesAnticipos.js-meta.xml`
- `force-app/main/default/quickActions/Opportunity.VN_RQ106_Solicitudes_Anticipos.quickAction-meta.xml`

### Archivos modificados

- `force-app/main/default/lwc/vnRq106OpportunityOverview/vnRq106OpportunityOverview.html`
- `force-app/main/default/lwc/vnRq106OpportunityOverview/vnRq106OpportunityOverview.js`
- `force-app/main/default/lwc/vnRq106OpportunityOverview/vnRq106OpportunityOverview.css`
- `force-app/main/default/flexipages/Opportunity_Record_Page_VN.flexipage-meta.xml`
- `force-app/main/default/flexipages/Opportunity_Record_Page_VU.flexipage-meta.xml`

## Inventario tecnico inicial

- Objeto `Opportunity`.
- Objeto `Anticipo__c`.
- Campo `Anticipo__c.Estatus__c`.
- Campo `Anticipo__c.Comentarios_Aprobacion_Rechazo__c`.
- Campo `Anticipo__c.Comentarios_Asesor__c`.
- Campo `Anticipo__c.Producto__c`.
- Campo `Anticipo__c.Tipo_Ingreso__c`.
- Campo `Anticipo__c.Identificador_Helios__c`.
- Flow `VN_RQ106_Notificaciones_Anticipo`.
- LWC `vnRq106OpportunityOverview`.
- LWC `vnRq106SolicitudesAnticipos`.
- Quick Action `Opportunity.VN_RQ106_Solicitudes_Anticipos`.

## Campos pendientes

- Estado de aprobacion producto:
  - No existe todavia en `Anticipo__c`.
  - API Name pendiente de confirmar.
  - Tipo sugerido pendiente de confirmar.
  - Valores pendientes de confirmar.

## Pendientes funcionales

- Cuerpo completo del correo de rechazo.
- Texto del correo de reenvio.
- Enlace Helios.
- Destinatarios finales de Tesoreria contra documento oficial.
- API Name del nuevo campo Estado de aprobacion producto.
- Confirmacion de campos exactos de Jefe de Sucursal y Gerente de Sucursal.

## Proximo paso

- Revisar esta documentacion generada.
- Ejecutar dry-run solo del Bloque A.
- Si valida, desplegar Bloque A a `RedMotorsSandbox`.
- Probar manualmente en una Opportunity creada desde Ver inventario.

## Estado de trabajo

- No se hizo retrieve.
- No se hizo deploy.
- No se hizo commit.
- No se hizo push.
- No se hizo pull.
- No se hizo staging.
- No se toco Produccion.
- No se modifico Flow durante la creacion de este documento.
- No se modifico Apex adicional durante la creacion de este documento.
- No se modifico configuracion funcional adicional durante la creacion de este documento.

## Hotfixes post-checkpoint 2026-06-12

> Estos cambios ocurrieron DESPUÉS del checkpoint `f994472` y están documentados aquí para trazabilidad.

### Hotfix 1 — error `sObject type 'Organization' is not supported` (Tesorería)

- Problema: `SELECT IsSandbox FROM Organization LIMIT 1` falla para perfiles sin acceso al objeto Organization.
- Afectó: flujo de envío de anticipo a Tesorería (Paola/Jorge Agüero, ANT-01228).
- Clases: `SoftlandEndpointService` (untracked local), `SolicitudAprobacionTesoreria` (modificada).
- Solución: try/catch sobre la consulta Organization + fallback `System.Url.getOrgDomainUrl()`.
- Deploys Sandbox:
  - `SoftlandEndpointService`: `0AfNq00000XtJmzKAF`
  - `SolicitudAprobacionTesoreria`: `0AfNq00000XtBr5KAF`
- Validación: Paola/Jorge reintentaron — error no volvió a aparecer.
- Estado: validado en Sandbox.
- Nota de seguridad: `SoftlandEndpointService.cls` está presente localmente como untracked. No tiene credenciales hardcodeadas. Pendiente decidir si versionar (requiere sanitización previa y aprobación de equipo).

### Hotfix 2 — error Flow `rellenarDatosContacto` (DotsContacto / Jefe de Sucursal)

- Problema: Perfil Jefe de Sucursal abría Opportunity y veía `Se ha producido un fallo no gestionado en este flujo`.
- Causa: Flow `rellenarDatosContacto` se mostraba a todos los perfiles cuando campos de contacto estaban vacíos. Flow tiene cero faultConnectors.
- Páginas: `Opportunity_Record_Page_VN`, `Opportunity_Record_Page_VU`.
- Solución: Se agregaron criterios `NE` a la visibilityRule del componente flowruntime:interview:
  - `Jefe de Sucursal BMW Escazú`
  - `Jefe de Sucursal BMW Uruca`
  - booleanFilter: `(1 OR 2 OR 3 OR 4) AND 5 AND 6`
- Deploy Sandbox: `0AfNq00000XtKntKAF`.
- Estado: desplegado en Sandbox. Pendiente validación con Pedro.

## Correos QA adicionales Luis — Flow notificaciones

- Flow: `VN_RQ106_Notificaciones_Anticipo`.
- Correos agregados temporalmente: `oaparicio@redmotorscr.com`, `cmora@redmotorscr.com`.
- Correos QA completos activos en Sandbox:
  - `pago15924@gmail.com`
  - `paola.lobo@portalnetcr.com`
  - `sandra.lopez@portalnetcr.com`
  - `admin@portalnetcr.com`
  - `salesforcedevslp@gmail.com`
  - `oaparicio@redmotorscr.com`
  - `cmora@redmotorscr.com`
- Deploy Sandbox: `0AfNq00000XtO57KAF`.
- Pendiente: Confirmar recepción de correos.
- Estado: **Aplicado en Sandbox**.
- **NOTA OBLIGATORIA:** Temporal Sandbox. Remover o reemplazar TODOS los correos QA temporales antes de cualquier pase a Producción.

## Cierre funcional Sandbox 2026-06-12

### Deploys realizados en Sandbox

| Descripción | Deploy Id |
|---|---|
| UI + Flow B.2 | 0AfNq00000Xscq5KAB |
| Apex: permitir `Anticipo creado` + Id Helios para aprobación | 0AfNq00000Xsg5hKAB |
| Corrección texto PDF Softland | 0AfNq00000XshD3KAJ |
| Corrección autorización: solo JefeSucursal__c aprueba/rechaza/reenvía | 0AfNq00000XswX3KAJ |
| Columna `Código de anticipo` usa `Identificador_Helios__c` | 0AfNq00000XsxePKAR |
| Flow `VN_RQ106_Notificaciones_Anticipo` con correos corregidos | 0AfNq00000Xt7U5KAJ |

### Cierre de correos VN-RQ106 — Sandbox 2026-06-12

Se desplegó y activó una nueva versión del Flow `VN_RQ106_Notificaciones_Anticipo` con textos corregidos según plantillas de negocio.

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

Pendiente para Producción:

- Confirmar destinatarios/configuración productiva final antes del pase.

### Cambios de código aplicados localmente (sesión 2026-06-12)

**VN_RQ106_AnticipoController.cls**

- Eliminado: `overridePermissionSetCheck`, `hasPermissionSetVN_RQ106_Anticipo()`.
- `canManageReservationApproval(Id jefeSucursalId)` simplificado: compara `String.valueOf(jefeSucursalId) == UserInfo.getUserId()`, null-safe.
- Restaurado: inner class `ProductOption` para asegurar integridad de la clase.

**VN_RQ106_OpportunityOverviewController.cls**

- Eliminado: `overridePermissionSetCheck`, `hasPermissionSetVN_RQ106_Anticipo()`.
- Mismo cambio de `canManageReservationApproval`.
- Se restauró la integridad del archivo y se validó el contenido final.

**VN_RQ106_AnticipoControllerTest.cls**

- Eliminadas pruebas de bypass PS: `approveReservationByPermissionSetUserSucceeds`, `rejectReservationByPermissionSetUserSucceeds`.
- Renombrada: `reservationDecisionByNonJefeFails` (era `reservationDecisionByNonJefeWithoutPermissionSetFails`).
- Agregada: `reservationDecisionByPermissionSetHolderNonJefeFails` — verifica que el titular del PS sin ser JefeSucursal no puede decidir reservas.
- Restaurado: helper `getSolicitudForTreasuryBuild(Id anticipoId)`.
- Limpiado: código huérfano fuera del cierre de clase.

**VN_RQ106_OppOverviewCtrlTest.cls**

- Eliminadas referencias a `overridePermissionSetCheck`.
- `getOverviewShowsReservationActionsForPermissionSetUser` → reemplazada por `getOverviewHidesReservationActionsForPermissionSetUserNonJefe` (prueba negativa).
- `getOverviewShowsReservationActionsForAnticipoCreadoWithHeliosId` — corregida para usar `JefeSucursal__c = UserInfo.getUserId()` en lugar de override PS.
- Completado: `getOverviewHidesReservationActionsForAnticipoCreadoWithoutHeliosId`.

**vnRq106OpportunityOverview.html**

- Columna `Código de anticipo`: `{item.name}` → `{item.identificadorHelios}`.
- Columna `Id Helios` eliminada del thead y tbody (era duplicado exacto tras el cambio anterior).

### No se modificó

- `SolicitudAprobacionTesoreria.cls`
- Lógica de envío a Tesorería
- Lógica de integración Helios/Softland
- Flow B.2
- Producción

### Estado del repositorio al cierre 2026-06-12

- No se hizo staging.
- No se hizo commit.
- No se hizo push.
- No se hizo retrieve.
- No se hizo deploy local (deploys ya realizados directo desde VS Code / Sandbox en sesión anterior).
- Producción permanece sin cambios.

### Pendientes después del cierre 2026-06-12

1. Confirmar destinatarios/configuración productiva final de correos.
2. Consolidar evidencia final de QA.
3. Confirmar alcance final de PDF Softland, si aplica.
4. No subir documentación oficial hasta confirmar alcance y evidencia.

---

## Estado oficial del proyecto VN-RQ106 al 2026-06-12

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
