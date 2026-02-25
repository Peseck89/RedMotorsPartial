@istest
public class BatchLeadActivityUploaderTest {
    @istest
    public static void testmethod1 (){
        Id idBMW = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('BMW').getRecordTypeId();
        Id idMini = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('MINI').getRecordTypeId();
        Id idMotorrad = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Motorrad').getRecordTypeId();
        Id recordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Campana_Red_Motors').getRecordTypeId();
        
        Campaign campanna = new Campaign(Name='Campaign',RecordTypeId = recordTypeId);
        insert campanna;
        
        
        Lead ld = new Lead(
            LastName = 'TestNameXF',
            Company = 'Test',
            Phone = '1231231234',
            Campana__c = campanna.Id,
            FechaPosibleCompra__c = '1 a 3 meses'
        );      
        insert ld;
        
        System.debug('Lead Full '+ld);
        List<Lead> ldList = [Select Id,Name,RecordType.Name From Lead where Name = 'TestNameXF'];
        system.debug('OPP2 : '+ldList);
        
        Task t = new Task();
        t.WhoId = ld.id;
        t.TaskSubtype = 'Task';
        t.Subject = 'Seguimiento';
        insert t;
        
        Event et = new Event();
        et.WhoId = ld.Id;
        et.Subject = 'Call';
        et.DurationInMinutes = 1;
        et.ActivityDateTime = Datetime.now();
        et.tipoCargoAseguradora__c = true;
        insert et;
        
        Datetime dtTime=System.now();
        date dt= date.newinstance(dtTime.year(), dtTime.month(), dtTime.day());
        date last6Month = dt.addMonths(-6);
        //Test.setCreatedDate(op.Id, last6Month); 
        
        Test.startTest();
        BatchLeadActivityUploader obj = new BatchLeadActivityUploader(system.today());
        DataBase.executeBatch(obj);
        
        Test.stopTest();
    }
}