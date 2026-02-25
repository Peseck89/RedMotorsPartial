public class ConsultaCredidMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"error": false, "mensaje": "OK", "data": { "confidenceResult": 824, "color": "#035595", "rangos": []}}');
        res.setStatusCode(200);
        return res; 
    }
}