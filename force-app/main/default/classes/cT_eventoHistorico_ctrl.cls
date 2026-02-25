public with sharing class cT_eventoHistorico_ctrl {
    @AuraEnabled(cacheable=true)
    public static List<Horarios_Historicos__c> getHistorico (String recordId){
        List<Horarios_Historicos__c> lstHistoricos = [SELECT Id,Hora_Original__c,Horario_Modificado__c,Movimiento__c FROM Horarios_Historicos__c WHERE Evento_Origen__c	=:recordId];
        return lstHistoricos;
    }
}