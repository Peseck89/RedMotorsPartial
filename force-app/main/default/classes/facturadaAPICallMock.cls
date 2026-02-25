@isTest
global class facturadaAPICallMock implements HttpCalloutMock{
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
        return '{"SoftlandCode":"asdqwe1231","Estado":"F"}';
    }
}