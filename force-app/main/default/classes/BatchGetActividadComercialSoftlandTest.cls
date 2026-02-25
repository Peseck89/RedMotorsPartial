@isTest
public class BatchGetActividadComercialSoftlandTest {
    @isTest
    public static void testBatchGetActividadComercialSoftland() {
        condicionPago__c cp = new condicionPago__c(condicionPago__c = 'test');
        insert cp;
        
        BatchGetActividadComercialSoftland bgv = new BatchGetActividadComercialSoftland('company');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        System.enqueueJob(bgv);
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