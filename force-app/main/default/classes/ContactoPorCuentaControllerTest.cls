@isTest(seeAllData=true)
public class ContactoPorCuentaControllerTest {

    @isTest
    static void testGuardarContactoPorCuentaInsert() {
        Account acc = new Account(LastName = 'Test',FirstName = 'asdasdasd',Cedula__c = '635462733');
        insert acc;
		Tipo_de_contacto__c newTipo = new Tipo_de_contacto__c(Name ='Tets');
        Insert newTipo;
        Tipo_de_contacto__c tipo = [SELECT Id FROM Tipo_de_contacto__c LIMIT 1];

        Map<String, Object> data = new Map<String, Object>{
            'nombreContacto' => 'Juan Pérez',
            'tipoContactoId' => tipo.Id,
            'esPrimario' => true,
            'accountId' => acc.Id,
            'contactoId' => null,
            'relacionId' => null,
            'correo' => 'juan@test.com',
            'codigoArea' => '+506',
            'telefono' => '12345678'
        };

        Test.startTest();
        ContactoPorCuentaController.guardarContactoPorCuenta(data);
        Test.stopTest();

        List<Contacto_por_cuenta__c> relacionados = [SELECT Id FROM Contacto_por_cuenta__c WHERE Account__c = :acc.Id];
        System.assertEquals(1, relacionados.size());
    }

    @isTest
    static void testGuardarContactoPorCuentaUpdate() {
        Account acc = new Account(LastName = 'Test',FirstName = 'asdasdasd',Cedula__c = '635462733');
        insert acc;

        Contact contacto = new Contact(LastName = 'Inicial');
        insert contacto;
		
        Tipo_de_contacto__c newTipo = new Tipo_de_contacto__c(Name ='Tets');
        Insert newTipo;
        Tipo_de_contacto__c tipo = [SELECT Id FROM Tipo_de_contacto__c LIMIT 1];

        Contacto_por_cuenta__c rel = new Contacto_por_cuenta__c(
            Account__c = acc.Id,
            Contact__c = contacto.Id,
            Tipo_de_contacto__c = tipo.Id,
            Es_primario__c = false
        );
        insert rel;

        Map<String, Object> data = new Map<String, Object>{
            'nombreContacto' => 'Nuevo Nombre',
            'tipoContactoId' => tipo.Id,
            'esPrimario' => true,
            'accountId' => acc.Id,
            'contactoId' => contacto.Id,
            'relacionId' => rel.Id,
            'correo' => 'nuevo@correo.com',
            'codigoArea' => '+506',
            'telefono' => 98765432
        };

        Test.startTest();
        ContactoPorCuentaController.guardarContactoPorCuenta(data);
        Test.stopTest();

        Contact contactoModificado = [SELECT LastName FROM Contact WHERE Id = :contacto.Id];
        System.assertEquals('Nuevo Nombre', contactoModificado.LastName);
    }

    @isTest
    static void testEliminarContactoPorCuenta() {
        Account acc = new Account(LastName = 'Test',FirstName = 'asdasdasd',Cedula__c = '635462733');
        insert acc;

        Contact contacto = new Contact(LastName = 'Eliminar');
        insert contacto;
		Tipo_de_contacto__c newTipo = new Tipo_de_contacto__c(Name ='Tets');
        Insert newTipo;
        Tipo_de_contacto__c tipo = [SELECT Id FROM Tipo_de_contacto__c LIMIT 1];

        Contacto_por_cuenta__c rel = new Contacto_por_cuenta__c(
            Account__c = acc.Id,
            Contact__c = contacto.Id,
            Tipo_de_contacto__c = tipo.Id,
            Es_primario__c = false
        );
        insert rel;

        Test.startTest();
        ContactoPorCuentaController.eliminarContactoPorCuenta(rel.Id);
        Test.stopTest();

        List<Contacto_por_cuenta__c> resultados = [SELECT Id FROM Contacto_por_cuenta__c WHERE Id = :rel.Id];
        System.assertEquals(0, resultados.size());
    }

    @isTest
    static void testObtenerContactos() {
        Account acc = new Account(LastName = 'Test',FirstName = 'asdasdasd',Cedula__c = '635462733');
        insert acc;

        Contact contacto = new Contact(LastName = 'Obtener');
        insert contacto;
        
        Tipo_de_contacto__c newTipo = new Tipo_de_contacto__c(Name ='Tets');
        Insert newTipo;

        Tipo_de_contacto__c tipo = [SELECT Id FROM Tipo_de_contacto__c LIMIT 1];

        Contacto_por_cuenta__c rel = new Contacto_por_cuenta__c(
            Account__c = acc.Id,
            Contact__c = contacto.Id,
            Tipo_de_contacto__c = tipo.Id,
            Es_primario__c = false
        );
        insert rel;

        List<Contacto_por_cuenta__c> lista = ContactoPorCuentaController.obtenerContactos(acc.Id);
        System.assertEquals(1, lista.size());
    }

    @isTest
    static void testObtenerTiposContacto() {
        List<Tipo_de_contacto__c> tipos = ContactoPorCuentaController.obtenerTiposContacto();
    }
}