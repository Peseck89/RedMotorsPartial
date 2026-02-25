public with sharing class RM_CT_VistaKanbanWorkOrder_Ctrl {

    public static final Date START_DATE = RM_CT_Service.START_DATE;

    public static final Integer PAGE_SIZE = 100;

    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getRecords(String territoryId,String stage,String workOrderNumber,String caseNumber,String placa,String vin,Date startDate,Date endDate,Integer pageNumber) {        
        Map<String,Object> responseMap = new Map<String,Object>();
        
        Date defaultStartDate = RM_CT_Service.START_DATE;

        Integer defaultPageSize = PAGE_SIZE;

        pageNumber = pageNumber != null ? pageNumber : 1;
        
        if(String.isBlank(stage)){
            return responseMap;
        }

        // if(String.isBlank(territoryId)){
        //     return responseMap;
        // }
        
        Set<Id> assignedTerritoryIds = RM_CT_Service.getAssignedTerritoryIds();

        if (assignedTerritoryIds.isEmpty()) {
            return responseMap;
        }

        String workOrderSoqlString = 'SELECT CaseId FROM WorkOrder WHERE ServiceTerritoryId IN :assignedTerritoryIds AND Etapa_de_flujo_de_trabajo__c != \'Orden Facturada\' AND Etapa_de_flujo_de_trabajo__c != \'Orden Rechazada\' AND CaseId != NULL AND Case.Status != NULL AND Case.Status != \'Cerrado\' ';
        
        if(String.isNotBlank(workOrderNumber)){
            workOrderSoqlString += ' AND WorkOrderNumber = :workOrderNumber ';
        }

        workOrderSoqlString += ' WITH SECURITY_ENFORCED';

        List<WorkOrder> workOrderList = (List<WorkOrder>) Database.query(workOrderSoqlString);
        Set<Id> workOrderIds = new Set<Id>();
        if (workOrderList.isEmpty()) {
            return responseMap;
        }

        for (WorkOrder workOrder : workOrderList) {
            workOrderIds.add(workOrder.CaseId);
        }

        String soqlString = 'SELECT Id, CaseNumber, Mecanico_Asignado__c, StatusDetail__c,Service_Territory1__c, Service_Territory1__r.Name, AssetId,AccountId,Asset.Id,Asset.Name, Account.Id,Account.Name, Mecanico_Asignado__r.Name, Fecha_Creacion_FM__c, Status FROM Case ';

        String soqlFilterString = ' WHERE Id IN :workOrderIds AND Fecha_Creacion_FM__c >= :defaultStartDate AND Service_Territory1__c IN:assignedTerritoryIds AND StatusDetail__c != null AND Status != \'Cerrado\' ';                     
        
        if(String.isNotBlank(territoryId) && territoryId != 'all'){
            soqlFilterString += ' AND Service_Territory1__c = :territoryId ';
        }

        soqlFilterString += ' AND StatusDetail__c = :stage '; 

        if(String.isNotBlank(placa)){
            placa = '%'+placa+'%';
            soqlFilterString += ' AND Asset.Name LIKE :placa ';
        }

        if(String.isNotBlank(vin)){
            vin = '%'+vin+'%';           
            soqlFilterString += ' AND VIN__c  LIKE :vin ';
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

        soqlFilterString += ' WITH SECURITY_ENFORCED ';

        System.debug('@soqlFilterString@');
        System.debug(soqlFilterString);

        try {    

            Integer offset = (pageNumber - 1) * defaultPageSize;
            Integer totalRecords = Database.countQuery('SELECT count() FROM Case '+ soqlFilterString);
            Integer recordEnd = defaultPageSize * pageNumber;
                        
            responseMap.put('pageSize',defaultPageSize);
            responseMap.put('pageNumber',pageNumber);
            responseMap.put('totalRecords',totalRecords);
            responseMap.put('recordStart',offset + 1);
            responseMap.put('recordEnd',totalRecords >= recordEnd ? recordEnd : totalRecords);
            
            System.debug('@totalRecords@');
            System.debug(totalRecords);

            soqlString += soqlFilterString +' LIMIT :defaultPageSize OFFSET :offset';

            responseMap.put('records',(List<Case>) Database.query(soqlString));

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return responseMap;
    }

}