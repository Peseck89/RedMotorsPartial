@isTest(seeAllData=true)
public class UpdateEventStatusScheduledTest {

    @isTest
    static void testScheduledApex() {
        // Simula la programación de la clase Scheduled Apex
        Test.startTest();
        String jobId = System.schedule('Test Scheduled Batch', '0 0 * * * ?', new UpdateEventStatusScheduled());
        Test.stopTest();
        
        // Verifica que la clase batch se ejecutó correctamente
        List<Event> eventsAfter = [SELECT Id, ActivityDateTime, Estado__c FROM Event ORDER BY ActivityDateTime ASC];

    }
}