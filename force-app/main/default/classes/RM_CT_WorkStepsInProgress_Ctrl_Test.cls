/**
 * @description       : Test class for RM_CT_WorkStepsInProgress_Ctrl
 * @author            : marcohernandezhp@gmail.com
 * @group             : Redmotors
 * @last modified on  : 08-05-2023
 * @last modified by  : marcohernandezhp@gmail.com
**/
@IsTest
public without sharing class RM_CT_WorkStepsInProgress_Ctrl_Test {
    @TestSetup
    static void makeData(){
        TestDataFactory.prepareConsoleRecords();
    }

    @IsTest
    static void test_GetRecords(){
        List<String> territoryIds;
        List<String>  statuses = new List<String>{'Nueva'};
        String caseNumber;
        String workOrderNumber;
        String placa;
        String vin;
        String mechanicId;
        String agentId;
        Date startDate;
        Date endDate;
        Integer pageNumber;

        //Consultar tareas filtros en null
        RM_CT_WorkStepsInProgress_Ctrl.getRecords(territoryIds, statuses, caseNumber, workOrderNumber, placa, vin, mechanicId,agentId, startDate, endDate, true, pageNumber);       

        //consultar tareas con estatus nueva
        RM_CT_WorkStepsInProgress_Ctrl.getRecords(territoryIds, statuses, caseNumber, workOrderNumber, placa, vin, mechanicId,agentId, startDate, endDate, true, pageNumber);     

        //consultar tareas con un rango de fecha
        startDate = System.today();
        endDate = System.today().addDays(5);
        RM_CT_WorkStepsInProgress_Ctrl.getRecords(territoryIds, statuses, caseNumber, workOrderNumber, placa, vin, mechanicId,agentId, startDate, endDate, true, pageNumber);    
        
        //Consultar tareas por numero de caso
        List<Case> caseList = [SELECT Id,CaseNumber FROM Case LIMIT 1];
        RM_CT_WorkStepsInProgress_Ctrl.getRecords(territoryIds, statuses, caseNumber, caseList[0].CaseNumber, placa, vin, mechanicId,agentId, startDate, endDate, true, pageNumber);   

    }

    @IsTest
    static void test_RM_CT_ConsolaTaller_Ctrl(){
        RM_CT_ConsolaTaller_Ctrl.getTerritories(false);  
        RM_CT_ConsolaTaller_Ctrl.getWorkStepStatus();  

    }
}