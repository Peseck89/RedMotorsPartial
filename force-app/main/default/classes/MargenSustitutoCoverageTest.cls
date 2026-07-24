@IsTest
private class MargenSustitutoCoverageTest {
    private static final String PROD_CODE = 'COV-MARGEN-001';
    private static final String MO_CODE = 'COV-MO-001';
    private static final String DISPLAY_PB_NAME = 'Bavarian Dolar Coverage';
    private static final String LOCAL_PB_NAME = 'Bavarian Local Coverage';

    @TestSetup
    static void setupData() {
        Id standardPbId = Test.getStandardPricebookId();
        try {
            update new Pricebook2(Id = standardPbId, IsActive = true);
        } catch (Exception e) {
        }

        Pricebook2 displayPb = new Pricebook2(Name = DISPLAY_PB_NAME, IsActive = true);
        Pricebook2 localPb = new Pricebook2(Name = LOCAL_PB_NAME, IsActive = true);
        try {
            displayPb.CurrencyIsoCode = UserInfo.getDefaultCurrency();
            localPb.CurrencyIsoCode = UserInfo.getDefaultCurrency();
        } catch (Exception e) {
        }
        insert new List<Pricebook2>{ displayPb, localPb };

        OperatingHours oh = new OperatingHours(Name = 'OH Margen Coverage');
        insert oh;

        List<ServiceTerritory> territories = new List<ServiceTerritory>{
            new ServiceTerritory(Name = 'Uruca - Mecanica Rapida', IsActive = true, OperatingHoursId = oh.Id),
            new ServiceTerritory(Name = 'Uruca - Mecánica Rápida', IsActive = true, OperatingHoursId = oh.Id),
            new ServiceTerritory(Name = 'Pinares - Mecánica Rápida', IsActive = true, OperatingHoursId = oh.Id),
            new ServiceTerritory(Name = 'Escazú - Mecánica Rápida', IsActive = true, OperatingHoursId = oh.Id)
        };
        insert territories;

        Bodega__c bodega = new Bodega__c(
            Name = 'BR-COV',
            Bodega__c = 'BR-COV',
            ID_EXTERNO_BODEGA__c = 'BR-COV',
            Alias__c = 'BR Coverage'
        );
        insert bodega;

        List<BodegaxTerritorio__c> territoryWarehouses = new List<BodegaxTerritorio__c>();
        for (ServiceTerritory st : territories) {
            territoryWarehouses.add(new BodegaxTerritorio__c(
                ServiceTerritory__c = st.Id,
                Bodega__c = bodega.Id,
                isPrincipal__c = true
            ));
        }
        insert territoryWarehouses;

        Product2 product = new Product2(
            Name = 'Producto Margen Coverage',
            ProductCode = PROD_CODE,
            Codigo_de_Producto__c = PROD_CODE,
            IsActive = true,
            tipoProducto__c = 'Materiales',
            costoLocal__c = 80,
            Sustitutivo__c = 'SUST-COV',
            alternativo__c = 'ALT-COV',
            transito__c = 'TRANS-COV'
        );
        insert product;

        Product2 labor = new Product2(
            Name = 'Mano Obra Margen Coverage',
            ProductCode = MO_CODE,
            Codigo_de_Producto__c = MO_CODE,
            IsActive = true,
            tipoProducto__c = 'Mano de Obra',
            costoLocal__c = 50,
            Sustitutivo__c = 'SUST-MO-COV',
            alternativo__c = 'ALT-MO-COV',
            transito__c = 'TRANS-MO-COV'
        );
        insert labor;

        insert new ProductoXBodega__c(
            Producto__c = product.Id,
            Bodega__c = bodega.Id,
            Disponible__c = 7
        );

        ensurePricebookEntry(standardPbId, product.Id, 100, 70);
        ensurePricebookEntry(displayPb.Id, product.Id, 120, 90);
        ensurePricebookEntry(localPb.Id, product.Id, 100, 60);

        ensurePricebookEntry(standardPbId, labor.Id, 80, 35);
        ensurePricebookEntry(displayPb.Id, labor.Id, 90, 36);
        ensurePricebookEntry(localPb.Id, labor.Id, 100, 30);
    }

    private static PricebookEntry ensurePricebookEntry(Id pricebookId, Id productId, Decimal unitPrice, Decimal costoFijo) {
        List<PricebookEntry> existing = [
            SELECT Id, UnitPrice, IsActive, UseStandardPrice, Costo_Fijo__c
            FROM PricebookEntry
            WHERE Pricebook2Id = :pricebookId
              AND Product2Id = :productId
            LIMIT 1
        ];

        if (!existing.isEmpty()) {
            PricebookEntry pbe = existing[0];
            pbe.UnitPrice = unitPrice;
            pbe.Costo_Fijo__c = costoFijo;
            pbe.IsActive = true;
            pbe.UseStandardPrice = false;
            update pbe;
            return pbe;
        }

        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = productId,
            UnitPrice = unitPrice,
            Costo_Fijo__c = costoFijo,
            IsActive = true,
            UseStandardPrice = false
        );
        try {
            pbe.CurrencyIsoCode = UserInfo.getDefaultCurrency();
        } catch (Exception e) {
        }
        insert pbe;
        return pbe;
    }

    private static String getAnyActiveOpportunityStage() {
        for (Schema.PicklistEntry pe : Opportunity.StageName.getDescribe().getPicklistValues()) {
            if (pe.isActive()) {
                return pe.getValue();
            }
        }
        return null;
    }

    private static String getAnyActiveQuoteStatus() {
        for (Schema.PicklistEntry pe : Quote.Status.getDescribe().getPicklistValues()) {
            if (pe.isActive()) {
                return pe.getValue();
            }
        }
        return null;
    }

    @IsTest
    static void coverExistingCoverageHelpers() {
        Test.startTest();
        Test.stopTest();
    }

    @IsTest
    static void coverBusquedaDetalladaSearchAndService() {
        Pricebook2 displayPb = [
            SELECT Id
            FROM Pricebook2
            WHERE Name = :DISPLAY_PB_NAME
            LIMIT 1
        ];
        ServiceTerritory st = [
            SELECT Id
            FROM ServiceTerritory
            WHERE Name = 'Uruca - Mecánica Rápida'
            LIMIT 1
        ];

        BusquedaDetalladaService service = new BusquedaDetalladaService(null);

        Test.startTest();
        Id principalBodega = service.getPrincipal(st.Id);
        Id displayId = service.getDisplayPricebookId(displayPb.Id);
        Id localId = service.getLocalPricebookId(displayPb.Id);
        Map<Id, Product2> products = service.searchProductsByName(PROD_CODE, displayPb.Id, st.Id);

        BusquedaDetalladaHelper helper = new BusquedaDetalladaHelper(null);
        List<WoliGridWrapper> helperRows = helper.searchProductsbyValue('', PROD_CODE, displayPb.Id, st.Id);

        List<Pricebook2> activePricebooks = BusquedaDetalladaController.getActivePricebooks();
        List<ServiceTerritory> activeTerritories = BusquedaDetalladaController.getActiveServiceTerritories();
        List<WoliGridWrapper> controllerRows =
            BusquedaDetalladaController.searchProducts('', PROD_CODE, null, displayPb.Id, st.Id);
        Test.stopTest();

        System.assertNotEquals(null, principalBodega);
        System.assertEquals(displayPb.Id, displayId);
        System.assertNotEquals(null, localId);
        System.assert(!products.isEmpty(), 'Debe encontrar el producto de prueba.');
        System.assert(!helperRows.isEmpty(), 'Debe devolver filas desde el helper.');
        System.assert(!activePricebooks.isEmpty(), 'Debe encontrar pricebooks activos.');
        System.assert(!activeTerritories.isEmpty(), 'Debe encontrar territorios activos.');
        System.assert(!controllerRows.isEmpty(), 'Debe devolver filas desde el controller.');
        System.assertEquals('SUST-COV', helperRows[0].sustitutivo);
        System.assertEquals('ALT-COV', helperRows[0].alternativo);
        System.assertEquals('25.00%', helperRows[0].margen);
        System.assertEquals('TRANS-COV', helperRows[0].transito);
        System.assertEquals('25.00%', controllerRows[0].margen);
    }

    @IsTest
    static void coverWoliHelpersSearchWithQuoteContext() {
        Pricebook2 displayPb = [
            SELECT Id
            FROM Pricebook2
            WHERE Name = :DISPLAY_PB_NAME
            LIMIT 1
        ];
        ServiceTerritory st = [
            SELECT Id
            FROM ServiceTerritory
            WHERE Name = 'Uruca - Mecánica Rápida'
            LIMIT 1
        ];

        Account acc = new Account(Name = 'Account Margen Coverage');
        insert acc;

        Opportunity opp = new Opportunity(
            Name = 'Opportunity Margen Coverage',
            AccountId = acc.Id,
            StageName = getAnyActiveOpportunityStage(),
            CloseDate = Date.today().addDays(10),
            Pricebook2Id = displayPb.Id,
            BMW_TallerDeServicio__c = st.Id
        );
        insert opp;

        Quote quote = new Quote(
            Name = 'Quote Margen Coverage',
            OpportunityId = opp.Id,
            Pricebook2Id = displayPb.Id,
            Status = getAnyActiveQuoteStatus()
        );
        insert quote;

        Product2 product = [
            SELECT Id
            FROM Product2
            WHERE ProductCode = :PROD_CODE
            LIMIT 1
        ];
        PricebookEntry pbe = [
            SELECT Id
            FROM PricebookEntry
            WHERE Product2Id = :product.Id
              AND Pricebook2Id = :displayPb.Id
            LIMIT 1
        ];
        Bodega__c bodega = [
            SELECT Id
            FROM Bodega__c
            WHERE ID_EXTERNO_BODEGA__c = 'BR-COV'
            LIMIT 1
        ];
        ProductoXBodega__c productWarehouse = [
            SELECT Id
            FROM ProductoXBodega__c
            WHERE Producto__c = :product.Id
              AND Bodega__c = :bodega.Id
            LIMIT 1
        ];

        insert new QuoteLineItem(
            QuoteId = quote.Id,
            Quantity = 1,
            PricebookEntryId = pbe.Id,
            Product2Id = product.Id,
            UnitPrice = 120,
            BMW_Bodega__c = bodega.Id,
            BMW_Alias__c = 'Alias QLI Coverage',
            ProductoPorBodega__c = productWarehouse.Id
        );

        Test.startTest();
        WoliGridHelper helper = new WoliGridHelper(quote.Id, true);
        List<WoliGridWrapper> helperRows = helper.searchProductsbyValue('', PROD_CODE);
        List<WoliGridWrapper> helperLaborRows = helper.searchProductsbyValue('', MO_CODE);
        List<WoliGridWrapper> helperQuoteRows = helper.qolisToWrappers('[]');

        WoliGridHelper2 helper2 = new WoliGridHelper2(quote.Id, true);
        List<WoliGridWrapper> helper2Rows = helper2.searchProductsbyValue('', PROD_CODE);
        List<WoliGridWrapper> helper2LaborRows = helper2.searchProductsbyValue('', MO_CODE);
        List<WoliGridWrapper> helper2QuoteRows = helper2.qolisToWrappers('[]');
        Test.stopTest();

        System.assert(!helperRows.isEmpty(), 'WoliGridHelper debe devolver filas.');
        System.assert(!helperLaborRows.isEmpty(), 'WoliGridHelper debe devolver filas de mano de obra.');
        System.assert(!helperQuoteRows.isEmpty(), 'WoliGridHelper debe convertir líneas de cotización.');
        System.assert(!helper2Rows.isEmpty(), 'WoliGridHelper2 debe devolver filas.');
        System.assert(!helper2LaborRows.isEmpty(), 'WoliGridHelper2 debe devolver filas de mano de obra.');
        System.assert(!helper2QuoteRows.isEmpty(), 'WoliGridHelper2 debe convertir líneas de cotización.');
        System.assertEquals('SUST-COV', helperRows[0].sustitutivo);
        System.assertEquals('ALT-COV', helperRows[0].alternativo);
        System.assertEquals('25.00%', helperRows[0].margen);
        System.assertEquals('TRANS-COV', helperRows[0].transito);
        System.assertEquals('60.00%', helperLaborRows[0].margen);
        System.assertEquals('SUST-COV', helperQuoteRows[0].sustitutivo);
        System.assertEquals('25.00%', helperQuoteRows[0].margen);
        System.assertEquals('25.00%', helper2Rows[0].margen);
        System.assertEquals('60.00%', helper2LaborRows[0].margen);
        System.assertEquals('SUST-COV', helper2QuoteRows[0].sustitutivo);
        System.assertEquals('25.00%', helper2QuoteRows[0].margen);
    }

    @IsTest
    static void coverWoliHelpersWithWorkOrderContext() {
        Pricebook2 displayPb = [
            SELECT Id
            FROM Pricebook2
            WHERE Name = :DISPLAY_PB_NAME
            LIMIT 1
        ];
        ServiceTerritory st = [
            SELECT Id
            FROM ServiceTerritory
            WHERE Name = 'Uruca - Mecánica Rápida'
            LIMIT 1
        ];
        Product2 product = [
            SELECT Id
            FROM Product2
            WHERE ProductCode = :PROD_CODE
            LIMIT 1
        ];
        PricebookEntry pbe = [
            SELECT Id
            FROM PricebookEntry
            WHERE Product2Id = :product.Id
              AND Pricebook2Id = :displayPb.Id
            LIMIT 1
        ];
        Bodega__c bodega = [
            SELECT Id
            FROM Bodega__c
            WHERE ID_EXTERNO_BODEGA__c = 'BR-COV'
            LIMIT 1
        ];
        ProductoXBodega__c productWarehouse = [
            SELECT Id
            FROM ProductoXBodega__c
            WHERE Producto__c = :product.Id
              AND Bodega__c = :bodega.Id
            LIMIT 1
        ];

        WorkOrder wo = new WorkOrder(
            Subject = 'WO Woli Helper Coverage',
            Pricebook2Id = displayPb.Id,
            ServiceTerritoryId = st.Id
        );
        insert wo;

        WorkOrderLineItem woli = new WorkOrderLineItem(
            WorkOrderId = wo.Id,
            PricebookEntryId = pbe.Id,
            Product__c = product.Id,
            ProductoPorBodega__c = productWarehouse.Id,
            Bodega__c = bodega.Id,
            Quantity = 2,
            UnitPrice = 120,
            Alias_Articulo__c = 'Alias WOLI Coverage',
            Estado__c = 'Pendiente',
            Estado_reserva__c = 'Pendiente de reserva',
            Estado_entrega__c = 'Sin Entregar'
        );
        insert woli;

        Test.startTest();
        WoliGridQueryService service = new WoliGridQueryService(wo.Id);
        service.getDisplayPricebookId();
        service.getLocalPricebookId();
        service.getSearchPricebookIds();
        service.getWolis();
        service.getPrincipal();
        service.getBodegasOnly(new Set<String>{ String.valueOf(product.Id) });
        service.getFileUrlsFromWorkOrder();
        service.updateDocsAsSendWO();
        WoliGridQueryService.getPricebookEntries(new List<Id>{ pbe.Id });

        WoliGridHelper helper = new WoliGridHelper(wo.Id);
        List<WoliGridWrapper> rows = helper.wolisToWrappers('[]');
        helper.searchProductsbyValue('', PROD_CODE);

        WoliGridHelper2 helper2 = new WoliGridHelper2(wo.Id);
        List<WoliGridWrapper> rows2 = helper2.wolisToWrappers('[]');
        helper2.searchProductsbyValue('', PROD_CODE);
        Test.stopTest();

        System.assert(!rows.isEmpty());
        System.assert(!rows2.isEmpty());
    }

    @IsTest
    static void coverBusquedaMarginEdges() {
        Test.startTest();
        System.assertEquals('', BusquedaDetalladaHelper.calculateMarginFromPricebookEntry(null, 1, 'test', 'P', 'N'));
        System.assertEquals('', BusquedaDetalladaHelper.calculateMarginFromPricebookEntry(0, 1, 'test', 'P', 'N'));
        System.assertEquals('', BusquedaDetalladaHelper.calculateMarginFromPricebookEntry(100, null, 'test', 'P', 'N'));
        Test.stopTest();
    }

    @IsTest
    static void coverWrapperConstructorAndSetters() {
        Product2 product = [
            SELECT Id
            FROM Product2
            WHERE ProductCode = :PROD_CODE
            LIMIT 1
        ];
        PricebookEntry pbe = [
            SELECT Id, CurrencyIsoCode
            FROM PricebookEntry
            WHERE Product2Id = :product.Id
              AND Pricebook2.Name = :DISPLAY_PB_NAME
            LIMIT 1
        ];

        Test.startTest();
        WoliGridWrapper material = new WoliGridWrapper(
            null,
            product.Id,
            PROD_CODE,
            'Producto Margen Coverage',
            120,
            'BR-COV',
            7,
            'Materiales',
            'Alias',
            null,
            pbe.Id,
            pbe.CurrencyIsoCode,
            'BOD-001',
            'BR-COV',
            null
        );
        material.setWolId(product.Id);
        material.sustitutivo = 'SUST-COV';
        material.alternativo = 'ALT-COV';
        material.margen = '25.00%';
        material.transito = 'TRANS-COV';

        WoliGridWrapper labor = new WoliGridWrapper(
            null,
            product.Id,
            PROD_CODE,
            'Mano Obra Coverage',
            100,
            'Mano de Obra',
            0,
            'Mano de Obra',
            '',
            null,
            pbe.Id,
            pbe.CurrencyIsoCode,
            null,
            null,
            null
        );

        WoliGridWrapper.Bodegas bodega = new WoliGridWrapper.Bodegas();
        bodega.Id = 'BOD-001';
        bodega.name = 'BR-COV';
        bodega.cantidadDisponible = 7;
        bodega.isPrincipal = true;
        Test.stopTest();

        System.assertNotEquals(null, material.wolId);
        System.assertEquals(1000, labor.softlandQuantity);
        System.assertEquals(true, bodega.isPrincipal);
        System.assertEquals('25.00%', material.margen);
    }
}