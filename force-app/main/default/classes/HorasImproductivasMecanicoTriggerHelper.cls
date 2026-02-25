/**
 * @description       : 
 * @author            : Marco Hernandez
 * @group             : Redmotors
 * @last modified on  : 10-28-2022
 * @last modified by  : marcohernandezhp@gmail.com
**/
public without sharing class HorasImproductivasMecanicoTriggerHelper {
    
    public static List<Horas_improductivas_por_mec_nico__c> createRecords(Horas_improductivas_por_mec_nico__c newRecord) {    
        List<Horas_improductivas_por_mec_nico__c> recordsToCreateList = new List<Horas_improductivas_por_mec_nico__c>();
        Date currentDate = newRecord.Inicio__c;
        Date endDate = newRecord.Fin__c;
        Set<String> daySet = new Set<String>();

        if (newRecord.L__c) {
            daySet.add('Monday');
        }
        if (newRecord.M__c) {
            daySet.add('Tuesday');
        }
        if (newRecord.K__c) {
            daySet.add('Wednesday');
        }
        if (newRecord.J__c) {
            daySet.add('Thursday');
        }
        if (newRecord.V__c) {
            daySet.add('Friday');
        }

        while (currentDate <= endDate) {            
            Datetime dt = (DateTime)currentDate;
            String day = dt.format('EEEE');
            if (newRecord.Se_repite__c.equalsIgnoreCase('Diariamente') || daySet.contains(day)) {
                Boolean isMonday = day.equalsIgnoreCase('Monday');
                Boolean isTuesday = day.equalsIgnoreCase('Tuesday');
                Boolean isWednesday = day.equalsIgnoreCase('Wednesday');
                Boolean isThursday = day.equalsIgnoreCase('Thursday');
                Boolean isFriday = day.equalsIgnoreCase('Friday');
                
                recordsToCreateList.add(
                    new Horas_improductivas_por_mec_nico__c(
                        Inicio__c = currentDate,
                        Fin__c = currentDate,
                        Hora_inicio__c = newRecord.Hora_inicio__c,
                        Hora_fin__c = newRecord.Hora_fin__c,
                        Tipo_de_Trabajo__c = newRecord.Tipo_de_Trabajo__c,
                        Mecanico__c = newRecord.Mecanico__c,
                        Se_repite__c = 'No repetir',
                        HIM__c = newRecord.Id,
                        Observaciones__c = newRecord.Observaciones__c,
                        L__c = isMonday,
                        M__c = isTuesday,
                        K__c = isWednesday,
                        J__c = isThursday,
                        V__c = isFriday
                    )
                );
            }

           if (newRecord.Se_repite__c.equalsIgnoreCase('Diariamente')) {            
                currentDate = currentDate.addDays(1);
            }else if(newRecord.Se_repite__c.equalsIgnoreCase('Semanalmente')){
                currentDate = currentDate.addDays(7);
            }else if(newRecord.Se_repite__c.equalsIgnoreCase('Mensualmente')){
                currentDate = currentDate.addMonths(1);
            } else {              
                currentDate = currentDate.addDays(1);
            }
        }
        return recordsToCreateList;
    }
}