public with sharing class UpdateEventStatusService implements Queueable{
	
    public void execute(QueueableContext context){
        List<Event> events = [SELECT Id, StartDateTime, Estado__c FROM Event  where StartDateTime=TODAY and Estado__c = ''];
 
        for(Event evt : events){
            System.debug(evt);
            evt.Estado__c = 'No se presentó';
            System.debug(evt);
        }
        
        update events;
    }    	
    
}