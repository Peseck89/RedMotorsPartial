@IsTest
private class QuoteServiceTest {

    private static String uid() {
        return String.valueOf(Math.abs(Crypto.getRandomInteger())).left(8);
    }

    private static Account makeAccount() {
        Account acc = new Account(Name = 'QS Account ' + uid());
        insert acc;
        return acc;
    }

    private static Opportunity makeOpportunity(Id accountId, Id pricebookId, Boolean useOtobaiRecordType) {
        TriggerHandler.bypass('OpportunityTriggerHandler');

        Opportunity opp = new Opportunity(
            Name = 'QS Opp ' + uid(),
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(15),
            AccountId = accountId,
            Pricebook2Id = pricebookId
        );

        if (useOtobaiRecordType) {
            List<RecordType> recordTypes = [
                SELECT Id
                FROM RecordType
                WHERE SObjectType = 'Opportunity'
                AND DeveloperName IN ('Polaris', 'Kawasaki', 'Indian')
                LIMIT 1
            ];
            if (!recordTypes.isEmpty()) {
                opp.RecordTypeId = recordTypes[0].Id;
            }
        }

        insert opp;
        return opp;
    }

    private static Pricebook2 makePricebook(String name) {
        Pricebook2 pb = new Pricebook2(Name = name + ' ' + uid(), IsActive = true);
        insert pb;
        return pb;
    }

    private static Product2 makeProduct(Boolean vehicle, String code, String brand, String model, String year) {
        Product2 prod = new Product2(
            Name = 'QS Product ' + code + ' ' + uid(),
            ProductCode = code,
            Codigo_de_Producto__c = code,
            IsActive = true,
            esVehiculo__c = vehicle,
            Producto_Reservado__c = false,
            marcaVehiculo__c = brand,
            Anno__c = year,
            modelo__c = model
        );
        insert prod;
        return prod;
    }

    private static Product2 makeProductForCompany(Boolean vehicle, String code, String brand, String model, String year, String companyCode) {
        Product2 prod = makeProduct(vehicle, code, brand, model, year);
        prod.Empresa__c = companyCode;
        update prod;
        return prod;
    }

    private static Empresa__c makeEmpresa(String companyCode) {
        Empresa__c empresa = new Empresa__c(
            Name = 'QS Empresa ' + companyCode + ' ' + uid(),
            Codigo__c = companyCode,
            Codigo_ERP__c = companyCode,
            Nombre_Legal__c = 'QS Empresa Legal ' + companyCode,
            Activa__c = true
        );
        insert empresa;
        return empresa;
    }

    private static Product2 makeLaborProduct(String code) {
        Product2 prod = new Product2(
            Name = 'QS Labor ' + code + ' ' + uid(),
            ProductCode = code,
            Codigo_de_Producto__c = code,
            IsActive = true,
            tipoProducto__c = 'Mano de Obra',
            Empresa__c = 'RMOTOBAI',
            RM_VN_EsActivo__c = true
        );
        insert prod;
        return prod;
    }

    private static void makePrice(Id pricebookId, Id productId, Decimal unitPrice) {
        Id standardPbId = Test.getStandardPricebookId();

        List<PricebookEntry> standardEntries = [
            SELECT Id
            FROM PricebookEntry
            WHERE Pricebook2Id = :standardPbId
            AND Product2Id = :productId
            LIMIT 1
        ];
        if (standardEntries.isEmpty()) {
            insert new PricebookEntry(
                Pricebook2Id = standardPbId,
                Product2Id = productId,
                UnitPrice = unitPrice,
                IsActive = true
            );
        }

        insert new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = productId,
            UnitPrice = unitPrice,
            Costo_Fijo__c = unitPrice / 2,
            IsActive = true,
            UseStandardPrice = false
        );
    }

    private static Bodega__c makeBodega(String code, String externalId) {
        Bodega__c bodega = new Bodega__c(
            Name = 'QS Bodega ' + code + ' ' + uid(),
            Bodega__c = code,
            ID_EXTERNO_BODEGA__c = externalId
        );
        insert bodega;
        return bodega;
    }

    private static ProductoXBodega__c makeProductWarehouse(Id productId, Id bodegaId, Decimal quantity) {
        ProductoXBodega__c pxb = new ProductoXBodega__c(
            Name = 'QS PXB ' + uid(),
            Producto__c = productId,
            Bodega__c = bodegaId,
            Disponible__c = quantity
        );
        insert pxb;
        return pxb;
    }

    private static Oportunidad_Producto_Interes__c makeInterest(Id oppId, Id productId, String brand, String model, String year, Decimal price) {
        TriggerHandler.bypass('OportunidadProductoInteresTriggerHandler');

        Oportunidad_Producto_Interes__c interest = new Oportunidad_Producto_Interes__c(
            Oportunidad__c = oppId,
            Producto__c = productId,
            Marca__c = brand,
            Modelo_Interes__c = model,
            Anio__c = year,
            Precio_Unitario__c = price,
            Cantidad__c = 1,
            Comision_Porcentaje_Vendedor__c = 1,
            Comision_Porcentaje_Jefe__c = 1,
            Comision_Porcentaje_Gerente__c = 1
        );
        insert interest;
        return interest;
    }

    private static Quote makeQuote(Id oppId, Id pricebookId) {
        TriggerHandler.bypass('BMW_QuoteLineItemHandlerTrigger');
        TriggerHandler.bypass('QuoteLineItemTriggerHandler');

        Quote quote = new Quote(
            Name = 'QS Quote ' + uid(),
            OpportunityId = oppId,
            Pricebook2Id = pricebookId,
            Status = 'Draft'
        );
        insert quote;
        return quote;
    }

    private static void makeSalesConfig(String brand, String year, Id pricebookId) {
        Configuracion_de_ventas__c config = new Configuracion_de_ventas__c(
            Name = brand,
            Marca__c = brand,
            Listas_de_Precios_Vigente__c = brand + ' - ' + year,
            RM_ListaPrecioSoftland__c = pricebookId
        );
        insert config;
    }

    @IsTest
    static void addVehicle_usesPavasForOtobaiVehicle() {
        TriggerHandler.bypass('OpportunityLineItemTriggerHandler');
        TriggerHandler.bypass('BMW_QuoteLineItemHandlerTrigger');
        TriggerHandler.bypass('QuoteLineItemTriggerHandler');

        Pricebook2 otobaiPb = makePricebook('Otobai Dolares');
        makeBodega('BR02', 'RMOTOBAIBR02');
        Bodega__c externalBodega = makeBodega('ZZ99', 'ZZ99');

        Product2 vehicle = makeProduct(true, 'KAWA-' + uid(), 'Kawasaki', '120', '2026');
        makePrice(otobaiPb.Id, vehicle.Id, 15000);
        makeSalesConfig('Kawasaki', '2026', otobaiPb.Id);

        Account acc = makeAccount();
        Opportunity opp = makeOpportunity(acc.Id, otobaiPb.Id, true);
        ProductoXBodega__c pxb = makeProductWarehouse(vehicle.Id, externalBodega.Id, 1);
        Oportunidad_Producto_Interes__c interest = makeInterest(opp.Id, vehicle.Id, 'Kawasaki', '120', '2026', 15000);

        Test.startTest();
        Map<String, Object> response = QuoteService.addVehicle(opp.Id, interest.Id, pxb.Id, null);
        Test.stopTest();

        String addVehicleMessage = response.containsKey('message') ? (String) response.get('message') : 'addVehicle failed';
        System.assertEquals(true, response.get('success'), addVehicleMessage);
        QuoteLineItem qli = [
            SELECT BMW_Bodega__r.Bodega__c, BMW_Bodega__r.ID_EXTERNO_BODEGA__c
            FROM QuoteLineItem
            WHERE Oportunidad_Producto_Interes__c = :interest.Id
            LIMIT 1
        ];
        System.assertEquals('BR02', qli.BMW_Bodega__r.Bodega__c);
        System.assertEquals('RMOTOBAIBR02', qli.BMW_Bodega__r.ID_EXTERNO_BODEGA__c);
    }

    @IsTest
    static void addVehicle_pekingVehicleStopsBeforeBavarianBodegaFallback() {
        Pricebook2 pekingPb = makePricebook('PEKING Dolares');
        Bodega__c externalBodega = makeBodega('ZZ94', 'ZZ94');

        Product2 vehicle = makeProduct(true, 'PEK-' + uid(), 'Omoda', 'C5', '2026');

        Account acc = makeAccount();
        Opportunity opp = makeOpportunity(acc.Id, pekingPb.Id, false);
        ProductoXBodega__c pxb = makeProductWarehouse(vehicle.Id, externalBodega.Id, 1);
        Oportunidad_Producto_Interes__c interest = makeInterest(opp.Id, vehicle.Id, 'BMW', 'C5', '2026', 16000);

        Test.startTest();
        Boolean thrown = false;
        try {
            QuoteService.addVehicle(opp.Id, interest.Id, pxb.Id, null);
        } catch (AuraHandledException e) {
            thrown = true;
        }
        Test.stopTest();

        System.assertEquals(true, thrown, 'PEKING debe detenerse porque no existe bodega principal confirmada.');
        System.assertEquals(
            0,
            [SELECT COUNT() FROM QuoteLineItem WHERE Oportunidad_Producto_Interes__c = :interest.Id],
            'No debe crear líneas parciales para PEKING sin bodega confirmada.'
        );
    }

    @IsTest
    static void addVehicle_validationAndErrorBranches() {
        Pricebook2 otobaiPb = makePricebook('Otobai Dolares');
        makeBodega('BR02', 'RMOTOBAIBR02');
        Bodega__c bodega = makeBodega('ZZ97', 'ZZ97');
        Product2 vehicle = makeProduct(true, 'VAL-' + uid(), 'Kawasaki', '120', '2026');
        ProductoXBodega__c pxb = makeProductWarehouse(vehicle.Id, bodega.Id, 1);

        Account acc = makeAccount();
        Opportunity opp = makeOpportunity(acc.Id, otobaiPb.Id, true);
        Oportunidad_Producto_Interes__c interest = makeInterest(opp.Id, vehicle.Id, 'Kawasaki', '120', '2026', 15000);

        Test.startTest();
        Map<String, Object> noOpp = QuoteService.addVehicle(null, interest.Id, pxb.Id, null);
        Map<String, Object> noInterest = QuoteService.addVehicle(opp.Id, null, pxb.Id, null);
        Map<String, Object> noPxb = QuoteService.addVehicle(opp.Id, interest.Id, null, null);
        Map<String, Object> noConfig = QuoteService.addVehicle(opp.Id, interest.Id, pxb.Id, null);
        Test.stopTest();

        System.assertEquals(false, noOpp.get('success'));
        System.assertEquals(false, noInterest.get('success'));
        System.assertEquals(false, noPxb.get('success'));
        System.assertEquals(false, noConfig.get('success'));
    }

    @IsTest
    static void addVehicle_missingRelatedRecordsAndPrice() {
        Pricebook2 otobaiPb = makePricebook('Otobai Dolares');
        makeBodega('BR02', 'RMOTOBAIBR02');
        Bodega__c bodega = makeBodega('ZZ96', 'ZZ96');
        Product2 vehicle = makeProduct(true, 'NOPBE-' + uid(), 'Kawasaki', '120', '2026');
        ProductoXBodega__c pxb = makeProductWarehouse(vehicle.Id, bodega.Id, 1);

        Account acc = makeAccount();
        Opportunity opp = makeOpportunity(acc.Id, otobaiPb.Id, true);
        Oportunidad_Producto_Interes__c interest = makeInterest(opp.Id, vehicle.Id, 'Kawasaki', '120', '2026', 15000);
        makeSalesConfig('Kawasaki', '2026', otobaiPb.Id);

        ProductoXBodega__c deletedPxb = makeProductWarehouse(vehicle.Id, bodega.Id, 1);
        Id deletedPxbId = deletedPxb.Id;
        delete deletedPxb;

        Oportunidad_Producto_Interes__c deletedInterest = makeInterest(opp.Id, vehicle.Id, 'Kawasaki', '120', '2026', 15000);
        Id deletedInterestId = deletedInterest.Id;
        delete deletedInterest;

        Test.startTest();
        Map<String, Object> pxbNotFound = QuoteService.addVehicle(opp.Id, interest.Id, deletedPxbId, null);
        Map<String, Object> interestNotFound = QuoteService.addVehicle(opp.Id, deletedInterestId, pxb.Id, null);
        Map<String, Object> noPbe = QuoteService.addVehicle(opp.Id, interest.Id, pxb.Id, null);
        Test.stopTest();

        System.assertEquals(false, pxbNotFound.get('success'));
        System.assertEquals(false, interestNotFound.get('success'));
        System.assertEquals(false, noPbe.get('success'));
    }

    @IsTest
    static void addVehicle_differentModelWithoutFantasyPriceThrows() {
        Pricebook2 otobaiPb = makePricebook('Otobai Dolares');
        makeBodega('BR02', 'RMOTOBAIBR02');
        Bodega__c bodega = makeBodega('ZZ95', 'ZZ95');
        Product2 vehicle = makeProduct(true, 'DIFF-' + uid(), 'Kawasaki', '120', '2026');
        makePrice(otobaiPb.Id, vehicle.Id, 15000);
        makeSalesConfig('Kawasaki', '2026', otobaiPb.Id);

        Account acc = makeAccount();
        Opportunity opp = makeOpportunity(acc.Id, otobaiPb.Id, true);
        ProductoXBodega__c pxb = makeProductWarehouse(vehicle.Id, bodega.Id, 1);
        Oportunidad_Producto_Interes__c interest = makeInterest(opp.Id, vehicle.Id, 'Kawasaki', 'DIFFERENT', '2026', 15000);

        Boolean thrown = false;
        Test.startTest();
        try {
            QuoteService.addVehicle(opp.Id, interest.Id, pxb.Id, null);
        } catch (AuraHandledException e) {
            thrown = true;
        }
        Test.stopTest();

        System.assertEquals(true, thrown);
    }

    @IsTest
    static void addLineItem_extraUsesQuoteDefaultBodega() {
        TriggerHandler.bypass('BMW_QuoteLineItemHandlerTrigger');
        TriggerHandler.bypass('QuoteLineItemTriggerHandler');
        TriggerHandler.bypass('OpportunityTriggerHandler');

        Pricebook2 otobaiPb = makePricebook('Otobai Dolares');
        makeBodega('BR01', 'BR01');
        makeBodega('BR02', 'RMOTOBAIBR02');
        Bodega__c externalBodega = makeBodega('ZZ98', 'ZZ98');

        Product2 extra = makeProduct(false, 'EXT-' + uid(), 'Kawasaki', '120', '2026');
        makePrice(otobaiPb.Id, extra.Id, 300);

        Account acc = makeAccount();
        Opportunity opp = makeOpportunity(acc.Id, otobaiPb.Id, true);
        Quote quote = makeQuote(opp.Id, otobaiPb.Id);
        ProductoXBodega__c pxb = makeProductWarehouse(extra.Id, externalBodega.Id, 2);

        Test.startTest();
        Map<String, Object> response = QuoteService.addLineItem(
            quote.Id,
            pxb.Id,
            null,
            false,
            true,
            'extra',
            'Extra alias',
            2,
            300
        );
        Test.stopTest();

        String addExtraMessage = response.containsKey('message') ? (String) response.get('message') : 'addLineItem extra failed';
        System.assertEquals(true, response.get('success'), addExtraMessage);
        QuoteLineItem qli = [
            SELECT BMW_Bodega__r.Bodega__c, BMW_Bodega__r.ID_EXTERNO_BODEGA__c, Total_Extra__c
            FROM QuoteLineItem
            WHERE QuoteId = :quote.Id
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        System.assertEquals('BR02', qli.BMW_Bodega__r.Bodega__c);
        System.assertEquals('RMOTOBAIBR02', qli.BMW_Bodega__r.ID_EXTERNO_BODEGA__c);
        System.assertEquals(600, qli.Total_Extra__c);
    }

    @IsTest
    static void addLineItem_pekingQuoteStopsBeforeBavarianBodegaFallback() {
        TriggerHandler.bypass('BMW_QuoteLineItemHandlerTrigger');
        TriggerHandler.bypass('QuoteLineItemTriggerHandler');
        TriggerHandler.bypass('OpportunityTriggerHandler');

        Pricebook2 pekingPb = makePricebook('PEKING Dolares');
        Bodega__c externalBodega = makeBodega('ZZ93', 'ZZ93');

        Product2 extra = makeProduct(false, 'PEKEXT-' + uid(), 'Omoda', 'C5', '2026');
        makePrice(pekingPb.Id, extra.Id, 300);

        Account acc = makeAccount();
        Opportunity opp = makeOpportunity(acc.Id, pekingPb.Id, false);
        opp.Empresa_Operadora__c = makeEmpresa('RMPEKING').Id;
        update opp;

        Quote quote = makeQuote(opp.Id, pekingPb.Id);
        ProductoXBodega__c pxb = makeProductWarehouse(extra.Id, externalBodega.Id, 2);

        Test.startTest();
        Boolean thrown = false;
        try {
            QuoteService.addLineItem(
                quote.Id,
                pxb.Id,
                null,
                false,
                true,
                'extra',
                'Extra PEKING',
                2,
                300
            );
        } catch (AuraHandledException e) {
            thrown = true;
        }
        Test.stopTest();

        System.assertEquals(true, thrown, 'PEKING debe detenerse porque no existe bodega principal confirmada.');
        System.assertEquals(
            0,
            [SELECT COUNT() FROM QuoteLineItem WHERE QuoteId = :quote.Id],
            'No debe crear líneas parciales para PEKING sin bodega confirmada.'
        );
    }

    @IsTest
    static void addLineItem_failureBranchesAndPrincipalBodega() {
        TriggerHandler.bypass('BMW_QuoteLineItemHandlerTrigger');
        TriggerHandler.bypass('QuoteLineItemTriggerHandler');
        TriggerHandler.bypass('OpportunityTriggerHandler');

        Pricebook2 otobaiPb = makePricebook('Otobai Dolares');
        Bodega__c pavas = makeBodega('BR02', 'RMOTOBAIBR02');
        Product2 extra = makeProduct(false, 'PXBERR-' + uid(), 'Kawasaki', '120', '2026');
        makePrice(otobaiPb.Id, extra.Id, 300);

        Account acc = makeAccount();
        Opportunity opp = makeOpportunity(acc.Id, otobaiPb.Id, true);
        Quote quote = makeQuote(opp.Id, otobaiPb.Id);
        ProductoXBodega__c pavasPxb = makeProductWarehouse(extra.Id, pavas.Id, 2);

        ProductoXBodega__c deletedPxb = makeProductWarehouse(extra.Id, pavas.Id, 1);
        Id deletedPxbId = deletedPxb.Id;
        delete deletedPxb;

        Quote deletedQuote = makeQuote(opp.Id, otobaiPb.Id);
        Id deletedQuoteId = deletedQuote.Id;
        delete deletedQuote;

        Product2 noPriceProduct = makeProduct(false, 'NOPR-' + uid(), 'Kawasaki', '120', '2026');
        ProductoXBodega__c noPricePxb = makeProductWarehouse(noPriceProduct.Id, pavas.Id, 1);

        Test.startTest();
        Map<String, Object> pxbNotFound = QuoteService.addLineItem(
            quote.Id, deletedPxbId, null, false, true, 'extra', 'Alias', 1, 300
        );
        Map<String, Object> quoteNotFound = QuoteService.addLineItem(
            deletedQuoteId, pavasPxb.Id, null, false, true, 'extra', 'Alias', 1, 300
        );
        Map<String, Object> priceNotFound = QuoteService.addLineItem(
            quote.Id, noPricePxb.Id, null, false, true, 'extra', 'Alias', 1, 300
        );
        Map<String, Object> success = QuoteService.addLineItem(
            quote.Id, pavasPxb.Id, null, true, false, 'extra', 'Alias', 1, 300
        );
        Test.stopTest();

        System.assertEquals(false, pxbNotFound.get('success'));
        System.assertEquals(false, quoteNotFound.get('success'));
        System.assertEquals(false, priceNotFound.get('success'));
        System.assertEquals(true, success.get('success'));
    }

    @IsTest
    static void addLineItem_manoObraAndValidations() {
        Pricebook2 otobaiPb = makePricebook('Otobai Dolares');
        Product2 labor = makeLaborProduct('SUB-MOT');
        makePrice(otobaiPb.Id, labor.Id, 100);

        Account acc = makeAccount();
        Opportunity opp = makeOpportunity(acc.Id, otobaiPb.Id, true);
        Quote quote = makeQuote(opp.Id, otobaiPb.Id);

        Test.startTest();
        Map<String, Object> invalidQty = QuoteService.addLineItem(
            quote.Id, labor.Id, null, false, false, 'mano obra', 'Labor', 0, 100
        );
        Map<String, Object> invalidPrice = QuoteService.addLineItem(
            quote.Id, labor.Id, null, false, false, 'mano obra', 'Labor', 1, 0
        );
        Map<String, Object> success = QuoteService.addLineItem(
            quote.Id, labor.Id, null, false, false, 'mano obra', 'Labor', 2, 100
        );
        Test.stopTest();

        System.assertEquals(false, invalidQty.get('success'));
        System.assertEquals(false, invalidPrice.get('success'));
        String laborMessage = success.containsKey('message') ? (String) success.get('message') : 'addLineItem labor failed';
        System.assertEquals(true, success.get('success'), laborMessage);
    }

    @IsTest
    static void helperMethods_coverBranches() {
        Oportunidad_Producto_Interes__c interest = new Oportunidad_Producto_Interes__c(
            Marca__c = 'BMW',
            Anio__c = '2025',
            Modelo_Interes__c = 'X1'
        );
        ProductoXBodega__c samePxb = new ProductoXBodega__c(
            Producto__r = new Product2(marcaVehiculo__c = 'BMW', Anno__c = '2025', modelo__c = 'X1')
        );
        ProductoXBodega__c differentPxb = new ProductoXBodega__c(
            Producto__r = new Product2(marcaVehiculo__c = 'Kawasaki', Anno__c = '2026', modelo__c = '120')
        );

        Test.startTest();
        Boolean sameModel = QuoteService.checkIfDifferentModel(interest, samePxb);
        Boolean differentModel = QuoteService.checkIfDifferentModel(interest, differentPxb);
        String missingPricebook = QuoteService.getSoftlandPriceBookId('NoBrand' + uid(), '2099');
        Test.stopTest();

        System.assertEquals(false, sameModel);
        System.assertEquals(true, differentModel);
        System.assertEquals(null, missingPricebook);
    }
}
