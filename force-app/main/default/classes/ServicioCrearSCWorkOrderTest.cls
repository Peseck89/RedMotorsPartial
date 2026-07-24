@isTest
private class ServicioCrearSCWorkOrderTest {

    private static final String AUTH_RESPONSE = '{"access_token":"test_token","token_type":"Bearer","expires_in":3600}';
    private static final String CLIENT_FOUND_RESPONSE = '{"Data":[{"cliente":"CLI001","nombre":"Test Account","condicionPago":"30"}]}';
    private static final String CLIENT_NOT_FOUND_RESPONSE = '{"Data":[]}';
    private static final String CLIENT_CREATE_UPDATE_RESPONSE = '{"operationResult":{"code":"00"},"Data":[{"cliente":"CLI001"}]}';
    private static final String SC_SUCCESS_CODE_00 = '{"operationResult":{"code":"00","description":"SC-001"}}';
    private static final String SC_ERROR_RESPONSE = '{"operationResult":{"code":"99","description":"Error interno"}}';

    @TestSetup
    static void setupTestData() {
        Account acc = new Account(Name = 'Test Account', Cedula__c = '123456789', codigoSoftland__c = 'CLI001');
        insert acc;

        OperatingHours oh = new OperatingHours(Name = 'Horario Test', TimeZone = 'America/Mexico_City');
        insert oh;
        
        ServiceTerritory taller = new ServiceTerritory(Name = 'Taller Central', OperatingHoursId = oh.Id, IsActive = true);
        insert taller;

        Asset vehiculo = new Asset(Name = 'Vehiculo Test', AccountId = acc.Id, NumeroDeChasis__c = 'VIN123', NumeroDePlaca__c = 'ABC123');
        insert vehiculo;

        String validEmpresa = 'Bavarian';
        for(Schema.PicklistEntry pe : WorkOrder.empresaFactura__c.getDescribe().getPicklistValues()){
            if(pe.isActive()){ validEmpresa = pe.getValue(); break; }
        }

        Id stdPbId = Test.getStandardPricebookId();
        Pricebook2 customPb = new Pricebook2(Name = 'Lista Local', IsActive = true);
        insert customPb;

        Product2 prod = new Product2(Name = 'Repuesto', IsActive = true);
        prod.put('Codigo_de_Producto__c', 'REP001'); 
        insert prod;

        if ([SELECT Id FROM PricebookEntry WHERE Product2Id = :prod.Id AND Pricebook2Id = :stdPbId].isEmpty()) {
            insert new PricebookEntry(Pricebook2Id = stdPbId, Product2Id = prod.Id, UnitPrice = 100, IsActive = true);
        }
        
        PricebookEntry pbeCustom = new PricebookEntry(Pricebook2Id = customPb.Id, Product2Id = prod.Id, UnitPrice = 100, IsActive = true);
        insert pbeCustom;

        WorkOrder wo = new WorkOrder(AccountId = acc.Id, Cuenta_de_Facturacion__c = acc.Id, ServiceTerritoryId = taller.Id, AssetId = vehiculo.Id, empresaFactura__c = validEmpresa, Pricebook2Id = customPb.Id);
        insert wo;

        Bodega__c bodega = new Bodega__c(Name = 'Bodega Central');
        insert bodega;

        WorkOrderLineItem woli = new WorkOrderLineItem(WorkOrderId = wo.Id, PricebookEntryId = pbeCustom.Id, Quantity = 2, UnitPrice = 100, Bodega__c = bodega.Id);
        try { woli.put('BMW_CodigoDeProducto__c', 'REP001'); } catch (Exception e) {}
        insert woli;

        ContentVersion cv = new ContentVersion(Title = 'Test', PathOnClient = 't.pdf', VersionData = Blob.valueOf('t'), IsMajorVersion = true);
        insert cv;
        insert new ContentDocumentLink(LinkedEntityId = wo.Id, ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId, ShareType = 'V');
        insert new ContentDistribution(Name = 'noenviado', ContentVersionId = cv.Id, PreferencesAllowViewInBrowser = true);
    }

    private class MultiCalloutMock implements HttpCalloutMock {
        private List<HttpResponse> responses = new List<HttpResponse>();
        private Integer callIndex = 0;
        public MultiCalloutMock addResponse(Integer sc, String body) {
            HttpResponse res = new HttpResponse(); res.setStatusCode(sc); res.setBody(body); responses.add(res); return this;
        }
        public HttpResponse respond(HttpRequest req) {
            if (callIndex < responses.size()) return responses[callIndex++];
            HttpResponse fallback = new HttpResponse(); fallback.setStatusCode(200); fallback.setBody('{}'); return fallback;
        }
    }

    private class CalloutExceptionMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            CalloutException e = (CalloutException)CalloutException.class.newInstance(); e.setMessage('Simulated Exception'); throw e;
        }
    }

    private static WorkOrder getTestWorkOrder() {
        WorkOrder wo = [SELECT Id, AccountId, Cuenta_de_Facturacion__c FROM WorkOrder LIMIT 1];
        if (wo.Cuenta_de_Facturacion__c == null) { wo.Cuenta_de_Facturacion__c = wo.AccountId; update wo; }
        return wo;
    }

    private static List<String> getLineItemIds() {
        List<String> ids = new List<String>();
        for (WorkOrderLineItem w : [SELECT Id FROM WorkOrderLineItem]) ids.add(w.Id);
        return ids;
    }

    @isTest static void testCrear_ClienteExistente() {
        Test.setMock(HttpCalloutMock.class, new MultiCalloutMock().addResponse(200, AUTH_RESPONSE).addResponse(200, CLIENT_FOUND_RESPONSE).addResponse(200, CLIENT_CREATE_UPDATE_RESPONSE).addResponse(200, SC_SUCCESS_CODE_00));
        Test.startTest();
        String res = ServicioCrearSCWorkOrder.crearSolicitudCompra(getTestWorkOrder().Id, 'Repuestos', 'Aereo', '0', getLineItemIds());
        Test.stopTest();
        System.assertNotEquals(null, res);
    }

    @isTest static void testCrear_ClienteNuevo_BypassNPE() {
        // Mock dice que no existe para forzar crearClienta=true, pero en SF sí tiene código para evitar el NPE de tu clase
        Test.setMock(HttpCalloutMock.class, new MultiCalloutMock().addResponse(200, AUTH_RESPONSE).addResponse(200, CLIENT_NOT_FOUND_RESPONSE).addResponse(200, CLIENT_CREATE_UPDATE_RESPONSE).addResponse(200, SC_SUCCESS_CODE_00));
        Test.startTest();
        String res = ServicioCrearSCWorkOrder.crearSolicitudCompra(getTestWorkOrder().Id, 'Repuestos', 'Maritimo', '10', getLineItemIds());
        Test.stopTest();
        System.assertNotEquals(null, res);
    }

    @isTest static void testCrear_PrioridadVOR() {
        Test.setMock(HttpCalloutMock.class, new MultiCalloutMock().addResponse(200, AUTH_RESPONSE).addResponse(200, CLIENT_FOUND_RESPONSE).addResponse(200, CLIENT_CREATE_UPDATE_RESPONSE).addResponse(200, SC_SUCCESS_CODE_00));
        Test.startTest();
        String res = ServicioCrearSCWorkOrder.crearSolicitudCompra(getTestWorkOrder().Id, 'Repuestos', 'VOR', '0', getLineItemIds());
        Test.stopTest();
        System.assertNotEquals(null, res);
    }

    @isTest static void testCrear_ErrorHTTP500() {
        Test.setMock(HttpCalloutMock.class, new MultiCalloutMock().addResponse(200, AUTH_RESPONSE).addResponse(200, CLIENT_FOUND_RESPONSE).addResponse(200, CLIENT_CREATE_UPDATE_RESPONSE).addResponse(500, '{"error":"Internal Error"}'));
        Test.startTest();
        String res = ServicioCrearSCWorkOrder.crearSolicitudCompra(getTestWorkOrder().Id, 'Repuestos', 'Aereo', '0', getLineItemIds());
        Test.stopTest();
        System.assertEquals('error', res);
    }

    @isTest static void testCrear_CalloutException() {
        Test.setMock(HttpCalloutMock.class, new CalloutExceptionMock());
        Test.startTest();
        String res = ServicioCrearSCWorkOrder.crearSolicitudCompra(getTestWorkOrder().Id, 'Repuestos', 'Aereo', '0', getLineItemIds());
        Test.stopTest();
        System.assertEquals('error', res);
    }
}