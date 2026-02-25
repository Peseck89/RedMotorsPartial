@isTest(seeAllData=true)
public class TelefonoControllerTest {

    @isTest
    static void testObtenerTelefonos() {
        Account acc = new Account(LastName = 'Test',FirstName = 'asdasdasd',Cedula__c = '635462733');
        insert acc;

        List<Tipo_de_datos_de_comunicaci_n__c> tipos = [SELECT Id FROM Tipo_de_datos_de_comunicaci_n__c WHERE Telefono__c = true LIMIT 1];

        Tel_fono__c tel = new Tel_fono__c(
            Cuenta__c = acc.Id,
            N_mero_de_tel_fono__c = '62345678',
            C_digo_de_rea__c = '+506',
            Tipo_telefono__c = 'Móvil',
            Tipo_de_datos_de_comunicaci_n__c = tipos[0].Id
        );
        insert tel;

        List<Tel_fono__c> telefonos = TelefonoController.obtenerTelefonos(acc.Id);
        System.assertEquals(1, telefonos.size());
    }

    @isTest
    static void testGuardarTelefonoNuevoYDesmarcarOtros() {
        Account acc = new Account(LastName = 'Test',FirstName = 'asdasdasd',Cedula__c = '635462733');
        insert acc;

        List<Tipo_de_datos_de_comunicaci_n__c> tipos = [SELECT Id FROM Tipo_de_datos_de_comunicaci_n__c WHERE Telefono__c = true LIMIT 1];

        Tel_fono__c tel1 = new Tel_fono__c(
            Cuenta__c = acc.Id,
            N_mero_de_tel_fono__c = '21314151',
            C_digo_de_rea__c = '+506',
            Tipo_telefono__c = 'Fijo',
            Telefono_principal__c = true,
            Tipo_de_datos_de_comunicaci_n__c = tipos[0].Id
        );
        insert tel1;

        Tel_fono__c tel2 = new Tel_fono__c(
            Cuenta__c = acc.Id,
            N_mero_de_tel_fono__c = '22526272',
            C_digo_de_rea__c = '+506',
            Tipo_telefono__c = 'Fijo',
            Telefono_principal__c = true,
            Tipo_de_datos_de_comunicaci_n__c = tipos[0].Id
        );

        Test.startTest();
        TelefonoController.dummy();
        TelefonoController.guardarTelefono(tel2);
        Test.stopTest();

        tel1 = [SELECT Telefono_principal__c FROM Tel_fono__c WHERE Id = :tel1.Id];
        tel2 = [SELECT Telefono_principal__c FROM Tel_fono__c WHERE Id = :tel2.Id];

        System.assertEquals(false, tel1.Telefono_principal__c);
        System.assertEquals(true, tel2.Telefono_principal__c);
    }

    @isTest
    static void testEliminarTelefono() {
        Account acc = new Account(LastName = 'Test',FirstName = 'asdasdasd',Cedula__c = '635462733');
        insert acc;

        List< Tipo_de_datos_de_comunicaci_n__c > lstTipo = [Select Id From Tipo_de_datos_de_comunicaci_n__c  Where Id != null];
        
        Tel_fono__c tel = new Tel_fono__c(
            Cuenta__c = acc.Id,
            N_mero_de_tel_fono__c = '29495969',
            C_digo_de_rea__c = '+506',
            Tipo_telefono__c = 'Fijo',
            Tipo_de_datos_de_comunicaci_n__c = lstTipo[0].id
        );
        insert tel;

        Test.startTest();
        TelefonoController.eliminarTelefono(tel.Id);
        Test.stopTest();

        List<Tel_fono__c> resultado = [SELECT Id FROM Tel_fono__c WHERE Id = :tel.Id];
        System.assertEquals(0, resultado.size());
        //
    }


}