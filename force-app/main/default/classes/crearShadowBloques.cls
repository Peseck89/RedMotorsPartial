public class crearShadowBloques {
 public static void onBeforeInsert(List<Event> newList) {
     List<Event_Shadow__c> lstShadow = new List<Event_Shadow__c>();
     
     
     for(Event rec : newList) {  
         if(rec.RecordTypeId == '012PH000002dSzNYAU' && rec.Owner.FirstName != 'Calendario'){
             List<AsesorxCalendario__c> asesoresPorCalendario = [SELECT Asesor__c, Calendario__c FROM AsesorxCalendario__c WHERE Asesor__c =:rec.OwnerId Limit 1];
             if(asesoresPorCalendario.size()>0){
                 if (rec.StartDateTime != null && rec.EndDateTime != null) {
             Double timeDifferenceInHours = (rec.EndDateTime.getTime() - rec.StartDateTime.getTime()) / (1000 * 60 * 60); // Convert milliseconds to hours
             System.debug(timeDifferenceInHours);
             System.debug(timeDifferenceInHours > 1); // 0.5 represents 30 minutes in terms of hours
             datetime fecha1 = rec.StartDateTime;
             //datetime fecha2 = lstEvent[0].StartDateTime.addMinutes(30);
             
             if(timeDifferenceInHours > 0.5){
                 while (fecha1 < rec.EndDateTime) {
                     Event_Shadow__c newShadow = new Event_Shadow__c();
                     newShadow.ActivityDate__c = fecha1;
                     newShadow.Asesor__c = rec.OwnerId;
                     newShadow.Calendar__c = asesoresPorCalendario[0].Calendario__c;
                     newShadow.Description2__c = 'creado desde trigger';
                     newShadow.EndDateTime__c = fecha1.addMinutes(30);
                     newShadow.StartDateTime__c = fecha1;
                     newShadow.Tipo_de_cita__c = 'Asesor';
                     lstShadow.add(newShadow);
                     fecha1 = fecha1.addMinutes(30);
                 }
                 
                 //System.debug(lstShadow);
             }
         }
     }
     insert lstShadow;
             }
         	
   }
 }
}