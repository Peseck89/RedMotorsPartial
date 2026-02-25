@istest
public class CT_DisponibilidadBodegaControllerTest {
    static Integer iTotReg = 2;
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

    static testMethod void RTAsignadoDefecto() {
         List<Opportunity> opps = [Select Id From Opportunity];
         List<Product2> product = [Select Id From Product2];
         List<PricebookEntry> pricebook = [Select Id, CurrencyIsoCode From PricebookEntry Where CurrencyIsoCode='USD'];
		System.debug('pricebook '+pricebook);
        Quote quo = new Quote();
        quo.Name = 'test';
        quo.OpportunityId = opps[0].Id;
        quo.CurrencyIsoCode = 'USD';
        quo.Pricebook2Id =Test.getStandardPricebookId();
        insert quo;
        Quote quo2 = new Quote();
        quo2.Name = 'test2';
        quo2.OpportunityId = opps[0].Id;
        quo2.CurrencyIsoCode = 'USD';
        quo2.Pricebook2Id =Test.getStandardPricebookId();
        insert quo2;
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
        qli.QuoteId = quo.Id;
        qli.Quantity = 2;
        qli.PricebookEntryId = pricebook[0].Id;
        qli.Product2Id = product[0].Id;
        qli.UnitPrice = 1;
        qli.BMW_Bodega__c = bod.Id;
        insert qli;
        QuoteLineItem qli2 = new QuoteLineItem();
        qli2.QuoteId = quo.Id;
        qli2.Quantity = 2;
        qli2.PricebookEntryId = pricebook[0].Id;
        qli2.Product2Id = product[1].Id;
        qli2.UnitPrice = 1;
        qli2.BMW_Bodega__c = bod.Id;
        insert qli2;
		QuoteLineItem qli3 = new QuoteLineItem();
        qli3.QuoteId = quo2.Id;
        qli3.Quantity = 2;
        qli3.PricebookEntryId = pricebook[0].Id;
        qli3.Product2Id = product[1].Id;
        qli3.UnitPrice = 1;
        qli3.BMW_Bodega__c = bod.Id;
        insert qli3;
        test.startTest();
        	CT_DisponibilidadBodegaController.getProductosDisponibles(quo.Id);
        	CT_DisponibilidadBodegaController.getProductosDisponibles(quo2.Id);
            CT_DisponibilidadBodegaController.getQuote(quo.Id);
        test.stopTest();

    }
    
        

}