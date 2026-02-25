/**
 * @description       : Clase de prueba del componente cambiar vehiculo clase RM_VN_CambiarVehiculo_Ctrl
 * @author            : marcohernandezhp@gmail.com
 * @group             : Redmotors
 * @last modified on  : 06-12-2023
 * @last modified by  : marcohernandezhp@gmail.com
**/
@IsTest
public without sharing class RM_VN_CambiarVehiculo_Ctrl_Test {
    @TestSetup
    static void makeData(){
        // TestDataFactory.createQuoteWithItems();
    }

    @IsTest
    static void Test_GetOppLineItems(){
        // List<Opportunity> oppList = [SELECT Id FROM Opportunity LIMIT 1];  
        // Map<String,Object> responseMap = RM_VN_CambiarVehiculo_Ctrl.getOppLineItems(oppList[0].Id, 1);
        RM_VN_CambiarVehiculo_Ctrl.dummy();
    }
}