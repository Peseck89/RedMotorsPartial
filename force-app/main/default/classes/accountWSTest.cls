@isTest
public class accountWSTest {
    @isTest
    public static void testAccountWS() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/account'; //Request URL
        req.httpMethod = 'POST';
        req.requestBody=blob.valueOf('{"foo":"bar"}');
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        accountWS.createAccount();
        Test.stopTest();
    }
    
    @isTest
    public static void accountWSTestNegative(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/account'; //Request URL
        req.httpMethod = 'POST';
        req.requestBody=blob.valueOf('abc');
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        accountWS.createAccount();
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