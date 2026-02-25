/**
 * @description       : Test Class for WorkStepController
 * @author            : Marco Hernandez
 * @group             : Redmotors
 * @last modified on  : 11-10-2022
 * @last modified by  : marcohernandezhp@gmail.com
**/
@isTest
public class WorkStepControllerTest {    
    @IsTest
    static void unitTestGetWorkSteps(){
        WorkStepController wsCtr = new WorkStepController();
        WorkStepController.getWorkSteps(null, null, null, null, null, null, null, null, null, null);        
        WorkStepController.getTasksGroupedByCase(null,null, null, null, null, null, null, null, null, null);
        WorkStepController.getTerritories();
    }
}