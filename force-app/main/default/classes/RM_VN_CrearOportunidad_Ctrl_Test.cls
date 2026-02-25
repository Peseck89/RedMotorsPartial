@IsTest
public with sharing class RM_VN_CrearOportunidad_Ctrl_Test {
        
    // public static final String PRICEBOOK_NAME;// = RM_VN_CrearOportunidad_Ctrl.getDefaultPriceListVN();

    @TestSetup
    static void makeData(){
        RM_VN_DataFactoryHelper.createRecordsVN();
    }

    @IsTest
    static void testGetProducts(){        

        List<Product2> productList = [SELECT Id, Name,ProductCode,Anno__c,marcaVehiculo__c,modelo__c,Color__c,Color_Externo__c,vin__c FROM Product2 WHERE esVehiculo__c = false AND IsActive = TRUE LIMIT 1];

        List<ProductoXBodega__c> prodXBodList = [SELECT Id, Producto__c,Producto__r.Name,Producto__r.ProductCode,Producto__r.Anno__c,Producto__r.marcaVehiculo__c,Producto__r.modelo__c,Producto__r.Color__c,Producto__r.Color_Externo__c,Producto__r.vin__c FROM ProductoXBodega__c WHERE Producto__r.esVehiculo__c = true LIMIT 1];
        String productName = productList[0].Name;
        String productCode = productList[0].ProductCode;
        String bodegaId = productList[0].Id;
        String year = productList[0].Anno__c; 
        String  vin = productList[0].vin__c; 
        String  brand = productList[0].marcaVehiculo__c; 
        String  internalColor = productList[0].Color__c;
        String  externalColor = productList[0].Color_Externo__c; 
        String  model = productList[0].modelo__c;
        String  tipoCombustible = 'All';
        Integer pageNumber =  1;
               
        // Map<String,Object> responseMap = RM_VN_CrearOportunidad_Ctrl.getProducts(brand, year, productCode, bodegaId, vin, internalColor, externalColor, model, tipoCombustible, pageNumber);

        Account acc = [SELECT Id FROM Account LIMIT 1];

        Id softlandId = RM_VN_Service.getSoftlandPriceBookId(brand,year);


        List<Product2> productBavarianList = [SELECT Id, (SELECT Product2Id, UnitPrice, Gerente__c, Jefe__c, Vendedor__c,Costo_Fijo__c, Name FROM PricebookEntries WHERE Pricebook2Id = :softlandId AND Pricebook2.IsActive = TRUE AND IsActive = TRUE ORDER BY UnitPrice DESC LIMIT 1) FROM Product2 WHERE esVehiculo__c = true AND IsActive = TRUE LIMIT 1];
        PricebookEntry pbeBararian = productBavarianList[0].PricebookEntries[0];

        String brandLike = '%'+brand+'%';
        String yearLike = '%'+year+'%';
        List<Product2> productFantasiaList = [SELECT Id, (SELECT Product2Id, UnitPrice, Gerente__c, Jefe__c, Vendedor__c,Costo_Fijo__c, Name FROM PricebookEntries WHERE Pricebook2.Name LIKE :brandLike AND Pricebook2.Name LIKE :yearLike AND Pricebook2.IsActive = TRUE AND IsActive = TRUE ORDER BY UnitPrice DESC LIMIT 1) FROM Product2 WHERE esVehiculo__c = false AND IsActive = TRUE LIMIT 1];
        PricebookEntry pbeFantasia = productFantasiaList[0].PricebookEntries[0];

        List<RM_VN_CrearOportunidad_Ctrl.RM_VN_SelectedItem_Wrapper> selectionItemWrapperList = new List<RM_VN_CrearOportunidad_Ctrl.RM_VN_SelectedItem_Wrapper>();
        
        RM_VN_CrearOportunidad_Ctrl.RM_VN_SelectedItem_Wrapper tmp = new RM_VN_CrearOportunidad_Ctrl.RM_VN_SelectedItem_Wrapper();
        tmp.pbeFantasiaId = pbeFantasia.Id;
        tmp.pbeBararianId = pbeBararian.Id;
        tmp.prodXBodId = prodXBodList[0].Id;

        selectionItemWrapperList.add(tmp);
        
        RM_VN_CrearOportunidad_Ctrl.validarCuenta(acc.id);
        RM_VN_CrearOportunidad_Ctrl.getSoftlandPriceBookId('BMW');
        RM_VN_CrearOportunidad_Ctrl.getSucursalName();

        //RM_VN_CrearOportunidad_Ctrl.createOpportunity(acc.Id, selectionItemWrapperList, brand, year,null,null,null,null,null,null,null);

        List<RM_SelectOption_Wrapper> options = RM_VN_CrearOportunidad_Ctrl.getTipoGasolina();
		RM_VN_CrearOportunidad_Ctrl.dummy();
    }
  
}