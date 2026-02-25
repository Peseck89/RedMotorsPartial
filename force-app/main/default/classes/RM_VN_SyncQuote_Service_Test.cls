@IsTest
public with sharing class RM_VN_SyncQuote_Service_Test {
    @TestSetup
    static void makeData(){
        TestDataFactory.createQuoteWithItems();
    }

    @IsTest
    public static void test_SyncQuote(){
        Quote quote = [SELECT Id FROM Quote LIMIT 1];
        Set<Id> quoteIds = new Set<Id>();
        quoteIds.add(quote.Id);
        RM_VN_SyncQuote_Service.sync(quoteIds);
    }
}