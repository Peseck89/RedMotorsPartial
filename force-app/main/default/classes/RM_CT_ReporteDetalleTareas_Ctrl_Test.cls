@isTest
private class RM_CT_ReporteDetalleTareas_Ctrl_Test {

    static String userEmail = 'marcotest@test.com';
    static String workStepName = 'cambio de aceite test';
    static String vehiclePlate = 'ABCTEST01';

    @TestSetup
    static void makeData(){
        TestDataFactory.prepareConsoleRecords();        
    }

    @isTest
    static void testGetWorkSteps() {
        Case caso = [SELECT Id,caseNumber FROM Case LIMIT 1];
        ServiceTerritory territory = [SELECT Id,Name FROM ServiceTerritory LIMIT 1];
        Contact contact = [SELECT Id FROM Contact LIMIT 1];

        RM_CT_ReporteDetalleTareas_Ctrl.getWorkSteps(caso.Id, territory.Id, contact.Id,1,1);
    }
}