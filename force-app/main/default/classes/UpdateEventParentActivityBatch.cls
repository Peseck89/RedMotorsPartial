global class UpdateEventParentActivityBatch implements Database.Batchable<SObject>, Database.Stateful {
    
    // The start method collects the records to be processed
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = '';
        if(!Test.isRunningTest()){
        	query = 'SELECT Id, CreatedDate, Event_Shadow__c FROM Event WHERE ParentActivity__c = null AND Owner.FirstName LIKE \'%Calendario%\' AND Event_Shadow__c != null AND CreatedDate > 2024-05-06T03:33:51.000+0000';
        }else{
            query = 'SELECT Id, CreatedDate, Event_Shadow__c FROM Event WHERE ParentActivity__c = null AND Owner.FirstName LIKE \'%Calendario%\' AND Event_Shadow__c != null AND CreatedDate > 2024-05-06T03:33:51.000+0000 LIMIT 1';
        }
        return Database.getQueryLocator(query);
    }
    
    // The execute method processes the records in chunks
    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        List<Event> lstEventos = (List<Event>) scope;
        List<Event> actualizar = new List<Event>();

        for(Event evento : lstEventos) {
            List<Event> lstEventosPadres = [SELECT Id, CreatedDate, Event_Shadow__c FROM Event WHERE Event_Shadow__c = :evento.Event_Shadow__c AND Id != :evento.Id];
            if(lstEventosPadres.size() > 0) {
                evento.ParentActivity__c = lstEventosPadres[0].Id;
                actualizar.add(evento);
            }
        }

        if(!actualizar.isEmpty()) {
            update actualizar;
        }
    }
    
    // The finish method performs final operations after all batches are processed
    global void finish(Database.BatchableContext BC) {
        // Any post-processing logic can be added here, if needed
    }
}