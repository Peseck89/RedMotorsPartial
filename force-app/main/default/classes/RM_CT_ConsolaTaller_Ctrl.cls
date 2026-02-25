/**
 * @description       : Funciones comunes para la consola
 * @author            : marcohernandezhp@gmail.com
 * @group             : Redmotors
 * @last modified on  : 07-25-2023
 * @last modified by  : marcohernandezhp@gmail.com
**/
public with sharing class RM_CT_ConsolaTaller_Ctrl {

    @AuraEnabled(cacheable=true)
    public static List<RM_Option> getWorkStepStatus()
    {
       List<RM_Option> options = new List<RM_Option>();
       Schema.DescribeFieldResult fieldResult = WorkStep.Status.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
       for( Schema.PicklistEntry f : ple)
       {
            if (f.isActive()) {
                options.add(new RM_Option(f.getLabel(), f.getValue()));
            }
       }
       return options;
    }

    @AuraEnabled(cacheable=true)
    public static List<RM_Option> getServiceTypes()
    {
       List<RM_Option> options = new List<RM_Option>();
       options.add(new RM_Option('Todos','all'));
       Schema.DescribeFieldResult fieldResult = WorkOrder.Tipo_de_servicio__c.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
       for( Schema.PicklistEntry f : ple)
       {
            if (f.isActive()) {         
                options.add(new RM_Option(f.getLabel(), f.getValue()));
            }
       }
       return options;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<RM_Option> getTerritories(Boolean flagMultiSelect) {
        List<RM_Option> options = new List<RM_Option>();
        if(!flagMultiSelect){
            options.add(new RM_Option('Todos','all'));
        }
        for (ServiceTerritory st : getUserTerritories()) {
            options.add(new RM_Option(st.Name,st.Id));
        }
        return options;
    }
    
    public static List<ServiceTerritory> getUserTerritories() {      
        List<FSL__User_Territory__c> listaTerritorio = [SELECT FSL__Territory_Name__c FROM FSL__User_Territory__c WHERE FSL__User__c =: UserInfo.getUserId()];
        List<String> newList = new List<String>();
        For(FSL__User_Territory__c territ : listaTerritorio ){
            newList.add(territ.FSL__Territory_Name__c);
        }        
        return [SELECT Id,Name FROM ServiceTerritory WHERE Name IN :newList];
    }

}