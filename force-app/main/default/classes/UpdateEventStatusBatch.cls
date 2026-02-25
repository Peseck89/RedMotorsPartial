global class UpdateEventStatusBatch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        // Calcula el DateTime una hora antes de ahora
        DateTime oneHourAgo = System.now().addHours(-1);
        
        // Usa la variable calculada dentro del SOQL
        if(test.isRunningTest()){
            return Database.getQueryLocator([
                SELECT Id, ActivityDateTime, Estado__c
                FROM Event
                WHERE Estado__c  = '' 
                AND ActivityDateTime <= :oneHourAgo LIMIT 1
            ]);
        }else{
            return Database.getQueryLocator([
                SELECT Id, ActivityDateTime, Estado__c
                FROM Event
                WHERE Estado__c = '' 
                AND ActivityDateTime <= :oneHourAgo
            ]);
        }
        
    }

    global void execute(Database.BatchableContext bc, List<Event> scope) {
        if (!scope.isEmpty()) {
            for (Event ev : scope) {
                ev.Estado__c = 'No se presentó';
            }
            update scope;
        }
    }

    global void finish(Database.BatchableContext bc) {
        System.debug('Batch Job Completed: Updated events to "No se presentó".');
    }
}