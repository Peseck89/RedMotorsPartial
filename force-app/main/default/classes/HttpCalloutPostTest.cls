@isTest
public class HttpCalloutPostTest {
	 @isTest
    public static void testHttpCallout() {
        HttpCalloutPost bgv = new HttpCalloutPost();
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