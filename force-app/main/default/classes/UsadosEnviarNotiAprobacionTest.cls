@IsTest
public class UsadosEnviarNotiAprobacionTest {

    @TestSetup
    static void makeData(){
        Trigger_control__c tc = new Trigger_control__c();
        tc.Name = 'aprobacion de descuentos';
        tc.Turned_off__c = true;
        insert tc;
        TestDataFactory.createQuoteWithItems();

    }
        
	 static testmethod void testCalloutCellExpert(){
        List<Quote> quoteList = [SELECT Id,OpportunityId FROM Quote LIMIT 1];
        Opportunity oppnueva = [Select Id,CurrencyIsoCode, Pricebook2Id from Opportunity Where Id =:quoteList[0].OpportunityId LIMIT 1];
        //RM_SyncQuoteService.syncQuote(new Set<Id>{quoteList[0].Id});

        //  List<Opportunity> oppList = [SELECT Id FROM Opportunity LIMIT 1];
         List<String> oppIds = new List<String>();
         oppIds.add(quoteList[0].OpportunityId);
         Product2 prod = new Product2();
        prod.Name = 'prod 1';
        prod.Codigo_de_Producto__c = 'Serie 1';
        prod.ProductCode = 'prod 1';
        prod.IsActive = true;
       	prod.Color__c = 'rojo';
        prod.es_Vehiculo_usado__c = true;
        prod.Marca__c = 'BMW';
        //prod.modelo__c = 'prod 1';
        prod.Description = '25d PAQ M';
        prod.NombredePlantilla__c = 'BMWX5AgradecimientoVisita';
        //prod.Familia__c = 'Serie 1';
        //prod.Grupo__c = 'Serie 1';
        insert prod;
        
        PriceBookEntry pbe = [Select Id,CurrencyIsoCode from PriceBookEntry Where Pricebook2Id =: oppnueva.Pricebook2Id LIMIT 1 ];
         delete quoteList;
         oppnueva.CurrencyIsoCode = pbe.CurrencyIsoCode;
         update oppnueva;
         OpportunityLineItem lineItem2 = new OpportunityLineItem();
        lineItem2.Preciodefacturacion__c = 220000;
        lineItem2.OpportunityId = oppnueva.Id;
        lineItem2.Marca__c = prod.Marca__c;
        lineItem2.Modelo_De_Inter_s1__c = prod.Modelo_De_Inter_s__c;
        lineItem2.Familia1__c = prod.Familia__c;
        lineItem2.Product2Id = prod.Id;
        lineItem2.PriceBookEntryId = pbe.Id;
        lineItem2.Quantity = 1;
        //lineItem2.PricebookEntryId = pbe.Id;
        lineItem2.TotalPrice = 225000;
        List<Product2> productosList = [Select Id, es_Vehiculo_usado__c From Product2];
         for(Product2 prodtest : productosList){
             prodtest.es_Vehiculo_usado__c = true;
         }
        insert lineItem2;  
                  update productosList;
         UsadosEnviarNotiAprobacion.enviarNotiUsados(oppIds);
    }
}