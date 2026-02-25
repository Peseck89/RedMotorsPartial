@isTest(seeAllData=true)
public class cT_ChangeData_copy_ctrl_tst {

   
    // @isTest
    // static void testCreateAccount() {
    //     // Test data
    //     String cedula = '924647634';
    //     String tipoDocumento = '01';
    //     String nombreCuenta = 'Test Account';
    //     String apellido = 'Doe';
    //     String telefono = '+50612312312';
    //     String fechaNacimiento = '2000-01-01';
    //     String correoElectronico = 'test@example.com';
    //     String nombreEncargado = 'Manager Name';
    //     String telefonoEncargado = '+50612312313';
    //     Boolean esEmpresarial = true;

    //     // Call method
    //     Account createdAccount = cT_ChangeData_copy_ctrl.createAccount(
    //         nombreCuenta, apellido, cedula, telefono, fechaNacimiento, correoElectronico, nombreEncargado, telefonoEncargado, esEmpresarial
    //     );


    // }

    @isTest
    static void testCreatePersonAccount() {
        String cedula = '654321873';
        Boolean esEmpresarial = false;
        
        Account acc = cT_ChangeData_copy_ctrl.createAccount(
            'John', 'Doe', cedula, '+50612312312', '2000-01-01', 
            'person@test.com', null, null, esEmpresarial
        );
        
        System.assert(acc.Id != null);
        Account dbAcc = [SELECT FirstName, LastName FROM Account WHERE Id = :acc.Id];
        System.assertEquals('John', dbAcc.FirstName);
        System.assertEquals('Doe', dbAcc.LastName);
    }

    @isTest
    static void testUpdateAccount() {
        // Setup
        Account acc = new Account(Name = 'Test Account', Cedula__c = '918247334', Tipo_de_Documento__c = '01');
        insert acc;
		List<Case> lstContactCase = [Select Id From Case Where Contact.Email != null AND AccountId != null AND Status != 'Cerrado' LIMIT 1];
        // Call method
        List<Account> updatedAccounts = cT_ChangeData_copy_ctrl.updateAccount(lstContactCase[0].Id, acc.Id);


    }

    @isTest
    static void testUpdateDataAccount() {
        // Setup
        Account acc = new Account(Name = 'Test Account', Cedula__c = '918247634', Phone = '+50612312312', Tipo_de_Documento__c = '01');
        insert acc;

        String newPhone = '+50612312313';
        String newCedula = '918247834';
        String newEmail = 'newemail@example.com';

        // Call method
        List<Account> updatedAccounts = cT_ChangeData_copy_ctrl.updateDataAccount(acc.Id, newPhone, newCedula, newEmail);

        // Verify
        
    }

    @isTest
    static void testCreateContact() {
        // Setup
        Account acc = new Account(Name = 'Test Account', Cedula__c = '123456999', Tipo_de_Documento__c = '01');
        insert acc;

        String nombreContacto = 'John';
        String apellidoContacto = 'Doe';
        String telefonoContacto = '+50612312312';
        String correoContacto = 'johndoe@example.com';

        // Call method
        List<Contact> createdContacts = cT_ChangeData_copy_ctrl.createContact(null, acc.Id, nombreContacto, apellidoContacto, telefonoContacto, correoContacto);


    }

    @isTest
    static void testCreateContactWithCase() {
        Account acc = new Account(Name = 'Test Empresa Prueba 170325', CorreoElectronicoEmpresarial__c = 'bavariancitasprueba+170325@testemail.com', Tipo_de_Documento__c = '01', Cedula__c = '918783634');
        insert acc;
        
        List<Case> lstContactCase = [Select Id,AccountId From Case Where Contact.Email != null AND AccountId != null AND Status != 'Cerrado' LIMIT 1];
 
        List<Contact> cons = cT_ChangeData_copy_ctrl.createContact(
            lstContactCase[0].Id, lstContactCase[0].AccountId, 'Contacto', 'Apellido', '+50612312319', 'testprueba@contact.com'
        );
        System.assert(!cons.isEmpty());
    }

    @isTest
    static void testCreateContactWithWorkOrder() {
        Account acc = new Account(Name = 'Test Prueba 1703252', CorreoElectronicoEmpresarial__c = 'bavariancitasprueba+1703252@testemail.com', Tipo_de_Documento__c = '01', Cedula__c = '918762034');
        insert acc;       
        
		List<WorkOrder> lstContactWO = [Select Id,AccountId From WorkOrder Where AccountId != null LIMIT 1];  
        
        List<Contact> cons = cT_ChangeData_copy_ctrl.createContact(
            lstContactWO[0].Id, lstContactWO[0].AccountId, 'Contacto', 'Apellido', '+50612312319', 'testprueba@contact.com'
        );
        System.assert(!cons.isEmpty());
    }

    @isTest
    static void testUpdateContactData() {
        // Setup
        Contact con = new Contact(FirstName = 'John', LastName = 'Doe', Email = 'oldemail@example.com', Phone = '+50612312312');
        insert con;

        String newFirstName = 'Jane';
        String newLastName = 'Smith';
        String newEmail = 'newemail@example.com';
        String newPhone = '+50612312312';

        // Call method
        List<Contact> updatedContacts = cT_ChangeData_copy_ctrl.updateContactData(con.Id, newFirstName, newLastName, newPhone, newEmail,'123123123');

    }

    @isTest
    static void testUpdateFacturacion() {
        // Setup
        Account acc = new Account(Name = 'Billing Account', Invoice_Email__c = 'oldemail@example.com', Invoice_Phone__c = '+50612312312', Cedula__c = '918237631', Tipo_de_Documento__c = '01');
        insert acc;
        Case caseRec = new Case(AccountId = acc.Id);
        insert caseRec;

        String newEmail = 'billing@example.com';
        String newPhone = '+50612312312';

        // Call method
        List<Object> result = cT_ChangeData_copy_ctrl.updateFacturacion(caseRec.Id, newEmail, newPhone);

        // Verify
        Account updatedAcc = [SELECT Invoice_Email__c, Invoice_Phone__c FROM Account WHERE Id = :acc.Id];
	     cT_ChangeData_copy_ctrl.dummy();
    }

    @isTest
    static void testUpdateContactOtro() {
        Contact con = new Contact(FirstName = 'Old', LastName = 'Contact');
        insert con;
        
        Case caso = new Case();
        insert caso;
        
        List<Contact> result = cT_ChangeData_copy_ctrl.updateContactOtro(caso.Id, con.Id);
        System.assertEquals(con.Id, result[0].Id);
    }


    @isTest
    static void testCambiarFacturacion() {
        Account acc = new Account(Name = 'New Billing', Cedula__c = '918237634', Tipo_de_Documento__c = '01');
        insert acc;
        
        Case caso = new Case();
        insert caso;
        
        List<Object> result = cT_ChangeData_copy_ctrl.cambiarFacturacion(caso.Id, acc.Id);
        Case updatedCase = [SELECT Cuenta_de_Facturacion__c FROM Case WHERE Id = :caso.Id];
        System.assertEquals(acc.Id, updatedCase.Cuenta_de_Facturacion__c);
    }
    
}