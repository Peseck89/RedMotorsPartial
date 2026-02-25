public with sharing class RM_WorkStep_Trg_Handler extends TriggerHandler{
    public List<WorkStep> newRecordList{get;set;}
    public Map<Id, WorkStep> newRecordMap{get;set;}
    public List<WorkStep> oldRecordList{get;set;}
    public Map<Id, WorkStep> oldRecordMap{get;set;}

    RM_WorkStep_Service workStepService;

    public static Boolean skipValidarTrabajoSubtrabajoEnCurso = false;
    public static Boolean skipRegistrarActividadMecanico = false;
    public static Boolean skipActualizarModoTrabajo = false;
    public static Boolean skipActualizaSubtrabajos = false;

    public RM_WorkStep_Trg_Handler() {
        this.newRecordList = (List<WorkStep>) Trigger.New;
        this.newRecordMap = (Map<Id, WorkStep>) Trigger.newMap;
        this.oldRecordList = (List<WorkStep>) Trigger.Old;
        this.oldRecordMap = (Map<Id, WorkStep>) Trigger.oldMap; 
        workStepService = new RM_WorkStep_Service(newRecordList, oldRecordMap, newRecordMap);             
    }

    public override void afterInsert(){
    }

    public override void afterUpdate(){
        if (!skipActualizaSubtrabajos) {
            TriggerHandler.bypass('RM_WorkStep_Trg_Handler');
            workStepService.actualizaSubtrabajos();
            TriggerHandler.clearBypass('RM_WorkStep_Trg_Handler');
        }
        if (!skipRegistrarActividadMecanico) {
            workStepService.registrarActividadMecanico();
        }
        if (!skipActualizarModoTrabajo) {
            workStepService.actualizarModoTrabajo();
        }
    }

    public override void beforeUpdate(){
        // Check the flag before calling the function
        if (!skipValidarTrabajoSubtrabajoEnCurso) {
            workStepService.validarTrabajoSubtrabajoEnCurso();
        }
        workStepService.setearFechasInicioFin();
    }

}