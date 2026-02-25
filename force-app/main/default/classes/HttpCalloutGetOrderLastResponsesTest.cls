@IsTest
private class HttpCalloutGetOrderLastResponsesTest {
    @IsTest
    static void testGetOrderLastResponses() {
        // Set up mock HTTP response
        HttpResponse mockHttpResponse = new HttpResponse();
        mockHttpResponse.setStatusCode(200);
        mockHttpResponse.setBody('{"code":"00","detail":"Json procesado con exito","Total_Pedido":"0","Subtotal":"0","Impuesto":"0","Estado":"0","tipoCargo":"","Data":[{"code":"00","detail":"OSLU-0000013971","Total_Pedido":"910412.85","Subtotal":"805675.11","Impuesto":"104737.74","Estado":"A","tipoCargo":"4","Data":[]},{"code":"00","detail":"PILU-0000000999","Total_Pedido":"53731.21000000","Subtotal":"47549.74000000","Impuesto":"6181.47000000","Estado":"F","tipoCargo":"2","Data":[]}]}');

        // Set the mock callout class
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockHttpResponse));

        // Call the method being tested
        HttpResponse response = HttpCalloutGetOrderLastResponses.getOrderLastResponses('00028281', 'RMBAVARIAN','0WO5C0000005KIXWA2');

        // Perform assertions on the response
        System.assertEquals(200, response.getStatusCode());
        System.assertEquals('{"code":"00","detail":"Json procesado con exito","Total_Pedido":"0","Subtotal":"0","Impuesto":"0","Estado":"0","tipoCargo":"","Data":[{"code":"00","detail":"OSLU-0000013971","Total_Pedido":"910412.85","Subtotal":"805675.11","Impuesto":"104737.74","Estado":"A","tipoCargo":"4","Data":[]},{"code":"00","detail":"PILU-0000000999","Total_Pedido":"53731.21000000","Subtotal":"47549.74000000","Impuesto":"6181.47000000","Estado":"F","tipoCargo":"2","Data":[]}]}', response.getBody());
    }

    // Define the mock callout class
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        private HttpResponse response;

        public MockHttpResponseGenerator(HttpResponse response) {
            this.response = response;
        }

        public HttpResponse respond(HttpRequest request) {
            return response;
        }
    }
}