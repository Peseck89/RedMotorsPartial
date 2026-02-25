@RestResource(urlMapping='/ServicioNotaCredito/*')
global with sharing class ServicioNotaCredito {

    // Define a class for the request body
    global class RequestBody {
        public String idOrden;
        public List<WOLI> workOrderLineItems;
    }

    // Define a class for work order line items
    global class WOLI {
        public String cantidad;
        public String idWorkOrderLineItem;
    }

    @HttpPost
    global static void doPost() {
        // Parse the JSON request body
        RequestBody reqBody = (RequestBody) JSON.deserialize(RestContext.request.requestBody.toString(), RequestBody.class);
        System.debug('Requjest body' + reqBody);
        System.debug('ID WorkOrder' + reqBody.idOrden);
        WorkOrder workOrder;

        try {
            // Perform SOQL query to retrieve the Work Order
            workOrder = [SELECT Id, isLocked__c, Etapa_de_flujo_de_trabajo__c, WorkOrderNumber FROM WorkOrder WHERE WorkOrderNumber = :reqBody.idOrden LIMIT 1];
            System.debug('WorkOrder ' + workOrder);
            // Update the Work Order fields
            //workOrder.isLocked__c = false;
            //workOrder.Nota_de_cr_dito_activa__c = true;
            //workOrder.Etapa_de_flujo_de_trabajo__c = 'En proceso';
            //update workOrder;
            
            System.debug('WOLIIIIS' + reqBody.workOrderLineItems);

            // Process and update each WorkOrderLineItem
            for (WOLI item : reqBody.workOrderLineItems) {
                List<WorkOrderLineItem> lineItems = [SELECT Id, Estado__c,Estado_entrega__c, Quantity FROM WorkOrderLineItem WHERE Id = :item.idWorkOrderLineItem LIMIT 1];
                if(lineItems.size() != 0){
                    WorkOrderLineItem lineItem = lineItems[0];                
                    if(Integer.valueOf(item.cantidad) == 0){
                        delete lineItem;
                    }else if(item.cantidad!=NULL && Integer.valueOf(item.cantidad) != lineItem.Quantity){
                        lineItem.Estado__c = '';
                        lineItem.Estado_entrega__c = 'Entregado';
                        lineItem.Quantity = Integer.valueOf(item.cantidad);
                        update lineItem;
                    }
                }                
            }
            RestContext.response.statusCode = 200;
            RestContext.response.responseBody = Blob.valueOf('Pedido actualizado con éxito');

        } catch(Exception e) {
            RestContext.response.statusCode = 400;
            RestContext.response.responseBody = Blob.valueOf('Error: ' + e.getMessage());
        }
    }
}