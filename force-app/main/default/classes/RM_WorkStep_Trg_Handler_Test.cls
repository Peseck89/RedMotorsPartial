@IsTest
public class RM_WorkStep_Trg_Handler_Test {

    @TestSetup
    static void setup() {
        RM_CT_TestDataFactory.createCaseWithWorkSteps();
    }

    @IsTest
    static void testValidarFechasTrabajoProcesado() {
        WorkStep workStep = [SELECT Id,Caso__c,Caso__r.Service_Territory1__c,WorkOrderId,Status,RM_Mecanico__c,Tipo_de_trabajo_del_caso__c FROM WorkStep WHERE RM_EsTrabajo__c = FALSE LIMIT 1];
        Contact mechanic = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'Contacto_de_Taller' LIMIT 1];
        
        workStep.RM_Mecanico__c = mechanic.Id;
        UPDATE workStep;

        Test.startTest();
            workStep.Status = 'En curso';
            UPDATE workStep;

            workStep.Status = 'Completada';
            UPDATE workStep;
        Test.stopTest();
        
        WorkStep actividadCompletada = [SELECT Id,StartTime,EndTime FROM WorkStep WHERE Id = :workStep.Id LIMIT 1];
        Assert.areNotEqual(null, actividadCompletada.StartTime, 'Se esperaba que la tarea tuviera una fecha de inicio');
        Assert.areNotEqual(null, actividadCompletada.EndTime, 'Se esperaba que la tarea tuviera una fecha fin');
    }

    @IsTest
    static void testTrabajoEnCurso() {
        WorkStep workStep = [SELECT Id,RM_Mecanico__c,Tipo_de_trabajo_del_caso__c FROM WorkStep WHERE RM_EsTrabajo__c = TRUE LIMIT 1];
        Contact mechanic = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'Contacto_de_Taller' LIMIT 1];
        workStep.RM_Mecanico__c = mechanic.Id;
        UPDATE workStep;

        Test.startTest();
        workStep.Status = 'En curso';
        UPDATE workStep;
        Test.stopTest();

        for(WorkStep ws : [SELECT Id,Status,RM_Mecanico__c FROM WorkStep WHERE Tipo_de_trabajo_del_caso__c = :workStep.Tipo_de_trabajo_del_caso__c ]){
            Assert.isTrue(ws.Status == 'En curso', 'Se esperaba que el trabajo y subtrabajos estuvieran en curso');
        }

        List<RM_ActividadMecanico__c> acts = [SELECT Id FROM RM_ActividadMecanico__c WHERE RM_Paso__c = :workStep.Id AND RM_Tipo__c = 'Tarea En Curso' AND RM_FechaHoraInicio__c != null AND RM_FechaHoraFin__c = null];
        System.assertEquals(1, acts.size());

        List<RM_ActividadMecanico__c> allActivities = [SELECT Id,RM_Tipo__c FROM RM_ActividadMecanico__c];
        System.assertEquals(1, allActivities.size());
    }

    @IsTest
    static void testTrabajoEnPausa() {
        WorkStep workStep = [SELECT Id,RM_Mecanico__c,Tipo_de_trabajo_del_caso__c FROM WorkStep WHERE RM_EsTrabajo__c = TRUE LIMIT 1];
        Contact mechanic = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'Contacto_de_Taller' LIMIT 1];
        workStep.RM_Mecanico__c = mechanic.Id;
        UPDATE workStep;

        Test.startTest();
            workStep.Status = 'En curso';
            UPDATE workStep;
            
            workStep.Status = 'En pausa';
            UPDATE workStep;
        Test.stopTest();

        for(WorkStep ws : [SELECT Id,Status,RM_Mecanico__c FROM WorkStep WHERE Tipo_de_trabajo_del_caso__c = :workStep.Tipo_de_trabajo_del_caso__c ]){
            Assert.isTrue(ws.Status == 'En pausa', 'Se esperaba que el trabajo y los subtrabajos estuvieran en pausa');
        }

        List<RM_ActividadMecanico__c> actsInPause = [SELECT Id,RM_Tipo__c FROM RM_ActividadMecanico__c WHERE RM_Paso__c = :workStep.Id AND RM_Tipo__c = 'Tarea En Pausa' AND RM_FechaHoraInicio__c != null AND RM_FechaHoraFin__c = null];
        System.assertEquals(1, actsInPause.size());

        List<RM_ActividadMecanico__c> actsInProgress = [SELECT Id,RM_Tipo__c FROM RM_ActividadMecanico__c WHERE RM_Paso__c = :workStep.Id AND RM_Tipo__c = 'Tarea En Curso' AND RM_FechaHoraInicio__c != null AND RM_FechaHoraFin__c != null];
        System.assertEquals(1, actsInProgress.size());

        List<RM_ActividadMecanico__c> allActivities = [SELECT Id,RM_Tipo__c FROM RM_ActividadMecanico__c];
        System.assertEquals(2, allActivities.size());
    }

    @IsTest
    static void testTrabajoReanudar() {
        WorkStep workStep = [SELECT Id,RM_Mecanico__c,Tipo_de_trabajo_del_caso__c FROM WorkStep WHERE RM_EsTrabajo__c = TRUE LIMIT 1];
        Contact mechanic = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'Contacto_de_Taller' LIMIT 1];
        
        workStep.RM_Mecanico__c = mechanic.Id;
        UPDATE workStep;

        Test.startTest();
            workStep.Status = 'En curso';
            UPDATE workStep;

            workStep.Status = 'En pausa';
            UPDATE workStep;

            workStep.Status = 'En curso';
            UPDATE workStep;
        Test.stopTest();

        for(WorkStep ws : [SELECT Id,Status,RM_Mecanico__c FROM WorkStep WHERE Tipo_de_trabajo_del_caso__c = :workStep.Tipo_de_trabajo_del_caso__c ]){
            Assert.isTrue(ws.Status == 'En curso', 'Se esperaba que el trabajo y subtrabajo estuvieran en curso');
        }

        List<RM_ActividadMecanico__c> oldActsInProgress = [SELECT Id,RM_Tipo__c FROM RM_ActividadMecanico__c WHERE RM_Paso__c = :workStep.Id AND RM_Tipo__c = 'Tarea En Curso' AND RM_FechaHoraInicio__c != null AND RM_FechaHoraFin__c != null];
        System.assertEquals(1, oldActsInProgress.size());

        List<RM_ActividadMecanico__c> actsInPause = [SELECT Id,RM_Tipo__c FROM RM_ActividadMecanico__c WHERE RM_Paso__c = :workStep.Id AND RM_Tipo__c = 'Tarea En Pausa' AND RM_FechaHoraInicio__c != null AND RM_FechaHoraFin__c != null];
        System.assertEquals(1, actsInPause.size());

        List<RM_ActividadMecanico__c> actsInProgress = [SELECT Id,RM_Tipo__c FROM RM_ActividadMecanico__c WHERE RM_Paso__c = :workStep.Id AND RM_Tipo__c = 'Tarea En Curso' AND RM_FechaHoraInicio__c != null AND RM_FechaHoraFin__c = null];
        System.assertEquals(1, actsInProgress.size());

        List<RM_ActividadMecanico__c> allActivities = [SELECT Id FROM RM_ActividadMecanico__c];
        System.assertEquals(3, allActivities.size());
    }

    @IsTest
    static void testTrabajoCompletado() {
        WorkStep workStep = [SELECT Id,RM_Mecanico__c,Tipo_de_trabajo_del_caso__c FROM WorkStep WHERE RM_EsTrabajo__c = TRUE LIMIT 1];
        Contact mechanic = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'Contacto_de_Taller' LIMIT 1];
        
        workStep.RM_Mecanico__c = mechanic.Id;
        UPDATE workStep;

        Test.startTest();
            workStep.Status = 'En curso';
            UPDATE workStep;

            workStep.Status = 'Completada';
            UPDATE workStep;
        Test.stopTest();

        for(WorkStep ws : [SELECT Id,Status,RM_Mecanico__c FROM WorkStep WHERE Tipo_de_trabajo_del_caso__c = :workStep.Tipo_de_trabajo_del_caso__c ]){
            Assert.isTrue(ws.Status == 'Completada', 'Se esperaba que el trabajo y subtrabajo estuvieran Completada');
        }

        List<RM_ActividadMecanico__c> oldActsInProgress = [SELECT Id,RM_Tipo__c FROM RM_ActividadMecanico__c WHERE RM_Paso__c = :workStep.Id AND RM_Tipo__c = 'Tarea En Curso' AND RM_FechaHoraInicio__c != null AND RM_FechaHoraFin__c != null];
        System.assertEquals(1, oldActsInProgress.size());


        List<RM_ActividadMecanico__c> actsCompleted = [SELECT Id,RM_Tipo__c FROM RM_ActividadMecanico__c WHERE RM_Paso__c = :workStep.Id AND RM_Tipo__c = 'Tarea Completada' AND RM_FechaHoraInicio__c != null AND RM_FechaHoraFin__c = null];
        System.assertEquals(1, actsCompleted.size());

        List<RM_ActividadMecanico__c> allActivities = [SELECT Id FROM RM_ActividadMecanico__c];
        System.assertEquals(2, allActivities.size());
    }

    @IsTest
    static void testResetearStartTimeTarea() {
        List<WorkStep> workSteps = [SELECT Id,Caso__c,Caso__r.Service_Territory1__c,WorkOrderId,Status,RM_Mecanico__c FROM WorkStep LIMIT 1];
        List<Contact> mechanics = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'Contacto_de_Taller' LIMIT 1];
        
        Test.startTest();
        
            workSteps[0].RM_Mecanico__c = mechanics[0].Id;
            UPDATE workSteps;

            workSteps[0].Status = 'En curso';
            UPDATE workSteps;

        Test.stopTest();

        List<WorkStep> workStepUpdated = [SELECT Id,Status,StartTime FROM WorkStep WHERE Id = :workSteps[0].Id];

        Assert.areNotEqual(null, workStepUpdated[0].StartTime, 'Se esperaba que la tarea tuviera una fecha de inicio');

        workSteps[0].Status = 'Nueva';
        UPDATE workSteps;

        workStepUpdated = [SELECT Id,Status,StartTime FROM WorkStep WHERE Id = :workSteps[0].Id];

        Assert.areEqual(null, workStepUpdated[0].StartTime, 'Se esperaba que la tarea no tuviera una fecha de inicio');

    }

    @IsTest
    static void testActualizarModoTrabajoTareaPadre() {
        WorkStep workStep = [SELECT Id,Tipo_de_trabajo_del_caso__c,Status,RM_Mecanico__c FROM WorkStep WHERE RM_EsTrabajo__c = TRUE LIMIT 1];
        Contact mechanic = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'Contacto_de_Taller' LIMIT 1];
        workStep.RM_Mecanico__c = mechanic.Id;
        UPDATE workStep;

        Test.startTest();
            workStep.Status = 'En curso';
            UPDATE workStep;
        Test.stopTest();

        List<tiposDeTrabajoCaso__c> ttcs = [SELECT Id,RM_ModoTrabajo__c FROM tiposDeTrabajoCaso__c WHERE Id = :workStep.Tipo_de_trabajo_del_caso__c];

        Assert.isTrue(ttcs.size() > 0 && ttcs[0].RM_ModoTrabajo__c == 'Tarea padre', 'Se esperaba que el modo de trabajo fuera Tarea padre');
    }

    @IsTest
    static void testActualizarModoTrabajoTareaHija() {
        WorkStep workStep = [SELECT Id,Tipo_de_trabajo_del_caso__c,Status,RM_Mecanico__c FROM WorkStep WHERE RM_EsTrabajo__c = FALSE LIMIT 1];
        Contact mechanic = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'Contacto_de_Taller' LIMIT 1];
        workStep.RM_Mecanico__c = mechanic.Id;
        UPDATE workStep;

        Test.startTest();
            workStep.Status = 'En curso';
            UPDATE workStep;
        Test.stopTest();

        List<tiposDeTrabajoCaso__c> ttcs = [SELECT Id,RM_ModoTrabajo__c FROM tiposDeTrabajoCaso__c WHERE Id = :workStep.Tipo_de_trabajo_del_caso__c];

        Assert.isTrue(ttcs.size() > 0 && ttcs[0].RM_ModoTrabajo__c == 'Tarea hija', 'Se esperaba que el modo de trabajo fuera Tarea hija');
    }

    @IsTest
    static void testResetearTipoTrabajoCaso() {
        List<WorkStep> workSteps = [SELECT Id,Tipo_de_trabajo_del_caso__c,Status,RM_Mecanico__c FROM WorkStep WHERE RM_EsTrabajo__c = FALSE LIMIT 2];
        List<Contact> mechanics = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'Contacto_de_Taller' LIMIT 1];

        for(WorkStep ws : workSteps){
            ws.RM_Mecanico__c = mechanics[0].Id;
        }
        UPDATE workSteps;

        Test.startTest();
            workSteps[0].Status = 'En curso';
            UPDATE workSteps;
        Test.stopTest();

        List<tiposDeTrabajoCaso__c> ttcs = [SELECT Id,RM_ModoTrabajo__c FROM tiposDeTrabajoCaso__c WHERE Id = :workSteps[0].Tipo_de_trabajo_del_caso__c];
        Assert.isTrue(ttcs.size() > 0 && ttcs[0].RM_ModoTrabajo__c != null, 'Se esperaba que el modo de trabajo no estuviera vacío');
    }

    @IsTest
    static void testTrabajoAsignacionMecanico() {
        WorkStep workStep = [SELECT Id,RM_Mecanico__c,Tipo_de_trabajo_del_caso__c FROM WorkStep WHERE RM_EsTrabajo__c = TRUE LIMIT 1];
        Contact mechanic = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'Contacto_de_Taller' LIMIT 1];
        workStep.RM_Mecanico__c = mechanic.Id;

        Test.startTest();
        UPDATE workStep;
        Test.stopTest();

        for(WorkStep ws : [SELECT Id,RM_Mecanico__c FROM WorkStep WHERE Tipo_de_trabajo_del_caso__c = :workStep.Tipo_de_trabajo_del_caso__c ]){
            Assert.isTrue(ws.RM_Mecanico__c == mechanic.Id, 'Se esperaba que el trabajo tuviera el mismo mecánico que el subtrabajo');
        }
    }

    @IsTest
    static void testValidarSubtrabajoEnCurso() {
        List<WorkStep> workSteps = [SELECT Id,RM_Mecanico__c FROM WorkStep WHERE RM_EsTrabajo__c = TRUE LIMIT 2];
        List<Contact> mechanics = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'Contacto_de_Taller' LIMIT 1];
        
        //Asignar Subtrabajos al mismo mecánico
        for(WorkStep ws : workSteps){
            ws.RM_Mecanico__c = mechanics[0].Id;
        }
        UPDATE workSteps;

        //Poner un subtrabajo en curso
        workSteps[0].Status = 'En curso';
        UPDATE workSteps[0];
       
        try {
            workSteps[1].Status = 'En curso';
            UPDATE workSteps;        
        } catch (DmlException e) {
            System.assertEquals(true, e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
            System.assertEquals(true, e.getMessage().contains('El mecánico ya tiene una tarea "En curso".'));
        }
    }

    @IsTest
    static void testIniciarSubtrabajoCreaActividad() {
        WorkStep workStep = [SELECT Id,RM_Mecanico__c FROM WorkStep WHERE RM_EsTrabajo__c = FALSE LIMIT 1];
        Contact mechanic = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'Contacto_de_Taller' LIMIT 1];
        
        workStep.RM_Mecanico__c = mechanic.Id;
        UPDATE workStep;

        Test.startTest();
            workStep.Status = 'En curso';
            UPDATE workStep;
        Test.stopTest();

        List<RM_ActividadMecanico__c> acts = [SELECT Id,RM_Tipo__c FROM RM_ActividadMecanico__c WHERE RM_Paso__c = :workStep.Id AND RM_Tipo__c = 'Tarea En Curso' AND RM_FechaHoraInicio__c != null AND RM_FechaHoraFin__c = null];
        System.assertEquals(1, acts.size());

        List<RM_ActividadMecanico__c> allActivities = [SELECT Id,RM_Tipo__c FROM RM_ActividadMecanico__c];
        System.assertEquals(1, allActivities.size());
    }

    @IsTest
    static void testPausarSubtrabajoCreaActividad() {
        WorkStep workStep = [SELECT Id,RM_Mecanico__c FROM WorkStep WHERE RM_EsTrabajo__c = FALSE LIMIT 1];
        Contact mechanic = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'Contacto_de_Taller' LIMIT 1];
        
        workStep.RM_Mecanico__c = mechanic.Id;
        UPDATE workStep;

        Test.startTest();
            workStep.Status = 'En curso';
            UPDATE workStep;

            workStep.Status = 'En pausa';
            UPDATE workStep;
        Test.stopTest();

        List<RM_ActividadMecanico__c> actsInPause = [SELECT Id,RM_Tipo__c FROM RM_ActividadMecanico__c WHERE RM_Paso__c = :workStep.Id AND RM_Tipo__c = 'Tarea En Pausa' AND RM_FechaHoraInicio__c != null AND RM_FechaHoraFin__c = null];
        System.assertEquals(1, actsInPause.size());

        List<RM_ActividadMecanico__c> actsInProgress = [SELECT Id,RM_Tipo__c FROM RM_ActividadMecanico__c WHERE RM_Paso__c = :workStep.Id AND RM_Tipo__c = 'Tarea En Curso' AND RM_FechaHoraInicio__c != null AND RM_FechaHoraFin__c != null];
        System.assertEquals(1, actsInProgress.size());

        List<RM_ActividadMecanico__c> allActivities = [SELECT Id,RM_Tipo__c FROM RM_ActividadMecanico__c];
        System.assertEquals(2, allActivities.size());
    }

    @IsTest
    static void testReanudarSubtrabajoCreaActividad() {
        WorkStep workStep = [SELECT Id,RM_Mecanico__c FROM WorkStep WHERE RM_EsTrabajo__c = FALSE LIMIT 1];
        Contact mechanic = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'Contacto_de_Taller' LIMIT 1];
        
        workStep.RM_Mecanico__c = mechanic.Id;
        UPDATE workStep;

        Test.startTest();
            workStep.Status = 'En curso';
            UPDATE workStep;

            workStep.Status = 'En pausa';
            UPDATE workStep;

            workStep.Status = 'En curso';
            UPDATE workStep;
        Test.stopTest();

        List<RM_ActividadMecanico__c> oldActsInProgress = [SELECT Id,RM_Tipo__c FROM RM_ActividadMecanico__c WHERE RM_Paso__c = :workStep.Id AND RM_Tipo__c = 'Tarea En Curso' AND RM_FechaHoraInicio__c != null AND RM_FechaHoraFin__c != null];
        System.assertEquals(1, oldActsInProgress.size());

        List<RM_ActividadMecanico__c> actsInPause = [SELECT Id,RM_Tipo__c FROM RM_ActividadMecanico__c WHERE RM_Paso__c = :workStep.Id AND RM_Tipo__c = 'Tarea En Pausa' AND RM_FechaHoraInicio__c != null AND RM_FechaHoraFin__c != null];
        System.assertEquals(1, actsInPause.size());

        List<RM_ActividadMecanico__c> actsInProgress = [SELECT Id,RM_Tipo__c FROM RM_ActividadMecanico__c WHERE RM_Paso__c = :workStep.Id AND RM_Tipo__c = 'Tarea En Curso' AND RM_FechaHoraInicio__c != null AND RM_FechaHoraFin__c = null];
        System.assertEquals(1, actsInProgress.size());

        List<RM_ActividadMecanico__c> allActivities = [SELECT Id FROM RM_ActividadMecanico__c];
        System.assertEquals(3, allActivities.size());
    }

    @IsTest
    static void testEstatusTrabajos() {
        Case caso = [SELECT Id,(SELECT Id,Status,RM_EsTrabajo__c,RM_Mecanico__c,Tipo_de_trabajo_del_caso__c FROM Subtipos_de_trabajos1__r) FROM Case LIMIT 1];
        Contact mechanic = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'Contacto_de_Taller' LIMIT 1];
        
        for(WorkStep ws : caso.Subtipos_de_trabajos1__r){
            ws.RM_Mecanico__c = mechanic.Id;
        }
        UPDATE caso.Subtipos_de_trabajos1__r;

        Test.startTest();
        Id parentWorkStepId;
        for(WorkStep ws : caso.Subtipos_de_trabajos1__r){
            if (!ws.RM_EsTrabajo__c) {                
                ws.Status = 'En curso';
                UPDATE ws;
                ws.Status = 'Completada';
                UPDATE ws;
            }else{
                parentWorkStepId = ws.Id;
            }
        }
        Test.stopTest();

        WorkStep parentWorkStep = [SELECT Id,Status FROM WorkStep WHERE Id = :parentWorkStepId LIMIT 1];
        Assert.isTrue(parentWorkStep.Status == 'Completada', 'Se esperaba que el estatus del trabajo fuera Completada');
    }
}