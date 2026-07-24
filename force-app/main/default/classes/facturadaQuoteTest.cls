@isTest
private class facturadaQuoteTest {

    @TestSetup
    static void setupTestData() {
        Account acc = new Account(
            Name = 'Test Account',
            Cedula__c = '123456789'
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
            pbe = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 100.00, IsActive = true);
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
        try { qli.put('Codigo_producto__c', 'REP001'); } catch (Exception e) {}
        insert qli;

        Respuesta_pedido_quote__c pedidoExistente = new Respuesta_pedido_quote__c(
            Quote__c = q.Id,
            D_Pedido_Softland__c = 'SOFT-001',
            Estado__c = 'En Proceso'
        );
        insert pedidoExistente;
    }

    @isTest
    static void testFacturada_EncuentraPedido_Facturado() {
        Quote q = [SELECT Id, Quote_Number__c FROM Quote LIMIT 1];
        QuoteLineItem qli = [SELECT Id FROM QuoteLineItem LIMIT 1];

        facturadaQuote.facturadaRequestJSON req = new facturadaQuote.facturadaRequestJSON();
        req.softland_code = 'SOFT-001'; 
        req.Estado = 'F'; 
        req.Fecha_facturacion = Datetime.now();
        req.PedidoID = 'PED-123';
        req.Total_Pedido = '500';
        req.quote_salesforce = q.Quote_Number__c; 

        facturadaQuote.Estado_lineas linea = new facturadaQuote.Estado_lineas();
        linea.itemId = qli.Id;
        linea.ESTADO = 'F';
        req.estado_lineas = new List<facturadaQuote.Estado_lineas>{ linea };

        String jsonPayload = JSON.serialize(req);

        Test.startTest();
        String resultado = facturadaQuote.actualizarFacturada(jsonPayload);
        Test.stopTest();

        System.assert(resultado.contains('"CODIGO":"800"'));
        
        Respuesta_pedido_quote__c pedidoActualizado = [SELECT Estado__c FROM Respuesta_pedido_quote__c WHERE D_Pedido_Softland__c = 'SOFT-001' LIMIT 1];
        System.assertEquals('Facturado', pedidoActualizado.Estado__c);
    }

    @isTest
    static void testFacturada_NuevoPedido_Cancelado() {
        Quote q = [SELECT Id, Quote_Number__c FROM Quote LIMIT 1];

        facturadaQuote.facturadaRequestJSON req = new facturadaQuote.facturadaRequestJSON();
        req.softland_code = 'SOFT-002'; 
        req.Estado = 'C'; 
        req.Fecha_facturacion = Datetime.now();
        req.PedidoID = 'PED-999';
        req.Total_Pedido = '0';
        req.quote_salesforce = q.Quote_Number__c;

        String jsonPayload = JSON.serialize(req);

        Test.startTest();
        String resultado = facturadaQuote.actualizarFacturada(jsonPayload);
        Test.stopTest();

        System.assert(resultado.contains('"CODIGO":"800"'));
        
        List<Respuesta_pedido_quote__c> nuevosPedidos = [SELECT Id, Estado__c FROM Respuesta_pedido_quote__c WHERE D_Pedido_Softland__c = 'PED-999'];
        System.assertEquals(1, nuevosPedidos.size());
        System.assertEquals('Cancelado', nuevosPedidos[0].Estado__c);
    }

    @isTest
    static void testFacturada_NotFound() {
        facturadaQuote.facturadaRequestJSON req = new facturadaQuote.facturadaRequestJSON();
        req.quote_salesforce = 'Q-INVALIDA-999'; 

        String jsonPayload = JSON.serialize(req);

        Test.startTest();
        String resultado = facturadaQuote.actualizarFacturada(jsonPayload);
        Test.stopTest();

        System.assert(resultado.contains('"CODIGO":"404"'));
    }

    @isTest
    static void testFacturada_Exception() {
        Quote q = [SELECT Id, Quote_Number__c FROM Quote LIMIT 1];

        facturadaQuote.facturadaRequestJSON req = new facturadaQuote.facturadaRequestJSON();
        req.softland_code = 'SOFT-ERR';
        req.quote_salesforce = q.Quote_Number__c;

        facturadaQuote.Estado_lineas linea = new facturadaQuote.Estado_lineas();
        linea.itemId = 'ID_INVALIDO'; 
        linea.ESTADO = 'F';
        req.estado_lineas = new List<facturadaQuote.Estado_lineas>{ linea };

        String jsonPayload = JSON.serialize(req);

        Test.startTest();
        String resultado = facturadaQuote.actualizarFacturada(jsonPayload);
        Test.stopTest();

        System.assert(resultado.contains('"CODIGO":"800"'));
    }

    @isTest
    static void testMetodosExtraDeValidacion() {
        Quote q = [SELECT Id FROM Quote LIMIT 1];

        Test.startTest();
        Boolean orderBilled = facturadaQuote.WorkOrderBilledCheck(q.Id);
        Boolean linesBilled = facturadaQuote.workOrderLinesBilledCheck(q.Id);
        Test.stopTest();

        System.assertNotEquals(null, orderBilled);
        System.assertNotEquals(null, linesBilled);
    }
}