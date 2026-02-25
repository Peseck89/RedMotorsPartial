@IsTest
public with sharing class RM_CT_ReporteHorasFacturadas_Ctrl_Test {
    @TestSetup
    static void makeData(){
        RM_CT_TestDataFactory.createCaseWithWorkSteps();
    }

    @IsTest
    static void testConsularDatosReporte(){
        List<Case> cases = [SELECT Id, CaseNumber FROM Case];

        
        Contact mechanic = [SELECT Id FROM Contact WHERE RecordTypeId = :RM_CT_TestDataFactory.getMechanicRecordTypeId() LIMIT 1];

        String caseNumber = cases[0].CaseNumber;

        List<tiposDeTrabajoCaso__c> ttcs = [SELECT Id,Paso_de_trabajo__r.Status,Paso_de_trabajo__r.RM_Mecanico__c,
                                            (
                                                SELECT Id, Paso_de_trabajo__c, Paso_de_trabajo__r.Status,Paso_de_trabajo__r.RM_Mecanico__c
                                                FROM Subtipos_de_trabajos_del_caso__r
                                            ) FROM tiposDeTrabajoCaso__c WHERE Caso__r.CaseNumber = :caseNumber];
        //fetch tipos de trabajo del caso
        System.debug('cases: ' + cases);
        List<WorkStep> workStepToUpdate = new List<WorkStep>();
        for (tiposDeTrabajoCaso__c ttc : ttcs) {
            for (Subtipo_de_trabajo_del_caso__c sttc : ttc.Subtipos_de_trabajos_del_caso__r) {
                workStepToUpdate.add(
                    new WorkStep(
                        Id = sttc.Paso_de_trabajo__c,
                        RM_Mecanico__c = mechanic.Id
                    )
                );
            }
        }
        UPDATE workStepToUpdate;

        for(WorkStep ws : workStepToUpdate){
    
            ws.Status = 'En curso';
            UPDATE ws;

            ws.Status = 'Completada';
            UPDATE ws;

            ws.Status = 'En curso';
            UPDATE ws;

            ws.Status = 'Completada';
            UPDATE ws;
        }

        Test.startTest();
            Date startDate = Date.today().addDays(-100);
            Date endDate = Date.today().addDays(100);
            Boolean showResume = false;
            RM_CT_ReporteHorasFacturadas_Ctrl.getData(null,startDate, endDate, showResume,caseNumber);
        Test.stopTest();
        // Add assertions here
    }
}