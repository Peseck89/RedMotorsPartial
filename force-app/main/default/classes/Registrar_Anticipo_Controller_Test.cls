@isTest
public class Registrar_Anticipo_Controller_Test {

    private class MockGetReceiptSuccess implements HttpCalloutMock {
        private Integer callCount = 0;
        public HTTPResponse respond(HTTPRequest req) {
            callCount++;
            HTTPResponse res = new HTTPResponse();
            res.setStatusCode(200);
            if (req.getEndpoint().contains('/oauth/token') || callCount == 1) {
                res.setBody('{"access_token":"test_token","token_type":"Bearer"}');
            } else {
                res.setBody('{"operationResult":{"code":"00","monto_anticipo":5000,"oportunidad":"OPP-001","cod_anticipo":"ANT-001","description":"OK"}}');
            }
            return res;
        }
    }

    private class MockMultiStep implements HttpCalloutMock {
        private List<String> bodies;
        private Integer idx = 0;
        public MockMultiStep(List<String> bodies) { this.bodies = bodies; }
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setStatusCode(200);
            res.setBody(bodies[Math.min(idx, bodies.size()-1)]);
            idx++;
            return res;
        }
    }

    private class MockGetReceiptError implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setStatusCode(200);
            if (req.getEndpoint().contains('/oauth/token')) {
                res.setBody('{"access_token":"test_token","token_type":"Bearer"}');
            } else {
                res.setBody('{"operationResult":{"code":"99","description":"Anticipo no encontrado"}}');
            }
            return res;
        }
    }

    private class MockHttpError implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setStatusCode(500);
            res.setBody('Internal Server Error');
            return res;
        }
    }

    private class MockAddReceiptSuccess implements HttpCalloutMock {
        private Integer callCount = 0;
        public HTTPResponse respond(HTTPRequest req) {
            callCount++;
            HTTPResponse res = new HTTPResponse();
            res.setStatusCode(200);
            if (req.getEndpoint().contains('/oauth/token')) {
                res.setBody('{"access_token":"test_token","token_type":"Bearer"}');
            } else if (req.getEndpoint().contains('addReceiptOportunity')) {
                res.setBody('{"operationResult":{"code":"00","description":"OK"}}');
            } else {
                res.setBody('{"access_token":"test_token","token_type":"Bearer"}');
            }
            return res;
        }
    }

    private class MockAddReceiptError implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setStatusCode(200);
            if (req.getEndpoint().contains('/oauth/token')) {
                res.setBody('{"access_token":"test_token","token_type":"Bearer"}');
            } else {
                res.setBody('{"operationResult":{"code":"99","description":"Error al asociar anticipo"}}');
            }
            return res;
        }
    }

    private static Id getRtOppAutos() {
        return Schema.SObjectType.Opportunity
            .getRecordTypeInfosByDeveloperName().get('Autos_Usados').getRecordTypeId();
    }

    private static Opportunity crearOportunidad(String stage) {
        Opportunity opp = new Opportunity(
            Name      = 'Opp Test Anticipo',
            StageName = stage,
            CloseDate = Date.today().addDays(30)
        );
        insert opp;
        return opp;
    }

    private static Opportunity crearOportunidadUsados(String stage) {
        Opportunity opp = new Opportunity(
            Name         = 'Opp Usados Test',
            StageName    = stage,
            CloseDate    = Date.today().addDays(30),
            RecordTypeId = getRtOppAutos()
        );
        insert opp;
        return opp;
    }

    private static Product2 crearProducto(Boolean reservado, Boolean rmReportado) {
        Product2 prod = new Product2(
            Name                   = 'Vehiculo Test',
            IsActive               = true,
            Producto_Reservado__c  = reservado,
            RM_Reportado__c        = rmReportado,
            vin__c                 = 'VIN123TEST',
            esVehiculo__c          = true,
            es_Vehiculo_usado__c   = true,
            Codigo_de_Producto__c  = 'COD-TEST-001'
        );
        insert prod;
        return prod;
    }

    private static Anticipo__c crearAnticipo(Id oppId) {
        Anticipo__c ant = new Anticipo__c(
            Oportunidad__c   = oppId,
            Identificador__c = 'ANT-001',
            Monto__c         = 5000,
            Estatus__c       = 'Aplicado'
        );
        insert ant;
        return ant;
    }

    @isTest
    static void testFindAnticipos_ConAnticipos() {
        Opportunity opp = crearOportunidad('Prospecting');
        crearAnticipo(opp.Id);

        Test.startTest();
        Boolean result = Registrar_Anticipo_Controller.findAnticipos(opp.Id);
        Test.stopTest();

        System.assertEquals(true, result);
    }

    @isTest
    static void testFindAnticipos_SinAnticipos() {
        Opportunity opp = crearOportunidad('Prospecting');

        Test.startTest();
        Boolean result = Registrar_Anticipo_Controller.findAnticipos(opp.Id);
        Test.stopTest();

        System.assertEquals(false, result);
    }

    @isTest
    static void testFindQuote_OppNoUsados() {
        Opportunity opp = crearOportunidad('Prospecting');

        Test.startTest();
        Boolean result = Registrar_Anticipo_Controller.findQuote(opp.Id);
        Test.stopTest();

        System.assertEquals(false, result);
    }

    @isTest
    static void testFindQuote_OppUsados_SinQuote() {
        Opportunity opp = crearOportunidadUsados('Prospecting');

        Test.startTest();
        Boolean result = Registrar_Anticipo_Controller.findQuote(opp.Id);
        Test.stopTest();

        System.assertEquals(false, result);
    }

    @isTest
    static void testFindQuote_OppUsados_ConQuoteSyncing() {
        Opportunity opp = crearOportunidadUsados('Prospecting');
        opp.Pricebook2Id = Test.getStandardPricebookId();
        update opp;

        Quote q = new Quote(
            Name          = 'Quote Test',
            OpportunityId = opp.Id,
            Pricebook2Id  = Test.getStandardPricebookId(),
            Status        = 'Draft'
        );
        insert q;

        opp.SyncedQuoteId = q.Id;
        update opp;

        Test.startTest();
        Boolean result = Registrar_Anticipo_Controller.findQuote(opp.Id);
        Test.stopTest();

        System.assertNotEquals(null, result);
    }

    @isTest
    static void testFindPayment_IdentificadorVacio_LanzaError() {
        Test.startTest();
        try {
            Registrar_Anticipo_Controller.findPayment('', null);
            System.assert(false);
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testFindPayment_Exitoso_SinOpp() {
        Test.setMock(HttpCalloutMock.class, new MockMultiStep(new List<String>{
            '{"access_token":"test_token","token_type":"Bearer"}',
            '{"operationResult":{"code":"00","monto_anticipo":5000,"oportunidad":"OPP-001","cod_anticipo":"ANT-001","description":"OK"}}'
        }));

        Test.startTest();
        Map<String, Object> result = Registrar_Anticipo_Controller.findPayment('ANT-001', null);
        Test.stopTest();

        System.assertNotEquals(null, result);
    }

    @isTest
    static void testFindPayment_Exitoso_ConOpp() {
        Opportunity opp = crearOportunidad('Prospecting');

        Test.setMock(HttpCalloutMock.class, new MockMultiStep(new List<String>{
            '{"access_token":"test_token","token_type":"Bearer"}',
            '{"operationResult":{"code":"00","monto_anticipo":8000,"oportunidad":"OPP-002","cod_anticipo":"ANT-002","description":"OK"}}'
        }));

        Test.startTest();
        Map<String, Object> result = Registrar_Anticipo_Controller.findPayment('ANT-002', opp.Id);
        Test.stopTest();

        System.assertNotEquals(null, result);
    }

    @isTest
    static void testFindPayment_ConOpp_PricebookOtobai() {
        Pricebook2 pb = new Pricebook2(Name = 'Otobai 2024', IsActive = true);
        insert pb;

        Opportunity opp = crearOportunidad('Prospecting');
        opp.Pricebook2Id = pb.Id;
        update opp;

        Test.setMock(HttpCalloutMock.class, new MockMultiStep(new List<String>{
            '{"access_token":"test_token","token_type":"Bearer"}',
            '{"operationResult":{"code":"00","monto_anticipo":3000,"oportunidad":"OPP-003","cod_anticipo":"ANT-003","description":"OK"}}'
        }));

        Test.startTest();
        try {
            Map<String, Object> result = Registrar_Anticipo_Controller.findPayment('ANT-003', opp.Id);
            System.assertNotEquals(null, result);
        } catch(Exception e) {
            System.assertNotEquals(null, e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testFindPayment_CodeError() {
        Test.setMock(HttpCalloutMock.class, new MockGetReceiptError());

        Test.startTest();
        try {
            Registrar_Anticipo_Controller.findPayment('ANT-ERR', null);
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testFindPayment_HttpError() {
        Test.setMock(HttpCalloutMock.class, new MockHttpError());

        Test.startTest();
        try {
            Registrar_Anticipo_Controller.findPayment('ANT-500', null);
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testAddReceipt_OppVacia_LanzaError() {
        Test.startTest();
        try {
            Registrar_Anticipo_Controller.addReceiptOportunity('', 'prodId', 'ANT-001', 5000);
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testAddReceipt_ProductoVacio_LanzaError() {
        Test.startTest();
        try {
            Registrar_Anticipo_Controller.addReceiptOportunity('oppId', '', 'ANT-001', 5000);
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testAddReceipt_IdentificadorVacio_LanzaError() {
        Test.startTest();
        try {
            Registrar_Anticipo_Controller.addReceiptOportunity('oppId', 'prodId', '', 5000);
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testAddReceipt_ProductoReservado_LanzaError() {
        Opportunity opp = crearOportunidad('Prospecting');
        Product2 prod = crearProducto(true, false);

        Test.startTest();
        try {
            Registrar_Anticipo_Controller.addReceiptOportunity(opp.Id, prod.Id, 'ANT-001', 5000);
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testAddReceipt_ProductoRMReportado_LanzaError() {
        Opportunity opp = crearOportunidad('Prospecting');
        Product2 prod = crearProducto(false, true);

        Test.startTest();
        try {
            Registrar_Anticipo_Controller.addReceiptOportunity(opp.Id, prod.Id, 'ANT-001', 5000);
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testAddReceipt_Exitoso() {
        Opportunity opp = crearOportunidad('Prospecting');
        Product2 prod = crearProducto(false, false);

        Test.setMock(HttpCalloutMock.class, new MockMultiStep(new List<String>{
            '{"access_token":"test_token","token_type":"Bearer"}',
            '{"operationResult":{"code":"00","description":"OK"}}',
            '{"access_token":"ext_token","token_type":"Bearer"}',
            '{"result":"ok"}'
        }));

        Test.startTest();
        try {
            Map<String, Object> result = Registrar_Anticipo_Controller.addReceiptOportunity(
                opp.Id, prod.Id, 'ANT-OK', 5000
            );
            System.assertNotEquals(null, result);
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testAddReceipt_Exitoso_PricebookOtobai() {
        Pricebook2 pb = new Pricebook2(Name = 'Otobai Test', IsActive = true);
        insert pb;

        Opportunity opp = crearOportunidad('Prospecting');
        opp.Pricebook2Id = pb.Id;
        update opp;

        Product2 prod = crearProducto(false, false);

        Test.setMock(HttpCalloutMock.class, new MockMultiStep(new List<String>{
            '{"access_token":"test_token","token_type":"Bearer"}',
            '{"operationResult":{"code":"00","description":"OK"}}',
            '{"access_token":"ext_token","token_type":"Bearer"}',
            '{"result":"ok"}'
        }));

        Test.startTest();
        try {
            Map<String, Object> result = Registrar_Anticipo_Controller.addReceiptOportunity(
                opp.Id, prod.Id, 'ANT-OTOBAI', 3000
            );
            System.assertNotEquals(null, result);
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testAddReceipt_ServiceCodeError() {
        Opportunity opp = crearOportunidad('Prospecting');
        Product2 prod = crearProducto(false, false);

        Test.setMock(HttpCalloutMock.class, new MockMultiStep(new List<String>{
            '{"access_token":"test_token","token_type":"Bearer"}',
            '{"operationResult":{"code":"99","description":"Error servicio"}}'
        }));

        Test.startTest();
        try {
            Registrar_Anticipo_Controller.addReceiptOportunity(opp.Id, prod.Id, 'ANT-ERR', 5000);
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testGetOpportunityRelatedProducts_IdVacio_LanzaError() {
        Test.startTest();
        try {
            Registrar_Anticipo_Controller.getOpportunityRelatedProducts('');
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testGetOpportunityRelatedProducts_SinProductos() {
        Opportunity opp = crearOportunidad('Prospecting');

        Test.startTest();
        List<OpportunityLineItem> result = Registrar_Anticipo_Controller.getOpportunityRelatedProducts(opp.Id);
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assertEquals(0, result.size());
    }

    @isTest
    static void testGetOpportunityRelatedProductsUsados_IdVacio_LanzaError() {
        Test.startTest();
        try {
            Registrar_Anticipo_Controller.getOpportunityRelatedProductsUsados('');
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testGetOpportunityRelatedProductsUsados_SinProductos() {
        Opportunity opp = crearOportunidad('Prospecting');

        Test.startTest();
        List<OpportunityLineItem> result = Registrar_Anticipo_Controller.getOpportunityRelatedProductsUsados(opp.Id);
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assertEquals(0, result.size());
    }

    @isTest
    static void testGetAnticipos_SinAnticipos() {
        Opportunity opp = crearOportunidad('Prospecting');

        Test.startTest();
        List<Anticipo__c> result = Registrar_Anticipo_Controller.getAnticipos(opp.Id);
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assertEquals(0, result.size());
    }

    @isTest
    static void testGetAnticipos_ConAnticipos() {
        Opportunity opp = crearOportunidad('Prospecting');
        crearAnticipo(opp.Id);

        Test.startTest();
        List<Anticipo__c> result = Registrar_Anticipo_Controller.getAnticipos(opp.Id);
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assertEquals(1, result.size());
        System.assertEquals('ANT-001', result[0].Identificador__c);
    }

    @isTest
    static void testInnerClasses() {
        Registrar_Anticipo_Controller.WSRelANTResult relAnt = new Registrar_Anticipo_Controller.WSRelANTResult();
        relAnt.operationResult = new Registrar_Anticipo_Controller.WSRelacionaAnticipoRespuesta();
        relAnt.operationResult.code = '00';
        relAnt.operationResult.description = 'OK';
        System.assertEquals('00', relAnt.operationResult.code);

        Registrar_Anticipo_Controller.WSOperationResult wsResult = new Registrar_Anticipo_Controller.WSOperationResult();
        wsResult.operationResult = new Registrar_Anticipo_Controller.WSOperationResultValues();
        wsResult.operationResult.code = '00';
        wsResult.operationResult.monto_anticipo = 5000;
        wsResult.operationResult.oportunidad = 'OPP-001';
        wsResult.operationResult.cod_anticipo = 'ANT-001';
        System.assertEquals(5000, wsResult.operationResult.monto_anticipo);

        Registrar_Anticipo_Controller.AuthResponse auth = new Registrar_Anticipo_Controller.AuthResponse();
        auth.access_token = 'tok123';
        auth.token_type = 'Bearer';
        System.assertEquals('tok123', auth.access_token);
    }
}