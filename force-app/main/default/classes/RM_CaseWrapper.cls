public with sharing class RM_CaseWrapper {
    @AuraEnabled public String id {get; set;}
    @AuraEnabled public String caseId {get; set;}
    @AuraEnabled public String caseNumber {get; set;}
    @AuraEnabled public String territoryId {get; set;}
    @AuraEnabled public String territoryName {get; set;}
    @AuraEnabled public String status {get; set;}
    @AuraEnabled public Decimal totalHorasEstimadas {get; set;}//estimadas
    @AuraEnabled public Decimal totalMinutosReales {get; set;}//trabajadas
    @AuraEnabled public List<RM_WorkOrderWrapper> workOrders {get; set;}
        
    public RM_CaseWrapper(Case caseObj) {
        this.id = caseObj.Id;
        this.caseId = caseObj.Id;
        this.caseNumber = caseObj.CaseNumber;
        this.territoryId = caseObj.Service_Territory1__c;
        this.territoryName = caseObj.Service_Territory1__r?.Name;
        this.status = caseObj.Status;
        this.workOrders = new List<RM_WorkOrderWrapper>();
    }

    public void addWorkOrder(RM_WorkOrderWrapper workOrder) {
        this.workOrders.add(workOrder);
    }

    public void addWorkOrders(List<RM_WorkOrderWrapper> workOrders) {
        this.workOrders.addAll(workOrders);
    }
}