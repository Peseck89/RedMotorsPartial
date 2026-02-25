@IsTest
public with sharing class RM_SyncQuoteControllerTest {

    @TestSetup
    static void makeData(){
        TestDataFactory.createQuoteWithItems();
    }

    @IsTest
    public static void test_SyncQuote(){
        List<Quote> quoteList = [SELECT Id FROM Quote LIMIT 1];
        List<QuoteLineItem> quoteLineItemList = [SELECT Id,Product2.esVehiculo__c,Product2.es_Vehiculo_usado__c,QuoteId FROM QuoteLineItem];
        RM_SyncQuoteService.syncQuote(new Set<Id>{quoteList[0].Id});
    }

    @IsTest
    public static void test_controller(){      
        RM_SyncQuoteController ctl = new RM_SyncQuoteController();  
        List<Quote> quoteList = [SELECT Id FROM Quote LIMIT 1];
        
        // RM_SyncQuoteController.syncQuote(null);

        RM_SyncQuoteController.syncQuote(quoteList[0].Id);
    }
}