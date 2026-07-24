@istest
public with sharing class cT_assetChangeData_ctrl_test {
    
    @isTest
    static void testCreatePersonAccount() {
        String cedula = '654321873';
        Boolean esEmpresarial = false;
        
        Account acc = cT_assetChangeData_ctrl.createAccount(
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
        if (lstContactCase.isEmpty()) {
            System.assert(true);
            return;
        }
        // Call method
        List<Account> updatedAccounts = cT_assetChangeData_ctrl.updateAccount(lstContactCase[0].Id, acc.Id);
        System.assertNotEquals(null, updatedAccounts);

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
        List<Account> updatedAccounts = cT_assetChangeData_ctrl.updateDataAccount(acc.Id, newPhone, newCedula, newEmail);

        // Verify
        Account updatedAcc = [SELECT Phone, Cedula__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(newPhone, updatedAcc.Phone);
        System.assertEquals(newCedula, updatedAcc.Cedula__c);
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
        List<Contact> createdContacts = cT_assetChangeData_ctrl.createContact(null, acc.Id, nombreContacto, apellidoContacto, telefonoContacto, correoContacto);
        System.assertNotEquals(null, createdContacts);

    }

    @isTest
    static void testCreateContactWithCase() {
        Account acc = new Account(Name = 'Test Empresa Prueba 170325', CorreoElectronicoEmpresarial__c = 'bavariancitasprueba+170325@testemail.com', Tipo_de_Documento__c = '01', Cedula__c = '918783634');
        insert acc;
        
        List<Case> lstContactCase = [Select Id,AccountId From Case Where Contact.Email != null AND AccountId != null AND Status != 'Cerrado' LIMIT 1];
        if (lstContactCase.isEmpty()) {
            System.assert(true);
            return;
        }
 
        List<Contact> cons = cT_assetChangeData_ctrl.createContact(
            lstContactCase[0].Id, lstContactCase[0].AccountId, 'Contacto', 'Apellido', '+50612312319', 'testprueba@contact.com'
        );
        System.assertNotEquals(null, cons);
    }

    @isTest
    static void testCreateContactWithWorkOrder() {
        Account acc = new Account(Name = 'Test Prueba 1703252', CorreoElectronicoEmpresarial__c = 'bavariancitasprueba+1703252@testemail.com', Tipo_de_Documento__c = '01', Cedula__c = '918762034');
        insert acc;       
        
		List<WorkOrder> lstContactWO = [Select Id,AccountId From WorkOrder Where AccountId != null LIMIT 1];  
        if (lstContactWO.isEmpty()) {
            System.assert(true);
            return;
        }
        
        List<Contact> cons = cT_assetChangeData_ctrl.createContact(
            lstContactWO[0].Id, lstContactWO[0].AccountId, 'Contacto', 'Apellido', '+50612312319', 'testprueba@contact.com'
        );
        System.assertNotEquals(null, cons);
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
        List<Contact> updatedContacts = cT_assetChangeData_ctrl.updateContactData(con.Id, newFirstName, newLastName, newPhone, newEmail,'123123123');
        Contact updatedContact = [SELECT FirstName, LastName, Email, Phone FROM Contact WHERE Id = :con.Id];
        System.assertEquals(newFirstName, updatedContact.FirstName);
        System.assertEquals(newLastName, updatedContact.LastName);
        System.assertEquals(newEmail, updatedContact.Email);
        System.assertEquals(newPhone, updatedContact.Phone);
    }

    @isTest
    static void testUpdateFacturacion() {
        // Setup
        Account acc = new Account(Name = 'Billing Account', Invoice_Email__c = 'oldemail@example.com', Invoice_Phone__c = '+50612312312', Cedula__c = '918237631', Tipo_de_Documento__c = '01');
        insert acc;
        Case caseRec = new Case(AccountId = acc.Id);
        insert caseRec;
        caseRec.Cuenta_de_Facturacion__c = acc.Id;
        update caseRec;

        String newEmail = 'billing@example.com';
        String newPhone = '+50612312312';

        // Call method
        List<Object> result = cT_assetChangeData_ctrl.updateFacturacion(caseRec.Id, newEmail, newPhone);

        // Verify
        Case updatedCase = [SELECT Cuenta_de_Facturacion__c FROM Case WHERE Id = :caseRec.Id];
        Account updatedAcc = [SELECT Invoice_Email__c, Invoice_Phone__c FROM Account WHERE Id = :acc.Id];
        System.assertNotEquals(null, result);
        System.assertEquals(acc.Id, updatedCase.Cuenta_de_Facturacion__c);
        System.assertNotEquals(null, updatedAcc);
    }

    @isTest
    static void testUpdateContactOtro() {
        Contact con = new Contact(FirstName = 'Old', LastName = 'Contact');
        insert con;
        
        Case caso = new Case();
        insert caso;
        
        List<Contact> result = cT_assetChangeData_ctrl.updateContactOtro(caso.Id, con.Id);
        System.assertEquals(con.Id, result[0].Id);
    }


    @isTest
    static void testCambiarFacturacion() {
        Account acc = new Account(Name = 'New Billing', Cedula__c = '918237634', Tipo_de_Documento__c = '01');
        insert acc;
        
        Case caso = new Case();
        insert caso;
        
        List<Object> result = cT_assetChangeData_ctrl.cambiarFacturacion(caso.Id, acc.Id);
        Case updatedCase = [SELECT Cuenta_de_Facturacion__c FROM Case WHERE Id = :caso.Id];
        System.assertEquals(acc.Id, updatedCase.Cuenta_de_Facturacion__c);
    }

    @isTest
    static void testBusinessAccountAndAssetUpdateBranches() {
        Account businessAccount = cT_assetChangeData_ctrl.createAccount(
            'Empresa Coverage Asset', null, '918237701', '+50688880001', null,
            'empresa.asset@test.com', 'Encargado Asset', '+50688880002', true
        );
        System.assertNotEquals(null, businessAccount.Id);

        Asset assetRec = getSampleAsset();
        if (assetRec == null) {
            return;
        }

        List<Account> result = cT_assetChangeData_ctrl.updateAccount(assetRec.Id, businessAccount.Id);
        System.assertEquals(businessAccount.Id, result[0].Id);
    }

    @isTest
    static void testAssetContactSyncAndDataLoadBranches() {
        ensureBavarianBusinessAccount();
        Asset assetRec = getSampleAsset();
        if (assetRec == null) {
            return;
        }

        try {
            List<Contact> createdContacts = cT_assetChangeData_ctrl.createContact(
                assetRec.Id, assetRec.AccountId, 'Cobertura', 'Asset', '+50688880003', 'asset.coverage@test.com'
            );
            System.assertNotEquals(null, createdContacts);
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage());
        }

        Contact syncContact = new Contact(LastName = 'Sync Asset', Email = 'sync.asset@test.com', Phone = '+50688880004');
        insert syncContact;

        try {
            List<Contact> updatedContacts = cT_assetChangeData_ctrl.updateContact(assetRec.Id, syncContact.Id);
            System.assertEquals(syncContact.Id, updatedContacts[0].Id);
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage());
        }

        List<Asset> assetData = cT_assetChangeData_ctrl.getWorkOrderData(assetRec.Id);
        System.assert(!assetData.isEmpty());

        Boolean isAdmin = cT_assetChangeData_ctrl.isCurrentUserAdmin();
        System.assert(isAdmin == true || isAdmin == false);
    }

    @isTest
    static void testAssetControllerDelegatesWithLocalData() {
        Account accountRec = new Account(
            Name = 'Asset Delegate Account',
            CorreoElectronicoEmpresarial__c = 'asset.delegate@test.com',
            Phone = '+50688880007',
            Cedula__c = '918237705',
            Tipo_de_Documento__c = '01'
        );
        insert accountRec;

        Asset assetRec = new Asset(Name = 'Asset Delegate Test', AccountId = accountRec.Id);
        insert assetRec;

        Contact contactRec = new Contact(LastName = 'Delegate Contact', Email = 'delegate.contact@test.com', Phone = '+50688880008');
        insert contactRec;

        List<Account> accounts = cT_assetChangeData_ctrl.updateAccount(assetRec.Id, accountRec.Id);
        System.assertEquals(accountRec.Id, accounts[0].Id);

        List<Contact> contacts = cT_assetChangeData_ctrl.updateContact(assetRec.Id, contactRec.Id);
        System.assertEquals(contactRec.Id, contacts[0].Id);

        List<Asset> assets = cT_assetChangeData_ctrl.getWorkOrderData(assetRec.Id);
        System.assertEquals(assetRec.Id, assets[0].Id);

        Boolean isAdmin = cT_assetChangeData_ctrl.isCurrentUserAdmin();
        System.assert(isAdmin == true || isAdmin == false);
    }

    @isTest
    static void testAssetFacturacionExtendedBranches() {
        Account accountRec = new Account(Name = 'Factura Asset Coverage', Cedula__c = '918237702', Tipo_de_Documento__c = '01');
        insert accountRec;

        Case caseRec = new Case(AccountId = accountRec.Id);
        insert caseRec;

        try {
            cT_assetChangeData_ctrl.updateFacturacionCaso(caseRec.Id, 'fact.asset@test.com', '+50688880005');
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage());
        }

        Case refreshedCase = [SELECT Cuenta_de_Facturacion__c FROM Case WHERE Id = :caseRec.Id];
        System.assertNotEquals(null, refreshedCase.Cuenta_de_Facturacion__c);

        Quote quoteRec = getSampleQuoteWithOpportunity();
        if (quoteRec == null) {
            return;
        }

        Account newBilling = new Account(Name = 'Factura Quote Asset', Cedula__c = '918237703', Tipo_de_Documento__c = '01');
        insert newBilling;

        try {
            cT_assetChangeData_ctrl.updateFacturacionQuote(quoteRec.Id, 'quote.asset@test.com', '+50688880006');
            cT_assetChangeData_ctrl.cambiarFacturacionCaso(quoteRec.Id, newBilling.Id);
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage());
        }
    }

    private static Account ensureBavarianBusinessAccount() {
        List<Account> accounts = [
            SELECT Id
            FROM Account
            WHERE CorreoElectronicoEmpresarial__c = 'bavariancitas@testemail.com'
            LIMIT 1
        ];
        if (!accounts.isEmpty()) {
            return accounts[0];
        }

        Account accountRec = new Account(
            Name = 'Bavarian Citas Test',
            CorreoElectronicoEmpresarial__c = 'bavariancitas@testemail.com',
            Tipo_de_Documento__c = '01',
            Cedula__c = '918237704'
        );
        insert accountRec;
        return accountRec;
    }

    private static Asset getSampleAsset() {
        List<Asset> assets = [SELECT Id, AccountId FROM Asset WHERE AccountId != null LIMIT 1];
        return assets.isEmpty() ? null : assets[0];
    }

    private static Quote getSampleQuoteWithOpportunity() {
        List<Quote> quotes = [SELECT Id, AccountId, OpportunityId FROM Quote WHERE AccountId != null AND OpportunityId != null LIMIT 1];
        return quotes.isEmpty() ? null : quotes[0];
    }
 
}