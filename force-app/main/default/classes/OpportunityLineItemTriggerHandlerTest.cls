/**
 * @description       : 
 * @author            : marcohernandezhp@gmail.com
 * @group             : 
 * @last modified on  : 05-11-2023
 * @last modified by  : marcohernandezhp@gmail.com
**/
@IsTest
public without sharing class OpportunityLineItemTriggerHandlerTest {

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
            RM_SyncQuoteService.syncQuote(quoteIds);
        Test.stopTest();
        quoteList = [SELECT Name,Opportunity.Synced_Quote__c FROM Quote WHERE Id =:quoteList[0].Id LIMIT 1];
        System.assert(quoteList[0].Opportunity.Synced_Quote__c == quoteList[0].Id, 'Se esperaba que el campo syn a nivel oportunidad fuera actualizado.');

        List<OpportunityLineItem> oliList = [SELECT Id FROM OpportunityLineItem LIMIT 1];
        if (oliList.size()>0) {
            delete oliList;
        }
        
    }    

      
}