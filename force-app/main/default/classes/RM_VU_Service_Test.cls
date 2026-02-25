@IsTest
public with sharing class RM_VU_Service_Test {

    @TestSetup
    static void makeData(){
        RM_VU_TestDataFactory.prepareRecords();
    }

    @IsTest
    static void testGePBEBavarian(){

        String priceBookId,currencyCode,brand,year,modelOrName,placa;     

        RM_Config__mdt cfgMdtDPLVU = RM_Config__mdt.getInstance('Default_Price_List_VU');
        
        RM_Config__mdt cfgMdtDPLVUCC = RM_Config__mdt.getInstance('Default_Price_List_VU_Currency_Code');

        List<Pricebook2> pbList = [SELECT Id FROM Pricebook2 WHERE Name = :cfgMdtDPLVU.Value__c];

        List<Product2> productList = [SELECT Id,Anno__c,marcaVehiculo__c,modelo__c,ProductCode,combustible__c,Color__c,Color_Externo__c,vin__c,Codigo_de_Producto__c FROM Product2 WHERE IsActive = TRUE AND es_Vehiculo_usado__c = true];

        List<PricebookEntry> pbeList = RM_VU_Service.gePBEBavarian(pbList[0].Id,cfgMdtDPLVUCC.Value__c,productList[0].marcaVehiculo__c,productList[0].Anno__c,productList[0].modelo__c,productList[0].ProductCode);     

    }
}