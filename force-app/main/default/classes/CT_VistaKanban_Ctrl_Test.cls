/**
 * @description       : Test class CT_VistaKanban_Ctrl_Test for CT_VistaKanban_Ctrl
 * @author            : marcohernandezhp@gmail.com
 * @group             : Redmotors
 * @last modified on  : 02-27-2023
 * @last modified by  : marcohernandezhp@gmail.com
**/
@isTest
public class CT_VistaKanban_Ctrl_Test {

    @TestSetup
    static void makeData(){
        TestDataFactory.prepareConsoleRecords();
    }
    
    @IsTest
    public static void unitTestGetRecords(){
        Case caso = [SELECT Id,CaseNumber FROM Case LIMIT 1];
    
        Map<String,Object> responseMap = new Map<String,Object>(); 
        List<WorkStepWrapper> workStepList = new List<WorkStepWrapper>();                

        responseMap = CT_VistaKanban_Ctrl.getRecords(null, null, null, null, null, 'abc123', System.today().addDays(-100), System.today().addDays(200), false,null);
        responseMap = CT_VistaKanban_Ctrl.getRecords(null, null, null, null, null, null, System.today().addDays(-100), System.today().addDays(200), false,null);

    }
}