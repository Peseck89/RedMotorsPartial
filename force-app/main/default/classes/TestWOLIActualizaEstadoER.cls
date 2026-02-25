@isTest
private class TestWOLIActualizaEstadoER {

    @isTest static void testProcessRequest() {
        // Set up test data
        ActividadComercial__c act = new ActividadComercial__c();
        act.Name = 'VENTA DE REPUESTOS NUEVOS PARA AUTOMOVIL';
        insert act;
        
        condicionPago__c condicionPagoWO2 = new condicionPago__c();
        condicionPagoWO2.condicionPago__c='0';
        condicionPagoWO2.Descripcion__c='test desc';
        condicionPagoWO2.Name='CONTADO';
        insert condicionPagoWO2;
        
        Account acc= new Account();
        acc.Name='Test account';
        acc.Cedula__c='9876543210';
        acc.Tipo_de_Documento__c='02';
        //acc.condicionPago__c=condicionPago.Id;
        //acc.Impuesto__c=Impuesto.Id;
        
        insert acc;
        
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
        
        WorkOrder testWorkOrder = new WorkOrder();
        testWorkOrder.Pricebook2Id=standardPBE.Pricebook2Id;
        testWorkOrder.AccountId = acc.Id;
        insert testWorkOrder;

        // Create WorkOrderLineItem records as needed
        WorkOrderLineItem testLineItem1 = new WorkOrderLineItem();
        testLineItem1.workOrderId = testWorkOrder.Id;
        testLineItem1.description = 'abcd';
        testLineItem1.Quantity=2;
        testLineItem1.PricebookEntryId=standardPBE.Id;
        testLineItem1.Cantidad_devolucion__c =1;
        insert testLineItem1;

        WorkOrderLineItem testLineItem2 = new WorkOrderLineItem();
        testLineItem2.workOrderId = testWorkOrder.Id;
        testLineItem2.description = 'abcd';
        testLineItem2.Quantity=3;
        testLineItem2.PricebookEntryId=standardPBE.Id;
        insert testLineItem2;
        
        
        WorkOrderLineItem testLineItem3 = new WorkOrderLineItem();
        testLineItem3.workOrderId = testWorkOrder.Id;
        testLineItem3.description = 'abcd';
        testLineItem3.Quantity=2;
        testLineItem3.PricebookEntryId=standardPBE.Id;
        testLineItem3.Cantidad_devolucion__c =1;
        insert testLineItem3;

        //insert new List<WorkOrderLineItem>{testLineItem1, testLineItem2};

            
        WorkOrder insertedWO = [SELECT Id, WorkOrderNumber FROM WorkOrder WHERE Id = :testWorkOrder.Id];
 
        // Prepare the request body
        WOLIActualizaEstadoER.RequestBody requestBody = new WOLIActualizaEstadoER.RequestBody();
        
        
        System.debug('JSON WorkOrderNumber' + insertedWO.WorkOrderNumber);
        
        requestBody.orden_trabajo = insertedWO.WorkOrderNumber;
        requestBody.articulos = new List<WOLIActualizaEstadoER.Articulo>();

        WOLIActualizaEstadoER.Articulo articulo1 = new WOLIActualizaEstadoER.Articulo();
        articulo1.id_linea = testLineItem1.Id;
        articulo1.estadoReserva = 'Reservado';
        articulo1.estado = 'Entregado';
        
        WOLIActualizaEstadoER.Articulo articulo3 = new WOLIActualizaEstadoER.Articulo();
        articulo3.id_linea = testLineItem3.Id;
        articulo3.estadoReserva = 'Reservado';
        articulo3.estado = 'Pendiente devolución nota de crédito';
        

        WOLIActualizaEstadoER.Articulo articulo2 = new WOLIActualizaEstadoER.Articulo();
        articulo2.id_linea = testLineItem2.Id;
        articulo2.estadoReserva = 'Eliminado';
        articulo2.estado = 'Eliminado';


        requestBody.articulos.add(articulo1);
        requestBody.articulos.add(articulo2);
        requestBody.articulos.add(articulo3);

        // Mock HTTP request and response
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestBody = Blob.valueOf(JSON.serialize(requestBody));
        req.httpMethod = 'POST';

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        WOLIActualizaEstadoER.processRequest();
        Test.stopTest();

        // Assertions
        //System.assertEquals(200, res.statusCode, 'Status code should be 200');
        // Additional assertions to verify the response and any changes to data
    }
}