public with sharing class RM_CT_ReporteDetalleTareas_Ctrl {

    @AuraEnabled(cacheable=true)
    public static List<WorkStep> getWorkSteps(String mechanicId, String territoryId, String caseId, Integer offset, Integer pageSize) {
        return [SELECT Id, Name,WorkOrderId,WorkOrder.WorkOrderNumber,Caso__r.Service_Territory1__c,Caso__r.Service_Territory1__r.Name,Caso__r.CaseNumber,Mec_nico_asignado__c,Mec_nico_asignado__r.Name,RM_TotalHorasFX__c,Total_de_tiempo_trabajado_en_minutos__c,Flag_Is_Task_FX__c,Status,Tipo_de_trabajo_del_caso__c,Tipo_de_trabajo_del_caso__r.Name,Tipo_de_trabajo_del_caso__r.RM_ModoTrabajo__c,Tipo_de_trabajo_del_caso__r.Tipotrabajo__r.Name FROM WorkStep WHERE Caso__c != NULL AND Caso__r.Service_Territory1__c != NULL AND Mec_nico_asignado__c = :mechanicId AND Caso__r.Service_Territory1__c = :territoryId AND Caso__c = :caseId ORDER BY Tipo_de_trabajo_del_caso__r.Name ASC];
    }

}