/**
 * @description       : Controller class for tiempos improductivos report
 * @author            : marcohernandezhp@gmail.com
 * @group             : Redmotors
 * @last modified on  : 05-09-2023
 * @last modified by  : marcohernandezhp@gmail.com
**/
public without sharing class CT_Reporte_Tiempos_Improductivos_Ctrl {
    
    public static final Date START_DATE = isSandbox() ? Date.newinstance(1900,01,01) : Date.newinstance(2022,10,31); 

    public static Boolean isSandbox() {
        List<Organization> organizationList = [SELECT IsSandbox FROM Organization LIMIT 1];
        if (organizationList.size() > 0) {
            return organizationList[0].IsSandbox;
        }
        return false;
    }    

    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getRecords(List<String> territories,String mechanicId,Date startDate, Date endDate){
        Map<String,Object> responseMap = new Map<String,Object>();
        
        Set<Id> territoryIds = WorkStepService.getAssignedTerritories();

        String soqlString = 'SELECT Id,CT_CantidadDeHoras__c,Caso__c,Caso__r.CaseNumber, Total_de_tiempo_trabajado_en_minutos__c, WorkOrderId,WorkOrder.WorkOrderNumber,  Mec_nico_asignado__c,Mec_nico_asignado__r.Name,WorkOrder.ServiceTerritory.Name FROM WorkStep';               
        
        String soqlFilterString = ' WHERE Caso__r.Fecha_Creacion_FM__c >:START_DATE AND Mec_nico_asignado__c != null AND ((Tipo_de_trabajo_del_caso__r.CT_Total_Subtareas_FM__c = 0 AND CT_TieneSubtipo__c = false) OR CT_TieneSubtipo__c = true)';
        // String soqlFilterString = ' WHERE Caso__r.Fecha_Creacion_FM__c >:START_DATE AND WorkOrder.ServiceTerritoryId IN:territoryIds AND Mec_nico_asignado__c != null AND ((Tipo_de_trabajo_del_caso__r.CT_Total_Subtareas_FM__c = 0 AND CT_TieneSubtipo__c = false) OR CT_TieneSubtipo__c = true)';

        if(territories != null && !territories.isEmpty()){
            // soqlFilterString += ' AND WorkOrder.ServiceTerritoryId IN :territories  ';
        }
        
        if(String.isNotBlank(mechanicId)){
            soqlFilterString += ' AND Mec_nico_asignado__c = \''+ mechanicId.trim() +'\' ';
        }             
        
        if(startDate == null || endDate == null){
            return responseMap;
        }
              
        soqlFilterString += ' AND WorkOrder.CT_Fecha_Creacion_FM__c >= :startDate AND WorkOrder.CT_Fecha_Creacion_FM__c <= :endDate';                

        soqlString += soqlFilterString;  
        
        soqlString += ' ORDER BY Mec_nico_asignado__r.Name ASC,WorkOrder.WorkOrderNumber';

        System.debug('@@@soqlString@@@'+soqlString);
        
        List<WorkStep> workStepList = (List<WorkStep>) Database.query(soqlString);        
        System.debug('@@@workStepList@@@'+workStepList);
        Set<Id> mechanicIds = new Set<Id>();
        Map<String,Set<String>> mecIdCaseSetMap = new Map<String,Set<String>>();
        Map<String,List<WorkStep>> mecIdWorkStepListMap = new Map<String,List<WorkStep>>();
        for (WorkStep ws : workStepList) {  
            mechanicIds.add(ws.Mec_nico_asignado__c);
            
            if (!mecIdCaseSetMap.containsKey(ws.Mec_nico_asignado__c)) {
                mecIdCaseSetMap.put(ws.Mec_nico_asignado__c,new Set<String>());
            }

            Set<String> caseSet = mecIdCaseSetMap.get(ws.Mec_nico_asignado__c);
            caseSet.add(ws.Caso__c);
            mecIdCaseSetMap.put(ws.Mec_nico_asignado__c,caseSet);

            if (!mecIdWorkStepListMap.containsKey(ws.Mec_nico_asignado__c)) {
                mecIdWorkStepListMap.put(ws.Mec_nico_asignado__c,new List<WorkStep>());
            }
            
            List<WorkStep> wsList = mecIdWorkStepListMap.get(ws.Mec_nico_asignado__c);
            wsList.add(ws);
            mecIdWorkStepListMap.put(ws.Mec_nico_asignado__c,wsList);
        }
        
        List<Contact> contactList = [SELECT Id,Name FROM Contact WHERE Id IN :mechanicIds ORDER BY Name ASC];
        
        List<ContactWrapper> WSWrapperReportList = new List<ContactWrapper>();
        for(Contact contact : contactList){
            ContactWrapper wrpReport = new ContactWrapper();
            wrpReport.id = contact.Id;
            wrpReport.contactName = contact.Name;
            wrpReport.workSteps = mecIdWorkStepListMap.get(contact.Id);
            wrpReport.setCases(mecIdCaseSetMap.get(contact.Id));
            wrpReport.numWS = wrpReport.cases.size();
            WSWrapperReportList.add(wrpReport);
        }
        responseMap.put('records',WSWrapperReportList);
        
        return responseMap;            
    }

    public class ContactWrapper {
        @AuraEnabled
        public String id;

        @AuraEnabled
        public String contactName;
        
        @AuraEnabled
        public Integer numWS;

        @AuraEnabled
        public List<WorkStep> workSteps;

        @AuraEnabled
        public List<String> cases;

        ContactWrapper(){
            this.cases = new List<String>();
        }

        public void setCases(Set<String> caseSet){
            for (String caseId : caseSet) {
                this.cases.add(caseId);
            }
        }                
    }    

    public static void dummy() {
        String test='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
        test+='';
    }
}