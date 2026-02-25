@RestResource(urlMapping='/ProductUpdateService/*')
global with sharing class ProductUpdateService {
    
    global class RequestBody {
        public String productCode;
        public String vin;
        public Boolean arregloVin;
        //public String opportunityId;
    }
    
    @HttpPost
    global static void updateProduct() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        RequestBody body = (RequestBody)JSON.deserialize(req.requestBody.toString(), RequestBody.class);
        Map<String, Object> response = new Map<String, Object>();
        
        if(body.arregloVin){
            try {
                
                fixProduct(body.productCode, body.vin);
                response.put('OK', 'Se actualizó correctamente.');
                res.responseBody = Blob.valueOf(JSON.serialize(response));
                res.statusCode = 200;
            return;
            } catch(Exception e) {
                res.statusCode = 500;
                response.put('Error', 'Error al actualizar: ' + e.getMessage());
                res.responseBody = Blob.valueOf(JSON.serialize(response));
                return;
            }
        }else{
            try {
                
                updateProductDetails(body.productCode, body.vin);
                response.put('OK', 'Se actualizó correctamente.');
                res.responseBody = Blob.valueOf(JSON.serialize(response));
                res.statusCode = 200;
            return;
            } catch(Exception e) {
                res.statusCode = 500;
                response.put('Error', 'Error al actualizar: ' + e.getMessage());
                res.responseBody = Blob.valueOf(JSON.serialize(response));
                return;
            }
        }
    }
        
    private static void updateProductDetails(String productCode, String vin) {
        Product2 prod = [SELECT Id, esVehiculo__c	, es_Vehiculo_en_transito__c, Codigo_de_Producto__c FROM Product2 WHERE Codigo_de_Producto__c = :productCode LIMIT 1];
        prod.Codigo_de_Producto__c = vin;
        prod.esVehiculo__c = true;
        prod.es_Vehiculo_en_transito__c = false;
        //prod.name = vin;
        
        List<ProductoXBodega__c> prodXBodegaList = [SELECT Id, BodegaNombre__c,Identificador__c, Bodega__r.bodega__c FROM ProductoXBodega__c WHERE Producto__c = :prod.Id];
        
        System.debug('idProducto ' + prodXBodegaList);
        
        List<ProductoXBodega__c> toupdate= new List<ProductoXBodega__c>();
    

        if (!prodXBodegaList.isEmpty()) {
            for (ProductoXBodega__c prodXBodega : prodXBodegaList) {
                System.debug('nombreBodega ' + prodXBodega.Bodega__r.bodega__c);
                System.debug('nuevoIdentificador ' + vin + '-' + prodXBodega.Bodega__r.bodega__c);
                String nombreBodega = prodXBodega.Bodega__r.bodega__c;
                String nuevoIdentificador = vin + '-' + nombreBodega;
                //ProductoXBodega__c prodXBodega = prodXBodegaList[0];
                prodXBodega.Identificador__c = nuevoIdentificador;
                toupdate.add(prodXBodega);
            }
			System.debug('AntesUpdate ');            
            update toupdate;
            System.debug('despuesupdate ');
        }
        System.debug('antesupdateproducto ');
        update prod;
        System.debug('despuesupdateproducto ');
    }
    
    
     private static void fixProduct(String productCode, String vin) {
        Product2 prod = [SELECT Id, esVehiculo__c	, es_Vehiculo_en_transito__c, Codigo_de_Producto__c FROM Product2 WHERE Pedido_Original__c = :productCode LIMIT 1];
        prod.Codigo_de_Producto__c = vin;
        prod.esVehiculo__c = true;
        prod.es_Vehiculo_en_transito__c = false;
        
        List<ProductoXBodega__c> prodXBodegaList = [SELECT Id, BodegaNombre__c,Identificador__c, Bodega__r.bodega__c FROM ProductoXBodega__c WHERE Producto__c = :prod.Id];
        
        System.debug('idProducto ' + prodXBodegaList);
        
        List<ProductoXBodega__c> toupdate= new List<ProductoXBodega__c>();
    

        if (!prodXBodegaList.isEmpty()) {
            for (ProductoXBodega__c prodXBodega : prodXBodegaList) {
                System.debug('nombreBodega ' + prodXBodega.Bodega__r.bodega__c);
                System.debug('nuevoIdentificador ' + vin + '-' + prodXBodega.Bodega__r.bodega__c);
                String nombreBodega = prodXBodega.Bodega__r.bodega__c;
                String nuevoIdentificador = vin + '-' + nombreBodega;
                //ProductoXBodega__c prodXBodega = prodXBodegaList[0];
                prodXBodega.Identificador__c = nuevoIdentificador;
                toupdate.add(prodXBodega);
            }
			System.debug('AntesUpdate ');            
            update toupdate;
            System.debug('despuesupdate ');
        }
        System.debug('antesupdateproducto ');
        update prod;
        System.debug('despuesupdateproducto ');
    }
}