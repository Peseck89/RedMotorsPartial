@isTest
public class BatchLeadActivityUploaderTest {
    
    @isTest
    static void testBatchLeadActivityUploaderExecution() {
        Id idBMW = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('BMW').getRecordTypeId();
        Id campRT = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Campana_Red_Motors').getRecordTypeId();
        
        Campaign camp = new Campaign(
            Name = 'Campaign Test',
            RecordTypeId = campRT
        );
        insert camp;
        
        Lead ld = new Lead(
            LastName = 'Lead Test',
            Company = 'Company Test',
            Phone = '1234567890',
            RecordTypeId = idBMW,
            Campana__c = camp.Id
        );
        insert ld;
        
        String validTaskSubject = Task.Subject.getDescribe().getPicklistValues()[0].getValue();
        String validEventSubject = Event.Subject.getDescribe().getPicklistValues()[0].getValue();
        
        Task tk = new Task(
            WhoId = ld.Id,
            Subject = validTaskSubject,
            TaskSubtype = 'Task'
        );
        insert tk;
        
        Event ev = new Event(
            WhoId = ld.Id,
            Subject = validEventSubject,
            StartDateTime = Datetime.now().addDays(1),
            EndDateTime = Datetime.now().addDays(1).addMinutes(30),
            tipoCargoAseguradora__c = true
        );
        insert ev;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        BatchLeadActivityUploader batch = new BatchLeadActivityUploader(Datetime.now().addDays(-1));
        Database.executeBatch(batch, 10);
        Test.stopTest();
        
        List<AsyncApexJob> batchJobs = [
            SELECT Id, Status, NumberOfErrors 
            FROM AsyncApexJob 
            WHERE ApexClass.Name = 'BatchLeadActivityUploader'
            AND JobType = 'BatchApex'
        ];
        
        System.assert(!batchJobs.isEmpty());
        for(AsyncApexJob job : batchJobs) {
            System.assertEquals('Completed', job.Status);
            System.assertEquals(0, job.NumberOfErrors);
        }
    }
    
    public class MockHttpResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success"}');
            res.setStatusCode(200);
            return res;
        }
    }
}