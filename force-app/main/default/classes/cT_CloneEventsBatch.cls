public class cT_CloneEventsBatch implements Database.Batchable<sObject>, Database.AllowsCallouts,Database.Stateful {


    public Database.QueryLocator start(Database.BatchableContext bc) {
		if (test.isRunningTest()) {
            return Database.getQueryLocator(
                'Select Id,ActivityDate,StartDateTime,EndDateTime,OwnerId,Asesor__c,Activo__c,Event_Shadow__c,Owner.FirstName From Event WHERE Event_Shadow__c = null AND Asesor__c != null AND StartDateTime >= 2023-09-04T00:00:00.000+0000 LIMIT 50 '
            );
        }else{
            return Database.getQueryLocator(
            'Select Id,ActivityDate,StartDateTime,EndDateTime,OwnerId,Asesor__c,Activo__c,Event_Shadow__c,Owner.FirstName From Event WHERE  Asesor__c != null AND  ActivityDate >= TODAY '
        );
        }
        
    }
    public void execute(Database.BatchableContext bc, List<Event> scope){
        List<Event_Shadow__c> lstEvent = new List<Event_Shadow__c>();
        Map<Id, Id> mapaCalendarios = new Map<Id, Id>();
        Map<String, Id> mapaShadow = new Map<String, Id>();

        List<AsesorxCalendario__c> lstAsesor = [Select id,Calendario__c,Asesor__c From AsesorxCalendario__c];
        for(AsesorxCalendario__c asesor: lstAsesor){
            mapaCalendarios.put(asesor.Asesor__c, asesor.Calendario__c);
        }

        List<Event_Shadow__c> lstShadow = [Select id,OriginalEventId__c From Event_Shadow__c WHERE OriginalEventId__c != null AND  ActivityDate__c >= TODAY];
        for(Event_Shadow__c shadow: lstShadow){
            mapaShadow.put(shadow.OriginalEventId__c, shadow.id);
        }
        
        for (Event evento : scope) {
            String eventID = mapaShadow.get(evento.Id);
            if(eventID == null){
                if(evento.Owner.FirstName != 'Calendario Avaluos' && evento.Owner.FirstName != 'Calendario Reparaciones' && !String.isBlank(evento.Owner.FirstName) ){
                    
                    Event_Shadow__c newShadow = new Event_Shadow__c();
                    newShadow.ActivityDate__c = evento.StartDateTime;
                    newShadow.StartDateTime__c = evento.StartDateTime;
                    newShadow.EndDateTime__c = evento.EndDateTime;
                    if(evento.Owner.FirstName.Contains('Calendario')){
                        newShadow.Calendar__c = evento.OwnerId;
                    }else{
                        id calendario = mapaCalendarios.get(evento.OwnerId);
                        newShadow.Calendar__c = calendario;
                    }
                    
                    newShadow.OwnerId = evento.OwnerId;
                    newShadow.Asesor__c = evento.Asesor__c;               
                    newShadow.OriginalEventId__c = evento.Id;
                    if(evento.OwnerId == evento.Asesor__c){
                        newShadow.Tipo_de_cita__c = 'Asesor';
                    }else{
                        newShadow.Tipo_de_cita__c = 'Calendario';
                    }
                    lstEvent.add(newShadow);
                } 
            }                                
        }
        
        
        if(lstEvent.size()>0){
            try{
                insert lstEvent;
                
            }catch(Exception e){
                System.debug('Error--'+e.getMessage());
            }
            
        }

    }
    public void finish(Database.BatchableContext bc){

        // call some utility to send email
    }
}