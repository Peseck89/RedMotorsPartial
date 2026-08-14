@isTest
public class HttpCalloutGetProductRefPricesTest {
    @isTest
    static void testGetProductRefPricesPOST() {
        Test.setMock(
            HttpCalloutMock.class,
            new HttpCalloutGetProductRefPricesTest.MockHttpCallout('RMBAVARIAN')
        );

        // Instantiate the class to test
        HttpCalloutGetProductRefPrices service = new HttpCalloutGetProductRefPrices();

        // Call the method with the provided request data
        HttpResponse response = service.getProductRefPricesPOST('11657605341', 'RMBAVARIAN');
        System.assertEquals(200, response.getStatusCode());
    }

    @isTest
    static void sendsPekingCodeReceivedFromCaller() {
        Test.setMock(
            HttpCalloutMock.class,
            new HttpCalloutGetProductRefPricesTest.MockHttpCallout('RMPEKING')
        );

        HttpResponse response = new HttpCalloutGetProductRefPrices()
            .getProductRefPricesPOST('11657605341', 'rmpeking');

        System.assertEquals(200, response.getStatusCode());
    }

    @isTest
    static void sendsOtobaiCodeReceivedFromCaller() {
        Test.setMock(
            HttpCalloutMock.class,
            new HttpCalloutGetProductRefPricesTest.MockHttpCallout('RMOTOBAI')
        );

        HttpResponse response = new HttpCalloutGetProductRefPrices()
            .getProductRefPricesPOST('11657605341', 'RMOTOBAI');

        System.assertEquals(200, response.getStatusCode());
    }

    @isTest
    static void rejectsMissingCompanyCodeBeforeCallout() {
        Boolean receivedExpectedError = false;
        try {
            new HttpCalloutGetProductRefPrices()
                .getProductRefPricesPOST('11657605341', null);
        } catch (AuraHandledException ex) {
            receivedExpectedError = ex.getMessage().contains('Código Softland');
        }
        System.assert(receivedExpectedError);
    }

    public class MockHttpCallout implements HttpCalloutMock {
        private String expectedCompany;

        public MockHttpCallout(String expectedCompany) {
            this.expectedCompany = expectedCompany;
        }

        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();

            // Simulate authentication request
            if (req.getEndpoint().contains('getAuth')) {
                res.setStatusCode(200);
                res.setBody('{"access_token":"mock_token","token_type":"Bearer"}');
                return res;
            }

            // Simulate POST request to getProductRefPrices
            if (req.getMethod() == 'POST' && req.getEndpoint().contains('getProductRefPrices')) {
                Map<String, Object> requestBody =
                    (Map<String, Object>) JSON.deserializeUntyped(req.getBody());
                if (String.valueOf(requestBody.get('articulo')) == '11657605341' &&
                    String.valueOf(requestBody.get('compania')) == expectedCompany) {
                    res.setStatusCode(200);
                    res.setBody('{"ARTICULO":"11657605341","VOR_DOLAR":"13.69810000","VOR":"7017.12830000","MARIT_DOLAR":"11.41510000","MARI":"5847.60690000","AEREO_DOLAR":"16.91120000","AERE":"8663.12140000","PRECIO_CON_IVA":"8990.28000000","PRECIO_EMPLEADO":"4574.59000000"}');
                    return res;
                } else {
                    res.setStatusCode(400);
                    res.setBody('{"error":"Invalid Request"}');
                    return res;
                }
            }

            res.setStatusCode(404);
            res.setBody('{"error":"Endpoint not found"}');
            return res;
        }
    }
}
