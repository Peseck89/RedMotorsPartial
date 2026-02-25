/**
 * @description       : 
 * @author            : martin.alvrz.grcs@gmail.com
 * @group             : 
 * @last modified on  : 01-19-2023
 * @last modified by  : martin.alvrz.grcs@gmail.com
**/
@isTest
global class servicioReservasMock implements HttpCalloutMock{
    
    global HTTPResponse respond(HTTPRequest request){
        //Create fake response.
        HTTPResponse response = new HTTPResponse();

        //check if the url contains the word token
        if(request.getEndpoint().contains('token')){
            response.setBody('token001');
        }else{
            //response.setHeader('Content-Type', 'application/json');
            response.setBody('{"operationResult":{"code":"00","description":"EL ARTICULO INDICADO ES VALIDO."}}');
        }
        response.setStatusCode(200);

        return response;
    }

}