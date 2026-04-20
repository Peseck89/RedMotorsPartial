@isTest(seeAllData=true)
public class CorreoControllerTest {

    @isTest
    static void testObtenerCorreos() {
        Account acc = new Account(LastName = 'Test',FirstName = 'asdasdasd',Cedula__c = '635462733');
        insert acc;

        Correo__c correo = new Correo__c(Name = 'correo1@test.com', Account__c = acc.Id);
        insert correo;

        List<Correo__c> lista = CorreoController.obtenerCorreos(acc.Id);
        System.assertEquals(1, lista.size());
    }

    @isTest
    static void testGuardarCorreoInsertPrincipal() {
        Account acc = new Account(LastName = 'Test',FirstName = 'asdasdasd',Cedula__c = '635462732');
        insert acc;

        Correo__c nuevoCorreo = new Correo__c(Name = 'nuevo@test.com', Account__c = acc.Id);

        Test.startTest();
        CorreoController.guardarCorreo(nuevoCorreo);
        Test.stopTest();

        Correo__c inserted = [SELECT Principal__c FROM Correo__c WHERE Name = 'nuevo@test.com' LIMIT 1];
        System.assertEquals(true, inserted.Principal__c);
    }

    @isTest
    static void testGuardarCorreoUpdateQuitaOtrosPrincipales() {
        Account acc = new Account(LastName = 'Test',FirstName = 'asdasdasd',Cedula__c = '635462738');
        insert acc;

        Correo__c correo1 = new Correo__c(Name = 'a@test.com', Account__c = acc.Id, Principal__c = true);
        insert correo1;

        Correo__c correo2 = new Correo__c(Name = 'b@test.com', Account__c = acc.Id);
        insert correo2;

        correo2.Principal__c = true;
        Test.startTest();
        CorreoController.guardarCorreo(correo2);
        Test.stopTest();

        Correo__c c1 = [SELECT Principal__c FROM Correo__c WHERE Id = :correo1.Id];
        Correo__c c2 = [SELECT Principal__c FROM Correo__c WHERE Id = :correo2.Id];

        System.assertEquals(false, c1.Principal__c);
        System.assertEquals(true, c2.Principal__c);
    }

    @isTest
    static void testEliminarCorreo() {
        Account acc = new Account(FirstName = 'asdasdasd',LastName = 'Test', Cedula__c = '635462738');
        insert acc;

        Correo__c correo = new Correo__c(Name = 'delete@test.com', Account__c = acc.Id);
        insert correo;

        Test.startTest();
        CorreoController.eliminarCorreo(correo.Id);
        Test.stopTest();

        List<Correo__c> resultado = [SELECT Id FROM Correo__c WHERE Id = :correo.Id];
        System.assertEquals(0, resultado.size());
    }


}