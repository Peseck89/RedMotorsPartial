/**
 * @description       : 
 * @author            : marcohernandezhp@gmail.com
 * @group             : Redmotors
 * @last modified on  : 07-25-2023
 * @last modified by  : marcohernandezhp@gmail.com
**/
@IsTest
public with sharing class RM_CT_ConsolaTaller_Ctrl_Test {    
    @IsTest
    static void test_RM_CT_ConsolaTaller_Ctrl(){
        RM_CT_ConsolaTaller_Ctrl.getTerritories(true);  
        RM_CT_ConsolaTaller_Ctrl.getWorkStepStatus();
        RM_CT_ConsolaTaller_Ctrl.getServiceTypes();
        RM_CT_ConsolaTaller_Ctrl.getUserTerritories();
    }
}