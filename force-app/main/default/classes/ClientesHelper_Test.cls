/**
 * @description       : 
 * @author            : esteban@incompany.cr
 * @group             : 
 * @last modified on  : 09-12-2022
 * @last modified by  : esteban@incompany.cr
**/
@isTest
public class ClientesHelper_Test {
    private
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
    static void getClientesListFromAlticaTest()
    {
        String jsonStr = ClientesTestData.getClientesJSON();
        ClienteParser movimientosResponse = ClienteParser.parse(jsonStr);
        List<Account> lstClientes = ClientesHelper.getClientesListFromAltica(movimientosResponse);
        ClientesHelper.upsertClientes(lstClientes);
    }

    @isTest
    static void upsertClientesActualizaClienteExistenteTest()
    {
        Account clienteExistente = new Account();
        clienteExistente.Name = 'Cliente Altica Existente';
        clienteExistente.cedula__c = '555TEST001';
        clienteExistente.clienteAltica__c = true;
        insert clienteExistente;
        clienteExistente = [
            SELECT Id, cedula__c, clienteAltica__c
            FROM Account
            WHERE Id = :clienteExistente.Id
        ];

        String jsonStr = ClientesTestData.getClientesJSON();
        ClienteParser movimientosResponse = ClienteParser.parse(jsonStr);
        Account clienteActualizado = ClientesHelper.getClientesListFromAltica(movimientosResponse)[0];
        clienteActualizado.cedula__c = clienteExistente.cedula__c;
        System.assertEquals(1, [
            SELECT COUNT()
            FROM Account
            WHERE cedula__c = :clienteActualizado.cedula__c
            AND clienteAltica__c = true
        ]);

        Test.startTest();
        ClientesHelper.upsertClientes(new List<Account>{ clienteActualizado });
        Test.stopTest();

        Account resultado = [
            SELECT Id
            FROM Account
            WHERE Id = :clienteExistente.Id
        ];
        System.assertEquals(clienteExistente.Id, resultado.Id);
    }

}
