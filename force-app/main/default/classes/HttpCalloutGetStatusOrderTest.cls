@isTest
public class HttpCalloutGetStatusOrderTest {
    @isTest
    public static void testHttpCalloutGetStatusOrder() {
        condicionPago__c cp = new condicionPago__c(condicionPago__c = 'test');
        insert cp;
        
        HttpCalloutGetStatusOrder bgv = new HttpCalloutGetStatusOrder();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        bgv.getGetStatusOrderCallout('','','','');
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