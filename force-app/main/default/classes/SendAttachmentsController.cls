public with sharing class SendAttachmentsController {
    @AuraEnabled
    public static Oportunidad_de_Financiamiento__c getOpportunity(Id oppId) {
        Oportunidad_de_Financiamiento__c opp;    
        try {
            opp = [SELECT Id, Name, Email__c, EmailVendedorOP__c FROM Oportunidad_de_Financiamiento__c WHERE Id = :oppId];       	
        } catch(Exception ex){
            opp = new Oportunidad_de_Financiamiento__c();
        }
        return opp;
    }
    
    @AuraEnabled
    public static List<String> getUserList() {
        List<Oportunidad_de_financimiento__mdt> recipientsMetadata = [SELECT Id,Enviar_a__c,Email__c, plantilla_de_correo__c  
                                                                      FROM Oportunidad_de_financimiento__mdt];
        
        List<String> users = new List<String>();
        for(Oportunidad_de_financimiento__mdt user:recipientsMetadata){
            users.add(user.Enviar_a__c);    
        }
        return users;
    }
    
    @AuraEnabled
    public static List <Attachment> getAttachments(Id oppId) {
        List<Attachment> attachments = [SELECT Id, Name, CreatedDate, ParentId, Parent.Type FROM Attachment 
                                        where Parent.Type = 'Oportunidad_de_Financiamiento__c' 
                                        AND ParentId = :oppId
                                       ORDER BY CreatedDate DESC];
        
        return attachments;
    }
    
    @AuraEnabled
    public static List<String> sendEmail(Id oppId, List<String> userNames, List<Id> attachmentIds, List<String> ccEmailIdList){
        Set<String> templateNames = new Set<String>();
        Map<String, Id> emailTemplateMap = new Map<String, Id> ();
        List<Messaging.SingleEmailMessage> singleEmails = new List<Messaging.SingleEmailMessage>();
        List<Messaging.EmailFileAttachment> mailAttList = new List<Messaging.EmailFileAttachment>();
        
        List<Attachment> attList = [SELECT Id, Name, Body FROM Attachment where Id IN :attachmentIds];
        
        List<Oportunidad_de_financimiento__mdt> recipientsMetadata = [SELECT Id,Enviar_a__c,Email__c, plantilla_de_correo__c 
                                                                      FROM Oportunidad_de_financimiento__mdt 
                                                                      WHERE Enviar_a__c IN :userNames];
        
        Oportunidad_de_Financiamiento__c opp = SendAttachmentsController.getOpportunity(oppId);
        
        For(Oportunidad_de_financimiento__mdt recipient :recipientsMetadata){
            templateNames.add(recipient.plantilla_de_correo__c);   
        }
        
        List<EmailTemplate> templates = [SELECT Id, Subject, HtmlValue, DeveloperName
                                         FROM EmailTemplate 
                                         WHERE DeveloperName IN :templateNames];
        
        for(EmailTemplate emailTemplate : templates){
            emailTemplateMap.put(emailTemplate.DeveloperName, emailTemplate.Id);    
        }
        For(Oportunidad_de_financimiento__mdt recipient :recipientsMetadata){
            if(emailTemplateMap.containsKey(recipient.plantilla_de_correo__c)){
                Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(emailTemplateMap.get(recipient.plantilla_de_correo__c), Null, oppId);    
                String toAddress = recipient.Email__c;
                if(recipient.Enviar_a__c.equalsIgnoreCase('Cliente') && opp.email__c != null){
                    toAddress = String.valueOf(opp.get(recipient.Email__c));
                }
                else if(recipient.Enviar_a__c.equalsIgnoreCase('Vendedor') && opp.EmailVendedorOP__c != null){
                    toAddress = String.valueOf(opp.get(recipient.Email__c));   
                }
                email.setToAddresses(new List<String> {toAddress});
                if(ccEmailIdList != null && ccEmailIdList.size()>0){
                    email.setCcAddresses(ccEmailIdList);
                }
                email.setSubject(email.getSubject());
                email.sethtmlBody(email.gethtmlBody());
                for(Attachment att1 : attList){
                    Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                    efa.setBody(att1.body);
                    efa.setFileName(att1.name);
                    mailAttList.add(efa);
                }
                 email.setFileAttachments(mailAttList);
                email.saveAsActivity = true;
                singleEmails.add(email);
            }
        }
        
        Messaging.sendEmail(singleEmails);
        
        return new List<String>();
    }
}