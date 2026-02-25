@isTest
private class TestExternalAuthService {

    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            // Create a fake response
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"access_token": "test_access_token"}');
            response.setStatusCode(200);
            return response;
        }
    }

    @isTest static void testAuthenticate() {
        // Set up the mock response generator
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Call the method to test
        String accessToken = ExternalAuthService.authenticate();

        // Perform the test
        System.assertEquals('test_access_token', accessToken, 'Access token should match mock response');
    }
}