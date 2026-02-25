@isTest
public class HttpCalloutTest {
    @isTest
    public static void testHttpCallout() {
        condicionPago__c cp = new condicionPago__c(condicionPago__c = 'test');
        insert cp;
        
        HttpCallout bgv = new HttpCallout();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        bgv.callRequest('','','','');
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