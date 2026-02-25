@IsTest
global class MockHttpResponseGenerator2 implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        // Simula la respuesta del servicio web
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"operationResult": {"code": "00", "monto_anticipo": 1000, "oportunidad": "Opp-001", "cod_anticipo": "001"}}');
        res.setStatusCode(200);
        return res;
    }
}