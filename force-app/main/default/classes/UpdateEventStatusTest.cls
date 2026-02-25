@isTest
public class UpdateEventStatusTest {
   
    @isTest static void updateScheduleTest(){
        String scheduleTime = '00 00 01 * * ?';
        Test.startTest();
        String jobID=System.schedule('Update Status Schedule', scheduleTime, new UpdateEventStatus());
        Test.stopTest();
    }
}