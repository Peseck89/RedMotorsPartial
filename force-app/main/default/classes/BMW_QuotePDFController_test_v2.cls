@isTest
public class BMW_QuotePDFController_test_v2 {
    static Integer iTotReg = 1;
    static Campaign campanna;

    static {
        TestDataFactory.datosGenerales();
        TestDataFactory.crearCuentas(iTotReg);
        campanna = new Campaign(Name = 'Campaign');
        insert campanna;
        TestDataFactory.crearOportunidades(iTotReg, 'Oportunidad Calificada');
        TestDataFactory.createProducts(iTotReg);
    }

    @isTest
    static void testConLineasDeTrabajo() {
        List<Opportunity> opps    = [SELECT Id FROM Opportunity];
        List<Product2>    products = [SELECT Id FROM Product2];

        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id   = products[0].Id,
            UnitPrice    = 100,
            CurrencyIsoCode = 'CRC',
            IsActive     = true
        );
        insert pbe;

        Quote quo = new Quote(
            Name          = 'test',
            OpportunityId = opps[0].Id,
            CurrencyIsoCode = 'CRC',
            Pricebook2Id  = Test.getStandardPricebookId()
        );
        insert quo;

        List<QuoteLineItem> qlis = new List<QuoteLineItem>();
        for (String tipo : new List<String>{ 'Materiales', 'Mano de Obra', 'Subcontrato', 'Pintura', 'Varios' }) {
            qlis.add(new QuoteLineItem(
                QuoteId         = quo.Id,
                PricebookEntryId = pbe.Id,
                Product2Id      = products[0].Id,
                Quantity        = 1,
                UnitPrice       = 100,
                BMW_TipoDeArticulo__c = tipo
            ));
        }
        insert qlis;

        Test.startTest();
        BMW_QuotePDFController_v2 controller = new BMW_QuotePDFController_v2(
            new ApexPages.StandardController(quo)
        );
        controller.getData(quo.Id);
        Test.stopTest();

        System.assertEquals(100, controller.montoMaterial,    'montoMaterial debe ser 100');
        System.assertEquals(100, controller.montoManoDeObra,  'montoManoDeObra debe ser 100');
        System.assertEquals(100, controller.montoSubcontrato, 'montoSubcontrato debe ser 100');
        System.assertEquals(100, controller.montoPintura,     'montoPintura debe ser 100');
        System.assertEquals(100, controller.montoVarios,      'montoVarios debe ser 100');
        System.assertNotEquals(null, controller.ordenaTrabajos);
        System.assertEquals(5, controller.ordenaTrabajos.size());
    }

    @isTest
    static void testSinLineasDeTrabajo() {
        List<Opportunity> opps = [SELECT Id FROM Opportunity];

        Quote quo = new Quote(
            Name          = 'test sin lineas',
            OpportunityId = opps[0].Id,
            CurrencyIsoCode = 'CRC',
            Pricebook2Id  = Test.getStandardPricebookId()
        );
        insert quo;

        Test.startTest();
        BMW_QuotePDFController_v2 controller = new BMW_QuotePDFController_v2(
            new ApexPages.StandardController(quo)
        );
        Test.stopTest();

        System.assertEquals(0, controller.montoMaterial);
        System.assertEquals(0, controller.montoManoDeObra);
        System.assertEquals(0, controller.montoSubcontrato);
        System.assertEquals(0, controller.montoPintura);
        System.assertEquals(0, controller.montoVarios);
    }
}
