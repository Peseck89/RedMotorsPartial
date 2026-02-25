/**
 * @description       : 
 * @author            : esteban@incompany.cr
 * @group             : 
 * @last modified on  : 04-11-2022
 * @last modified by  : esteban@incompany.cr
**/
@isTest
public class SaldosFromAlticaBDSchedule_Test {
    public static String CRON_EXP = '0 0 0 30 6 ? 2023';
    @isTest
    static void scheduleTest()
    {
        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('ScheduledApexTest',
            CRON_EXP,
            new SaldosFromAlticaBDSchedule());

        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
        NextFireTime
        FROM CronTrigger WHERE id = :jobId];

        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        Test.stopTest();
    }
}