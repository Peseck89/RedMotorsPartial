@IsTest
public class cT_newPlanVentaControler_test {

    @TestSetup
    static void setupData() {
        TestDataFactory.createQuoteWithItems();
    }

    @IsTest
    static void testConstructor_conReciboUsado() {
        Opportunity opp   = [SELECT Id FROM Opportunity LIMIT 1];
        Quote quote       = [SELECT Id FROM Quote LIMIT 1];
        Set<Id> quoteIds  = new Set<Id>{ quote.Id };
        RM_SyncQuoteService_v2.syncQuote(quoteIds);

        ReciboUsado__c reciboUsado = new ReciboUsado__c(
            Oportunidad__c        = opp.Id,
            Marca__c              = 'BMW',
            Ano__c                = '2023',
            Placa__c              = 'ASDASD112',
            ValorReciboCliente__c = 1,
            ReciboJefeUsados__c   = 1,
            Modelo__c             = 'X1',
            Color__c              = 'GRIS',
            N_puertas__c          = 4,
            Serecibevehiculo__c   = true,
            Fecha_de_recibo__c    = Date.today(),
            Kilometraje__c        = 100
        );
        insert reciboUsado;

        Test.startTest();
        cT_newPlanVentaControler quotePDF = new cT_newPlanVentaControler(
            new ApexPages.StandardController(opp)
        );
        Test.stopTest();

        // opp: campo del constructor poblado desde la query con subqueries
        System.assertNotEquals(null, quotePDF.opp,
            'opp no debe ser null tras inicializar el controller.');
        System.assertEquals(opp.Id, quotePDF.opp.Id,
            'opp.Id debe coincidir con la oportunidad de prueba.');

        // op: campo poblado en getData()
        System.assertNotEquals(null, quotePDF.op,
            'op no debe ser null: getData() debe encontrar la oportunidad por recordId.');

        // Fecha: asignada en getData() y getDataQuote()
        System.assertNotEquals(null, quotePDF.Fecha,
            'Fecha debe ser asignada por getData() / getDataQuote().');

        // usados: poblado en getDataQuote() con el ReciboUsado que tiene Serecibevehiculo__c = true
        System.assertNotEquals(null, quotePDF.usados,
            'usados debe ser poblado porque se insertó un ReciboUsado con Serecibevehiculo__c = true.');

    }
}