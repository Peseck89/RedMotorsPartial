/**
 * @description       : 
 * @author            : alexander@incompany.cr
 * @group             : 
 * @last modified on  : 18-11-2022
 * @last modified by  : esteban@incompany.cr
**/
public with sharing class ClientesCallout {
    public static HttpResponse enviarDatosClientes(Account clienteActual,String actualToken)
    {
        HttpResponse response;
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://test-snapcompliance-altica-serv-api-load.azurewebsites.net/Customers/SendCustomers');
        request.setMethod('POST');
        request.setHeader('Authorization', 'Bearer ' + actualToken);
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        // Set the body as a JSON object
        String clientesRequestJSON = ClientesHelper.getJSONClientes(clienteActual);
        request.setBody(clientesRequestJSON);
        response = http.send(request);
        // Parse the JSON response
        if(response.getStatusCode() != 200) {
            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
        } else {
            System.debug(response.getBody());
        }
        
        return response;
    }

    public static HttpResponse getClientesDataFromAltica()
    {
        HttpResponse response;
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('http://35.226.4.74/api/SnapCompliance/obtenerClientes');
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