@isTest
private class CrearPlandeVentaTest {
    @isTest
    static void copiesEmpresaOperadoraWithoutTransformingLookup() {
        Empresa__c empresa = new Empresa__c(
            Name = 'PEKING Test',
            Codigo__c = 'RMPEKING',
            Codigo_ERP__c = 'RMPEKING',
            Nombre_Legal__c = 'PEKING Test S.A.',
            Activa__c = true
        );
        insert empresa;

        Quote sourceQuote = createSourceQuote(
            empresa.Id,
            'Bavarian',
            'WITH-LOOKUP',
            true
        );
        Opportunity sourceBefore = [
            SELECT Empresa_Operadora__c, BMW_Compania__c,
                   Cuenta_de_Facturaci_n__c
            FROM Opportunity
            WHERE Id = :sourceQuote.OpportunityId
        ];

        Test.startTest();
        CrearPlandeVenta.FlowOutput output = executePlan(sourceQuote.Id);
        Test.stopTest();

        Quote createdQuote = [
            SELECT OpportunityId, Cuenta_de_facturaci_n2__c,
                   Opportunity.Empresa_Operadora__c,
                   Opportunity.BMW_Compania__c,
                   Opportunity.Cuenta_de_Facturaci_n__c
            FROM Quote
            WHERE Id = :output.newQuoteId
        ];
        Opportunity sourceAfter = [
            SELECT Empresa_Operadora__c, BMW_Compania__c,
                   Cuenta_de_Facturaci_n__c
            FROM Opportunity
            WHERE Id = :sourceQuote.OpportunityId
        ];

        System.assertNotEquals(sourceQuote.OpportunityId, createdQuote.OpportunityId);
        System.assertEquals(empresa.Id, createdQuote.Opportunity.Empresa_Operadora__c);
        System.assertEquals(
            sourceBefore.Empresa_Operadora__c,
            sourceAfter.Empresa_Operadora__c
        );
        System.assertEquals(sourceBefore.BMW_Compania__c, sourceAfter.BMW_Compania__c);
        System.assertEquals(
            sourceBefore.Cuenta_de_Facturaci_n__c,
            createdQuote.Opportunity.Cuenta_de_Facturaci_n__c
        );
        System.assertEquals(
            sourceBefore.Cuenta_de_Facturaci_n__c,
            createdQuote.Cuenta_de_facturaci_n2__c
        );
        System.assertEquals(
            sourceBefore.Cuenta_de_Facturaci_n__c,
            sourceAfter.Cuenta_de_Facturaci_n__c
        );
    }

    @isTest
    static void preservesNullLookupAndLegacyCompanyBehavior() {
        Quote sourceQuote = createSourceQuote(
            null,
            'Bavarian',
            'WITHOUT-LOOKUP',
            true
        );
        Opportunity sourceOpportunity = [
            SELECT RecordType.Name
            FROM Opportunity
            WHERE Id = :sourceQuote.OpportunityId
        ];
        String expectedLegacyCompany =
            expectedLegacyCompany(sourceOpportunity.RecordType.Name);

        Test.startTest();
        CrearPlandeVenta.FlowOutput output = executePlan(sourceQuote.Id);
        Test.stopTest();

        Quote createdQuote = [
            SELECT OpportunityId, Compania__c,
                   Opportunity.Empresa_Operadora__c,
                   Opportunity.BMW_Compania__c
            FROM Quote
            WHERE Id = :output.newQuoteId
        ];

        System.assertNotEquals(sourceQuote.OpportunityId, createdQuote.OpportunityId);
        System.assertEquals(null, createdQuote.Opportunity.Empresa_Operadora__c);
        System.assertEquals(expectedLegacyCompany, createdQuote.Opportunity.BMW_Compania__c);
        System.assertEquals(expectedLegacyCompany, createdQuote.Compania__c);
    }

    @isTest
    static void keepsLegacyBillingAccountAsFallbackWhenSourceIsEmpty() {
        Quote sourceQuote = createSourceQuote(
            null,
            'Bavarian',
            'EMPTY-BILLING-ACCOUNT',
            false
        );
        Opportunity sourceOpportunity = [
            SELECT RecordType.Name, Cuenta_de_Facturaci_n__c
            FROM Opportunity
            WHERE Id = :sourceQuote.OpportunityId
        ];
        System.assertEquals(null, sourceOpportunity.Cuenta_de_Facturaci_n__c);

        String expectedFallback = expectedBillingAccount(sourceOpportunity.RecordType.Name);
        Boolean receivedExpectedCrossReferenceError = false;
        Boolean messageContainsLegacyAccount = false;

        Test.startTest();
        try {
            CrearPlandeVenta.FlowInput input = new CrearPlandeVenta.FlowInput();
            input.quoteId = sourceQuote.Id;
            CrearPlandeVenta.ejecutar(
                new List<CrearPlandeVenta.FlowInput>{ input }
            );
            System.assert(false, 'El fallback legado debía conservarse');
        } catch (DmlException ex) {
            receivedExpectedCrossReferenceError =
                ex.getDmlType(0) ==
                    StatusCode.INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY;
            messageContainsLegacyAccount =
                ex.getMessage().contains(expectedFallback.left(15));
        }
        Test.stopTest();

        System.assert(
            receivedExpectedCrossReferenceError,
            'Debe recibirse el error de referencia cruzada esperado'
        );
        System.assert(
            messageContainsLegacyAccount,
            'Debe conservarse el ID fijo correspondiente al Record Type'
        );
    }

    @isTest
    static void returnsExistingPlanWhenGiftVehicleHasSameVin() {
        Quote sourceQuote = createSourceQuote(
            null,
            'Bavarian',
            'EXISTING-VIN',
            true
        );
        Product2 vehicle = addGiftLine(
            sourceQuote,
            'CPV-VEHICLE-VIN',
            'Vehiculo',
            'VIN-CPV-EXISTING',
            true
        );
        Opportunity sourceOpportunity = [
            SELECT AccountId, Cuenta_de_Facturaci_n__c
            FROM Opportunity
            WHERE Id = :sourceQuote.OpportunityId
        ];
        Id planSalesRecordTypeId = getAvailableRecordTypeId(
            Opportunity.SObjectType,
            'Planes_de_Venta'
        );
        Id workshopQuoteRecordTypeId = getAvailableRecordTypeId(
            Quote.SObjectType,
            'Taller'
        );
        Opportunity existingPlan = new Opportunity(
            Name = 'Existing Plan VIN',
            RecordTypeId = planSalesRecordTypeId,
            AccountId = sourceOpportunity.AccountId,
            Cuenta_de_Facturaci_n__c =
                sourceOpportunity.Cuenta_de_Facturaci_n__c,
            StageName = 'Oferta',
            CloseDate = Date.today().addDays(15),
            CurrencyIsoCode = 'USD',
            Pricebook2Id = sourceQuote.Pricebook2Id,
            VIN__c = vehicle.VIN__c
        );
        insert existingPlan;
        Quote existingQuote = new Quote(
            Name = 'Existing Quote VIN',
            RecordTypeId = workshopQuoteRecordTypeId,
            OpportunityId = existingPlan.Id,
            Pricebook2Id = sourceQuote.Pricebook2Id,
            CurrencyIsoCode = 'USD',
            ExpirationDate = Date.today().addDays(30)
        );
        insert existingQuote;

        Test.startTest();
        CrearPlandeVenta.FlowOutput output = executePlan(sourceQuote.Id);
        Test.stopTest();

        System.assertEquals(existingQuote.Id, output.newQuoteId);
        System.assertEquals(
            1,
            [
                SELECT COUNT()
                FROM Opportunity
                WHERE VIN__c = :vehicle.VIN__c
                AND RecordTypeId = :planSalesRecordTypeId
            ]
        );
    }

    @isTest
    static void copiesGiftLineWhenCompatiblePricebookEntryExists() {
        Quote sourceQuote = createSourceQuote(
            null,
            'Bavarian',
            'COMPATIBLE-GIFT',
            true
        );
        Product2 gift = addGiftLine(
            sourceQuote,
            'CPV-GIFT-COMPATIBLE',
            'Varios',
            null,
            true
        );

        Test.startTest();
        CrearPlandeVenta.FlowOutput output = executePlan(sourceQuote.Id);
        Test.stopTest();

        List<QuoteLineItem> copiedLines = [
            SELECT Product2Id, PricebookEntry.Pricebook2Id, Quantity,
                   UnitPrice, Discount, Description, ServiceDate
            FROM QuoteLineItem
            WHERE QuoteId = :output.newQuoteId
        ];
        System.assertEquals(1, copiedLines.size());
        System.assertEquals(gift.Id, copiedLines[0].Product2Id);
        System.assertEquals(sourceQuote.Pricebook2Id, copiedLines[0].PricebookEntry.Pricebook2Id);
        System.assertEquals(2, copiedLines[0].Quantity);
        System.assertEquals(25, copiedLines[0].UnitPrice);
        System.assertEquals(10, copiedLines[0].Discount);
        System.assertEquals('Regalía compatible', copiedLines[0].Description);
        System.assertEquals(Date.today().addDays(5), copiedLines[0].ServiceDate);
    }

    @isTest
    static void skipsGiftLineWhenCompatiblePricebookEntryIsInactive() {
        Quote sourceQuote = createSourceQuote(
            null,
            'Bavarian',
            'INACTIVE-GIFT',
            true
        );
        addGiftLine(
            sourceQuote,
            'CPV-GIFT-INACTIVE',
            'Varios',
            null,
            false
        );

        Test.startTest();
        CrearPlandeVenta.FlowOutput output = executePlan(sourceQuote.Id);
        Test.stopTest();

        System.assertEquals(
            0,
            [SELECT COUNT() FROM QuoteLineItem WHERE QuoteId = :output.newQuoteId]
        );
    }

    @isTest
    static void appliesOtobaiBranchForIndianRecordType() {
        Id indianRecordTypeId = getAvailableRecordTypeId(
            Opportunity.SObjectType,
            'Indian'
        );
        Quote sourceQuote = createSourceQuote(
            null,
            'Bavarian',
            'INDIAN-OTOBI-BRANCH',
            true,
            indianRecordTypeId
        );

        Test.startTest();
        CrearPlandeVenta.FlowOutput output = executePlan(sourceQuote.Id);
        Test.stopTest();

        Quote createdQuote = [
            SELECT Compania__c, Opportunity.BMW_Compania__c,
                   Cuenta_de_facturaci_n2__c,
                   Opportunity.Cuenta_de_Facturaci_n__c
            FROM Quote
            WHERE Id = :output.newQuoteId
        ];
        System.assertEquals('Otobai', createdQuote.Compania__c);
        System.assertEquals('Otobai', createdQuote.Opportunity.BMW_Compania__c);
        System.assertEquals(
            createdQuote.Opportunity.Cuenta_de_Facturaci_n__c,
            createdQuote.Cuenta_de_facturaci_n2__c
        );
    }

    private static CrearPlandeVenta.FlowOutput executePlan(Id sourceQuoteId) {
        CrearPlandeVenta.FlowInput input = new CrearPlandeVenta.FlowInput();
        input.quoteId = sourceQuoteId;

        List<CrearPlandeVenta.FlowOutput> outputs =
            CrearPlandeVenta.ejecutar(new List<CrearPlandeVenta.FlowInput>{ input });

        System.assertEquals(1, outputs.size());
        System.assertNotEquals(null, outputs[0].newQuoteId);
        return outputs[0];
    }

    private static Quote createSourceQuote(
        Id empresaOperadoraId,
        String legacyCompany,
        String scenario,
        Boolean useSourceBillingAccount
    ) {
        return createSourceQuote(
            empresaOperadoraId,
            legacyCompany,
            scenario,
            useSourceBillingAccount,
            null
        );
    }

    private static Quote createSourceQuote(
        Id empresaOperadoraId,
        String legacyCompany,
        String scenario,
        Boolean useSourceBillingAccount,
        Id opportunityRecordTypeId
    ) {
        Account account = new Account(Name = 'Cuenta ' + scenario);
        insert account;

        Pricebook2 pricebook = new Pricebook2(
            Name = 'Pricebook ' + scenario,
            IsActive = true
        );
        insert pricebook;

        Opportunity sourceOpportunity = new Opportunity(
            Name = 'Opportunity ' + scenario,
            AccountId = account.Id,
            StageName = 'Draft',
            CloseDate = Date.today(),
            CurrencyIsoCode = 'USD',
            Pricebook2Id = pricebook.Id,
            BMW_Compania__c = legacyCompany,
            Empresa_Operadora__c = empresaOperadoraId,
            Cuenta_de_Facturaci_n__c =
                useSourceBillingAccount ? account.Id : null
        );
        if (opportunityRecordTypeId != null) {
            sourceOpportunity.RecordTypeId = opportunityRecordTypeId;
        }
        insert sourceOpportunity;

        Quote sourceQuote = new Quote(
            Name = 'Quote ' + scenario,
            OpportunityId = sourceOpportunity.Id,
            Pricebook2Id = pricebook.Id,
            CurrencyIsoCode = 'USD',
            Compania__c = legacyCompany,
            ExpirationDate = Date.today().addDays(30)
        );
        insert sourceQuote;
        return sourceQuote;
    }

    private static Product2 addGiftLine(
        Quote sourceQuote,
        String productCode,
        String articleType,
        String vin,
        Boolean keepPricebookEntryActive
    ) {
        Product2 product = new Product2(
            Name = productCode,
            IsActive = true,
            CurrencyIsoCode = 'USD',
            Codigo_de_Producto__c = productCode,
            tipoProducto__c = articleType,
            VIN__c = vin
        );
        insert product;

        ensurePricebookEntry(Test.getStandardPricebookId(), product.Id, true);
        PricebookEntry sourceEntry =
            ensurePricebookEntry(sourceQuote.Pricebook2Id, product.Id, true);

        QuoteLineItem sourceLine = new QuoteLineItem(
            QuoteId = sourceQuote.Id,
            PricebookEntryId = sourceEntry.Id,
            Product2Id = product.Id,
            Quantity = 2,
            UnitPrice = 25,
            Discount = 10,
            Description = 'Regalía compatible',
            ServiceDate = Date.today().addDays(5),
            esRegalia__c = true
        );
        insert sourceLine;

        if (!keepPricebookEntryActive) {
            sourceEntry.IsActive = false;
            update sourceEntry;
        }
        return product;
    }

    private static PricebookEntry ensurePricebookEntry(
        Id pricebookId,
        Id productId,
        Boolean active
    ) {
        List<PricebookEntry> existing = [
            SELECT Id, IsActive
            FROM PricebookEntry
            WHERE Pricebook2Id = :pricebookId
            AND Product2Id = :productId
            AND CurrencyIsoCode = 'USD'
            LIMIT 1
        ];
        if (!existing.isEmpty()) {
            return existing[0];
        }

        PricebookEntry entry = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = productId,
            CurrencyIsoCode = 'USD',
            UnitPrice = 25,
            IsActive = active
        );
        insert entry;
        return entry;
    }

    private static Id getAvailableRecordTypeId(
        Schema.SObjectType objectType,
        String developerName
    ) {
        Schema.RecordTypeInfo recordTypeInfo = objectType
            .getDescribe()
            .getRecordTypeInfosByDeveloperName()
            .get(developerName);
        System.assertNotEquals(
            null,
            recordTypeInfo,
            'No existe el Record Type requerido: ' + developerName
        );
        System.assert(
            recordTypeInfo.isAvailable(),
            'El Record Type no está disponible: ' + developerName
        );
        return recordTypeInfo.getRecordTypeId();
    }

    private static String expectedLegacyCompany(String recordTypeName) {
        Set<String> bavarianRecordTypes = new Set<String>{
            'BMW',
            'Motorrad',
            'MINI',
            'Autos usados'
        };
        return bavarianRecordTypes.contains(recordTypeName) ? 'Bavarian' : 'Otobai';
    }

    private static String expectedBillingAccount(String recordTypeName) {
        Set<String> bavarianRecordTypes = new Set<String>{
            'BMW',
            'Motorrad',
            'MINI',
            'Autos usados'
        };
        return bavarianRecordTypes.contains(recordTypeName)
            ? '001PH00000X9ZEcYAN'
            : '0014U00002IpmIxQAJ';
    }
}
