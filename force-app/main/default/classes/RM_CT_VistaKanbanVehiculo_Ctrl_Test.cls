@IsTest
public class RM_CT_VistaKanbanVehiculo_Ctrl_Test {

    @TestSetup
    static void makeData(){
        RM_CT_TestDataFactory.createCaseWithWorkSteps();
    }

    @IsTest
    static void testGetData() {
        List<Case> cases = [SELECT Id,Status FROM Case LIMIT 1];
        RM_CT_VistaKanbanVehiculo_Ctrl.getData(null, cases[0].Status, null, null, null, null, null, null, null);
    }

    @IsTest
    static void test_getAssignedTerritoryIds(){
        RM_CT_Service.getAssignedTerritoryIds();
    }
}