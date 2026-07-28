@IsTest
public class RegistrarAnticipoCasillasTst {

    @TestSetup
    static void setupData() {
        Trigger_control__c tc = new Trigger_control__c(
            Name = 'aprobacion de descuentos', Turned_off__c = true
        );
        insert tc;

        Product2 prod = new Product2(
            Name                  = 'BM101 - X2 - Sdrive 18i Premium',
            modelo__c             = 'BM101 - X2 - Sdrive 18i Premium',
            Codigo_de_Producto__c = 'BM101',
            ProductCode           = 'BM101',
            IsActive              = true,
            Marca__c              = 'BMW',
            Description           = 'BM101 - X2 - Sdrive 18i Premium',
            NombredePlantilla__c  = 'BMWX2AgradecimientoVisita',
            esVehiculo__c         = true,
            Empresa__c            = 'RMBAVARIAN'
        );
        insert prod;

        Pricebook2 pb2 = new Pricebook2(Name = 'BMW - 2020', IsActive = true);
        insert pb2;

        PricebookEntry pbe = new PricebookEntry(
            Product2Id       = prod.Id,
            Pricebook2Id     = pb2.Id,
            UnitPrice        = 90000,
            UseStandardPrice = false,
            IsActive         = true
        );
        insert pbe;

        Opportunity opp = new Opportunity(
            Name            = 'Test',
            BMW_Compania__c = 'Bavarian',
            StageName       = 'Oportunidad Calificada',
            CloseDate       = Date.today(),
            Pricebook2Id    = pb2.Id
        );
        insert opp;

        OpportunityLineItem oppLI = new OpportunityLineItem(
            OpportunityId         = opp.Id,
            Modelo_De_Inter_s1__c = 'BM101 - X2 - Sdrive 18i Premium',
            Reservado__c          = false,
            Product2Id            = prod.Id,
            Quantity              = 1,
            TotalPrice            = pbe.UnitPrice
        );
        insert oppLI;

        Quote quo = new Quote(
            Name          = 'Test Quote',
            OpportunityId = opp.Id,
            Pricebook2Id  = pb2.Id
        );
        insert quo;

        QuoteLineItem quoteLI = new QuoteLineItem(
            QuoteId          = quo.Id,
            Product2Id       = prod.Id,
            PricebookEntryId = pbe.Id,
            Quantity         = 1,
            UnitPrice        = 2000
        );
        insert quoteLI;

        oppLI.Quantity = 2;
        update oppLI;
        delete oppLI;
    }

    @IsTest
    static void testGetCurrentOpp() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        Test.startTest();
        Opportunity result = RegistrarAnticipoCasillas.getCurrentOpp(opp.Id);
        Test.stopTest();

        System.assertNotEquals(null, result,
            'getCurrentOpp no debe retornar null');
        System.assertEquals(opp.Id, result.Id,
            'getCurrentOpp debe retornar la Opportunity con el Id correcto');
    }

    @IsTest
    static void testGetModelosVehiculos() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        Test.startTest();
        List<Product2> productos = RegistrarAnticipoCasillas.getModelosVehiculos(opp.Id);
        Test.stopTest();

        System.assertNotEquals(null, productos,
            'getModelosVehiculos no debe retornar null');
    }

    @IsTest
    static void testMakeReserva() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Product2 prod   = [SELECT Id FROM Product2 LIMIT 1];

        Test.setMock(HttpCalloutMock.class, new servicioReservasMock());
        Test.startTest();
        Product2 producto = RegistrarAnticipoCasillas.makeReserva(opp.Id, prod.Id);
        Test.stopTest();

        System.assertNotEquals(null, producto,
            'makeReserva no debe retornar null');
    }
}