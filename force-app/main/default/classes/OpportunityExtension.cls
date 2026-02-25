public class OpportunityExtension {
    public Opportunity opp { get; set; }
    public ReciboUsado__c reciboUsado { get; set; }
    public OpportunityLineItem oppProduct { get; set; }
    public Product2 producto { get; set; }
    private ApexPages.StandardController controller; 
    
    public OpportunityExtension(ApexPages.StandardController controller) {
        this.controller = controller;
        this.opp = (Opportunity)controller.getRecord();
        this.getReciboUsado();
        this.getOppProduct();
        this.getProduct();
    }
    
    public ReciboUsado__c getReciboUsado() {
        try {
            if (controller.getId() != null) { 
                reciboUsado = [SELECT Id, Name,Serecibevehiculo__c, Observaciones_Generales__c, Recibo_Marchamo__c,Placa__c,ValorReciboCliente__c
                               FROM ReciboUsado__c 
                               WHERE Oportunidad__c = :controller.getId() 
                               LIMIT 1];
            }
        } catch (QueryException e) {
            System.debug('No records found: ' + e.getMessage());
            reciboUsado = null; 
        }
        return reciboUsado;
    }
    public OpportunityLineItem getOppProduct() {
        try {
            if (controller.getId() != null) { 
                oppProduct = [SELECT Id, Name,Product2Id,UnitPrice
                              FROM OpportunityLineItem 
                              WHERE OpportunityId = :controller.getId() AND Tipo_Producto__c = 'Vehiculo'
                              ORDER BY LastModifiedDate DESC
                              LIMIT 1];
            }
        } catch (QueryException e) {
            System.debug('No records found: ' + e.getMessage());
            oppProduct = null; 
        }
        return oppProduct;
    }
    public Product2 getProduct() {
        try {
            if (controller.getId() != null) { 
                oppProduct = [SELECT Id, Name,Product2Id,UnitPrice
                              FROM OpportunityLineItem 
                              WHERE OpportunityId = :controller.getId() AND Tipo_Producto__c = 'Vehiculo'
                              ORDER BY LastModifiedDate DESC
                              LIMIT 1];
                if (oppProduct.Product2Id != null) { 
                    producto = [SELECT Id, Name,marcaVehiculo__c,modelo__c,Anno__c,vin__c,Numero_Motor__c,tapiceria__c,
                                Color_Externo__c,Carroceria__c
                                FROM Product2 
                                WHERE Id = :oppProduct.Product2Id
                                LIMIT 1];
                }
            }
        } catch (QueryException e) {
            System.debug('No records found: ' + e.getMessage());
            producto = null; 
        }
        return producto;
    }
    
}