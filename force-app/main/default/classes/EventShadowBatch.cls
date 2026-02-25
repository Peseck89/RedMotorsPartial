global class EventShadowBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
        String query;
        if(Test.isRunningTest()) {
            query = 'Select Id, CreatedDate, LastModifiedDate, StartDateTime__c, EndDateTime__c, Activo__c, Description__c, Description2__c, Estado2__c, OrigenEvento__c, Asesor__c, Calendar__c, OriginalEventId__c, Subject__c, WhatId__c FROM Event_Shadow__c WHERE ToBeProcessed__c = true LIMIT 5';
        } else{
            query = 'Select Id, CreatedDate, LastModifiedDate, StartDateTime__c, EndDateTime__c, Activo__c, Description__c, Description2__c, Estado2__c, OrigenEvento__c, Asesor__c, Calendar__c, OriginalEventId__c, Subject__c, WhatId__c FROM Event_Shadow__c WHERE ToBeProcessed__c = true';
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Event_Shadow__c> eventShadowList) {
        List<Event_Shadow__c> eventsShadowToUpdate = new List<Event_Shadow__c>();
        List<Event> eventsToUpsert = new List<Event>();
        
        try {
            if(!eventShadowList.isEmpty()) {
                // For events in Assessor Calendar
                
                for(Event_Shadow__c eventSh : eventShadowList) {
                    
                    if(eventSh.CreatedDate == eventSh.LastModifiedDate){
                        Event newEvent = new Event();
                        newEvent.ActivityDateTime = eventSh.StartDateTime__c;
                        newEvent.StartDateTime = eventSh.StartDateTime__c;
                        //newEvent.EndDateTime = eventSh.EndDateTime__c; 
                        newEvent.EndDateTime = eventSh.StartDateTime__c.addMinutes(30);
                        newEvent.Activo__c = eventSh.Activo__c;
                        newEvent.Asesor__c = eventSh.Asesor__c;
                        newEvent.Description = eventSh.Description2__c;
                        newEvent.Estado__c = eventSh.Estado2__c;
                        newEvent.OwnerId = eventSh.Asesor__c;
                        /*newEvent.Calendario__c = eventSh.Asesor__c;*/
                        newEvent.Subject = eventSh.Subject__c;
                        newEvent.WhatId = eventSh.WhatId__c;
                        newEvent.UpdateOrigin__c = 'EventShadowBatchNewEvent';
                        newEvent.Event_Shadow__c = eventSh.Id;
                        newEvent.OrigenEvento__c = 'Formulario Web';
                        newEvent.UpdatedByFlow__c = True;
                        eventsToUpsert.add(newEvent);
                        
                        eventSh.Description__c = 'This is a test';
                        eventSh.ToBeProcessed__c = false;
                        eventSh.OriginalEventId__c = newEvent.Id;
                        eventSh.OrigenEvento__c ='EventShadowBatchUpdate';
                        eventsShadowToUpdate.add(eventSh);
                    }
                    
                    // The related Event to the Event Shadow, should be updated.
                   
                    else if(eventSh.CreatedDate != eventSh.LastModifiedDate){
                        Event eventRelated = new Event();
                        String relatedEventId = eventSh.OriginalEventId__c;
                        
                        if(relatedEventId!=''){
                            Event[] eventos = [Select Id, ActivityDate, EndDateTime, StartDateTime, Estado__c from Event where Id=:relatedEventId];
                            if (eventos.size()>0){
                            	eventRelated = eventos[0];
                            }                            
                        }
                        
                        eventRelated.Estado__c = eventSh.Estado2__c;
                        eventRelated.StartDateTime = eventSh.StartDateTime__c;
                        eventRelated.ActivityDateTime = eventSh.StartDateTime__c;
                        eventRelated.EndDateTime = eventSh.StartDateTime__c.addMinutes(30);
                        eventRelated.UpdateOrigin__c = 'EventShadowBatchUpdateEvent';
                        eventRelated.Event_Shadow__c = eventSh.Id;
                        eventsToUpsert.add(eventRelated);

                        eventSh.ToBeProcessed__c = false;
                        eventSh.OriginalEventId__c = eventRelated.Id;
                        eventsShadowToUpdate.add(eventSh);
                    }
                } 
                // For events in general Calendar
                
            }
            
            	upsert eventsToUpsert;
                Integer eventsToUpsertSize = eventsToUpsert.size();
                
                for(Integer i=0; i<eventsToUpsertSize;i++){
                    Event_Shadow__c eventsShadowElement = eventsShadowToUpdate[i];
                    Event eventElement  = eventsToUpsert[i];
                    eventsShadowElement.OriginalEventId__c = eventElement.Id;
                }
            
                update eventsShadowToUpdate;
            }            
     catch (DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());            
        }
    }    
    
    global void finish(Database.BatchableContext bc) {
        system.scheduleBatch(New EventShadowBatch(),'EventShadowBatch' + DateTime.now().getTime(),1);    
    }
    
    global void execute(SchedulableContext SC) {
        database.executeBatch(new EventShadowBatch());
    }
}