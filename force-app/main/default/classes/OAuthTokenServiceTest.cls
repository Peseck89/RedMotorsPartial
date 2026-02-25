@IsTest
public class OAuthTokenServiceTest {

    @IsTest
    static void testGetAccessToken_Success() {
        // Mock HTTP response for a successful token retrieval
        Test.setMock(HttpCalloutMock.class, new OAuthTokenMockResponseGenerator(200, '{"access_token": "mockAccessToken"}'));

        // Call the method
        Test.startTest();
        String accessToken = OAuthTokenService.getAccessToken();
        Test.stopTest();

        // Verify that the access token returned is as expected
        System.assertEquals('mockAccessToken', accessToken, 'The access token should match the mock value');
    }

    @IsTest
    static void testGetAccessToken_Error() {
        // Mock HTTP response for an error (e.g., invalid credentials)
        Test.setMock(HttpCalloutMock.class, new OAuthTokenMockResponseGenerator(400, '{"error": "invalid_grant", "error_description": "authentication failure"}'));

        // Call the method and expect an exception
        Test.startTest();
        try {
            OAuthTokenService.getAccessToken();
            System.assert(false, 'Expected AuraHandledException was not thrown');
        } catch (AuraHandledException e) {
            //System.assert(e.getMessage().contains('Error: 400'), 'Expected error message to contain status code 400');
        }
        Test.stopTest();
    }

    // Mock class for simulating HTTP callouts
    private class OAuthTokenMockResponseGenerator implements HttpCalloutMock {
        private Integer statusCode;
        private String responseBody;

        public OAuthTokenMockResponseGenerator(Integer statusCode, String responseBody) {
            this.statusCode = statusCode;
            this.responseBody = responseBody;
        }

        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(statusCode);
            res.setBody(responseBody);
            return res;
        }
    }
}