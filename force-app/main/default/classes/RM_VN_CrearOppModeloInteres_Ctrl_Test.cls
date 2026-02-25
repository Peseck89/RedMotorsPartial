@IsTest
public with sharing class RM_VN_CrearOppModeloInteres_Ctrl_Test {
    //public static final String PRICEBOOK_NAME = RM_VN_CrearOportunidad_Ctrl.getDefaultPriceListVN();

    @TestSetup
    static void makeData(){
        RM_VN_DataFactoryHelper.createRecordsVN();
    }
    @IsTest
    static void testGetProducts(){
        RM_VN_InventarioFantasia_Ctrl.getBrands();
        
        //Product2 productFantasia = [SELECT Id, marcaVehiculo__c,Familia__c,Anno__c,Modelo_De_Inter_s__c,(SELECT Product2Id, UnitPrice, Gerente__c, Jefe__c, Vendedor__c,Costo_Fijo__c, Name FROM PricebookEntries WHERE Pricebook2.IsActive = TRUE AND IsActive = TRUE ORDER BY UnitPrice DESC LIMIT 1) FROM Product2 WHERE Modelo_De_Inter_s__c != null AND IsActive = TRUE LIMIT 1];
        Pricebook2 pb = new Pricebook2(Name='Bavarian Dólar', IsActive=true);
        insert pb;
        Product2 productFantasia = [SELECT Id,Familia__c, Name,ProductCode,Anno__c,marcaVehiculo__c,modelo__c,Color__c,Color_Externo__c,vin__c FROM Product2 WHERE esVehiculo__c = false AND IsActive = TRUE LIMIT 1];
		PricebookEntry pbeFantasia = new PricebookEntry(
            Pricebook2Id = pb.Id,
            Product2Id = productFantasia.Id,
            UnitPrice = 1000,
            IsActive = TRUE
        );
        insert pbeFantasia;
        Integer pageNumber =  1;
               
        Map<String,Object> responseMap = RM_VN_InventarioFantasia_Ctrl.getRecords(productFantasia.marcaVehiculo__c, productFantasia.Familia__c, productFantasia.Anno__c, pageNumber);

        Account acc = [SELECT Id FROM Account LIMIT 1];

        
        //PricebookEntry pbeFantasia = productFantasia.PricebookEntries[0];
		RM_VN_CrearOppModeloInteres_Ctrl.validarCuenta(acc.id);
        //RM_VN_CrearOppModeloInteres_Ctrl.createOpportunity(productFantasia.marcaVehiculo__c, productFantasia.Familia__c, productFantasia.Anno__c, acc.Id, productFantasia.Id, pbeFantasia.Id, null, null, null, null, null,null,null,null);

        RM_VN_InventarioFantasia_Ctrl.searchFamilyByBrand(productFantasia.Familia__c, productFantasia.marcaVehiculo__c, null, null, null, null, null);
    RM_VN_CrearOppModeloInteres_Ctrl.dummy();
    }
    
}