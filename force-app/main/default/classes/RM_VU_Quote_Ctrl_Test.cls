@IsTest
public with sharing class RM_VU_Quote_Ctrl_Test {
    @TestSetup
    static void makeData(){
        RM_VU_TestDataFactory.prepareRecords();
    }

    @IsTest
    static void testGetQuotes(){
        Id oppId = [SELECT Id FROM Opportunity LIMIT 1].Id;
        RM_VU_Quote_Ctrl.getQuotes(oppId);
    }

    @IsTest
    static void testAddVehicle(){
        Id oppId = [SELECT Id FROM Opportunity LIMIT 1].Id;
        RM_VU_Quote_Ctrl.getQuotes(oppId);
        Id prodXBodegaId = [SELECT Id FROM ProductoXBodega__c WHERE Producto__r.es_Vehiculo_usado__c = true AND Producto__r.IsActive = TRUE ].Id;
        Map<String,Object> responseMap = RM_VU_Quote_Ctrl.addVehicle(oppId, prodXBodegaId, null);
    }    


}