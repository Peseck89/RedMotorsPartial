@IsTest
public with sharing class RM_VN_ConsultarCosteo_Ctrl_Test {
    @TestSetup
    static void makeData(){
        RM_VN_DataFactoryHelper.createVehiculosNuevos();
    }

    @IsTest
    static void testGetProducts(){     

        List<Product2> productList = [SELECT Id, Name,ProductCode,Anno__c,marcaVehiculo__c,modelo__c,Color__c,Color_Externo__c,vin__c,
                                        (
                                            SELECT Id, Producto__c,Producto__r.Name,Producto__r.ProductCode,Producto__r.Anno__c,Producto__r.marcaVehiculo__c,Producto__r.modelo__c,Producto__r.Color__c,Producto__r.Color_Externo__c,Producto__r.vin__c
                                            FROM Productos_por_Bodega__r
                                            WHERE Disponible__c > 0
                                        )
                                    FROM Product2
                                    WHERE esVehiculo__c = true AND IsActive = TRUE LIMIT 1];
                                    
        System.debug('productList: ' + productList);
        
        String productName = productList[0].Name;
        String productCode = productList[0].ProductCode;
        String bodegaId = productList[0].Productos_por_Bodega__r[0].Id;
        String year = productList[0].Anno__c; 
        String  vin = productList[0].vin__c; 
        String  brand = productList[0].marcaVehiculo__c; 
        String  internalColor = productList[0].Color__c;
        String  externalColor = productList[0].Color_Externo__c; 
        String  model = productList[0].modelo__c;
        String  tipoCombustible = 'all';
        Integer pageNumber =  1;

        String error;
        Map<String,Object> responseMap = RM_VN_ConsultarCosteo_Ctrl.getData('', year, model, bodegaId, vin, internalColor, externalColor, tipoCombustible, 'Disponible', pageNumber,false);

        Map<String,Object> responseMap2 = RM_VN_ConsultarCosteo_Ctrl.getDataError(pageNumber);

        responseMap = RM_VN_ConsultarCosteo_Ctrl.getData('', year, model, bodegaId, vin, internalColor, externalColor, tipoCombustible, 'Reservado', pageNumber,false);
        responseMap = RM_VN_ConsultarCosteo_Ctrl.getData('', year, model, bodegaId, vin, internalColor, externalColor, tipoCombustible, 'En transito', pageNumber,false);

        List<Product2> records = (List<Product2>) responseMap.get('records');
        // Assert.isTrue(records.size() > 0);

        // String vehiculoId = productList[0].Id;
        // List<Detalle_Costo_Producto__c> detalleCostos = RM_VN_ConsultarCosteo_Ctrl.getDetalleCosto(vehiculoId);

    }

}