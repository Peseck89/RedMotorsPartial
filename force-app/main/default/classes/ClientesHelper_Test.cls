/**
 * @description       : 
 * @author            : esteban@incompany.cr
 * @group             : 
 * @last modified on  : 09-12-2022
 * @last modified by  : esteban@incompany.cr
**/
@isTest
public class ClientesHelper_Test {
    @TestSetup
    static void setup(){
        Account acc = new Account();
        acc.Name = 'Test';
        acc.cedula__c = '000000564867';
        acc.clienteAltica__c = true; 
        
        insert acc;
    }

    @isTest
    static void getJSONResponseMovimientoTest()
    {
        ClientesTestData testData = new ClientesTestData();
        Account clienteTest = testData.generateMovimiento(false);
        String clienteJSON = ClientesHelper.getJSONClientes(clienteTest);
        System.assert(clienteJSON!=null);
    }

    @isTest
    static void getJSONAuthorizationTest()
    {
        String expectedValue = '00D7h000000Gz1s';
        String authJSON = '{"token":"'+expectedValue+'"}';
        String actualValue = ClientesHelper.getJSONAuthorization(authJSON);
        System.assertEquals(expectedValue,actualValue);
    }

    @isTest
    static void getClientesListFromAlticaTest()
    {
        String jsonStr = ClientesTestData.getClientesJSON();
        ClienteParser movimientosResponse = ClienteParser.parse(jsonStr);
        List<Account> lstClientes = ClientesHelper.getClientesListFromAltica(movimientosResponse);
        ClientesHelper.upsertClientes(lstClientes);
    }
}