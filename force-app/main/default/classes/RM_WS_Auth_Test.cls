/**
 * @description       : Test class for ws sms
 * @author            : marcohernandezhp@gmail.com
 * @group             : Redmotors
 * @last modified on  : 03-18-2023
 * @last modified by  : marcohernandezhp@gmail.com
**/
@isTest
public class RM_WS_Auth_Test {
    
    @IsTest
    static void testAuth(){
        Test.setMock(HttpCalloutMock.class, new WSAuthMock());        
        RM_WS_Auth.getAuth() ;
    }

    public class WSAuthMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            RM_WS_Auth.AuthResponse authParams = new RM_WS_Auth.AuthResponse();
            authParams.access_token = '';
            authParams.token_type = '';

            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(System.JSON.serialize(authParams));
            res.setStatusCode(200);
            return res;
        }
    }
}