@isTest
global class OrderBatchMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"code": "Draft","detail": "Modificable","Data": []}');
        res.setStatusCode(200);
        return res;
    }
}