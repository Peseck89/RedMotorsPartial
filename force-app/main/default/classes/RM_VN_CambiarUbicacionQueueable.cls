public with sharing class RM_VN_CambiarUbicacionQueueable implements Queueable {
    private String productoXBodegaOrigenId;
    private String bodegaDestinoId;
    Boolean success = false;
    String message;

    public RM_VN_CambiarUbicacionQueueable(String productoXBodegaOrigenId, String bodegaDestinoId) {
        this.productoXBodegaOrigenId = productoXBodegaOrigenId;
        this.bodegaDestinoId = bodegaDestinoId;
    }

    public void execute(QueueableContext context) {
        try{
            //Actualizar la disponibilidad a 0
            List<ProductoXBodega__c> productoXBodegas = [SELECT Id, Producto__c,Producto__r.vin__c, Bodega__c,Bodega__r.Name,Disponible__c, Bodega__r.ID_EXTERNO_BODEGA__c FROM ProductoXBodega__c WHERE Id = :productoXBodegaOrigenId];
            for(ProductoXBodega__c pxb : productoXBodegas){
                pxb.Disponible__c = 0;
            }
            UPDATE productoXBodegas;

            String vehiculoId = productoXBodegas[0].Producto__c;
            
            //Actualizar la disponibilidad de la nueva ubicacion a 1
            productoXBodegas = [SELECT Id, Producto__c, Bodega__c,Disponible__c,Bodega__r.ID_EXTERNO_BODEGA__c FROM ProductoXBodega__c WHERE Producto__c!= NULL AND Producto__c =: vehiculoId AND Bodega__c != NULL AND Bodega__c =: bodegaDestinoId LIMIT 1];
            if(productoXBodegas.size() == 0){
                //creamos el registro
                ProductoXBodega__c nuevoPXB  = new ProductoXBodega__c();
                nuevoPXB.Producto__c = vehiculoId;
                nuevoPXB.Bodega__c = bodegaDestinoId;
                nuevoPXB.Disponible__c = 1;
                INSERT nuevoPXB;
            }else {
                //actualizamos el registro
                for(ProductoXBodega__c pxb : productoXBodegas){
                    pxb.Disponible__c = 1;
                }
                UPDATE productoXBodegas;
            }
            success = true;
            message = 'El vehiculo fue transferido correctamete.';
            sendNotificationMessage(productoXBodegaOrigenId, 'success','Cambio de Ubicacion',message);
        }catch(DmlException e){
            success = false;
            message = e.getMessage();
            sendNotificationMessage(productoXBodegaOrigenId, 'error','Cambio de Ubicacion',message);
            return;
        }
    }

    public void sendNotificationMessage(String productoXBodegaOrigenId, String type,String title,String message) {
        try {
            // Create a new event instance
            RM_Event__e event = new RM_Event__e();
            event.Message__c = message;
            event.Record_Id__c = productoXBodegaOrigenId;
            event.Title__c = 'Cambio de Ubicación';
            event.Type__c = 'alert';
    
            // Log the event details
            System.debug('Publishing event: ' + event);
    
            // Publish the event
            EventBus.publish(event);
    
            // Log success message
            System.debug('Event published successfully.');
        } catch (Exception e) {
            // Log the exception
            System.debug('Error publishing event: ' + e.getMessage());
            throw new AuraHandledException('An error occurred while publishing the event.');
        }
    }
}