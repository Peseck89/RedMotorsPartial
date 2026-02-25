@isTest(seealldata = true)
public with sharing class OpportunityLeadController_test {
    public OpportunityLeadController_test() {

    }
    @isTest
    static void testGetRecords() {
        Test.startTest();
        
        List<sObject> records = OpportunityLeadController.getRecords(20, 1);
        
        Test.stopTest();
        
        
    }
    
    @isTest
    static void testGetRecordCount() {
        Test.startTest();
        
        Integer recordCount = OpportunityLeadController.getRecordCount();
        OpportunityLeadController.getAllRecords();
        Test.stopTest();
        
       
    }
}