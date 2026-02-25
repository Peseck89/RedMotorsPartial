@isTest
public class HttpCalloutAuthTest {
    @isTest
    public static void testHttpCalloutAuth() {
        condicionPago__c cp = new condicionPago__c(condicionPago__c = 'test');
        insert cp;
        
        HttpCalloutAuth bgv = new HttpCalloutAuth('', '');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        bgv.getAuth();
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