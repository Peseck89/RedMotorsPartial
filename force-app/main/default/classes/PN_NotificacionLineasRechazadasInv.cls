/********************************************************************
Apex Class Name	:	PN_NotificacionLineasRechazadasInv
Version			:	1.0
Created Date	:	 12/09/2025
Function 		:    Clase que se invoca desde flow PN_NotificacionLineasRechazadas
Test Class		:	

Modification Log
*--------------------------------------------------------------------
* Developer		     		Date			   	Description
* -------------------------------------------------------------------
* Kevin Garcia  		 	28/07/2025			Original Version-
*********************************************************************/
public with sharing class PN_NotificacionLineasRechazadasInv {
    
    @InvocableMethod(label='Notificacion Lineas Rechazadas' iconName='slds:standard:account')
	public static void sendNotif(List<InputVars> lsInputVars ) {

        for(InputVars inputVar : lsInputVars){
            
            makeCallout(inputVar.idQuote);

        }
        
    }

    @future(callout=true)
    public static void makeCallout(Id quoteId){

        Quote coti = [SELECT Id, Account.Invoice_Phone__c, Account.PersonMobilePhone, Account.Phone FROM Quote WHERE Id =: quoteId];

            String celular;

            if(coti.Account.Invoice_Phone__c != null) celular = coti.Account.Invoice_Phone__c;
            if(coti.Account.Phone != null) celular = coti.Account.Phone;
            if(coti.Account.PersonMobilePhone != null) celular = coti.Account.PersonMobilePhone;

            System.debug('--PN_NotificacionLineasRechazadasInv.sendNotif-- celular: ' + celular);

            if(celular != null){

                String fullRecordURL = URL.getOrgDomainURL().toExternalForm() + '/lightning/r/Quote/' + coti.Id +  
                                        '/related/Archivo_lineas_rechazadas__r/view?ws=%2Flightning%2Fr%2FQuote%2F' +
                                        coti.Id + '%2Fview';


                System.debug('--PN_NotificacionLineasRechazadasInv.sendNotif-- fullRecordURL: ' + fullRecordURL);

                PN_APIWhatsAppSettings__mdt apiWhats = PN_APIWhatsAppSettings__mdt.getInstance('Default');

                String body = '{' +
                                '"id" : "' + celular + '",' +
                                '"channel" : "' + apiWhats.PN_Channel__c + '",' +
                                '"webhook_password" : "' + apiWhats.PN_WebhookPass__c + '",' +
                                '"variables" : {' +
                                    '"1" : "' + fullRecordURL + '"' +
                                '}' +
                            '}';


                
                Http http = new Http();
                HttpResponse response;
                HttpRequest request = new HttpRequest();
                request.setEndpoint(apiWhats.PN_Endpoint__c);
                request.setMethod('POST');
                request.setHeader('Content-Type', 'application/json');
                request.setBody(body);

                try {
                    response = http.send(request);
                    System.debug('--PN_NotificacionLineasRechazadasInv.sendNotif-- response: ' + response.getBody());
                } catch (System.CalloutException e) {
                    System.debug('--PN_NotificacionLineasRechazadasInv.sendNotif-- CalloutException e: ' + e.getMessage());
                }
            }
    }

    

    public class InputVars{
        @InvocableVariable
        public Id idQuote;
    }

    
}