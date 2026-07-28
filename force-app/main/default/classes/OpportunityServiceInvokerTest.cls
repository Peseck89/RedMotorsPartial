@isTest
private class OpportunityServiceInvokerTest {
    private static List<String> paymentRequestBodies = new List<String>();

    // ─────────────────────────────────────────────────────────────
    // HTTP Mock: respuesta 200 exitosa
    // ─────────────────────────────────────────────────────────────
	    private class MockHttpSuccess implements HttpCalloutMock {
	        public HTTPResponse respond(HTTPRequest req) {
	            System.assertEquals(false, req == null, 'El mock exitoso debe recibir request');
            capturePaymentRequest(req);
	            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"operationResult":{"code":"200","description":"OK"}}');
            res.setHeader('Content-Type', 'application/json');
            return res;
        }
    }

    // ─────────────────────────────────────────────────────────────
    // HTTP Mock: respuesta de error (500)
    // ─────────────────────────────────────────────────────────────
	    private class MockHttpError implements HttpCalloutMock {
	        public HTTPResponse respond(HTTPRequest req) {
	            System.assertEquals(false, req == null, 'El mock de error debe recibir request');
            capturePaymentRequest(req);
	            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setBody('{"error":"Internal Server Error"}');
            return res;
        }
    }

    // ─────────────────────────────────────────────────────────────
    // HTTP Mock: JSON inválido para cubrir rama de parseo
    // ─────────────────────────────────────────────────────────────
	    private class MockHttpInvalidJson implements HttpCalloutMock {
	        public HTTPResponse respond(HTTPRequest req) {
	            System.assertEquals(false, req == null, 'El mock de JSON inválido debe recibir request');
            capturePaymentRequest(req);
	            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('INVALID_JSON_BODY');
            return res;
        }
    }

    // ─────────────────────────────────────────────────────────────
    // Utilidades de datos de prueba
    // ─────────────────────────────────────────────────────────────
    private static Product2 createProduct(String vin) {
        Product2 prod = new Product2(
            Name                  = 'Vehículo Test',
            VIN__c                = vin,
            IsActive              = true,
            Codigo_de_Producto__c = 'COD-' + vin
        );
        insert prod;
        return prod;
    }

    private static void createPBE(Id productId, Id pricebookId) {
        List<PricebookEntry> existingStd = [
            SELECT Id FROM PricebookEntry
            WHERE Pricebook2Id = :Test.getStandardPricebookId()
            AND Product2Id = :productId LIMIT 1
        ];
        if (existingStd.isEmpty()) {
            insert new PricebookEntry(
                Pricebook2Id = Test.getStandardPricebookId(),
                Product2Id   = productId,
                UnitPrice    = 100,
                IsActive     = true
            );
        }

        if (pricebookId != Test.getStandardPricebookId()) {
            List<PricebookEntry> existingCustom = [
                SELECT Id FROM PricebookEntry
                WHERE Pricebook2Id = :pricebookId
                AND Product2Id = :productId LIMIT 1
            ];
            if (existingCustom.isEmpty()) {
                insert new PricebookEntry(
                    Pricebook2Id = pricebookId,
                    Product2Id   = productId,
                    UnitPrice    = 100,
                    IsActive     = true
                );
            }
        }
    }

    private static Pricebook2 createPricebook(String name) {
        Pricebook2 pb = new Pricebook2(Name = name, IsActive = true);
        insert pb;
        return pb;
    }

    private static Empresa__c createEmpresa(String companyCode) {
        Empresa__c empresa = new Empresa__c(
            Name = companyCode,
            Codigo__c = companyCode,
            Codigo_ERP__c = companyCode,
            Nombre_Legal__c = companyCode + ' Legal',
            Activa__c = true
        );
        insert empresa;
        return empresa;
    }

    private static void capturePaymentRequest(HttpRequest req) {
        String requestBody = req.getBody();
        if (requestBody != null && requestBody.startsWith('{')) {
            paymentRequestBodies.add(requestBody);
        }
    }

    private static Map<String, Object> getLastPaymentPayload() {
        System.assertEquals(1, paymentRequestBodies.size(), 'Debe existir exactamente un request funcional de pago.');
        return (Map<String, Object>) JSON.deserializeUntyped(paymentRequestBodies[0]);
    }

    private static void createOLI(Id oppId, Id pricebookId, Id productId) {
        PricebookEntry pbe = [
            SELECT Id FROM PricebookEntry
            WHERE Pricebook2Id = :pricebookId AND Product2Id = :productId LIMIT 1
        ];
        insert new OpportunityLineItem(
            OpportunityId    = oppId,
            PricebookEntryId = pbe.Id,
            Quantity         = 1,
            UnitPrice        = 100
        );
    }

    private static Id getPersonAccountRecordTypeId() {
        List<RecordType> rts = [
            SELECT Id FROM RecordType
            WHERE SObjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1
        ];
        return rts.isEmpty() ? null : rts[0].Id;
    }

    // ─────────────────────────────────────────────────────────────
    // TEST 1: Lista nula → retorno temprano
    // ─────────────────────────────────────────────────────────────
    @isTest
    static void testSendOpportunity_NullList() {
	        Test.startTest();
	        OpportunityServiceInvoker.sendOpportunity(null);
	        Test.stopTest();
	        System.assertEquals(0, Limits.getCallouts(), 'Lista nula no debe ejecutar callouts');
    }

    // ─────────────────────────────────────────────────────────────
    // TEST 2: Lista vacía → retorno temprano
    // ─────────────────────────────────────────────────────────────
    @isTest
    static void testSendOpportunity_EmptyList() {
	        Test.startTest();
	        OpportunityServiceInvoker.sendOpportunity(new List<Id>());
	        Test.stopTest();
	        System.assertEquals(0, Limits.getCallouts(), 'Lista vacía no debe ejecutar callouts');
    }

    // ─────────────────────────────────────────────────────────────
    // TEST 3: PersonAccount + Pricebook RMBAVARIAN + HTTP 200
    // ─────────────────────────────────────────────────────────────
    @isTest
    static void testSendOpportunity_PersonAccount_Success() {
        Pricebook2 pb = createPricebook('RMBAVARIAN');
        Empresa__c empresa = createEmpresa('RMBAVARIAN');

        Account acc = new Account(
            FirstName    = 'Juan',
            LastName     = 'Pérez',
            RecordTypeId = getPersonAccountRecordTypeId(),
            Phone        = '3001234567',
            PersonEmail  = 'juan@test.com'
        );
        insert acc;

        Opportunity opp = new Opportunity(
            Name         = 'Opp Test PersonAccount',
            AccountId    = acc.Id,
            StageName    = 'Prospecting',
            CloseDate    = Date.today().addDays(30),
            Pricebook2Id = pb.Id,
            Empresa_Operadora__c = empresa.Id
        );
        insert opp;

        Product2 prod = createProduct('VIN123456');
        createPBE(prod.Id, pb.Id);
        createOLI(opp.Id, pb.Id, prod.Id);

        Test.setMock(HttpCalloutMock.class, new MockHttpSuccess());
        Test.startTest();
        OpportunityServiceInvoker.sendOpportunity(new List<Id>{ opp.Id });
	        Test.stopTest();

	        System.assertEquals(1,
	            [SELECT COUNT() FROM OpportunityLineItem WHERE OpportunityId = :opp.Id],
	            'La oportunidad PersonAccount debe conservar su línea para el envío');
        System.assertEquals('RMBAVARIAN', getLastPaymentPayload().get('compania'),
            'El lookup Bavarian debe conservar la compañía RMBAVARIAN en el payload.');
    }

    // ─────────────────────────────────────────────────────────────
    // TEST 4: BusinessAccount + Pricebook con nombre "Otobai"
    // ─────────────────────────────────────────────────────────────
    @isTest
    static void testSendOpportunity_BusinessAccount_OtobaiPricebook() {
        Pricebook2 pb = createPricebook('Otobai Premium');
        Empresa__c empresa = createEmpresa('RMOTOBAI');

        Account acc = new Account(
            Name                            = 'Empresa XYZ',
            Phone                           = '6011234567',
            CorreoElectronicoEmpresarial__c = 'empresa@xyz.com'
        );
        insert acc;

        Opportunity opp = new Opportunity(
            Name         = 'Opp Otobai',
            AccountId    = acc.Id,
            StageName    = 'Prospecting',
            CloseDate    = Date.today().addDays(30),
            Pricebook2Id = pb.Id,
            Empresa_Operadora__c = empresa.Id
        );
        insert opp;

        Product2 prod = createProduct('VIN654321');
        createPBE(prod.Id, pb.Id);
        createOLI(opp.Id, pb.Id, prod.Id);

        Test.setMock(HttpCalloutMock.class, new MockHttpSuccess());
        Test.startTest();
        OpportunityServiceInvoker.sendOpportunity(new List<Id>{ opp.Id });
	        Test.stopTest();

	        System.assertEquals('Otobai Premium',
	            [SELECT Pricebook2.Name FROM Opportunity WHERE Id = :opp.Id].Pricebook2.Name,
	            'Debe usar una lista de precios Otobai para cubrir esa rama');
        System.assertEquals('RMOTOBAI', getLastPaymentPayload().get('compania'),
            'El lookup Otobai debe conservar la compañía RMOTOBAI en el payload.');
    }

    // ─────────────────────────────────────────────────────────────
    // TEST 5: PersonAccount + HTTP 500
    // ─────────────────────────────────────────────────────────────
    @isTest
    static void testSendOpportunity_PersonAccount_HttpError() {
        Pricebook2 pb = createPricebook('RMBAVARIAN');

        Account acc = new Account(
            FirstName    = 'Ana',
            LastName     = 'López',
            RecordTypeId = getPersonAccountRecordTypeId(),
            Phone        = '3107654321',
            PersonEmail  = 'ana@test.com'
        );
        insert acc;

        Opportunity opp = new Opportunity(
            Name         = 'Opp Error Test',
            AccountId    = acc.Id,
            StageName    = 'Prospecting',
            CloseDate    = Date.today().addDays(30),
            Pricebook2Id = pb.Id
        );
        insert opp;

        Product2 prod = createProduct('VIN999888');
        createPBE(prod.Id, pb.Id);
        createOLI(opp.Id, pb.Id, prod.Id);

        Test.setMock(HttpCalloutMock.class, new MockHttpError());
        Test.startTest();
        OpportunityServiceInvoker.sendOpportunity(new List<Id>{ opp.Id });
	        Test.stopTest();

	        System.assertEquals(1,
	            [SELECT COUNT() FROM OpportunityLineItem WHERE OpportunityId = :opp.Id],
	            'La oportunidad debe seguir disponible aunque el servicio devuelva HTTP 500');
    }

    // ─────────────────────────────────────────────────────────────
    // TEST 6: JSON inválido → cubre rama de parseo con excepción
    // ─────────────────────────────────────────────────────────────
    @isTest
    static void testSendOpportunity_InvalidJsonResponse() {
        Pricebook2 pb = createPricebook('RMBAVARIAN');

        Account acc = new Account(
            FirstName    = 'Carlos',
            LastName     = 'Torres',
            RecordTypeId = getPersonAccountRecordTypeId(),
            Phone        = '3201112233',
            PersonEmail  = 'carlos@test.com'
        );
        insert acc;

        Opportunity opp = new Opportunity(
            Name         = 'Opp Invalid JSON',
            AccountId    = acc.Id,
            StageName    = 'Prospecting',
            CloseDate    = Date.today().addDays(30),
            Pricebook2Id = pb.Id
        );
        insert opp;

        Product2 prod = createProduct('VIN777666');
        createPBE(prod.Id, pb.Id);
        createOLI(opp.Id, pb.Id, prod.Id);

        Test.setMock(HttpCalloutMock.class, new MockHttpInvalidJson());
        Test.startTest();
        try {
            OpportunityServiceInvoker.sendOpportunity(new List<Id>{ opp.Id });
        } catch (Exception e) {
            // Excepción esperada por JSON inválido
        }
	        Test.stopTest();

	        System.assertEquals(1,
	            [SELECT COUNT() FROM OpportunityLineItem WHERE OpportunityId = :opp.Id],
	            'La oportunidad debe seguir con línea aun si la respuesta no es JSON válido');
    }

    // ─────────────────────────────────────────────────────────────
    // TEST 7: BusinessAccount + Pricebook estándar no debe caer por descarte
    // ─────────────────────────────────────────────────────────────
    @isTest
    static void testSendOpportunity_BusinessAccount_StandardPricebook() {
        Account acc = new Account(
            Name                            = 'Empresa Estándar',
            Phone                           = '6009998877',
            CorreoElectronicoEmpresarial__c = 'estandar@test.com'
        );
        insert acc;

        Opportunity opp = new Opportunity(
            Name         = 'Opp Pricebook Estándar',
            AccountId    = acc.Id,
            StageName    = 'Prospecting',
            CloseDate    = Date.today().addDays(30),
            Pricebook2Id = Test.getStandardPricebookId()
        );
        insert opp;

        Product2 prod = createProduct('VIN111222');
        createPBE(prod.Id, Test.getStandardPricebookId());
        createOLI(opp.Id, Test.getStandardPricebookId(), prod.Id);

        Test.setMock(HttpCalloutMock.class, new MockHttpSuccess());
        Test.startTest();
        try {
            OpportunityServiceInvoker.sendOpportunity(new List<Id>{ opp.Id });
            System.assert(false, 'Un Pricebook desconocido no debe caer por descarte en Bavarian.');
        } catch (AuraHandledException e) {
            System.assertNotEquals(null, e.getMessage(), 'Debe lanzarse una excepción controlada.');
        }
	        Test.stopTest();

	        System.assertEquals(Test.getStandardPricebookId(),
	            [SELECT Pricebook2Id FROM Opportunity WHERE Id = :opp.Id].Pricebook2Id,
	            'Debe cubrir oportunidad con pricebook estándar');
        System.assertEquals(0, paymentRequestBodies.size(),
            'Un Pricebook desconocido no debe llegar al callout de pago.');
	    }

    @isTest
    static void lookupPekingStopsBeforePaymentCallout() {
        Pricebook2 pb = createPricebook('PEKING Dólares');
        Empresa__c empresa = createEmpresa('RMPEKING');

        Account acc = new Account(
            Name = 'Empresa PEKING',
            Phone = '6001112233',
            CorreoElectronicoEmpresarial__c = 'peking@test.com'
        );
        insert acc;

        Opportunity opp = new Opportunity(
            Name = 'Opp PEKING',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Pricebook2Id = pb.Id,
            Empresa_Operadora__c = empresa.Id
        );
        insert opp;

        Product2 prod = createProduct('VINPEKING');
        createPBE(prod.Id, pb.Id);
        createOLI(opp.Id, pb.Id, prod.Id);

        Test.setMock(HttpCalloutMock.class, new MockHttpSuccess());
        Test.startTest();
        try {
            OpportunityServiceInvoker.sendOpportunity(new List<Id>{ opp.Id });
            System.assert(false, 'PEKING debe detenerse antes del callout mientras no exista contrato confirmado.');
        } catch (AuraHandledException e) {
            System.assertNotEquals(null, e.getMessage(), 'Debe lanzarse una excepción controlada.');
        }
        Test.stopTest();

        System.assertEquals(0, paymentRequestBodies.size(),
            'PEKING no debe ejecutar callout de pago sin contrato confirmado.');
    }

    @isTest
    static void lookupPekingTakesPriorityOverLegacyOtobaiPricebook() {
        Pricebook2 pb = createPricebook('Otobai Premium');
        Empresa__c empresa = createEmpresa('RMPEKING');

        Account acc = new Account(
            Name = 'Empresa Prioridad PEKING',
            Phone = '6001112244',
            CorreoElectronicoEmpresarial__c = 'prioridad.peking@test.com'
        );
        insert acc;

        Opportunity opp = new Opportunity(
            Name = 'Opp Prioridad PEKING',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Pricebook2Id = pb.Id,
            Empresa_Operadora__c = empresa.Id
        );
        insert opp;

        Product2 prod = createProduct('VINPEKPRIO');
        createPBE(prod.Id, pb.Id);
        createOLI(opp.Id, pb.Id, prod.Id);

        Test.setMock(HttpCalloutMock.class, new MockHttpSuccess());
        Test.startTest();
        try {
            OpportunityServiceInvoker.sendOpportunity(new List<Id>{ opp.Id });
            System.assert(false, 'El lookup PEKING debe ganar sobre el Pricebook Otobai.');
        } catch (AuraHandledException e) {
            System.assertNotEquals(null, e.getMessage(), 'Debe lanzarse una excepción controlada.');
        }
        Test.stopTest();

        System.assertEquals(0, paymentRequestBodies.size(),
            'La contradicción lookup PEKING / Pricebook Otobai no debe ejecutar callout.');
    }
	}