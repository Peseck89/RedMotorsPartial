@IsTest
public with sharing class cT_QuoteCrcPDFController_test {
    @IsTest
    static void usesBavarianLocalForBavarianDolar() {
        assertPricebookConversion(
            'Bavarian Dólar',
            'Bavarian Local',
            'RMBAVARIAN',
            201,
            101,
            'CTQ-CRC-BAV'
        );
    }

    @IsTest
    static void usesOtobaiLocalForOtobaiDolares() {
        assertPricebookConversion(
            'Otobai Dólares',
            'Otobai Local',
            'RMOTOBAI',
            202,
            102,
            'CTQ-CRC-OTO'
        );
    }

    @IsTest
    static void usesPekingLocalForPekingDolares() {
        assertPricebookConversion(
            'PEKING Dólares',
            'PEKING Local',
            'RMPEKING',
            203,
            103,
            'CTQ-CRC-PEK'
        );
    }

    @IsTest
    static void unknownPricebookDoesNotSelectAuthorizedCompany() {
        Quote quoteRecord = createQuoteWithLine(
            'Lista dólares desconocida',
            null,
            'RMUNKNOWN',
            'USD',
            204,
            null,
            'CTQ-CRC-UNKNOWN'
        );

        Test.startTest();
        cT_QuoteCrcPDFController controller =
            new cT_QuoteCrcPDFController(new ApexPages.StandardController(quoteRecord));
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
                    'Bavarian Local',
                    'Otobai Local',
                    'PEKING Local'
                )
            ],
            'El escenario desconocido no debe depender de Pricebooks autorizados.'
        );
    }

    @IsTest
    static void crcQuoteKeepsDirectPrice() {
        Quote quoteRecord = createQuoteWithLine(
            'Lista CRC directa',
            null,
            'RMUNKNOWNCRC',
            'CRC',
            105,
            null,
            'CTQ-CRC-DIRECT'
        );

        Test.startTest();
        cT_QuoteCrcPDFController controller =
            new cT_QuoteCrcPDFController(new ApexPages.StandardController(quoteRecord));
        Test.stopTest();

        System.assertEquals(1, controller.quoteLine.size());
        System.assertEquals(1, controller.quoteLine[0].Quantity);
        System.assertEquals(105.0, controller.quoteLine[0].UnitPrice);
        System.assertEquals(105.0, controller.quoteLine[0].TotalPrice);
    }

    private static void assertPricebookConversion(
        String sourcePricebookName,
        String targetPricebookName,
        String companyCode,
        Decimal sourcePrice,
        Decimal targetPrice,
        String productCode
    ) {
        Quote quoteRecord = createQuoteWithLine(
            sourcePricebookName,
            targetPricebookName,
            companyCode,
            'USD',
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
              AND CurrencyIsoCode = 'CRC'
            LIMIT 1
        ];

        Test.startTest();
        cT_QuoteCrcPDFController controller =
            new cT_QuoteCrcPDFController(new ApexPages.StandardController(quoteRecord));
        Test.stopTest();

        System.assertEquals(targetPricebookName, targetEntry.Pricebook2.Name);
        System.assertEquals(product.Id, targetEntry.Product2Id);
        System.assertEquals(1, controller.quoteLine.size());
        System.assertEquals(1, controller.quoteLine[0].Quantity);
        System.assertEquals(
            Double.valueOf(String.valueOf(targetPrice)),
            controller.quoteLine[0].UnitPrice,
            'Debe usar el precio CRC del mismo producto en el Pricebook destino.'
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
        String companyCode,
        String quoteCurrency,
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

        Empresa__c company = new Empresa__c(
            Name = 'Empresa ' + productCode,
            Codigo__c = companyCode,
            Codigo_ERP__c = companyCode,
            Nombre_Legal__c = 'Empresa ' + productCode,
            Activa__c = true
        );
        insert company;

        WorkOrder workOrderRecord = new WorkOrder(
            AccountId = accountRecord.Id,
            AssetId = assetRecord.Id,
            Kilometros__c = 120,
            CurrencyIsoCode = quoteCurrency,
            Pricebook2Id = sourcePricebook.Id,
            empresaFacturaCP__c = company.Id
        );
        insert workOrderRecord;

        Opportunity opportunityRecord = new Opportunity(
            AccountId = accountRecord.Id,
            CloseDate = System.today().addMonths(1),
            StageName = 'Oportunidad Calificada',
            CurrencyIsoCode = quoteCurrency,
            IngresoAproximado__c = 1500,
            BMW_PlacaDeVehiculoOElVIN__c = assetRecord.Id,
            WorkOrder__c = workOrderRecord.Id,
            RT_Lead__c = 'BMW'
        );
        insert opportunityRecord;

        Product2 product = new Product2(
            Name = 'Producto ' + productCode,
            ProductCode = productCode,
            Codigo_de_Producto__c = productCode,
            IsActive = true
        );
        insert product;

        ensureStandardPrice(product.Id, quoteCurrency, sourcePrice);
        if (targetPricebook != null) {
            ensureStandardPrice(product.Id, 'CRC', targetPrice);
        }

        PricebookEntry sourceEntry = new PricebookEntry(
            Pricebook2Id = sourcePricebook.Id,
            Product2Id = product.Id,
            CurrencyIsoCode = quoteCurrency,
            UnitPrice = sourcePrice,
            IsActive = true
        );
        insert sourceEntry;

        if (targetPricebook != null) {
            insert new PricebookEntry(
                Pricebook2Id = targetPricebook.Id,
                Product2Id = product.Id,
                CurrencyIsoCode = 'CRC',
                UnitPrice = targetPrice,
                IsActive = true
            );
        }

        Quote quoteRecord = new Quote(
            Name = 'Quote ' + productCode,
            OpportunityId = opportunityRecord.Id,
            CurrencyIsoCode = quoteCurrency,
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
