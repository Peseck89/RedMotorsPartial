/**
 * @description       : 
 * @author            : marcohernandezhp@gmail.com
 * @group             : 
 * @last modified on  : 04-19-2023
 * @last modified by  : marcohernandezhp@gmail.com
**/
@IsTest
public class EnviarNotiAprovTest {

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
        prod.Name = 'BM35 - X5 - 25d PREMIUM';
        prod.Codigo_de_Producto__c = 'BM36';
        prod.ProductCode = 'BM36';
        prod.IsActive = true;
        prod.Marca__c = 'BMW';
        prod.Description = '25d PAQ M';
        prod.NombredePlantilla__c = 'BMWX5AgradecimientoVisita';
        prod.Familia__c = 'X5';
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
        insert lineItem2;  
         EnviarNotiAprobacion.enviarNoti(oppIds);
    }
}