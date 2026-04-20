@IsTest
public with sharing class RM_VN_CrearOppModeloInteres_Ctrl_Test {

    @TestSetup
    static void makeData(){
        RM_VN_DataFactoryHelper.createRecordsVN();
    }
    @IsTest
    static void testGetProducts(){
        RM_VN_InventarioFantasia_Ctrl.getBrands();

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
        Integer pageNumber = 1;

        Map<String,Object> responseMap = RM_VN_InventarioFantasia_Ctrl.getRecords(productFantasia.marcaVehiculo__c, productFantasia.Familia__c, productFantasia.Anno__c, pageNumber);

        Account acc = [SELECT Id FROM Account LIMIT 1];

		List<Account> cuentaValidada = RM_VN_CrearOppModeloInteres_Ctrl.validarCuenta(acc.id);
        RM_VN_InventarioFantasia_Ctrl.searchFamilyByBrand(productFantasia.Familia__c, productFantasia.marcaVehiculo__c, null, null, null, null, null);

        Assert.areNotEqual(null, responseMap, 'El mapa de respuesta no debe ser nulo');
        Assert.areNotEqual(null, cuentaValidada, 'La lista de cuentas no debe ser nula');
    }

}
