@IsTest
public with sharing class RM_CT_GestionTareas_Ctrl_Test {
    @TestSetup
    static void setup() {
        RM_CT_TestDataFactory.createCaseWithWorkSteps();
    }

    @IsTest
    static void testAsignarMecanicoWorkOrder() {
        List<Case> cases = [
                            SELECT Id,
                                (
                                    SELECT Id
                                    FROM WorkOrders
                                )
                            FROM Case
                            LIMIT 1];
        WorkOrder woObj = cases[0].WorkOrders[0];

        List<Contact> mechanics = [SELECT Id FROM Contact WHERE RecordTypeId = :RM_CT_TestDataFactory.getMechanicRecordTypeId() LIMIT 2];
        
        Test.startTest();
        String mechanicId = (String) mechanics[0].Id;
        String mechanicId2 = (String) mechanics[1].Id;
        RM_CT_GestionTareas_Ctrl.asignarMechanico(woObj.Id, mechanicId);
        Test.stopTest();

        List<WorkStep> workSteps = [SELECT Id, RM_Mecanico__c, Status, Caso__c FROM WorkStep WHERE WorkOrderId = :woObj.Id LIMIT 1];
        for(WorkStep ws : workSteps){
            System.assertNotEquals(null, ws.RM_Mecanico__c);
        }
    }

    @IsTest
    static void testAsignarMecanicoTrabajo() {
        List<Case> cases = [
                            SELECT Id,
                                (
                                    SELECT Id
                                    FROM Tipos_de_Trabajo__r
                                )
                            FROM Case
                            LIMIT 1];
        tiposDeTrabajoCaso__c ttc = cases[0].Tipos_de_Trabajo__r[0];

        List<Contact> mechanics = [SELECT Id FROM Contact WHERE RecordTypeId = :RM_CT_TestDataFactory.getMechanicRecordTypeId() LIMIT 2];
        
        Test.startTest();
        String mechanicId = (String) mechanics[0].Id;
        String mechanicId2 = (String) mechanics[1].Id;
        RM_CT_GestionTareas_Ctrl.asignarMechanico(ttc.Id, mechanicId);
        Test.stopTest();

        List<WorkStep> workSteps = [SELECT Id, RM_Mecanico__c, Status, Caso__c FROM WorkStep WHERE Tipo_de_trabajo_del_caso__c = :ttc.Id LIMIT 1];
        for(WorkStep ws : workSteps){
            System.assertNotEquals(null, ws.RM_Mecanico__c);
        }
    }

    @IsTest
    static void testReasignarMecanicoTrabajo() {
        WorkStep workStep = [SELECT Id, RM_Mecanico__c, Status, Tipo_de_trabajo_del_caso__c FROM WorkStep WHERE RM_EsTrabajo__c = true LIMIT 1];

        List<Contact> mechanics = [SELECT Id FROM Contact WHERE RecordTypeId = :RM_CT_TestDataFactory.getMechanicRecordTypeId() LIMIT 2];

        String mechanicId = (String) mechanics[0].Id;
        String mechanicId2 = (String) mechanics[1].Id;
        RM_CT_GestionTareas_Ctrl.asignarMechanico(workStep.Tipo_de_trabajo_del_caso__c, mechanicId);

        Test.startTest();
            RM_CT_GestionTareas_Ctrl.reasignarMechanico(workStep.Id, mechanicId2);
        Test.stopTest();

        List<WorkStep> workSteps = [SELECT Id, RM_Mecanico__c, Status, Caso__c FROM WorkStep WHERE Tipo_de_trabajo_del_caso__c = :workStep.Tipo_de_trabajo_del_caso__c LIMIT 1];
        for(WorkStep ws : workSteps){
            System.assertEquals(mechanicId2, ws.RM_Mecanico__c);
        }
    }

    @IsTest
    static void testAsignarMecanicoSubTrabajo() {
        List<Case> cases = [
                            SELECT Id,
                                (
                                    SELECT Id,Paso_de_trabajo__c
                                    FROM Subtipos_de_trabajos_del_caso__r
                                )
                            FROM Case
                            LIMIT 1];
        Subtipo_de_trabajo_del_caso__c sttc = cases[0].Subtipos_de_trabajos_del_caso__r[0];

        List<Contact> mechanics = [SELECT Id FROM Contact WHERE RecordTypeId = :RM_CT_TestDataFactory.getMechanicRecordTypeId() LIMIT 2];
        
        Test.startTest();
        String mechanicId = (String) mechanics[0].Id;
        String mechanicId2 = (String) mechanics[1].Id;
        RM_CT_GestionTareas_Ctrl.asignarMechanico(sttc.Id, mechanicId);
        Test.stopTest();

        List<WorkStep> workSteps = [SELECT Id, RM_Mecanico__c, Status, Caso__c FROM WorkStep WHERE Id = :sttc.Id LIMIT 1];
        for(WorkStep ws : workSteps){
            System.assertNotEquals(null, ws.RM_Mecanico__c);
        }
    }

    @IsTest
    static void testIniciarTrabajo() {
        List<Case> cases = [
                            SELECT Id,
                                (
                                    SELECT Id,Paso_de_trabajo__c
                                    FROM Tipos_de_Trabajo__r
                                )
                            FROM Case
                            LIMIT 1];

        tiposDeTrabajoCaso__c ttc = cases[0].Tipos_de_Trabajo__r[0];

        Contact mechanic = [SELECT Id FROM Contact WHERE RecordTypeId = :RM_CT_TestDataFactory.getMechanicRecordTypeId() LIMIT 1];
    
        Test.startTest();
        RM_CT_GestionTareas_Ctrl.asignarMechanico(ttc.Id, mechanic.Id);
        RM_CT_GestionTareas_Ctrl.updateWorkStepStatus(ttc.Paso_de_trabajo__c, 'En curso');
        Test.stopTest();

       for (WorkStep ws : [SELECT Id,Status FROM WorkStep WHERE Tipo_de_trabajo_del_caso__c = :ttc.Id LIMIT 1]){
            System.assertEquals('En curso', ws.Status);
       }
    }

    @IsTest
    static void testIniciarSubTrabajo() {
        List<Case> cases = [
                            SELECT Id,
                                (
                                    SELECT Id,Paso_de_trabajo__c
                                    FROM Subtipos_de_trabajos_del_caso__r
                                )
                            FROM Case
                            LIMIT 1];
        Subtipo_de_trabajo_del_caso__c sttc = cases[0].Subtipos_de_trabajos_del_caso__r[0];

        Contact mechanic = [SELECT Id FROM Contact WHERE RecordTypeId = :RM_CT_TestDataFactory.getMechanicRecordTypeId() LIMIT 1];
    
        Test.startTest();
        RM_CT_GestionTareas_Ctrl.asignarMechanico(sttc.Id, mechanic.Id);
        RM_CT_GestionTareas_Ctrl.updateWorkStepStatus(sttc.Paso_de_trabajo__c, 'En curso');
        Test.stopTest();

       for (WorkStep ws : [SELECT Id,Status FROM WorkStep WHERE Id = :sttc.Paso_de_trabajo__c LIMIT 1]){
            System.assertEquals('En curso', ws.Status);
       }
    }

    @IsTest
    static void testReprocesarTrabajo() {
        Case c = [SELECT Id,CaseNumber FROM Case LIMIT 1];
        Contact mechanic = [SELECT Id FROM Contact WHERE RecordTypeId = :RM_CT_TestDataFactory.getMechanicRecordTypeId() LIMIT 1];
        String caseId = (String) c.Id;
        tiposDeTrabajoCaso__c ttc = [SELECT Id, Caso__c,(SELECT Id FROM Subtipos_de_trabajos_del_caso__r) FROM tiposDeTrabajoCaso__c WHERE Caso__c = :c.Id LIMIT 1];
        String ttcId = (String) ttc.Id;
        String mechanicId = (String) mechanic.Id;
        
        Test.startTest();
        Map<String,Object> response = RM_CT_GestionTareas_Ctrl.reprocesarTrabajoYSubtrabajos(ttcId,null);
        Test.stopTest();

        List<tiposDeTrabajoCaso__c> newTTCList = [SELECT Id, Caso__c FROM tiposDeTrabajoCaso__c WHERE Caso__c = :c.Id AND RM_TipoTrabajoCaso__c = :ttc.Id LIMIT 1];
        System.assertEquals(1, newTTCList.size());
    }

    @IsTest
    static void testReprocesarSubtrabajo() {
        Case c = [SELECT Id,CaseNumber FROM Case LIMIT 1];
        Contact mechanic = [SELECT Id FROM Contact WHERE RecordTypeId = :RM_CT_TestDataFactory.getMechanicRecordTypeId() LIMIT 1];
        String caseId = (String) c.Id;
        tiposDeTrabajoCaso__c ttc = [SELECT Id, Caso__c,(SELECT Id,Paso_de_trabajo__c FROM Subtipos_de_trabajos_del_caso__r) FROM tiposDeTrabajoCaso__c WHERE Caso__c = :c.Id LIMIT 1];
        String sttcId = (String) ttc.Subtipos_de_trabajos_del_caso__r[0].Id;
        String ttcId = (String) ttc.Id;
        String mechanicId = (String) mechanic.Id;

        Test.startTest();
        Map<String,Object> response = RM_CT_GestionTareas_Ctrl.reprocesarTrabajoYSubtrabajos(ttcId,sttcId);
        Test.stopTest();

        List<Subtipo_de_trabajo_del_caso__c> newSTTCList = [SELECT Id FROM Subtipo_de_trabajo_del_caso__c WHERE Caso__c = :c.Id AND RM_SubtipoTrabajoCaso__c = :sttcId LIMIT 1];
        System.assertEquals(1, newSTTCList.size());
    }
    
    @IsTest
    static void testEliminarTrabajo() {
        Case c = [SELECT Id,CaseNumber FROM Case LIMIT 1];
        tiposDeTrabajoCaso__c ttc = [SELECT Id,Paso_de_trabajo__c,(SELECT Id,Paso_de_trabajo__c FROM Subtipos_de_trabajos_del_caso__r) FROM tiposDeTrabajoCaso__c WHERE Caso__c = :c.Id LIMIT 1];
        System.debug(ttc.Subtipos_de_trabajos_del_caso__r);

        RM_CT_GestionTareas_Ctrl.reprocesarTrabajoYSubtrabajos(ttc.Id,null);

        ttc = [SELECT Id,Paso_de_trabajo__c,(SELECT Id,Paso_de_trabajo__c FROM Subtipos_de_trabajos_del_caso__r) FROM tiposDeTrabajoCaso__c WHERE Id != :ttc.Id AND Caso__c = :c.Id AND RM_TipoTrabajoCaso__c != null LIMIT 1];
            
        System.debug(ttc.Subtipos_de_trabajos_del_caso__r);

            Set<Id> workStepIds = new Set<Id>();
            workStepIds.add((Id) ttc.Paso_de_trabajo__c);
            //extract all Paso_de_trabajo__c from ttc
            for(Subtipo_de_trabajo_del_caso__c sttc : ttc.Subtipos_de_trabajos_del_caso__r) {
                workStepIds.add((Id) sttc.Paso_de_trabajo__c);
            }
            String ttcId = (String) ttc.Id;

        Test.startTest();
            RM_CT_GestionTareas_Ctrl.deleteTrabajo(ttcId);
        Test.stopTest();

        List<tiposDeTrabajoCaso__c> deletedTTCs = [SELECT Id FROM tiposDeTrabajoCaso__c WHERE Id = :ttc.Id LIMIT 1];

        // Assert if all work steps were deleted
        System.assertEquals(0, deletedTTCs.size());

        List<WorkStep> deletedWorkSteps = [SELECT Id FROM WorkStep WHERE Id IN :workStepIds];

        // Assert if all work steps were deleted
        System.assertEquals(0, deletedWorkSteps.size());
    }


    @IsTest
    static void testEliminarSubTrabajo() {
        Case c = [SELECT Id,CaseNumber FROM Case LIMIT 1];
        tiposDeTrabajoCaso__c ttc = [SELECT Id,Paso_de_trabajo__c,(SELECT Id,Paso_de_trabajo__c FROM Subtipos_de_trabajos_del_caso__r) FROM tiposDeTrabajoCaso__c WHERE Caso__c = :c.Id LIMIT 1];
        System.debug(ttc.Subtipos_de_trabajos_del_caso__r);

        RM_CT_GestionTareas_Ctrl.reprocesarTrabajoYSubtrabajos(ttc.Id,null);

        ttc = [SELECT Id,Paso_de_trabajo__c,(SELECT Id,Paso_de_trabajo__c FROM Subtipos_de_trabajos_del_caso__r) FROM tiposDeTrabajoCaso__c WHERE Id != :ttc.Id AND Caso__c = :c.Id AND RM_TipoTrabajoCaso__c != null LIMIT 1];
        String sttcId = (String) ttc.Subtipos_de_trabajos_del_caso__r[0].Id;  
        Test.startTest();
            RM_CT_GestionTareas_Ctrl.deleteSubtrabajo(sttcId);
        Test.stopTest();
    }

    @IsTest
    static void testSearchCasesLookUp() {
        Case c = [SELECT Id,CaseNumber FROM Case LIMIT 1];
        //extract the first 3 characters of the case number
        String searchTerm = c.CaseNumber.substring(0,3);
        
        Test.startTest();
        List<LookupSearchResult> results = RM_CT_GestionTareas_Ctrl.searchCases(searchTerm, null, null, 'Caso', 'Caso', 'case');
        Test.stopTest();
    }

    @IsTest
    static void testGetData() {
        WorkStep ws = [SELECT Id,Caso__c,Caso__r.CaseNumber,Caso__r.Service_Territory1__c FROM WorkStep LIMIT 1];
        RM_CT_GestionTareas_Ctrl.getData(ws.Caso__r.CaseNumber, ws.Caso__c, ws.Caso__r.Service_Territory1__c, 1);
    }

    @IsTest
    static void testGetTerritories() {
        RM_CT_Service.getAssignedTerritoryIds();
    }
}