public class RM_WorkStepWrapper {
    @AuraEnabled public String id {get; set;}
    @AuraEnabled public String name {get; set;}
    @AuraEnabled public String workStepId {get; set;}
    @AuraEnabled public String workStepName {get; set;}
    @AuraEnabled public String ttcId {get; set;}
    @AuraEnabled public String caseId {get; set;}
    @AuraEnabled public String caseNumber {get; set;}
    @AuraEnabled public String workOrderId {get; set;}
    @AuraEnabled public String workOrderNumber {get; set;}
    @AuraEnabled public String mechanicId {get; set;}
    @AuraEnabled public String mechanicName {get; set;}
    @AuraEnabled public DateTime startTime {get; set;}
    @AuraEnabled public DateTime endTime {get; set;}
    @AuraEnabled public String status {get; set;}
    @AuraEnabled public String tipoTabajoCasoId {get; set;}
    @AuraEnabled public String tipoTabajoCasoName {get; set;}
    @AuraEnabled public Decimal totalHorasEstimadas {get; set;}//estimadas
    @AuraEnabled public Decimal totalHorasReales {get; set;}//reales
    @AuraEnabled public Decimal totalMinutosReales {get; set;}//trabajadas
    @AuraEnabled public String modoTrabajo {get; set;}
    @AuraEnabled public List<RM_WorkStepWrapper> subtrabajos {get; set;}
    @AuraEnabled public String isReprocessing {get; set;}
    @AuraEnabled public String workType {get; set;}


    public RM_WorkStepWrapper(tiposDeTrabajoCaso__c ttc) {
        this.id = ttc?.Id;
        this.name = ttc?.Name;
        this.workOrderId = ttc?.Paso_de_trabajo__r?.WorkOrderId;
        this.workOrderNumber = ttc?.Paso_de_trabajo__r?.WorkOrder?.WorkOrderNumber;
        this.caseId = ttc?.Caso__c;
        this.caseNumber = ttc?.Caso__r?.CaseNumber;
        this.workStepId = ttc?.Paso_de_trabajo__c;
        this.workStepName = ttc?.Paso_de_trabajo__r?.Name;
        if (ttc.RM_TipoTrabajoCaso__c != null) {
            this.workStepName += ' (R)';
            this.isReprocessing = 'si';
        }else{
            this.isReprocessing = 'no';
        }
        this.status = ttc?.Paso_de_trabajo__r?.Status;
        this.startTime = ttc?.Paso_de_trabajo__r?.StartTime;
        this.endTime = ttc?.Paso_de_trabajo__r?.EndTime;
        this.mechanicId = ttc?.Paso_de_trabajo__r?.RM_Mecanico__c;
        this.mechanicName = ttc?.Paso_de_trabajo__r?.RM_Mecanico__r?.Name;
        this.totalHorasEstimadas = ttc.Paso_de_trabajo__r != null ? ttc.Paso_de_trabajo__r.RM_TotalHorasFX__c : 0;
        this.totalMinutosReales = ttc.Paso_de_trabajo__r != null && ttc.Paso_de_trabajo__r.Total_de_tiempo_trabajado_en_minutos__c != null ? ttc.Paso_de_trabajo__r.Total_de_tiempo_trabajado_en_minutos__c : 0;
        this.modoTrabajo = ttc?.RM_ModoTrabajo__c;
        this.workType = 'trabajo';
        this.subtrabajos = new List<RM_WorkStepWrapper>();
    }

    public RM_WorkStepWrapper(Subtipo_de_trabajo_del_caso__c sttc) {
        this.id = sttc?.Id;
        this.name = sttc?.Name;
        this.workOrderId = sttc?.Paso_de_trabajo__r?.WorkOrderId;
        this.workOrderNumber = sttc?.Paso_de_trabajo__r?.WorkOrder?.WorkOrderNumber;
        this.caseId = sttc?.Caso__c;
        this.caseNumber = sttc?.Caso__r?.CaseNumber;
        this.workStepId = sttc?.Paso_de_trabajo__c;
        this.workStepName = sttc?.Paso_de_trabajo__r?.Name;
        this.ttcId = sttc?.Tipo_de_trabajo_del_caso__c;
        if (sttc.RM_SubtipoTrabajoCaso__c != null) {
            this.workStepName += ' (R)';
            this.isReprocessing = 'si';
        }else{
            this.isReprocessing = 'no';
        }
        this.status = sttc?.Paso_de_trabajo__r?.Status;
        this.mechanicId = sttc?.Paso_de_trabajo__r?.RM_Mecanico__c;
        this.mechanicName = sttc?.Paso_de_trabajo__r?.RM_Mecanico__r?.Name;
        this.startTime = sttc?.Paso_de_trabajo__r?.StartTime;
        this.endTime = sttc?.Paso_de_trabajo__r?.EndTime;
        this.totalHorasEstimadas = sttc.Paso_de_trabajo__r != null ? sttc.Paso_de_trabajo__r.RM_TotalHorasFX__c : 0;
        this.totalMinutosReales = sttc.Paso_de_trabajo__r != null && sttc.Paso_de_trabajo__r.Total_de_tiempo_trabajado_en_minutos__c != null ? sttc.Paso_de_trabajo__r.Total_de_tiempo_trabajado_en_minutos__c : 0;
        this.modoTrabajo = sttc?.Tipo_de_trabajo_del_caso__r?.RM_ModoTrabajo__c;
        this.workType = 'subtrabajo';
    }

    public void addSubWorkStep(RM_WorkStepWrapper ws) {
        this.subtrabajos.add(ws);
    }

    // public void addSubWorkSteps(List<RM_WorkStepWrapper> wss) {
    //     this.subtrabajos = wss;
    // }
}