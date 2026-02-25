/**
 * @description       : 
 * @author            : esteban@incompany.cr
 * @group             : 
 * @last modified on  : 13-10-2022
 * @last modified by  : esteban@incompany.cr
**/
public with sharing class MovimientosCallout {
    public static HttpResponse sendMovimientoData(Movimiento__c actualMovimiento,String actualToken)
    {
        HttpResponse response;
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://test-snapcompliance-altica-serv-api-load.azurewebsites.net/Customers/SendTransactions');
        request.setMethod('POST');
        request.setHeader('Authorization', 'Bearer '+actualToken);
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        // Set the body as a JSON object
        String movimientoRequestJSON = MovimientosHelper.getJSONResponseMovimiento(actualMovimiento);
        System.debug(movimientoRequestJSON);
        request.setBody(movimientoRequestJSON);
        response = http.send(request);
        // Parse the JSON response
        if(response.getStatusCode() != 200) {
            System.debug('Server Status: ' + response.getStatusCode() + ' ' + response.getStatus()+' '+response.getBody());
            System.debug(response.getBody());
        } else {
            System.debug(response.getBody());
        }
        
        return response;
    }

    public static HttpResponse getMovimientoDataFromAltica()
    {
        HttpResponse response;
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('http://35.226.4.74/api/LagoDeDatos/obtenerMovimientos');
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        response = http.send(request);
        // Parse the JSON response
        if(response.getStatusCode() != 200) {
            System.debug('Server Status: ' + response.getStatusCode() + ' ' + response.getStatus()+' '+response.getBody());
            System.debug(response.getBody());
        } else {
            System.debug(response.getBody());
        }
        
        return response;
    }
}