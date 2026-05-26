@IsTest
private class cT_ChangeData_ctrl_tst {

    private static final String RT_EMPRESARIAL = '0120P000000aqmZQAQ';
    private static final String RT_PERSONA     = '0120P000000aqoLQAQ';


    private class DummyWsMock implements WebServiceMock {
        public void doInvoke(
            Object stub,
            Object request,
            Map<String, Object> response,
            String endpoint,
            String soapAction,
            String requestName,
            String responseNamespace,
            String responseName,
            String responseType
        ) {
            response.put(responseName, null);
        }
    }

    private class DummyHttpMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{}');
            return res;
        }
    }

    private static void setMocks() {
        Test.setMock(WebServiceMock.class, new DummyWsMock());
        Test.setMock(HttpCalloutMock.class, new DummyHttpMock());
    }

    // ---------------------------------------------------------
    // HELPERS
    // ---------------------------------------------------------
    private static String uniq(String prefix) {
        return prefix + '_' + String.valueOf(System.now().getTime()) + '_' + String.valueOf(Math.abs(Crypto.getRandomInteger()));
    }

    private static String digits(Integer len) {
        String s = '';
        while (s.length() < len) {
            s += String.valueOf(Math.abs(Crypto.getRandomInteger()));
        }
        return s.substring(0, len);
    }

    private static String firstActivePick(Schema.SObjectField fld) {
        for (Schema.PicklistEntry pe : fld.getDescribe().getPicklistValues()) {
            if (pe.isActive()) {
                return pe.getValue();
            }
        }
        return null;
    }

    private static Boolean hasField(Schema.SObjectType sType, String apiName) {
        return sType.getDescribe().fields.getMap().containsKey(apiName);
    }

    private static void putIfExists(SObject sobj, String fieldApi, Object value) {
        if (value == null) return;
        Map<String, Schema.SObjectField> fmap = sobj.getSObjectType().getDescribe().fields.getMap();
        if (fmap.containsKey(fieldApi)) {
            sobj.put(fieldApi, value);
        }
    }

    private static Boolean recordTypeExists(String rtId) {
        return [SELECT COUNT() FROM RecordType WHERE SObjectType = 'Account' AND Id = :rtId] > 0;
    }

    @TestSetup
    static void setupData() {
        setMocks();

        Account bavarian = new Account();
        bavarian.Name = 'Bavarian Citas Test';
        putIfExists(bavarian, 'Cedula__c', digits(9));
        if (hasField(Account.SObjectType, 'Tipo_de_Documento__c')) {
            String td = firstActivePick(Account.Tipo_de_Documento__c);
            if (td != null) bavarian.put('Tipo_de_Documento__c', td);
        }
        putIfExists(bavarian, 'CorreoElectronicoEmpresarial__c', 'bavariancitas@testemail.com');
        putIfExists(bavarian, 'Phone', digits(8));
        insert bavarian;
    }

    private static Account crearAccountEmpresarial() {
        Account acc = new Account();
        acc.Name = uniq('ACC');

        if (hasField(Account.SObjectType, 'Tipo_de_Documento__c')) {
            String td = firstActivePick(Account.Tipo_de_Documento__c);
            if (td != null) acc.put('Tipo_de_Documento__c', td);
        }

        putIfExists(acc, 'Cedula__c', digits(9));
        putIfExists(acc, 'CorreoElectronicoEmpresarial__c', uniq('empresa') + '@test.com');
        putIfExists(acc, 'Phone', digits(8));
        putIfExists(acc, 'Invoice_Email__c', uniq('fact') + '@test.com');
        putIfExists(acc, 'Invoice_Phone__c', digits(8));
        insert acc;
        return acc;
    }

    private static Contact crearContacto(Id accountId) {
        Contact c = new Contact();
        c.FirstName = 'Nombre';
        c.LastName  = uniq('Contacto');
        c.AccountId = accountId;
        c.Email     = uniq('contacto') + '@test.com';
        c.Phone     = digits(8);
        insert c;
        return c;
    }

    private static Asset crearAsset(Id accountId, Id contactId, Decimal km) {
        Asset a = new Asset();
        a.Name      = uniq('Asset');
        a.AccountId = accountId;
        a.ContactId = contactId;

        if (hasField(Asset.SObjectType, 'Status')) {
            String st = firstActivePick(Asset.Status);
            if (st != null) a.Status = st;
        }

        putIfExists(a, 'Kilometros__c', km);
        insert a;
        return a;
    }

    private static Case crearCase(Id accountId, Id assetId, Id contactId) {
        Case c = new Case();
        c.AccountId = accountId;
        c.AssetId   = assetId;
        c.ContactId = contactId;
        c.Subject   = uniq('Caso');

        String st = firstActivePick(Case.Status);
        if (st != null) c.Status = st;

        String origin = firstActivePick(Case.Origin);
        if (origin != null) c.Origin = origin;

        putIfExists(c, 'Cuenta_de_Facturacion__c', accountId);

        insert c;
        return c;
    }

    private static WorkOrder crearWorkOrder(Id caseId, Id accountId, Id assetId, Id contactId) {
        WorkOrder wo = new WorkOrder();
        wo.CaseId    = caseId;
        wo.AccountId = accountId;
        wo.AssetId   = assetId;
        wo.ContactId = contactId;
        wo.Subject   = uniq('WO');

        String st = firstActivePick(WorkOrder.Status);
        if (st != null) wo.Status = st;

        putIfExists(wo, 'Cuenta_de_Facturacion__c', accountId);
        putIfExists(wo, 'isLocked__c', false);

        insert wo;
        return wo;
    }

    private static Historial_Kilometraje__c crearHistorial(Id assetId, Decimal ultimoKm, Decimal nuevoKm) {
        Historial_Kilometraje__c h = new Historial_Kilometraje__c();
        putIfExists(h, 'Vehiculo__c', assetId);
        putIfExists(h, 'UltimoKilometraje__c', ultimoKm);
        putIfExists(h, 'NuevoKilometraje__c', nuevoKm);
        putIfExists(h, 'UsuarioQueRealizaElCambio__c', UserInfo.getUserId());
        insert h;
        return h;
    }

    private static Quote crearQuote(Id accountId, Id contactId) {
        Id stdPbId = Test.getStandardPricebookId();
        try {
            update new Pricebook2(Id = stdPbId, IsActive = true);
        } catch (Exception e) {
        }

        Opportunity opp = new Opportunity();
        opp.Name      = uniq('Opp');
        opp.AccountId = accountId;
        opp.CloseDate = Date.today().addDays(10);

        String stage = firstActivePick(Opportunity.StageName);
        opp.StageName = (stage == null ? 'Prospecting' : stage);

        if (hasField(Opportunity.SObjectType, 'Pricebook2Id')) {
            opp.Pricebook2Id = stdPbId;
        }
        insert opp;

        Quote q = new Quote();
        q.Name          = uniq('Quote');
        q.OpportunityId = opp.Id;
        q.ContactId     = contactId;
        if (hasField(Quote.SObjectType, 'Pricebook2Id')) {
            q.Pricebook2Id = stdPbId;
        }
        insert q;

        return q;
    }

    @IsTest
    static void test_createAccount_existente() {
        setMocks();

        Account acc = crearAccountEmpresarial();
        update new Account(Id = acc.Id, Cedula__c = '123456789');

        Test.startTest();
        Account res = cT_ChangeData_ctrl.createAccount(
            'Empresa X',
            null,
            '123456789',
            digits(8),
            null,
            'existente@test.com',
            'Encargado',
            digits(8),
            true
        );
        Test.stopTest();

        System.assertEquals(acc.Id, res.Id);
    }

    @IsTest
    static void test_createAccount_nueva_empresarial() {
        setMocks();

        if (!recordTypeExists(RT_EMPRESARIAL)) {
            System.assert(true);
            return;
        }

        Test.startTest();
        Account res = cT_ChangeData_ctrl.createAccount(
            'Empresa Nueva',
            null,
            digits(9),
            digits(8),
            null,
            'empresa.nueva@test.com',
            'Encargado Test',
            digits(8),
            true
        );
        Test.stopTest();

        System.assertNotEquals(null, res.Id);
    }

    @IsTest
    static void test_updateAccount_conCase() {
        setMocks();

        Account accViejo = crearAccountEmpresarial();
        Account accNuevo = crearAccountEmpresarial();
        Case caso        = crearCase(accViejo.Id, null, null);

        Test.startTest();
        List<Account> result = cT_ChangeData_ctrl.updateAccount(caso.Id, accNuevo.Id);
        Test.stopTest();

        System.assertEquals(1, result.size());
        System.assertEquals(accNuevo.Id, result[0].Id);
    }


    @IsTest
    static void test_updateDataAccount() {
        setMocks();

        Account acc = crearAccountEmpresarial();

        Test.startTest();
        List<Account> result = cT_ChangeData_ctrl.updateDataAccount(
            acc.Id,
            '88885555',
            '111222333',
            'nuevo@test.com'
        );
        Test.stopTest();

        Account db = [
            SELECT Phone, Cedula__c, CorreoElectronicoEmpresarial__c
            FROM Account
            WHERE Id = :acc.Id
        ];

        System.assertEquals('88885555', db.Phone);
        System.assertEquals('111222333', db.Cedula__c);
        System.assertEquals(1, result.size());
    }

    @IsTest
    static void test_createContact_sinRecordId() {
        setMocks();

        Account acc = crearAccountEmpresarial();

        Test.startTest();
        List<Contact> result = cT_ChangeData_ctrl.createContact(
            null,
            acc.Id,
            'María',
            'López',
            digits(8),
            'maria@test.com'
        );
        Test.stopTest();

        System.assertEquals(0, result.size());
    }

    @IsTest
    static void test_createContact_conCase() {
        setMocks();

        Account acc = crearAccountEmpresarial();
        Contact con = crearContacto(acc.Id);
        Asset asset = crearAsset(acc.Id, con.Id, 1000);
        Case caso   = crearCase(acc.Id, asset.Id, con.Id);
        crearWorkOrder(caso.Id, acc.Id, asset.Id, con.Id);

        Test.startTest();
        List<Contact> result = cT_ChangeData_ctrl.createContact(
            caso.Id,
            acc.Id,
            'Pedro',
            'Gómez',
            digits(8),
            'pedro@test.com'
        );
        Test.stopTest();

        Case casoDb = [SELECT ContactId FROM Case WHERE Id = :caso.Id];
        Asset assetDb = [SELECT ContactId FROM Asset WHERE Id = :asset.Id];

        System.assertEquals(1, result.size());
        System.assertEquals(result[0].Id, casoDb.ContactId);
        System.assertEquals(result[0].Id, assetDb.ContactId);
    }

    @IsTest
    static void test_createContact_conWorkOrder() {
        setMocks();

        Account acc = crearAccountEmpresarial();
        Contact con = crearContacto(acc.Id);
        Asset asset = crearAsset(acc.Id, con.Id, 1000);
        Case caso   = crearCase(acc.Id, asset.Id, con.Id);
        WorkOrder wo = crearWorkOrder(caso.Id, acc.Id, asset.Id, con.Id);

        Test.startTest();
        List<Contact> result = cT_ChangeData_ctrl.createContact(
            wo.Id,
            acc.Id,
            'Luis',
            'Hernandez',
            digits(8),
            'luis@test.com'
        );
        Test.stopTest();

        WorkOrder woDb = [SELECT ContactId FROM WorkOrder WHERE Id = :wo.Id];
        Case casoDb    = [SELECT ContactId FROM Case WHERE Id = :caso.Id];
        Asset assetDb  = [SELECT ContactId FROM Asset WHERE Id = :asset.Id];

        System.assertEquals(1, result.size());
        System.assertEquals(result[0].Id, woDb.ContactId);
        System.assertEquals(result[0].Id, casoDb.ContactId);
        System.assertEquals(result[0].Id, assetDb.ContactId);
    }

    @IsTest
    static void test_updateContactData() {
        setMocks();

        Account acc = crearAccountEmpresarial();
        Contact c   = crearContacto(acc.Id);

        Test.startTest();
        List<Contact> result = cT_ChangeData_ctrl.updateContactData(
            c.Id,
            'New',
            'Surname',
            '99990000',
            'new@test.com',
            '123'
        );
        Test.stopTest();

        Contact updated = [SELECT FirstName, LastName, Email, Phone FROM Contact WHERE Id = :c.Id];
        System.assertEquals('New', updated.FirstName);
        System.assertEquals('Surname', updated.LastName);
        System.assertEquals('new@test.com', updated.Email);
        System.assertEquals('99990000', updated.Phone);
        System.assertEquals(1, result.size());
    }

    @IsTest
    static void test_updateContactOtro_conCase() {
        setMocks();

        Account acc   = crearAccountEmpresarial();
        Contact con   = crearContacto(acc.Id);
        Contact nuevo = crearContacto(acc.Id);
        Asset asset   = crearAsset(acc.Id, con.Id, 1000);
        Case caso     = crearCase(acc.Id, asset.Id, con.Id);
        crearWorkOrder(caso.Id, acc.Id, asset.Id, con.Id);

        Test.startTest();
        List<Contact> result = cT_ChangeData_ctrl.updateContactOtro(caso.Id, nuevo.Id);
        Test.stopTest();

        Case updatedCase = [SELECT ContactId FROM Case WHERE Id = :caso.Id];
        Asset updatedAsset = [SELECT ContactId FROM Asset WHERE Id = :asset.Id];

        System.assertEquals(nuevo.Id, updatedCase.ContactId);
        System.assertEquals(nuevo.Id, updatedAsset.ContactId);
        System.assertEquals(nuevo.Id, result[0].Id);
    }

    @IsTest
    static void test_updateContactOtro_conWorkOrder() {
        setMocks();

        Account acc   = crearAccountEmpresarial();
        Contact con   = crearContacto(acc.Id);
        Contact nuevo = crearContacto(acc.Id);
        Asset asset   = crearAsset(acc.Id, con.Id, 1000);
        Case caso     = crearCase(acc.Id, asset.Id, con.Id);
        WorkOrder wo  = crearWorkOrder(caso.Id, acc.Id, asset.Id, con.Id);

        Test.startTest();
        List<Contact> result = cT_ChangeData_ctrl.updateContactOtro(wo.Id, nuevo.Id);
        Test.stopTest();

        WorkOrder updatedWo = [SELECT ContactId FROM WorkOrder WHERE Id = :wo.Id];
        Case updatedCase    = [SELECT ContactId FROM Case WHERE Id = :caso.Id];
        Asset updatedAsset  = [SELECT ContactId FROM Asset WHERE Id = :asset.Id];

        System.assertEquals(nuevo.Id, updatedWo.ContactId);
        System.assertEquals(nuevo.Id, updatedCase.ContactId);
        System.assertEquals(nuevo.Id, updatedAsset.ContactId);
        System.assertEquals(nuevo.Id, result[0].Id);
    }

    @IsTest
    static void test_updateContact_conCase() {
        setMocks();

        Account acc = crearAccountEmpresarial();
        update new Account(
            Id = acc.Id,
            Name = 'Empresa Actualizada',
            Phone = '89990000',
            CorreoElectronicoEmpresarial__c = 'empresa.actualizada@test.com'
        );

        Contact con = crearContacto(acc.Id);
        Asset asset = crearAsset(acc.Id, con.Id, 1000);
        Case caso   = crearCase(acc.Id, asset.Id, con.Id);

        Test.startTest();
        List<Contact> result = cT_ChangeData_ctrl.updateContact(caso.Id, con.Id);
        Test.stopTest();

        Contact db = [SELECT FirstName, LastName, Email, Phone FROM Contact WHERE Id = :con.Id];
        System.assertEquals('Empresa Actualizada', db.LastName);
        System.assertEquals('empresa.actualizada@test.com', db.Email);
        System.assertEquals('89990000', db.Phone);
        System.assertEquals(1, result.size());
    }

    @IsTest
    static void test_updateContact_conWorkOrder() {
        setMocks();

        Account acc = crearAccountEmpresarial();
        update new Account(
            Id = acc.Id,
            Name = 'Empresa WO',
            Phone = '87770000',
            CorreoElectronicoEmpresarial__c = 'empresa.wo@test.com'
        );

        Contact con = crearContacto(acc.Id);
        Asset asset = crearAsset(acc.Id, con.Id, 1000);
        Case caso   = crearCase(acc.Id, asset.Id, con.Id);
        WorkOrder wo = crearWorkOrder(caso.Id, acc.Id, asset.Id, con.Id);

        Test.startTest();
        List<Contact> result = cT_ChangeData_ctrl.updateContact(wo.Id, con.Id);
        Test.stopTest();

        Contact db = [SELECT LastName, Email, Phone FROM Contact WHERE Id = :con.Id];
        System.assertEquals('Empresa WO', db.LastName);
        System.assertEquals('empresa.wo@test.com', db.Email);
        System.assertEquals('87770000', db.Phone);
        System.assertEquals(1, result.size());
    }

    @IsTest
    static void test_updateContact_recordIdVacio() {
        setMocks();

        Account acc = crearAccountEmpresarial();
        Contact con = crearContacto(acc.Id);

        Test.startTest();
        List<Contact> result = cT_ChangeData_ctrl.updateContact(null, con.Id);
        Test.stopTest();

        System.assertEquals(1, result.size());
        System.assertEquals(con.Id, result[0].Id);
    }

    @IsTest
    static void test_updateAssetkilometraje_exitoso() {
        setMocks();

        Account acc = crearAccountEmpresarial();
        Contact con = crearContacto(acc.Id);
        Asset asset = crearAsset(acc.Id, con.Id, 10000);
        Case caso   = crearCase(acc.Id, asset.Id, con.Id);
        WorkOrder wo = crearWorkOrder(caso.Id, acc.Id, asset.Id, con.Id);

        Test.startTest();
        cT_ChangeData_ctrl.updateAssetkilometraje(asset.Id, 20000, caso.Id);
        Test.stopTest();

        Asset updatedAsset = [SELECT Kilometros__c FROM Asset WHERE Id = :asset.Id];
        Case updatedCase   = [SELECT Kilometraje__c FROM Case WHERE Id = :caso.Id];
        WorkOrder updatedWo = [SELECT Kilometros__c FROM WorkOrder WHERE Id = :wo.Id];

        System.assertEquals(20000, updatedAsset.Kilometros__c);
        System.assertEquals(20000, updatedCase.Kilometraje__c);
        System.assertEquals(20000, updatedWo.Kilometros__c);
    }

    @IsTest
    static void test_updateAssetkilometraje_menorIgual_lanzaExcepcion() {
        setMocks();

        Account acc = crearAccountEmpresarial();
        Contact con = crearContacto(acc.Id);
        Asset asset = crearAsset(acc.Id, con.Id, 10000);
        Case caso   = crearCase(acc.Id, asset.Id, con.Id);

        Boolean exceptionLanzada = false;

        Test.startTest();
        try {
            cT_ChangeData_ctrl.updateAssetkilometraje(asset.Id, 5000, caso.Id);
        } catch (AuraHandledException e) {
            exceptionLanzada = true;
        }
        Test.stopTest();

        System.assertEquals(true, exceptionLanzada);
    }

    @IsTest
    static void test_isCurrentUserAdmin() {
        setMocks();

        Test.startTest();
        Boolean result = cT_ChangeData_ctrl.isCurrentUserAdmin();
        Test.stopTest();

        System.assertNotEquals(null, result);
    }

    @IsTest
    static void test_getHistorialVehiculo() {
        setMocks();

        Account acc = crearAccountEmpresarial();
        Contact con = crearContacto(acc.Id);
        Asset asset = crearAsset(acc.Id, con.Id, 1000);
        Historial_Kilometraje__c hist = crearHistorial(asset.Id, 1000, 1500);

        Test.startTest();
        List<Historial_Kilometraje__c> result = cT_ChangeData_ctrl.getHistorialVehiculo(asset.Id);
        Test.stopTest();

        Boolean found = false;
        for (Historial_Kilometraje__c h : result) {
            if (h.Id == hist.Id) {
                found = true;
                break;
            }
        }
        System.assertEquals(true, found);
    }

    @IsTest
    static void test_updateAssetAddress() {
        setMocks();

        Account acc = crearAccountEmpresarial();
        Contact con = crearContacto(acc.Id);
        Asset asset = crearAsset(acc.Id, con.Id, 1000);
        Case caso   = crearCase(acc.Id, asset.Id, con.Id);

        Test.startTest();
        cT_ChangeData_ctrl.updateAssetAddress(asset.Id, caso.Id, 'San Jose', 'Central', 'Calle 1');
        Test.stopTest();

        Asset updatedAsset = [SELECT State, City, Street, Country FROM Asset WHERE Id = :asset.Id];
        Case updatedCase = [SELECT Actualizo_direccion__c FROM Case WHERE Id = :caso.Id];

        System.assertEquals('San Jose', updatedAsset.State);
        System.assertEquals('Central', updatedAsset.City);
        System.assertEquals('Calle 1', updatedAsset.Street);
        System.assertEquals('Costa Rica', updatedAsset.Country);
        System.assertEquals(true, updatedCase.Actualizo_direccion__c);
    }

    @IsTest
    static void test_updateKilometraje_aumento() {
        setMocks();

        Account acc = crearAccountEmpresarial();
        Contact con = crearContacto(acc.Id);
        Asset asset = crearAsset(acc.Id, con.Id, 10000);
        Case caso   = crearCase(acc.Id, asset.Id, con.Id);
        WorkOrder wo = crearWorkOrder(caso.Id, acc.Id, asset.Id, con.Id);

        Historial_Kilometraje__c historial = crearHistorial(asset.Id, 10000, 15000);

        Test.startTest();
        cT_ChangeData_ctrl.updateKilometraje(historial.Id, 20000, asset.Id, caso.Id);
        Test.stopTest();

        Asset updatedAsset = [SELECT Kilometros__c FROM Asset WHERE Id = :asset.Id];
        Case updatedCase   = [SELECT Kilometraje__c FROM Case WHERE Id = :caso.Id];
        WorkOrder updatedWo = [SELECT Kilometros__c FROM WorkOrder WHERE Id = :wo.Id];

        System.assertEquals(20000, updatedAsset.Kilometros__c);
        System.assertEquals(20000, updatedCase.Kilometraje__c);
        System.assertEquals(20000, updatedWo.Kilometros__c);
    }

    @IsTest
    static void test_updateKilometraje_reduccion() {
        setMocks();

        Account acc = crearAccountEmpresarial();
        Contact con = crearContacto(acc.Id);
        Asset asset = crearAsset(acc.Id, con.Id, 10000);
        Case caso   = crearCase(acc.Id, asset.Id, con.Id);
        WorkOrder wo = crearWorkOrder(caso.Id, acc.Id, asset.Id, con.Id);

        Historial_Kilometraje__c historial = crearHistorial(asset.Id, 5000, 15000);

        Test.startTest();
        cT_ChangeData_ctrl.updateKilometraje(historial.Id, 8000, asset.Id, caso.Id);
        Test.stopTest();

        Asset updatedAsset = [SELECT Kilometros__c FROM Asset WHERE Id = :asset.Id];
        Case updatedCase   = [SELECT Kilometraje__c FROM Case WHERE Id = :caso.Id];
        WorkOrder updatedWo = [SELECT Kilometros__c FROM WorkOrder WHERE Id = :wo.Id];

        System.assertEquals(8000, updatedAsset.Kilometros__c);
        System.assertEquals(8000, updatedCase.Kilometraje__c);
        System.assertEquals(8000, updatedWo.Kilometros__c);
    }

    @IsTest
    static void test_updateKilometraje_menorAlUltimo_lanzaExcepcion() {
        setMocks();

        Account acc = crearAccountEmpresarial();
        Contact con = crearContacto(acc.Id);
        Asset asset = crearAsset(acc.Id, con.Id, 10000);
        Case caso   = crearCase(acc.Id, asset.Id, con.Id);

        Historial_Kilometraje__c historial = crearHistorial(asset.Id, 10000, 15000);

        Boolean exceptionLanzada = false;

        Test.startTest();
        try {
            cT_ChangeData_ctrl.updateKilometraje(historial.Id, 3000, asset.Id, caso.Id);
        } catch (AuraHandledException e) {
            exceptionLanzada = true;
        }
        Test.stopTest();

        System.assertEquals(true, exceptionLanzada);
    }

    @IsTest
    static void test_updateFacturacion_conCase() {
        setMocks();

        Account acc = crearAccountEmpresarial();
        Case caso   = crearCase(acc.Id, null, null);
        update new Case(Id = caso.Id, Cuenta_de_Facturacion__c = acc.Id);

        Test.startTest();
        List<Object> result = cT_ChangeData_ctrl.updateFacturacion(caso.Id, 'fact.case@test.com', '71111111');
        Test.stopTest();

        Case updatedCase = [SELECT Id, Cuenta_de_Facturacion__c FROM Case WHERE Id = :caso.Id];
        System.assertEquals(acc.Id, updatedCase.Cuenta_de_Facturacion__c);
        System.assertNotEquals(null, result);
    }

    @IsTest
    static void test_updateFacturacion_conWorkOrder() {
        setMocks();

        Account acc = crearAccountEmpresarial();
        Contact con = crearContacto(acc.Id);
        Asset asset = crearAsset(acc.Id, con.Id, 1000);
        Case caso   = crearCase(acc.Id, asset.Id, con.Id);
        WorkOrder wo = crearWorkOrder(caso.Id, acc.Id, asset.Id, con.Id);
        update new WorkOrder(Id = wo.Id, Cuenta_de_Facturacion__c = acc.Id);

        Test.startTest();
        cT_ChangeData_ctrl.updateFacturacion(wo.Id, 'fact.wo@test.com', '72222222');
        Test.stopTest();

        WorkOrder updatedWo = [SELECT Id, Cuenta_de_Facturacion__c FROM WorkOrder WHERE Id = :wo.Id];
        System.assertEquals(acc.Id, updatedWo.Cuenta_de_Facturacion__c);
    }

    @IsTest
    static void test_cambiarFacturacion_conCase() {
        setMocks();

        Account accViejo = crearAccountEmpresarial();
        Account accNuevo = crearAccountEmpresarial();
        Case caso        = crearCase(accViejo.Id, null, null);

        Test.startTest();
        cT_ChangeData_ctrl.cambiarFacturacion(caso.Id, accNuevo.Id);
        Test.stopTest();

        Case updatedCase = [SELECT Cuenta_de_Facturacion__c FROM Case WHERE Id = :caso.Id];
        System.assertEquals(accNuevo.Id, updatedCase.Cuenta_de_Facturacion__c);
    }

    @IsTest
    static void test_cambiarFacturacion_conWorkOrder() {
        setMocks();

        Account acc = crearAccountEmpresarial();
        Account accN = crearAccountEmpresarial();
        Contact con = crearContacto(acc.Id);
        Asset asset = crearAsset(acc.Id, con.Id, 1000);
        Case caso   = crearCase(acc.Id, asset.Id, con.Id);
        WorkOrder wo = crearWorkOrder(caso.Id, acc.Id, asset.Id, con.Id);

        Test.startTest();
        cT_ChangeData_ctrl.cambiarFacturacion(wo.Id, accN.Id);
        Test.stopTest();

        WorkOrder updatedWo = [SELECT Cuenta_de_Facturacion__c FROM WorkOrder WHERE Id = :wo.Id];
        System.assertEquals(accN.Id, updatedWo.Cuenta_de_Facturacion__c);
    }

    @IsTest
    static void test_cambiarFacturacionCaso_conWorkOrders() {
        setMocks();

        Account acc = crearAccountEmpresarial();
        Account accN = crearAccountEmpresarial();
        Contact con = crearContacto(acc.Id);
        Asset asset = crearAsset(acc.Id, con.Id, 1000);
        Case caso   = crearCase(acc.Id, asset.Id, con.Id);
        WorkOrder wo = crearWorkOrder(caso.Id, acc.Id, asset.Id, con.Id);

        Test.startTest();
        cT_ChangeData_ctrl.cambiarFacturacionCaso(caso.Id, accN.Id, true);
        Test.stopTest();

        Case updatedCase = [SELECT Cuenta_de_Facturacion__c FROM Case WHERE Id = :caso.Id];
        WorkOrder updatedWo = [SELECT Cuenta_de_Facturacion__c FROM WorkOrder WHERE Id = :wo.Id];

        System.assertEquals(accN.Id, updatedCase.Cuenta_de_Facturacion__c);
        System.assertEquals(accN.Id, updatedWo.Cuenta_de_Facturacion__c);
    }

    @IsTest
    static void test_cambiarFacturacionCaso_sinActualizarWO() {
        setMocks();

        Account acc = crearAccountEmpresarial();
        Account accN = crearAccountEmpresarial();
        Case caso = crearCase(acc.Id, null, null);

        Test.startTest();
        cT_ChangeData_ctrl.cambiarFacturacionCaso(caso.Id, accN.Id, false);
        Test.stopTest();

        Case updatedCase = [SELECT Cuenta_de_Facturacion__c FROM Case WHERE Id = :caso.Id];
        System.assertEquals(accN.Id, updatedCase.Cuenta_de_Facturacion__c);
    }

    @IsTest
    static void test_updateFacturacionCaso_sinCuentaFact() {
        setMocks();

        Account acc = crearAccountEmpresarial();
        Contact con = crearContacto(acc.Id);
        Asset asset = crearAsset(acc.Id, con.Id, 1000);
        Case caso   = crearCase(acc.Id, asset.Id, con.Id);
        WorkOrder wo = crearWorkOrder(caso.Id, acc.Id, asset.Id, con.Id);

        update new Case(Id = caso.Id, Cuenta_de_Facturacion__c = null);

        Test.startTest();
        cT_ChangeData_ctrl.updateFacturacionCaso(caso.Id, 'fact@test.com', '73333333');
        Test.stopTest();

        Case updatedCase = [SELECT Cuenta_de_Facturacion__c, AccountId FROM Case WHERE Id = :caso.Id];
        WorkOrder updatedWo = [SELECT Cuenta_de_Facturacion__c FROM WorkOrder WHERE Id = :wo.Id];

        System.assertEquals(updatedCase.AccountId, updatedCase.Cuenta_de_Facturacion__c);
        System.assertEquals(updatedCase.AccountId, updatedWo.Cuenta_de_Facturacion__c);
    }

    @IsTest
    static void test_updateFacturacionCaso_conCuentaFact() {
        setMocks();

        Account acc = crearAccountEmpresarial();
        Account accF = crearAccountEmpresarial();
        Case caso = crearCase(acc.Id, null, null);
        update new Case(Id = caso.Id, Cuenta_de_Facturacion__c = accF.Id);

        Test.startTest();
        cT_ChangeData_ctrl.updateFacturacionCaso(caso.Id, 'nuevo@fact.com', '74444444');
        Test.stopTest();

        Case updatedCase = [SELECT Cuenta_de_Facturacion__c FROM Case WHERE Id = :caso.Id];
        System.assertEquals(accF.Id, updatedCase.Cuenta_de_Facturacion__c);
    }

    @IsTest
    static void test_updateFacturacionQuote() {
        setMocks();

        Account acc = crearAccountEmpresarial();
        Contact con = crearContacto(acc.Id);
        Quote q = crearQuote(acc.Id, con.Id);

        Test.startTest();
        cT_ChangeData_ctrl.updateFacturacionQuote(q.Id, 'quote@fact.com', '75555555');
        Test.stopTest();

        Quote updatedQuote = [SELECT Cuenta_de_facturaci_n2__c, AccountId FROM Quote WHERE Id = :q.Id];
        System.assertEquals(updatedQuote.AccountId, updatedQuote.Cuenta_de_facturaci_n2__c);
    }

    @IsTest
    static void test_getWorkOrderData_Quote() {
        setMocks();

        Account acc = crearAccountEmpresarial();
        Contact con = crearContacto(acc.Id);
        Quote q = crearQuote(acc.Id, con.Id);

        Test.startTest();
        List<Quote> result = cT_ChangeData_ctrl.getWorkOrderData(q.Id);
        Test.stopTest();

        System.assertEquals(1, result.size());
        System.assertEquals(q.Id, result[0].Id);
    }
}
