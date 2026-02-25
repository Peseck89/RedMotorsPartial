@isTest
private class TestServicioFechaFacturacion {
    @isTest static void testActualizarFechaFacturacionConOportunidad() {
		Impuesto__c im = new Impuesto__c();
        im.codigoImpuesto__c =  '0108';
        insert im;
        
        condicionPago__c condi = new condicionPago__c();
        condi.Name = 'CONTADO';
        condi.condicionPago__c = '0';
        insert condi;
        
        categoriaCliente__c cet = new categoriaCliente__c();
        cet.categoriaCliente__c = 'COM';
        insert cet;
            
        Account acc= new Account();
        acc.Name='Test account';
        acc.Cedula__c='9876543220';
        acc.Tipo_de_Documento__c='02';
        acc.codigoSoftland__c = '1234';

        
        Account acc2= new Account();
        acc2.Name='Test account 2';
        acc2.Cedula__c='9876543210';
        acc2.Tipo_de_Documento__c='02';
        acc2.codigoSoftland__c = '1234';
        acc2.Impuesto__c = Im.Id;
        acc2.condicionPago__c = condi.Id;
        acc2.Gusto_y_aficiones__c = 'Cocina';
        acc2.categoriaCliente__c = cet.Id;
        insert acc2;



		Product2 prod= new Product2();
        prod.IsActive=true;
        prod.Name='Test product Test';
        prod.ProductCode='WBA11EF06R5Y21251';
        prod.Codigo_de_Producto__c='WBA11EF06R5Y21251';
        prod.vin__c ='WBA11EF06R5Y21251';
        insert prod;
        
        Pricebook2 pb = new Pricebook2();
        pb.Name='Dolar';
        pb.IsActive=true;
       
        insert pb;
        
        List<PricebookEntry> lstPBE = new List<PricebookEntry>();
        //Id stdPriceBook =  Test.getStandardPricebookId();
        PricebookEntry pd1 = new PricebookEntry();
        pd1.UnitPrice = 1;
        pd1.CurrencyIsoCode = 'USD';
        pd1.Product2Id = prod.Id;
        pd1.Pricebook2Id = pb.Id;
        pd1.IsActive = true;
        lstPBE.add(pd1);
        insert pd1;
        
        Bodega__c b = new Bodega__c();
        insert b;
        
        ProductoXBodega__c pxb = new ProductoXBodega__c();
        pxb.Producto__c = prod.Id;
        pxb.Bodega__c = b.Id;
        pxb.Disponible__c = 12;
        insert pxb;

        // Insert PricebookEntry
        PricebookEntry standardPBE = [select id, Pricebook2Id, UnitPrice,IsActive,CurrencyIsoCode 
                                      from PricebookEntry 
                                      where Product2Id =:prod.Id 
                                      and CurrencyIsoCode = 'USD'
                                      limit 1];//new PricebookEntry(Pricebook2Id =pricebookId, Product2Id = prod.Id, UnitPrice = 999, IsActive = true);
        System.debug('Pricebook entry' + standardPBE.CurrencyIsoCode);
        
        
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Opportunity testOpportunity = new Opportunity(
            Name = 'Sebastián Burgos-BMW-14/12/2023',
            AccountId = acc2.Id,
            StageName = 'Interesado',
            CloseDate = System.today().addDays(30),
            Pricebook2Id = standardPBE.Pricebook2Id,
            CurrencyIsoCode = 'USD'
        );
        
            
        insert testOpportunity;
        
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = testOpportunity.Id,
            Quantity = 1,
            TotalPrice = 1000,
            Product2Id = prod.id,
            PricebookEntryId = standardPBE.id
        );
        insert oli;

		/*Opportunity testOpportunity2 = new Opportunity(
            Name = 'Sebastián Burgos-BMW-14/12/20232',
            AccountId = acc2.Id,
            StageName = 'Oferta',
            Realiza_Test_Drive__c = true,
            Enganche_monto__c = 12312312,
            Enganche_recibo__c = 'si',
            CloseDate = System.today().addDays(30),
            Pricebook2Id = standardPBE.Pricebook2Id,
            CurrencyIsoCode = 'USD'
        );
        insert testOpportunity2;
        
        testOpportunity2.StageName = 'Cerrada Ganada';
        update testOpportunity2;
        
        OpportunityLineItem oli2 = new OpportunityLineItem(
            OpportunityId = testOpportunity2.Id,
            Quantity = 1,
            TotalPrice = 1000,
            Product2Id = prod.id,
            PricebookEntryId = standardPBE.id
        );
        insert oli2;
        
        */
        Asset vehiculo = new Asset(
        	AccountId = acc2.id,
            Name = 'WBA11EF06R5Y21251',
            NumeroDeChasis__c = 'WBA11EF06R5Y21251',
            Oportunidad__c = testOpportunity.id
        );
        insert vehiculo;
        
        
        List<Opportunity> opps = [SELECT Id, Name FROM Opportunity];
        //List<Opportunity> opps2 = [SELECT Id, Name FROM Opportunity WHERE NAME ='Sebastián Burgos-BMW-14/12/20232'];
        System.debug('Oppppppps Lines!!!!!!!!!!!!!!!!! ' + opps);
        
        //List<OpportunityLineItem> oppsLines = [SELECT Id, VN_Codigo_Producto_FM__c FROM OpportunityLineItem WHERE VinProduct2__c = 'WBA11EF06R5Y2125' AND OpportunityId = :testOpportunity.Id];
        //List<OpportunityLineItem> oppsLines = [SELECT Id, VN_Codigo_Producto_FM__c FROM OpportunityLineItem WHERE OpportunityId = :testOpportunity.Id];

        //System.debug('Oppppppps Lines!!!!!!!!!!!!!!!!! ' + oppsLines);     
        Test.startTest();
        
        // Simular petición HTTP
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('{"nombreOportunidad": "'+opps[0].name+'", "VIN": "WBA11EF06R5Y21251", "fechaFacturacion": "2024-02-18"}');
        RestContext.request = req;
        RestContext.response = res;
        
        ServicioFechaFacturacion.actualizarFechaFacturacion();
        
        delete oli;
        
        req.requestBody = Blob.valueOf('{"nombreOportunidad": "'+opps[0].name+'", "VIN": "WBA11EF06R5Y21251", "fechaFacturacion": "2024-02-18"}');
        RestContext.request = req;
        RestContext.response = res;
        
        ServicioFechaFacturacion.actualizarFechaFacturacion();
        
        
        
        req.requestBody = Blob.valueOf('{"nombreOportunidad": "'+opps[0].name+'", "VIN": "WBA11EF06R5Y21251asda", "fechaFacturacion": "2024-02-18"}');
        RestContext.request = req;
        RestContext.response = res;
        
        ServicioFechaFacturacion.actualizarFechaFacturacion();
        req.requestBody = Blob.valueOf('{"nombreOportunidad": "asdasda", "VIN": "WBA11EF06R5Y21251asda", "fechaFacturacion": "2024-02-18"}');
        RestContext.request = req;
        RestContext.response = res;
        
        ServicioFechaFacturacion.actualizarFechaFacturacion();
        
        ServicioFechaFacturacion.dummy();
        
        Test.stopTest();
        
    }
    
    
    
    
    
    
    
    
    
}