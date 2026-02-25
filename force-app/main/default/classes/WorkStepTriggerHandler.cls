public with sharing class WorkStepTriggerHandler extends TriggerHandler{

    public List<WorkStep> newRecordList{get;set;}
    public Map<Id, WorkStep> newRecordMap{get;set;}
    public List<WorkStep> oldRecordList{get;set;}
    public Map<Id, WorkStep> oldRecordMap{get;set;}
    
    static final String WS_NEW_STATUS = 'Nueva';
    static final String WS_COMPLETED_STATUS = 'En curso';
    static final String WS_PAUSED_STATUS = 'En pausa';
    static final String WS_RUNNING_STATUS = 'En curso';

    public WorkStepTriggerHandler() {
        this.newRecordList = (List<WorkStep>) Trigger.New;
        this.newRecordMap = (Map<Id, WorkStep>) Trigger.newMap;
        this.oldRecordList = (List<WorkStep>) Trigger.Old;
        this.oldRecordMap = (Map<Id, WorkStep>) Trigger.oldMap;                 
    }

	public override void beforeUpdate(){
        validateWorkMode();
        validateWorkStepInProgress();
    }

    public override void afterUpdate(){        
        actualizarPadres();
        actualizaTareasHijas();

        // validarEnvioSMS();
        // validateWSModified();        
    }

    private Boolean hasWorkStepChanged(WorkStep newWS, WorkStep oldWS) {
        return (newWS.Status != oldWS.Status || newWS.RM_Mecanico__c != oldWS.RM_Mecanico__c) && newWS.Tipo_de_trabajo_del_caso__c != null;
    }

    /**
     * Valida el modo de trabajo de los WorkSteps, si el tipo de trabajo del caso se esta trabajando a nivel de trabajo o subtrabajos
     */
    private void validateWorkMode() {
        Set<Id> ttcIds = new Set<Id>();
        
        for(WorkStep newWS : newRecordList) {
            WorkStep oldWS = oldRecordMap.get(newWS.Id);
            // Check if the Status field has changed and the new value is not empty
            if(hasWorkStepChanged(newWS,oldWS) && String.isNotBlank(newWS.Status)) {
                ttcIds.add(newWS.Tipo_de_trabajo_del_caso__c);
            }
        }

        // If no records matched the criteria, exit early
        if(ttcIds.isEmpty()) {
            return;
        }      
        
        // Fetching related tiposDeTrabajoCaso__c records in one go
        Map<Id, tiposDeTrabajoCaso__c> ttcMap = new Map<Id, tiposDeTrabajoCaso__c>(
            [SELECT Id, RM_ModoTrabajo__c,(SELECT Id, Status,RM_Mecanico__c FROM Pasos_de_trabajo__r WHERE RM_EsTrabajo__c = FALSE)  FROM tiposDeTrabajoCaso__c WHERE Id IN :ttcIds]
        );

        // Validation for RM_EsTrabajo__c and tiposDeTrabajoCaso__c.RM_ModoTrabajo__c relationship
        for(WorkStep newWS : newRecordList) {
            WorkStep oldWS = oldRecordMap.get(newWS.Id);
            if(hasWorkStepChanged(newWS,oldWS)) {
                if(!newWS.RM_EsTrabajo__c && ttcMap.containsKey(newWS.Tipo_de_trabajo_del_caso__c)) {
                    tiposDeTrabajoCaso__c tipo = ttcMap.get(newWS.Tipo_de_trabajo_del_caso__c);
                    if(tipo.RM_ModoTrabajo__c == 'Tarea padre') {
                        newWS.addError('La tarea se esta trabajando a nivel de trabajo.".');
                    }
                } else if(newWS.RM_EsTrabajo__c && ttcMap.containsKey(newWS.Tipo_de_trabajo_del_caso__c)) {
                    tiposDeTrabajoCaso__c ttc = ttcMap.get(newWS.Tipo_de_trabajo_del_caso__c);
                    if(ttc.RM_ModoTrabajo__c == 'Tarea hija') {
                        // newWS.addError('La tarea se esta trabajando a nivel de subtrabajo.');
                        //check if all the worksteps are with status nueva and assigned to the same mechanic not necessary to the parent mechanic id
                        Boolean allNew = true;
                        Id assignedMechanicId = null;

                        for(WorkStep ws : ttc.Pasos_de_trabajo__r) {
                            if(assignedMechanicId == null) {
                                assignedMechanicId = ws.RM_Mecanico__c;
                            }
                            if((String.isNotBlank(ws.Status) &&  ws.Status != 'Nueva') || ws.RM_Mecanico__c != assignedMechanicId) {
                                allNew = false;
                                break;
                            }
                        }
                        if(!allNew) {
                            newWS.addError('La tarea se esta trabajando a nivel de subtrabajo.');
                        }
                    }
                }
            }
        }
    }
    
    private Map<Id,tiposDeTrabajoCaso__c> getTTC() {
        Set<Id> ttcIds = new Set<Id>();
        for (WorkStep workStep : newRecordList) {
            if(workStep.Status != oldRecordMap.get(workStep.Id).Status && workStep.Tipo_de_trabajo_del_caso__c != null){
                ttcIds.add(workStep.Tipo_de_trabajo_del_caso__c);
            }
        }
        return new Map<Id,tiposDeTrabajoCaso__c>([
            SELECT Id,(SELECT Id FROM Pasos_de_trabajo__r WHERE RM_EsTrabajo__c = FALSE AND Status != null AND Status != 'Nueva') FROM tiposDeTrabajoCaso__c WHERE Id IN :ttcIds
        ]);
    }

    private Boolean isLastTask(tiposDeTrabajoCaso__c ttc) {
        if (ttc != null && ttc.Pasos_de_trabajo__r.isEmpty()) {
            return true;
        }
        return false;
    }

    public void actualizarPadres(){
        Map<Id,tiposDeTrabajoCaso__c> existingTTCMap = getTTC();
    
        Map<Id,String> ttcIdModoTrabajoMap = new Map<Id,String>();
        Map<Id,tiposDeTrabajoCaso__c> ttcMapToUpdate = new Map<Id,tiposDeTrabajoCaso__c>();
        for (WorkStep newWS : newRecordList) {
            WorkStep oldWS = oldRecordMap.get(newWS.Id);
            if(hasWorkStepChanged(newWS, oldWS)){
                tiposDeTrabajoCaso__c ttc = new tiposDeTrabajoCaso__c(Id = newWS.Tipo_de_trabajo_del_caso__c);
                
                if ((!newWS.RM_EsTrabajo__c && isLastTask(existingTTCMap.get(newWS.Tipo_de_trabajo_del_caso__c))) && (String.isBlank(newWS.Status) || newWS.Status == WS_NEW_STATUS)) {
                    ttc.RM_ModoTrabajo__c = null;
                } else if (newWS.RM_EsTrabajo__c) {
                    ttc.RM_ModoTrabajo__c = 'Tarea padre';
                } else {
                    ttc.RM_ModoTrabajo__c = 'Tarea hija';
                }
                ttcMapToUpdate.put(newWS.Tipo_de_trabajo_del_caso__c,ttc);                  
            }
        }

        if(!ttcMapToUpdate.isEmpty()) {
            update ttcMapToUpdate.values();
        }        
    }

    public void actualizaTareasHijas() {
        Set<Id> parentWSIds = new Set<Id>();        
        for (WorkStep workStep : newRecordList) {
            if (workStep.RM_EsTrabajo__c && (workStep.Status != oldRecordMap.get(workStep.Id).Status || workStep.RM_Mecanico__c != oldRecordMap.get(workStep.Id).RM_Mecanico__c)) {
                parentWSIds.add(workStep.Id);
            }
        }

        if (parentWSIds.isEmpty()) {
            return;
        }

        Map<Id,WorkStep> parentWSMap= new Map<Id,WorkStep>([SELECT Id,Tipo_de_trabajo_del_caso__c FROM WorkStep WHERE Id IN:parentWSIds AND Tipo_de_trabajo_del_caso__c != null ]);
        Set<Id> ttcIds = new Set<Id>();
        for (WorkStep workStep : parentWSMap.values()) {
            ttcIds.add(workStep.Tipo_de_trabajo_del_caso__c);
        }

        if (ttcIds.isEmpty()) {
            return;
        }

        Map<Id,tiposDeTrabajoCaso__c> ttcMap = new Map<Id,tiposDeTrabajoCaso__c>([SELECT Id,(SELECT Id, Status,RM_Mecanico__c FROM Pasos_de_trabajo__r WHERE RM_EsTrabajo__c = FALSE) FROM tiposDeTrabajoCaso__c WHERE Id IN:ttcIds]);

        List<WorkStep> workStepsToUpdate = new List<WorkStep>();
        
        for (WorkStep workStep : parentWSMap.values()) {
            WorkStep newParetWS = newRecordMap.get(workStep.Id);
            WorkStep oldParetWS = oldRecordMap.get(workStep.Id);

            tiposDeTrabajoCaso__c ttc = ttcMap.get(workStep.Tipo_de_trabajo_del_caso__c);

            if (ttc != null) {

                for (WorkStep currWS : ttc.Pasos_de_trabajo__r) {

                    WorkStep workStepToUpdate = new WorkStep(
                        Id =  currWS.Id
                    );
                    
                    if (newParetWS.Status != oldParetWS.Status) {                        
                        workStepToUpdate.Status = newParetWS.Status;
                    }
                    
                    if (newParetWS.RM_Mecanico__c != oldParetWS.RM_Mecanico__c) {                        
                        workStepToUpdate.RM_Mecanico__c = newParetWS.RM_Mecanico__c;
                    }                    

                    workStepsToUpdate.add(workStepToUpdate);

                }
            }
        }

        if (!workStepsToUpdate.isEmpty()) {
            WorkStepTriggerHandler.bypass('WorkStepTriggerHandler');
                update workStepsToUpdate;
            WorkStepTriggerHandler.clearBypass('WorkStepTriggerHandler');

        }
    }

    /**
    * @description Clona un registro de Work Step cuando se reasigna de mecanico, siempre y cuando el registro actual
    *              su estatus sea diferente de Completada, tenga tiempo trabajado y tenga un mecanico asignado anteriormente
    * @author marcohernandezhp@gmail.com | 08-28-2022 
    * @param newRecordMap Mapa con la lista de valores nuevos de Work Step
    * @param oldRecordMap Mapa con la lista de valores anteriores de Work Step
    **/
    // public void cloneWorkStepNewAssignment(List<WorkStep> newRecordList,Map<Id, WorkStep> oldRecordMap) {
    //     List<WorkStep> workStepToInsertList = new List<WorkStep>();
    //     List<tiposDeTrabajoCaso__c> tipoTrabajoCasoToInsertList = new List<tiposDeTrabajoCaso__c>();
    //     List<tiposDeTrabajoCaso__c> tipoTrabajoCasoToUpdateList = new List<tiposDeTrabajoCaso__c>();
    //     Set<Id> ttcIdsSet = new Set<Id>();
        
    //     for (WorkStep currentWorkStep : newRecordList) {
    //         WorkStep oldWorkStep = oldRecordMap.get(recordId);
    //         if (currentWorkStep.Status != WS_COMPLETED_STATUS && currentWorkStep.RM_Mecanico__c != oldWorkStep.RM_Mecanico__c && currentWorkStep.RM_Mecanico__c != null &&  (oldWorkStep.Total_de_tiempo_trabajado_en_minutos__c == null || oldWorkStep.Total_de_tiempo_trabajado_en_minutos__c == 0)) {
    //             WorkStep newWorkStep = oldWorkStep.clone(false, true, false, false);

    //             Id currentMechanicId = oldWorkStep.RM_Mecanico__c;

    //             newWorkStep.StartTime = null;
    //             newWorkStep.EndTime = null;
    //             newWorkStep.Status = WS_NEW_STATUS;
    //             newWorkStep.Tiempo_trabajado_en_mins_antes_de_pausa__c = 0;
    //             newWorkStep.AcumuladoMinutosPausas__c = 0;
    //             workStepToInsertList.add(newWorkStep);

    //             currentWorkStep.Status = WS_COMPLETED_STATUS;
    //             currentWorkStep.Flag_Reasignacion__c = true;
    //             currentWorkStep.RM_Mecanico__c = currentMechanicId; 
                
    //             ttcIdsSet.add(currentWorkStep.Tipo_de_trabajo_del_caso__c);
    //         }
    //     }

    //     if (ttcIdsSet.isEmpty()) {
    //         return;            
    //     }

    //     Map<Id,tiposDeTrabajoCaso__c> tipoTrabajoCasoMap = new Map<Id,tiposDeTrabajoCaso__c>([]);

    //     if (workStepToInsertList.size() > 0) {
    //         isSystemUpdate = true;
    //         insert workStepToInsertList;            
    //     }
    // }

    /**
    * @description Valida si el mecanico ya tiene una tarea en curso, si es asi, se le muestra un mensaje de error
    * @author marcohernandezhp@gmail.com | 09-19-2022 
    * @param newRecordList List with new records
    **/
    public void validateWorkStepInProgress() {
        Set<Id> mechanicIds = new Set<Id>();
        for (WorkStep newRecord : newRecordList) {
            if (newRecord.RM_Mecanico__c != null && newRecord.Status != oldRecordMap.get(newRecord.Id).Status && newRecord.Status == WS_RUNNING_STATUS) {
                mechanicIds.add(newRecord.RM_Mecanico__c);
            }
        }

        if (mechanicIds.isEmpty()) {
            return;
        }

        List<WorkStep> existingWorkSteps = [SELECT RM_Mecanico__c FROM WorkStep WHERE RM_Mecanico__c IN :mechanicIds AND Status = : WS_RUNNING_STATUS];
        Set<Id> existingMechanics = new Set<Id>();
        for(WorkStep ws : existingWorkSteps) {
            existingMechanics.add(ws.RM_Mecanico__c);
        }

        for(WorkStep newRecord : newRecordList) {
            if(newRecord.RM_Mecanico__c != null && newRecord.Status != oldRecordMap.get(newRecord.Id).Status &&  newRecord.Status == WS_RUNNING_STATUS && existingMechanics.contains(newRecord.RM_Mecanico__c)) {
                newRecord.addError('El mecánico ya tiene una tarea "En curso".');
            }
        }
    }
    
    //<<<Pendiente Revisar>>
    // public void validarEnvioSMS(){
    //     List<String> wsIds = new List<String>(); 
    //     for (WorkStep workStep : newRecordList) {
    //         if (!workStep.Flag_System_Update__c) {
    //             if (workStep.Status != oldRecordMap.get(workStep.Id).Status && (workStep.Status == 'En curso' || workStep.Status == 'Completada')) {
    //                 wsIds.add(workStep.Id);
    //             }                
    //         }
    //     }

    //     if (wsIds.size()>0) {
    //         RM_WS_SMS_Service.sendSMSInProgress(wsIds);
    //     }
    // }

    //<<<Pendiente Revisar>>
    // public void validateWSModified(){
    //     Set<Id> caseIds = new Set<Id>(); 
    //     for (WorkStep workStep : newRecordList) {
    //         if (workStep.RM_Mecanico__c != oldRecordMap.get(workStep.Id).RM_Mecanico__c && workStep.Caso__c!=null) {
    //             caseIds.add(workStep.Caso__c);
    //         }
    //     }

    //     List<RM_Event__e> rmEventList = new List<RM_Event__e>();
    //     for (Id caseId : caseIds) {
    //         rmEventList.add(new RM_Event__e(
    //             Record_Id__c = caseId,
    //             Alert_Type__c = 'refresh'
    //         ));
    //     }

    //     if (rmEventList.size()>0) {
    //         EventBus.publish(rmEventList);
    //     }            
    // }
}