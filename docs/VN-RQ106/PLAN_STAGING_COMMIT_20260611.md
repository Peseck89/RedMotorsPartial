# Plan de staging y commit VN-RQ106

## Estado general

- Rama: `feature/pc/redmotors-vn-rq106-anticipo-ui-20260527`
- Sandbox: cambios desplegados parcialmente y validados.
- Produccion: sin cambios.
- QA completa: pendiente de proceso externo Helios/Softland, PDF Softland y validación de Bloque B.2.
- Commit final: pendiente hasta decisión sobre integración sensible y cierre de QA.

## Commit 1 sugerido: funcional VN-RQ106 desplegado en Sandbox

Incluir:

- `force-app/main/default/classes/VN_RQ106_AnticipoController.cls`
- `force-app/main/default/classes/VN_RQ106_AnticipoControllerTest.cls`
- `force-app/main/default/classes/VN_RQ106_OppOverviewCtrlTest.cls`
- `force-app/main/default/classes/VN_RQ106_OpportunityOverviewController.cls`
- `force-app/main/default/lwc/vnRq106OpportunityOverview/`
- `force-app/main/default/lwc/vnRq106RegistrarIngresoAnticipo/`
- `force-app/main/default/lwc/vnRq106SolicitudesAnticipos/`
- `force-app/main/default/quickActions/Opportunity.VN_RQ106_Solicitudes_Anticipos.quickAction-meta.xml`
- `force-app/main/default/flexipages/Opportunity_Record_Page_VN.flexipage-meta.xml`
- `force-app/main/default/flexipages/Opportunity_Record_Page_VU.flexipage-meta.xml`
- `force-app/main/default/objects/Anticipo__c/fields/Estado_Aprobacion_Producto__c.field-meta.xml`
- `force-app/main/default/permissionsets/VN_RQ106_Anticipo.permissionset-meta.xml`

Mensaje sugerido:

`feat(vn-rq106): add anticipation modal and reservation approval flow`

Notas:

- Excluir Flow.
- Excluir `jsconfig.json`.
- Validar antes descripcion del Permission Set si se quiere quitar texto "de prueba".
- Validar UI menor: scroll horizontal/modal y textos con tildes.

## Commit 2 sugerido: integracion sensible / cliente

Incluir solo si se acepta versionar clase real de integracion:

- `force-app/main/default/classes/SolicitudAprobacionTesoreria.cls`

Mensaje sugerido:

`fix(vn-rq106): include cliente in treasury request payload`

Notas:

- Contra Git parece cambio grande porque el baseline era mock.
- Contra copia real de Sandbox el cambio real son 2 lineas:
  - propiedad `cliente`
  - asignacion `cliente = codigoSoftland`
- Requiere decision de equipo porque versiona implementacion real de integracion.
- Revisar manejo de configuración de integración y `System.debug` en tarea separada.

## Commit 3 sugerido: documentacion interna

Incluir:

- `docs/VN-RQ106/README.md`
- `docs/VN-RQ106/ENTREGA_TECNICA_OFICIAL.md`
- `docs/VN-RQ106/PENDIENTES_Y_ESTADO_ACTUAL.md`
- `docs/VN-RQ106/ESTADO_QA_Y_EVIDENCIAS_20260611.md`
- `docs/VN-RQ106/QA_PEDRO_BMW_CASOS_C-L.md`
- `docs/VN-RQ106/PLAN_QA_EXCEL_20260611.md`
- `docs/VN-RQ106/BLOQUE_B2_NOTIFICACIONES_RESERVA.md`
- `docs/VN-RQ106/PLAN_STAGING_COMMIT_20260611.md`
- otros `.md` revisados que no contengan datos sensibles

Mensaje sugerido:

`docs(vn-rq106): document QA status and deployment plan`

## Excluir por ahora

No incluir:

- `force-app/main/default/flows/VN_RQ106_Notificaciones_Anticipo.flow-meta.xml`
- `force-app/main/default/lwc/jsconfig.json`
- `AGENTS.md`
- `tmp/`
- `docs/VN-RQ106/*.docx`
- `docs/VN-RQ106/*.patch`
- `docs/VN-RQ106/CONTEXTO_CODEX_VN_RQ106.md`
- `docs/VN-RQ106/CONTINUAR_MANANA_20260611.md`

## Motivo de exclusiones

- Flow: pertenece a Bloque B.2, esta Active, tiene destinatario temporal y textos pendientes.
- `jsconfig.json`: cambio de newline/EOL sin valor funcional.
- `AGENTS.md`: instrucciones locales internas.
- `tmp/`: backups temporales y clase sensible.
- `.docx` / `.patch`: binarios y respaldos; revisar antes de versionar.

## Pendientes antes de commit final

- Confirmar avance posterior del proceso externo Helios/Softland.
- Confirmar generación de PDF Softland.
- Definir si `SolicitudAprobacionTesoreria.cls` se versiona ahora o separado.
- Decidir si se limpian textos/tildes UI.
- Decidir si se ajusta descripcion del Permission Set.
- Validar si `cliente` debe usar `Account.codigoSoftland__c` o `Cuenta_de_Facturaci_n__r.codigoSoftland__c`.
- Confirmar si `canResendReservation` debe validar tambien `Estatus__c = Confirmada por Tesoreria`.
- Implementar y validar Bloque B.2 Notificaciones de reserva.
