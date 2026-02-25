@istest
public class cT_QuotePDFEmail_test {

         
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

    static testMethod void testWithMarca() {
         List<Opportunity> opps = [Select Id From Opportunity];
		 List<Account> cuentas = [Select Id From Account];
         Asset newCoche = new Asset();
         newCoche.Anio__c = '2022';
         newCoche.marca__c = 'Vehículo Polaris' ;
         newCoche.Name = 'coche prueba';
         newCoche.numeroDePlaca__c = 'test123';
         newCoche.NumeroDeChasis__c = '1';
         newCoche.AccountId = cuentas[0].id;
         insert newCoche;

         opps[0].BMW_PlacaDeVehiculoOElVIN__c = newCoche.id;
		 update opps;
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
        BMW_QuotePDFController quotePDF = new BMW_QuotePDFController(new ApexPages.StandardController(quo));
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
		cT_QuotePDFEmail quoteEmail = new cT_QuotePDFEmail();
        quoteEmail.body = 'test body';
        quoteEmail.subject = 'test subject';
        quoteEmail.destinatario = 'test@gmail.com';
        quoteEmail.send();
        test.stopTest();

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
       BMW_QuotePDFController quotePDF = new BMW_QuotePDFController(new ApexPages.StandardController(quo));
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
       cT_QuotePDFEmail quoteEmail = new cT_QuotePDFEmail();
       quoteEmail.body = 'test body';
       quoteEmail.subject = 'test subject';
       quoteEmail.destinatario = 'test@gmail.com';
       quoteEmail.send();
       test.stopTest();

   }

}