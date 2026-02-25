@isTest
global class servicioEliminarReservaMock implements HttpCalloutMock{
    
    global HTTPResponse respond(HTTPRequest request){
        //Create fake response.
        HTTPResponse response = new HTTPResponse();
        //check if the url contains the text '/oauth/token' return a fake response else if the url contains unreserved return a fake response
        if(request.getEndpoint().contains('/oauth/token')){
            response.setBody('Tkn01');
        }else if(request.getEndpoint().contains('unreserveVehicule')){
            response.setBody('{"operationResult":{"code":"00","description":"EL ARTICULO INDICADO ES VALIDO."}');
        }
  
        //response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(200);
        return response;
    }

}