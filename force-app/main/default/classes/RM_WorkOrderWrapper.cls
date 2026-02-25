public with sharing class RM_WorkOrderWrapper {
    @AuraEnabled public String id { get; set; }
    @AuraEnabled public String workOrderId { get; set; }
    @AuraEnabled public String status { get; set; }
    @AuraEnabled public String workOrderNumber { get; set; }
    @AuraEnabled public List<RM_WorkStepWrapper> trabajos {get; set;}
    @AuraEnabled public Decimal totalHorasEstimadas {get; set;}//estimadas
    @AuraEnabled public Decimal totalHorasReales {get; set;}//trabajadas
    @AuraEnabled public Decimal totalMinutosReales {get; set;}//trabajadas

    public RM_WorkOrderWrapper(WorkOrder wo) {
        this.id = wo.Id;
        this.workOrderId = wo.Id;
        this.status = wo.Status;
        this.workOrderNumber = wo.WorkOrderNumber;
        this.trabajos = new List<RM_WorkStepWrapper>();
        this.totalHorasEstimadas = 0;
        this.totalHorasReales = 0;
        this.totalMinutosReales = 0;
    }

    public void addWorkStep(RM_WorkStepWrapper ws) {
        this.totalHorasEstimadas += ws.totalHorasEstimadas != null ? ws.totalHorasEstimadas : 0;
        this.totalMinutosReales += ws.totalMinutosReales != null ? ws.totalMinutosReales : 0;
        // this.totalHorasReales = (this.totalMinutosReales == null) ? 0 : (this.totalMinutosReales / 60).setScale(2, System.RoundingMode.HALF_UP);
        this.trabajos.add(ws);
    }

    // public void addWorkSteps(List<RM_WorkStepWrapper> ws) {
    //     this.trabajos.addAll(ws);
    // }

    //summarize totalHorasEstimadas
    // public void calcularTotales() {
        // for (RM_WorkStepWrapper ws : this.trabajos) {
        //     this.totalHorasEstimadas += ws.totalHorasEstimadas != null ? ws.totalHorasEstimadas : 0;
        //     this.totalMinutosReales += ws.totalMinutosReales != null ? ws.totalMinutosReales : 0;
        // }
    // }
}