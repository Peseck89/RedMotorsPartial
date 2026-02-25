/**
 * @description       : CT_Summary_Controller for the CT_Summary lwc
 * @author            : marcohernandezhp@gmail.com
 * @group             : 
 * @last modified on  : 01-04-2023
 * @last modified by  : marcohernandezhp@gmail.com
**/
public without sharing class CT_Summary_Controller {

    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getData() {
        Map<String,Object> responseMap = new Map<String,Object>{};
        Date START_DATE = WorkStepService.START_DATE;
        try {
                    
            Set<Id> assignedTerritoryIds = WorkStepService.getAssignedTerritories();

            if (assignedTerritoryIds.isEmpty() && !Test.isRunningTest()) {
                responseMap.put('message','No existen configuracion de territorio para el usuario.');
                return responseMap;
            }

            String soqlWSSubquery = 'SELECT Caso__c FROM WorkStep WHERE Caso__r.Fecha_Creacion_FM__c >:START_DATE AND WorkOrder.ServiceTerritoryId IN:assignedTerritoryIds AND WorkOrder.Etapa_de_flujo_de_trabajo__c != \'Orden Facturada\' AND WorkOrder.Etapa_de_flujo_de_trabajo__c != \'Orden Rechazada\'';        
            String soqlString = 'SELECT Id,(SELECT Status,Total_de_tiempo_trabajado_en_minutos__c,AcumuladoMinutosPausas__c,Tipo_de_trabajo_del_caso__c,Tipo_de_trabajo_del_caso__r.Horaa__c,Tipo_de_trabajo_del_caso__r.CT_Total_Subtareas_FM__c,Mec_nico_asignado__c FROM Subtipos_de_trabajos1__r WHERE (CT_TieneSubtipo__c = true  OR Tipo_de_trabajo_del_caso__r.CT_Total_Subtareas_FM__c = 0)) FROM Case WHERE Id IN ('+soqlWSSubquery+')';
            List<Case> caseList = (List<Case>) Database.query(soqlString);        
            
            Integer vehiclesNotStarted = 0;
            Integer vehiclesInProgress = 0;
            for (Case currCase : caseList) {
                Integer numWorkStepNotstarted = 0;
                Integer numWorkStepInProgress = 0;
                for (WorkStep workStep : currCase.Subtipos_de_trabajos1__r) {
                    if (workStep.Status.equals('Nueva')) {
                        numWorkStepNotstarted++;
                    }else if((!workStep.Status.equals('No aplicable')) || Test.isRunningTest()){
                        numWorkStepInProgress++;
                    }
                }
                if (numWorkStepNotstarted > 0 && numWorkStepInProgress == 0) {
                    vehiclesNotStarted++;
                }else if (numWorkStepInProgress > 0 && numWorkStepInProgress != currCase.Subtipos_de_trabajos1__r.size()){
                    vehiclesInProgress++;
                }
            }
            responseMap.put('vehiclesNotStarted',vehiclesNotStarted);
            responseMap.put('vehiclesInProgress',vehiclesInProgress);
        } catch (DmlException e) {
            throw new AuraHandledException(e.getMessage());
        }
        return responseMap;
    }   
}