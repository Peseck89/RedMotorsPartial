/**
 * @description       : 
 * @author            : esteban@incompany.cr
 * @group             : 
 * @last modified on  : 18-11-2022
 * @last modified by  : esteban@incompany.cr
**/
public with sharing class ClientesController {
    @future(callout=true)
    public static void processClientes()
    {
        if(Test.isRunningTest())
        {
            Map<String, String> mapHeaders = new Map<String,String>();
            mapHeaders.put('Content-Type', 'application/json');

            String jsonBody = ClientesTestData.getClientesJSON();
            ClientesHttpCalloutMock mock = new ClientesHttpCalloutMock(200, 'OK', jsonBody, mapHeaders);
            Test.setMock(HttpCalloutMock.class, mock); 
        }
        HttpResponse response = ClientesCallout.getClientesDataFromAltica();
        System.debug(response);
        ClienteParser clienteResponse = ClienteParser.parse(response.getBody());
        List<Account> lstClientes = ClientesHelper.getClientesListFromAltica(clienteResponse);
        System.debug(lstClientes.size());
        ClientesHelper.upsertClientes(lstClientes);
    }
}