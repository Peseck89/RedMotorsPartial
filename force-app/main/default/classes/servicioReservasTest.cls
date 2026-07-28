/**
 * @description       : 
 * @author            : martin.alvrz.grcs@gmail.com
 * @group             : 
 * @last modified on  : 01-19-2023
 * @last modified by  : martin.alvrz.grcs@gmail.com
**/
@isTest
private class servicioReservasTest {
    
    @isTest
    static void testGetReservaById(){
        Opportunity opp = createOpportunity('Bavarian');
        Product2 prod = createProduct('RMBAVARIAN', 'Bavarian');

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new servicioReservasMock());
        Map<String,Object> responseMap = servicioReservas.getReservaById(opp.Id, prod.Id);
        Test.stopTest();

        System.assertEquals(true, (Boolean) responseMap.get('success'),
            'Bavarian debe conservar la reserva exitosa.');
    }

    @isTest
    static void otobaiProductKeepsReservationFlow(){
        Opportunity opp = createOpportunity('Otobai');
        Product2 prod = createProduct('RMOTOBAI', 'Otobai');

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new servicioReservasMock());
        Map<String,Object> responseMap = servicioReservas.getReservaById(opp.Id, prod.Id);
        Test.stopTest();

        System.assertEquals(true, (Boolean) responseMap.get('success'),
            'Otobai debe conservar la reserva exitosa.');
    }

    @isTest
    static void pekingProductStopsBeforeReservationCallout(){
        Opportunity opp = createOpportunity('Bavarian');
        Product2 prod = createProduct('RMPEKING', 'PEKING');

        Test.startTest();
        Map<String,Object> responseMap = servicioReservas.getReservaById(opp.Id, prod.Id);
        Test.stopTest();

        System.assertEquals(false, (Boolean) responseMap.get('success'));
        System.assert(((String) responseMap.get('error')).contains('RMPEKING'),
            'PEKING debe detenerse con error controlado antes del callout.');
    }

    @isTest
    static void nullProductCompanyDoesNotFallback(){
        Opportunity opp = createOpportunity('Bavarian');
        Product2 prod = createProduct(null, 'SinEmpresa');

        Test.startTest();
        Map<String,Object> responseMap = servicioReservas.getReservaById(opp.Id, prod.Id);
        Test.stopTest();

        System.assertEquals(false, (Boolean) responseMap.get('success'));
        System.assert(((String) responseMap.get('error')).contains('empresa'),
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
            Name = brand + '-Reserva-' + uniqueValue,
            ProductCode = brand + '-' + uniqueValue,
            Codigo_de_Producto__c = 'RES-' + uniqueValue,
            Empresa__c = companyCode,
            IsActive = true,
            CurrencyIsoCode = 'USD',

            vin__c = 'VIN-' + uniqueValue
        );
        insert prod;
        return prod;
    }
}
