@istest
public with sharing class cT_QuoteUsdPDFController_test {
    static Integer iTotReg = 1;
    static Sucursal__c sucursal;
    static Campaign campanna;       
    
    static {

        TestDataFactory.datosGenerales();
        
        TestDataFactory.crearCuentas(iTotReg);
        
        //Crear campaña.
        campanna = new Campaign
        (
            Name='Campaign'
        );
        
        insert campanna;   
         TestDataFactory.crearOportunidades(iTotReg,'Oportunidad Calificada');
        TestDataFactory.createProducts(iTotReg);
        TestDataFactory.createPriceBookEntries(0,Test.getStandardPricebookId());
        
    }
	/*
    static testMethod void RTAsignadoDefecto() {
         
         List<Product2> product = [Select Id From Product2];
        
        Account cuenta = new Account();
        cuenta.FirstName = 'name';
        cuenta.LastName = 'Lastname';
        insert cuenta;
         Asset coche = new Asset();
        coche.Name = 'Testing';
        coche.AccountId = cuenta.Id;
        insert coche;
		 Opportunity op = new Opportunity(
                AccountId = cuenta.Id,
                CloseDate = System.today().AddMonths(3),
                StageName = 'Oportunidad Calificada',
                //MonedaIngreso__c = 'Colones',
                IngresoAproximado__c = 1500,
	            BMW_PlacaDeVehiculoOElVIN__c = coche.id,
                RT_Lead__c = 'BMW'
            );
        insert op;
        
       	List<Opportunity> opps = [Select Id From Opportunity WHERE BMW_PlacaDeVehiculoOElVIN__c != NULL];
        WorkOrder wo = new WorkOrder();
        wo.AccountId = cuenta.Id;
        wo.Kilometros__c = 120;
        wo.AssetId = coche.id;
        insert wo;
        
        Pricebook2 lista2 = new Pricebook2();
		lista2.CurrencyIsoCode = 'CRC';
		lista2.IsActive = true;
        lista2.Description = 'Lista de precios empresa Bavarian, en colones.';
        lista2.Name = 'Bavarian Local';
        insert lista2;
            
        
        List<Pricebook2> pricebook = [Select Id, CurrencyIsoCode From 	Pricebook2 Where CurrencyIsoCode='CRC'];
        System.debug('pricebook '+pricebook);
        Quote quo = new Quote();
        quo.Name = 'test';
        quo.OpportunityId = opps[0].Id;
        quo.CurrencyIsoCode = 'CRC';
        quo.OpportunityId = op.id;
        quo.Pricebook2Id = pricebook[0].id;
        insert quo;
                        
        Bodega__c bod = new Bodega__c();
        bod.Name = 'test';
        bod.bodega__c = 'test';
        insert bod;
        ProductoXBodega__c proXbod = new ProductoXBodega__c();
        proXbod.Name = 'test';
        proXbod.Bodega__c = bod.Id;
        proXbod.Producto__c = product[0].Id;
        insert proXbod;
        
        Product2 product2 = new Product2(Name = 'Test',
                                        Codigo_de_Producto__c = 'test');
        insert product2;

        List<PricebookEntry> pricebookCRC = [Select Id, CurrencyIsoCode From PricebookEntry Where CurrencyIsoCode='CRC'];
		
        
        QuoteLineItem qli = new QuoteLineItem();
        //qli.Name = 'test';
        qli.QuoteId = quo.Id;
        qli.Quantity = 2;
        qli.PricebookEntryId = pricebookCRC[0].id;
        qli.Product2Id = product[0].Id;
        qli.UnitPrice = 1;
        qli.BMW_Bodega__c = bod.Id;
        insert qli;
        
        QuoteLineItem qli2 = new QuoteLineItem();
        //qli.Name = 'test';
        qli2.QuoteId = quo.Id;
        qli2.Quantity = 3;
        qli2.PricebookEntryId = pricebookCRC[0].id;
        qli2.Product2Id = product[0].Id;
        qli2.UnitPrice = 1;
        qli2.BMW_Bodega__c = bod.Id;
        insert qli2;
        cT_QuoteUsdPDFController quotePDF = new cT_QuoteUsdPDFController(new ApexPages.StandardController(quo));
        ApexPages.currentPage().getParameters().put('Id',quo.Id);
        test.startTest();
        

            quotePDF.getData(quo.Id);
        qli.UnitPrice = 100;
        //update qli;
        quotePDF.getData(quo.Id);
        qli.UnitPrice = 245;
        //update qli;
        quotePDF.getData(quo.Id);
        qli.UnitPrice = 24535;
        //update qli;
        quotePDF.getData(quo.Id);
        //delete qli;
        ApexPages.currentPage().getParameters().put('id',quo.Id);

        test.stopTest();

    }
    */
    static testMethod void RTAsignadoDefectoCRC() {        
        Id idBMW = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Taller').getRecordTypeId();

		Account cuenta = new Account();
        cuenta.FirstName = 'name';
        cuenta.LastName = 'Lastname';
        insert cuenta;
         Asset coche = new Asset();
        coche.Name = 'Testing';
        coche.AccountId = cuenta.Id;
        insert coche;
		 Opportunity op = new Opportunity(
                AccountId = cuenta.Id,
	             CurrencyIsoCode = 'USD',                
                CloseDate = System.today().AddMonths(3),
                StageName = 'Oportunidad Calificada',
                //MonedaIngreso__c = 'Colones',
                IngresoAproximado__c = 1500,
	            BMW_PlacaDeVehiculoOElVIN__c = coche.id,
                RT_Lead__c = 'BMW'
            );
        insert op;
        
        WorkOrder wo = new WorkOrder();
        wo.AccountId = cuenta.Id;
        wo.Kilometros__c = 120;
        wo.AssetId = coche.id;
        insert wo;
         List<Opportunity> opps = [Select Id From Opportunity WHERE CurrencyIsoCode = 'USD' AND BMW_PlacaDeVehiculoOElVIN__c != NULL];
		 
         List<Product2> product = [Select Id From Product2];
		
        List<PricebookEntry> pricebookCRC = [Select Id, CurrencyIsoCode From PricebookEntry Where CurrencyIsoCode='USD'];
        System.debug('pricebook '+pricebookCRC);
                Quote quo = new Quote();
        quo.Name = 'test';
        quo.OpportunityId = opps[0].Id;
        quo.CurrencyIsoCode = 'USD';
        quo.Pricebook2Id = Test.getStandardPricebookId();
        insert quo;

        
        Bodega__c bod = new Bodega__c();
        bod.Name = 'test';
        bod.bodega__c = 'test';
        insert bod;
        ProductoXBodega__c proXbod = new ProductoXBodega__c();
        proXbod.Name = 'test';
        proXbod.Bodega__c = bod.Id;
        proXbod.Producto__c = product[0].Id;
        insert proXbod;
        QuoteLineItem qli = new QuoteLineItem();
        //qli.Name = 'test';
        qli.QuoteId = quo.Id;
        qli.Quantity = 2;
        qli.PricebookEntryId = pricebookCRC[0].Id;
        qli.Product2Id = product[0].Id;
        qli.UnitPrice = 1;
        qli.BMW_Bodega__c = bod.Id;
        insert qli;
        cT_QuoteUsdPDFController quotePDF = new cT_QuoteUsdPDFController(new ApexPages.StandardController(quo));
        ApexPages.currentPage().getParameters().put('Id',quo.Id);
        test.startTest();
            //
            quotePDF.getData(quo.Id);
        qli.UnitPrice = 100;
        //update qli;
        quotePDF.getData(quo.Id);
        qli.UnitPrice = 245;
        //update qli;
        quotePDF.getData(quo.Id);
        qli.UnitPrice = 24535;
        //update qli;
        quotePDF.getData(quo.Id);
        //delete qli;
        ApexPages.currentPage().getParameters().put('id',quo.Id);

        test.stopTest();

    }
        
}