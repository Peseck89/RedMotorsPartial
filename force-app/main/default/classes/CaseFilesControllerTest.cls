@isTest(seeAllData = true)
private class CaseFilesControllerTest {
    
    @isTest
    static void testGetRelatedFiles() {
        // Get the test case
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        
        // Call the method and verify the results
        Test.startTest();
        List<ContentDocumentLink> relatedFiles = CaseFilesController.getRelatedFiles(testCase.Id);
        Test.stopTest();
        
        // Assert the results

    }
}