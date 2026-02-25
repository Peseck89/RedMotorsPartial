@isTest
public class BatchGetInventorySoftlandTest {
    @isTest
    public static void testBatchGetInventorySoftland() {
        condicionPago__c cp = new condicionPago__c(condicionPago__c = 'test');
        insert cp;
        
        BatchGetInventorySoftland bgv = new BatchGetInventorySoftland('', '');
        Test.startTest();
        try 
        {
            Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        }
        catch(System.CalloutException e) {
        }
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