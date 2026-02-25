@isTest(SeeAllData=true)
public class WorkorderHistoryCommunity_test {
 @isTest
    static void testWorkorderHistoryCommunity() {
        // Fetch an existing Case ID
        // WorkOrder
        WorkOrder wo = [Select Id,CaseId From WorkOrder Where CaseId != null LImit 1];
        Case testCase = [SELECT Id FROM Case Where Id =: wo.CaseId LIMIT 1];

        // Ensure there is at least one Case for testing
        System.assertNotEquals(null, testCase, 'An existing Case is required for testing.');

        // Simulate a page context with the required caseId parameter
        ApexPages.currentPage().getParameters().put('caseId', testCase.Id);

        // Create a mock StandardController with the Case record
        ApexPages.StandardController controller = new ApexPages.StandardController(testCase);

        // Initialize the WorkorderHistoryCommunity controller
        Test.startTest();
        WorkorderHistoryCommunity communityController = new WorkorderHistoryCommunity(controller);
        WorkorderHistoryCommunity.dummy();
        Test.stopTest();
        
    }
}