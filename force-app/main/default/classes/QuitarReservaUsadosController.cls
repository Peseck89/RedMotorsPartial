public with sharing class QuitarReservaUsadosController {
    
    public class WrapperRespuesta{
        public String code;
        public String description;
    }
    
    @AuraEnabled
    public static Opportunity getCurrentOpp(Id OppId){
        return [SELECT Id, Name, ModelosProductos__c, NombreProducto__c, QuoteSynUsado__c 
                FROM Opportunity 
                WHERE Id =: OppId];
        
    }
    
    @AuraEnabled
    public static List<Product2> getModelosVehiculos(Id OppId){
        Opportunity currentOpp = [SELECT Id, QuoteSynUsado__c FROM Opportunity WHERE Id =: OppId];
        List<Quote> presupuestosRelacionados = [SELECT Id, OpportunityId FROM Quote WHERE Id =: currentOpp.QuoteSynUsado__c];
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
        List<Product2> productos = [SELECT Id, Name, modelo__c, es_Vehiculo_usado__c, Producto_Reservado__c 
                                    FROM Product2 
                                    WHERE Id IN : productosId
                                    AND Id IN : productosSync
                                    AND es_Vehiculo_usado__c = TRUE
                                    AND Producto_Reservado__c = TRUE];
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
        //String reservaCallout = servicioEliminarReserva.getEliminarReservaById(OppId, ProdId);
        //reservaCallout = reservaCallout.substringAfter(':');
        
        //QuitarReservaUsadosController.WrapperRespuesta respuesta = (QuitarReservaUsadosController.WrapperRespuesta)JSON.deserialize(reservaCallout, QuitarReservaUsadosController.WrapperRespuesta.class);
        //System.debug('respuesta en makeEliminarReserva: ' + respuesta);
         
        //if ( respuesta.code != '00' || respuesta.code == null ) throw new AuraHandledException(respuesta.code + ' ' + respuesta.description);
        
        
        //Se realiza el query al producto reservado (Product2) y se asigna el campo:
        //Producto_Reservado__c = true.
        Product2 selectedProduct = [ SELECT Id, Name, vin__c, Producto_Reservado__c FROM Product2 WHERE Id =: ProdId ];
        selectedProduct.Producto_Reservado__c = FALSE;
        selectedProduct.OportunidadReserva__c = null;

        
        //Se realiza el query al producto reservado (OpportunityLineItem) y se asigna el campo:
        //Reservado__c = true.
        List<OpportunityLineItem> productoToUpdate = [SELECT Id, OpportunityId, Name, Modelo_De_Inter_s1__c, Reservado__c, Quantity, Product2Id 
                                                      FROM OpportunityLineItem 
                                                      WHERE Product2Id =: ProdId ];
        for (OpportunityLineItem opp : productoToUpdate)opp.Reservado__c = FALSE;
        
        UPDATE productoToUpdate;
        
        // Se Reliza el query para todos los opplineitems de la oportunidad para identificar si todavia tiene alguno reservado
        Boolean tienereservados = FALSE;
        List<OpportunityLineItem> productoToUpdate2 = [SELECT Id, OpportunityId, Name, Modelo_De_Inter_s1__c, Reservado__c, Quantity, Product2Id 
                                                      FROM OpportunityLineItem 
                                                      WHERE OpportunityId =: OppId ];
        for (OpportunityLineItem opp : productoToUpdate2){
            if(opp.Reservado__c==True){
                tienereservados = TRUE;
            }

        }
        
        //Se realiza el query a la oportunidad y se asigna el campo:
        //Tiene_Vehiculos_Reservados__c = true y se agrega el nombre del producto al campo Vehiculos_Reservados__c.
        //Actualizar esta codigo para enterder si tiene mas de un producto reservado todavia de lo contrario colocar en false
        Opportunity OppToUpdate = [SELECT Id, Name, Tiene_Vehiculos_Reservados__c, Vehiculos_Reservados__c
                                   FROM Opportunity 
                                   WHERE Id =: OppId ];
        OppToUpdate.Tiene_Vehiculos_Reservados__c = tienereservados;
        OppToUpdate.Vehiculos_Reservados__c = null;
        
        //if(OppToUpdate.Vehiculos_Reservados__c == NULL) OppToUpdate.Vehiculos_Reservados__c = selectedProduct.Name;
        //else OppToUpdate.Vehiculos_Reservados__c += (', ' + selectedProduct.Name);
        
        //Finalmente, se actualizan todos los registros.
        UPDATE productoToUpdate;
        UPDATE OppToUpdate;
        UPDATE selectedProduct;
        
        return selectedProduct;
    }

    
    
}