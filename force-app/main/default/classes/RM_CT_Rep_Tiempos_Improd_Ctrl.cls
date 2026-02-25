/**
 * @description       : Controlador reporte de tiempos improductivos
 * @author            : marcohernandezhp@gmail.com
 * @group             : Redmotors
 * @last modified on  : 06-08-2023
 * @last modified by  : marcohernandezhp@gmail.com
**/
public without sharing class RM_CT_Rep_Tiempos_Improd_Ctrl {
    
    public static final Integer PAGE_SIZE = 15;

    public static final Date START_DATE = WorkStepService.START_DATE; 

    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getRecords(List<String> territories,String mechanicId,String caseNumber,String workOrderNumber,Date startDate,Date endDate,Integer pageNumber){
        Map<String,Object> responseMap = new Map<String,Object>{'success' => false};           
        
        if(startDate == null || endDate == null){
            return responseMap;
        }        

        pageNumber = pageNumber != null ? pageNumber : 1;
        
        //Los que el usuario tiene asignados
        Set<Id> territoryIds = WorkStepService.getAssignedTerritories();

        String soqlString  = 'SELECT Id, Observaciones__c,Mecanico__r.Name,Caso__r.CaseNumber,Caso__c,Work_Step__c,Work_Step__r.Name,Fecha__c,Inicio__c FROM Horas_improductivas_por_mec_nico__c ';        

        String soqlFilterString = ' WHERE Mecanico__c != null ';

        // String soqlStringFilter = ' WHERE Work_Step__r.Caso__r.Fecha_Creacion_FM__c > :START_DATE AND WorkOrder.ServiceTerritoryId IN:relatedTerritoryIds AND Flag_Is_Task_FX__c = true AND WorkOrder.Etapa_de_flujo_de_trabajo__c NOT IN(\'Orden Facturada\',\'Orden Rechazada\') ';

        //Los que el usuario selecciono desde la pantalla
        // if(territories != null && !territories.isEmpty()){
        //     soqlFilterString += ' AND Work_Step__r.WorkOrder.ServiceTerritoryId IN :territories  ';
        // }
        
        if(String.isNotBlank(mechanicId)){
            soqlFilterString += ' AND Mecanico__c = \''+ mechanicId.trim() +'\' ';
        }    
        
        if(String.isNotBlank(caseNumber)){
            soqlFilterString += ' AND Caso__r.CaseNumber LIKE \'%'+ caseNumber.trim() +'%\'';
        }               
                  
        if(startDate != null){                  
            soqlFilterString += ' AND (Fecha__c >= :startDate OR Inicio__c >= :startDate )';
        }
        
        if(endDate != null){
            soqlFilterString += ' AND (Inicio__c <= :endDate OR Fin__c  <= :endDate)';            
        }

        soqlString += soqlFilterString;  
        
        soqlString += ' ORDER BY Fecha__c ';        
        try {
            responseMap.put('records',(List<Horas_improductivas_por_mec_nico__c>) Database.query(soqlString));
        } catch (DMLException e) {
            if (!Test.isRunningTest()) {
                throw new AuraHandledException(e.getMessage());
            }else {
                System.debug(e.getMessage());
            }
        }
        return responseMap;      
    }

}