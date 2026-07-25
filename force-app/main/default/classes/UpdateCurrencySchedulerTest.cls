@isTest
private class UpdateCurrencySchedulerTest {

    private static final String CRON_EXPRESSION = '0 0 23 * * ?';

    @isTest
    static void convertsBavarianLocalFromUsdToCrc() {
        assertConversion('Bavarian Local', 'USD', 'CRC', 'UCS-BAV-LOCAL');
    }

    @isTest
    static void convertsBavarianDolarFromCrcToUsd() {
        assertConversion('Bavarian Dólar', 'CRC', 'USD', 'UCS-BAV-USD');
    }

    @isTest
    static void convertsOtobaiLocalFromUsdToCrc() {
        assertConversion('Otobai Local', 'USD', 'CRC', 'UCS-OTO-LOCAL');
    }

    @isTest
    static void convertsOtobaiDolaresFromCrcToUsd() {
        assertConversion('Otobai Dólares', 'CRC', 'USD', 'UCS-OTO-USD');
    }

    @isTest
    static void convertsPekingLocalFromUsdToCrc() {
        assertConversion('PEKING Local', 'USD', 'CRC', 'UCS-PEK-LOCAL');
    }

    @isTest
    static void convertsPekingDolaresFromCrcToUsd() {
        assertConversion('PEKING Dólares', 'CRC', 'USD', 'UCS-PEK-USD');
    }

    @isTest
    static void leavesUnknownPricebookUnchangedWithoutFallback() {
        Product2 product = createProduct('UCS-UNKNOWN');
        ensureStandardPrices(product.Id, new Set<String>{'USD'});
        Pricebook2 unknownPricebook = new Pricebook2(
            Name = 'Pricebook desconocido',
            IsActive = true
        );
        insert unknownPricebook;
        PricebookEntry originalEntry = createEntry(
            product.Id,
            unknownPricebook.Id,
            'USD'
        );

        executeScheduler('UCS Unknown');

        List<PricebookEntry> remainingEntries = [
            SELECT Id, Pricebook2Id, CurrencyIsoCode
            FROM PricebookEntry
            WHERE Pricebook2Id = :unknownPricebook.Id
            AND Product2Id = :product.Id
        ];
        System.assertEquals(1, remainingEntries.size());
        System.assertEquals(originalEntry.Id, remainingEntries[0].Id);
        System.assertEquals(unknownPricebook.Id, remainingEntries[0].Pricebook2Id);
        System.assertEquals('USD', remainingEntries[0].CurrencyIsoCode);
    }

    private static void assertConversion(
        String pricebookName,
        String sourceCurrency,
        String targetCurrency,
        String productCode
    ) {
        Product2 product = createProduct(productCode);
        ensureStandardPrices(
            product.Id,
            new Set<String>{sourceCurrency, targetCurrency}
        );
        Pricebook2 pricebook = new Pricebook2(
            Name = pricebookName,
            IsActive = true
        );
        insert pricebook;
        PricebookEntry originalEntry = createEntry(
            product.Id,
            pricebook.Id,
            sourceCurrency
        );

        executeScheduler('UCS ' + productCode);

        System.assertEquals(
            0,
            [
                SELECT COUNT()
                FROM PricebookEntry
                WHERE Id = :originalEntry.Id
            ],
            'La entrada con moneda incorrecta debe dejar de existir.'
        );

        List<PricebookEntry> convertedEntries = [
            SELECT Id, Pricebook2Id, Product2Id, CurrencyIsoCode, UnitPrice,
                IsActive, UseStandardPrice, Costo_Fijo__c, Gerente__c,
                Jefe__c, Vendedor__c, pricebookEntryId__c
            FROM PricebookEntry
            WHERE Pricebook2Id = :pricebook.Id
            AND Product2Id = :product.Id
        ];
        System.assertEquals(1, convertedEntries.size());

        PricebookEntry convertedEntry = convertedEntries[0];
        System.assertNotEquals(originalEntry.Id, convertedEntry.Id);
        System.assertEquals(pricebook.Id, convertedEntry.Pricebook2Id);
        System.assertEquals(product.Id, convertedEntry.Product2Id);
        System.assertEquals(targetCurrency, convertedEntry.CurrencyIsoCode);
        System.assertEquals(250.50, convertedEntry.UnitPrice);
        System.assertEquals(true, convertedEntry.IsActive);
        System.assertEquals(false, convertedEntry.UseStandardPrice);
        System.assertEquals(125.25, convertedEntry.Costo_Fijo__c);
        System.assertEquals(3, convertedEntry.Gerente__c);
        System.assertEquals(2, convertedEntry.Jefe__c);
        System.assertEquals(1, convertedEntry.Vendedor__c);
        System.assertEquals(
            String.valueOf(originalEntry.Id),
            String.valueOf(convertedEntry.get('pricebookEntryId__c'))
        );
    }

    private static Product2 createProduct(String productCode) {
        Product2 product = new Product2(
            Name = 'Producto ' + productCode,
            Codigo_de_Producto__c = productCode,
            CurrencyIsoCode = 'USD',
            IsActive = true
        );
        insert product;
        return product;
    }

    private static void ensureStandardPrices(
        Id productId,
        Set<String> requiredCurrencies
    ) {
        Id standardPricebookId = Test.getStandardPricebookId();
        Set<String> existingCurrencies = new Set<String>();
        for (PricebookEntry existingEntry : [
            SELECT CurrencyIsoCode
            FROM PricebookEntry
            WHERE Pricebook2Id = :standardPricebookId
            AND Product2Id = :productId
            AND CurrencyIsoCode IN :requiredCurrencies
        ]) {
            existingCurrencies.add(existingEntry.CurrencyIsoCode);
        }

        List<PricebookEntry> missingEntries = new List<PricebookEntry>();
        for (String currencyIsoCode : requiredCurrencies) {
            if (existingCurrencies.contains(currencyIsoCode)) {
                continue;
            }
            missingEntries.add(new PricebookEntry(
                Product2Id = productId,
                Pricebook2Id = standardPricebookId,
                UnitPrice = 250.50,
                CurrencyIsoCode = currencyIsoCode,
                IsActive = true
            ));
        }
        if (!missingEntries.isEmpty()) {
            insert missingEntries;
        }
    }

    private static PricebookEntry createEntry(
        Id productId,
        Id pricebookId,
        String currencyIsoCode
    ) {
        PricebookEntry entry = new PricebookEntry(
            Product2Id = productId,
            Pricebook2Id = pricebookId,
            UnitPrice = 250.50,
            CurrencyIsoCode = currencyIsoCode,
            IsActive = true,
            UseStandardPrice = false,
            Costo_Fijo__c = 125.25,
            Gerente__c = 3,
            Jefe__c = 2,
            Vendedor__c = 1
        );
        insert entry;
        entry.put('pricebookEntryId__c', entry.Id);
        update entry;
        return entry;
    }

    private static void executeScheduler(String jobName) {
        Test.startTest();
        String jobId = System.schedule(
            jobName,
            CRON_EXPRESSION,
            new UpdateCurrencyScheduler()
        );
        CronTrigger scheduledJob = [
            SELECT CronExpression
            FROM CronTrigger
            WHERE Id = :jobId
        ];
        System.assertEquals(CRON_EXPRESSION, scheduledJob.CronExpression);
        Test.stopTest();
    }
}
