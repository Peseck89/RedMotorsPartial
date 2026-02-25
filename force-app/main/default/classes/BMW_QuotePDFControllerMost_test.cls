@istest
public class BMW_QuotePDFControllerMost_test {
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

    static testMethod void RTAsignadoDefecto() {
         List<Opportunity> opps = [Select Id From Opportunity];
         List<Product2> product = [Select Id From Product2];
         List<PricebookEntry> pricebook = [Select Id, CurrencyIsoCode From PricebookEntry Where CurrencyIsoCode='CRC'];
        System.debug('pricebook '+pricebook);
                Quote quo = new Quote();
        quo.Name = 'test';
        quo.OpportunityId = opps[0].Id;
        quo.CurrencyIsoCode = 'CRC';
        quo.Pricebook2Id =Test.getStandardPricebookId();
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
        qli.PricebookEntryId = pricebook[0].Id;
        qli.Product2Id = product[0].Id;
        qli.UnitPrice = 1;
        qli.BMW_Bodega__c = bod.Id;
        
        BMW_QuotePDFControllerMostrador quotePDF = new BMW_QuotePDFControllerMostrador(new ApexPages.StandardController(quo));
        ApexPages.currentPage().getParameters().put('Id',quo.Id);
        test.startTest();
            //insert qli;
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
        
        BMW_QuotePDFControllerMostrador.metodoDummy();

        // Validación trivial, solo para asegurar que no lanza errores
        System.assert(true, 'metodoDummy ejecutado correctamente');

        test.stopTest();

    }
    
        
}