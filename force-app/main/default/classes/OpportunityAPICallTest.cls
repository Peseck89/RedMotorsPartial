@isTest(SeeAllData=true)
private class OpportunityAPICallTest {

    @isTest
    private static void sendOpportunityDataToAwsTest(){

        Test.setMock(HttpCalloutMock.class, new LeadAPIBatchCallMock());
        Test.startTest();
        DataUploadController.initiateOpportunityImport();
        Test.stopTest();
    }
}