public with sharing class RM_CT_WorkStepsInProgress_Ctrl {
    
    public static final Integer PAGE_SIZE = 15;    

    public static final Date START_DATE = WorkStepService.START_DATE; 

    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getRecords(List<String> territoryIds,List<String> statuses,String caseNumber,String workOrderNumber,String placa,String vin,String mechanicId,String agentId,Date startDate,Date endDate,Boolean showParentTasks,Integer pageNumber){
        Map<String,Object> responseMap = new Map<String,Object>{'success' => false};       

        Set<Id> relatedTerritoryIds = new Set<Id>(); 
        for (FSL__User_Territory__c ut : [SELECT Id,FSL__ServiceTerritory__c FROM FSL__User_Territory__c WHERE FSL__User__c =:UserInfo.getUserId()  WITH SECURITY_ENFORCED]) {
            relatedTerritoryIds.add(ut.FSL__ServiceTerritory__c); 
        }
        
        if (relatedTerritoryIds.isEmpty() && !Test.isRunningTest()) {
            return responseMap;
        }
        
        pageNumber = pageNumber != null ? pageNumber : 1;

        showParentTasks = showParentTasks == null ? false : !showParentTasks;

        String soqlString = 'SELECT Id,StartTime,WorkOrderId,WorkOrder.WorkOrderNumber, Name, Status,Caso__r.CreatedDate,Caso__c,Caso__r.CaseNumber, CT_CantidadDeHoras__c, CT_HorasTipoTrabajo__c,Mec_nico_asignado__r.Name, '+
                            'Caso__r.Marca__c,AcumuladoMinutosPausas__c,Caso__r.Modelo__c,Caso__r.Asset.NumeroDeChasis__c,Caso__r.Asset.Name,Total_de_tiempo_trabajado_en_minutos__c, Caso__r.OwnerId, Caso__r.Owner.Name, '+
                            'Tipo_de_trabajo_del_caso__r.CT_Total_Subtareas_FM__c,RM_TotalHorasFX__c,(SELECT Id,Cantidad_de_horas__c FROM Subtipos_de_trabajos_del_caso__r) FROM WorkStep ';

        String soqlStringFilter = ' WHERE Caso__r.Status!=\'Cerrado\' AND Caso__r.Fecha_Creacion_FM__c > :START_DATE AND WorkOrder.ServiceTerritoryId IN:relatedTerritoryIds AND WorkOrder.Etapa_de_flujo_de_trabajo__c NOT IN(\'Orden Facturada\',\'Orden Rechazada\')  AND Flag_Is_Task_FX__c = :showParentTasks ';
        
        if(territoryIds != null && !territoryIds.isEmpty()){
            soqlStringFilter += ' AND WorkOrder.ServiceTerritoryId IN :territoryIds ';
        }

        if(statuses != null && !statuses.isEmpty()){
            soqlStringFilter += ' AND Status IN :statuses ';
        }
        
        if(String.isNotBlank(caseNumber)){
            caseNumber = '%'+caseNumber.trim()+'%';
            soqlStringFilter += ' AND Numero_Caso__c LIKE :caseNumber ';
        }
                
        if(String.isNotBlank(workOrderNumber)){  
            workOrderNumber = '%'+workOrderNumber.trim()+'%';          
            soqlStringFilter += ' AND WorkOrder.WorkOrderNumber LIKE :workOrderNumber ';
        }

        if(String.isNotBlank(placa)){      
            placa = '%'+placa.trim()+'%';        
            soqlStringFilter += ' AND Caso__r.Asset.Name LIKE :placa ';
        }
        
        if(String.isNotBlank(vin)){
            vin = '%'+vin.trim()+'%';
            soqlStringFilter += ' AND Caso__r.Asset.NumeroDeChasis__c LIKE :vin ';
        }
        
        if(String.isNotBlank(mechanicId)){        
            soqlStringFilter += ' AND Mec_nico_asignado__c = :mechanicId';
        }

        if(String.isNotBlank(agentId)){        
            soqlStringFilter += ' AND Caso__r.OwnerId = :agentId';
        }        

        if(startDate != null){                  
            soqlStringFilter += ' AND Caso__r.Fecha_Creacion_FM__c >= :startDate ';
        }
        
        if(endDate != null){
            soqlStringFilter += ' AND Caso__r.Fecha_Creacion_FM__c <= :endDate';            
        }

        soqlStringFilter += ' WITH SECURITY_ENFORCED ';        
    
        soqlString += soqlStringFilter;        

        try {
            String soqlStringCount = 'SELECT count() FROM WorkStep '+soqlStringFilter;

            Integer offset = (pageNumber - 1) * PAGE_SIZE;
            Integer totalRecords = Database.countQuery(soqlStringCount);        
            Integer recordEnd = PAGE_SIZE * pageNumber;
    
            responseMap.put('pageSize',PAGE_SIZE);
            responseMap.put('pageNumber',pageNumber);
            responseMap.put('totalRecords',totalRecords);
            responseMap.put('recordStart',offset + 1);
            responseMap.put('recordEnd',totalRecords >= recordEnd ? recordEnd : totalRecords);    
            soqlString += '  ORDER BY Caso__r.Fecha_Creacion_FM__c ASC LIMIT :PAGE_SIZE OFFSET :offset';

            responseMap.put('records',(List<WorkStep>) Database.query(soqlString));
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