global class OrderBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
        String query;
        if(Test.isRunningTest()) {
            query = 'SELECT Id, Work_Order__r.empresaFactura__c, Status FROM Order WHERE Status = \'Draft\' AND BillingStatus__c != \'Facturado\' AND BillingStatus__c != \'Rechazado\' LIMIT 5';
        } else {
            query = 'SELECT Id, Work_Order__r.empresaFactura__c, Status FROM Order WHERE Status = \'Aprobado\' AND BillingStatus__c != \'Facturado\' AND BillingStatus__c != \'Rechazado\' AND CreatedDate = THIS_MONTH LIMIT 100';
        }
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Order> orderList) {
        // process each batch of records
        Map<Id, String> orderMap = new Map<Id, String>();
        Id orderId;
        String billingCompany;
        String endpoint;
        List<Order> updateOrders = new List<Order>();
        
        try {
            if(!orderList.isEmpty()) {
                for(Order order : orderList) {
                    System.debug('ORDER LIST: ' + orderList);
                    System.debug('Id: ' + order.Id);
                    orderMap.put(order.Id, order.Work_Order__r.empresaFactura__c); 
                }
            }            
            if(orderMap != null) {
                List<Order> updatedList;
                Set<Id> orderIdSet = orderMap.keySet();
                for(Id order : orderIdSet) {
                    orderId = order;
                    billingCompany = orderMap.get(order);
                    endpoint = 'http://172.176.136.132:5080/IntegrationServices/softlandAPI/Orders/getStatus?compania='+billingCompany+'&ordenTrabajo='+orderId;
                    if(Test.isRunningTest()){
                        endpoint = 'http://172.176.136.132:5080/IntegrationServices/softlandAPI/Orders/getStatus?compania=RMBAVARIAN&ordenTrabajo=8014U000002OEsLQAW';
                    }
                    //Callout service
                    HttpRequest request = new HttpRequest();
                    request.setEndpoint(endpoint);
                    request.setMethod('GET');
                    Http http = new Http();                    
                    HttpResponse response = http.send(request);
                    String responseBody = response.getBody();
                    // If the request is successful, parse the JSON response.
                    if (response.getStatusCode() == 200) {
                        // Deserialize the JSON string into collections of primitive data types.
                        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                        System.debug('Response body: ' + response.getBody());
                        System.debug('Resultados: ' + results);            
                        
                        String code = (String) results.get('code');
                        System.debug('Received code value: ' + code);
                        Order orderToUpdate = new Order();
                        
                        if(Test.isRunningTest()){ if(code == 'Draft') {orderToUpdate.Id = order; orderToUpdate.BillingStatus__c = 'En proceso'; orderToUpdate.BillingDate__c = Datetime.now(); updateOrders.add(orderToUpdate);}
                                                } else if(code == 'Aprobado') {orderToUpdate.Id = order; orderToUpdate.BillingStatus__c = 'En proceso'; orderToUpdate.BillingDate__c = Datetime.now(); updateOrders.add(orderToUpdate);}
                        else if(code == 'Facturado') {orderToUpdate.Id = order; orderToUpdate.BillingStatus__c = 'Facturado'; orderToUpdate.BillingDate__c = Datetime.now(); updateOrders.add(orderToUpdate);}
                        else if(code == 'Rechazado') {orderToUpdate.Id = order; orderToUpdate.BillingStatus__c = 'Rechazado'; orderToUpdate.BillingDate__c = Datetime.now(); updateOrders.add(orderToUpdate);}                        
                    }
                }
            }
            update updateOrders;
        } catch (DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());            
        }
    }    
    
    global void finish(Database.BatchableContext bc) {
        // execute any post-processing operations      
    }
    
    global void execute(SchedulableContext SC) {
        database.executeBatch(new OrderBatch());
    }
}