@IsTest
public with sharing class RM_VN_Inventario_Ctrl_Test {
    @TestSetup
    static void makeData(){
        RM_VN_DataFactoryHelper.createRecordsVN();
    }

    @IsTest
    static void testGetProducts(){        
        List<Product2> productList = [SELECT Id, Name,ProductCode,Anno__c,marcaVehiculo__c,modelo__c,Color__c,Color_Externo__c,vin__c,
                                        (
                                            SELECT Id, Producto__c,Producto__r.Name,Producto__r.ProductCode,Producto__r.Anno__c,Producto__r.marcaVehiculo__c,Producto__r.modelo__c,Producto__r.Color__c,Producto__r.Color_Externo__c,Producto__r.vin__c,
                                            Producto__r.familia__c
                                            FROM Productos_por_Bodega__r
                                            WHERE Disponible__c > 0
                                        )
                                    FROM Product2
                                    WHERE esVehiculo__c = true AND IsActive = TRUE LIMIT 1];
        
        String productName = productList[0].Name;
        String productCode = productList[0].ProductCode;
        String locationId = productList[0].Productos_por_Bodega__r[0].Id;
        String year = productList[0].Anno__c; 
        String  vin = productList[0].vin__c; 
        String  brand = productList[0].marcaVehiculo__c; 
        String  internalColor = productList[0].Color__c;
        String  externalColor = productList[0].Color_Externo__c; 
        String  model = productList[0].modelo__c;
        String  tipoCombustible = 'all';
        String  reportado = '';
        String  numeroPedido = '';
        Integer pageNumber =  1;
		String familia = 'x1';
        String error;
        try {
            RM_VN_Inventario_Ctrl.getRecords(null, year,model,familia, productCode, locationId, vin, internalColor, externalColor, tipoCombustible,reportado,numeroPedido,null, pageNumber,false);
        } catch(AuraHandledException e) {
            error = e.getMessage();
        }
        System.assertNotEquals(null, error, 'Se esperaba una excepcion.');

        error = null;
        try {
            RM_VN_Inventario_Ctrl.getRecords(brand, null,model,familia, productCode, locationId, vin, internalColor, externalColor, tipoCombustible,reportado,numeroPedido,null, pageNumber,false);
        } catch(AuraHandledException e) {
            error = e.getMessage();
        }
        System.assertNotEquals(null, error, 'Se esperaba una excepcion.');

        Map<String,Object> responseMap = RM_VN_Inventario_Ctrl.getRecords(brand, year,model,familia, productCode, locationId, vin, internalColor, externalColor, tipoCombustible,reportado,numeroPedido,null, pageNumber,false);

        List<ProductoXBodega__c> records = (List<ProductoXBodega__c>) responseMap.get('records');

    }


    @IsTest
    static void testGetTipoGasolina(){
        RM_VN_Inventario_Ctrl.getTipoGasolina();
    }

    @IsTest
    static void testGetLocations(){
        RM_VN_Inventario_Ctrl.getLocations('BMW');
    }


    @IsTest
    static void testSearchModels(){
        RM_VN_Inventario_Ctrl.searchModels('', '', null, 'Product2', 'Product2', 'Product', 'standard:Product2','selected Family', 'selected Brand');
    }

    @IsTest
    static void testSearchPedidos(){
        RM_VN_Inventario_Ctrl.searchNumeroPedidos('', '', null, 'Product2', 'Product2', 'Product', 'standard:Product2');
    }

    @IsTest
    static void testAgregarComentaio(){
        ProductoXBodega__c pxb = [SELECT Id,Producto__c FROM ProductoXBodega__c LIMIT 1];

        String vehiculoId = pxb.Id;
        String comentario = 'test';
        Boolean reportado = true;

        RM_VN_Inventario_Ctrl.agregaComentario(pxb.Id,comentario,true);

        RM_VN_Inventario_Ctrl.testss();
    }

}