public class CaseTriggerHandler extends TriggerHandler {

    public static Boolean runOrders = false;

    public List<Case> newRecordList { get; set; }
    public Map<Id, Case> newRecordMap { get; set; }
    public List<Case> oldRecordList { get; set; }
    public Map<Id, Case> oldRecordMap { get; set; }

    public CaseTriggerHandler() {
        // Inicializar listas y mapas con los registros del trigger
        this.newRecordList = (List<Case>) Trigger.New;
        this.newRecordMap = (Map<Id, Case>) Trigger.newMap;
        this.oldRecordList = (List<Case>) Trigger.Old;
        this.oldRecordMap = (Map<Id, Case>) Trigger.oldMap;                 
    }

    public override void afterUpdate(){  
        // onAfterUpdate(newRecordList, newRecordMap, oldRecordMap);
        completarTrabajosYSubtrabajos(newRecordList, oldRecordMap);
    }

    public override void beforeDelete() {
        // Llamar al método de validación antes de eliminar los casos
        validateDeleteCases(oldRecordList);
    }

    // Crear método que valide que Case.Status cambio a Cerrado, consulte los WorkSteps relacionados por WorkStep.Caso__c
    // donde WorkStep.Status != Completada y StartTime != null.
    // Si existen registros, actualiza el campo WorkStep.Status a Completada
    public static void completarTrabajosYSubtrabajos(List<Case> newRecordList, Map<Id, Case> oldRecordMap){
        Set<String> caseIds = new Set<String>();
        for(Case caso : newRecordList) {
            if(caso.Status != oldRecordMap.get(caso.Id).Status && caso.Status == 'Cerrado')
                caseIds.add(caso.Id);
        }
        
        if(caseIds.size() > 0) {
            List<WorkStep> workStepsToComplete = [SELECT Id, Status, StartTime, EndTime FROM WorkStep 
                                                  WHERE Caso__c IN :caseIds AND Status != 'Completada'];
            
            if(workStepsToComplete.size() > 0) {
                for(WorkStep ws : workStepsToComplete) {
                    ws.Status = 'Completada';
                    ws.RM_SkipVR__c = true;
                    ws.StartTime = ws.StartTime != null ? ws.StartTime : System.now();
                }
                WorkStepTriggerHandler.bypass('RM_WorkStep_Trg_Handler');
                update workStepsToComplete;

                for(WorkStep ws : workStepsToComplete) {
                    ws.RM_SkipVR__c = false;
                }
                update workStepsToComplete;
                WorkStepTriggerHandler.clearBypass('RM_WorkStep_Trg_Handler');
            }
        }
    }

    // Validar que el usuario actual, si contiene 'egaray@redmotorscr.com' en su nombre de usuario,
    // no pueda eliminar casos a menos que sean de tipo de registro exactamente 'Motos' o 'Autos'
    private void validateDeleteCases(List<Case> casesToDelete) {
        // Obtener el usuario actual y verificar si el nombre de usuario contiene 'egaray@redmotorscr.com'
        User currentUser = [SELECT Username FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        
        if (currentUser.Username.contains('egaray@redmotorscr.com')) {
            // Obtener los Ids de Record Types válidos para 'Motos' y 'Autos' y almacenarlos en un Set
            Set<Id> validRecordTypeIds = new Set<Id>();
            for (RecordType rt : [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND Name IN ('Motos', 'Autos')]) {
                validRecordTypeIds.add(rt.Id);
            }

            // Iterar sobre los casos que se están intentando eliminar
            for (Case caseRecord : casesToDelete) {
                // Verificar si el RecordTypeId del caso no está en el conjunto de Ids válidos
                if (validRecordTypeIds.contains(caseRecord.RecordTypeId)) {
                    // Agregar un error que previene la eliminación del caso si no es del tipo permitido
                    caseRecord.addError('No tienes permiso para eliminar casos que sean de taller.');
                }
            }
        }
    }

    public override void beforeUpdate() {

        String currentUserProfileName = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;
        // Boolean esAdmin = currentUserProfileName == 'System Administrator'; 
        Boolean esAdmin = currentUserProfileName == 'System Administrator' || 
                 currentUserProfileName == 'Administrador de Sistema' ||
                 currentUserProfileName == 'Asesor de Taller V2' ||
                 currentUserProfileName == 'Asesor Call Center V2' ||
                 currentUserProfileName == 'Administrador del Sistema';

        if(esAdmin){
            // Consultar solicitudes aprobadas
            // Detectar si el cambio actual de cuenta ya fue aprobado exactamente igual
            Map<Id, List<Cambio_de_Propietario__c>> cambiosAprobadosPorCase = new Map<Id, List<Cambio_de_Propietario__c>>();
            for (Cambio_de_Propietario__c cambio : [
                SELECT Id, Case__c, Cuenta_Anterior__c, Cuenta_Nueva__c
                FROM Cambio_de_Propietario__c
                WHERE Estado__c = 'Aprobado'
            ]) {
                if (!cambiosAprobadosPorCase.containsKey(cambio.Case__c)) {
                    cambiosAprobadosPorCase.put(cambio.Case__c, new List<Cambio_de_Propietario__c>());
                }
                cambiosAprobadosPorCase.get(cambio.Case__c).add(cambio);
            }


            List<Cambio_de_Propietario__c> nuevasSolicitudes = new List<Cambio_de_Propietario__c>();
            List<Messaging.SingleEmailMessage> correos = new List<Messaging.SingleEmailMessage>();
            Id cuentaVieja;
            Id cuentaNueva;
            for (Case c : newRecordList) {
                Case oldC = oldRecordMap.get(c.Id);
                Boolean yaFueAprobadoMismoCambio = false;
                if (cambiosAprobadosPorCase.containsKey(c.Id)) {
                    for (Cambio_de_Propietario__c aprobado : cambiosAprobadosPorCase.get(c.Id)) {
                        if (aprobado.Cuenta_Anterior__c == oldC.AccountId &&
                            aprobado.Cuenta_Nueva__c == c.AccountId) {
                            yaFueAprobadoMismoCambio = true;
                            break;
                        }
                    }
                }

                if (c.AccountId != oldC.AccountId && !yaFueAprobadoMismoCambio && c.ignorarCambio__c != true) {            
                    // if (c.Aprobador__c == null) {
                    //     c.AccountId = oldC.AccountId;
                    //     c.addError('No se puede solicitar el cambio de cuenta porque el campo Aprobador__c no está definido.');
                    //     continue;
                    // }

                    nuevasSolicitudes.add(new Cambio_de_Propietario__c(
                        Case__c = c.Id,
                        Solicitante__c = UserInfo.getUserId(),
                        Cuenta_Anterior__c = oldC.AccountId,
                        Cuenta_Nueva__c = c.AccountId,
                        Estado__c = 'Pendiente'
                    ));
                    cuentaVieja = oldC.AccountId;
                    cuentaNueva = c.AccountId;
                    // c.AccountId = oldC.AccountId;
                    //c.addError('El cambio de cuenta asociada requiere aprobación. Se ha enviado una solicitud.');
                }else if(c.ignorarCambio__c == true){
                    c.ignorarCambio__c = false;
                }
            }
            // Insertar las solicitudes antes de marcar el error
            if (!nuevasSolicitudes.isEmpty() ) {
                List<Account> lstAccountVieja = [Select Id,Name From Account Where Id =: cuentaVieja];
                List<Account> lstAccountNueva = [Select Id,Name From Account Where Id =: cuentaNueva];

                insert nuevasSolicitudes;

                for (Cambio_de_Propietario__c s : nuevasSolicitudes) {
                    Case caso = newRecordMap.get(s.Case__c);
                    String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
                    String aprobarUrl = baseUrl + '/apex/CambioOwnerDecision?id=' + s.Id + '&accion=aprobar';
                    String rechazarUrl = baseUrl + '/apex/CambioOwnerDecision?id=' + s.Id + '&accion=rechazar';

                // String cuerpoHtml = 'El usuario <b>' + UserInfo.getName() + '</b> ha solicitado cambiar la cuenta asociada del caso "<b>' + caso.CaseNumber + '</b>" '
                //     + 'de la cuenta <b>' + (lstAccountVieja.isEmpty() ? '(Sin nombre)' : lstAccountVieja[0].Name) + '</b> '
                //     + 'a la cuenta <b>' + (lstAccountNueva.isEmpty() ? '(Sin nombre)' : lstAccountNueva[0].Name) + '</b>.<br><br>'
                //     + '<a href="' + aprobarUrl + '">Aprobar</a><br>'
                //     + '<a href="' + rechazarUrl + '">Rechazar</a>';


                    String cuerpoHtml =
                    '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">' +
                    '<html dir="ltr" xmlns="http://www.w3.org/1999/xhtml" xmlns:o="urn:schemas-microsoft-com:office:office" lang="es">' +
                    '<head>' +
                    '<meta charset="UTF-8">' +
                    '<meta content="width=device-width, initial-scale=1" name="viewport">' +
                    '<meta name="x-apple-disable-message-reformatting">' +
                    '<meta http-equiv="X-UA-Compatible" content="IE=edge">' +
                    '<meta content="telephone=no" name="format-detection">' +
                    '<title>Correo agradecimiento</title>' +
                    '<style type="text/css">' +
                    '.rollover:hover .rollover-first {' +
                    '  max-height: 0px !important;' +
                    '  display: none !important;' +
                    '}' +
                    '' +
                    '.rollover:hover .rollover-second {' +
                    '  max-height: none !important;' +
                    '  display: block !important;' +
                    '}' +
                    '' +
                    '.rollover span {' +
                    '  font-size: 0px;' +
                    '}' +
                    '' +
                    'u+.body img~div div {' +
                    '  display: none;' +
                    '}' +
                    '' +
                    '#outlook a {' +
                    '  padding: 0;' +
                    '}' +
                    '' +
                    'span.MsoHyperlink,' +
                    'span.MsoHyperlinkFollowed {' +
                    '  color: inherit;' +
                    '  mso-style-priority: 99;' +
                    '}' +
                    '' +
                    'a.es-button {' +
                    '  mso-style-priority: 100 !important;' +
                    '  text-decoration: none !important;' +
                    '}' +
                    '' +
                    'a[x-apple-data-detectors] {' +
                    '  color: inherit !important;' +
                    '  text-decoration: none !important;' +
                    '  font-size: inherit !important;' +
                    '  font-family: inherit !important;' +
                    '  font-weight: inherit !important;' +
                    '  line-height: inherit !important;' +
                    '}' +
                    '' +
                    '.es-desk-hidden {' +
                    '  display: none;' +
                    '  float: left;' +
                    '  overflow: hidden;' +
                    '  width: 0;' +
                    '  max-height: 0;' +
                    '  line-height: 0;' +
                    '  mso-hide: all;' +
                    '}' +
                    '' +
                    '.es-button-border:hover>a.es-button {' +
                    '  color: #ffffff !important;' +
                    '}' +
                    '' +
                    '@media only screen and (max-width:600px) {' +
                    '  h1 {' +
                    '    font-size: 30px !important;' +
                    '    text-align: left' +
                    '  }' +
                    '' +
                    '  h2 {' +
                    '    font-size: 24px !important;' +
                    '    text-align: left' +
                    '  }' +
                    '' +
                    '  h3 {' +
                    '    font-size: 20px !important;' +
                    '    text-align: left' +
                    '  }' +
                    '' +
                    '  .es-m-p20b {' +
                    '    padding-bottom: 20px !important' +
                    '  }' +
                    '' +
                    '  *[class="gmail-fix"] {' +
                    '    display: none !important' +
                    '  }' +
                    '' +
                    '  p,' +
                    '  a {' +
                    '    line-height: 150% !important' +
                    '  }' +
                    '' +
                    '  h1,' +
                    '  h1 a {' +
                    '    line-height: 120% !important' +
                    '  }' +
                    '' +
                    '  h2,' +
                    '  h2 a {' +
                    '    line-height: 120% !important' +
                    '  }' +
                    '' +
                    '  h3,' +
                    '  h3 a {' +
                    '    line-height: 120% !important' +
                    '  }' +
                    '' +
                    '  h4,' +
                    '  h4 a {' +
                    '    line-height: 120% !important' +
                    '  }' +
                    '' +
                    '  h5,' +
                    '  h5 a {' +
                    '    line-height: 120% !important' +
                    '  }' +
                    '  ' +
                    '  h6,' +
                    '  h6 a {' +
                    '    line-height: 120% !important' +
                    '  }' +
                    '' +
                    '  h4 {' +
                    '    font-size: 24px !important;' +
                    '    text-align: left' +
                    '  }' +
                    '' +
                    '  h5 {' +
                    '    font-size: 20px !important;' +
                    '    text-align: left' +
                    '  }' +
                    '' +
                    '  h6 {' +
                    '    font-size: 16px !important;' +
                    '    text-align: left' +
                    '  }' +
                    '' +
                    '  .es-header-body h1 a,' +
                    '  .es-content-body h1 a,' +
                    '  .es-footer-body h1 a {' +
                    '    font-size: 30px !important' +
                    '  }' +
                    '' +
                    '  .es-header-body h2 a,' +
                    '  .es-content-body h2 a,' +
                    '  .es-footer-body h2 a {' +
                    '    font-size: 24px !important' +
                    '  }' +
                    '' +
                    '  .es-header-body h3 a,' +
                    '  .es-content-body h3 a,' +
                    '  .es-footer-body h3 a {' +
                    '    font-size: 20px !important' +
                    '  }' +
                    '' +
                    '  .es-header-body h4 a,' +
                    '  .es-content-body h4 a,' +
                    '  .es-footer-body h4 a {' +
                    '    font-size: 24px !important' +
                    '  }' +
                    '' +
                    '  .es-header-body h5 a,' +
                    '  .es-content-body h5 a,' +
                    '  .es-footer-body h5 a {' +
                    '    font-size: 20px !important' +
                    '  }' +
                    '' +
                    '  .es-header-body h6 a,' +
                    '  .es-content-body h6 a,' +
                    '  .es-footer-body h6 a {' +
                    '    font-size: 16px !important' +
                    '  }' +
                    '' +
                    '  .es-menu td a {' +
                    '    font-size: 14px !important' +
                    '  }' +
                    '' +
                    '  .es-header-body p,' +
                    '  .es-header-body a {' +
                    '    font-size: 14px !important' +
                    '  }' +
                    '' +
                    '  .es-content-body p,' +
                    '  .es-content-body a {' +
                    '    font-size: 14px !important' +
                    '  }' +
                    '' +
                    '  .es-footer-body p,' +
                    '  .es-footer-body a {' +
                    '    font-size: 14px !important' +
                    '  }' +
                    '' +
                    '  .es-infoblock p,' +
                    '  .es-infoblock a {' +
                    '    font-size: 12px !important' +
                    '  }' +
                    '' +
                    '  .es-m-txt-c,' +
                    '  .es-m-txt-c h1,' +
                    '  .es-m-txt-c h2,' +
                    '  .es-m-txt-c h3,' +
                    '  .es-m-txt-c h4,' +
                    '  .es-m-txt-c h5,' +
                    '  .es-m-txt-c h6 {' +
                    '    text-align: center !important' +
                    '  }' +
                    '' +
                    '  .es-m-txt-r,' +
                    '  .es-m-txt-r h1,' +
                    '  .es-m-txt-r h2,' +
                    '  .es-m-txt-r h3,' +
                    '  .es-m-txt-r h4,' +
                    '  .es-m-txt-r h5,' +
                    '  .es-m-txt-r h6 {' +
                    '    text-align: right !important' +
                    '  }' +
                    '' +
                    '  .es-m-txt-j,' +
                    '  .es-m-txt-j h1,' +
                    '  .es-m-txt-j h2,' +
                    '  .es-m-txt-j h3,' +
                    '  .es-m-txt-j h4,' +
                    '  .es-m-txt-j h5,' +
                    '  .es-m-txt-j h6 {' +
                    '    text-align: justify !important' +
                    '  }' +
                    '' +
                    '  .es-m-txt-l,' +
                    '  .es-m-txt-l h1,' +
                    '  .es-m-txt-l h2,' +
                    '  .es-m-txt-l h3,' +
                    '  .es-m-txt-l h4,' +
                    '  .es-m-txt-l h5,' +
                    '  .es-m-txt-l h6 {' +
                    '    text-align: left !important' +
                    '  }' +
                    '' +
                    '  .es-m-txt-r img,' +
                    '  .es-m-txt-c img,' +
                    '  .es-m-txt-l img {' +
                    '    display: inline !important' +
                    '  }' +
                    '' +
                    '  .es-m-txt-r .rollover:hover .rollover-second,' +
                    '  .es-m-txt-c .rollover:hover .rollover-second,' +
                    '  .es-m-txt-l .rollover:hover .rollover-second {' +
                    '    display: inline !important' +
                    '  }' +
                    '' +
                    '  .es-m-txt-r .rollover span,' +
                    '  .es-m-txt-c .rollover span,' +
                    '  .es-m-txt-l .rollover span {' +
                    '    line-height: 0 !important;' +
                    '    font-size: 0 !important' +
                    '  }' +
                    '' +
                    '  .es-spacer {' +
                    '    display: inline-table' +
                    '  }' +
                    '' +
                    '  a.es-button,' +
                    '  button.es-button {' +
                    '    font-size: 18px !important;' +
                    '    line-height: 120% !important' +
                    '  }' +
                    '' +
                    '  a.es-button,' +
                    '  button.es-button,' +
                    '  .es-button-border {' +
                    '    display: inline-block !important' +
                    '  }' +
                    '' +
                    '  .es-m-fw,' +
                    '  .es-m-fw.es-fw,' +
                    '  .es-m-fw .es-button {' +
                    '    display: block !important' +
                    '  }' +
                    '' +
                    '  .es-m-il,' +
                    '  .es-m-il .es-button,' +
                    '  .es-social,' +
                    '  .es-social td,' +
                    '  .es-menu {' +
                    '    display: inline-block !important' +
                    '  }' +
                    '' +
                    '  .es-adaptive table,' +
                    '  .es-left,' +
                    '  .es-right {' +
                    '    width: 100% !important' +
                    '  }' +
                    '' +
                    '  .es-content table,' +
                    '  .es-header table,' +
                    '  .es-footer table,' +
                    '  .es-content,' +
                    '  .es-footer,' +
                    '  .es-header {' +
                    '    width: 100% !important;' +
                    '    max-width: 600px !important' +
                    '  }' +
                    '' +
                    '  .adapt-img {' +
                    '    width: 100% !important;' +
                    '    height: auto !important' +
                    '  }' +
                    '' +
                    '  .es-mobile-hidden,' +
                    '  .es-hidden {' +
                    '    display: none !important' +
                    '  }' +
                    '' +
                    '  .es-desk-hidden {' +
                    '    width: auto !important;' +
                    '    overflow: visible !important;' +
                    '    float: none !important;' +
                    '    max-height: inherit !important;' +
                    '    line-height: inherit !important;' +
                    '    display: table-row !important' +
                    '  }' +
                    '' +
                    '  tr.es-desk-hidden {' +
                    '    display: table-row !important' +
                    '  }' +
                    '' +
                    '  table.es-desk-hidden {' +
                    '    display: table !important' +
                    '  }' +
                    '  ' +
                    '  td.es-desk-menu-hidden {' +
                    '    display: table-cell !important' +
                    '  }' +
                    '' +
                    '  .es-menu td {' +
                    '    width: 1% !important' +
                    '  }' +
                    '' +
                    '  table.es-table-not-adapt,' +
                    '  .esd-block-html table {' +
                    '    width: auto !important' +
                    '  }' +
                    '' +
                    '  .es-social td {' +
                    '    padding-bottom: 10px' +
                    '  }' +
                    '' +
                    '  .h-auto {' +
                    '    height: auto !important' +
                    '  }' +
                    '}' +
                    '' +
                    '@media screen and (max-width:384px) {' +
                    '  .mail-message-content {' +
                    '    width: 414px !important' +
                    '  }' +
                    '}' +
                    '</style>' +
                    '</head>' +
                    '<body class="body" style="width:100%;height:100%;padding:0;Margin:0">' +
                    '<div dir="ltr" class="es-wrapper-color" lang="es" style="background-color:#F6F6F6">' +
                    '<table class="es-wrapper" width="100%" cellspacing="0" cellpadding="0" role="none" style="mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;padding:0;Margin:0;width:100%;height:100%;background-repeat:repeat;background-position:center top;background-color:#F6F6F6">' +
                    '<tr><td valign="top" style="padding:0;Margin:0">' +
                    '<table class="es-header" cellspacing="0" cellpadding="0" align="center" role="none" style="mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;width:100%;table-layout:fixed !important;background-color:transparent;background-repeat:repeat;background-position:center top">' +
                    '<tr><td align="center" style="padding:0;Margin:0">' +
                    '<table class="es-header-body" cellspacing="0" cellpadding="0" bgcolor="#f1f1f1" align="center" style="mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;background-color:#f1f1f1;width:600px" role="none">' +
                    '<tr><td align="left" style="padding:0;Margin:0;padding-top:20px;padding-right:20px;padding-left:20px">' +
                    '<table cellspacing="0" cellpadding="0" width="100%" role="none" style="mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px">' +
                    '<tr><td valign="top" align="center" style="padding:0;Margin:0;width:560px">' +
                    '<table width="100%" cellspacing="0" cellpadding="0" role="presentation" style="mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px">' +
                    '<tr><td align="center" style="padding:0;Margin:0;font-size:0px"><img src="https://ehxeqpz.stripocdn.email/content/guids/CABINET_acb286200a147884b697334b6b8ba60e6526faf6b747b3e2060647d7f175b4c5/images/redmlogocolor_uPR.png" alt style="display:block;font-size:14px;border:0;outline:none;text-decoration:none" width="115"></td></tr>' +
                    '</table></td></tr></table></td></tr></table></td></tr></table>' +
                    '<table class="es-content" cellspacing="0" cellpadding="0" align="center" role="none" style="mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;width:100%;table-layout:fixed !important">' +
                    '<tr><td align="center" style="padding:0;Margin:0">' +
                    '<table class="es-content-body" cellspacing="0" cellpadding="0" bgcolor="#f1f1f1" align="center" style="mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;background-color:#f1f1f1;width:600px" role="none">' +
                    '<tr><td align="left" style="padding:20px;Margin:0">' +
                    '<table width="100%" cellspacing="0" cellpadding="0" role="none" style="mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px">' +
                    '<tr><td valign="top" align="center" style="padding:0;Margin:0;width:560px">' +
                    '<table width="100%" cellspacing="0" cellpadding="0" bgcolor="#ffffff" style="mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;background-color:#ffffff" role="presentation">' +
                    '<tr><td align="center" style="padding:0;Margin:0;padding-top:30px;padding-bottom:30px">' +
                    '<p style="Margin:0;mso-line-height-rule:exactly;font-family:arial, helvetica neue, helvetica, sans-serif;line-height:45px;letter-spacing:0;color:#333333;font-size:30px"><strong><span style="color:#ee272c">SOLICITUD</span></strong></p>' +
                    '<p style="Margin:0;mso-line-height-rule:exactly;font-family:arial, helvetica neue, helvetica, sans-serif;line-height:45px;letter-spacing:0;color:#696969;font-size:30px">CAMBIO DE PROPIETARIO</p>' +
                    '</td></tr>' +
                    '<tr><td align="center" style="padding:0;Margin:0;padding-bottom:30px;padding-left:40px;padding-right:40px">' +
                    '<p style="Margin:0;mso-line-height-rule:exactly;font-family:arial, helvetica neue, helvetica, sans-serif;line-height:26px;letter-spacing:0;color:#333333;font-size:17px">' +
                    'El usuario <b>' + UserInfo.getName() + '</b> ha solicitado cambiar la cuenta asociada del caso "<b>' + caso.CaseNumber + '</b>" ' +
                    'de la cuenta <b>' + (lstAccountVieja.isEmpty() ? '(Sin nombre)' : lstAccountVieja[0].Name) + '</b> ' +
                    'a la cuenta <b>' + (lstAccountNueva.isEmpty() ? '(Sin nombre)' : lstAccountNueva[0].Name) + '</b>.<br><br>' +
                    '</p></td></tr>' +
                    '<tr><td align="center" style="padding:0;Margin:0;padding-bottom:30px">' +
                    '<span class="msohide es-button-border" style="border-style:solid;border-color:#ee272c;background:#ee272c;border-width:0px;display:inline-block;border-radius:30px;width:auto;mso-hide:all">' +
                    '<a href="' + aprobarUrl + '" class="es-button es-button-1720444452388" target="_blank" style="mso-style-priority:100 !important;text-decoration:none !important;mso-line-height-rule:exactly;color:#FFFFFF;font-size:18px;padding:10px 20px;display:inline-block;background:#ee272c;border-radius:30px;font-family:arial, helvetica neue, helvetica, sans-serif;font-weight:normal;font-style:normal;line-height:22px;width:auto;text-align:center;letter-spacing:0;mso-padding-alt:0;mso-border-alt:10px solid #ee272c">Aprobar</a></span>' +
                    '</td></tr>' +
                    '<tr><td align="center" style="padding:0;Margin:0;padding-bottom:30px;padding-left:40px;padding-right:40px">' +
                    '<p style="Margin:0;mso-line-height-rule:exactly;font-family:arial, helvetica neue, helvetica, sans-serif;line-height:21px;letter-spacing:0;color:#333333;font-size:14px">' +
                    '<a target="_blank" href="' + rechazarUrl + '" style="mso-line-height-rule:exactly;text-decoration:underline;color:#fe8b8f;font-size:14px">Rechazar</a>' +
                    '</p></td></tr>' +
                    '<tr><td align="center" style="padding:0;Margin:0;font-size:0px"><img class="adapt-img" src="https://ehxeqpz.stripocdn.email/content/guids/CABINET_acb286200a147884b697334b6b8ba60e6526faf6b747b3e2060647d7f175b4c5/images/p90343281crophighres.jpg" alt style="display:block;font-size:14px;border:0;outline:none;text-decoration:none" width="560"></td></tr>' +
                    '</table></td></tr></table></td></tr></table></td></tr></table>' +
                    '</td></tr></table></div></body></html>';

                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setSubject('Solicitud de cambio de cuenta en caso');
                    mail.setHtmlBody(cuerpoHtml);
                    mail.setToAddresses(new String[] {
                        'aprobacioncp@redmotorscr.com',
                        'john.navarro@portalnetcr.com',
                        'oaparicio@redmotorscr.com'
                    });
                    mail.setSaveAsActivity(false);
                    correos.add(mail);
                }

                if (!correos.isEmpty()) {
                    Messaging.sendEmail(correos);
                }

                // Ahora sí, lanzar los errores
                for (Case c : newRecordList) {
                    Case oldC = oldRecordMap.get(c.Id);
                    if (c.AccountId != oldC.AccountId && !cambiosAprobadosPorCase.containsKey(c.Id)) {
                        c.AccountId = oldC.AccountId;
                        //c.addError('El cambio de cuenta asociada requiere aprobación. Se ha enviado una solicitud.');
                    }
                }
            }
                
        }
        

    }




    // <<<pendiente de revisar>>>
    // public static void onAfterUpdate(List<Case> newList, Map<Id, Case> newRecordMap, Map<Id, Case> oldRecordMap)
    // {
    //     CaseTriggerHandler.runOrders = true;
    //     Set<String> caseIds = new Set<String>();
    //     for(Case cs : newList) {
    //         if(cs.Create_Orders_from_Workorders__c)
    //             caseIds.add(cs.Id);
    //     }
        
    //     if(caseIds.size() > 0) {
    //         List<Workorder> woList = [SELECT Id FROM Workorder WHERE CaseId in : caseIds];
            
    //         if(woList.size() > 0) {
    //             update woList;
    //         }
    //         updateCaseCheck(caseIds);
    //     }

    //     caseIds = new Set<String>();
    //     for (Case caso : newList) {
    //         if (caso.Mecanico_Asignado__c != oldRecordMap.get(caso.Id).Mecanico_Asignado__c && caso.Mecanico_Asignado__c != null && caso.Status != 'Cerrado') {
    //             caseIds.add(caso.Id);
    //         }
    //     }

    //     if (caseIds.size() > 0) {
    //         List<WorkStep> workStepList = [SELECT Id, Mec_nico_asignado__c, Caso__c, Status, Flag_Is_Task_FX__c, WorkOrder.Status FROM WorkStep 
    //                                        WHERE Caso__c IN : caseIds AND Caso__r.Status != 'Cerrado' AND Status != 'Completada' 
    //                                        AND WorkOrder.Etapa_de_flujo_de_trabajo__c != 'Orden Facturada' 
    //                                        AND WorkOrder.Etapa_de_flujo_de_trabajo__c != 'Orden Rechazada'];

    //         Map<Id, Boolean> caseIdBooleanMap = new Map<Id, Boolean>();
    //         for (WorkStep ws : workStepList) {
    //             if (ws.Status == 'Nueva') {
    //                 ws.Mec_nico_asignado__c = newRecordMap.get(ws.Caso__c).Mecanico_Asignado__c;
    //                 ws.Flag_System_Update__c = true;
    //             } else {
    //                 caseIdBooleanMap.put(ws.Caso__c, true);
    //             }                
    //         }

    //         if (workStepList.size() > 0) {
    //             update workStepList;
    //         }

    //         // Apagar bandera update by the system
    //         for (WorkStep ws : workStepList) {
    //             ws.Flag_System_Update__c = false;
    //             update workStepList;
    //         }

    //         List<RM_Event__e> rmEventList = new List<RM_Event__e>();
    //         for (Id caseId : caseIdBooleanMap.keySet()) {
    //             rmEventList.add(new RM_Event__e(
    //                 Message__c = 'El caso tiene tareas en proceso que no fueron reasignadas.',
    //                 Record_Id__c = caseId,
    //                 Type__c = 'alert',
    //                 Alert_Type__c = 'warning',
    //                 Title__c = 'Asignación de mecánico'
    //             ));
    //         }

    //         if (rmEventList.size() > 0) {
    //             EventBus.publish(rmEventList);
    //         }            
    //     }
    // }

    // <<<pendiente de revisar>>>
    // public static void onAfterInsert(List<Case> newList)
    // {
    //     List<String> caseIds = new List<String>();
    //     for (Case caso : newList) {
    //         if (caso.Cita__c != null) {                
    //             caseIds.add(caso.Id);
    //         }
    //     }

    //     if (caseIds.size() > 0) {
    //         RM_WS_SMS_Service.sendSMSTallerCheckIN(caseIds);
    //     }
    // }

    // <<<pendiente de revisar>>>
    // @future
    // public static void updateCaseCheck(Set<String> caseIds)
    // {
    //     List<Case> newList = new List<Case>();
    //     for(String caseId : caseIds) {
    //         newList.add(new Case(Id = caseId, Create_Orders_from_Workorders__c = false));
    //     }
        
    //     if(newList.size() > 0)
    //         update newList;
    // }
}
