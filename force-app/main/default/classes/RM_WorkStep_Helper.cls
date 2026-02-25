public with sharing class RM_WorkStep_Helper {

    public static final String WORK_STEP_STATUS_NEW = 'Nueva';
    public static final String WORK_STEP_STATUS_IN_PROGRESS = 'En curso';
    public static final String WORK_STEP_STATUS_IN_PAUSE = 'En pausa';
    public static final String WORK_STEP_STATUS_COMPLETED = 'Completada';

    public Set<Id> getWorkStepIds(List<WorkStep> newRecordList, Map<Id, WorkStep> oldRecordMap) {
        Set<Id> workStepIds = new Set<Id>();
        for (WorkStep newRecord : newRecordList) {
            if (newRecord.Status != oldRecordMap.get(newRecord.Id).Status && newRecord.Status != null 
            && (newRecord.Status == RM_WorkStep_Helper.WORK_STEP_STATUS_IN_PROGRESS ||
            newRecord.Status == RM_WorkStep_Helper.WORK_STEP_STATUS_IN_PAUSE ||
            newRecord.Status == RM_WorkStep_Helper.WORK_STEP_STATUS_COMPLETED
            )
            ) {
                workStepIds.add(newRecord.Id);
            }
        }
        return workStepIds;
    }

    public Map<Id, Case> getCases(Set<Id> workStepIds, Map<Id, WorkStep> newRecordMap) {
        Set<Id> casoIds = new Set<Id>();
        for (Id wsId : workStepIds) {
            WorkStep ws = newRecordMap.get(wsId);
            casoIds.add(ws.Caso__c);
        }

        Map<Id, Case> cases = new Map<Id, Case>();
        if(!casoIds.isEmpty()){
            cases = new Map<Id, Case>([SELECT Id,Service_Territory1__c FROM Case WHERE Id IN :casoIds]);
        }
        return cases;
    }

    public List<RM_ActividadMecanico__c> getActivitiesToRegister(Set<Id> workStepIds, Map<Id, Case> cases, Map<Id, WorkStep> newRecordMap) {
        List<RM_ActividadMecanico__c> activitiesToRegister = new List<RM_ActividadMecanico__c>();
        for (Id wsId : workStepIds) {
            WorkStep ws = newRecordMap.get(wsId);
            Case caso = cases.get(ws.Caso__c);
            RM_ActividadMecanico__c act = new RM_ActividadMecanico__c(
                RM_Caso__c = ws.Caso__c,
                RM_Orden__c = ws.WorkOrderId,
                RM_Taller__c = caso?.Service_Territory1__c,
                RM_Paso__c = ws.Id,
                RM_Mecanico__c = ws.RM_Mecanico__c,
                RM_Tipo__c = getActividadType(ws)
            );

            activitiesToRegister.add(act);
        }
        return activitiesToRegister;
    }

    private String getActividadType(WorkStep ws){
        if(ws.Status.equals(WORK_STEP_STATUS_IN_PROGRESS)){
            return 'Tarea En Curso';
        } else if(ws.Status.equals(WORK_STEP_STATUS_IN_PAUSE)){
            return 'Tarea En Pausa';
        } else if(ws.Status.equals(WORK_STEP_STATUS_COMPLETED)){
            return 'Tarea Completada';
        }
        return null;
    }

        
    /**
     * This function returns a map of tiposDeTrabajoCaso__c records that are associated with the WorkStep records in newRecordList.
     * Only the tiposDeTrabajoCaso__c records that are associated with WorkStep records whose status has changed and whose Tipo_de_trabajo_del_caso__c field is not null are included in the map.
     */
    public Map<Id, tiposDeTrabajoCaso__c> getTiposDeTrabajoCasoMap(List<WorkStep> newRecordList, Map<Id, WorkStep> oldRecordMap) {
        // Collect the IDs of the tiposDeTrabajoCaso__c records that are associated with the WorkStep records in newRecordList.
        Set<Id> ttcIds = new Set<Id>();
        for (WorkStep workStep : newRecordList) {
            if (workStep.Status != oldRecordMap.get(workStep.Id).Status && workStep.Tipo_de_trabajo_del_caso__c != null) {
                ttcIds.add(workStep.Tipo_de_trabajo_del_caso__c);
            }
        }

        // Query the tiposDeTrabajoCaso__c records and return them as a map.
        return new Map<Id, tiposDeTrabajoCaso__c>([
            SELECT Id,Paso_de_trabajo__c,Paso_de_trabajo__r.Status, (SELECT Id,Status FROM Pasos_de_trabajo__r WHERE RM_EsTrabajo__c = FALSE ) 
            FROM tiposDeTrabajoCaso__c 
            WHERE Id IN :ttcIds
        ]);
    }

    /**
     * This function creates a new 'tiposDeTrabajoCaso__c' record with the 'RM_ModoTrabajo__c' field set based on the 'RM_EsTrabajo__c' and 'Status' fields of the given WorkStep record and whether it is the last task.
     */
    public tiposDeTrabajoCaso__c createTiposDeTrabajoCaso(WorkStep newWS, Map<Id, tiposDeTrabajoCaso__c> existingTTCMap) {
        tiposDeTrabajoCaso__c ttc = new tiposDeTrabajoCaso__c(Id = newWS.Tipo_de_trabajo_del_caso__c);
        if ((!newWS.RM_EsTrabajo__c && isLastWorkStep(existingTTCMap.get(newWS.Tipo_de_trabajo_del_caso__c))) && (String.isBlank(newWS.Status) || newWS.Status == WORK_STEP_STATUS_NEW)) {
            ttc.RM_ModoTrabajo__c = null;//
        } else if (newWS.RM_EsTrabajo__c) {
            ttc.RM_ModoTrabajo__c = 'Tarea padre';
        } else {
            ttc.RM_ModoTrabajo__c = 'Tarea hija';
        }
        return ttc;
    }

    /**
     * This function checks if the given 'tiposDeTrabajoCaso__c' record is the last task.
     * It returns 'true' if the 'Pasos_de_trabajo__r' relationship field is empty, and 'false' otherwise.
     */
    public Boolean isLastWorkStep(tiposDeTrabajoCaso__c ttc) {
        return ttc != null && ttc.Pasos_de_trabajo__r.isEmpty();
    }

    /**
    * This function returns the IDs of the parent WorkStep records in 'newRecordList'.
    */
    public Set<Id> getParentWorkStepIds(List<WorkStep> newRecordList, Map<Id, WorkStep> oldRecordMap) {
        Set<Id> parentWSIds = new Set<Id>();
        for (WorkStep workStep : newRecordList) {
            if (workStep.RM_EsTrabajo__c && (workStep.Status != oldRecordMap.get(workStep.Id).Status || workStep.RM_Mecanico__c != oldRecordMap.get(workStep.Id).RM_Mecanico__c)) {
                parentWSIds.add(workStep.Id);
            }
        }
        return parentWSIds;
    }

    /**
    * This function returns a map of the parent WorkStep records with the given IDs.
    */
    public Map<Id, WorkStep> getParentWorkSteps(Set<Id> parentWSIds) {
        return new Map<Id, WorkStep>([SELECT Id, Tipo_de_trabajo_del_caso__c FROM WorkStep WHERE Id IN :parentWSIds AND Tipo_de_trabajo_del_caso__c != null]);
    }

    /**
    * This function returns a map of the 'tiposDeTrabajoCaso__c' records associated with the given parent WorkStep records.
    */
    public Map<Id, tiposDeTrabajoCaso__c> getTiposDeTrabajoCasoMap(Map<Id, WorkStep> parentWSMap) {
        Set<Id> ttcIds = new Set<Id>();
        for (WorkStep workStep : parentWSMap.values()) {
            ttcIds.add(workStep.Tipo_de_trabajo_del_caso__c);
        }
        if (ttcIds.isEmpty()) {
            return new Map<Id, tiposDeTrabajoCaso__c>();
        }
        return new Map<Id, tiposDeTrabajoCaso__c>([SELECT Id, (SELECT Id, Status, RM_Mecanico__c FROM Pasos_de_trabajo__r WHERE RM_EsTrabajo__c = FALSE) FROM tiposDeTrabajoCaso__c WHERE Id IN :ttcIds]);
    }

    /**
    * This function returns a list of the child WorkStep records that need to be updated based on the given parent WorkStep records and 'tiposDeTrabajoCaso__c' records.
    */
    public List<WorkStep> getWorkStepsToUpdate(Map<Id, WorkStep> parentWSMap, Map<Id, tiposDeTrabajoCaso__c> ttcMap, Map<Id, WorkStep> newRecordMap, Map<Id, WorkStep> oldRecordMap) {
        List<WorkStep> workStepsToUpdate = new List<WorkStep>();
        for (WorkStep workStep : parentWSMap.values()) {
            WorkStep newParentWS = newRecordMap.get(workStep.Id);
            WorkStep oldParentWS = oldRecordMap.get(workStep.Id);
            tiposDeTrabajoCaso__c ttc = ttcMap.get(workStep.Tipo_de_trabajo_del_caso__c);
            if (ttc != null) {
                for (WorkStep currWS : ttc.Pasos_de_trabajo__r) {
                    WorkStep workStepToUpdate = new WorkStep(Id = currWS.Id);
                    if (newParentWS.Status != oldParentWS.Status) {
                        workStepToUpdate.Status = newParentWS.Status;
                        // workStepToUpdate.Flag_System_Update__c = true;
                    }
                    if (newParentWS.RM_Mecanico__c != oldParentWS.RM_Mecanico__c) {
                        workStepToUpdate.RM_Mecanico__c = newParentWS.RM_Mecanico__c;
                        // workStepToUpdate.Flag_System_Update__c = true;
                    }
                    workStepsToUpdate.add(workStepToUpdate);
                }
            }
        }
        return workStepsToUpdate;
    }

    /**
    * This function returns the IDs of the mechanics associated with the 'WorkStep' records in 'newRecordList' that have the 'Status' field set to 'WS_RUNNING_STATUS'.
    */
   public Set<Id> getMechanicIds(List<WorkStep> newRecordList, Map<Id, WorkStep> oldRecordMap) {
        Set<Id> mechanicIds = new Set<Id>();
        for (WorkStep newRecord : newRecordList) {
            if (newRecord.RM_Mecanico__c != null && newRecord.Status != oldRecordMap.get(newRecord.Id).Status && newRecord.Status == WORK_STEP_STATUS_IN_PROGRESS) {
                mechanicIds.add(newRecord.RM_Mecanico__c);
            }
        }
        return mechanicIds;
    }

    /**
    * This function returns the IDs of the mechanics associated with the existing 'WorkStep' records that have the 'Status' field set to 'WORK_STEP_STATUS_IN_PROGRESS'.
    */
   public Map<Id,WorkStep> getExistingMechanicsInProgress(Set<Id> mechanicIds) {
        Map<Id,WorkStep> workStepByMechanicIdMap = new Map<Id,WorkStep>();
        for (WorkStep ws : [SELECT RM_Mecanico__c,Tipo_de_trabajo_del_caso__c,RM_EsTrabajo__c,
        Tipo_de_trabajo_del_caso__r.Paso_de_trabajo__c, Tipo_de_trabajo_del_caso__r.Paso_de_trabajo__r.Id,Tipo_de_trabajo_del_caso__r.RM_ModoTrabajo__c,
        Tipo_de_trabajo_del_caso__r.Paso_de_trabajo__r.Status FROM WorkStep WHERE RM_Mecanico__c IN :mechanicIds AND Status = : WORK_STEP_STATUS_IN_PROGRESS
        AND ((Tipo_de_trabajo_del_caso__r.RM_ModoTrabajo__c = 'Tarea padre' AND RM_EsTrabajo__c = TRUE) OR (Tipo_de_trabajo_del_caso__r.RM_ModoTrabajo__c = 'Tarea hija' AND RM_EsTrabajo__c = FALSE))]) {
            workStepByMechanicIdMap.put(ws.RM_Mecanico__c,ws);
        }
        return workStepByMechanicIdMap;
    }

    /**
    * This function adds an error to the 'WorkStep' records in 'newRecordList' that have the 'Status' field set to 'WORK_STEP_STATUS_IN_PROGRESS' and are associated with a mechanic in 'existingMechanics'.
    */
   public void addErrorsToWorkSteps(Map<Id,WorkStep> workStepsGroupByMechanicIdMap, List<WorkStep> newRecordList, Map<Id, WorkStep> oldRecordMap) {
        for (WorkStep newRecord : newRecordList) {
            WorkStep existingWorkStep = workStepsGroupByMechanicIdMap.get(newRecord.RM_Mecanico__c);
            if (newRecord.RM_Mecanico__c != null && newRecord.Status != oldRecordMap.get(newRecord.Id).Status && newRecord.Status == WORK_STEP_STATUS_IN_PROGRESS && existingWorkStep != null && !(existingWorkStep.RM_EsTrabajo__c == true && existingWorkStep.Tipo_de_trabajo_del_caso__r.RM_ModoTrabajo__c == 'Tarea hija')) {
                newRecord.addError('El mecánico ya tiene una tarea "En curso".');
            }
        }
    }

    public void createAndPublishWorkStepEvents(List<RM_ActividadMecanico__c> activitiesToRegister) {
        List<RM_WorkStep__e> workStepEvents = new List<RM_WorkStep__e>();
        for (RM_ActividadMecanico__c activity : activitiesToRegister) {
            RM_WorkStep__e workStepEvent = new RM_WorkStep__e();
            workStepEvent.RM_Paso__c = activity.RM_Paso__c;
            workStepEvents.add(workStepEvent);
        }

        if(workStepEvents.size() > 0){
            EventBus.publish(workStepEvents);
        }
    }

    public WorkStep validateStatusAndSetNewDates(WorkStep newRecord, WorkStep oldRecord) {
        if(newRecord.Status != oldRecord.Status){
            //NUEVO O SIN ESTADO
            if (newRecord.Status == null || newRecord.Status == RM_WorkStep_Helper.WORK_STEP_STATUS_NEW) {
                newRecord.StartTime = null;
                newRecord.EndTime = null;
                newRecord.AcumuladoMinutosPausas__c = 0;
                newRecord.Hora_de_inicio_de_pausa__c = null;
                newRecord.Hora_de_finalizaci_n_de_pausa__c = null;
            //EN CURSO
            } else if(newRecord.Status == RM_WorkStep_Helper.WORK_STEP_STATUS_IN_PROGRESS && newRecord.StartTime == null){
                newRecord.StartTime = Datetime.now();
            //REANUDAR
            } else if(newRecord.Status == RM_WorkStep_Helper.WORK_STEP_STATUS_IN_PROGRESS && oldRecord.Status == RM_WorkStep_Helper.WORK_STEP_STATUS_IN_PAUSE){
                // newRecord.AcumuladoMinutosPausas__c = AcumuladoMinutosPausas__c
                // newRecord.Hora_de_finalizaci_n_de_pausa__c
            //EN PAUSA
            } else if(newRecord.Status == RM_WorkStep_Helper.WORK_STEP_STATUS_IN_PAUSE){
                newRecord.Hora_de_inicio_de_pausa__c = Datetime.now();
                newRecord.Hora_de_finalizaci_n_de_pausa__c = null;
            //COMPLETADA
            } else if(newRecord.Status == RM_WorkStep_Helper.WORK_STEP_STATUS_COMPLETED){
                newRecord.EndTime = Datetime.now();
            }
        }
        return newRecord;
    }
}