public with sharing class JSONHistory {
	
    @AuraEnabled
      public static void logJSONErrors(String actualOrderId, String cardCode, String responseBody, String request_id){
          System.debug('actualOrderId: '+actualOrderId);
          System.debug('cardCode: '+cardCode);
          orderSoftlandWrapper bodyRequest = orderJSONData.getJSONFromOrder(actualOrderId,cardCode,request_id);
          String body = JSON.serialize(bodyRequest);
          Object o = JSON.deserializeUntyped(body);
          
          if(responseBody.Contains('errorCode')){
              JSON_History__c JSONHistory = new JSON_History__c();
              
              List<WorkOrder> woID = [SELECT Id FROM WorkOrder where WorkOrderNumber =: bodyRequest.num_Presupuesto limit 1];
              System.debug('Work Order Id: '+woID[0].Id);
              JSONHistory.Work_Order__c = woID[0].Id;
              JSONHistory.JSON__c = Json.serializePretty(o);
              
              if(responseBody.Length() > 255){
                    responseBody = responseBody.left(254);
              }
              JSONHistory.Error_Message__c = responseBody;
              
              System.debug('Testing Get Body:'+ responseBody);
              insert JSONHistory;
              
              Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
              String[] sendingTo = new String[]{'oaparicio@redmotorscr.com','smora@redmotorscr.com'}; 
              semail.setToAddresses(sendingTo); 
              //String[] sendingToBccAdd = new String[]{'a@gmail.com'}; 
              //semail.setBccAddresses(sendingToBccAdd); 
              //ring[] sendingTocAdd = new String[]{'a@gmail.com'}; 
              //mail.setCcAddresses(sendingTocAdd); 
              semail.setSubject('Error in the JSON object response from Softland');
              semail.setPlainTextBody('This is the error detail in the work order number: '+bodyRequest.num_Presupuesto+ '. Error:' + JSONHistory.Error_Message__c);
              Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail}); 
              
          }

      }
    
}