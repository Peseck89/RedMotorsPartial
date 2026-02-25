@istest
public class OppActivityUploaderTest {
    @istest
    public static void runtest(){
        
        contact con = new contact();
        con.FirstName='test';
        con.LastName='test';
        insert con;
        
        Id recordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Campana_Red_Motors').getRecordTypeId();
        
        Campaign campanna = new Campaign(Name='Campaign',RecordTypeId = recordTypeId);
        insert campanna;
        
        
        Opportunity op = new Opportunity(
            Name = 'TestName',
            CloseDate = System.today().AddMonths(3),
            StageName = 'Oportunidad Calificada',
            Campana__c = campanna.Id,
            RT_Lead__c = 'Polaris'
        );      
        insert op;
        
        Test.startTest();
        String cronexpression = '0 0 0 15 3 ? *';
        String jobId = System.schedule('ScheduleBatchApexClass',  cronexpression, new OppActivityUploader());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(cronexpression, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        
        OppActivityUploader.init2();
        
        Test.stopTest();
       
    }
    
}