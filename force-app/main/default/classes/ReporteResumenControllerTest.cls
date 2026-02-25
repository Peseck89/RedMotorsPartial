/**
 * @description       : Test class for ReporteResumenController
 * @author            : marcohernandezhp@gmail.com
 * @group             : 
 * @last modified on  : 04-16-2023
 * @last modified by  : marcohernandezhp@gmail.com
**/
@isTest
public with sharing class ReporteResumenControllerTest {

    @IsTest
    static void testGetWorkSteps(){        
        TestDataFactory.prepareConsoleRecords();
        ReporteResumenController.getWorkSteps(null, null, System.today().addDays(-100), System.today().addDays(100));
        // ReporteResumenController.RecordWrapperReport contactWrapper = new ReporteResumenController.RecordWrapperReport();
        // // contactWrapper.sumValues();
        ReporteResumenController.dummy();
    }
}