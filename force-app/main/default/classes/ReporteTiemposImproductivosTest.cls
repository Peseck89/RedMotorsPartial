/**
 * @description       : Test class for ReporteTiemposImproductivos
 * @author            : marcohernandezhp@gmail.com
 * @group             : 
 * @last modified on  : 12-15-2022
 * @last modified by  : marcohernandezhp@gmail.com
**/
@isTest
public with sharing class ReporteTiemposImproductivosTest {
    @IsTest
    static void testGetWorkSteps(){
        ReporteTiemposImproductivos.getWorkSteps(null, null, System.today().addDays(-100) , System.today().addDays(100));        
    }
}