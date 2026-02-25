/**
 * @description       : 
 * @author            : marcohernandezhp@gmail.com
 * @group             : Redmotors
 * @last modified on  : 08-01-2023
 * @last modified by  : marcohernandezhp@gmail.com
**/
public with sharing class RegistrarAnticipoCasillas {
    
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
        System.debug('currentOpp: ' + currentOpp);
        List<Quote> presupuestosRelacionados = [SELECT Id, OpportunityId FROM Quote WHERE Id =: currentOpp.Synced_Quote__c];
        System.debug('presupuestosRelacionados: ' + presupuestosRelacionados);
        List<QuoteLineItem> partidasRelacionadas = [SELECT Id, QuoteId, Product2Id FROM QuoteLineItem WHERE QuoteId =: presupuestosRelacionados];
        System.debug('partidasRelacionadas: ' + partidasRelacionadas);
        List<Id> productosSyncId = new List<Id>();
        for(QuoteLineItem quoteItem : partidasRelacionadas) productosSyncId.add(quoteItem.Product2Id);
        List<Product2> productosSync = [SELECT Id FROM Product2 WHERE Id IN : productosSyncId ];
        System.debug('productosSync: ' + productosSync);
        
        
        List<OpportunityLineItem> productosRelacionados = [SELECT Id, OpportunityId, Name, Modelo_De_Inter_s1__c, Reservado__c, Product2Id 
                                                           FROM OpportunityLineItem 
                                                           WHERE OpportunityId =: OppId 
                                                           AND Reservado__c = false];
        List<Id> productosId = new List<Id>();
        for(OpportunityLineItem lineItem : productosRelacionados) productosId.add(lineItem.Product2Id);
        System.debug('productosId: ' + productosId);
        List<Product2> productos = [SELECT Id, Name, modelo__c, esVehiculo__c, Producto_Reservado__c 
                                   	FROM Product2 
									WHERE Id IN : productosId
                                    AND Id IN : productosSync
									AND esVehiculo__c = TRUE
									AND Producto_Reservado__c = FALSE];
        System.debug('last productos ' + productos);
        Integer i = 0;
        for(Product2 pro : productos) {
            System.debug('Vehiculo ' + i);
            System.debug('Id : ' + pro.Id);
            System.debug('Name : ' + pro.Name);
            System.debug('modelo__c : ' + pro.modelo__c);
            System.debug('esVehiculo__c : ' + pro.esVehiculo__c);
            System.debug('Producto_Reservado__c : ' + pro.Producto_Reservado__c);
            i++;
        }
        return productos;
    }
    
    
    
    
    
    @AuraEnabled
    public static Product2 makeReserva(Id OppId, Id ProdId){
        
        
        //Se realiza el query al producto reservado (Product2) y se asigna el campo:
        //Producto_Reservado__c = true. y se asocia la opp reservada.
        Product2 selectedProduct = [ SELECT Id, Name, vin__c, Producto_Reservado__c FROM Product2 WHERE Id =: ProdId ];
        System.debug('selectedProduct '+selectedProduct);
        selectedProduct.Producto_Reservado__c = TRUE;
                System.debug('selectedProduct2 '+selectedProduct);

        
        //Se realiza el query al producto reservado (OpportunityLineItem) y se asigna el campo:
        //Reservado__c = true.
        List<OpportunityLineItem> productoToUpdate = [SELECT Id, OpportunityId, Name, Modelo_De_Inter_s1__c, Reservado__c, Quantity, Product2Id 
                                                	  FROM OpportunityLineItem 
                                                	  WHERE Product2Id =: ProdId ];
             System.debug('oli '+productoToUpdate);

        for (OpportunityLineItem opp : productoToUpdate){
             System.debug('oli1 '+opp);
             opp.Reservado__c = true;
             System.debug('oli2 '+opp);
        }    
        
        
        //Se realiza el query a la oportunidad y se asigna el campo:
        //Tiene_Vehiculos_Reservados__c = true y se agrega el nombre del producto al campo Vehiculos_Reservados__c.
        Opportunity OppToUpdate = [SELECT Id, Name, Tiene_Vehiculos_Reservados__c, Vehiculos_Reservados__c
                                   FROM Opportunity 
                                   WHERE Id =: OppId ];
                     System.debug('OppToUpdate '+OppToUpdate);

        OppToUpdate.Tiene_Vehiculos_Reservados__c = true;
        if(OppToUpdate.Vehiculos_Reservados__c == NULL){ 
                                 System.debug('OppToUpdate1 '+OppToUpdate);
            OppToUpdate.Vehiculos_Reservados__c = selectedProduct.Name;
                                             System.debug('OppToUpdate2 '+OppToUpdate);

                }
        if(! (OppToUpdate.Vehiculos_Reservados__c.length() + selectedProduct.Name.length() > 255) ) OppToUpdate.Vehiculos_Reservados__c += (', ' + selectedProduct.Name);
        
        //Finalmente, se actualizan todos los registros.
        UPDATE productoToUpdate;
        UPDATE OppToUpdate;
       	UPDATE selectedProduct;
        System.debug('actualización correcta');
        return selectedProduct;
    }


    @Future(callout=true)
    public static void reservarVehiculo(Id OppId, Id ProdId){
        makeReserva(OppId,ProdId);
    }
}