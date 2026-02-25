/**
 * @description       : Controller provee información al reporte cronologico
 * @author            : marcohernandezhp@gmail.com
 * @group             : Redmotors
 * @last modified on  : 06-01-2023
 * @last modified by  : marcohernandezhp@gmail.com
**/
public without sharing class CT_Reporte_Cronologico_Controller {
    
    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getWorkSteps(List<String> territories,String mechanicId,String caseNumber,Date startDate, Date endDate){
        Map<String,Object> responseMap = new Map<String,Object>();
        
        //Los que el usuario tiene asignados
        Set<Id> territoryIds = WorkStepService.getAssignedTerritories();

        String soqlString  = 'SELECT Id, CreatedById, Name, Work_Step__c, Work_Step__r.Name,Work_Step__r.StartTime, Work_Step__r.EndTime, Work_Step__r.Mec_nico_asignado__c,'+
	                        ' Work_Step__r.Mec_nico_asignado__r.Name,'+
	                        ' Work_Step__r.Status, Work_Step__r.Caso__r.CaseNumber,'+
	                        ' Work_Step__r.Caso__r.Id, New_Value__c, Old_Value__c, Start_Date_Time__c,'+
	                        ' End_Date_Time__c, Work_Step__r.WorkOrder.ServiceTerritory.Name,Work_Step__r.Tipo_de_trabajo_del_caso__r.Nombre_TTC__c FROM Log_Status__c ';        

        String soqlFilterString = ' WHERE  Work_Step__r.Mec_nico_asignado__c != null ';

        //Los que el usuario selecciono desde la pantalla
        if(territories != null && !territories.isEmpty()){
            soqlFilterString += ' AND Work_Step__r.WorkOrder.ServiceTerritoryId IN :territories  ';
        }
        
        if(String.isNotBlank(mechanicId)){
            soqlFilterString += ' AND Mecanico__c = \''+ mechanicId.trim() +'\' ';
        }             
        
        if(String.isNotBlank(caseNumber)){
            soqlFilterString += ' AND Work_Step__r.Caso__r.CaseNumber = \''+ caseNumber.trim() +'\' ';
        }
                
        if(startDate == null || endDate == null){
            return responseMap;
        }
              
        soqlFilterString += ' AND Work_Step__r.WorkOrder.CT_Fecha_Creacion_FM__c >= :startDate AND Work_Step__r.WorkOrder.CT_Fecha_Creacion_FM__c <= :endDate';                

        soqlString += soqlFilterString;  
        
        soqlString += ' ORDER BY Work_Step__r.Caso__r.CaseNumber ASC,Work_Step__r.StartTime';        

        List<Log_Status__c> workStepList = (List<Log_Status__c>) Database.query(soqlString); 
        
        responseMap.put('records', workStepList);

        return responseMap;      
    }
}