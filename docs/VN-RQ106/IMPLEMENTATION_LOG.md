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
- Mensajes de Maria.
- Mensajes de Luis.
- Mensajes de Diego.
- Respuesta corregida de Luis del 10/06/2026 11:27 a. m.

## Decisiones confirmadas por Luis

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

## Configuracion temporal de QA

- Se configuró un correo temporal de pruebas como destinatario durante QA.
- No es defecto funcional.
- Debe retirarse al finalizar QA.
- La configuracion final debe seguir la documentacion y los mensajes del equipo.

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
