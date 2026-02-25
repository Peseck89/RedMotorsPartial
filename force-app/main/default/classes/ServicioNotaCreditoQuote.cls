@RestResource(urlMapping='/ServicioNotaCreditoQuote/*')
global with sharing class ServicioNotaCreditoQuote {

    // Define a class for the request body
    global class RequestBody {
        public String quote_salesforce;
        public List<QUOLI> articulos;
    }

    // Define a class for work order line items
    global class QUOLI {
        public String cantidad;
        //public String estado;
        public String id_linea;
    }

    @HttpPost
    global static void doPost() {
        // Parse the JSON request body
        RequestBody reqBody = (RequestBody) JSON.deserialize(RestContext.request.requestBody.toString(), RequestBody.class);
        System.debug('Requjest body' + reqBody);
        System.debug('ID WorkOrder' + reqBody.quote_salesforce);
        Quote quote;

        try {
            quote = [SELECT Id, isLocked__c, Quote_Number__c FROM Quote WHERE Quote_Number__c = :reqBody.quote_salesforce LIMIT 1];
            System.debug('WorkOrder ' + quote);
            // Update the Work Order fields
            quote.isLocked__c = false;
            quote.Nota_de_cr_dito_activa__c = true;
            //workOrder.Etapa_de_flujo_de_trabajo__c = 'En proceso';
            update quote;
            
            System.debug('WOLIIIIS' + reqBody.articulos);

            // Process and update each WorkOrderLineItem
            for (QUOLI item : reqBody.articulos) {
                List<Quotelineitem> lineItems = [SELECT Id,Estado_entrega__c, Quantity FROM Quotelineitem WHERE Id = :item.id_linea LIMIT 1];
                if(lineItems.size() != 0){
                    Quotelineitem lineItem = lineItems[0];                
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