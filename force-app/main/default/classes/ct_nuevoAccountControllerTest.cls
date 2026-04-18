@isTest(seeAllData=true)
public class ct_nuevoAccountControllerTest {

    @isTest
    static void testCrearCuentaExitosa() {
        Map<String, Object> data = new Map<String, Object>{
            'RecordTypeId' => [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND IsPersonType = true LIMIT 1].Id,
            'Tipos_de_cuenta__c' => 'Persona Física',
            'Tipo_de_Documento__c' => 'DNI',
            'Cedula__c' => '123446789',
            'PaisPicklist__c' => 'Costa Rica',
            'LastName' => 'Perez',
            'FirstName' => 'Perez',
            'Sexo__c' => 'Hombre',
            'Fecha_Nacimiento__c' => '1990-01-01',
            'Profesiones__c' => 'Ingeniero',
            'EstadoCivilTipos__c' => 'Soltero'
        };

        Id newId = ct_nuevoAccountController.crearCuenta(data);
        System.assertNotEquals(null, newId);
    }

    @isTest
    static void testCrearCuentaJuridicaExitosa() {
        Map<String, Object> data = new Map<String, Object>{
            'Tipos_de_cuenta__c' => 'Persona Jurídica',
            'Tipo_de_Documento__c' => 'RFC',
            'PaisPicklist__c' => 'Costa Rica',
            'Cedula__c' => 'XAXX010101000',
            'Name' => 'Empresa X',
            'Description' => 'Cuenta jurídica de prueba'
        };

        Id accId = ct_nuevoAccountController.crearCuentaJuridica(data);
        System.assertNotEquals(null, accId);
    }

    @isTest
    static void testActualizarCorreoYTelefono() {
        Account acc = new Account(
            RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' LIMIT 1].Id,
            Name = 'Martinez', Tipo_de_Documento__c  = '01' ,Cedula__c = '345432393'
        );
        insert acc;

        Correo__c correo = new Correo__c(Name = 'ventas@antoniodorantes.com', Account__c = acc.Id, Principal__c = true);
        //insert correo;

        List<Tipo_de_datos_de_comunicaci_n__c> tDC = [Select Id From Tipo_de_datos_de_comunicaci_n__c Where Id != null];
        
        Tel_fono__c tel = new Tel_fono__c( Cuenta__c = acc.Id, Telefono_principal__c = true);
        tel.N_mero_de_tel_fono__c = '83191850';
        tel.C_digo_de_rea__c = '+506';
        tel.Tipo_de_datos_de_comunicaci_n__c = tDC[0].id;     
        insert tel;

        Test.startTest();
        ct_nuevoAccountController.actualizarCorreoYTelefono(acc.Id);
        Test.stopTest();

        Account actualizado = [SELECT Phone FROM Account WHERE Id = :acc.Id];
        Assert.areNotEqual(null, actualizado.Phone, 'Se esperaba que el teléfono principal se asignara a la cuenta');
    }

    @isTest
    static void testActualizarCuenta() {
        Account acc = new Account(
            RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' LIMIT 1].Id,
           Name = 'Dominguez', Tipo_de_Documento__c  = '01' ,Cedula__c = '345432393'
        );
        insert acc;

        Map<String, Object> datos = new Map<String, Object>{
            'Name' => 'Dominguez',
            'Cedula__c' => '957655321',
            'Tipo_de_Documento__c' => 'DNI'
        };

        Test.startTest();
        ct_nuevoAccountController.actualizarCuenta(acc.Id, datos);
        Test.stopTest();

        Account actualizado = [SELECT Cedula__c FROM Account WHERE Id = :acc.Id];
        Assert.areEqual('957655321', actualizado.Cedula__c, 'La cédula debe haberse actualizado');
    }

    @isTest
    static void testGetAccountById() {
        Account acc = new Account(
            RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' LIMIT 1].Id,
            Name = 'Torres', Tipo_de_Documento__c  = '01' ,Cedula__c = '345432393'
        );
        insert acc;

        Account result = ct_nuevoAccountController.getAccountById(acc.Id);
        System.assertEquals(acc.Id, result.Id);
    }
}