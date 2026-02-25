@isTest
public class ServicioNotaCreditoTest {
    @isTest static void testProcessRequest() {
        // Set up test data
        
        
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
        
        Account acc= new Account();
        acc.Name='Test account';
        acc.Cedula__c='9876543210';
        acc.Tipo_de_Documento__c='02';
        //acc.condicionPago__c=condicionPago.Id;
        //acc.Impuesto__c=Impuesto.Id;
        
        insert acc;
        
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
        
        condicionPago__c condicionPago = new condicionPago__c();
        condicionPago.condicionPago__c='0';
        condicionPago.Descripcion__c='test desc';
        condicionPago.Name='CONTADO';
        insert condicionPago;
        
        
        ActividadComercial__c ActividadComercial = new ActividadComercial__c();
        ActividadComercial.Name = 'VENTA DE REPUESTOS NUEVOS PARA AUTOMOVIL';
        insert ActividadComercial;
        
        condicionPago__c condicionPagoB = [SELECT Id FROM condicionPago__c WHERE condicionPago__c = '0'];
            
        WorkOrder testWorkOrder = new WorkOrder();
        testWorkOrder.Pricebook2Id=standardPBE.Pricebook2Id;
        testWorkOrder.AccountId=acc.Id;
        insert testWorkOrder;

        // Create WorkOrderLineItem records as needed
        WorkOrderLineItem testLineItem1 = new WorkOrderLineItem();
        testLineItem1.workOrderId = testWorkOrder.Id;
        testLineItem1.description = 'abcd';
        testLineItem1.Quantity=4;
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
        testLineItem3.Quantity=3;
        testLineItem3.PricebookEntryId=standardPBE.Id;
        insert testLineItem3;

        //insert new List<WorkOrderLineItem>{testLineItem1, testLineItem2};

            
        WorkOrder insertedWO = [SELECT Id, WorkOrderNumber FROM WorkOrder WHERE Id = :testWorkOrder.Id];
 
        // Prepare the request body
        ServicioNotaCredito.RequestBody requestBody = new ServicioNotaCredito.RequestBody();
        
        
        
        
        requestBody.idOrden = insertedWO.WorkOrderNumber;
        requestBody.workOrderLineItems = new List<ServicioNotaCredito.WOLI>();

        ServicioNotaCredito.WOLI articulo1 = new ServicioNotaCredito.WOLI();
        articulo1.idWorkOrderLineItem = testLineItem1.Id;
        articulo1.cantidad = '1';

        ServicioNotaCredito.WOLI articulo2 = new ServicioNotaCredito.WOLI();
        articulo2.idWorkOrderLineItem = testLineItem2.Id;
        articulo2.cantidad = '0';
        
        ServicioNotaCredito.WOLI articulo3 = new ServicioNotaCredito.WOLI();
        articulo3.idWorkOrderLineItem = testLineItem2.Id;


        requestBody.workOrderLineItems.add(articulo1);
        requestBody.workOrderLineItems.add(articulo2);
        requestBody.workOrderLineItems.add(articulo3);

        // Mock HTTP request and response
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestBody = Blob.valueOf(JSON.serialize(requestBody));
        req.httpMethod = 'POST';

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        ServicioNotaCredito.doPost();
        Test.stopTest();

    }

}