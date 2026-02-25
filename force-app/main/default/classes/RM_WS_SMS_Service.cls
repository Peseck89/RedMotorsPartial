public class RM_WS_SMS_Service extends RM_WS_Auth {

    public static String WS_SMS_IN_PROGRESS = 'WS SMS In Progress';
    public static String WS_SMS_GET_TEMPLATES = 'WS SMS Get Templates';
    public static String WS_SMS_CHECK_IN = 'WS SMS Check In';

    /**
    * @description Obtiene una lista de plantillas usadas para el envio de sms
    * actualmente es de consulta, no se tiene implementacion mas que para conocer los parametros
    * @author marcohernandezhp@gmail.com | 03-10-2023 
    **/
    // public static void getSMSTemplates() {
    //     AuthResponse authResponse = getAuth();
    //     Http http = new Http();        
    //     HttpRequest request = new HttpRequest();
    //     request.setEndpoint( Label.URLSoftland + '/'+Label.AmbienteSoftland+'/softlandAPI/Catalogs/getSMSTemplates');
    //     request.setHeader('Authorization', 'Bearer '+authResponse.access_token);            
    //     request.setMethod('GET');   
    //     HttpResponse response = http.send(request);
    //     String jsonString = response.getBody();
    //     System.debug('@debug@'+jsonString);
    // }


    /**
    * @description Funcion que envia una solicitud al web service de envio de sms
    * @author marcohernandezhp@gmail.com | 03-10-2023 
    * @param messageId 
    * @param workStepId 
    **/
    @future(callout = true) 
    public static void sendSMSInProgress(List<String> wsIds) {
        // List<WorkStep> workStepList;
        // if(Test.isRunningTest()){
        //     workStepList = [SELECT Id, Status,Caso__c,Flag_Lavado_Vehiculo__c,Caso__r.Flag_SMS_InProgress__c,Caso__r.AccountId,Caso__r.Account.Name,Caso__r.Account.FirstName,Caso__r.Account.LastName, Caso__r.Account.Phone,Caso__r.Contact.Name,Caso__r.Contact.FirstName,Caso__r.Contact.LastName, Caso__r.Account.RecordType.DeveloperName, Caso__r.Contact.Phone, Caso__r.N_de_placa__c, Caso__r.Owner.Name, CT_DetailStatus__c, WorkOrder.WorkOrderNumber, Caso__r.Owner.Phone, Caso__r.Service_Territory1__r.Name  FROM WorkStep  WHERE Id IN :wsIds AND Caso__c != null];
        // }else{
        //     workStepList = [SELECT Id, Status,Flag_Lavado_Vehiculo__c, Caso__c,Caso__r.Flag_SMS_InProgress__c,Caso__r.AccountId,Caso__r.Account.Name,Caso__r.Account.FirstName,Caso__r.Account.LastName, Caso__r.Account.Phone,Caso__r.Contact.Name,Caso__r.Contact.FirstName,Caso__r.Contact.LastName, Caso__r.Account.RecordType.DeveloperName, Caso__r.Contact.Phone, Caso__r.N_de_placa__c, Caso__r.Owner.Name, CT_DetailStatus__c, WorkOrder.WorkOrderNumber, Caso__r.Owner.Phone, Caso__r.Service_Territory1__r.Name  FROM WorkStep  WHERE Id IN :wsIds AND Caso__r.esMecanicaRapida__c = true AND Caso__c != null AND WorkOrder.Etapa_de_flujo_de_trabajo__c != 'Orden Facturada' AND WorkOrder.Etapa_de_flujo_de_trabajo__c != 'Orden Rechazada'];
        // }
        
        // Map<String,Boolean> wsSMSMap = new Map<String,Boolean>();

        // Set<String> accIds = new Set<String>();
        // for (WorkStep workStep : workStepList) {
        //     if (workStep.Caso__r != null && workStep.Caso__r.Account != null) {                
        //         accIds.add(workStep.Caso__r.AccountId);
        //     }
        //     wsSMSMap.put(workStep.Id, workStep.Caso__r.Flag_SMS_InProgress__c);
        // }

        // Map<Id,Account> accMap = new Map<Id,Account>();
        // if (accIds.size()> 0) {  
        //     accMap = new Map<Id,Account>([SELECT Id,(SELECT Name,Phone FROM Contacts ORDER BY CreatedDate DESC LIMIT 1) FROM Account WHERE Id IN :accIds]);
        // }

        // AuthResponse authResponse = getAuth();
        // List<Log__c> logsToInsert = new List<Log__c>();
        // List<Case> casesToUpdate = new List<Case>();
        
        // for (WorkStep currWorkStep : workStepList) {
        //     Boolean flagSmsInProgressSent = wsSMSMap.containsKey(currWorkStep.Caso__c) ? wsSMSMap.get(currWorkStep.Caso__c) : false;
        //     if ((currWorkStep.Flag_Lavado_Vehiculo__c && currWorkStep.Status == 'Completada') || (!currWorkStep.Flag_Lavado_Vehiculo__c && currWorkStep.Status == 'En curso' && !flagSmsInProgressSent)) {
        //         String message = '';
        //         String messageId = (currWorkStep.Flag_Lavado_Vehiculo__c) ? 'FINALIZACIÓN DE SERVICIO' : 'TALLER-EN PROCESO';            
        //         SMSRequest smsRequest = new SMSRequest(messageId);
        //         prepareRequestParams(smsRequest,currWorkStep,accMap);
        //         Http http = new Http();
        //         HttpRequest request = new HttpRequest();
        //         String jsonReq = JSON.serialize(smsRequest);
        //         message = 'request: '+jsonReq;
        //         request.setEndpoint(Label.URLSoftland + '/'+Label.AmbienteSoftland+'/softlandAPI/Catalogs/sendSMS?json='+ EncodingUtil.urlEncode(jsonReq,'UTF-8'));
        //         request.setHeader('Authorization', 'Bearer '+authResponse.access_token);            
        //         request.setMethod('GET');

        //         HttpResponse response = http.send(request);
        //         String jsonString = response.getBody();
        //         if (String.isNotEmpty(jsonString)) {
        //             SMSResponse smsResponse = (SMSResponse) System.JSON.deserialize(jsonString, SMSResponse.class);
        //             if (smsResponse != null) {
        //                 if (smsResponse.operationResult != null && String.isNotEmpty(smsResponse.operationResult.code) && smsResponse.operationResult.code == '00') {
        //                     if (!currWorkStep.Flag_Lavado_Vehiculo__c && currWorkStep.Status == 'Completada'){
        //                         casesToUpdate.add(new Case(
        //                             Id = currWorkStep.Caso__c,
        //                             Flag_SMS_InProgress__c = true
        //                             ));                                 
        //                         wsSMSMap.put(currWorkStep.Caso__c, true);
        //                     }
        //                     message += ' \n Response: '+ JSON.serialize(smsResponse);
        //                 } else {
        //                     message += ' Error: La respuesta del sevicio web '+ WS_SMS_IN_PROGRESS +', no fue respondida en el formato correcto.\n'+ smsResponse;
        //                 }
        //             }else{
        //                 message += ' Error: La respuesta del sevicio web '+ WS_SMS_IN_PROGRESS +', no fue respondida en el formato correcto.\n'+ jsonString; 
        //             }
        //         }else{
        //             message += ' Error: El sevicio '+ WS_SMS_IN_PROGRESS +', no respondio con información.';
        //         }
        //         logsToInsert.add(RM_Log.write(currWorkStep.Caso__c,currWorkStep.Id,message,null,false)); 
        //     }
        // }

        // if (casesToUpdate.size()>0) {
        //     update casesToUpdate;
        // }

        // if (logsToInsert.size()>0) {
        //     insert logsToInsert;
        // }            
    }

    /**
    * @description Funcion que envia una solicitud al web service de envio de sms
    * @author marcohernandezhp@gmail.com | 03-10-2023 
    * @param messageId 
    * @param workStepId 
    **/
    @future(callout = true)
    public static void sendSMSTallerCheckIN(List<String> caseIds) {
        // List<Case> caseList = [SELECT Id,Flag_SMS_InProgress__c,AccountId,Account.Name,Account.FirstName,Account.LastName,Account.Phone,Contact.Name,Contact.FirstName,Contact.LastName,Account.RecordType.DeveloperName,Contact.Phone,N_de_placa__c,Owner.Name,Owner.Phone,StatusDetail__c,Service_Territory1__r.Name,(SELECT WorkOrderNumber FROM WorkOrders ORDER BY CreatedDate LIMIT 1) FROM Case WHERE Id IN :caseIds];        
        // // System.debug(caseList);

        // Set<String> accIds = new Set<String>();
        // for (Case caso : caseList) {
        //     if (caso.Account != null) {                
        //         accIds.add(caso.AccountId);
        //     }
        // }
        // // System.debug(accIds);
        // Map<Id,Account> accMap = new Map<Id,Account>();
        // if (accIds.size()> 0) {            
        //     accMap = new Map<Id,Account>([SELECT Id,(SELECT Name,Phone FROM Contacts ORDER BY CreatedDate DESC LIMIT 1) FROM Account WHERE Id IN :accIds]);
        // }

        // AuthResponse authResponse = getAuth();
        // List<Log__c> logsToInsert = new List<Log__c>();
        // List<Case> casesToUpdate = new List<Case>();        
        // for (Case caso : caseList) {
        //     String message = '';
        //     SMSRequest smsRequest = new SMSRequest('TALLER-CHECK IN');
        //     smsRequest.telefono = (caso.Contact != null && String.isNotBlank(caso.Contact.Phone)) ? caso.Contact.Phone : null;
        //     String workOrderNumber = '';
        //     if (smsRequest.telefono == null && caso.Account != null) { 
        //         Account acc = accMap.get(caso.AccountId);
        //         if (acc != null) {
        //             if (acc.Contacts.size()>0 && String.isNotBlank(acc.Contacts[0].Phone)) {
        //                 smsRequest.telefono = acc.Contacts[0].Phone;
        //             }else{
        //                 smsRequest.telefono = caso.Account.Phone;
        //             }
        //         }
        //     }

        //     for (WorkOrder workOrder : caso.WorkOrders) {
        //         workOrderNumber = workOrder.WorkOrderNumber;
        //     }
        
        //     smsRequest.addParam('Caso__r.Account.Name',(caso.Account != null && String.isNotBlank(caso.Account.Name)) ? caso.Account.Name : '');
        //     smsRequest.addParam('Caso__r.Account.FirstName',(caso.Account != null && String.isNotBlank(caso.Account.FirstName)) ? caso.Account.FirstName : '');
        //     smsRequest.addParam('Caso__r.Account.LastName',(caso.Account != null && String.isNotBlank(caso.Account.LastName)) ? caso.Account.LastName : '');
        //     smsRequest.addParam('Caso__r.Account.RecordType.DeveloperName',(caso.Account != null && String.isNotBlank(caso.Account.RecordType.DeveloperName)) ? caso.Account.RecordType.DeveloperName : '');
        //     smsRequest.addParam('Caso__r.Account.Phone',(caso.Account != null && String.isNotBlank(caso.Account.Phone)) ? caso.Account.Phone : '');
        //     smsRequest.addParam('Caso__r.Contact.Name',(caso.Contact != null && String.isNotBlank(caso.Contact.Name)) ? caso.Contact.Name : '');
        //     smsRequest.addParam('Caso__r.Contact.FirstName',(caso.Contact != null && String.isNotBlank(caso.Contact.FirstName)) ? caso.Contact.FirstName : '');
        //     smsRequest.addParam('Caso__r.Contact.LastName',(caso.Contact != null && String.isNotBlank(caso.Contact.LastName)) ? caso.Contact.LastName : '');
        //     smsRequest.addParam('Caso__r.Contact.Phone',(caso.Contact != null && String.isNotBlank(caso.Contact.Phone)) ? caso.Contact.Phone : '');
        //     smsRequest.addParam('Caso__r.N_de_placa__c',(String.isNotBlank(caso.N_de_placa__c)) ? caso.N_de_placa__c : '');
        //     smsRequest.addParam('Caso__r.Owner.Name',(caso.Owner != null && String.isNotBlank(caso.Owner.Name)) ? caso.Owner.Name : '');
        //     smsRequest.addParam('CT_DetailStatus__c','En curso');
        //     smsRequest.addParam('WorkOrder.WorkOrderNumber',workOrderNumber);
        //     smsRequest.addParam('Caso__r.Owner.Phone',(caso.Owner != null && String.isNotBlank(caso.Owner.Phone)) ? caso.Owner.Phone : '');
        //     smsRequest.addParam('Caso__r.Service_Territory1__r.Name',(caso.Service_Territory1__r != null && String.isNotBlank(caso.Service_Territory1__r.Name)) ? caso.Service_Territory1__r.Name : '');

        //     Http http = new Http();
        //     HttpRequest request = new HttpRequest();
        //     String jsonReq = JSON.serialize(smsRequest);
        //     message = 'Request:'+jsonReq;
        //     request.setEndpoint(Label.URLSoftland + '/'+Label.AmbienteSoftland+'/softlandAPI/Catalogs/sendSMS?json='+ EncodingUtil.urlEncode(jsonReq,'UTF-8'));
        //     request.setHeader('Authorization', 'Bearer '+authResponse.access_token);            
        //     request.setMethod('GET');

        //     HttpResponse response = http.send(request);
        //     String jsonString = response.getBody();

        //     if (String.isNotEmpty(jsonString)) {
        //         SMSResponse smsResponse = (SMSResponse) System.JSON.deserialize(jsonString, SMSResponse.class);
        //         if (smsResponse != null) {
        //             if (smsResponse.operationResult != null && String.isNotEmpty(smsResponse.operationResult.code) && smsResponse.operationResult.code.equalsIgnoreCase('00')) {
        //                 message += ' \nResponse: '+ JSON.serialize(smsResponse);
        //             }else {
        //                 message += ' \nError:La respuesta del sevicio web '+ WS_SMS_CHECK_IN +', no fue respondida en el formato correcto.\n'+ smsResponse;
        //             }
        //         }else{
        //             message += ' \nError:La respuesta del sevicio web '+ WS_SMS_CHECK_IN +', no fue respondida en el formato correcto.\n'+ jsonString;
        //         }             
        //     }else{
        //         message += ' \nError:El sevicio '+ WS_SMS_CHECK_IN +', no respondio con información.';
        //     }
            
        //     logsToInsert.add(RM_Log.write(caso.Id,null,message,null,false)); 
        // }

        // if (casesToUpdate.size()>0) {
        //     update casesToUpdate;
        // }

        // if (logsToInsert.size()>0) {
        //     insert logsToInsert;
        // }            
    }

    /**
    * @description Funcion que prepara los parametros para el consumo del ws
    * @author marcohernandezhp@gmail.com | 03-10-2023 
    * @param smsRequest Objeto que representa el formato esperado por el ws, importante el nombre de las variables
    * @param ws WorkStep sobre el que se esta trabajando
    * @return SMSRequest objeto request con la informacion seteada
    **/
    public static SMSRequest prepareRequestParams(SMSRequest smsRequest,WorkStep ws,Map<Id,Account> accMap) {
        //Inicialmente se evalua si el contacto ligado al caso tiene un numero de telefono
        smsRequest.telefono = (ws.Caso__r != null && ws.Caso__r.Contact != null && String.isNotBlank(ws.Caso__r.Contact.Phone)) ? ws.Caso__r.Contact.Phone : null;
        System.debug('smsRequest.telefono:'+smsRequest.telefono);
        if (smsRequest.telefono == null && ws.Caso__r != null && ws.Caso__r.Account != null) { 
            Account acc = accMap.get(ws.Caso__r.AccountId);
            if (acc != null) {
                if (acc.Contacts.size()>0 && String.isNotBlank(acc.Contacts[0].Phone)) {
                    smsRequest.telefono = acc.Contacts[0].Phone;
                }else{
                    smsRequest.telefono = ws.Caso__r.Account.Phone;
                }
            }
        }

        smsRequest.addParam('Caso__r.Account.Name',(ws.Caso__r != null && ws.Caso__r.Account != null && String.isNotBlank(ws.Caso__r.Account.Name)) ? ws.Caso__r.Account.Name : '');
        smsRequest.addParam('Caso__r.Account.FirstName',(ws.Caso__r != null && ws.Caso__r.Account != null && String.isNotBlank(ws.Caso__r.Account.FirstName)) ? ws.Caso__r.Account.FirstName : '');
        smsRequest.addParam('Caso__r.Account.LastName',(ws.Caso__r != null && ws.Caso__r.Account != null && String.isNotBlank(ws.Caso__r.Account.LastName)) ? ws.Caso__r.Account.LastName : '');
        smsRequest.addParam('Caso__r.Account.RecordType.DeveloperName',(ws.Caso__r != null && ws.Caso__r.Account != null && String.isNotBlank(ws.Caso__r.Account.RecordType.DeveloperName)) ? ws.Caso__r.Account.RecordType.DeveloperName : '');
        smsRequest.addParam('Caso__r.Account.Phone',(ws.Caso__r != null && ws.Caso__r.Account != null && String.isNotBlank(ws.Caso__r.Account.Phone)) ? ws.Caso__r.Account.Phone : '');
        smsRequest.addParam('Caso__r.Contact.Name',(ws.Caso__r != null && ws.Caso__r.Contact != null && String.isNotBlank(ws.Caso__r.Contact.Name)) ? ws.Caso__r.Contact.Name : '');
        smsRequest.addParam('Caso__r.Contact.FirstName',(ws.Caso__r != null && ws.Caso__r.Contact != null && String.isNotBlank(ws.Caso__r.Contact.FirstName)) ? ws.Caso__r.Contact.FirstName : '');
        smsRequest.addParam('Caso__r.Contact.LastName',(ws.Caso__r != null && ws.Caso__r.Contact != null && String.isNotBlank(ws.Caso__r.Contact.LastName)) ? ws.Caso__r.Contact.LastName : '');
        smsRequest.addParam('Caso__r.Contact.Phone',(ws.Caso__r != null && ws.Caso__r.Contact != null && String.isNotBlank(ws.Caso__r.Contact.Phone)) ? ws.Caso__r.Contact.Phone : '');
        smsRequest.addParam('Caso__r.N_de_placa__c',(ws.Caso__r != null && String.isNotBlank(ws.Caso__r.N_de_placa__c)) ? ws.Caso__r.N_de_placa__c : '');
        smsRequest.addParam('Caso__r.Owner.Name',(ws.Caso__r != null && ws.Caso__r.Owner != null && String.isNotBlank(ws.Caso__r.Owner.Name)) ? ws.Caso__r.Owner.Name : '');
        smsRequest.addParam('CT_DetailStatus__c',(String.isNotBlank(ws.CT_DetailStatus__c)) ? ws.CT_DetailStatus__c :'');
        smsRequest.addParam('WorkOrder.WorkOrderNumber',(ws.WorkOrder != null && String.isNotBlank(ws.WorkOrder.WorkOrderNumber)) ? ws.WorkOrder.WorkOrderNumber : '');
        smsRequest.addParam('Caso__r.Owner.Phone',(ws.Caso__r != null && ws.Caso__r.Owner != null && String.isNotBlank(ws.Caso__r.Owner.Phone)) ? ws.Caso__r.Owner.Phone : '');
        smsRequest.addParam('Caso__r.Service_Territory1__r.Name',(ws.Caso__r != null && ws.Caso__r.Service_Territory1__r != null && String.isNotBlank(ws.Caso__r.Service_Territory1__r.Name)) ? ws.Caso__r.Service_Territory1__r.Name : '');
        return smsRequest;
    }

    public class ValueWrapper {
        public String id;
        public String valor;

        public ValueWrapper(String id,String valor){
            this.id = id;
            this.valor = valor;
        }
    }

    public class SMSRequest{
        public String id_mensaje;
        public String telefono;
        public List<ValueWrapper> parametros;

        public SMSRequest(String id_mensaje){
            this.id_mensaje = id_mensaje;            
            this.parametros = new List<ValueWrapper>();
        }
                
        // public SMSRequest(String id_mensaje,String telefono){
        //     this.id_mensaje = id_mensaje;
        //     this.telefono = telefono;
        //     this.parametros = new List<ValueWrapper>();
        // }        
        
        public void addParam(String key,String value){
            this.parametros.add(new ValueWrapper(key,value));
        }     
    }

    public class SMSResponse {
        public OperationResult operationResult = new OperationResult();
    }   
    
    public class OperationResult{
        public String code;
        public String description;
    }

}