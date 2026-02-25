@isTest
public class ScheduleGetAseguradoraSoftlandTest {
    @isTest
    public static void testScheduleGetAseguradoraSoftlandland() {
        condicionPago__c cp = new condicionPago__c(condicionPago__c = 'test');
        insert cp;
        
        ScheduleGetAseguradoraSoftland bgv = new ScheduleGetAseguradoraSoftland();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, bgv);
        Test.stopTest();
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