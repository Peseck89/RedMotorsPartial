public class WorkOrderListController {
    
    @AuraEnabled(cacheable=true)
    public static List<WorkOrder> getWorkOrderList(String caseId){
        return [SELECT Id, WorkOrderNumber, CaseId, CT_AccountName__c FROM WorkOrder WHERE CaseId =: caseId];
    }
}