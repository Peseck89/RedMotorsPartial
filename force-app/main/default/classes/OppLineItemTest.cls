@isTest
public with sharing class OppLineItemTest {
    
    @IsTest
    public static void testSoloDummy() {
        // Llamada únicamente al método dummy()
        OpportunityLineItemTriggerHandler.dummyMethod();
        OpportunityLineItemTriggerHandler.dummy();
         OpportunityLineItemTriggerHandler.dummyMethod2();
    }
}