@IsTest
public with sharing class RM_VU_Inventario_Ctrl_Test {

    @TestSetup
    static void makeData(){
        RM_VU_TestDataFactory.prepareRecords();
    }

    @IsTest
    static void TestGetRecords(){
        RM_Config__mdt cfgMdtDPLVU = RM_Config__mdt.getInstance('Default_Price_List_VU');
        RM_Config__mdt cfgMdtDPLVUCC = RM_Config__mdt.getInstance('Default_Price_List_VU_Currency_Code');

        String currencyCode, brand, year, model, productCode, bodegaId, vin, internalColor, externalColor, tipoCombustible, placa;        
        Integer pageNumber = 1;

        Id priceBookId = [SELECT Id FROM Pricebook2 WHERE Name = :cfgMdtDPLVU.Value__c AND IsActive = TRUE].Id;

        List<Product2> productList = [SELECT Id,Anno__c,marcaVehiculo__c,modelo__c,ProductCode,combustible__c,Color__c,Color_Externo__c,vin__c,Codigo_de_Producto__c FROM Product2 WHERE IsActive = TRUE AND es_Vehiculo_usado__c = true];
        System.debug(productList);
        Map<String,Object> responseMap = RM_VU_Inventario_Ctrl.getRecords('Autos_Usados',productList[0].marcaVehiculo__c, productList[0].Anno__c, productList[0].modelo__c,productList[0].ProductCode, placa , internalColor, externalColor , tipoCombustible,  pageNumber,false,'Bavarian Dólar');         

        Map<String,Object> responseMap2 = RM_VU_Inventario_Ctrl.getRecords('','', '', '','', '' , '', '' , '',  1,false ,'Bavarian Dólar');

		List<Pricebook2> pbList = RM_VU_Inventario_Ctrl.getPriceBooks();
        
        Id oppId = [SELECT Id FROM Opportunity LIMIT 1].Id;
        Opportunity opp= RM_VU_Inventario_Ctrl.getOpportunity(oppId);
    }
    
    @IsTest
    static void TestGetTipoGasolina(){
        List<RM_SelectOption_Wrapper> options = RM_VU_Inventario_Ctrl.getTipoGasolina();
    }


    @IsTest
    static void testGetUsadoRecordTypeOptions() {
        // Call the method
        List<Map<String, String>> options = RM_VU_Inventario_Ctrl.getUsadoRecordTypeOptions();

        // Assert that the returned list is not empty
        System.assertNotEquals(0, options.size(), 'No options returned');
    }

}