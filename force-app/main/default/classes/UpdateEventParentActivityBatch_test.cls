@isTest(SeeAllData = true)
public class UpdateEventParentActivityBatch_test {
	@isTest
    static void testBatchExecution() {
        // Execute the batch
        Test.startTest();
        UpdateEventParentActivityBatch batch = new UpdateEventParentActivityBatch();
        Database.executeBatch(batch, 1); // Setting batch size to 1 for testing
        Test.stopTest();
    }
}