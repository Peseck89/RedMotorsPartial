/**
 * @description       : 
 * @author            : Marco Hernandez
 * @group             : Redmotors
 * @last modified on  : 09-01-2022
 * @last modified by  : marcohernandezhp@gmail.com
**/
public with sharing class CT_AsignaMecanicoClass {
    
    @AuraEnabled( cacheable = true )
    public static List<WorkStep> fetchAccounts(String workOrderNumber,String caseNumber,String workType) {
        //Filtrar por territorio de acuerdo al usuario
        List<FSL__User_Territory__c> userTerritotyList = [SELECT FSL__ServiceTerritory__c FROM FSL__User_Territory__c WHERE FSL__User__c =: UserInfo.getUserId()];
        Set<Id> territoryIdSet = new Set<Id>();
        if (userTerritotyList.size() == 0) {
            return new List<WorkStep>();
        }

        for (FSL__User_Territory__c userTerritory : userTerritotyList) {
            territoryIdSet.add(userTerritory.FSL__ServiceTerritory__c);
        }

        String query = 'SELECT CT_NombreOrdenDeTrabajo__c, CT_TipoDeTrabajoDelCaso__c,Numero_Caso__c, '+
                        'CT_AsignadoA__c,Caso__c,'+
                        'WorkOrder.WorkOrderNumber, Id, WorkOrderId,'+
                        'Name,StartTime,format(StartTime)cStartTime,'+
                        'WorkOrder.AssetId,WorkOrder.Asset.Name, '+
                        'Status, Mec_nico_asignado__c,Mec_nico_asignado__r.Name,'+
                        'CT_Placa__c,'+
                        'Tipo_de_trabajo_del_caso__c, Tipo_de_trabajo_del_caso__R.Name,Orden_URL_F__c'+            
                        ' FROM WorkStep WHERE WorkOrder.ServiceTerritoryId IN:territoryIdSet AND Status !=\'Completada\' AND WorkOrder.Etapa_de_flujo_de_trabajo__c != \'Orden Facturada\'  AND WorkOrder.Etapa_de_flujo_de_trabajo__c != \'Orden Rechazada\'';

        String stringConditions = '';
        if(String.isNotBlank(workOrderNumber)){
            stringConditions += ' AND WorkOrder.WorkOrderNumber = \''+workOrderNumber+'\'';
        }

        if(String.isNotBlank(caseNumber)){
            stringConditions += ' AND Caso__r.CaseNumber = \''+caseNumber.trim()+'\'';
        }

        if(String.isNotBlank(workType)){
            stringConditions += ' AND CT_TipoDeTrabajoDelCaso__c LIKE \'%'+workType+'%\'';
        }
      
        query += stringConditions+' LIMIT 15';

        System.debug('@@@soql@@@'+query);

        List<WorkStep> workStepList = (List<WorkStep>) Database.query(query);
        return workStepList;
    }

    @AuraEnabled
    public static List<WorkStep> asignarWorkSteps(List<Id> wsIds, Id contactId) {
        if (wsIds == null || wsIds.isEmpty()) {
            throw new AuraHandledException('Se requiere por lo menos seleccionar una tarea!');
        }
        if (String.isEmpty(contactId)) {
            throw new AuraHandledException('El mecanico es requerido!');
        }

        List<WorkStep> wsList = [SELECT Id, Mec_nico_asignado__c FROM WorkStep WHERE Id IN:wsIds];
        if (wsList.size() == 0) {
            throw new AuraHandledException('No se encontraron los registros a actualizar!');
        }

        for(WorkStep ws : wsList){
            ws.Mec_nico_asignado__c = contactId;
        }
        System.System.debug('wslist '+wsList);
        
        try {            
            update wsList;
        } catch (DmlException e) {
            throw new AuraHandledException(getErrorMessage(e.getMessage()));
        }
        // Database.SaveResult[] srList = Database.update(wsList, false);
        //update wsList;
        // System.System.debug('wslist '+wsList);
        return wsList;
    }

    public static String getErrorMessage(String message){
        if (message.contains('FIELD_FILTER_VALIDATION_EXCEPTION')) {
            message = message.substringAfter('FIELD_FILTER_VALIDATION_EXCEPTION');
            message = message.substringAfter(', ');
        }
        if (message.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
            message = message.substringAfter('FIELD_CUSTOM_VALIDATION_EXCEPTION');
            message = message.substringAfter(', ');
        }            
        if (message.contains('INVALID_FIELD')) {
            message = message.substringAfter('INVALID_FIELD');
            message = message.substringAfter(', ');
        }         
        return message;
    }    

    @AuraEnabled
    public static List<WorkStep> IniciaYAsignaWorkSteps(List<Id> wsIds, Id contactId) {
        if (wsIds == null || wsIds.isEmpty()) {
            throw new AuraHandledException('Se requiere por lo menos seleccionar una tarea!');
        }
        if (String.isEmpty(contactId)) {
            throw new AuraHandledException('El mecanico es requerido!');
        }

        List<WorkStep> wsList = [Select Id, Mec_nico_asignado__c,Status From WorkStep Where Id IN:wsIds];
        if (wsList.size() == 0) {
            throw new AuraHandledException('No se encontraron los registros a actualizar!');
        }

        for(WorkStep ws : wsList){
            ws.Mec_nico_asignado__c = contactId;
            ws.Status = 'En curso';
        }
        try{            
            update wsList;
        } catch (DmlException e) {
            throw new AuraHandledException(getErrorMessage(e.getMessage()));
        }

        return wsList;
    }
}