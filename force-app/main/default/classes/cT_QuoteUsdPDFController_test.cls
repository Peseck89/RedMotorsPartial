@IsTest
public with sharing class cT_QuoteUsdPDFController_test {
    @IsTest
    static void usesBavarianDolarForBavarianLocal() {
        assertPricebookConversion(
            'Bavarian Local',
            'Bavarian Dólar',
            101,
            201,
            'CTQ-USD-BAV'
        );
    }

    @IsTest
    static void usesOtobaiDolaresForOtobaiLocal() {
        assertPricebookConversion(
            'Otobai Local',
            'Otobai Dólares',
            102,
            202,
            'CTQ-USD-OTO'
        );
    }

    @IsTest
    static void usesPekingDolaresForPekingLocal() {
        assertPricebookConversion(
            'PEKING Local',
            'PEKING Dólares',
            103,
            203,
            'CTQ-USD-PEK'
        );
    }

    @IsTest
    static void unknownPricebookDoesNotSelectAuthorizedCompany() {
        Quote quoteRecord = createQuoteWithLine(
            'Lista desconocida',
            null,
            104,
            null,
            'CTQ-USD-UNKNOWN'
        );

        Test.startTest();
        cT_QuoteUsdPDFController controller =
            new cT_QuoteUsdPDFController(new ApexPages.StandardController(quoteRecord));
        Test.stopTest();

        System.assertNotEquals(null, controller.quoteLine);
        System.assertEquals(
            0,
            controller.quoteLine.size(),
            'Un Pricebook desconocido no debe seleccionar listas Bavarian, Otobai o PEKING.'
        );
        System.assertEquals(
            0,
            [
                SELECT COUNT()
                FROM Pricebook2
                WHERE Name IN (
                    'Bavarian Dólar',
                    'Otobai Dólares',
                    'PEKING Dólares'
                )
            ],
            'El escenario desconocido no debe depender de Pricebooks autorizados.'
        );
    }

    private static void assertPricebookConversion(
        String sourcePricebookName,
        String targetPricebookName,
        Decimal sourcePrice,
        Decimal targetPrice,
        String productCode
    ) {
        Quote quoteRecord = createQuoteWithLine(
            sourcePricebookName,
            targetPricebookName,
            sourcePrice,
            targetPrice,
            productCode
        );

        Product2 product = [
            SELECT Id
            FROM Product2
            WHERE Codigo_de_Producto__c = :productCode
            LIMIT 1
        ];
        PricebookEntry targetEntry = [
            SELECT Pricebook2.Name, Product2Id, UnitPrice
            FROM PricebookEntry
            WHERE Pricebook2.Name = :targetPricebookName
              AND Product2Id = :product.Id
              AND CurrencyIsoCode = 'USD'
            LIMIT 1
        ];

        Test.startTest();
        cT_QuoteUsdPDFController controller =
            new cT_QuoteUsdPDFController(new ApexPages.StandardController(quoteRecord));
        Test.stopTest();

        System.assertEquals(targetPricebookName, targetEntry.Pricebook2.Name);
        System.assertEquals(product.Id, targetEntry.Product2Id);
        System.assertEquals(1, controller.quoteLine.size());
        System.assertEquals(1, controller.quoteLine[0].Quantity);
        System.assertEquals(
            Double.valueOf(String.valueOf(targetPrice)),
            controller.quoteLine[0].UnitPrice,
            'Debe usar el precio USD del mismo producto en el Pricebook destino.'
        );
        System.assertEquals(
            Double.valueOf(String.valueOf(targetPrice)),
            controller.quoteLine[0].TotalPrice,
            'Debe conservar el cálculo existente de cantidad por precio destino.'
        );
    }

    private static Quote createQuoteWithLine(
        String sourcePricebookName,
        String targetPricebookName,
        Decimal sourcePrice,
        Decimal targetPrice,
        String productCode
    ) {
        Account accountRecord = new Account(
            FirstName = 'PDF',
            LastName = productCode
        );
        insert accountRecord;

        Asset assetRecord = new Asset(
            Name = 'Asset ' + productCode,
            AccountId = accountRecord.Id
        );
        insert assetRecord;

        Opportunity opportunityRecord = new Opportunity(
            AccountId = accountRecord.Id,
            CloseDate = System.today().addMonths(1),
            StageName = 'Oportunidad Calificada',
            CurrencyIsoCode = 'CRC',
            IngresoAproximado__c = 1500,
            BMW_PlacaDeVehiculoOElVIN__c = assetRecord.Id,
            RT_Lead__c = 'BMW'
        );
        insert opportunityRecord;

        WorkOrder workOrderRecord = new WorkOrder(
            AccountId = accountRecord.Id,
            AssetId = assetRecord.Id,
            Kilometros__c = 120
        );
        insert workOrderRecord;

        Pricebook2 sourcePricebook = new Pricebook2(
            Name = sourcePricebookName,
            IsActive = true
        );
        insert sourcePricebook;

        Pricebook2 targetPricebook;
        if (targetPricebookName != null) {
            targetPricebook = new Pricebook2(
                Name = targetPricebookName,
                IsActive = true
            );
            insert targetPricebook;
        }

        Product2 product = new Product2(
            Name = 'Producto ' + productCode,
            ProductCode = productCode,
            Codigo_de_Producto__c = productCode,
            IsActive = true
        );
        insert product;

        ensureStandardPrice(product.Id, 'CRC', sourcePrice);
        if (targetPricebook != null) {
            ensureStandardPrice(product.Id, 'USD', targetPrice);
        }

        PricebookEntry sourceEntry = new PricebookEntry(
            Pricebook2Id = sourcePricebook.Id,
            Product2Id = product.Id,
            CurrencyIsoCode = 'CRC',
            UnitPrice = sourcePrice,
            IsActive = true
        );
        insert sourceEntry;

        if (targetPricebook != null) {
            insert new PricebookEntry(
                Pricebook2Id = targetPricebook.Id,
                Product2Id = product.Id,
                CurrencyIsoCode = 'USD',
                UnitPrice = targetPrice,
                IsActive = true
            );
        }

        Quote quoteRecord = new Quote(
            Name = 'Quote ' + productCode,
            OpportunityId = opportunityRecord.Id,
            CurrencyIsoCode = 'CRC',
            Pricebook2Id = sourcePricebook.Id
        );
        insert quoteRecord;

        Bodega__c warehouse = new Bodega__c(
            Name = 'Bodega ' + productCode,
            bodega__c = productCode
        );
        insert warehouse;

        insert new ProductoXBodega__c(
            Producto__c = product.Id,
            Bodega__c = warehouse.Id
        );

        insert new QuoteLineItem(
            QuoteId = quoteRecord.Id,
            Quantity = 1,
            PricebookEntryId = sourceEntry.Id,
            UnitPrice = sourcePrice,
            BMW_Bodega__c = warehouse.Id
        );

        return quoteRecord;
    }

    private static void ensureStandardPrice(
        Id productId,
        String currencyIsoCode,
        Decimal unitPrice
    ) {
        Id standardPricebookId = Test.getStandardPricebookId();
        List<PricebookEntry> existingEntries = [
            SELECT Id
            FROM PricebookEntry
            WHERE Pricebook2Id = :standardPricebookId
              AND Product2Id = :productId
              AND CurrencyIsoCode = :currencyIsoCode
        ];
        if (existingEntries.isEmpty()) {
            insert new PricebookEntry(
                Pricebook2Id = standardPricebookId,
                Product2Id = productId,
                CurrencyIsoCode = currencyIsoCode,
                UnitPrice = unitPrice,
                IsActive = true
            );
        }
    }
}
