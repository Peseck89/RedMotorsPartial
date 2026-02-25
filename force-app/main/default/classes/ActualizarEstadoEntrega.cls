@RestResource(urlMapping='/actualizarEstadoEntrega/*')
global with sharing class ActualizarEstadoEntrega {
    @HttpPost
    global static void woliEntregado() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String jsonStr = RestContext.request.requestBody.toString();
        System.debug('JSON Recieved ' + jsonStr);
        
         try {
            // Deserializamos un array de objetos
            List<actualizarWoliRequest> wrapRespuestasJSON = parseRespuesta(jsonStr);
             
            List<WorkOrderLineItem> workOrderLineItemsToUpdate = new List<WorkOrderLineItem>();

            // Iteramos a través de cada línea de la orden de trabajo
            for (actualizarWoliRequest wrapRespuestaJSON : wrapRespuestasJSON) {
                String numeroDeOrden = wrapRespuestaJSON.numeroDeOrden;
                String pedido = wrapRespuestaJSON.pedido;
                String identificadorLineaOrdenTrabajo = wrapRespuestaJSON.identificadorLineaOrdenTrabajo;
                String codigoArticulo = wrapRespuestaJSON.codigoArticulo;
                String estado = wrapRespuestaJSON.estado;
                
                List<WorkOrder> workOrders = [SELECT Id FROM WorkOrder WHERE WorkOrderNumber = :numeroDeOrden LIMIT 1];
				
                
                System.debug('Antes de work order');
                if(!workOrders.isEmpty()) {
                    WorkOrder workOrder = workOrders[0];
                    
                    List<WorkOrderLineItem> WOLIs = [SELECT Id, AliasArticuloModuloAnidar__c, Estado_softland__c , Estado_entrega__c, Cantidad_devolucion__c  FROM WorkOrderLineItem WHERE Id = :identificadorLineaOrdenTrabajo And  WorkOrderId = :workOrder.Id LIMIT 1];
                    
                    
                    if(!workOrders.isEmpty()) {
                        WorkOrderLineItem Woli = WOLIs[0];
                        Woli.Estado_entrega__c = estado;
                        Woli.Estado_softland__c = '';
                        Double CantidadActualizada = Woli.Quantity - Woli.Cantidad_devolucion__c;
                        System.debug('Cantidad actualizada' +  CantidadActualizada);
                        System.debug('Devolucion parcial' +  Woli.Cantidad_devolucion__c);
                        Woli.Quantity = CantidadActualizada;
                        Woli.Cantidad_devolucion__c = 0;
                        
                        workOrderLineItemsToUpdate.add(Woli);
                        //update Woli;
                    } else {
                        res.responseBody = Blob.valueOf('{"message": "No se encontró ninguna línea con el Id especificado."}');
                        res.statusCode = 404;
                        return;
                    }
                } else {
                    res.responseBody = Blob.valueOf('{"message": "No se encontró ninguna orden de trabajo con el Id especificado."}');
                    res.statusCode = 404;
                    return;
                }
            }
            
            if(!workOrderLineItemsToUpdate.isEmpty()) {
                update workOrderLineItemsToUpdate;
                res.responseBody = Blob.valueOf('{"message": "Actualización realizada con éxito"}');
                res.statusCode = 200;
            }
            
        } catch(Exception e) {
            res.responseBody = Blob.valueOf('{"message": "Ocurrió un error en el proceso: ' + e.getMessage() + '"}');
            res.statusCode = 500;
        }
    }
    
    public class actualizarWoliRequest {
        public String numeroDeOrden;
        public String pedido;
        public String identificadorLineaOrdenTrabajo;
        public String codigoArticulo;
        public String estado;
        
    }
    
    public static List<actualizarWoliRequest> parseRespuesta(String json) {
        return (List<actualizarWoliRequest>) System.JSON.deserialize(json, List<actualizarWoliRequest>.class);
    }
    
}