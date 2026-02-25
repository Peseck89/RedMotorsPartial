@IsTest
public with sharing class RM_CT_Gestion_Tareas_Ctrl_Test {
    @TestSetup
    static void setup() {
        RM_CT_TestDataFactory.createCaseWithWorkSteps();

        Case c = [SELECT Id,CaseNumber FROM Case LIMIT 1];
        WorkOrder wo = [SELECT Id FROM WorkOrder WHERE CaseId = :c.Id LIMIT 1];
        ServiceTerritory t = [SELECT Id FROM ServiceTerritory LIMIT 1];
        String territoryId = null;
        Integer limitSize = 10;
        Integer offsetSize = 0;

        tiposDeTrabajoCaso__c trabajo1 = RM_CT_TestDataFactory.createTipoTrabajoCaso(c,null,t,null,true);
        Subtipo_de_trabajo_del_caso__c subtrabajo1 = RM_CT_TestDataFactory.createSubTipoTrabajoCaso('mtto 1',c,trabajo1,wo,true);
        Subtipo_de_trabajo_del_caso__c subtrabajo2 = RM_CT_TestDataFactory.createSubTipoTrabajoCaso('mtto 2',c,trabajo1,wo,true);
        Subtipo_de_trabajo_del_caso__c subtrabajo3 = RM_CT_TestDataFactory.createSubTipoTrabajoCaso('mtto 3',c,trabajo1,wo,true);
    }

    @IsTest
    static void testGetCases() {
        Case c = [SELECT Id,CaseNumber FROM Case LIMIT 1];
        String caseId = (String) c.Id;
        List<RM_CaseWrapper> caseWrappersMap = RM_CT_Gestion_Tareas_Ctrl.getData(c.CaseNumber, caseId, null, 0);
    }

    @IsTest
    static void testAsignarReasinarMecanico() {
        WorkStep ws = [SELECT Id, Mec_nico_asignado__c, Status, Caso__c FROM WorkStep LIMIT 1];
        List<Contact> mechanics = [SELECT Id FROM Contact WHERE RecordTypeId = :RM_CT_TestDataFactory.getMechanicRecordTypeId() LIMIT 2];
        
        Test.startTest();
        String workStepId = (String) ws.Id;
        String mechanicId = (String) mechanics[0].Id;
        String mechanicId2 = (String) mechanics[1].Id;
        RM_CT_Gestion_Tareas_Ctrl.asignarMechanico(workStepId, mechanicId);
        Test.stopTest();

        ws = [SELECT Id, Mec_nico_asignado__c, Status, Caso__c FROM WorkStep WHERE Id = :ws.Id LIMIT 1];
        System.assertNotEquals(null, ws.Mec_nico_asignado__c);
        RM_CT_Gestion_Tareas_Ctrl.reasignarMechanico(workStepId, mechanicId2);
    }

    @IsTest
    static void testIniciar() {
        WorkStep ws = [SELECT Id, Mec_nico_asignado__c, Status, Caso__c FROM WorkStep LIMIT 1];
        Contact mechanic = [SELECT Id FROM Contact WHERE RecordTypeId = :RM_CT_TestDataFactory.getMechanicRecordTypeId() LIMIT 1];
        
        Test.startTest();
        String workStepId = (String) ws.Id;
        String mechanicId = (String) mechanic.Id;
        RM_CT_Gestion_Tareas_Ctrl.asignarMechanico(workStepId, mechanicId);
        RM_CT_Gestion_Tareas_Ctrl.updateWorkStepStatus(workStepId, 'En curso');
        Test.stopTest();

        ws = [SELECT Id,Status FROM WorkStep WHERE Id = :ws.Id LIMIT 1];
        System.assertEquals('En curso', ws.Status);
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
        Map<String,Object> response = RM_CT_Gestion_Tareas_Ctrl.reprocesarTrabajo(ttcId,null, mechanicId);
        Test.stopTest();

        List<tiposDeTrabajoCaso__c> newTTCList = [SELECT Id, Caso__c FROM tiposDeTrabajoCaso__c WHERE Caso__c = :c.Id AND RM_TipoTrabajoCaso__c = :ttc.Id LIMIT 1];
        System.assertEquals(1, newTTCList.size());
    }

    @IsTest
    static void testReprocesarSubtrabajo() {
        Case c = [SELECT Id,CaseNumber FROM Case LIMIT 1];
        Contact mechanic = [SELECT Id FROM Contact WHERE RecordTypeId = :RM_CT_TestDataFactory.getMechanicRecordTypeId() LIMIT 1];
        String caseId = (String) c.Id;
        tiposDeTrabajoCaso__c ttc = [SELECT Id, Caso__c,(SELECT Id FROM Subtipos_de_trabajos_del_caso__r) FROM tiposDeTrabajoCaso__c WHERE Caso__c = :c.Id LIMIT 1];
        String sttcId = (String) ttc.Subtipos_de_trabajos_del_caso__r[0].Id;
        String mechanicId = (String) mechanic.Id;

        Test.startTest();
        Map<String,Object> response = RM_CT_Gestion_Tareas_Ctrl.reprocesarSubTrabajo(sttcId, mechanicId);
        Test.stopTest();

        List<Subtipo_de_trabajo_del_caso__c> newSTTCList = [SELECT Id FROM Subtipo_de_trabajo_del_caso__c WHERE Caso__c = :c.Id AND RM_SubtipoTrabajoCaso__c = :sttcId LIMIT 1];
        System.assertEquals(1, newSTTCList.size());
    }
    
    @IsTest
    static void testEliminarTrabajo() {
        Case c = [SELECT Id,CaseNumber FROM Case LIMIT 1];
        tiposDeTrabajoCaso__c ttc = [SELECT Id,Paso_de_trabajo__c,(SELECT Id,Paso_de_trabajo__c FROM Subtipos_de_trabajos_del_caso__r) FROM tiposDeTrabajoCaso__c WHERE Caso__c = :c.Id LIMIT 1];
        System.debug(ttc.Subtipos_de_trabajos_del_caso__r);

        RM_CT_Gestion_Tareas_Ctrl.reprocesarTrabajo(ttc.Id,null,null);

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
            RM_CT_Gestion_Tareas_Ctrl.deleteTrabajo(ttcId);
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

        RM_CT_Gestion_Tareas_Ctrl.reprocesarTrabajo(ttc.Id,null,null);

        ttc = [SELECT Id,Paso_de_trabajo__c,(SELECT Id,Paso_de_trabajo__c FROM Subtipos_de_trabajos_del_caso__r) FROM tiposDeTrabajoCaso__c WHERE Id != :ttc.Id AND Caso__c = :c.Id AND RM_TipoTrabajoCaso__c != null LIMIT 1];
        String sttcId = (String) ttc.Subtipos_de_trabajos_del_caso__r[0].Id;  
        Test.startTest();
            RM_CT_Gestion_Tareas_Ctrl.deleteSubtrabajo(sttcId);
        Test.stopTest();
    }

    @IsTest
    static void testSearchCasesLookUp() {
        Case c = [SELECT Id,CaseNumber FROM Case LIMIT 1];
        //extract the first 3 characters of the case number
        String searchTerm = c.CaseNumber.substring(0,3);
        
        Test.startTest();
        List<LookupSearchResult> results = RM_CT_Gestion_Tareas_Ctrl.searchCases(searchTerm, null, null, 'Caso', 'Caso', 'case');
        Test.stopTest();
    }
}