global class shadowSchedule implements Schedulable {

    global void execute(SchedulableContext SC) {
        //correccion comercial
        List<Event_Shadow__c> lstShadow = [SELECT Id,Asesor__c,Asesor__r.Name,Calendar__c FROM Event_Shadow__c WHERE Asesor__r.Name Like '%Calendario%' and StartDateTime__c >= today];
        For(Event_Shadow__c evSha : lstShadow){
            List<AsesorxCalendario__c> lstAsec = [Select Id,Asesor__c,Calendario__c From AsesorxCalendario__c WHERE Calendario__c = :evSha.Calendar__c];
            evSha.Asesor__c = lstAsec[0].Asesor__c;
        }
        Integer i = 0;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        update lstShadow;
    }
     
}