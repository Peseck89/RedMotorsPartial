public without sharing class CT_AsignaMecanico {

    public static final Integer PAGE_SIZE = 50;

    public static final Date START_DATE = WorkStepService.START_DATE; 

    @AuraEnabled(cacheable=true)
    public static WorkStepResponseWrapper getWorkSteps(String caseId,String mechanicId,String tallerId,String status,String action,Boolean showParentTasks,String tipoCargo,Integer pageNumber) {
        WorkStepResponseWrapper workStepReponseWrapper =  new WorkStepResponseWrapper();

        List<FSL__User_Territory__c> userTerritotyList = [SELECT FSL__ServiceTerritory__c FROM FSL__User_Territory__c WHERE FSL__User__c =: UserInfo.getUserId()];
        if (userTerritotyList.isEmpty()) {
            return workStepReponseWrapper;
        }

        Set<Id> territorySet = new Set<Id>();
        
        for (FSL__User_Territory__c userTerritory : userTerritotyList) {
            territorySet.add(userTerritory.FSL__ServiceTerritory__c);
        }

        showParentTasks = showParentTasks == null ? false : !showParentTasks;

        String  soqlString = 'SELECT Id,Tipo_de_trabajo_del_caso__r.Tipo_de_cargo__c,Status,WorkOrder.CT_Fecha_Creacion_FM__c,Hora_de_inicio_de_pausa__c,RM_TotalHorasFX__c,Total_de_tiempo_trabajado_en_minutos__c,AcumuladoMinutosPausas__c, Caso__c, WorkOrderId, Caso__r.CaseNumber, WorkOrder.WorkOrderNumber, WorkOrder.Asset.Name, WorkOrder.Asset.numeroDePlaca__c, WorkOrder.Asset.NumeroDeChasis__c, Tipo_de_trabajo_del_caso__r.Id, Tipo_de_trabajo_del_caso__r.Horaa__c, ( SELECT Id, Cantidad_de_horas__c FROM Subtipos_de_trabajos_del_caso__r ), CT_TipoDeTrabajoDelCaso__c, CT_AsignadoA__c, CT_Placa__c, StartTime, Name, WorkOrder.createdDate FROM WorkStep';
                
        String  soqlFilterString = ' WHERE Caso__r.Fecha_Creacion_FM__c > :START_DATE AND Caso__r.Status != \'Cerrado\' AND  WorkOrder.ServiceTerritoryId IN:territorySet AND WorkOrder.Etapa_de_flujo_de_trabajo__c != \'Orden Facturada\'  AND WorkOrder.Etapa_de_flujo_de_trabajo__c != \'Orden Rechazada\' AND Flag_Is_Task_FX__c = :showParentTasks';
        
        if (!showParentTasks) {
            soqlFilterString += ' AND CT_Seguimiento_Nivel_Padre__c = false ';
        }

        if(String.isNotBlank(status) && status != 'all'){
            soqlFilterString += ' AND Status = \''+ status.trim() +'\'';
        }

        if(String.isNotBlank(caseId)){
            soqlFilterString += ' AND Caso__c = \''+ caseId.trim() +'\'';
        }        

        if(String.isNotBlank(mechanicId) && action.equals('consultar-tareas')){
            soqlFilterString += ' AND Mec_nico_asignado__c = \''+ mechanicId.trim() +'\'';
        }

        if(String.isNotBlank(tallerId) && action.equals('cierre-taller')){
            soqlFilterString += ' AND WorkOrder.ServiceTerritoryId = \''+ tallerId.trim() +'\'';
        }     
        
        if(String.isNotBlank(tipoCargo) && tipoCargo != 'all'){
            soqlFilterString += ' AND Tipo_de_trabajo_del_caso__r.Tipo_de_cargo__c = \''+ tipoCargo.trim() +'\'';
        }

        if(String.isNotBlank(action)){
            if (action.equals('asignar')){                        
                soqlFilterString += ' AND ( Status = \'Nueva\' AND Mec_nico_asignado__c = \'\' ) ';
            }else if(action.equals('reasignar')){                        
                soqlFilterString += ' AND ( Status != \'Completada\' AND Mec_nico_asignado__c != \'\' ) ';
            }else if(action.equals('iniciar')){                        
                soqlFilterString += ' AND ( Status = \'Nueva\' AND Mec_nico_asignado__c != \'\' ) ';
            }else if((action.equals('pausar') || action.equals('cierre-taller'))){                        
                soqlFilterString += ' AND ( Status = \'En curso\' ) ';
            }else if(action.equals('completar')){                        
                soqlFilterString += ' AND ( Status = \'En curso\' OR Status = \'En pausa\' ) ';
            }else if(action.equals('reanudar')){                        
                soqlFilterString += ' AND ( Status = \'En pausa\' ) ';
            }            
        }          
        
        try {  
            Integer offset = (pageNumber - 1) * PAGE_SIZE;
            Integer totalRecords = Database.countQuery('SELECT count() FROM WorkStep '+ soqlFilterString);
            Integer recordEnd = PAGE_SIZE * pageNumber;
            
            soqlString += soqlFilterString +' ORDER BY Mec_nico_asignado__c DESC LIMIT :PAGE_SIZE OFFSET :offset';

            System.debug(soqlString);

            workStepReponseWrapper.pageSize = PAGE_SIZE;
            workStepReponseWrapper.pageNumber = pageNumber;
            workStepReponseWrapper.totalRecords = totalRecords;            
            workStepReponseWrapper.recordStart = offset + 1;
            workStepReponseWrapper.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
            workStepReponseWrapper.workSteps = (List<WorkStep>) Database.query(soqlString);
        } catch (DmlException e) {
            if (!Test.isRunningTest()) {                
                throw new AuraHandledException(e.getMessage());
            }
        }
        return workStepReponseWrapper;  
    }



    public class WorkStepResponseWrapper {
        @AuraEnabled
        public Integer pageSize {get;set;}
        @AuraEnabled
        public Integer pageNumber {get;set;}
        @AuraEnabled
        public Integer totalRecords {get;set;}
        @AuraEnabled
        public Integer totalPages {get;set;}
        @AuraEnabled
        public Integer recordStart {get;set;}
        @AuraEnabled
        public Integer recordEnd {get;set;}
        @AuraEnabled
        public List<WorkStep> workSteps {get;set;}
    } 

    @AuraEnabled
    public static void createTiempoImproductivo(List<Id> wsIds, String description) {
        if (wsIds == null || wsIds.isEmpty()) {
            throw new AuraHandledException('Favor de seleccionar al menos una tarea.');
        }         

        List<WorkStep> wsList = [SELECT Id, Status,Mec_nico_asignado__c,Tipo_de_trabajo_del_caso__c,WorkOrderId,Comentario_Pausa__c FROM WorkStep WHERE Id IN :wsIds];
        if (wsList.isEmpty()) {
            throw new AuraHandledException('No se encontraros las tareas seleccionadas.');
        }

        try {
            for (WorkStep ws : wsList) {
                ws.Status = 'En pausa';
                ws.Comentario_Pausa__c = description;
            }

            if (wsList.size() > 0) {
                update wsList;                
            }            
        } catch (DmlException e) {
            if (!Test.isRunningTest()) {
                throw new AuraHandledException(e.getMessage());                
            }
        }        
    }    

    @AuraEnabled
    public static Map<String,Object> checkTaskRunning(Id taskId){
        Map<String,Object> responseMap = new Map<String,Object>();
        try {          
            if(String.isBlank(taskId)){
                throw new AuraHandledException('El id de la tarea es requerido.');
            }

            List<WorkStep> wsList = [SELECT Mec_nico_asignado__c FROM WorkStep WHERE Id = :taskId LIMIT 1];
            if (wsList.isEmpty()) {
                throw new AuraHandledException('La tarea no fue encontrada.');
            }

            wsList = [SELECT Id, Name, Caso__r.CaseNumber,Tipo_de_trabajo_del_caso__r.Name, Tipo_de_trabajo_del_caso__r.Tipotrabajo__r.Name FROM WorkStep WHERE Mec_nico_asignado__c = :wsList[0].Mec_nico_asignado__c AND Status = 'En curso' LIMIT 1];
            responseMap.put('hasRunningTask', wsList.size() > 0);
            if (wsList.size() > 0) {                
                responseMap.put('task', wsList[0]);
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return responseMap;
    }

    @AuraEnabled
    public static Map<String,Object> updateWorkSteps(List<Id> wsIds,String action,String status, Id mechanicId) {
        Map<String,Object> responseMap = new Map<String,Object>();

        if (wsIds == null || wsIds.isEmpty()) {
            throw new AuraHandledException('Favor de seleccionar al menos una tarea.');
        }

        List<WorkStep> wsList = [SELECT Id, Status,Mec_nico_asignado__c FROM WorkStep WHERE Id IN:wsIds];
        if (wsList.isEmpty()) {
            throw new AuraHandledException('No se encontraros las tareas seleccionadas.');
        }

        //Pausar la tarea actual en curso
        if (action.equals('iniciar') || action.equals('cierre-taller')){
            List<WorkStep> workStepToPause = [SELECT Id,Status FROM WorkStep WHERE Mec_nico_asignado__c = :wsList[0].Mec_nico_asignado__c AND Status = 'En curso' LIMIT 1]; 
            for (WorkStep ws : workStepToPause) {
                ws.Status = 'En pausa';
            }                      
            update workStepToPause;
        }
                
        for(WorkStep ws : wsList){
            if (action.equalsIgnoreCase('iniciar') || action.equalsIgnoreCase('pausar') || action.equalsIgnoreCase('completar') || action.equalsIgnoreCase('reanudar')) {
                ws.Status = status;
            }else if(action.equalsIgnoreCase('asignar') || action.equalsIgnoreCase('reasignar')){
                ws.Mec_nico_asignado__c = mechanicId;
            }            
        }
        try {            
            update wsList;        

            if (action.equalsIgnoreCase('reanudar')) {
                List<Horas_improductivas_por_mec_nico__c> himList = [SELECT Id,Fin__c,Hora_fin__c FROM Horas_improductivas_por_mec_nico__c WHERE Work_Step__c IN :wsIds AND Fin__c = null AND Hora_fin__c = null];
                for (Horas_improductivas_por_mec_nico__c him : himList) {
                    him.Fin__c = System.today();
                    him.Hora_fin__c = System.now().time();
                }
                if (himList.size() > 0) {                    
                    update himList;
                }
            }
        } catch (DmlException e) {
            throw new AuraHandledException(getErrorMessage(e.getMessage()));
        }  
        return responseMap;      
    }

    @AuraEnabled
    public static List<WorkStep> assignWorkSteps(List<Id> wsIds, Id contactId) {
        if (wsIds == null || wsIds.isEmpty()) {
            throw new AuraHandledException('Favor de seleccionar al menos una tarea.');
        }

        if (String.isBlank(contactId)) {
            throw new AuraHandledException('Favor de seleccionar el mecánico.');
        }

        List<WorkStep> wsList = [SELECT Id, Mec_nico_asignado__c FROM WorkStep WHERE Id IN:wsIds];
        if (wsList.isEmpty()) {
            throw new AuraHandledException('No se encontraros las tareas seleccionadas.');
        }

        for(WorkStep ws : wsList){
            ws.Mec_nico_asignado__c = contactId;
        }

        try {            
            update wsList;
        } catch (DmlException e) {
            throw new AuraHandledException(getErrorMessage(e.getMessage()));
        }
        return wsList;
    }   

    @AuraEnabled
    public static List<WorkStep> assignAndStartWorkSteps(List<Id> wsIds, Id contactId) {
        if (wsIds == null || wsIds.isEmpty()) {
            throw new AuraHandledException('Favor de seleccionar al menos una tarea.');
        }    
        
        List<WorkStep> wsList = [SELECT Id,Mec_nico_asignado__c,Status FROM WorkStep WHERE Id IN:wsIds];
        if (wsList.isEmpty()) {
            throw new AuraHandledException('No se encontraros las tareas seleccionadas.');
        }
                
        for(WorkStep ws : wsList){
            ws.Status = 'En curso';
        }
        try {            
            update wsList;
        } catch (DmlException e) {
            if (!Test.isRunningTest()) {
                throw new AuraHandledException(getErrorMessage(e.getMessage()));                
            }
        }
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
    
    @AuraEnabled(cacheable=true)
    public static List<ServiceTerritory> getTerritories() {        
        List<Map<String,String>> territoryMapList = new List<Map<String,String>>();

        List<FSL__User_Territory__c> userTerritoryList = [SELECT FSL__ServiceTerritory__c FROM FSL__User_Territory__c WHERE FSL__User__c =: UserInfo.getUserId()];
        List<Id> territoryIds = new List<Id>();
        for(FSL__User_Territory__c userTerritory : userTerritoryList ){
            territoryIds.add(userTerritory.FSL__ServiceTerritory__c);
        }
        return [SELECT Id,Name FROM ServiceTerritory WHERE Id IN :territoryIds];
    }     

    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getTipoCargo() {
        List<Map<String, String>> picklistValues = new List<Map<String, String>>();
    
        Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get('tiposDeTrabajoCaso__c');
        if (sObjectType != null) {
            Schema.DescribeSObjectResult describeSObjectResult = sObjectType.getDescribe();
            Schema.SObjectField sObjectField = describeSObjectResult.fields.getMap().get('Tipo_de_cargo__c');
    
            if (sObjectField != null) {
                Schema.DescribeFieldResult describeFieldResult = sObjectField.getDescribe();
                for (Schema.PicklistEntry picklistEntry : describeFieldResult.getPicklistValues()) {
                    Map<String, String> picklistValue = new Map<String, String>();
                    picklistValue.put('name', picklistEntry.getValue());
                    picklistValue.put('label', picklistEntry.getLabel());
                    picklistValues.add(picklistValue);
                }
            }
        }
        return picklistValues;
    }


}