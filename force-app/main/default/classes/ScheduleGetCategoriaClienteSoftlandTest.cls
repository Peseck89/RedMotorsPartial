@isTest
public class ScheduleGetCategoriaClienteSoftlandTest {
    @isTest
    public static void testScheduleGetCategoriaClienteSoftland() {
        condicionPago__c cp = new condicionPago__c(condicionPago__c = 'test');
        insert cp;
        
        ScheduleGetCategoriaClienteSoftland bgv = new ScheduleGetCategoriaClienteSoftland();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        String sch = '0 0 23 * * ?';
        String jobId = system.schedule('Test check', sch, bgv);
        Test.stopTest();

        CronTrigger ct = [SELECT Id, CronExpression FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals(sch, ct.CronExpression);

        List<AsyncApexJob> queueableJobs = [
            SELECT Id
            FROM AsyncApexJob
            WHERE ApexClass.Name = 'BatchGetCategoriaClienteSoftland'
            AND JobType = 'Queueable'
        ];
        System.assertEquals(2, queueableJobs.size(), 'El scheduler debe encolar dos Queueables independientes de BatchGetCategoriaClienteSoftland: uno para RMBAVARIAN y uno para RMPEKING');
    }

    public class ExampleCalloutMock implements HttpCalloutMock{
        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(200);
            res.setBody('{"access_token":"","token_type":""}');
            return res;
        }
    }
}