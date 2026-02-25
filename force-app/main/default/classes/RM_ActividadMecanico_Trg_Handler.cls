/**
 * @File Name          : RM_ActividadMecanico_Trg_Handler.cls
 * @Description        : Clase que maneja los triggers de RM_ActividadMecanico__c
 * @Test Class         : RM_ActividadMecanico_Trg_Handler_Test
 * @author Redmotors
 * @since 
 */
public with sharing class RM_ActividadMecanico_Trg_Handler extends TriggerHandler{
    private List<RM_ActividadMecanico__c> newRecordList{get;set;}
    private List<RM_ActividadMecanico__c> oldRecordList{get;set;}
    private Map<Id, RM_ActividadMecanico__c> newRecordMap{get;set;}
    private Map<Id, RM_ActividadMecanico__c> oldRecordMap{get;set;}

    public RM_ActividadMecanico_Trg_Handler () {
        this.newRecordList = (List<RM_ActividadMecanico__c>) Trigger.New;
        this.oldRecordList = (List<RM_ActividadMecanico__c>) Trigger.Old;
        this.newRecordMap = (Map<Id, RM_ActividadMecanico__c>) Trigger.newMap;
        this.oldRecordMap = (Map<Id, RM_ActividadMecanico__c>)  Trigger.oldMap;                      
    }

    public override void beforeInsert(){                  
        setStartDate();
    }

    public override void afterInsert(){                  
        terminarActividadActual();
    }

    public override void afterUpdate(){                  
        // pausarTrabajoEnCurso();
    }

    private void setStartDate() {
        for (RM_ActividadMecanico__c newRecord : (List<RM_ActividadMecanico__c>) Trigger.New) {
            newRecord.RM_FechaHoraInicio__c = Datetime.now();
        }
    }

    private void terminarActividadActual() {
        Set<Id> workStepIds = new Set<Id>();
        List<RM_ActividadMecanico__c> recordsToUpdateList = new List<RM_ActividadMecanico__c>();
        Set<Id> mechanicIds = new Set<Id>();
        for (RM_ActividadMecanico__c newRecord : newRecordList) {     
            if (newRecord.RM_Mecanico__c != null) {
                mechanicIds.add(newRecord.RM_Mecanico__c);
            }
        }

        Set<Id> pasoIds = new Set<Id>();
        if (!mechanicIds.isEmpty()) {
            recordsToUpdateList = [SELECT Id,RM_Tipo__c,RM_Paso__c,RM_Paso__r.RM_EsTrabajo__c,RM_Paso__r.Tipo_de_trabajo_del_caso__c,RM_Paso__r.Tipo_de_trabajo_del_caso__r.RM_ModoTrabajo__c FROM RM_ActividadMecanico__c WHERE RM_Mecanico__c IN :mechanicIds AND Id NOT IN :newRecordMap.keySet() AND RM_FechaHoraFin__c = NULL AND CreatedDate >= TODAY];
        }
        
        Set<Id> trabajoIds = new Set<Id>();
        Set<Id> ttcIds = new Set<Id>();
        if (recordsToUpdateList.size() > 0) {
            for (RM_ActividadMecanico__c record : recordsToUpdateList) {
                record.RM_FechaHoraFin__c = Datetime.now();
                if (record.RM_Tipo__c == 'Tarea En Curso' && record.RM_Paso__c != null) {
                    pasoIds.add(record.RM_Paso__c);
                }
            }

            TriggerHandler.bypass('RM_ActividadMecanico_Trg_Handler');
            UPDATE recordsToUpdateList;
            TriggerHandler.clearBypass('RM_ActividadMecanico_Trg_Handler');

            if (pasoIds.size() > 0) {
                List<WorkStep> workSteps = [SELECT Id,Status,Caso__c FROM WorkStep WHERE Id IN :pasoIds AND Status = 'En curso'];
                for (WorkStep ws : workSteps) {
                    ws.Status = 'En pausa';
                }

                if(workSteps.size() > 0){
                    RM_WorkStep_Trg_Handler.skipValidarTrabajoSubtrabajoEnCurso = true;
                    RM_WorkStep_Trg_Handler.skipRegistrarActividadMecanico = true;
                    RM_WorkStep_Trg_Handler.skipActualizarModoTrabajo = true;
                    RM_WorkStep_Trg_Handler.skipActualizaSubtrabajos = false;
                    UPDATE workSteps;
                    RM_WorkStep_Trg_Handler.skipValidarTrabajoSubtrabajoEnCurso = false;
                    RM_WorkStep_Trg_Handler.skipRegistrarActividadMecanico = false;
                    RM_WorkStep_Trg_Handler.skipActualizarModoTrabajo = false;
                    RM_WorkStep_Trg_Handler.skipActualizaSubtrabajos = false;

                    List<RM_Event__e> workStepEvents = new List<RM_Event__e>();
                    for (WorkStep ws : workSteps) {                        
                        workStepEvents.add(new RM_Event__e(
                            Record_Id__c = ws.Caso__c
                        ));
                    }

                    if (workStepEvents.size()>0) {
                        EventBus.publish(workStepEvents);
                    }
                }
            }
        }
    }
    
    // private void pausarTrabajoEnCurso(){
    //     Set<Id> workStepIds = new Set<Id>();
    //     Set<Id> mechanicIds = new Set<Id>();

    //     for (RM_ActividadMecanico__c newRecord : newRecordList) {            
    //         if (newRecord.RM_Paso__c != null && newRecord.RM_FechaHoraFin__c != oldRecordMap.get(newRecord.Id).RM_FechaHoraFin__c && newRecord.RM_FechaHoraFin__c != null) {
    //             workStepIds.add(newRecord.RM_Paso__c);
    //         }

    //         mechanicIds.add(newRecord.RM_Mecanico__c);
    //     }
    //     if (workStepIds.isEmpty()) {
    //         return;
    //     }

    //     List<RM_ActividadMecanico__c> actividades = [SELECT Id,RM_Mecanico__c,RM_FechaHoraFin__c,RM_Paso__c FROM RM_ActividadMecanico__c WHERE  RM_Mecanico__c IN :mechanicIds AND RM_FechaHoraFin__c = NULL AND RM_Paso__c != NULL];
    //     Map<Id,Id> mechanicWorkStepInProgressMap = new Map<Id,Id>();
    //     for (RM_ActividadMecanico__c am : actividades) {
    //         mechanicWorkStepInProgressMap.put(am.RM_Mecanico__c,am.RM_Paso__c);
    //     }

    //     List<WorkStep> workSteps = [SELECT Id,Status,RM_Mecanico__c FROM WorkStep WHERE  Id IN :workStepIds AND Status = 'En curso'];
    //     List<WorkStep> workStepsToPause = new List<WorkStep>();
    //     for (WorkStep ws : workSteps) {
    //         if (workStepIds.contains(ws.Id) && ws.Status == 'En curso' && (!mechanicWorkStepInProgressMap.containsKey(ws.RM_Mecanico__c) || (mechanicWorkStepInProgressMap.containsKey(ws.RM_Mecanico__c) && mechanicWorkStepInProgressMap.get(ws.RM_Mecanico__c) != ws.Id))) {
    //             ws.Status = 'En pausa';
    //             workStepsToPause.add(ws);
    //         }
    //     }

    //     if(workStepsToPause.size() > 0){
    //         bypass('RM_WorkStep_Trg_Handler');
    //         update workStepsToPause;
    //         clearBypass('RM_WorkStep_Trg_Handler');
    //     }
    // }
}