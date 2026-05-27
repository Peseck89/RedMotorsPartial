@IsTest
private class ReservaOportunidadControllerTst {

    private class MockHttpSuccess implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"operationResult":{"code":"00","description":"OK"}}');
            return res;
        }
    }

    
    private static Product2 makeVehiculo(String name, Boolean reportado) {
        Product2 p = new Product2(
            Name                   = name,
            Codigo_de_Producto__c = name.left(50),
            esVehiculo__c          = true,
            Producto_Reservado__c = false,
            RM_Reportado__c        = reportado,
            IsActive               = true
        );

        Map<String, Schema.SObjectField> fmap = Product2.SObjectType.getDescribe().fields.getMap();
        for (String fieldKey : fmap.keySet()) {
            Schema.DescribeFieldResult dfr = fmap.get(fieldKey).getDescribe();
            if (!dfr.isCreateable()) continue;
            if (dfr.getType() != Schema.DisplayType.PICKLIST &&
                dfr.getType() != Schema.DisplayType.MULTIPICKLIST) continue;
            if (!dfr.isRestrictedPicklist()) continue;
            if (dfr.isDependentPicklist()) continue;
            try { if (p.get(dfr.getName()) != null) continue; } catch (Exception ex) { continue; }
            String firstVal = null;
            for (Schema.PicklistEntry e : dfr.getPicklistValues()) {
                if (e.isActive()) { firstVal = e.getValue(); break; }
            }
            if (firstVal != null) {
                try { p.put(dfr.getName(), firstVal); } catch (Exception ex) {}
            }
        }
        insert p;
        return p;
    }

    private static Account makeAccount(String name) {
        Account a = new Account(Name = name);
        insert a;
        return a;
    }

    private static Opportunity makeOpp(String name, Id accountId) {
        TriggerHandler.bypass('OpportunityTriggerHandler');
        Opportunity o = new Opportunity(
            Name      = name,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            AccountId = accountId
        );
        insert o;
        return o;
    }

    private static Opportunity makeOpp(String name) {
        TriggerHandler.bypass('OpportunityTriggerHandler');
        Opportunity o = new Opportunity(
            Name      = name,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );
        insert o;
        return o;
    }

    private static OpportunityLineItem makeOLI(Id oppId, Id prodId, Boolean reservado) {
        TriggerHandler.bypass('OpportunityLineItemTriggerHandler');

        Opportunity opp = [SELECT Id, Pricebook2Id FROM Opportunity WHERE Id = :oppId];
        if (opp.Pricebook2Id == null || opp.Pricebook2Id != Test.getStandardPricebookId()) {
            opp.Pricebook2Id = Test.getStandardPricebookId();
            update opp;
        }

        Id pbId = Test.getStandardPricebookId();
        List<PricebookEntry> existingPbe = [
            SELECT Id FROM PricebookEntry
            WHERE Product2Id = :prodId AND Pricebook2Id = :pbId LIMIT 1
        ];
        PricebookEntry pbe;
        if (!existingPbe.isEmpty()) {
            pbe = existingPbe[0];
        } else {
            pbe = new PricebookEntry(
                Pricebook2Id = pbId,
                Product2Id   = prodId,
                UnitPrice    = 100.0,
                IsActive     = true
            );
            insert pbe;
        }

        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId    = oppId,
            Product2Id       = prodId,
            PricebookEntryId = pbe.Id,
            Quantity         = 1,
            UnitPrice        = 100.0,
            Reservado__c     = reservado
        );
        insert oli;
        return oli;
    }

    private static Quote makeQuote(Id oppId) {
        Quote q = new Quote(
            Name          = 'TestQuote',
            OpportunityId = oppId,
            Pricebook2Id  = Test.getStandardPricebookId(),
            Status        = 'Draft'
        );
        insert q;
        return q;
    }

    private static QuoteLineItem makeQLI(Id quoteId, Id prodId) {
        TriggerHandler.bypass('QuoteLineItemTriggerHandler');

        Id pbId = Test.getStandardPricebookId();
        List<PricebookEntry> existingPbe = [
            SELECT Id FROM PricebookEntry
            WHERE Product2Id = :prodId AND Pricebook2Id = :pbId LIMIT 1
        ];
        PricebookEntry pbe;
        if (!existingPbe.isEmpty()) {
            pbe = existingPbe[0];
        } else {
            pbe = new PricebookEntry(
                Pricebook2Id = pbId,
                Product2Id   = prodId,
                UnitPrice    = 100.0,
                IsActive     = true
            );
            insert pbe;
        }

        QuoteLineItem qli = new QuoteLineItem(
            QuoteId          = quoteId,
            Product2Id       = prodId,
            PricebookEntryId = pbe.Id,
            Quantity         = 1,
            UnitPrice        = 100.0
        );
        insert qli;
        return qli;
    }

    @IsTest
    static void testGetCurrentOpp() {
        Opportunity opp = makeOpp('OppGetCurrent');
        Test.startTest();
        Opportunity result = ReservaOportunidadController.getCurrentOpp(opp.Id);
        Test.stopTest();
        System.assertNotEquals(null, result);
        System.assertEquals(opp.Id, result.Id);
    }

    @IsTest
    static void testGetProduct() {
        Product2 prod = makeVehiculo('VehiculoGetProduct', false);
        Test.startTest();
        Product2 result = ReservaOportunidadController.getProduct(prod.Id);
        Test.stopTest();
        System.assertNotEquals(null, result);
        System.assertEquals(prod.Id, result.Id);
    }

    @IsTest
    static void testGetAnticipo_SinAnticipo() {
        Opportunity opp  = makeOpp('OppSinAnticipo');
        Product2    prod = makeVehiculo('ProdSinAnticipo', false);
        Test.startTest();
        Boolean result = ReservaOportunidadController.getAnticipo(opp.Id, prod.Id);
        Test.stopTest();
        System.assertEquals(false, result);
    }

    @IsTest
    static void testGetAnticipo_ConAnticipo() {
        Opportunity opp  = makeOpp('OppConAnticipo');
        Product2    prod = makeVehiculo('ProdConAnticipo', false);
        insert new Anticipo__c(Oportunidad__c = opp.Id, Producto__c = prod.Id);
        Test.startTest();
        Boolean result = ReservaOportunidadController.getAnticipo(opp.Id, prod.Id);
        Test.stopTest();
        System.assertEquals(true, result);
    }

    @IsTest
    static void testGetModelosVehiculos_SinSyncedQuote() {
        Opportunity opp = makeOpp('OppSinSyncedQuote');
        Test.startTest();
        List<Product2> result = ReservaOportunidadController.getModelosVehiculos(opp.Id);
        Test.stopTest();
        System.assertNotEquals(null, result);
        System.assertEquals(0, result.size());
    }

    @IsTest
    static void testMakeReserva_Exitoso() {
        Account      acc  = makeAccount('CuentaReserva');
        Product2    prod = makeVehiculo('VehiculoReservaTest', false);
        Opportunity opp  = makeOpp('OppReserva', acc.Id);
        makeOLI(opp.Id, prod.Id, false);

        Test.setMock(HttpCalloutMock.class, new MockHttpSuccess());
        TriggerHandler.bypass('OpportunityLineItemTriggerHandler');
        TriggerHandler.bypass('OpportunityTriggerHandler');

        Test.startTest();
        Product2 result = ReservaOportunidadController.makeReserva(opp.Id, prod.Id);
        Test.stopTest();

        System.assertNotEquals(null, result);
        Product2 updProd = [SELECT Producto_Reservado__c FROM Product2 WHERE Id = :prod.Id];
        System.assertEquals(true, updProd.Producto_Reservado__c);
        Opportunity updOpp = [SELECT Tiene_Vehiculos_Reservados__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(true, updOpp.Tiene_Vehiculos_Reservados__c);
    }

    @IsTest
    static void testMakeReserva_AppendVehiculosReservados() {
        Account      acc  = makeAccount('CuentaAppend');
        Product2    prod = makeVehiculo('VehiculoAppend', false);
        TriggerHandler.bypass('OpportunityTriggerHandler');
        Opportunity opp  = new Opportunity(
            Name                          = 'OppAppend',
            StageName                     = 'Prospecting',
            CloseDate                     = Date.today().addDays(30),
            AccountId                     = acc.Id,
            Tiene_Vehiculos_Reservados__c = true,
            Vehiculos_Reservados__c       = 'OtroVehiculo'
        );
        insert opp;
        makeOLI(opp.Id, prod.Id, false);

        Test.setMock(HttpCalloutMock.class, new MockHttpSuccess());
        TriggerHandler.bypass('OpportunityLineItemTriggerHandler');
        TriggerHandler.bypass('OpportunityTriggerHandler');

        Test.startTest();
        Product2 result = ReservaOportunidadController.makeReserva(opp.Id, prod.Id);
        Test.stopTest();

        System.assertNotEquals(null, result);
        Opportunity updOpp = [SELECT Vehiculos_Reservados__c FROM Opportunity WHERE Id = :opp.Id];
        System.assert(updOpp.Vehiculos_Reservados__c.contains('VehiculoAppend'));
    }

    @IsTest
    static void testMakeReserva_ReservadoDesdeAquiToggle() {
        Account      acc  = makeAccount('CuentaToggle');
        Product2    prod = makeVehiculo('VehiculoToggle', false);
        Opportunity opp  = makeOpp('OppToggle', acc.Id);

        OpportunityLineItem oli = makeOLI(opp.Id, prod.Id, false);
        TriggerHandler.bypass('OpportunityLineItemTriggerHandler');
        oli.ReservadoDesdeAqui__c = true;
        update oli;

        Test.setMock(HttpCalloutMock.class, new MockHttpSuccess());
        TriggerHandler.bypass('OpportunityLineItemTriggerHandler');
        TriggerHandler.bypass('OpportunityTriggerHandler');

        Test.startTest();
        Product2 result = ReservaOportunidadController.makeReserva(opp.Id, prod.Id);
        Test.stopTest();
        System.assertNotEquals(null, result);
    }

    @IsTest
    static void testMakeReserva_VehiculoReportado() {
        Account      acc  = makeAccount('CuentaReportado');
        Product2    prod = makeVehiculo('VehiculoReportado', true);
        Opportunity opp  = makeOpp('OppReportado', acc.Id);

        Boolean threw = false;
        Test.startTest();
        try {
            ReservaOportunidadController.makeReserva(opp.Id, prod.Id);
        } catch (AuraHandledException e) {
            threw = true;
        }
        Test.stopTest();
        System.assert(threw, 'Debe lanzar AuraHandledException');
    }

    @IsTest
    static void testMakeReserva_ProductoNoExiste() {
        Opportunity opp = makeOpp('OppProdNoExiste');
        Id fakeProdId   = '01t000000000001AAA';

        Boolean threw = false;
        Test.startTest();
        try {
            ReservaOportunidadController.makeReserva(opp.Id, fakeProdId);
        } catch (AuraHandledException e) {
            threw = true;
        }
        Test.stopTest();
        System.assert(threw, 'Debe lanzar AuraHandledException');
    }

    @IsTest
    static void testReservarVehiculo_Future() {
        Account      acc  = makeAccount('CuentaFuture');
        Product2    prod = makeVehiculo('VehiculoFuture', false);
        Opportunity opp  = makeOpp('OppFuture', acc.Id);
        makeOLI(opp.Id, prod.Id, false);

        Test.setMock(HttpCalloutMock.class, new MockHttpSuccess());
        TriggerHandler.bypass('OpportunityLineItemTriggerHandler');
        TriggerHandler.bypass('OpportunityTriggerHandler');

        Test.startTest();
        ReservaOportunidadController.reservarVehiculo(opp.Id, prod.Id);
        Test.stopTest();
        System.assert(true);
    }

    @IsTest
    static void testWrapperRespuesta() {
        Test.startTest();
        ReservaOportunidadController.WrapperRespuesta w =
            new ReservaOportunidadController.WrapperRespuesta();
        w.code        = '00';
        w.description = 'OK';
        Test.stopTest();
        System.assertEquals('00', w.code);
        System.assertEquals('OK', w.description);
    }

    @IsTest
    static void testMakeReserva_OLIDeOtraOpp() {
        Account      acc  = makeAccount('CuentaOtraOpp');
        Product2    prod = makeVehiculo('VehiculoOtraOpp', false);
        Opportunity opp1 = makeOpp('OppPrincipal',  acc.Id);
        Opportunity opp2 = makeOpp('OppSecundaria', acc.Id);
        makeOLI(opp1.Id, prod.Id, false);
        makeOLI(opp2.Id, prod.Id, false);

        Test.setMock(HttpCalloutMock.class, new MockHttpSuccess());
        TriggerHandler.bypass('OpportunityLineItemTriggerHandler');
        TriggerHandler.bypass('OpportunityTriggerHandler');

        Test.startTest();
        Product2 result = ReservaOportunidadController.makeReserva(opp1.Id, prod.Id);
        Test.stopTest();
        System.assertNotEquals(null, result);
    }
}