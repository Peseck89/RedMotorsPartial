public with sharing class RM_CT_VistaKanbanVehiculo_Ctrl {

    //inicializar en 01/05/2024
    public static final Date START_DATE = RM_CT_Service.getStartDateFilter();

    public static final Integer PAGE_SIZE = 15;

    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getData(String territoryId,String etapa,String workOrderNumber,String caseNumber,String placa,String vin,Date startDate,Date endDate,Integer pageNumber) {        
        Map<String,Object> responseMap = new Map<String,Object>();
        
        pageNumber = pageNumber != null ? pageNumber : 1;
        
        if(String.isBlank(etapa)){
            return responseMap;
        }
        
        Set<Id> tallerIds = RM_CT_Service.getAssignedTerritoryIds();

        // if (tallerIds.isEmpty()) {
        //     return responseMap;
        // }

        // String workOrderSoqlString = 'SELECT CaseId FROM WorkOrder WHERE ServiceTerritoryId IN :tallerIds AND Etapa_de_flujo_de_trabajo__c != \'Orden Facturada\' AND Etapa_de_flujo_de_trabajo__c != \'Orden Rechazada\' AND CaseId != NULL AND Case.Status != NULL AND Case.Status != \'Cerrado\' ';

        // workOrderSoqlString += ' WITH SECURITY_ENFORCED';

        // List<WorkOrder> workOrderList = (List<WorkOrder>) Database.query(workOrderSoqlString);
        // Set<Id> workOrderIds = new Set<Id>();
        // if (workOrderList.isEmpty()) {
        //     return responseMap;
        // }

        // for (WorkOrder workOrder : workOrderList) {
        //     workOrderIds.add(workOrder.CaseId);
        // }

        // Set<String> workOrderStatus = new Set<String>{'Orden Facturada','Orden Rechazada'};
        Set<String> caseStatus = new Set<String>{'Cerrado'};

        String soqlString = 'SELECT Id,StatusDetail__c,CaseNumber,Asset.Name,Account.Name,Fecha_Creacion_FM__c,Mecanico_Asignado__c,Mecanico_Asignado__r.Name FROM Case ';

        String soqlFilterString = ' WHERE Service_Territory1__c IN :tallerIds AND Status NOT IN :caseStatus AND Fecha_Creacion_FM__c >= : START_DATE AND StatusDetail__c = :etapa';                     
        
        // if(String.isNotBlank(etapa)){
        //     soqlFilterString += ' AND Case.Status = :etapa ';
        // }

        // if(String.isNotBlank(workOrderNumber)){
        //     soqlFilterString += ' AND WorkOrderNumber = :workOrderNumber ';
        // }

        if(String.isNotBlank(territoryId)){
            soqlFilterString += ' AND Service_Territory1__c = :territoryId ';
        }

        if(String.isNotBlank(placa)){
            placa = '%'+placa+'%';
            soqlFilterString += ' AND N_de_placa__c LIKE :placa ';
        }
        
        if(String.isNotBlank(caseNumber)){
            soqlFilterString += ' AND CaseNumber = :caseNumber ';
        }   

        if(startDate != null){           
            soqlFilterString += ' AND Fecha_Creacion_FM__c >= :startDate ';
        }

        if(endDate != null){       
            soqlFilterString += ' AND Fecha_Creacion_FM__c <= :endDate';            
        }

        try {    

            Integer offset = (pageNumber - 1) * PAGE_SIZE;
            Integer totalRecords = Database.countQuery('SELECT count() FROM Case '+ soqlFilterString);
            Integer recordEnd = PAGE_SIZE * pageNumber;
                        
            responseMap.put('pageSize',PAGE_SIZE);
            responseMap.put('pageNumber',pageNumber);
            responseMap.put('totalRecords',totalRecords);
            responseMap.put('recordStart',offset + 1);
            responseMap.put('recordEnd',totalRecords >= recordEnd ? recordEnd : totalRecords);

            soqlString += soqlFilterString +' ORDER BY LastModifiedDate DESC LIMIT :PAGE_SIZE OFFSET :offset ';

            System.debug('soqlString: '+soqlString);

            responseMap.put('records',(List<Case>) Database.query(soqlString));

        } catch (Exception e) {
            System.debug('Error: '+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }

        return responseMap;
    }
}