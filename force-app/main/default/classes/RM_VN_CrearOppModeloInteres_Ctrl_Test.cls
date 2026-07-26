@IsTest
public with sharing class RM_VN_CrearOppModeloInteres_Ctrl_Test {
    private static final String TEST_YEAR = '2026';
    private static final String TEST_GROUP = 'X';
    private static final String TEST_FAMILY = 'X1';

    @TestSetup
    static void makeData() {
        insert new List<Empresa__c>{
            buildEmpresa('RMBAVARIAN'),
            buildEmpresa('RMOTOBAI'),
            buildEmpresa('RMPEKING')
        };
    }


    @IsTest
    static void validarCuentaReturnsSelectedAccount() {
        Account account = createBasicAccount('VALIDAR');

        Test.startTest();
        List<Account> result = RM_VN_CrearOppModeloInteres_Ctrl.validarCuenta(account.Id);
        Test.stopTest();

        System.assertEquals(1, result.size(), 'Debe devolver la cuenta solicitada.');
        System.assertEquals(account.Id, result[0].Id);
        System.assertEquals(account.Name, result[0].Name);
    }

    @IsTest
    static void crearCuentaUpdatesBusinessAccount() {
        Account account = createBasicAccount('CREAR');

        Test.startTest();
        List<Account> result = RM_VN_CrearOppModeloInteres_Ctrl.crearCuenta(
            account.Id,
            'Cuenta Actualizada B19',
            'Apellido No Usado',
            '22223333',
            'empresa.b19@example.com',
            'facturacion.b19@example.com'
        );
        Test.stopTest();

        System.assertEquals(1, result.size(), 'Debe devolver la cuenta actualizada.');
        Account updatedAccount = [
            SELECT Id, Name, Phone, CorreoElectronicoEmpresarial__c, Invoice_Email__c
            FROM Account
            WHERE Id = :account.Id
            LIMIT 1
        ];
        System.assertEquals('Cuenta Actualizada B19', updatedAccount.Name);
        System.assertEquals('22223333', updatedAccount.Phone);
        System.assertEquals('empresa.b19@example.com', updatedAccount.CorreoElectronicoEmpresarial__c);
    }

    @IsTest
    static void createOpportunityRejectsBlankRequiredInputs() {
        ScenarioData data = createScenarioData('BMW');

        assertCreateOpportunityFails(null, TEST_FAMILY, TEST_YEAR, data.accountId, data.productId, data.pricebookEntryId);
        assertCreateOpportunityFails('BMW', null, TEST_YEAR, data.accountId, data.productId, data.pricebookEntryId);
        assertCreateOpportunityFails('BMW', TEST_FAMILY, null, data.accountId, data.productId, data.pricebookEntryId);
        assertCreateOpportunityFails('BMW', TEST_FAMILY, TEST_YEAR, null, data.productId, data.pricebookEntryId);
        assertCreateOpportunityFails('BMW', TEST_FAMILY, TEST_YEAR, data.accountId, null, data.pricebookEntryId);
        assertCreateOpportunityFails('BMW', TEST_FAMILY, TEST_YEAR, data.accountId, data.productId, null);
    }

    @IsTest
    static void createsBmwOpportunityWithBavarianCompany() {
        assertCreatesOpportunityForBrand('BMW', 'RMBAVARIAN');
    }

    @IsTest
    static void createsMiniOpportunityWithBavarianCompany() {
        assertCreatesOpportunityForBrand('MINI', 'RMBAVARIAN');
    }

    @IsTest
    static void createsPolarisOpportunityWithOtobaiCompany() {
        assertCreatesOpportunityForBrand('Polaris', 'RMOTOBAI');
    }

    @IsTest
    static void createsKawasakiOpportunityWithOtobaiCompany() {
        assertCreatesOpportunityForBrand('Kawasaki', 'RMOTOBAI');
    }

    @IsTest
    static void createsOmodaOpportunityWithPekingCompany() {
        assertCreatesOpportunityForBrand('Omoda', 'RMPEKING');
    }

    @IsTest
    static void createsJaecooOpportunityWithPekingCompany() {
        assertCreatesOpportunityForBrand('Jaecoo', 'RMPEKING');
    }

    @IsTest
    static void unknownBrandFailsBeforeCreatingRecords() {
        ScenarioData data = createScenarioData('MarcaNoConfigurada');
        Integer opportunitiesBefore = [SELECT count() FROM Opportunity];
        Integer lineItemsBefore = [SELECT count() FROM OpportunityLineItem];
        Integer interestBefore = [SELECT count() FROM Oportunidad_Producto_Interes__c];

        Test.startTest();
        try {
            invokeCreateOpportunity('MarcaNoConfigurada', data);
            System.assert(false, 'La marca desconocida debe producir error controlado.');
        } catch (AuraHandledException expected) {
            System.assertNotEquals(null, expected, 'Debe lanzarse una excepción controlada.');
        }

        System.assertEquals(opportunitiesBefore, [SELECT count() FROM Opportunity]);
        System.assertEquals(lineItemsBefore, [SELECT count() FROM OpportunityLineItem]);
        System.assertEquals(interestBefore, [SELECT count() FROM Oportunidad_Producto_Interes__c]);
    }

    @IsTest
    static void inactiveCompanyFailsBeforeCreatingRecords() {
        Empresa__c peking = [
            SELECT Id, Activa__c
            FROM Empresa__c
            WHERE Codigo__c = 'RMPEKING'
            LIMIT 1
        ];
        peking.Activa__c = false;
        update peking;

        ScenarioData data = createScenarioData('Omoda');
        Integer opportunitiesBefore = [SELECT count() FROM Opportunity];
        Integer lineItemsBefore = [SELECT count() FROM OpportunityLineItem];
        Integer interestBefore = [SELECT count() FROM Oportunidad_Producto_Interes__c];

        Test.startTest();
        try {
            invokeCreateOpportunity('Omoda', data);
            System.assert(false, 'La empresa inactiva debe producir error controlado.');
        } catch (EmpresaConfigurationException expected) {
            System.assert(
                expected.getMessage().contains('inactiva'),
                'El error debe indicar que la empresa está inactiva.'
            );
        }

        System.assertEquals(opportunitiesBefore, [SELECT count() FROM Opportunity]);
        System.assertEquals(lineItemsBefore, [SELECT count() FROM OpportunityLineItem]);
        System.assertEquals(interestBefore, [SELECT count() FROM Oportunidad_Producto_Interes__c]);
    }

    private static void assertCreatesOpportunityForBrand(String brand, String expectedCompanyCode) {
        ScenarioData data = createScenarioData(brand);
        Id expectedRecordTypeId = getOpportunityRecordTypeId(brand);
        Id expectedEmpresaId = getEmpresaId(expectedCompanyCode);

        Test.startTest();
        Map<String, Object> result = invokeCreateOpportunity(brand, data);
        Test.stopTest();

        System.assertEquals(true, result.containsKey('opportunityId'));
        Id opportunityId = (Id) result.get('opportunityId');
        System.assertNotEquals(null, opportunityId, 'Debe retornar el Id de la Opportunity.');

        Opportunity createdOpportunity = [
            SELECT Id, RecordTypeId, Pricebook2Id, Empresa_Operadora__c,
                   AccountId, Familia__c, CurrencyIsoCode
            FROM Opportunity
            WHERE Id = :opportunityId
            LIMIT 1
        ];

        System.assertEquals(expectedRecordTypeId, createdOpportunity.RecordTypeId);
        System.assertEquals(data.pricebookId, createdOpportunity.Pricebook2Id);
        System.assertEquals(expectedEmpresaId, createdOpportunity.Empresa_Operadora__c);
        System.assertEquals(data.accountId, createdOpportunity.AccountId);
        System.assertEquals(TEST_FAMILY, createdOpportunity.Familia__c);
        System.assertEquals(data.currencyIsoCode, createdOpportunity.CurrencyIsoCode);

        List<OpportunityLineItem> lineItems = [
            SELECT Id, OpportunityId, PricebookEntryId, Quantity, UnitPrice
            FROM OpportunityLineItem
            WHERE OpportunityId = :opportunityId
        ];
        System.assertEquals(1, lineItems.size(), 'Debe crear una línea de Opportunity.');
        System.assertEquals(data.pricebookEntryId, lineItems[0].PricebookEntryId);
        System.assertEquals(1, lineItems[0].Quantity);
        System.assertEquals(data.unitPrice, lineItems[0].UnitPrice);

        List<Oportunidad_Producto_Interes__c> interests = [
            SELECT Id, Oportunidad__c, Producto__c, PricebookEntryId__c,
                   Marca__c, Familia__c, Anio__c, Cantidad__c, Precio_Unitario__c
            FROM Oportunidad_Producto_Interes__c
            WHERE Oportunidad__c = :opportunityId
        ];
        System.assertEquals(1, interests.size(), 'Debe crear un producto de interés.');
        System.assertEquals(data.productId, interests[0].Producto__c);
        System.assertEquals(data.pricebookEntryId, interests[0].PricebookEntryId__c);
        System.assertEquals(brand, interests[0].Marca__c);
        System.assertEquals(TEST_FAMILY, interests[0].Familia__c);
        System.assertEquals(TEST_YEAR, interests[0].Anio__c);
        System.assertEquals(1, interests[0].Cantidad__c);
        System.assertEquals(data.unitPrice, interests[0].Precio_Unitario__c);
    }

    private static Map<String, Object> invokeCreateOpportunity(String brand, ScenarioData data) {
        return RM_VN_CrearOppModeloInteres_Ctrl.createOpportunity(
            null,
            brand,
            TEST_FAMILY,
            TEST_YEAR,
            data.accountId,
            data.productId,
            data.pricebookEntryId,
            null,
            null,
            null,
            'Web',
            'No',
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null
        );
    }

    private static ScenarioData createScenarioData(String brand) {
        String suffix = uniqueSuffix(brand);

        Account account = new Account(
            Name = 'Cuenta Modelo Interes ' + suffix,
            Tipo_de_Documento__c = '01',
            Cedula__c = 'B19' + suffix.left(12)
        );
        insert account;

        Pricebook2 pricebook = new Pricebook2(
            Name = 'PB Modelo Interes ' + suffix,
            IsActive = true
        );
        insert pricebook;

        Product2 product = new Product2(
            RecordTypeId = getProductRecordTypeId('Producto_Red_Motors'),
            Name = 'Modelo Interes ' + brand + ' ' + suffix,
            ProductCode = 'MI-' + suffix,
            Codigo_de_Producto__c = 'MI-' + suffix,
            IsActive = true,
            Marca__c = 'BMW',
            Categor_a_veh_culo__c = 'SUV',
            Grupo__c = TEST_GROUP,
            Familia__c = TEST_FAMILY,
            Anno__c = TEST_YEAR
        );
        insert product;

        ensureStandardPrice(product.Id, 'USD');

        Decimal unitPrice = 25000;
        PricebookEntry entry = new PricebookEntry(
            Pricebook2Id = pricebook.Id,
            Product2Id = product.Id,
            UnitPrice = unitPrice,
            IsActive = true,
            CurrencyIsoCode = 'USD',
            Costo_Fijo__c = unitPrice,
            Gerente__c = 1,
            Vendedor__c = 1,
            Jefe__c = 1
        );
        insert entry;

        ScenarioData data = new ScenarioData();
        data.accountId = account.Id;
        data.pricebookId = pricebook.Id;
        data.productId = product.Id;
        data.pricebookEntryId = entry.Id;
        data.unitPrice = unitPrice;
        data.currencyIsoCode = 'USD';
        return data;
    }

    private static void ensureStandardPrice(Id productId, String currencyIsoCode) {
        Id standardPricebookId = Test.getStandardPricebookId();
        List<PricebookEntry> existingEntries = [
            SELECT Id
            FROM PricebookEntry
            WHERE Pricebook2Id = :standardPricebookId
            AND Product2Id = :productId
            AND CurrencyIsoCode = :currencyIsoCode
            LIMIT 1
        ];
        if (!existingEntries.isEmpty()) {
            return;
        }

        insert new PricebookEntry(
            Pricebook2Id = standardPricebookId,
            Product2Id = productId,
            UnitPrice = 1000,
            IsActive = true,
            CurrencyIsoCode = currencyIsoCode
        );
    }

    private static Id getProductRecordTypeId(String developerName) {
        Schema.RecordTypeInfo rtInfo =
            Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get(developerName);
        System.assertNotEquals(null, rtInfo, 'Debe existir el Record Type de Product2 ' + developerName);
        System.assert(rtInfo.isAvailable(), 'Debe estar disponible el Record Type de Product2 ' + developerName);
        return rtInfo.getRecordTypeId();
    }


    private static Account createBasicAccount(String seed) {
        Account account = new Account(
            Name = 'Cuenta ' + seed + ' ' + uniqueSuffix(seed),
            Tipo_de_Documento__c = '01',
            Cedula__c = 'B19' + uniqueSuffix(seed).left(12)
        );
        insert account;
        return account;
    }

    private static void assertCreateOpportunityFails(
        String brand,
        String family,
        String year,
        Id accountId,
        Id productId,
        Id pricebookEntryId
    ) {
        Integer opportunitiesBefore = [SELECT count() FROM Opportunity];
        try {
            RM_VN_CrearOppModeloInteres_Ctrl.createOpportunity(
                null,
                brand,
                family,
                year,
                accountId,
                productId,
                pricebookEntryId,
                null,
                null,
                null,
                'Web',
                'No',
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null
            );
            System.assert(false, 'La entrada inválida debe producir error controlado.');
        } catch (AuraHandledException expected) {
            System.assertNotEquals(null, expected, 'Debe lanzarse una excepción controlada.');
        }
        System.assertEquals(opportunitiesBefore, [SELECT count() FROM Opportunity]);
    }
    private static Empresa__c buildEmpresa(String codigo) {
        return new Empresa__c(
            Name = 'Empresa ' + codigo,
            Codigo__c = codigo,
            Codigo_ERP__c = codigo,
            Nombre_Legal__c = 'Empresa ' + codigo + ' S.A.',
            Activa__c = true
        );
    }

    private static Id getEmpresaId(String codigo) {
        return [
            SELECT Id
            FROM Empresa__c
            WHERE Codigo__c = :codigo
            LIMIT 1
        ].Id;
    }

    private static Id getOpportunityRecordTypeId(String developerName) {
        List<RecordType> recordTypes = [
            SELECT Id, DeveloperName
            FROM RecordType
            WHERE SObjectType = 'Opportunity'
            AND DeveloperName = :developerName.toUpperCase()
            AND IsActive = true
            LIMIT 1
        ];
        System.assertEquals(
            1,
            recordTypes.size(),
            'Debe existir el Record Type activo de Opportunity para ' + developerName
        );
        return recordTypes[0].Id;
    }

    private static String uniqueSuffix(String seed) {
        String raw = seed + String.valueOf(DateTime.now().getTime()) + String.valueOf(Crypto.getRandomInteger());
        return raw.replaceAll('[^A-Za-z0-9]', '').left(30);
    }

    private class ScenarioData {
        Id accountId;
        Id pricebookId;
        Id productId;
        Id pricebookEntryId;
        Decimal unitPrice;
        String currencyIsoCode;
    }
}
