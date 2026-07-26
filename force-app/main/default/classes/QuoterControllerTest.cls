@IsTest
private class QuoterControllerTest {
    private class Scenario {
        Opportunity opportunity;
        Empresa__c company;
        Product2 product;
        ProductoXBodega__c productByWarehouse;
        Oportunidad_Producto_Interes__c interest;
        Pricebook2 pricebook;
        PricebookEntry pricebookEntry;
    }

    @IsTest
    static void createQuoteUsesBavarianLookup() {
        assertCreateQuote('RMBAVARIAN', 'Otobai', 'Bavarian Dólar');
    }

    @IsTest
    static void createQuoteUsesOtobaiLookup() {
        assertCreateQuote('RMOTOBAI', 'Bavarian', 'Otobai Dólares');
    }

    @IsTest
    static void createQuoteUsesPekingLookup() {
        assertCreateQuote('RMPEKING', null, 'PEKING Dólares');
    }

    @IsTest
    static void pekingLookupHasPriorityOverBavarianLegacy() {
        assertCreateQuote('RMPEKING', 'Bavarian', 'PEKING Dólares');
    }

    @IsTest
    static void emptyLookupKeepsBavarianLegacy() {
        assertCreateQuote(null, 'Bavarian', 'Bavarian Dólar');
    }

    @IsTest
    static void emptyLookupKeepsOtobaiLegacy() {
        assertCreateQuote(null, 'Otobai', 'Otobai Dólares');
    }

    @IsTest
    static void nullCompanyDoesNotFallbackToBavarian() {
        Scenario scenario = createScenario(null, null, null, false, false);
        assertConfigurationFailureWithoutChanges(scenario);
    }

    @IsTest
    static void inactiveCompanyReturnsControlledError() {
        Scenario scenario = createScenario('RMPEKING', 'Bavarian', null, false, false);
        scenario.company.Activa__c = false;
        update scenario.company;
        assertConfigurationFailureWithoutChanges(scenario);
    }

    @IsTest
    static void missingPricebookPreservesOpportunityAndLines() {
        Scenario scenario = createScenario('RMPEKING', 'Bavarian', null, false, false);
        createExistingOpportunityLine(scenario);
        Id originalPricebookId = [
            SELECT Pricebook2Id FROM Opportunity WHERE Id = :scenario.opportunity.Id
        ].Pricebook2Id;
        Integer originalLines = [
            SELECT COUNT() FROM OpportunityLineItem
            WHERE OpportunityId = :scenario.opportunity.Id
        ];
        Boolean controlled = false;

        Test.startTest();
        try {
            QuoterController.createQuote(
                scenario.interest.Id,
                scenario.productByWarehouse.Id,
                false,
                null
            );
            System.assert(false, 'Debe rechazar una empresa sin Pricebook activo.');
        } catch (AuraHandledException e) {
            controlled = true;
        }
        Test.stopTest();

        Opportunity afterFailure = [
            SELECT Pricebook2Id FROM Opportunity WHERE Id = :scenario.opportunity.Id
        ];
        System.assert(controlled, 'Debe producir un error controlado.');
        System.assertEquals(originalPricebookId, afterFailure.Pricebook2Id, 'No debe cambiar el Pricebook.');
        System.assertEquals(
            originalLines,
            [SELECT COUNT() FROM OpportunityLineItem WHERE OpportunityId = :scenario.opportunity.Id],
            'No debe eliminar líneas existentes.'
        );
        System.assertEquals(
            0,
            [SELECT COUNT() FROM Quote WHERE OpportunityId = :scenario.opportunity.Id],
            'No debe crear una Quote parcial.'
        );
    }

    @IsTest
    static void missingPricebookEntryPreservesOpportunityAndLines() {
        Scenario scenario = createScenario('RMPEKING', 'Bavarian', 'PEKING Dólares', true, false);
        createExistingOpportunityLine(scenario);
        Id originalPricebookId = [
            SELECT Pricebook2Id FROM Opportunity WHERE Id = :scenario.opportunity.Id
        ].Pricebook2Id;
        Integer originalLines = [
            SELECT COUNT() FROM OpportunityLineItem
            WHERE OpportunityId = :scenario.opportunity.Id
        ];
        Boolean controlled = false;

        Test.startTest();
        try {
            QuoterController.createQuote(
                scenario.interest.Id,
                scenario.productByWarehouse.Id,
                false,
                null
            );
            System.assert(false, 'Debe rechazar un producto sin PricebookEntry empresarial.');
        } catch (AuraHandledException e) {
            controlled = true;
        }
        Test.stopTest();

        Opportunity afterFailure = [
            SELECT Pricebook2Id FROM Opportunity WHERE Id = :scenario.opportunity.Id
        ];
        System.assert(controlled, 'Debe producir un error controlado.');
        System.assertEquals(originalPricebookId, afterFailure.Pricebook2Id, 'No debe cambiar el Pricebook.');
        System.assertEquals(
            originalLines,
            [SELECT COUNT() FROM OpportunityLineItem WHERE OpportunityId = :scenario.opportunity.Id],
            'No debe eliminar líneas existentes.'
        );
        System.assertEquals(
            0,
            [SELECT COUNT() FROM Quote WHERE OpportunityId = :scenario.opportunity.Id],
            'No debe crear una Quote parcial.'
        );
    }

    @IsTest
    static void addLineItemUsesEffectivePekingPricebook() {
        Scenario scenario = createScenario('RMPEKING', 'Bavarian', 'PEKING Dólares', true, true);
        Pricebook2 bavarian = createPricebook('Bavarian Dólar');
        upsertStandardPrice(scenario.product.Id, 100);
        PricebookEntry bavarianEntry = createPrice(
            bavarian.Id,
            scenario.product.Id,
            110
        );
        update new Opportunity(
            Id = scenario.opportunity.Id,
            Pricebook2Id = scenario.pricebook.Id
        );
        Quote quote = new Quote(
            Name = 'Quote PEKING',
            OpportunityId = scenario.opportunity.Id,
            Pricebook2Id = scenario.pricebook.Id,
            CurrencyIsoCode = 'USD'
        );
        insert quote;

        Test.startTest();
        QuoterController.addLineItem(
            quote.Id,
            scenario.product.Id,
            null,
            false,
            false,
            'mano obra',
            'Mano de obra PEKING',
            2,
            75
        );
        Test.stopTest();

        QuoteLineItem line = [
            SELECT QuoteId, Product2Id, PricebookEntryId,
                   PricebookEntry.Pricebook2Id, Quantity, UnitPrice
            FROM QuoteLineItem
            WHERE QuoteId = :quote.Id
            LIMIT 1
        ];
        System.assertEquals(scenario.product.Id, line.Product2Id, 'Debe conservar el producto.');
        System.assertEquals(scenario.pricebookEntry.Id, line.PricebookEntryId, 'Debe usar la entrada PEKING.');
        System.assertNotEquals(bavarianEntry.Id, line.PricebookEntryId, 'No debe usar la entrada Bavarian.');
        System.assertEquals(scenario.pricebook.Id, line.PricebookEntry.Pricebook2Id, 'Debe respetar el Pricebook de la Quote.');
        System.assertEquals(2, line.Quantity, 'Debe conservar la cantidad.');
        System.assertEquals(75, line.UnitPrice, 'Debe conservar el precio recibido.');
    }

    @IsTest
    static void createQuoteChangesPricebookAfterValidatingExistingLines() {
        Scenario scenario = createScenario(
            'RMPEKING',
            'Bavarian',
            'PEKING Dólares',
            true,
            true
        );
        createExistingOpportunityLine(scenario);
        OpportunityLineItem previousLine = [
            SELECT Id, Product2Id, Quantity, UnitPrice
            FROM OpportunityLineItem
            WHERE OpportunityId = :scenario.opportunity.Id
            LIMIT 1
        ];

        Test.startTest();
        QuoterController.createQuote(
            scenario.interest.Id,
            scenario.productByWarehouse.Id,
            false,
            null
        );
        Test.stopTest();

        Opportunity updatedOpportunity = [
            SELECT Pricebook2Id
            FROM Opportunity
            WHERE Id = :scenario.opportunity.Id
        ];
        Quote quote = [
            SELECT Id, OpportunityId, Pricebook2Id
            FROM Quote
            WHERE OpportunityId = :scenario.opportunity.Id
            LIMIT 1
        ];
        QuoteLineItem createdLine = [
            SELECT QuoteId, Product2Id, PricebookEntryId,
                   PricebookEntry.Pricebook2Id, Quantity, UnitPrice
            FROM QuoteLineItem
            WHERE QuoteId = :quote.Id
            LIMIT 1
        ];

        System.assertEquals(
            0,
            [SELECT COUNT() FROM OpportunityLineItem WHERE Id = :previousLine.Id],
            'La línea anterior debe eliminarse después de validar la configuración.'
        );
        System.assertEquals(
            scenario.pricebook.Id,
            updatedOpportunity.Pricebook2Id,
            'Opportunity debe cambiar al Pricebook USD empresarial.'
        );
        System.assertEquals(scenario.opportunity.Id, quote.OpportunityId, 'La Quote debe pertenecer a la Opportunity.');
        System.assertEquals(scenario.pricebook.Id, quote.Pricebook2Id, 'La Quote debe usar el Pricebook empresarial.');
        System.assertEquals(scenario.product.Id, createdLine.Product2Id, 'Debe conservar el producto.');
        System.assertEquals(scenario.pricebookEntry.Id, createdLine.PricebookEntryId, 'Debe usar la entrada empresarial.');
        System.assertEquals(scenario.pricebook.Id, createdLine.PricebookEntry.Pricebook2Id, 'La entrada debe pertenecer al Pricebook empresarial.');
        System.assertEquals(1, createdLine.Quantity, 'Debe conservar la cantidad histórica.');
        System.assertEquals(99000, createdLine.UnitPrice, 'Debe conservar el precio esperado.');
    }

    @IsTest
    static void addGiftExtraUsesFixedCostFromEffectivePricebook() {
        Scenario scenario = createScenario(
            'RMPEKING',
            'Bavarian',
            'PEKING Dólares',
            true,
            true
        );
        scenario.pricebookEntry.Costo_Fijo__c = 45;
        update scenario.pricebookEntry;
        Quote quote = new Quote(
            Name = 'Quote Extra PEKING',
            OpportunityId = scenario.opportunity.Id,
            Pricebook2Id = scenario.pricebook.Id,
            CurrencyIsoCode = 'USD'
        );
        insert quote;

        Test.startTest();
        QuoterController.addLineItem(
            quote.Id,
            scenario.productByWarehouse.Id,
            null,
            true,
            true,
            'extra',
            'Regalía PEKING',
            2,
            999
        );
        Test.stopTest();

        QuoteLineItem line = [
            SELECT QuoteId, Product2Id, PricebookEntryId,
                   PricebookEntry.Pricebook2Id, Quantity, UnitPrice,
                   BMW_Bodega__c, Total_Extra__c, Total_Regalia__c
            FROM QuoteLineItem
            WHERE QuoteId = :quote.Id
            LIMIT 1
        ];
        Quote unchangedQuote = [
            SELECT Pricebook2Id
            FROM Quote
            WHERE Id = :quote.Id
        ];

        System.assertEquals(scenario.product.Id, line.Product2Id, 'Debe usar el producto de la bodega.');
        System.assertEquals(scenario.pricebookEntry.Id, line.PricebookEntryId, 'Debe usar la entrada empresarial.');
        System.assertEquals(scenario.pricebook.Id, line.PricebookEntry.Pricebook2Id, 'La entrada debe pertenecer al Pricebook efectivo.');
        System.assertEquals(scenario.productByWarehouse.Bodega__c, line.BMW_Bodega__c, 'Debe conservar la bodega.');
        System.assertEquals(2, line.Quantity, 'Debe conservar la cantidad.');
        System.assertEquals(45, line.UnitPrice, 'La regalía debe usar Costo_Fijo__c.');
        System.assertEquals(90, line.Total_Extra__c, 'Debe conservar el total de extra.');
        System.assertEquals(90, line.Total_Regalia__c, 'Debe conservar el total de regalía.');
        System.assertEquals(scenario.pricebook.Id, unchangedQuote.Pricebook2Id, 'No debe cambiar el Pricebook de la Quote.');
    }

    private static void assertCreateQuote(
        String lookupCode,
        String legacyCompany,
        String expectedPricebookName
    ) {
        Scenario scenario = createScenario(
            lookupCode,
            legacyCompany,
            expectedPricebookName,
            true,
            true
        );

        Test.startTest();
        QuoterController.createQuote(
            scenario.interest.Id,
            scenario.productByWarehouse.Id,
            false,
            null
        );
        Test.stopTest();

        Opportunity opportunity = [
            SELECT Pricebook2Id, Empresa_Operadora__c, BMW_Compania__c
            FROM Opportunity
            WHERE Id = :scenario.opportunity.Id
        ];
        Quote quote = [
            SELECT Id, OpportunityId, Pricebook2Id, CurrencyIsoCode
            FROM Quote
            WHERE OpportunityId = :scenario.opportunity.Id
            LIMIT 1
        ];
        QuoteLineItem line = [
            SELECT QuoteId, Product2Id, PricebookEntryId, Quantity, UnitPrice
            FROM QuoteLineItem
            WHERE QuoteId = :quote.Id
            LIMIT 1
        ];

        System.assertEquals(scenario.pricebook.Id, opportunity.Pricebook2Id, 'Opportunity debe usar el Pricebook empresarial.');
        System.assertEquals(scenario.pricebook.Id, quote.Pricebook2Id, 'Quote debe usar el Pricebook empresarial.');
        System.assertEquals('USD', quote.CurrencyIsoCode, 'Quote debe conservar USD.');
        System.assertEquals(scenario.product.Id, line.Product2Id, 'La línea debe conservar el producto.');
        System.assertEquals(scenario.pricebookEntry.Id, line.PricebookEntryId, 'La línea debe usar la entrada empresarial.');
        System.assertEquals(1, line.Quantity, 'La cantidad histórica debe permanecer en uno.');
        System.assertEquals(99000, line.UnitPrice, 'Debe conservar el precio del producto de interés.');
    }

    private static void assertConfigurationFailureWithoutChanges(Scenario scenario) {
        Id originalPricebookId = [
            SELECT Pricebook2Id FROM Opportunity WHERE Id = :scenario.opportunity.Id
        ].Pricebook2Id;
        Boolean controlled = false;

        Test.startTest();
        try {
            QuoterController.createQuote(
                scenario.interest.Id,
                scenario.productByWarehouse.Id,
                false,
                null
            );
            System.assert(false, 'La empresa inválida debe detener el proceso.');
        } catch (EmpresaConfigurationException e) {
            controlled = true;
        }
        Test.stopTest();

        Opportunity afterFailure = [
            SELECT Pricebook2Id FROM Opportunity WHERE Id = :scenario.opportunity.Id
        ];
        System.assert(controlled, 'Debe recibirse EmpresaConfigurationException.');
        System.assertEquals(originalPricebookId, afterFailure.Pricebook2Id, 'No debe cambiar Opportunity.');
        System.assertEquals(
            0,
            [SELECT COUNT() FROM Quote WHERE OpportunityId = :scenario.opportunity.Id],
            'No debe crear Quote.'
        );
        System.assertEquals(
            0,
            [SELECT COUNT() FROM QuoteLineItem WHERE Quote.OpportunityId = :scenario.opportunity.Id],
            'No debe crear líneas.'
        );
    }

    private static Scenario createScenario(
        String lookupCode,
        String legacyCompany,
        String pricebookName,
        Boolean createTargetPricebook,
        Boolean createTargetEntry
    ) {
        Scenario scenario = new Scenario();
        Account account = new Account(Name = 'Cuenta Quoter');
        insert account;

        if (lookupCode != null) {
            scenario.company = new Empresa__c(
                Name = 'Empresa ' + lookupCode,
                Codigo__c = lookupCode,
                Codigo_ERP__c = 'ERP-' + lookupCode,
                Nombre_Legal__c = 'Empresa ' + lookupCode + ' S.A.',
                Activa__c = true
            );
            insert scenario.company;
        }

        scenario.opportunity = new Opportunity(
            Name = 'Opportunity Quoter',
            AccountId = account.Id,
            StageName = activePicklistValue(Opportunity.StageName),
            CloseDate = Date.today().addDays(30),
            CurrencyIsoCode = 'USD',
            Empresa_Operadora__c = scenario.company == null ? null : scenario.company.Id,
            BMW_Compania__c = legacyCompany
        );
        insert scenario.opportunity;

        scenario.product = new Product2(
            Name = 'Producto Quoter',
            IsActive = true,
            tipoProducto__c = 'Materiales',
            Codigo_de_Producto__c = 'QTR-' + String.valueOf(DateTime.now().getTime())
        );
        insert scenario.product;

        Bodega__c warehouse = new Bodega__c(
            Name = 'Bodega Quoter',
            bodega__c = 'QTR'
        );
        insert warehouse;
        scenario.productByWarehouse = new ProductoXBodega__c(
            Name = 'Producto Bodega Quoter',
            Producto__c = scenario.product.Id,
            Bodega__c = warehouse.Id,
            Disponible__c = 1
        );
        insert scenario.productByWarehouse;

        scenario.interest = new Oportunidad_Producto_Interes__c(
            Oportunidad__c = scenario.opportunity.Id,
            Marca__c = fieldValue(Oportunidad_Producto_Interes__c.Marca__c, 'BMW'),
            Modelo_Interes__c = fieldValue(Oportunidad_Producto_Interes__c.Modelo_Interes__c, 'Modelo Quoter'),
            Familia__c = fieldValue(Oportunidad_Producto_Interes__c.Familia__c, 'Familia Quoter'),
            Anio__c = fieldValue(Oportunidad_Producto_Interes__c.Anio__c, String.valueOf(Date.today().year())),
            Precio_Unitario__c = 99000,
            Costo_Fijo__c = 10000
        );
        insert scenario.interest;

        if (createTargetPricebook) {
            scenario.pricebook = createPricebook(pricebookName);
            if (createTargetEntry) {
                upsertStandardPrice(scenario.product.Id, 100);
                scenario.pricebookEntry = createPrice(
                    scenario.pricebook.Id,
                    scenario.product.Id,
                    125
                );
                update new Opportunity(
                    Id = scenario.opportunity.Id,
                    Pricebook2Id = scenario.pricebook.Id
                );
            }
        }
        return scenario;
    }

    private static void createExistingOpportunityLine(Scenario scenario) {
        Pricebook2 existingPricebook = createPricebook('Existing Quoter Pricebook');
        upsertStandardPrice(scenario.product.Id, 100);
        PricebookEntry existingEntry = createPrice(
            existingPricebook.Id,
            scenario.product.Id,
            105
        );
        update new Opportunity(
            Id = scenario.opportunity.Id,
            Pricebook2Id = existingPricebook.Id
        );
        insert new OpportunityLineItem(
            OpportunityId = scenario.opportunity.Id,
            PricebookEntryId = existingEntry.Id,
            Quantity = 1,
            UnitPrice = 105
        );
    }

    private static Pricebook2 createPricebook(String name) {
        Pricebook2 pricebook = new Pricebook2(
            Name = name,
            IsActive = true
        );
        insert pricebook;
        return pricebook;
    }

    private static void upsertStandardPrice(Id productId, Decimal unitPrice) {
        Id standardPricebookId = Test.getStandardPricebookId();
        List<PricebookEntry> existing = [
            SELECT Id
            FROM PricebookEntry
            WHERE Pricebook2Id = :standardPricebookId
            AND Product2Id = :productId
            AND CurrencyIsoCode = 'USD'
            LIMIT 1
        ];
        if (existing.isEmpty()) {
            insert new PricebookEntry(
                Pricebook2Id = standardPricebookId,
                Product2Id = productId,
                CurrencyIsoCode = 'USD',
                UnitPrice = unitPrice,
                IsActive = true
            );
        }
    }

    private static PricebookEntry createPrice(
        Id pricebookId,
        Id productId,
        Decimal unitPrice
    ) {
        PricebookEntry entry = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = productId,
            CurrencyIsoCode = 'USD',
            UnitPrice = unitPrice,
            IsActive = true
        );
        insert entry;
        return entry;
    }

    private static String activePicklistValue(Schema.SObjectField fieldToken) {
        for (Schema.PicklistEntry entry : fieldToken.getDescribe().getPicklistValues()) {
            if (entry.isActive()) return entry.getValue();
        }
        return null;
    }

    private static String fieldValue(
        Schema.SObjectField fieldToken,
        String fallback
    ) {
        Schema.DescribeFieldResult description = fieldToken.getDescribe();
        if (
            description.getType() == Schema.DisplayType.Picklist ||
            description.getType() == Schema.DisplayType.MultiPicklist
        ) {
            return activePicklistValue(fieldToken);
        }
        return fallback;
    }
}
