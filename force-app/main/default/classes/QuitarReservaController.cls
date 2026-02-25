public with sharing class QuitarReservaController {
    
    public class WrapperRespuesta{
        public String code;
        public String description;
    }
    
    @AuraEnabled
    public static Opportunity getCurrentOpp(Id OppId){
        return [SELECT Id, Name, ModelosProductos__c, NombreProducto__c, Synced_Quote__c 
                FROM Opportunity 
                WHERE Id =: OppId];
        
    }
    
    @AuraEnabled
    public static List<Product2> getModelosVehiculos(Id OppId){
        Opportunity currentOpp = [SELECT Id, Synced_Quote__c FROM Opportunity WHERE Id =: OppId];
        List<Quote> presupuestosRelacionados = [SELECT Id, OpportunityId FROM Quote WHERE Id =: currentOpp.Synced_Quote__c];
        List<QuoteLineItem> partidasRelacionadas = [SELECT Id, QuoteId, Product2Id FROM QuoteLineItem WHERE QuoteId =: presupuestosRelacionados];
        List<Id> productosSyncId = new List<Id>();
        for(QuoteLineItem quoteItem : partidasRelacionadas) productosSyncId.add(quoteItem.Product2Id);
        List<Product2> productosSync = [SELECT Id FROM Product2 WHERE Id IN : productosSyncId ];
        
        
        List<OpportunityLineItem> productosRelacionados = [SELECT Id, OpportunityId, Name, Modelo_De_Inter_s1__c, Reservado__c, Product2Id 
                                                           FROM OpportunityLineItem 
                                                           WHERE OpportunityId =: OppId 
                                                           AND Product2.Producto_Reservado__c = TRUE];
        List<Id> productosId = new List<Id>();
        for(OpportunityLineItem lineItem : productosRelacionados) productosId.add(lineItem.Product2Id);
        List<Product2> productos = [SELECT Id, Name, modelo__c, esVehiculo__c, es_Vehiculo_en_transito__c, Producto_Reservado__c 
                                   	FROM Product2 
									WHERE Id IN : productosId
                                    AND Id IN : productosSync
									AND ( esVehiculo__c = true OR es_Vehiculo_en_transito__c = true)
									AND Producto_Reservado__c = true];
        return productos;
    }
    
    @AuraEnabled
    public static Product2 getProduct(Id ProdId){
        return [ SELECT Id, Name, vin__c, Producto_Reservado__c 
                 FROM Product2 
                 WHERE Id =: ProdId ];
    }
    
    @AuraEnabled
    public static Boolean getAnticipo(Id OppId, Id ProdId){
        List<Anticipo__c> anticipos = [ SELECT Id, Name, Estatus__c, Oportunidad__c, Producto__c 
                                        FROM Anticipo__c
                 						WHERE Oportunidad__c =: OppId
                                      	AND Producto__c =: ProdId];
        if(anticipos.size() > 0) return true;
        else return false;
    }
    
    @AuraEnabled
    public static Product2 makeEliminarReserva(Id OppId, Id ProdId){
        //Se realiza la consulta al servicio externo (Softland) para checar la disponiblidad del Vehiculo
        //La respuesta del servicio es de la forma {"operationResult":{"code":"xx","description":"xxxxxxxxx"}}
        //Se forma una subString para que quede de la siguiente manera {"code":"xx","description":"xxxxxxxxx"}}
        //y finalmente, se deserializa con la clase WrapperRespuesta
        // String reservaCallout = servicioEliminarReserva.getEliminarReservaById(OppId, ProdId);
        // reservaCallout = reservaCallout.substringAfter(':');
        
        // QuitarReservaController.WrapperRespuesta respuesta = (QuitarReservaController.WrapperRespuesta)JSON.deserialize(reservaCallout, QuitarReservaController.WrapperRespuesta.class);
        // System.debug('respuesta en makeEliminarReserva: ' + respuesta);
         
        // if ( respuesta.code != '00' || respuesta.code == null ) throw new AuraHandledException(respuesta.code + ' ' + respuesta.description);
        
        
        //Se realiza el query al producto reservado (Product2) y se asigna el campo:
        //Producto_Reservado__c = true.

        List<Product2> selectedProducts = [ SELECT Id, Name, vin__c, Producto_Reservado__c FROM Product2 WHERE Id =: ProdId ];
        if (selectedProducts.isEmpty()) {
            throw new AuraHandledException('El vehículo no fue encontrado');
        }

        Product2 selectedProduct =  selectedProducts[0];

        try{

        selectedProduct.Producto_Reservado__c = false;
        selectedProduct.OportunidadReserva__c = null;
        UPDATE selectedProduct;

        
        //Se realiza el query al producto reservado (OpportunityLineItem) y se asigna el campo:
        //Reservado__c = true.
        List<OpportunityLineItem> productoToUpdate = [SELECT Id, OpportunityId, Name, Modelo_De_Inter_s1__c, Reservado__c, Quantity, Product2Id 
                                                	  FROM OpportunityLineItem 
                                                	  WHERE Product2Id =: ProdId ];
        for (OpportunityLineItem opp : productoToUpdate){
            opp.Reservado__c = false;
        }
        UPDATE productoToUpdate;
        
        
        // Se Reliza el query para todos los opplineitems de la oportunidad para identificar si todavia tiene alguno reservado
        Boolean tienereservados = false;
        List<OpportunityLineItem> productoToUpdate2 = [SELECT Id, OpportunityId, Name, Modelo_De_Inter_s1__c, Reservado__c, Quantity, Product2Id,
                                                       Product2.Name,Product2.Producto_Reservado__c
                                                	  FROM OpportunityLineItem 
                                                	  WHERE OpportunityId =: OppId ];
        
        String vehiculosReservados = '';
        for (OpportunityLineItem opp : productoToUpdate2){
            if(opp.Reservado__c){
                tienereservados = true;
            }
            if (opp.Product2.Producto_Reservado__c) {
                //guardar en vehiculosReservados el nombre de los productos product2.name separados por comas, considerar cuando la lista esta vacia
                vehiculosReservados += String.isBlank(vehiculosReservados) ? opp.Product2.Name : ', ' + opp.Product2.Name;
            }
        }
        
        //Se realiza el query a la oportunidad y se asigna el campo:
        //Tiene_Vehiculos_Reservados__c = true y se agrega el nombre del producto al campo Vehiculos_Reservados__c.
        //Actualizar esta codigo para enterder si tiene mas de un producto reservado todavia de lo contrario colocar en false
        Opportunity OppToUpdate = [SELECT Id, Name, Tiene_Vehiculos_Reservados__c, Vehiculos_Reservados__c
                                   FROM Opportunity 
                                   WHERE Id =: OppId ];

        OppToUpdate.Tiene_Vehiculos_Reservados__c = tienereservados;
		OppToUpdate.Vehiculos_Reservados__c = String.isBlank(vehiculosReservados) ? null : vehiculosReservados;
  
        //Finalmente, se actualizan todos los registros.
        
        UPDATE OppToUpdate;

        } catch (DmlException e) {
            throw new AuraHandledException(e.getMessage());
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
   
        return selectedProduct;

    }
}