public with sharing class RM_WorkStep_Service {

    private List<WorkStep> newRecordList;
    private Map<Id, WorkStep> oldRecordMap;
    private Map<Id, WorkStep> newRecordMap;
    RM_WorkStep_Helper workStepHelper = new RM_WorkStep_Helper();

    public RM_WorkStep_Service(List<WorkStep> newRecordList, Map<Id, WorkStep> oldRecordMap, Map<Id, WorkStep> newRecordMap) {
        this.newRecordList = newRecordList;
        this.oldRecordMap = oldRecordMap;
        this.newRecordMap = newRecordMap;
    }

    public void registrarActividadMecanico() {
        Set<Id> workStepIds = workStepHelper.getWorkStepIds(newRecordList, oldRecordMap);
        if (workStepIds.isEmpty()) {
            return;
        }
        Map<Id, Case> cases = workStepHelper.getCases(workStepIds, newRecordMap);
        List<RM_ActividadMecanico__c> activitiesToRegister = workStepHelper.getActivitiesToRegister(workStepIds, cases, newRecordMap);
        if(activitiesToRegister.size() > 0){
            INSERT activitiesToRegister;

            workStepHelper.createAndPublishWorkStepEvents(activitiesToRegister);
        }
    }

    public void setearFechasInicioFin(){
        for (WorkStep newRecord : newRecordList) {
            newRecord = workStepHelper.validateStatusAndSetNewDates(newRecord,oldRecordMap.get(newRecord.Id));
        }
    }

    /**
     * This function updates the 'RM_ModoTrabajo__c' field of the 'tiposDeTrabajoCaso__c' records associated with the WorkStep records in 'newRecordList'.
     * The 'RM_ModoTrabajo__c' field is updated based on the 'RM_EsTrabajo__c' and 'Status' fields of the WorkStep record and whether it is the last task.
     */
    public void actualizarModoTrabajo() {
        Map<Id, tiposDeTrabajoCaso__c> existingTTCMap = workStepHelper.getTiposDeTrabajoCasoMap(newRecordList, oldRecordMap);

        Map<Id, tiposDeTrabajoCaso__c> ttcMapToUpdate = new Map<Id, tiposDeTrabajoCaso__c>();

        Map<Id, WorkStep> parentWorkStepsMap = getParentWorkStepsToUpdate(existingTTCMap);

        for (WorkStep newWS : newRecordList) {
            WorkStep oldWS = oldRecordMap.get(newWS.Id);
            // Check if the status or mechanic of the WorkStep record has changed.
            if (newWS.Status != oldWS.Status && newWS.Tipo_de_trabajo_del_caso__c != null ) {
                tiposDeTrabajoCaso__c ttc = workStepHelper.createTiposDeTrabajoCaso(newWS, existingTTCMap);
                ttcMapToUpdate.put(newWS.Tipo_de_trabajo_del_caso__c, ttc);
            }
        }

        if (!ttcMapToUpdate.isEmpty()) {
            UPDATE ttcMapToUpdate.values();
        }

        if (parentWorkStepsMap.values().size() > 0) {
            TriggerHandler.bypass('RM_WorkStep_Trg_Handler');
            UPDATE parentWorkStepsMap.values();
            TriggerHandler.clearBypass('RM_WorkStep_Trg_Handler');
        }
    }

    private Set<String> getSkipParentWorkSteps(){
        Set<String> skipParentWorkSteps = new Set<String>(); 
        for (WorkStep newWS : newRecordList) {
            WorkStep oldWS = oldRecordMap.get(newWS.Id);
            if (newWS.Status != oldWS.Status && newWS.RM_EsTrabajo__c != null && newWS.RM_EsTrabajo__c) {
                skipParentWorkSteps.add(newWS.Id);
            }
        }
        return skipParentWorkSteps;
    }

    private Map<Id, WorkStep> getParentWorkStepsToUpdate(Map<Id, tiposDeTrabajoCaso__c> existingTTCMap) {
        Set<Id> parentWorkStepIds = new Set<Id>();
        Map<Id, WorkStep> parentWorkStepsToUpdate = new Map<Id, WorkStep>();

        Set<String> skipParentWorkSteps = getSkipParentWorkSteps();
    
        // Iterar sobre el mapa de tiposDeTrabajoCaso
        for (tiposDeTrabajoCaso__c ttc : existingTTCMap.values()) {
            Boolean anyChildInProgress = false; // Variable para verificar si algún hijo está 'En curso'
            Boolean allChildrenCompleted = true; // Variable para verificar si todos los hijos están 'Completado'
    
            // Asegurarse de que la relación Pasos_de_trabajo__r no sea nula antes de iterar sobre ella
            if (ttc.Pasos_de_trabajo__r != null) {
                for (WorkStep ws : ttc.Pasos_de_trabajo__r) {
                    // Verificar el estado de los WorkSteps hijos
                    if (ws.Status != null && ws.Status != RM_WorkStep_Helper.WORK_STEP_STATUS_NEW) {
                        anyChildInProgress = true;
                    }
                    if (ws.Status != RM_WorkStep_Helper.WORK_STEP_STATUS_COMPLETED) {
                        allChildrenCompleted = false;
                    }
                }
                
                // Determinar el estado del WorkStep padre
                if (allChildrenCompleted) {
                    parentWorkStepsToUpdate.put(ttc.Paso_de_trabajo__c, new WorkStep(Id = ttc.Paso_de_trabajo__c, Status = RM_WorkStep_Helper.WORK_STEP_STATUS_COMPLETED));
                } else if (anyChildInProgress) {
                    parentWorkStepsToUpdate.put(ttc.Paso_de_trabajo__c, new WorkStep(Id = ttc.Paso_de_trabajo__c, Status = RM_WorkStep_Helper.WORK_STEP_STATUS_IN_PROGRESS));
                }
            }
        }

        
        for (Id wsId : parentWorkStepsToUpdate.keySet()) {
            if(skipParentWorkSteps.contains(wsId)){
                parentWorkStepsToUpdate.remove(wsId);
            }
        }

    
        // Devolver el mapa de WorkSteps padres actualizados
        return parentWorkStepsToUpdate;
    }
    
    

    /**
    * This function updates the 'Status' and 'RM_Mecanico__c' fields of the child WorkStep records associated with the WorkStep records in 'newRecordList'.
    * The fields are updated based on the 'Status' and 'RM_Mecanico__c' fields of the parent WorkStep record.
    */
    public void actualizaSubtrabajos() {
        Set<Id> parentWSIds = workStepHelper.getParentWorkStepIds(newRecordList, oldRecordMap);
        if (parentWSIds.isEmpty()) {
            return;
        }
        Map<Id, WorkStep> parentWSMap = workStepHelper.getParentWorkSteps(parentWSIds);
        Map<Id, tiposDeTrabajoCaso__c> ttcMap = workStepHelper.getTiposDeTrabajoCasoMap(parentWSMap);

        List<WorkStep> workStepsToUpdate = workStepHelper.getWorkStepsToUpdate(parentWSMap, ttcMap, newRecordMap, oldRecordMap);
        if (!workStepsToUpdate.isEmpty()) {
            // RM_WorkStep_Trg_Handler.skipRegistrarActividadMecanico = true;
            // RM_WorkStep_Trg_Handler.skipActualizarModoTrabajo = true;
            // RM_WorkStep_Trg_Handler.skipActualizaSubtrabajos = true;
            // RM_WorkStep_Trg_Handler.skipValidarTrabajoSubtrabajoEnCurso = true;
            
            UPDATE workStepsToUpdate;

            // RM_WorkStep_Trg_Handler.skipRegistrarActividadMecanico = false;
            // RM_WorkStep_Trg_Handler.skipActualizarModoTrabajo = false;
            // RM_WorkStep_Trg_Handler.skipActualizaSubtrabajos = false;
            // RM_WorkStep_Trg_Handler.skipValidarTrabajoSubtrabajoEnCurso = false;
        }
    }

    /**
    * This function validates that a mechanic does not have more than one 'WorkStep' record with the 'Status' field set to 'WS_RUNNING_STATUS'.
    * If a mechanic does have more than one such record, an error is added to the new 'WorkStep' record.
    */
    public void validarTrabajoSubtrabajoEnCurso() {
        Set<Id> mechanicIds = workStepHelper.getMechanicIds(newRecordList, oldRecordMap);
        if (mechanicIds.isEmpty()) {
            return;
        }
        Map<Id,WorkStep> workStepsGroupByMechanicIdMap = workStepHelper.getExistingMechanicsInProgress(mechanicIds);
        workStepHelper.addErrorsToWorkSteps(workStepsGroupByMechanicIdMap,newRecordList, oldRecordMap);
    }
    

}