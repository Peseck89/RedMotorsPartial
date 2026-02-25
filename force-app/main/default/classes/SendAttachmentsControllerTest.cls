@isTest
public class SendAttachmentsControllerTest {
    
    @testSetup
    private static void TestDataSeup(){
        TestDataFactory.datosGenerales();
        Oportunidad_de_Financiamiento__c opF1 = new Oportunidad_de_Financiamiento__c();
        
        TestDataFactory.crearCuentasAltica(1);
        TestDataFactory.crearOpFAltica(1);
        opF1 = TestDataFactory.MapOpF.get(0);
        opF1.Estado__c = 'Aprobada';
        opF1.Email__c = 'test@test.com';
        opF1.EmailVendedorOP__c = 'test@test.com';
        
        update opF1;
        
        Attachment attach=new Attachment();   	
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=opF1.id;
        insert attach;    
        
        Task t = new Task();
        t.WhatId = opF1.id;
        t.TaskSubtype = 'Task';
         t.WhatId =  opF1.id;
        insert t;
        
        createEmailTemplate();
    }
    
    @future
    private static void createEmailTemplate()
    {
        EmailTemplate validEmailTemplate = new EmailTemplate();
        validEmailTemplate.isActive = true;
        validEmailTemplate.Name = 'Test';
        validEmailTemplate.DeveloperName = 'Test';
        validEmailTemplate.TemplateType = 'text';
        validEmailTemplate.FolderId = UserInfo.getUserId();
        
        insert validEmailTemplate;
    }
    
    @isTest
    private static void TestSendEmailFunction(){
        Oportunidad_de_Financiamiento__c oportunidad = [SELECT Id, Name FROM Oportunidad_de_Financiamiento__c];
        List<Id> attachmentIds = new List<Id>();
        
        Test.startTest();
        Oportunidad_de_Financiamiento__c opp = SendAttachmentsController.getOpportunity(oportunidad.Id);
        List<String> userNames = SendAttachmentsController.getUserList();
        List<Attachment> attachmentsResult = SendAttachmentsController.getAttachments(opp.id);
        for(Attachment att : attachmentsResult){
            attachmentIds.add(att.Id);    
        }
        List<String> result = SendAttachmentsController.sendEmail(opp.Id, userNames, attachmentIds, new List<String> {'test@test.com'});
        Test.stopTest(); 
        
        Task task = [SELECT ID, WhatId, TaskSubtype FROM Task WHERE WhatId = :opp.Id LIMIT 1];
        
        System.assertEquals(oportunidad.Id, opp.Id);
        System.assertEquals(true, (userNames.size() > 0));
        System.assertEquals(1, attachmentsResult.size());
       // System.assertEquals('Email', task.TaskSubtype);
    }
}