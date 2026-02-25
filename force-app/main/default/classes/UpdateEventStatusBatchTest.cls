@isTest(seeAllData=true)
public class UpdateEventStatusBatchTest {      
    @isTest
    static void testBatchExecution() {
        // Verifica datos iniciales
        List<Event> eventsBefore = [SELECT Id, ActivityDateTime, Estado__c FROM Event Limit 1];
        
        
        // Ejecuta el batch
        Test.startTest();
        UpdateEventStatusBatch batch = new UpdateEventStatusBatch();
        Database.executeBatch(batch, 200);
        Test.stopTest();
        
        // Verifica los resultados
        List<Event> eventsAfter = [SELECT Id, ActivityDateTime, Estado__c FROM Event ORDER BY ActivityDateTime ASC];
        
    
    }
}