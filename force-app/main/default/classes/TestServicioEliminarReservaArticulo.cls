@isTest
private class TestServicioEliminarReservaArticulo {
    
    // Mock class for HTTP callouts
    private class MockHttpCallout implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            // Create a fake response
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            // Modify this JSON to match the expected response from your service
            response.setBody('{"status":"success", "message":"Mock response"}');
            response.setStatusCode(200);
            return response;
        }
    }

    // Test method
    @isTest static void testEliminarReservaArticulos() {
        // Set up test data
        // Create and insert a WorkOrder and related WorkOrderLineItem records as per your schema
        // Example (adapt with your actual field names and data requirements):
        
        WorkOrder testWorkOrder = new WorkOrder();
        insert testWorkOrder;

        WorkOrderLineItem testLineItem = new WorkOrderLineItem( WorkOrderId = testWorkOrder.Id);
        insert testLineItem;
        
        //
        //
        Test.startTest();
        
        ActividadComercial__c actividad = new ActividadComercial__c(Name = 'VENTA DE REPUESTOS NUEVOS PARA AUTOMOVIL');
        insert actividad;
        
        tiposDeTrabajo__c tiposDeTrabajo = new tiposDeTrabajo__c(Name = 'Mantenimiento');
        insert tiposDeTrabajo;
                
        Product2 prod= new Product2();
        prod.IsActive=true;
        prod.Name='Test product Test';
        prod.ProductCode='0001999';
        prod.Codigo_de_Producto__c='00199999';
        insert prod;
        
        List<PricebookEntry> lstPBE = new List<PricebookEntry>();
        Id stdPriceBook =  Test.getStandardPricebookId();
        PricebookEntry pd1 = new PricebookEntry();
        pd1.UnitPrice = 1;
        pd1.CurrencyIsoCode = 'USD';
        pd1.Product2Id = prod.Id;
        pd1.Pricebook2Id = stdPriceBook;
        pd1.IsActive = true;
        lstPBE.add(pd1);
        
        Bodega__c b = new Bodega__c();
        insert b;
        
        ProductoXBodega__c pxb = new ProductoXBodega__c();
        pxb.Producto__c = prod.Id;
        pxb.Bodega__c = b.Id;
        pxb.Disponible__c = 12;
        insert pxb;

        // Insert PricebookEntry
        PricebookEntry standardPBE = [select id, Pricebook2Id, UnitPrice,IsActive,CurrencyIsoCode 
                                      from PricebookEntry 
                                      where Product2Id =:prod.Id 
                                      and CurrencyIsoCode = 'USD'
                                      limit 1];//new PricebookEntry(Pricebook2Id =pricebookId, Product2Id = prod.Id, UnitPrice = 999, IsActive = true);
        System.debug(standardPBE.CurrencyIsoCode);
        
        Pricebook2 pb = new Pricebook2();
        pb.Name='Dolar';
        pb.IsActive=true;
       
        insert pb;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        WorkOrder wo = new WorkOrder();
        wo.subject ='title';
        wo.Pricebook2Id=standardPBE.Pricebook2Id;
        wo.tipoDeGasto__c='Cliente';
        wo.CurrencyIsoCode = 'USD';
        insert wo;
        
        WorkOrder insertedWO = [SELECT Id, WorkOrderNumber FROM WorkOrder WHERE Id = :wo.Id];
        
        System.debug('WO NUMBEEEER   ' + wo.WorkOrderNumber + wo.Id);
        
        CentroCosto__c cc = new CentroCosto__c();
        insert cc;
        
        CentroCosto__c cc2 = new CentroCosto__c();
        insert cc2;
        
        CentroCosto__c cc3 = new CentroCosto__c();
        insert cc3;
        
        CentroCosto__c cc4 = new CentroCosto__c();
        insert cc4;
        
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.workOrderId = wo.Id;
        woli.description = 'abcd';
        woli.Quantity=2;
        woli.PricebookEntryId=standardPBE.Id;
        woli.centroCosto__c = cc.Id;
        woli.Cantidad_devolucion__c =1;
        insert woli;
        
        WorkOrderLineItem woli2 = new WorkOrderLineItem();
        woli2.workOrderId = wo.Id;
        woli2.description = 'abcd2';
        woli2.Quantity=3;
        woli2.PricebookEntryId=standardPBE.Id;
        woli2.centroCosto__c = cc.Id;
        insert woli2;
        
        WorkOrderLineItem woli3 = new WorkOrderLineItem();
        woli3.workOrderId = wo.Id;
        woli3.description = 'abcd3';
        woli3.Quantity=3;
        woli3.PricebookEntryId=standardPBE.Id;
        woli3.centroCosto__c = cc.Id;
        insert woli3;
        
        
        WorkOrderLineItem woli4 = new WorkOrderLineItem();
        woli4.workOrderId = wo.Id;
        woli4.description = 'abcd4';
        woli4.Quantity=3;
        woli4.PricebookEntryId=standardPBE.Id;
        woli4.centroCosto__c = cc.Id;
        insert woli4;

        List<String> lineItemIds = new List<String>{woli.id,woli2.id,woli3.id,woli4.id};

        ServicioEliminarReservaArticulo service = new ServicioEliminarReservaArticulo(insertedWO.WorkOrderNumber, lineItemIds);
        String result = service.eliminarReservaArticulos();

    }
}