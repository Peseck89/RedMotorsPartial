@istest
public class WebServiceAutomationBatchTest {
@istest
    public Static void runtest(){
        
       	Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Cedula__c = '211234661';
        insert acc;
        
        Oportunidad_de_Financiamiento__c opp = new Oportunidad_de_Financiamiento__c();
        opp.Name = 'Test opp';
        opp.Nombre_Cliente_Altica__c = acc.Id;
        insert opp;
        
        String text = '"teref,df",",terefdf","terefdf,"\nterefdf","terefdf","terefdf",treteer\n';
        ContentVersion conVer = new ContentVersion();
        conVer.PathOnClient = 'fileName';
        conVer.Title = 'fileName';
        conVer.VersionData = Blob.valueOf(text);
        insert conVer;

        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;

        WebServiceAutomationBatch.processOpportunity(opp.Id);
        Test.startTest();
        WebServiceAutomationBatch.runBatch(conDoc);
        Test.stopTest();
    }
    @istest
    public Static void runtest1(){
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Cuenta_Altica').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Fname';
        acc.LastName = 'Lname';
        acc.Cedula__c = '211234661';
        acc.RecordTypeId = recordTypeId;
        insert acc;
        
       	Oportunidad_de_Financiamiento__c opp = new Oportunidad_de_Financiamiento__c();
        opp.Name = 'Test opp';
        opp.Nombre_Cliente_Altica__c = acc.Id;
        insert opp;
		
        WebServiceAutomationBatch.processOpportunity(opp.Id);
    }

}