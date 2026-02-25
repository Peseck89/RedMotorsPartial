@isTest
public class RegistrarAnticipoCasillasTst {
    
    public static testmethod Map<String, Id> testFactoryRegistrarAnticipoCasillas(){
         Trigger_control__c tc = new Trigger_control__c();
        tc.Name = 'aprobacion de descuentos';
        tc.Turned_off__c = true;
        insert tc;
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
            prod.esVehiculo__c = true;
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
        OppLI.Quantity = 2;
        update OppLI;
        delete OppLI;
        return mapFactoryId;
    }
    
    public static testmethod void testGetCurrentOpp(){
		 Trigger_control__c tc = new Trigger_control__c();
        tc.Name = 'aprobacion de descuentos';
        tc.Turned_off__c = true;
        insert tc;
        Map<String, Id> mapFactoryId = testFactoryRegistrarAnticipoCasillas();
        Opportunity newOpp = new Opportunity();

        Test.startTest();
        	newOpp=RegistrarAnticipoCasillas.getCurrentOpp(mapFactoryId.get('Opp'));
        Test.stopTest();
        
        system.debug(newOpp);      
    }
    
    public static testmethod void testGetModelosVehiculos(){
        
        Map<String, Id> mapFactoryId = testFactoryRegistrarAnticipoCasillas();
        List<Product2> productos = new List<Product2>();

        Test.startTest();
        	productos=RegistrarAnticipoCasillas.getModelosVehiculos(mapFactoryId.get('Opp'));
        Test.stopTest();
        
        system.debug(productos);
    }
    
    
    
        
    public static testmethod void testMakeReserva(){
        Trigger_control__c tc = new Trigger_control__c();
        tc.Name = 'aprobacion de descuentos';
        tc.Turned_off__c = true;
        insert tc;
        Map<String, Id> mapFactoryId = testFactoryRegistrarAnticipoCasillas();
        Product2 producto = new Product2();
        
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new servicioReservasMock());
        	producto = RegistrarAnticipoCasillas.makeReserva(mapFactoryId.get('Opp'), mapFactoryId.get('prod'));
		Test.stopTest();
        
        system.debug(producto);
    }

}