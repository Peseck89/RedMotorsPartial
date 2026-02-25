@isTest(seeAllData=true)
public class IdentificacionControllerTest {

    @isTest
    static void testObtenerIdentificaciones() {
        Account acc = new Account(LastName = 'Test',FirstName = 'asdasdasd',Cedula__c = '635462733');
        insert acc;

        List<Tipo_de_documento__c> tipos = [SELECT Id FROM Tipo_de_documento__c LIMIT 1];
        Identificacion__c ident = new Identificacion__c(
            Cuenta__c = acc.Id,
            Tipo_de_documento__c = tipos[0].Id,
            Pais__c = 'Costa Rica',
            Identificaci_n__c = '12345678'
        );
        insert ident;

        List<Identificacion__c> lista = IdentificacionController.obtenerIdentificaciones(acc.Id);
        System.assertEquals(1, lista.size());
    }

    @isTest
    static void testGuardarIdentificacion() {
        Account acc = new Account(LastName = 'Test',FirstName = 'asdasdasd',Cedula__c = '635462733');
        insert acc;

        List<Tipo_de_documento__c> tipos = [SELECT Id FROM Tipo_de_documento__c LIMIT 1];
        Identificacion__c ident = new Identificacion__c(
            Cuenta__c = acc.Id,
            Tipo_de_documento__c = tipos[0].Id,
            Pais__c = 'Costa Rica',
            Identificaci_n__c = '253627384',
            Identificacion_principal__c = true
        );

        Test.startTest();
        IdentificacionController.guardarIdentificacion(ident);
        Test.stopTest();

        Identificacion__c saved = [SELECT Identificacion_principal__c FROM Identificacion__c WHERE Id = :ident.Id];
        System.assert(saved.Identificacion_principal__c);
    }

    @isTest
    static void testEliminarIdentificacion() {
        Account acc = new Account(LastName = 'Test',FirstName = 'asdasdasd',Cedula__c = '635462733');
        insert acc;

        List<Tipo_de_documento__c> tipos = [SELECT Id FROM Tipo_de_documento__c LIMIT 1];
        Identificacion__c ident = new Identificacion__c(
            Cuenta__c = acc.Id,
            Tipo_de_documento__c = tipos[0].Id,
            Pais__c = 'Costa Rica',
            Identificaci_n__c = '999'
        );
        insert ident;

        Test.startTest();
        IdentificacionController.eliminarIdentificacion(ident.Id);
        Test.stopTest();

        List<Identificacion__c> result = [SELECT Id FROM Identificacion__c WHERE Id = :ident.Id];
        System.assertEquals(0, result.size());
    }

    @isTest
    static void testObtenerTiposDocumento() {
        List<Tipo_de_documento__c> tipos = IdentificacionController.obtenerTiposDocumento();
        System.assert(!tipos.isEmpty());
    }

    @isTest
    static void testObtenerTiposDocumentoCuenta() {
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'Cliente Jurídico' LIMIT 1];
        Account acc = new Account(RecordTypeId = rt.Id, Name = 'Empresa X', Tipo_de_Documento__c  = '01' ,Cedula__c = '345432393');
        insert acc;

        List<TiposDocumentoxTiposCuenta__c> docs = IdentificacionController.obtenerTiposDocumentoCuenta(acc.Id);
        System.assertNotEquals(null, docs);
    }

    @isTest
    static void testCrearIdentificacionInicial() {
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'Cliente Jurídico' LIMIT 1];
        Account acc = new Account(RecordTypeId = rt.Id, Name = 'Empresa Inicial', Tipo_de_Documento__c  = '01' ,Cedula__c = '345432393');
        insert acc;

        Tipo_de_documento__c tipoDoc = new Tipo_de_documento__c (Name = 'Cédula Juridica');
        insert tipoDoc;
        Tipo_de_documento__c tipo = [SELECT Id, Name FROM Tipo_de_documento__c WHERE Name = 'Cédula Juridica' LIMIT 1];

        Test.startTest();
        IdentificacionController.crearIdentificacionInicial(acc.Id, tipo.id, 'Costa Rica', '234234999');
        IdentificacionController.testDummy();
        Test.stopTest();
		
        List<Identificacion__c> ident = [SELECT Id FROM Identificacion__c WHERE Cuenta__c = :acc.Id];
        System.assertEquals(1, ident.size());
    }
}