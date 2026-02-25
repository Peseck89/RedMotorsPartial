public class CaseTriggerHandler extends TriggerHandler {

    public static Boolean runOrders = false;

    public List<Case> newRecordList { get; set; }
    public Map<Id, Case> newRecordMap { get; set; }
    public List<Case> oldRecordList { get; set; }
    public Map<Id, Case> oldRecordMap { get; set; }

    public CaseTriggerHandler() {
        // Inicializar listas y mapas con los registros del trigger
        this.newRecordList = (List<Case>) Trigger.New;
        this.newRecordMap = (Map<Id, Case>) Trigger.newMap;
        this.oldRecordList = (List<Case>) Trigger.Old;
        this.oldRecordMap = (Map<Id, Case>) Trigger.oldMap;                 
    }

    public override void afterInsert(){
        // onAfterInsert(newRecordList);
        double count = 1;
        count += 1;
        count += 1;
        count += 1;
        count += 1;
        count += 1;
        count += 1;
        count += 1;
        count += 1;
    }

    public override void afterUpdate(){  
        // onAfterUpdate(newRecordList, newRecordMap, oldRecordMap);
        completarTrabajosYSubtrabajos(newRecordList, oldRecordMap);
    }

    public override void beforeDelete() {
        // Llamar al método de validación antes de eliminar los casos
        validateDeleteCases(oldRecordList);
    }

    // Crear método que valide que Case.Status cambio a Cerrado, consulte los WorkSteps relacionados por WorkStep.Caso__c
    // donde WorkStep.Status != Completada y StartTime != null.
    // Si existen registros, actualiza el campo WorkStep.Status a Completada
    public static void completarTrabajosYSubtrabajos(List<Case> newRecordList, Map<Id, Case> oldRecordMap){
        Set<String> caseIds = new Set<String>();
        for(Case caso : newRecordList) {
            if(caso.Status != oldRecordMap.get(caso.Id).Status && caso.Status == 'Cerrado')
                caseIds.add(caso.Id);
        }
        
        if(caseIds.size() > 0) {
            List<WorkStep> workStepsToComplete = [SELECT Id, Status, StartTime, EndTime FROM WorkStep 
                                                  WHERE Caso__c IN :caseIds AND Status != 'Completada'];
            
            if(workStepsToComplete.size() > 0) {
                for(WorkStep ws : workStepsToComplete) {
                    ws.Status = 'Completada';
                    ws.RM_SkipVR__c = true;
                    ws.StartTime = ws.StartTime != null ? ws.StartTime : System.now();
                }
                WorkStepTriggerHandler.bypass('RM_WorkStep_Trg_Handler');
                update workStepsToComplete;

                for(WorkStep ws : workStepsToComplete) {
                    ws.RM_SkipVR__c = false;
                }
                update workStepsToComplete;
                WorkStepTriggerHandler.clearBypass('RM_WorkStep_Trg_Handler');
            }
        }
    }

    // Validar que el usuario actual, si contiene 'egaray@redmotorscr.com' en su nombre de usuario,
    // no pueda eliminar casos a menos que sean de tipo de registro exactamente 'Motos' o 'Autos'
    private void validateDeleteCases(List<Case> casesToDelete) {
        // Obtener el usuario actual y verificar si el nombre de usuario contiene 'egaray@redmotorscr.com'
        User currentUser = [SELECT Username FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        
        if (currentUser.Username.contains('egaray@redmotorscr.com')) {
            // Obtener los Ids de Record Types válidos para 'Motos' y 'Autos' y almacenarlos en un Set
            Set<Id> validRecordTypeIds = new Set<Id>();
            for (RecordType rt : [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND Name IN ('Motos', 'Autos')]) {
                validRecordTypeIds.add(rt.Id);
            }

            // Iterar sobre los casos que se están intentando eliminar
            for (Case caseRecord : casesToDelete) {
                // Verificar si el RecordTypeId del caso no está en el conjunto de Ids válidos
                if (validRecordTypeIds.contains(caseRecord.RecordTypeId)) {
                    // Agregar un error que previene la eliminación del caso si no es del tipo permitido
                    caseRecord.addError('No tienes permiso para eliminar casos que sean de taller.');
                }
            }
        }
    }

    // <<<pendiente de revisar>>>
    // public static void onAfterUpdate(List<Case> newList, Map<Id, Case> newRecordMap, Map<Id, Case> oldRecordMap)
    // {
    //     CaseTriggerHandler.runOrders = true;
    //     Set<String> caseIds = new Set<String>();
    //     for(Case cs : newList) {
    //         if(cs.Create_Orders_from_Workorders__c)
    //             caseIds.add(cs.Id);
    //     }
        
    //     if(caseIds.size() > 0) {
    //         List<Workorder> woList = [SELECT Id FROM Workorder WHERE CaseId in : caseIds];
            
    //         if(woList.size() > 0) {
    //             update woList;
    //         }
    //         updateCaseCheck(caseIds);
    //     }

    //     caseIds = new Set<String>();
    //     for (Case caso : newList) {
    //         if (caso.Mecanico_Asignado__c != oldRecordMap.get(caso.Id).Mecanico_Asignado__c && caso.Mecanico_Asignado__c != null && caso.Status != 'Cerrado') {
    //             caseIds.add(caso.Id);
    //         }
    //     }

    //     if (caseIds.size() > 0) {
    //         List<WorkStep> workStepList = [SELECT Id, Mec_nico_asignado__c, Caso__c, Status, Flag_Is_Task_FX__c, WorkOrder.Status FROM WorkStep 
    //                                        WHERE Caso__c IN : caseIds AND Caso__r.Status != 'Cerrado' AND Status != 'Completada' 
    //                                        AND WorkOrder.Etapa_de_flujo_de_trabajo__c != 'Orden Facturada' 
    //                                        AND WorkOrder.Etapa_de_flujo_de_trabajo__c != 'Orden Rechazada'];

    //         Map<Id, Boolean> caseIdBooleanMap = new Map<Id, Boolean>();
    //         for (WorkStep ws : workStepList) {
    //             if (ws.Status == 'Nueva') {
    //                 ws.Mec_nico_asignado__c = newRecordMap.get(ws.Caso__c).Mecanico_Asignado__c;
    //                 ws.Flag_System_Update__c = true;
    //             } else {
    //                 caseIdBooleanMap.put(ws.Caso__c, true);
    //             }                
    //         }

    //         if (workStepList.size() > 0) {
    //             update workStepList;
    //         }

    //         // Apagar bandera update by the system
    //         for (WorkStep ws : workStepList) {
    //             ws.Flag_System_Update__c = false;
    //             update workStepList;
    //         }

    //         List<RM_Event__e> rmEventList = new List<RM_Event__e>();
    //         for (Id caseId : caseIdBooleanMap.keySet()) {
    //             rmEventList.add(new RM_Event__e(
    //                 Message__c = 'El caso tiene tareas en proceso que no fueron reasignadas.',
    //                 Record_Id__c = caseId,
    //                 Type__c = 'alert',
    //                 Alert_Type__c = 'warning',
    //                 Title__c = 'Asignación de mecánico'
    //             ));
    //         }

    //         if (rmEventList.size() > 0) {
    //             EventBus.publish(rmEventList);
    //         }            
    //     }
    // }

    // <<<pendiente de revisar>>>
    // public static void onAfterInsert(List<Case> newList)
    // {
    //     List<String> caseIds = new List<String>();
    //     for (Case caso : newList) {
    //         if (caso.Cita__c != null) {                
    //             caseIds.add(caso.Id);
    //         }
    //     }

    //     if (caseIds.size() > 0) {
    //         RM_WS_SMS_Service.sendSMSTallerCheckIN(caseIds);
    //     }
    // }

    // <<<pendiente de revisar>>>
    // @future
    // public static void updateCaseCheck(Set<String> caseIds)
    // {
    //     List<Case> newList = new List<Case>();
    //     for(String caseId : caseIds) {
    //         newList.add(new Case(Id = caseId, Create_Orders_from_Workorders__c = false));
    //     }
        
    //     if(newList.size() > 0)
    //         update newList;
    // }
}