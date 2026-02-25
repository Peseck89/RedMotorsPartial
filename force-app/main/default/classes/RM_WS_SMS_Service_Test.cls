@IsTest
public class RM_WS_SMS_Service_Test {
    
    @TestSetup
    static void makeData(){
        // TestDataFactory.prepareConsoleRecords();
        RM_CT_TestDataFactory.createCaseWithWorkSteps();
    }

    @IsTest
    public static void testSMSMethod(){
        Test.setMock(HttpCalloutMock.class, new WSSMSMock());
        // RM_WS_SMS_Service.getSMSTemplates();

        // workStep workStep = [SELECT Id,Status FROM workStep LIMIT 1];
              
        // RM_WS_SMS_Service.sendSMSInProgress(new List<String>{workStep.Id});
        
        // Case caso = [SELECT Id FROM Case LIMIT 1];
        // RM_WS_SMS_Service.sendSMSTallerCheckIN(new List<String>{caso.Id});
        
        RM_WS_SMS_Service.SMSRequest smsRequest = new RM_WS_SMS_Service.SMSRequest('TALLER-EN PROCESO');        

        List<workStep> workStepList = [SELECT Id, Status,Caso__c,Flag_Lavado_Vehiculo__c,Caso__r.Flag_SMS_InProgress__c,Caso__r.AccountId,Caso__r.Account.Name,Caso__r.Account.FirstName,Caso__r.Account.LastName, Caso__r.Account.Phone,Caso__r.Contact.Name,Caso__r.Contact.FirstName,Caso__r.Contact.LastName, Caso__r.Account.RecordType.DeveloperName, Caso__r.Contact.Phone, Caso__r.N_de_placa__c, Caso__r.Owner.Name, CT_DetailStatus__c, WorkOrder.WorkOrderNumber, Caso__r.Owner.Phone, Caso__r.Service_Territory1__r.Name  FROM WorkStep  WHERE Caso__c != null LIMIT 1];

        Map<Id,Account> accMap = new Map<Id,Account>([SELECT Id,(SELECT Name,Phone FROM Contacts ORDER BY CreatedDate DESC LIMIT 1) FROM Account LIMIT 1]);

        RM_WS_SMS_Service.SMSRequest smsRequest2 = RM_WS_SMS_Service.prepareRequestParams(smsRequest,workStepList[0],accMap);

    }
    
    public class WSSMSMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');            
            if (req.getEndpoint().endsWith('token')) {
                RM_WS_Auth.AuthResponse authParams = new RM_WS_Auth.AuthResponse();
                authParams.access_token = '';
                authParams.token_type = '';
                res.setBody(System.JSON.serialize(authParams));
            }else{
                RM_WS_SMS_Service.SMSResponse smsResponse = new RM_WS_SMS_Service.SMSResponse();
                smsResponse.operationResult.code ='00';
                smsResponse.operationResult.description ='El mensaje ha sido enviado.';
                res.setBody(System.JSON.serialize(smsResponse));
            }

            res.setStatusCode(200);
            return res;
        }
    }

}