@IsTest
public class RM_ActividadMecanico_Trg_Handler_Test {

    @TestSetup
    static void setup() {
        RM_CT_TestDataFactory.createCaseWithWorkSteps();
    }

    @IsTest
    static void testTerminarActividadActual() {
        Contact mechanic = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'Contacto_de_Taller' LIMIT 1];
        RM_ActividadMecanico__c act1 = RM_CT_TestDataFactory.createActividadMecanico(null,null,null,null,mechanic,'Capacitación',true);
        RM_ActividadMecanico__c act2 = RM_CT_TestDataFactory.createActividadMecanico(null,null,null,null,mechanic,'Elaboración de Presupuesto',true);
        List<RM_ActividadMecanico__c> actsRunning = [SELECT Id,RM_FechaHoraFin__c FROM RM_ActividadMecanico__c WHERE Id = :act2.Id LIMIT 1];
        List<RM_ActividadMecanico__c> actsCompleted = [SELECT Id,RM_FechaHoraFin__c FROM RM_ActividadMecanico__c WHERE Id = :act1.Id LIMIT 1];
        
        System.assert(actsRunning.size() > 0);
        System.assert(actsCompleted.size() > 0);
        System.assertEquals(null,actsRunning[0].RM_FechaHoraFin__c);
        System.assertNotEquals(null,actsCompleted[0].RM_FechaHoraFin__c);
    }

    @IsTest
    static void testPausarSubtrabajoEnCurso() {
        WorkStep subtrabajo = [SELECT Id,RM_Mecanico__c,Status FROM WorkStep WHERE Id IN (SELECT Paso_de_trabajo__c FROM Subtipo_de_trabajo_del_caso__c) AND RM_EsTrabajo__c = FALSE LIMIT 1];
        
        Contact mechanic = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'Contacto_de_Taller' LIMIT 1];

        subtrabajo.RM_Mecanico__c = mechanic.Id;
        UPDATE subtrabajo;

        subtrabajo.Status = 'En curso';
        UPDATE subtrabajo;

        List<RM_ActividadMecanico__c> actividades = [SELECT Id,RM_Paso__c,RM_FechaHoraFin__c FROM RM_ActividadMecanico__c WHERE RM_Mecanico__c = :subtrabajo.RM_Mecanico__c AND RM_Paso__c = :subtrabajo.Id];
        System.assert(actividades.size() == 1);
        System.assert(actividades[0].RM_Paso__c == subtrabajo.Id);
        System.assert(actividades[0].RM_FechaHoraFin__c == null);

        Test.startTest();
            RM_ActividadMecanico__c act = RM_CT_TestDataFactory.createActividadMecanico(null,null,null,null,mechanic,'Capacitación',true);
        Test.stopTest();

        List<RM_ActividadMecanico__c> actividadesAnteriores = [SELECT Id,RM_Paso__c,RM_Paso__r.Status,RM_FechaHoraFin__c FROM RM_ActividadMecanico__c WHERE Id = :actividades[0].Id LIMIT 1];
        System.assert(actividadesAnteriores.size() > 0);
        System.assertNotEquals(null,actividadesAnteriores[0].RM_FechaHoraFin__c);
        System.assertEquals('En pausa',actividadesAnteriores[0].RM_Paso__r.Status);
    }


    @IsTest
    static void testPausarTrabajoEnCurso() {
        WorkStep trabajo = [SELECT Id,RM_Mecanico__c,Status,Tipo_de_trabajo_del_caso__c FROM WorkStep WHERE Id IN (SELECT Paso_de_trabajo__c FROM tiposDeTrabajoCaso__c) LIMIT 1];
        
        Contact mechanic = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'Contacto_de_Taller' LIMIT 1];

        trabajo.RM_Mecanico__c = mechanic.Id;
        UPDATE trabajo;

        trabajo.Status = 'En curso';
        UPDATE trabajo;

        List<RM_ActividadMecanico__c> actividades = [SELECT Id,RM_Paso__c,RM_FechaHoraFin__c FROM RM_ActividadMecanico__c WHERE RM_Mecanico__c = :trabajo.RM_Mecanico__c AND RM_Paso__c = :trabajo.Id];
        System.assert(actividades.size() == 1);
        System.assert(actividades[0].RM_Paso__c == trabajo.Id);
        System.assert(actividades[0].RM_FechaHoraFin__c == null);

        Test.startTest();
            RM_ActividadMecanico__c act = RM_CT_TestDataFactory.createActividadMecanico(null,null,null,null,mechanic,'Capacitación',true);
        Test.stopTest();

        List<RM_ActividadMecanico__c> actividadesAnteriores = [SELECT Id,RM_Paso__c,RM_Paso__r.Status,RM_Paso__r.Tipo_de_trabajo_del_caso__c,RM_FechaHoraFin__c FROM RM_ActividadMecanico__c WHERE Id = :actividades[0].Id LIMIT 1];
        System.assert(actividadesAnteriores.size() > 0);
        System.assertNotEquals(null,actividadesAnteriores[0].RM_FechaHoraFin__c);
        System.assertEquals('En pausa',actividadesAnteriores[0].RM_Paso__r.Status);

        List<WorkStep> workSteps = [SELECT Id,Status FROM WorkStep WHERE Tipo_de_trabajo_del_caso__c = :trabajo.Tipo_de_trabajo_del_caso__c AND RM_EsTrabajo__c = FALSE];
        for (WorkStep ws : workSteps) {
            System.assert(ws.Status == 'En pausa');
        }
        
    }
}