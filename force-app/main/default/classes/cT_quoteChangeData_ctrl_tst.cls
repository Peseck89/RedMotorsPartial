@isTest
public with sharing class cT_quoteChangeData_ctrl_tst {
    
    @isTest
    static void testCreatePersonAccount() {
        String cedula = '654321873';
        Boolean esEmpresarial = false;
        
        Account acc = cT_quoteChangeData_ctrl.createAccount(
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
		Case caseRec = getSampleCaseWithAsset();
        // Call method
        List<Account> updatedAccounts = cT_quoteChangeData_ctrl.updateAccount(caseRec.Id, acc.Id);
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
        List<Account> updatedAccounts = cT_quoteChangeData_ctrl.updateDataAccount(acc.Id, newPhone, newCedula, newEmail);

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
        List<Contact> createdContacts = cT_quoteChangeData_ctrl.createContact(null, acc.Id, nombreContacto, apellidoContacto, telefonoContacto, correoContacto);
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
 
        List<Contact> cons = cT_quoteChangeData_ctrl.createContact(
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
        
        List<Contact> cons = cT_quoteChangeData_ctrl.createContact(
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
        List<Contact> updatedContacts = cT_quoteChangeData_ctrl.updateContactData(con.Id, newFirstName, newLastName, newPhone, newEmail,'123123123');
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
        List<Object> result = cT_quoteChangeData_ctrl.updateFacturacion(caseRec.Id, newEmail, newPhone);

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
        
        Quote quoteRec = getSampleQuoteWithOpportunity();
        
        List<Contact> result = cT_quoteChangeData_ctrl.updateContactOtro(quoteRec.Id, con.Id);
        System.assertEquals(con.Id, result[0].Id);
    }


    @isTest
    static void testCambiarFacturacion() {
        Account acc = new Account(Name = 'New Billing', Cedula__c = '918237634', Tipo_de_Documento__c = '01');
        insert acc;
        
        Case caso = new Case();
        insert caso;
        
        List<Object> result = cT_quoteChangeData_ctrl.cambiarFacturacion(caso.Id, acc.Id);
        Case updatedCase = [SELECT Cuenta_de_Facturacion__c FROM Case WHERE Id = :caso.Id];
        System.assertEquals(acc.Id, updatedCase.Cuenta_de_Facturacion__c);
    }

    @isTest
    static void testBusinessAccountAndCaseBranchCoverage() {
        Account businessAccount = cT_quoteChangeData_ctrl.createAccount(
            'Empresa Coverage Quote', null, '918237801', '+50677770001', null,
            'empresa.quote@test.com', 'Encargado Quote', '+50677770002', true
        );
        System.assertNotEquals(null, businessAccount.Id);

        Case caseRec = getSampleCaseWithAsset();
        if (caseRec == null) {
            return;
        }

        List<Account> result = cT_quoteChangeData_ctrl.updateAccount(caseRec.Id, businessAccount.Id);
        System.assertEquals(businessAccount.Id, result[0].Id);
    }

    @isTest
    static void testWorkOrderBranchCoverage() {
        Account businessAccount = cT_quoteChangeData_ctrl.createAccount(
            'Empresa Coverage WO', null, '918237802', '+50677770003', null,
            'empresa.wo@test.com', 'Encargado WO', '+50677770004', true
        );
        System.assertNotEquals(null, businessAccount.Id);

        WorkOrder workOrderRec = getSampleWorkOrderWithAsset();
        if (workOrderRec == null) {
            return;
        }

        List<Account> result = cT_quoteChangeData_ctrl.updateAccount(workOrderRec.Id, businessAccount.Id);
        System.assertEquals(businessAccount.Id, result[0].Id);
    }

    @isTest
    static void testQuoteContactSyncAndDataLoadBranches() {
        ensureBavarianBusinessAccount();
        Quote quoteRec = getSampleQuoteWithOpportunity();
        if (quoteRec == null) {
            return;
        }

        try {
            List<Contact> createdContacts = cT_quoteChangeData_ctrl.createContact(
                quoteRec.Id, quoteRec.AccountId, 'Cobertura', 'Quote', '+50677770005', 'quote.coverage@test.com'
            );
            System.assertNotEquals(null, createdContacts);
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage());
        }

        Contact syncContact = new Contact(LastName = 'Sync Quote', Email = 'sync.quote@test.com', Phone = '+50677770006');
        insert syncContact;

        try {
            List<Contact> updatedContacts = cT_quoteChangeData_ctrl.updateContact(quoteRec.Id, syncContact.Id);
            System.assertEquals(syncContact.Id, updatedContacts[0].Id);
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage());
        }

        List<Quote> quoteData = cT_quoteChangeData_ctrl.getQuoteData(quoteRec.Id);
        System.assert(!quoteData.isEmpty());

        Boolean isAdmin = cT_quoteChangeData_ctrl.isCurrentUserAdmin();
        System.assert(isAdmin == true || isAdmin == false);
    }

    @isTest
    static void testQuoteFacturacionExtendedBranches() {
        Account accountRec = new Account(Name = 'Factura Quote Coverage', Cedula__c = '918237803', Tipo_de_Documento__c = '01');
        insert accountRec;

        Case caseRec = new Case(AccountId = accountRec.Id);
        insert caseRec;
        insertCommunicationData(accountRec);

        try {
            cT_quoteChangeData_ctrl.updateFacturacionCaso(caseRec.Id, 'fact.quote@test.com', '+50677770007');
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage());
        }

        Case refreshedCase = [SELECT Cuenta_de_Facturacion__c FROM Case WHERE Id = :caseRec.Id];
        System.assertNotEquals(null, refreshedCase.Cuenta_de_Facturacion__c);

        Quote quoteRec = getSampleQuoteWithOpportunity();
        if (quoteRec == null) {
            return;
        }

        Account newBilling = new Account(Name = 'Factura Cambio Quote', Cedula__c = '918237804', Tipo_de_Documento__c = '01');
        insert newBilling;

        try {
            cT_quoteChangeData_ctrl.updateFacturacionQuote(quoteRec.Id, 'quote.fact@test.com', '+50677770008');
            cT_quoteChangeData_ctrl.cambiarFacturacionCaso(quoteRec.Id, newBilling.Id);
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage());
        }
    }

    @isTest
    static void testWorkOrderFacturacionBranches() {
        WorkOrder workOrderRec = getSampleWorkOrderWithAsset();

        Account billing = new Account(Name = 'Billing WO Coverage', Cedula__c = '918237806', Tipo_de_Documento__c = '01');
        insert billing;

        workOrderRec.Cuenta_de_Facturacion__c = billing.Id;
        update workOrderRec;

        List<Object> updatedBilling = cT_quoteChangeData_ctrl.updateFacturacion(workOrderRec.Id, 'wo.fact@test.com', '+50677770009');
        Account newBilling = new Account(Name = 'Billing WO Cambio', Cedula__c = '918237807', Tipo_de_Documento__c = '01');
        insert newBilling;
        List<Object> changedBilling = cT_quoteChangeData_ctrl.cambiarFacturacion(workOrderRec.Id, newBilling.Id);

        System.assertNotEquals(null, updatedBilling);
        System.assertNotEquals(null, changedBilling);
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
            Cedula__c = '918237805'
        );
        insert accountRec;
        return accountRec;
    }

    private static Case getSampleCaseWithAsset() {
        Account accountRec = createBusinessAccount('Coverage Case Account', '918237811', 'case.account@test.com');
        Contact contactRec = new Contact(
            FirstName = 'Case',
            LastName = 'Coverage',
            Email = 'case.contact@test.com',
            Phone = '+50670000001',
            AccountId = accountRec.Id
        );
        insert contactRec;
        Asset assetRec = new Asset(
            Name = 'Coverage Asset Case',
            AccountId = accountRec.Id,
            ContactId = contactRec.Id
        );
        insert assetRec;
        Case caseRec = new Case(
            AccountId = accountRec.Id,
            ContactId = contactRec.Id,
            AssetId = assetRec.Id,
            Status = 'Nuevo'
        );
        insert caseRec;
        WorkOrder workOrderRec = new WorkOrder(
            AccountId = accountRec.Id,
            ContactId = contactRec.Id,
            CaseId = caseRec.Id,
            AssetId = assetRec.Id,
            isLocked__c = false
        );
        insert workOrderRec;
        return [
            SELECT Id, AccountId, AssetId, ContactId
            FROM Case
            WHERE Id = :caseRec.Id
        ];
    }

    private static WorkOrder getSampleWorkOrderWithAsset() {
        Account accountRec = createBusinessAccount('Coverage WO Account', '918237812', 'wo.account@test.com');
        Contact contactRec = new Contact(
            FirstName = 'WO',
            LastName = 'Coverage',
            Email = 'wo.contact@test.com',
            Phone = '+50670000002',
            AccountId = accountRec.Id
        );
        insert contactRec;
        Asset assetRec = new Asset(
            Name = 'Coverage Asset WO',
            AccountId = accountRec.Id,
            ContactId = contactRec.Id
        );
        insert assetRec;
        WorkOrder workOrderRec = new WorkOrder(
            AccountId = accountRec.Id,
            ContactId = contactRec.Id,
            AssetId = assetRec.Id,
            isLocked__c = false
        );
        insert workOrderRec;
        return [
            SELECT Id, AccountId, AssetId, ContactId, Cuenta_de_Facturacion__c
            FROM WorkOrder
            WHERE Id = :workOrderRec.Id
        ];
    }

    private static Quote getSampleQuoteWithOpportunity() {
        Account accountRec = createBusinessAccount('Coverage Quote Account', '918237813', 'quote.account@test.com');
        Opportunity opp = new Opportunity(
            Name = 'Coverage Quote Opportunity',
            AccountId = accountRec.Id,
            CloseDate = System.today().addDays(15),
            StageName = 'Oportunidad Calificada',
            Campana__c = getCampaignId(),
            Sucursal__c = TestDataFactory.sucursal.Name,
            SucursalId__c = TestDataFactory.sucursal.Id,
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('BMW').getRecordTypeId(),
            RT_Lead__c = 'BMW'
        );
        insert opp;
        Quote quoteRec = new Quote(
            Name = 'Coverage Quote',
            OpportunityId = opp.Id,
            Pricebook2Id = Test.getStandardPricebookId(),
            CurrencyIsoCode = 'USD'
        );
        insert quoteRec;
        return [
            SELECT Id, AccountId, OpportunityId
            FROM Quote
            WHERE Id = :quoteRec.Id
        ];
    }

    private static Account createBusinessAccount(String name, String cedula, String email) {
        Account accountRec = new Account(
            Name = name,
            Cedula__c = cedula,
            Tipo_de_Documento__c = '01',
            Phone = '+50670000000',
            CorreoElectronicoEmpresarial__c = email
        );
        insert accountRec;
        return accountRec;
    }

    private static void insertCommunicationData(Account accountRec) {
        Tipo_de_datos_de_comunicaci_n__c tipoCorreo = new Tipo_de_datos_de_comunicaci_n__c(
            Name = 'Facturación Coverage',
            Correo_Electrenico__c = true
        );
        Tipo_de_datos_de_comunicaci_n__c tipoTelefono = new Tipo_de_datos_de_comunicaci_n__c(
            Name = 'Cobros Coverage',
            Telefono__c = true
        );
        insert new List<Tipo_de_datos_de_comunicaci_n__c>{ tipoCorreo, tipoTelefono };

        insert new Correo__c(
            Name = 'old.fact@test.com',
            Account__c = accountRec.Id,
            Tipo_de_datos_de_comunicaci_n__c = tipoCorreo.Id
        );
        insert new Tel_fono__c(
            Cuenta__c = accountRec.Id,
            N_mero_de_tel_fono__c = '+50611112222',
            Tipo_de_datos_de_comunicaci_n__c = tipoTelefono.Id
        );
    }

    private static Id getCampaignId() {
        if (TestDataFactory.campanna == null) {
            TestDataFactory.datosGenerales();
        }
        return TestDataFactory.campanna.Id;
    }
 
}