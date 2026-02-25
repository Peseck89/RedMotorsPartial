@RestResource(urlMapping='/ServicioSoftlandActualiza')
global class ServicioSoftlandActualiza {

    global class RequestBody {
        public String orden_trabajo;
        public List<Articulo> articulos;
    }
    
    global class Articulo {
            public String id_linea;
            public String localizacion;
       		public String estado;
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
        
        List<WorkOrderLineItem> itemsToUpdate = new List<WorkOrderLineItem>();
        for (Articulo art : body.articulos) {
            if (mapLineItems.containsKey(art.id_linea)) {
                WorkOrderLineItem item = mapLineItems.get(art.id_linea);
                
                item.Localizacion__c = art.localizacion;
                item.Estado_reserva__c = art.estado;
                itemsToUpdate.add(item);
                
                ResponseItem respItem = new ResponseItem();
                respItem.id = art.id_linea;
                respItem.status = 'Actualizado';
                responseItems.add(respItem);
            } else {
                ResponseItem respItem = new ResponseItem();
                respItem.id = art.id_linea;
                respItem.status = 'No encontrado';
                responseItems.add(respItem);
            }
        }
        update itemsToUpdate;
        
        res.statusCode = 200;
        response.put('items', responseItems);
        System.debug('Final Response ' + JSON.serialize(response));
        res.responseBody = Blob.valueOf(JSON.serialize(response));
    }
}