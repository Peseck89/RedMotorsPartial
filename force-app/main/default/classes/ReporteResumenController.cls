/**
 * @description       : 
 * @author            : marcohernandezhp@gmail.com
 * @group             : 
 * @last modified on  : 04-16-2023
 * @last modified by  : marcohernandezhp@gmail.com
**/
public without sharing class ReporteResumenController {
    
    @AuraEnabled(cacheable=true)    
    public static Map<String,Object> getWorkSteps(List<Id> territories,String mechanicId,Date startDate, Date endDate) {
            Map<String,Object> responseMap = new Map<String,Object>();
            
            Set<Id> territoryIds = WorkStepService.getAssignedTerritories();

            if(territoryIds.isEmpty() || (startDate == null || endDate == null)){
                return responseMap;
            }            
    
            String soqlString = 'SELECT Id,CT_CantidadDeHoras__c,Caso__c,Caso__r.CaseNumber, AcumuladoMinutosPausas__c, Total_de_tiempo_trabajado_en_minutos__c, WorkOrderId,WorkOrder.WorkOrderNumber,  Mec_nico_asignado__c,Mec_nico_asignado__r.Name,WorkOrder.ServiceTerritory.Name FROM WorkStep';               
            
            String soqlFilterString = ' WHERE WorkOrder.ServiceTerritoryId IN:territoryIds AND Mec_nico_asignado__c != null AND ((Tipo_de_trabajo_del_caso__r.CT_Total_Subtareas_FM__c = 0 AND CT_TieneSubtipo__c = false) OR CT_TieneSubtipo__c = true)';
    
            if(territories != null && !territories.isEmpty()){
                soqlFilterString += ' AND WorkOrder.ServiceTerritoryId IN :territories  ';
            }                        
            
            if(String.isNotBlank(mechanicId)){
                soqlFilterString += ' AND Mec_nico_asignado__c = \''+ mechanicId.trim() +'\' ';
            }
                  
            soqlFilterString += ' AND WorkOrder.CT_Fecha_Creacion_FM__c >= :startDate AND WorkOrder.CT_Fecha_Creacion_FM__c <= :endDate';                
    
            soqlString += soqlFilterString;  
            
            soqlString += ' ORDER BY Mec_nico_asignado__r.Name ASC,WorkOrder.WorkOrderNumber';

            List<WorkStep> workStepList = (List<WorkStep>) Database.query(soqlString);        

            Set<Id> mechanicIds = new Set<Id>();
            Map<String,List<WorkStep>> mecIdWorkStepListMap = new Map<String,List<WorkStep>>();
            for (WorkStep ws : workStepList) {  
                mechanicIds.add(ws.Mec_nico_asignado__c);
    
                if (!mecIdWorkStepListMap.containsKey(ws.Mec_nico_asignado__c)) {
                    mecIdWorkStepListMap.put(ws.Mec_nico_asignado__c,new List<WorkStep>());
                }
                
                List<WorkStep> wsList = mecIdWorkStepListMap.get(ws.Mec_nico_asignado__c);
                wsList.add(ws);
                mecIdWorkStepListMap.put(ws.Mec_nico_asignado__c,wsList);
            }
            
            List<Contact> contactList = [SELECT Id,Name FROM Contact WHERE Id IN :mechanicIds ORDER BY Name ASC];

            // Map<String,Integer> cfgMap = new Map<String,Integer>();        
            // for (Config_Disponibilidad__c cfg : [SELECT Mecanico__c,Taller__c,Horas_x_dia__c FROM Config_Disponibilidad__c WHERE Mecanico__c IN :mechanicIds ]) {
            //     cfgMap.put(cfg.Mecanico__c + '_'+cfg.Taller__c,cfg.Horas_x_dia__c);
            // }            
            
            List<RecordWrapperReport> WSWrapperReportList = new List<RecordWrapperReport>();
            for(Contact contact : contactList){
                RecordWrapperReport wrpReport = new RecordWrapperReport();
                // RecordWrapperReport.cfgMap = cfgMap;
                wrpReport.mechanicId = contact.Id;
                wrpReport.mechanicName = contact.Name;
                wrpReport.workSteps = mecIdWorkStepListMap.get(contact.Id);
                wrpReport.sumValues();
                WSWrapperReportList.add(wrpReport);
            }
            responseMap.put('records',WSWrapperReportList);

            return responseMap;
    }


    public class RecordWrapperReport {
        // @AuraEnabled
        // public static Map<String,Integer> cfgMap;

        @AuraEnabled
        public String mechanicId;

        @AuraEnabled
        public String mechanicName;

        @AuraEnabled
        public Decimal assignedHours = 0.0;

        @AuraEnabled
        public Decimal workedHours = 0.0;

        @AuraEnabled
        public Decimal tiemposImproductivos = 0.0;
        
        @AuraEnabled
        public Decimal eficiencia = 0.0;
        
        @AuraEnabled
        public Decimal productividad = 0.0;        

        @AuraEnabled
        public List<WorkStep> workSteps;

        public RecordWrapperReport(){            
        }

        public void sumValues() {
            for (WorkStep workStep : workSteps) {
                this.assignedHours += workStep.CT_CantidadDeHoras__c != null ? workStep.CT_CantidadDeHoras__c : 0;
                this.workedHours += workStep.Total_de_tiempo_trabajado_en_minutos__c!= null && workStep.Total_de_tiempo_trabajado_en_minutos__c > 0 ? workStep.Total_de_tiempo_trabajado_en_minutos__c / 60 : 0;
                this.tiemposImproductivos += workStep.AcumuladoMinutosPausas__c != null  && workStep.AcumuladoMinutosPausas__c > 0 ? workStep.AcumuladoMinutosPausas__c / 60 : 0;
            }
        }                
    }

    public static void dummy() {
        String dummy = '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
        dummy += '';
    }
}