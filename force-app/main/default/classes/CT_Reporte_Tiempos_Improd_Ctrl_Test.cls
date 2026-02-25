/**
 * @description       : Test class
 * @author            : marcohernandezhp@gmail.com
 * @group             : Redmotors
 * @last modified on  : 05-09-2023
 * @last modified by  : marcohernandezhp@gmail.com
**/
@isTest
public without sharing class CT_Reporte_Tiempos_Improd_Ctrl_Test {
    @IsTest
    static void testGetRecords(){
        CT_Reporte_Tiempos_Improductivos_Ctrl.getRecords(null, null, System.today().addDays(-100) , System.today().addDays(100));       
        CT_Reporte_Tiempos_Improductivos_Ctrl.dummy();
    }
}