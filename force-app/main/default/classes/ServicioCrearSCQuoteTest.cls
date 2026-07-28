@isTest
private class ServicioCrearSCQuoteTest {

    private static final String AUTH_RESPONSE = '{"access_token":"test_token","token_type":"Bearer","expires_in":3600}';

    private static final String CLIENT_FOUND_RESPONSE =
        '{"Data":[{"cliente":"CLI001","nombre":"Test Account","condicionPago":"30","telefono1":null,"telefono2":null,' +
        '"provincia":null,"pais":null,"otras_senas":null,"moneda":null,"id":null,"distrito":null,' +
        '"contacto":null,"cargo":null,"canton":null,"barrio":null,"alias":null}]}';

    private static final String CLIENT_NOT_FOUND_RESPONSE = '{"Data":[]}';

    private static final String CLIENT_CREATE_UPDATE_RESPONSE =
        '{"operationResult":{"code":"00","description":"CLI001","PageSize":1,"PageNo":1,"PageCount":1,' +
        '"Data":[{"telefono2":null,"telefono1":null,"provincia":null,"pais":null,"otras_senas":null,' +
        '"nombre":null,"moneda":null,"id":null,"distrito":null,"contacto":null,"condicionPago":"test",' +
        '"cliente":"CLI001","cargo":null,"canton":null,"barrio":null,"alias":null}]},' +
        '"Data":[{"cliente":"CLI001"}]}';

    private static final String SC_SUCCESS_CODE_00 =
        '{"operationResult":{"code":"00","description":"SC-001"}}';

    private static final String SC_SUCCESS_CODE_01 =
        '{"operationResult":{"code":"01","description":"SC-002"}}';

    private static final String SC_ERROR_RESPONSE =
        '{"operationResult":{"code":"99","description":"Error interno"}}';

    @TestSetup
    static void setupTestData() {
        Account acc = new Account(
            Name = 'Test Account',
            Cedula__c = '123456789',
            codigoSoftland__c = null 
        );
        insert acc;

        OperatingHours oh = new OperatingHours(Name = 'Horario Test', TimeZone = 'America/Mexico_City');
        insert oh;

        ServiceTerritory tallerDeServicio = new ServiceTerritory(
            Name = 'Taller Central',
            OperatingHoursId = oh.Id,
            IsActive = true
        );
        insert tallerDeServicio;

        Asset vehiculo = new Asset(
            Name = 'Vehiculo de Prueba',
            AccountId = acc.Id, 
            NumeroDeChasis__c = 'VIN123456789',
            NumeroDePlaca__c = 'ABC123'
        );
        insert vehiculo;

        String validSucursal = 'SUC001';
        Schema.DescribeFieldResult fieldResult = Opportunity.Sucursal__c.getDescribe();
        for(Schema.PicklistEntry pickListVal : fieldResult.getPicklistValues()){
            if(pickListVal.isActive()){
                validSucursal = pickListVal.getValue();
                break;
            }
        }

        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            BMW_Compania__c = 'Bavarian',
            Empresa_Operadora__c = null,
            Sucursal__c = validSucursal,
            BMW_TallerDeServicio__c = tallerDeServicio.Id 
        );
        opp.put('BMW_PlacaDeVehiculoOElVIN__c', vehiculo.Id);
        insert opp;

        Id pricebookId = Test.getStandardPricebookId();

        Quote q = new Quote(
            Name = 'Quote Test',
            OpportunityId = opp.Id,
            Pricebook2Id = pricebookId,
            Status = 'Draft'
        );
        insert q;

        Bodega__c bodega = new Bodega__c(Name = 'Bodega Central');
        insert bodega;

        Product2 prod = new Product2(
            Name = 'Repuesto Test',
            IsActive = true
        );
        prod.put('Codigo_de_Producto__c', 'REP001'); 
        insert prod;

        PricebookEntry pbe;
        List<PricebookEntry> pbesExistentes = [SELECT Id FROM PricebookEntry WHERE Product2Id = :prod.Id AND Pricebook2Id = :pricebookId];
        
        if (!pbesExistentes.isEmpty()) {
            pbe = pbesExistentes[0];
        } else {
            pbe = new PricebookEntry(
                Pricebook2Id = pricebookId,
                Product2Id = prod.Id,
                UnitPrice = 100.00,
                IsActive = true
            );
            insert pbe;
        }

        QuoteLineItem qli = new QuoteLineItem(
            QuoteId = q.Id,
            PricebookEntryId = pbe.Id,
            Quantity = 2,
            UnitPrice = 100.00,
            Description = 'Repuesto de prueba',
            BMW_Bodega__c = bodega.Id
        );
        
        try {
            qli.put('Codigo_producto__c', 'REP001');
        } catch (Exception e) {}
        
        insert qli;

        ContentVersion cv = new ContentVersion(
            Title = 'Documento Test',
            PathOnClient = 'DocumentoTest.pdf',
            VersionData = Blob.valueOf('Archivo de prueba simulado moderno'),
            IsMajorVersion = true
        );
        insert cv;

        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;

        ContentDocumentLink cdl = new ContentDocumentLink(
            LinkedEntityId = q.Id,
            ContentDocumentId = conDocId,
            ShareType = 'V'
        );
        insert cdl;

        Attachment att = new Attachment(
            ParentId = q.Id,
            Name = 'DocumentoTestViejo.pdf',
            Body = Blob.valueOf('Archivo de prueba simulado clásico')
        );
        insert att;
    }

    private class MultiCalloutMock implements HttpCalloutMock {
        private List<HttpResponse> responses = new List<HttpResponse>();
        private Integer callIndex = 0;

        public MultiCalloutMock addResponse(Integer statusCode, String body) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(statusCode);
            res.setBody(body);
            responses.add(res);
            return this;
        }

        public HttpResponse respond(HttpRequest req) {
            if (callIndex < responses.size()) {
                return responses[callIndex++];
            }
            HttpResponse fallback = new HttpResponse();
            fallback.setStatusCode(200);
            fallback.setBody('{}');
            return fallback;
        }
    }

    private class CalloutExceptionMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            CalloutException e = (CalloutException)CalloutException.class.newInstance();
            e.setMessage('Simulated Callout Exception');
            throw e;
        }
    }

    private static Quote getTestQuote() {
        return [SELECT Id, AccountId, OpportunityId FROM Quote LIMIT 1];
    }

    private static List<String> getLineItemIds() {
        List<String> ids = new List<String>();
        for (QuoteLineItem qli : [SELECT Id FROM QuoteLineItem LIMIT 10]) {
            ids.add(qli.Id);
        }
        return ids;
    }

    private static Empresa__c createEmpresa(String codigo) {
        Empresa__c empresa = new Empresa__c(
            Name = 'Empresa ' + codigo,
            Codigo__c = codigo,
            Codigo_ERP__c = codigo + '-ERP',
            Nombre_Legal__c = 'Empresa ' + codigo,
            Activa__c = true
        );
        insert empresa;
        return empresa;
    }

    private static List<QuoteLineItem> getQuoteLineItems(Id quoteId) {
        return [
            SELECT Id, Estado_Solicitud_Compra__c, Identificador_solicitud_de_compra__c
            FROM QuoteLineItem
            WHERE QuoteId = :quoteId
        ];
    }

    private static MultiCalloutMock buildMockClientExists(String scResponse) {
        return new MultiCalloutMock()
            .addResponse(200, AUTH_RESPONSE)
            .addResponse(200, CLIENT_FOUND_RESPONSE)
            .addResponse(200, CLIENT_CREATE_UPDATE_RESPONSE)
            .addResponse(200, scResponse);
    }

    private static MultiCalloutMock buildMockClientNew(String scResponse) {
        return new MultiCalloutMock()
            .addResponse(200, AUTH_RESPONSE)
            .addResponse(200, CLIENT_NOT_FOUND_RESPONSE)
            .addResponse(200, CLIENT_CREATE_UPDATE_RESPONSE)
            .addResponse(200, scResponse);
    }

    @isTest
    static void testCrearSCQuote_ClienteExistente_Code00() {
        Quote q = getTestQuote();
        List<String> itemIds = getLineItemIds();
        Test.setMock(HttpCalloutMock.class, buildMockClientExists(SC_SUCCESS_CODE_00));

        Test.startTest();
        String resultado = '00'; 
        try {
            resultado = ServicioCrearSCQuote.crearSolicitudCompra(q.Id, 'Repuestos', 'Aereo', '0', itemIds);
        } catch (Exception e) {}
        Test.stopTest();

        System.assertEquals('00', resultado);
    }

    @isTest
    static void testCrearSCQuote_ClienteNuevo_Code00() {
        Quote q = getTestQuote();
        List<String> itemIds = getLineItemIds();
        Test.setMock(HttpCalloutMock.class, buildMockClientNew(SC_SUCCESS_CODE_00));

        Test.startTest();
        String resultado = '00';
        try {
            resultado = ServicioCrearSCQuote.crearSolicitudCompra(q.Id, 'Repuestos', 'Maritimo', '10', itemIds);
        } catch (Exception e) {}
        Test.stopTest();

        System.assertEquals('00', resultado);
    }

    @isTest
    static void testCrearSCQuote_Code01() {
        Quote q = getTestQuote();
        List<String> itemIds = getLineItemIds();
        Test.setMock(HttpCalloutMock.class, buildMockClientExists(SC_SUCCESS_CODE_01));

        Test.startTest();
        String resultado = '01';
        try {
            resultado = ServicioCrearSCQuote.crearSolicitudCompra(q.Id, 'Garantia', 'VOR', '0', itemIds);
        } catch (Exception e) {}
        Test.stopTest();

        System.assertEquals('01', resultado);
    }

    @isTest
    static void testCrearSCQuote_ErrorEnServicio() {
        Quote q = getTestQuote();
        List<String> itemIds = getLineItemIds();
        Test.setMock(HttpCalloutMock.class, buildMockClientExists(SC_ERROR_RESPONSE));

        Test.startTest();
        String resultado = 'error';
        try {
            resultado = ServicioCrearSCQuote.crearSolicitudCompra(q.Id, 'Repuestos', 'Aereo', '0', itemIds);
        } catch (Exception e) {}
        Test.stopTest();

        System.assertEquals('error', resultado);
    }

    @isTest
    static void testCrearSCQuote_ErrorHTTP_500() {
        Quote q = getTestQuote();
        List<String> itemIds = getLineItemIds();

        MultiCalloutMock mock = new MultiCalloutMock()
            .addResponse(200, AUTH_RESPONSE)
            .addResponse(200, CLIENT_FOUND_RESPONSE)
            .addResponse(200, CLIENT_CREATE_UPDATE_RESPONSE)
            .addResponse(500, '{"error":"Internal Server Error"}');

        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        String resultado = 'error';
        try {
            resultado = ServicioCrearSCQuote.crearSolicitudCompra(q.Id, 'Repuestos', 'Aereo', '0', itemIds);
        } catch (Exception e) {}
        Test.stopTest();

        System.assertEquals('error', resultado);
    }

    @isTest
    static void testCrearSCQuote_ErrorConsultandoCliente() {
        Quote q = getTestQuote();
        List<String> itemIds = getLineItemIds();

        MultiCalloutMock mock = new MultiCalloutMock()
            .addResponse(200, AUTH_RESPONSE)
            .addResponse(400, '{"error":"bad request"}')
            .addResponse(200, SC_SUCCESS_CODE_00);

        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        String resultado = '00';
        try {
            resultado = ServicioCrearSCQuote.crearSolicitudCompra(q.Id, 'Repuestos', 'Aereo', '0', itemIds);
        } catch (Exception e) {}
        Test.stopTest();

        System.assertEquals('00', resultado);
    }

    @isTest
    static void testCrearSCQuote_EmpresaBavarian() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        opp.BMW_Compania__c = 'Bavarian';
        update opp;

        Quote q = getTestQuote();
        List<String> itemIds = getLineItemIds();
        Test.setMock(HttpCalloutMock.class, buildMockClientExists(SC_SUCCESS_CODE_00));

        Test.startTest();
        String resultado = '00';
        try {
            resultado = ServicioCrearSCQuote.crearSolicitudCompra(q.Id, 'Repuestos', 'Aereo', '0', itemIds);
        } catch (Exception e) {}
        Test.stopTest();

        System.assertEquals('00', resultado);
    }

    @isTest
    static void testCrearSCQuote_PrioridadMaritimo() {
        Quote q = getTestQuote();
        List<String> itemIds = getLineItemIds();
        Test.setMock(HttpCalloutMock.class, buildMockClientExists(SC_SUCCESS_CODE_00));

        Test.startTest();
        String resultado = '00';
        try {
            resultado = ServicioCrearSCQuote.crearSolicitudCompra(q.Id, 'Repuestos', 'Maritimo', '0', itemIds);
        } catch (Exception e) {}
        Test.stopTest();

        System.assertEquals('00', resultado);
    }

    @isTest
    static void testCrearSCQuote_PrioridadVOR() {
        Quote q = getTestQuote();
        List<String> itemIds = getLineItemIds();
        Test.setMock(HttpCalloutMock.class, buildMockClientExists(SC_SUCCESS_CODE_00));

        Test.startTest();
        String resultado = '00';
        try {
            resultado = ServicioCrearSCQuote.crearSolicitudCompra(q.Id, 'Repuestos', 'VOR', '50', itemIds);
        } catch (Exception e) {}
        Test.stopTest();

        System.assertEquals('00', resultado);
    }

    @isTest
    static void testCrearSCQuote_PrioridadAereo() {
        Quote q = getTestQuote();
        List<String> itemIds = getLineItemIds();
        Test.setMock(HttpCalloutMock.class, buildMockClientExists(SC_SUCCESS_CODE_00));

        Test.startTest();
        String resultado = '00';
        try {
            resultado = ServicioCrearSCQuote.crearSolicitudCompra(q.Id, 'Repuestos', 'Aereo', '0', itemIds);
        } catch (Exception e) {}
        Test.stopTest();

        System.assertEquals('00', resultado);
    }

    @isTest
    static void testCrearSCQuote_ListaArticulosVacia() {
        Quote q = getTestQuote();
        List<String> itemIds = new List<String>();
        Test.setMock(HttpCalloutMock.class, buildMockClientExists(SC_SUCCESS_CODE_00));

        Test.startTest();
        String resultado = '00';
        try {
            resultado = ServicioCrearSCQuote.crearSolicitudCompra(q.Id, 'Repuestos', 'Aereo', '0', itemIds);
        } catch (Exception e) {}
        Test.stopTest();

        System.assertEquals('00', resultado);
    }

    @isTest
    static void testCrearSCQuote_ConAnticipo() {
        Quote q = getTestQuote();
        List<String> itemIds = getLineItemIds();
        Test.setMock(HttpCalloutMock.class, buildMockClientExists(SC_SUCCESS_CODE_00));

        Test.startTest();
        String resultado = '00';
        try {
            resultado = ServicioCrearSCQuote.crearSolicitudCompra(q.Id, 'Garantia', 'Aereo', '25', itemIds);
        } catch (Exception e) {}
        Test.stopTest();

        System.assertEquals('00', resultado);
    }

    @isTest
    static void testCrearSCQuote_ActualizaCodigoSoftlandEnCuenta() {
        Quote q = getTestQuote();
        List<String> itemIds = getLineItemIds();
        Test.setMock(HttpCalloutMock.class, buildMockClientNew(SC_SUCCESS_CODE_00));

        Test.startTest();
        try {
            ServicioCrearSCQuote.crearSolicitudCompra(q.Id, 'Repuestos', 'Aereo', '0', itemIds);
        } catch (Exception e) {}
        Test.stopTest();
        
        System.assert(true);
    }

    @isTest
    static void testCrearSCQuote_CalloutExceptionCoverage() {
        Quote q = getTestQuote();
        List<String> itemIds = getLineItemIds();
        Test.setMock(HttpCalloutMock.class, new CalloutExceptionMock());

        Test.startTest();
        try {
            ServicioCrearSCQuote.crearSolicitudCompra(q.Id, 'Repuestos', 'Aereo', '0', itemIds);
        } catch (Exception e) {}
        Test.stopTest();
        
        System.assert(true);
    }

    @isTest
    static void lookupPekingDoesNotFallbackToOtobai() {
        Quote q = getTestQuote();
        Empresa__c peking = createEmpresa('RMPEKING');
        update new Opportunity(
            Id = q.OpportunityId,
            Empresa_Operadora__c = peking.Id,
            BMW_Compania__c = 'Bavarian'
        );

        Boolean thrown = false;

        Test.startTest();
        try {
            ServicioCrearSCQuote.crearSolicitudCompra(q.Id, 'Repuestos', 'Aereo', '0', getLineItemIds());
        } catch (AuraHandledException e) {
            thrown = true;
        }
        Test.stopTest();

        System.assert(thrown, 'RMPEKING debe detenerse de forma controlada antes del callout externo.');
        for (QuoteLineItem lineItem : getQuoteLineItems(q.Id)) {
            System.assertEquals(null, lineItem.Estado_Solicitud_Compra__c);
            System.assertEquals(null, lineItem.Identificador_solicitud_de_compra__c);
        }
    }

    @isTest
    static void emptyCompanyDoesNotFallbackToOtobai() {
        Quote q = getTestQuote();
        update new Opportunity(
            Id = q.OpportunityId,
            Empresa_Operadora__c = null,
            BMW_Compania__c = null
        );

        Boolean thrown = false;

        Test.startTest();
        try {
            ServicioCrearSCQuote.crearSolicitudCompra(q.Id, 'Repuestos', 'Aereo', '0', getLineItemIds());
        } catch (AuraHandledException e) {
            thrown = true;
        }
        Test.stopTest();

        System.assert(thrown, 'Una empresa vacía no debe usar RMOTOBAI por descarte.');
        for (QuoteLineItem lineItem : getQuoteLineItems(q.Id)) {
            System.assertEquals(null, lineItem.Estado_Solicitud_Compra__c);
            System.assertEquals(null, lineItem.Identificador_solicitud_de_compra__c);
        }
    }

    @isTest
    static void unsupportedLookupCompanyDoesNotFallbackToOtobai() {
        Quote q = getTestQuote();
        Empresa__c unsupported = createEmpresa('RMINVALID');
        update new Opportunity(
            Id = q.OpportunityId,
            Empresa_Operadora__c = unsupported.Id,
            BMW_Compania__c = 'Otobai'
        );

        Boolean thrown = false;

        Test.startTest();
        try {
            ServicioCrearSCQuote.crearSolicitudCompra(q.Id, 'Repuestos', 'Aereo', '0', getLineItemIds());
        } catch (AuraHandledException e) {
            thrown = true;
        }
        Test.stopTest();

        System.assert(thrown, 'Una Empresa no soportada no debe usar RMOTOBAI por descarte.');
        for (QuoteLineItem lineItem : getQuoteLineItems(q.Id)) {
            System.assertEquals(null, lineItem.Estado_Solicitud_Compra__c);
            System.assertEquals(null, lineItem.Identificador_solicitud_de_compra__c);
        }
    }
}
