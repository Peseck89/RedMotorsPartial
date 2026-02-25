public with sharing class CaseWorkTypeController {

    @AuraEnabled
    public static WorkOrder existWorkOrder(String caseId){
        List<WorkOrder> workOrderList;
        try {
            workOrderList = [SELECT Id, Desea_financiamiento__c, Account.Monto_a_financiar_Altica__c, Account.Moneda_financiamiento_Altica__c, Account.ClienteAltica__c  
                             FROM WorkOrder WHERE CaseId=:caseId LIMIT 1];
            if (workOrderList.size() == 0) {
                return null;
            } else {
                return workOrderList[0];
            }
        } catch (DmlException e) {
            return null;
        }
    }  
}