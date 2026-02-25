/**
 * @description       : Test class for CT_Reporte_Cronologico_Controller
 * @author            : marcohernandezhp@gmail.com
 * @group             : Redmotors
 * @last modified on  : 06-01-2023
 * @last modified by  : marcohernandezhp@gmail.com
**/
@isTest
public with sharing class CT_Reporte_Cronologico_Controller_Test {
    @IsTest
    static void testGetWorkSteps(){
        // CT_Reporte_Cronologico_Controller.getWorkSteps(null, null, System.today().addDays(-100) , System.today().addDays(100));   
        CT_Reporte_Cronologico_Controller.getWorkSteps(null, null, null, System.today().addDays(-100) , System.today().addDays(100));
    }
}