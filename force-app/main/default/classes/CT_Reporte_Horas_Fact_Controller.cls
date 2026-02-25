/**
 * @description       : Controller class para el reporte de horas facturadas
 * @author            : marcohernandezhp@gmail.com
 * @group             : Redmotor
 * @last modified on  : 02-14-2023
 * @last modified by  : marcohernandezhp@gmail.com
**/
public without sharing class CT_Reporte_Horas_Fact_Controller {


    @AuraEnabled(cacheable=true)
    public static List<Config_Disponibilidad__c> getConfig(){
        List<Config_Disponibilidad__c> configList = new List<Config_Disponibilidad__c>();
        Map<String,Object> responseMap = new Map<String,Object>();
        try {
            configList = [SELECT Id,Name,Taller__c,Mecanico__c,Dias_x_mes__c,Horas_x_dia__c FROM Config_Disponibilidad__c];       
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return configList;
    }

}