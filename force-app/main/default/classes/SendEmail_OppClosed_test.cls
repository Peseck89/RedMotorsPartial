@istest(seeAllData=true)
public class SendEmail_OppClosed_test {
 static testMethod void testExecuteMethod() {
     // Create a test SchedulableContext
        Test.startTest();        
        // Instantiate and execute the Schedulable class
        scheduleSendEmail_OppClosed scheduler = new scheduleSendEmail_OppClosed();
 
        String sch ='0 48 * * * ?'; 
        System.schedule('Schedule to send opp email', sch,scheduler);
        // Stop the test execution context
        Test.stopTest();
 }
}