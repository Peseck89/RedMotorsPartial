@RestResource(urlMapping='/WOLIActualizaEstadoER')
global class WOLIActualizaEstadoER {

    global class RequestBody {
        public String compania;
        public String orden_trabajo;
        public List<Articulo> articulos;
    }
    
    global class Articulo {
            public String id_linea;
            public String estado;
            public String estadoReserva;
        }

    public class ResponseItem {
        public String id;
        public String status;
    }

    @HttpPost
    global static void processRequest(){   //RequestBody body) {
        System.debug('Antes de llamada ');
        RestRequest req = RestContext.request;
    	RequestBody body = (RequestBody)JSON.deserialize(req.requestBody.toString(), RequestBody.class);
        
        RestResponse res = RestContext.response;
        
        System.debug(res);
        System.debug(body);
        
        if(res == null) {
            res = new RestResponse();
            RestContext.response = res;
        }

        Map<String, Object> response = new Map<String, Object>();
        List<ResponseItem> responseItems = new List<ResponseItem>();
        
        System.debug('JSON Body ' + body);

        List<WorkOrder> orders = [SELECT Id FROM WorkOrder WHERE WorkOrderNumber = :body.orden_trabajo LIMIT 1];

        if (orders.isEmpty()) {
            System.debug('Orden VACIA');
            res.statusCode = 404;
            response.put('error', 'Orden de trabajo no encontrada.');
            res.responseBody = Blob.valueOf(JSON.serialize(response));
            return;
        }
        
        List<String> lineIds = new List<String>();
        for (Articulo art : body.articulos) {
            System.debug('FOR ARTICULOS');
            lineIds.add(art.id_linea);
        }

        List<WorkOrderLineItem> lineItems = [SELECT Id, Estado_entrega__c,Estado_softland__c,Cantidad_devolucion__c,Quantity, Estado_reserva__c FROM WorkOrderLineItem WHERE Id IN :lineIds];
        Map<String, WorkOrderLineItem> mapLineItems = new Map<String, WorkOrderLineItem>();
        for (WorkOrderLineItem item : lineItems) {
            System.debug('FOR');
            mapLineItems.put(item.Id, item);
        }
        
		boolean OTNotaCredito = False;
        List<WorkOrderLineItem> itemsToUpdate = new List<WorkOrderLineItem>();
        List<WorkOrderLineItem> itemsToDelete = new List<WorkOrderLineItem>();
        for (Articulo art : body.articulos) {
            if (mapLineItems.containsKey(art.id_linea)) {
                WorkOrderLineItem item = mapLineItems.get(art.id_linea);
                
                if (String.isNotBlank(art.estado)) {
                    if(art.estado == 'Eliminado'){
                        itemsToDelete.add(item);
                        
                    }else{
                        if(art.estado == 'Pendiente devolución nota de crédito' ){
                            OTNotaCredito = true;                            
                        }
                        
                        if(item.Cantidad_devolucion__c == null ){
                            item.Cantidad_devolucion__c = 0;                            
                        }
                        
                        if(art.estado == 'DEVOLUCION' ){
                            item.Estado_entrega__c = 'Pendiente de devolución';                            
                        }else{
                            item.Estado_entrega__c = art.estado;
                        }
                        
                        //system.debug('Estado Softland ' +  art.estado);
                        
                        item.Estado_softland__c = '';
                        Double CantidadActualizada = item.Quantity - item.Cantidad_devolucion__c;
                        System.debug('Cantidad actualizada' +  CantidadActualizada);
                        System.debug('Devolucion parcial' +  item.Cantidad_devolucion__c);
                        item.Quantity = CantidadActualizada;
                        item.Cantidad_devolucion__c = 0;
                        
                        itemsToUpdate.add(item);
        
                        ResponseItem respItem = new ResponseItem();
                        respItem.id = art.id_linea;
                        respItem.status = 'Actualizado';
                        responseItems.add(respItem);
                    }            
                        
                }
                
                
            } else {
                ResponseItem respItem = new ResponseItem();
                respItem.id = art.id_linea;
                respItem.status = 'No encontrado';
                responseItems.add(respItem);
            }
        }
        
         if(OTNotaCredito == true ){
             orders[0].isLocked__c = false;
             orders[0].Nota_de_cr_dito_activa__c = true;
             orders[0].Etapa_de_flujo_de_trabajo__c = 'En proceso';
             update orders[0];                         
         }
        
        

        update itemsToUpdate;
        delete itemsToDelete;
        
        res.statusCode = 200;
        response.put('items', responseItems);
        System.debug('Final Response ' + JSON.serialize(response));
        res.responseBody = Blob.valueOf(JSON.serialize(response));
    }
}