@isTest
private class servicioEliminarReservaTest {
    
    @isTest
    static void testGetReservaById(){
        Opportunity opp = createOpportunity('Bavarian');
        Product2 prod = createProduct('RMBAVARIAN', 'Bavarian');

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new servicioEliminarReservaMock());
        String actual = servicioEliminarReserva.getEliminarReservaById(opp.Id, prod.Id);
        System.debug('Actual response: ' + actual);
        String expected = '{"operationResult":{"code":"00","description":"EL ARTICULO INDICADO ES VALIDO."}';
        Test.stopTest();

        System.assertEquals(expected, actual);
    }

    @isTest
    static void otobaiProductStopsBeforeUnreserveCallout(){
        Opportunity opp = createOpportunity('Otobai');
        Product2 prod = createProduct('RMOTOBAI', 'Otobai');

        Test.startTest();
        String actual = servicioEliminarReserva.getEliminarReservaById(opp.Id, prod.Id);
        Test.stopTest();

        System.assert(actual.contains('RMOTOBAI'),
            'Otobai debe detenerse con respuesta controlada mientras no exista contrato confirmado.');
    }

    @isTest
    static void pekingProductStopsBeforeUnreserveCallout(){
        Opportunity opp = createOpportunity('Bavarian');
        Product2 prod = createProduct('RMPEKING', 'PEKING');

        Test.startTest();
        String actual = servicioEliminarReserva.getEliminarReservaById(opp.Id, prod.Id);
        Test.stopTest();

        System.assert(actual.contains('RMPEKING'),
            'PEKING debe detenerse con respuesta controlada antes del callout.');
    }

    @isTest
    static void nullProductCompanyDoesNotFallback(){
        Opportunity opp = createOpportunity('Bavarian');
        Product2 prod = createProduct(null, 'SinEmpresa');

        Test.startTest();
        String actual = servicioEliminarReserva.getEliminarReservaById(opp.Id, prod.Id);
        Test.stopTest();

        System.assert(actual.contains('empresa'),
            'Una empresa nula no debe caer por descarte en Bavarian u Otobai.');
    }

    private static Opportunity createOpportunity(String legacyCompany) {
        Opportunity opp = new Opportunity(
            Name = 'Test ' + String.valueOf(DateTime.now().getTime()),
            BMW_Compania__c = legacyCompany,
            StageName = 'Oportunidad Calificada',
            CloseDate = Date.today()
        );
        insert opp;
        return opp;
    }

    private static Product2 createProduct(String companyCode, String brand) {
        Schema.RecordTypeInfo productRt = Schema.SObjectType.Product2
            .getRecordTypeInfosByDeveloperName()
            .get('Producto_Red_Motors');
        System.assertNotEquals(null, productRt, 'Debe existir el Record Type Product2.Producto_Red_Motors.');

        String uniqueValue = String.valueOf(DateTime.now().getTime()) + '-' + String.valueOf(Math.mod(Crypto.getRandomInteger(), 100000));
        Product2 prod = new Product2(
            RecordTypeId = productRt.getRecordTypeId(),
            Name = brand + '-EliminarReserva-' + uniqueValue,
            ProductCode = brand + '-' + uniqueValue,
            Codigo_de_Producto__c = 'ELI-' + uniqueValue,
            Empresa__c = companyCode,
            IsActive = true,
            CurrencyIsoCode = 'USD',
            vin__c = 'VIN-' + uniqueValue
        );
        insert prod;
        return prod;
    }
}
