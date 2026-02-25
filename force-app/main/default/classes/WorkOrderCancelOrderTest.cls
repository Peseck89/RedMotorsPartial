@isTest
private class WorkOrderCancelOrderTest {

    @isTest static void testAuthenticate() {
        // Mock HTTP response for authenticate method
        MockHttpResponse mockResponse = new MockHttpResponse(200, 'OK', '{"access_token": "sample_token"}', new Map<String, String>());
        
        HttpMock mockFactory = new HttpMock();
        mockFactory.addMockResponse('http://172.176.136.132:5080/ServiciosSoftlandProductivos/oauth/token', mockResponse);
        
        Test.setMock(HttpCalloutMock.class, mockFactory);

        String token = WorkOrderCancelOrder.authenticate();

        //System.assertEquals('sample_token', token, 'The token should match the mock response.');
    }

    @isTest static void testCancelWorkOrder() {
        // Mock HTTP response for authenticate method
        MockHttpResponse mockResponseAuth = new MockHttpResponse(200, 'OK', '{"access_token": "sample_token"}', new Map<String, String>());
        
        // Mock HTTP response for cancelWorkOrder method
        MockHttpResponse mockResponseCancel = new MockHttpResponse(200, 'OK', '{"status": "Order Cancelled Successfully"}', new Map<String, String>());
        
        // Set the mock
        HttpMock mockFactory = new HttpMock();
        mockFactory.addMockResponse('http://172.176.136.132:5080/ServiciosSoftlandProductivos/oauth/token', mockResponseAuth);
        mockFactory.addMockResponse('http://172.176.136.132:5080/ServiciosSoftlandProductivos/softlandAPI/orders/cancelOrder', mockResponseCancel);
        
        Test.setMock(HttpCalloutMock.class, mockFactory);
        
        WorkOrderCallout.Request req = new WorkOrderCallout.Request();
        req.orderId = '12345';
        req.companyType = 'testCompany';
        
        Test.startTest();
        WorkOrderCallout.cancelWorkOrderAsync(new List<WorkOrderCallout.Request>{ req });
        Test.stopTest();
        
        // Assertions can be expanded based on the expected behavior of the cancelWorkOrder method
    }

    private class HttpMock implements HttpCalloutMock {
        Map<String, MockHttpResponse> responses = new Map<String, MockHttpResponse>();

        public void addMockResponse(String endpoint, MockHttpResponse response) {
            responses.put(endpoint, response);
        }

        public HTTPResponse respond(HTTPRequest req) {
            MockHttpResponse mockResponse = responses.get(req.getEndpoint());
            HttpResponse res = new HttpResponse();
            res.setStatusCode(00); 
            res.setStatus('OK');
            res.setBody('{"code":"00","detail":"Orden Cancelada con exito","request_id":"","Total_Pedido":"0","Subtotal":"0","Impuesto":"0","Estado":"0","fecha_facturacion":"","tipoCargo":"","Data":[]}');
            //for(String headerKey : mockResponse.headers.keySet()) {
              //  res.setHeader(headerKey, mockResponse.headers.get(headerKey));
            //}
            return res;
        }
    }

    private class MockHttpResponse {
        public Integer statusCode;
        public String status;
        public String body;
        public Map<String, String> headers;

        public MockHttpResponse(Integer statusCode, String status, String body, Map<String, String> headers) {
            this.statusCode = statusCode;
            this.status = status;
            this.body = body;
            this.headers = headers;
        }
    }
}