@isTest
global class ProveedorAPICallMock implements HttpCalloutMock {
	global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setStatus('OK');
        response.setBody(mockResponse());
        response.setStatusCode(200);
        return response; 
    }
    public static String mockResponse(){
        return '{"Name":"Proveedor 1 test","SoftlandCode":"234324","activo":"true"}';
    }
}