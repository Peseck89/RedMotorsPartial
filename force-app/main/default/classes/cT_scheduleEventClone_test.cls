@istest(seeAllData=true)
public with sharing class cT_scheduleEventClone_test {

    static testMethod void testExecuteMethod() {
        // Create a test SchedulableContext
        Test.startTest();        
        // Instantiate and execute the Schedulable class
        cT_scheduleEventClone scheduler = new cT_scheduleEventClone();
 
        String sch ='0 48 * * * ?'; 
        System.schedule('Schedule to update Account Name', sch,scheduler);
        // Stop the test execution context
        Test.stopTest();

     
    }
}