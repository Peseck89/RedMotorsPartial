@isTest(seeAllData=true)
public class DireccionControllerTest {

    @isTest
    static void testObtenerDirecciones() {
        Account acc = new Account(LastName = 'Test',FirstName = 'asdasdasd',Cedula__c = '635462733');
        insert acc;

        List<Provincia__c> lstProv = [Select Id From Provincia__c  Where Id != null];
        List< Canton__c > lstCanton = [Select Id From Canton__c  WHere Id != null];
        List< Distrito__c > lstDistrito = [Select Id From Distrito__c  Where Id != null];
        Direccion__c dir = new Direccion__c(Direccion__c = 'Calle 123', Cuenta__c = acc.Id, Provincia__c = lstProv[0].Id, Canton__c =lstCanton[0].Id,Distrito__c= lstDistrito[0].Id );
        insert dir;

        List<Direccion__c> direcciones = DireccionController.obtenerDirecciones(acc.Id);
        System.assertEquals(1, direcciones.size());
    }

    @isTest
    static void testGuardarDireccionPrimera() {
        Account acc = new Account(LastName = 'Test',FirstName = 'asdasdasd',Cedula__c = '635462733');
        insert acc;
		
        List<Provincia__c> lstProv = [Select Id From Provincia__c  Where Id != null];
        List< Canton__c > lstCanton = [Select Id From Canton__c  WHere Id != null];
        List< Distrito__c > lstDistrito = [Select Id From Distrito__c  Where Id != null];
        Direccion__c dir = new Direccion__c(Direccion__c = 'Av Siempre Viva', Cuenta__c = acc.Id, Provincia__c = lstProv[0].Id, Canton__c = lstCanton[0].id,Distrito__c = lstDistrito[0].Id);

        Test.startTest();
        Direccion__c result = DireccionController.guardarDireccion(dir);
        Test.stopTest();

        System.assert(result.Direccion_principal__c);
    }

    @isTest
    static void testGuardarDireccionDesmarcaOtros() {
        Account acc = new Account(LastName = 'Test',FirstName = 'asdasdasd',Cedula__c = '635462733');
        insert acc;
		
        List<Provincia__c> lstProv = [Select Id From Provincia__c  Where Id != null];
        List< Canton__c > lstCanton = [Select Id From Canton__c  WHere Id != null];
        List< Distrito__c > lstDistrito = [Select Id From Distrito__c  Where Id != null];
        Direccion__c d1 = new Direccion__c(Direccion__c = 'Eliminar', Cuenta__c = acc.Id, Provincia__c = lstProv[0].Id,Canton__c = lstCanton[0].Id, Distrito__c = lstDistrito[0].Id );
		insert d1;
        Direccion__c d2 = new Direccion__c(Direccion__c = 'Calle Dos', Cuenta__c = acc.Id,Provincia__c = lstProv[0].Id, Canton__c = lstCanton[0].Id , Distrito__c = lstDistrito[0].Id);
        insert d2;

        d2.Direccion_principal__c = true;
        Test.startTest();
        DireccionController.guardarDireccion(d2);
        Test.stopTest();

        d1 = [SELECT Direccion_principal__c FROM Direccion__c WHERE Id = :d1.Id];
        d2 = [SELECT Direccion_principal__c FROM Direccion__c WHERE Id = :d2.Id];

        System.assertEquals(false, d1.Direccion_principal__c);
        System.assertEquals(true, d2.Direccion_principal__c);
    }

    @isTest
    static void testEliminarDireccion() {
        Account acc = new Account(LastName = 'Test',FirstName = 'asdasdasd',Cedula__c = '635462733');
        insert acc;

        List<Provincia__c> lstProv = [Select Id From Provincia__c  Where Id != null];
        List< Canton__c > lstCanton = [Select Id From Canton__c  WHere Id != null];
        List< Distrito__c > lstDistrito = [Select Id From Distrito__c  Where Id != null];
        Direccion__c dir = new Direccion__c(Direccion__c = 'Eliminar', Cuenta__c = acc.Id, Provincia__c = lstProv[0].Id ,Canton__c = lstCanton[0].Id, Distrito__c = lstDistrito[0].id );
        insert dir;

        Test.startTest();
        DireccionController.eliminarDireccion(dir.Id);
        Test.stopTest();

        List<Direccion__c> resultados = [SELECT Id FROM Direccion__c WHERE Id = :dir.Id];
        System.assertEquals(0, resultados.size());
    }

    @isTest
    static void testObtenerProvinciasYGeografia() {

        List<Provincia__c> provincias = DireccionController.obtenerProvincias();
        List<Canton__c> cantones = DireccionController.obtenerCantones();
        List<Distrito__c> distritos = DireccionController.obtenerDistritos();


    }
}