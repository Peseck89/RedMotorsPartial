@IsTest(SeeAllData=true)
public class cT_CloneEventsBatch_test {
@isTest static void test() {
        Test.startTest();
        cT_CloneEventsBatch uca = new cT_CloneEventsBatch();
        Id batchId = Database.executeBatch(uca);
        Test.stopTest();
    }
}