@isTest
public class CleanProductInfoTest {
	@isTest static void testUpdateProductWithOpportunityId() {
        
        Product2 newProduct = new Product2();
        newProduct.Name ='ProductTest';
        newProduct.ProductCode = 'asx123';
        newProduct.vin__c = 'asx123';
        newProduct.Codigo_de_Producto__c ='asx123';
        newProduct.Pedido_Original__c ='asx123';
        newProduct.CodigoProductoInterno__c = 'asx123';
        newProduct.es_Vehiculo_en_transito__c = true;
        insert newProduct;
        
        bodega__c bodegatest = new  bodega__c();
        bodegatest.bodega__c = 'asd';
        bodegatest.ID_EXTERNO_BODEGA__c = 'asd';
        bodegatest.Name = 'Bodega Test';
        insert bodegatest;
        
        List<bodega__c> bodega = [SELECT Id FROM bodega__c LIMIT 1];
        //List<Product2> productonuevo = [SELECT Id FROM Product2  WHERE ProductCode = :'asx123' LIMIT 1];
        
        //System.debug('idProducto ' + productonuevo[0].id);
        
        
        
        List<Product2> listatestProduct = [SELECT id, productCode,vin__c, Codigo_de_Producto__c,Pedido_Original__c, esVehiculo__c, es_Vehiculo_en_transito__c, OportunidadReserva__c FROM Product2 WHERE es_Vehiculo_en_transito__c = true ];
        Product2 testProduct = listatestProduct[0];
        System.debug(testProduct.Codigo_de_Producto__c );
        System.debug('Test pedido original'+testProduct.Pedido_Original__c );
        
        ProductoXBodega__c productoxbodega = new ProductoXBodega__c();
        productoxbodega.Bodega__c = bodega[0].id;
        productoxbodega.Producto__c = testProduct.id;
        productoxbodega.Identificador__c = 'abc';
        insert productoxbodega;
        
        
        CleanProductInfo.RequestBody reqBody = new CleanProductInfo.RequestBody();
        reqBody.productCode = testProduct.productCode ;
        
        
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        req.requestBody = Blob.valueOf(JSON.serialize(reqBody));
        
        Test.startTest();
        CleanProductInfo.updateProduct();
        
        
        
        CleanProductInfo.RequestBody reqBody2 = new CleanProductInfo.RequestBody();
        reqBody2.productCode = testProduct.productCode ;
        
        
        RestRequest req2 = new RestRequest(); 
        RestResponse res2 = new RestResponse();
        RestContext.request = req2;
        RestContext.response = res2;
        req2.requestBody = Blob.valueOf(JSON.serialize(reqBody2));
        
        CleanProductInfo.updateProduct();
        Test.stopTest();
        
    }
}