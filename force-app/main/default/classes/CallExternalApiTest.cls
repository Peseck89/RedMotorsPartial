@IsTest
public class CallExternalApiTest {
    @IsTest
    static void testCallExternalApi_Success() {
        // Set up test data
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'TestSucursal - TestService',
            Username = 'testuser-Redm@test.com',
            Email = 'testuser-Redm@test.com',
            Alias = 'tuser',
            CommunityNickname = 'testuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;

        // Mock access token service
        //Test.setMock(OAuthTokenServiceMock.class, new OAuthTokenServiceMock('mockAccessToken'));

        // Mock HTTP response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, '{"message": "Success"}'));

        // Call the method
        Test.startTest();
        String response = CommunityCalendarController.callExternalApi('TestService', '0054U000009hiwMQAQ', '29/10/2024');
        Test.stopTest();

        // Verify the response
        System.assertEquals('{"message": "Success"}', response);
    }

    @IsTest
    static void testCallExternalApi_Error() {
        // Set up test data
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'TestSucursal - TestService',
            Username = 'testuser2-RedM@test.com',
            Email = 'testuser2-RedM@test.com',
            Alias = 'tuser2',
            CommunityNickname = 'testuser2',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;

        // Mock access token service
       //Test.setMock(OAuthTokenServiceMock.class, new OAuthTokenServiceMock('mockAccessToken'));

        // Mock HTTP error response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(404, 'Not Found'));

        // Call the method and expect an exception
        Test.startTest();
        try {
            CommunityCalendarController.callExternalApi('TestService', testUser.Id, '2024-11-01');
            System.assert(false, 'Expected AuraHandledException was not thrown');
        } catch (AuraHandledException e) {
            //System.assert(e.getMessage().contains('Error: 404 Not Found'));
        }
        Test.stopTest();
    }

    // Mock class for access token retrieval
    private class OAuthTokenServiceMock implements HttpCalloutMock {
        private String accessToken;

        public OAuthTokenServiceMock(String token) {
            this.accessToken = token;
        }

        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Authorization', 'Bearer ' + accessToken);
            return res;
        }
    }

    // Mock class for HTTP callouts
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        private Integer statusCode;
        private String responseBody;

        public MockHttpResponseGenerator(Integer statusCode, String responseBody) {
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