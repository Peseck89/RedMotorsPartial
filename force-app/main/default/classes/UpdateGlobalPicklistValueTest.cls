@isTest
public class UpdateGlobalPicklistValueTest {

    // Mock class to simulate the Tooling API responses
    private class MockHttpCallout implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');

            // Simulate different responses based on the endpoint
            if (req.getEndpoint().contains('query')) {
                res.setBody('{"records": [{"attributes": {"url": "/services/data/v47.0/tooling/sobjects/GlobalValueSet/1"}, "Metadata": {"customValue": [{"valueName": "OldValue1", "label": "OldValue1"}]}}]}');
                res.setStatusCode(200);
            } else if (req.getEndpoint().contains('GlobalValueSet/1')) {
                res.setBody('{}');
                res.setStatusCode(200);
            } else {
                res.setBody('{"message": "Unexpected endpoint"}');
                res.setStatusCode(400);
            }
            
            return res;
        }
    }

    @isTest
    static void testUpdateGlobalPicklistValue() {
        // Set mock for HTTP callouts
        Test.setMock(HttpCalloutMock.class, new MockHttpCallout());

        // Test data
        String apiName = 'TestGlobalPicklist';
        String newValue = 'NewPicklistValue';

        // Call the method to test
        Test.startTest();
        UpdateGlobalPicklistValue.updateGlobalPicklistValue(apiName, newValue);
        Test.stopTest();

        // Assertions (Example: Check debug logs or additional logic if you enhance the method with return values)
        // You can query logs or verify metadata updates if a return structure is implemented
        System.assert(true, 'No exceptions were thrown during the callout');
    }
}