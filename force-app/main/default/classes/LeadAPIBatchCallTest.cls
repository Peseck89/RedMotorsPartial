@isTest
private  class LeadAPIBatchCallTest {
    @isTest
    private static void fun(){
        
        Id recordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Campana_Red_Motors').getRecordTypeId();
        
        Campaign campanna = new Campaign(Name='Campaign',RecordTypeId = recordTypeId);
        insert campanna;        
        
        Lead ld = new Lead(
            LastName = 'TestNameXF',
            Company = 'Test',
            Phone = '1231231234',
            Marca__c = 'BMW',
            Campana__c = campanna.Id,
            FechaPosibleCompra__c = '1 a 3 meses'
        );      
        insert ld;        
        
        Test.setMock(HttpCalloutMock.class, new LeadAPIBatchCallMock());
        Test.startTest();
        DataUploadController.initiateLeadImport();
        Test.stopTest();
    }
    
    
}