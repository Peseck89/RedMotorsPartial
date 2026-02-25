@IsTest
public without sharing class QuoteTriggerHandlerTest_v2 {
    @TestSetup
    static void makeData(){
        TestDataFactory.createQuoteWithItems();
    }

    @IsTest
    public static void test_setSyncedQuoteIdOnOpportunity(){
        List<Quote> quoteList = [SELECT Name,QuoteNumber,OpportunityId FROM Quote LIMIT 1];
        Set<Id> quoteIds = new Set<Id>();
        for (Quote currQuote : quoteList) {
            quoteIds.add(currQuote.Id);
        }
        Test.startTest();
            RM_SyncQuoteService_v2.syncQuote(quoteIds);
        Test.stopTest();
        quoteList = [SELECT Name,Opportunity.Synced_Quote__c FROM Quote WHERE Id =:quoteList[0].Id LIMIT 1];
        System.assert(quoteList[0].Opportunity.Synced_Quote__c == quoteList[0].Id, 'Se esperaba que el campo syn a nivel oportunidad fuera actualizado.');
    }

    @IsTest
    public static void test_calculateTaxes(){
        
    }

    @IsTest
    public static void test_addExpirationDate(){
        List<Opportunity> oppList = [SELECT Id FROM Opportunity LIMIT 1];
        System.assert(oppList.size()>0,'No opportunities found');

        Quote newQuote = TestDataFactory.createQuote(oppList[0],'15 Días',true);
        List<Quote> quoteList = [SELECT Id,ExpirationDate FROM Quote WHERE Id = :newQuote.Id LIMIT 1];
        System.debug('@quoteList@'+quoteList[0].ExpirationDate);
        System.debug('@expirationDate@'+Date.today().addDays(15));
        System.assert(Date.today().addDays(15) == quoteList[0].ExpirationDate, 'the expiration date is not valid ('+Date.today().addDays(15)+')');
    } 
    
    @IsTest
    public static void test_setFriendlyQuoteName(){
        List<Quote> quoteList = [SELECT Name,QuoteNumber FROM Quote LIMIT 1];
        System.assert(quoteList.size()>0,'No quotes found');

        String friendlyQuoteName = 'PT-'+quoteList[0].QuoteNumber;
        System.assert(quoteList[0].Name == friendlyQuoteName, 'Quote name is different from Quote Number');
    }    
}