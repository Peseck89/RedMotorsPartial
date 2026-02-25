@isTest
public class QuitarReservaUsadosControllerTst {
    
    public static testmethod Map<String, Id> testFactoryQuitarReservaUsadosController(){
        Map<String, Id> mapFactoryId = new Map<String, Id>();
        
        Product2 prod = new Product2();
            prod.Name = 'BM101 - X2 - Sdrive 18i Premium';
            prod.modelo__c = 'BM101 - X2 - Sdrive 18i Premium';
            prod.Codigo_de_Producto__c = 'BM101';
            prod.ProductCode = 'BM101';
            prod.IsActive = true;
            prod.Marca__c = 'BMW';
            prod.Description = 'BM101 - X2 - Sdrive 18i Premium';
            prod.NombredePlantilla__c = 'BMWX2AgradecimientoVisita';
            prod.Familia__c = 'X2';
            prod.es_Vehiculo_usado__c = true;
            prod.Empresa__c = 'RMBAVARIAN';
        insert prod;
        mapFactoryId.put('prod', prod.Id);
        
        Pricebook2 pb2 = new Pricebook2();
            pb2.Name = 'BMW - 2020';
            pb2.IsActive = true;
        insert pb2;
        mapFactoryId.put('pb2', pb2.Id);
        
        PricebookEntry pbe = new PricebookEntry();
            pbe.Product2Id = prod.Id;
            pbe.Pricebook2Id = pb2.Id;
            pbe.UnitPrice = 90000;
            pbe.UseStandardPrice = false;
            pbe.IsActive = true;
        insert pbe;
        mapFactoryId.put('pbe', pbe.Id);
        
        Opportunity Opp = new Opportunity();
            Opp.Name = 'Test';
            Opp.BMW_Compania__c = 'Bavarian';
            Opp.StageName = 'Oportunidad Calificada';
            Opp.CloseDate = Date.today();
            Opp.Pricebook2Id = pb2.Id;
        insert Opp;
        mapFactoryId.put('Opp', Opp.Id);
        
        OpportunityLineItem OppLI = new OpportunityLineItem();
            OppLI.OpportunityId = Opp.Id;
            OppLI.Modelo_De_Inter_s1__c = 'BM101 - X2 - Sdrive 18i Premium';
            OppLI.Reservado__c = false;
            OppLI.Product2Id = prod.Id;
            OppLI.Quantity = 1;
            OppLI.TotalPrice = pbe.UnitPrice;
        insert OppLI;
        mapFactoryId.put('OppLI', OppLI.Id);
        
        Quote Quo = new Quote();
            Quo.Name = 'Test Quote';
            Quo.OpportunityId = Opp.Id;
            Quo.Pricebook2Id = pb2.Id;
        insert Quo;
        mapFactoryId.put('Quo', Quo.Id);
        
        QuoteLineItem QuoteLI = new QuoteLineItem();
            QuoteLI.QuoteId = Quo.Id;
            QuoteLI.Product2Id = prod.Id;
            QuoteLI.PricebookEntryId = pbe.Id;
            QuoteLI.Quantity = 1; 
            QuoteLI.UnitPrice = 2000;
        insert QuoteLI;
        mapFactoryId.put('QuoteLI', QuoteLI.Id);
        
        return mapFactoryId;
    }
    
    public static testmethod void testGetCurrentOpp(){
        Map<String, Id> mapFactoryId = testFactoryQuitarReservaUsadosController();
        Opportunity newOpp = new Opportunity();

        Test.startTest();
            newOpp=QuitarReservaUsadosController.getCurrentOpp(mapFactoryId.get('Opp'));
        Test.stopTest();
        
        system.debug(newOpp);      
    }
    
    public static testmethod void testGetModelosVehiculos(){
        Map<String, Id> mapFactoryId = testFactoryQuitarReservaUsadosController();
        List<Product2> productos = new List<Product2>();

        Test.startTest();
            productos=QuitarReservaUsadosController.getModelosVehiculos(mapFactoryId.get('Opp'));
        Test.stopTest();
        
        system.debug(productos);
    }
    
    public static testmethod void testGetProduct(){
        Map<String, Id> mapFactoryId = testFactoryQuitarReservaUsadosController();
        Product2 producto = new Product2();
        
        Test.startTest();
            producto=QuitarReservaUsadosController.getProduct(mapFactoryId.get('prod'));
        Test.stopTest();
        
        system.debug(producto);
    }
    
    public static testmethod void testGetAnticipo(){
        Map<String, Id> mapFactoryId = testFactoryQuitarReservaUsadosController();
        Boolean hayAnticipo;
        
        Test.startTest();
            hayAnticipo = QuitarReservaUsadosController.getAnticipo(mapFactoryId.get('Opp'), mapFactoryId.get('prod'));
        Test.stopTest();
        
        system.debug(hayAnticipo);
    }
    
    public static testmethod void testmakeEliminarReserva(){
        Map<String, Id> mapFactoryId = testFactoryQuitarReservaUsadosController();
        Product2 producto = new Product2();
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new servicioEliminarReservaMock());
            producto =QuitarReservaUsadosController.makeEliminarReserva(mapFactoryId.get('Opp'),  mapFactoryId.get('prod'));
                
        Test.stopTest();
        
        system.debug(producto);
    }

}