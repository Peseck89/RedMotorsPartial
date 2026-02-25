@isTest
private class TestConsultaDisponibleBodega {

    // Mock class for HTTP callouts
    

    // Test method for consultarDisponibilidad
    @isTest static void testConsultarDisponibilidad() {
        // Setup test data
        // You need to create a WorkOrder and any related records required for your test
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
        prod.ProductCode='00199999';
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
        woli2.description = 'abcd';
        woli2.Quantity=3;
        woli2.PricebookEntryId=standardPBE.Id;
        woli2.centroCosto__c = cc.Id;
        insert woli2;
        

        List<String> lineItemIds = new List<String>{woli.id,woli2.id};
            
         WoliGridWrapper wrapper1 = new WoliGridWrapper(
            woli.Id, // WorkOrderLineItem ID for wrapper1
            prod.Id, // Product ID
            prod.ProductCode, // Product Code
            prod.Name, // Product Name
            pd1.UnitPrice, // Unit Price
            b.Name, // Bodega Name
            pxb.Disponible__c, // Cantidad Disponible
            'Tipo1', // Product Type
            'Alias1', // Alias
            'Mantenimiento', // Tipo de Trabajo
            standardPBE.Id, // PriceBookEntry Id
            'USD', // Currency Code
            b.Id, // Bodega ID
            'BodegaExtID1', // External Bodega ID
            pxb.Id // ProductXBodega ID
        );

        WoliGridWrapper wrapper2 = new WoliGridWrapper(
            woli2.Id, // WorkOrderLineItem ID for wrapper2
            prod.Id, // Product ID
            prod.ProductCode, // Product Code
            prod.Name, // Product Name
            pd1.UnitPrice, // Unit Price
            b.Name, // Bodega Name
            pxb.Disponible__c, // Cantidad Disponible
            'Tipo2', // Product Type
            'Alias2', // Alias
            'Mantenimiento', // Tipo de Trabajo
            standardPBE.Id, // PriceBookEntry Id
            'USD', // Currency Code
            b.Id, // Bodega ID
            'BodegaExtID2', // External Bodega ID
            pxb.Id // ProductXBodega ID
        );
        
        
        System.debug('WOLI 1 codep  ' + prod.ProductCode);
        System.debug('WOLI 2 codep  ' + prod.ProductCode);

        List<WoliGridWrapper> testWrappers = new List<WoliGridWrapper>{wrapper1, wrapper2 };

        // Set mock callout class
        //Test.setMock(HttpCalloutMock.class, new MockHttpCallout());

        

        // Call the method under test
        List<WoliGridWrapper> result = consultaDisponibleBodega.consultarDisponibilidad(testWrappers, insertedWO.WorkOrderNumber);

        Test.stopTest();
    }

    // You might need to define any inner classes (like WoliGridWrapper) used in consultaDisponibleBodega
    // if they are not already publicly accessible
}