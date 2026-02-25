@isTest
public class ServicioGenerarPedidoFlow_Test {
    private class MockErrorHttpResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            // Create a fake response
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(  '{"operationResult":{"code":"00","description":"1","PageSize":1,"PageNo":1,"PageCount":1,"Data":[{"telefono2":null,"telefono1":null,"provincia":null,"pais":null,"otras_senas":null,"nombre":null,"moneda":null,"id":null,"distrito":null,"contacto":null,"condicionPago":"test","cliente":"df","cargo":null,"canton":null,"barrio":null,"alias":null}]},"Data":[]}');
            response.setStatusCode(200);
            return response;
        }
    }
    
     private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            // Create a fake response
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody( '{"operationResult":{"code":"00","description":"1","PageSize":1,"PageNo":1,"PageCount":1,"Data":[{"telefono2":null,"telefono1":null,"provincia":null,"pais":null,"otras_senas":null,"nombre":null,"moneda":null,"id":null,"distrito":null,"contacto":null,"condicionPago":"test","cliente":"df","cargo":null,"canton":null,"barrio":null,"alias":null}]},"Data":[{"telefono2":null,"telefono1":null,"provincia":null,"pais":null,"otras_senas":null,"nombre":null,"moneda":null,"id":null,"distrito":null,"contacto":null,"condicionPago":"test","cliente":"df","cargo":null,"canton":null,"barrio":null,"alias":null}]}');
            response.setStatusCode(200);
            return response;
        }
    }
	@isTest
    static void generarPedidoTest() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        // Set up test data
        
		Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Cedula__c = '211234661';
        insert acc;
        
        condicionPago__c condicionPago = new condicionPago__c();
        condicionPago.condicionPago__c='0';
        condicionPago.Descripcion__c='test desc';
        condicionPago.Name='CONTADO';
        insert condicionPago;
        
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
        testWorkOrder.AccountId = acc.id;
        testWorkOrder.Cuenta_de_Facturacion__c = acc.id;
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

        //insert new List<WorkOrderLineItem>{testLineItem1, testLineItem2};

            
        WorkOrder insertedWO = [SELECT Id, WorkOrderNumber FROM WorkOrder WHERE Id = :testWorkOrder.Id];
 
        // Test data setup
        // Create necessary test data, such as Account, WorkOrder, etc.
		 
        Test.startTest();

        // Call the method to be tested
        //ServicioGenerarPedidoFlow.generarPedido(new List<Id>{ insertedWO.id });

        // Assert statements
        // Verify the expected results after the method is called
        // Use System.assert, System.assertEquals, or System.assertNotEquals

        Test.stopTest();
    }

    @isTest
    static void getWorkOrderTest() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        // Test data setup
        // Create necessary test data, such as WorkOrder record
		Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Cedula__c = '211234661';
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
        testWorkOrder.AccountId = acc.id;
        testWorkOrder.Cuenta_de_Facturacion__c = acc.id;
        testWorkOrder.Pricebook2Id=standardPBE.Pricebook2Id;
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

        //insert new List<WorkOrderLineItem>{testLineItem1, testLineItem2};

            
        WorkOrder insertedWO = [SELECT Id, WorkOrderNumber FROM WorkOrder WHERE Id = :testWorkOrder.Id];
 
        Test.startTest();

        // Call the method to be tested
        WorkOrder wo = ServicioGenerarPedidoFlow.getWorkOrder(insertedWO.id);

        // Assert statements
        // Verify the expected results after the method is called
        // Use System.assert, System.assertEquals, or System.assertNotEquals

        Test.stopTest();
    }
    
    @isTest
    static void getWorkOrderErrorTest() {
        Test.setMock(HttpCalloutMock.class, new MockErrorHttpResponseGenerator());
        // Test data setup
        // Create necessary test data, such as WorkOrder record
		Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Cedula__c = '211234661';
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
        testWorkOrder.AccountId = acc.id;
        testWorkOrder.Cuenta_de_Facturacion__c = acc.id;
        testWorkOrder.Pricebook2Id=standardPBE.Pricebook2Id;
        insert testWorkOrder;
		
        Bodega__c bodeg = new Bodega__c();
        bodeg.Name = 'B01';
        insert bodeg;
        
        // Create WorkOrderLineItem records as needed
        WorkOrderLineItem testLineItem1 = new WorkOrderLineItem();
        testLineItem1.workOrderId = testWorkOrder.Id;
        testLineItem1.description = 'abcd';
        testLineItem1.Quantity=2;
        testLineItem1.Bodega__c = bodeg.id;
        testLineItem1.trabajo__c = 'Materiales';
        testLineItem1.PricebookEntryId=standardPBE.Id;
        testLineItem1.Cantidad_devolucion__c =1;
        testLineItem1.descuento__c = 1;
        testLineItem1.UnitPrice = 1;
        insert testLineItem1;
		
        /*
        WorkOrderLineItem testLineItem2 = new WorkOrderLineItem();
        testLineItem2.workOrderId = testWorkOrder.Id;
        testLineItem2.description = 'abcd';
        testLineItem2.Quantity=3;
        testLineItem2.descuento__c = 1;
        testLineItem2.UnitPrice = 1;
        testLineItem2.Bodega__c = bodeg.id;
        testLineItem2.trabajo__c = 'Materiales';
        testLineItem2.PricebookEntryId=standardPBE.Id;
        insert testLineItem2;
		*/
		condicionPago__c condicionPago = new condicionPago__c(); 
        condicionPago.condicionPago__c = '0';
        insert condicionPago;
        
        TipoCargo__c tipoCargo = new TipoCargo__c();
        tipoCargo.tipoCargo__c = '1';
        tipoCargo.porcentaje__c = 100;

        tipoCargo.Work_Order_Line_Item__c = testLineItem1.id;
        insert tipoCargo;
        //insert new List<WorkOrderLineItem>{testLineItem1, testLineItem2};

            
        WorkOrder insertedWO = [SELECT Id, WorkOrderNumber FROM WorkOrder WHERE Id = :testWorkOrder.Id];
 
        Test.startTest();

        // Call the method to be tested
        //
        ServicioGenerarPedidoFlow.setdummyTest(); 
        ServicioGenerarPedidoFlow.generarPedido(new List<Id>{ insertedWO.id });

        // Assert statements
        // Verify the expected results after the method is called
        // Use System.assert, System.assertEquals, or System.assertNotEquals

        Test.stopTest();
    }

    // Add more test methods as needed for different scenarios
  
}