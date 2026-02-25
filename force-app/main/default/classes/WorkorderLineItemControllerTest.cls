@isTest(SeeAllData=false)
public class WorkorderLineItemControllerTest {
    
    @isTest(seeAllData=false)
    public static void testWorkorderLineItemController(){
        
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
        insert woli;
        
        categoriaCliente__c cet = new categoriaCliente__c();
        cet.categoriaCliente__c = 'COM';
        insert cet;
        
        condicionPago__c condicionPago = new condicionPago__c();
        condicionPago.condicionPago__c='0';
        condicionPago.Descripcion__c='test desc';
        condicionPago.Name='test cp';
        insert condicionPago;

        Impuesto__c Impuesto = new Impuesto__c();
        Impuesto.codigoImpuesto__c='0108';
        Impuesto.descripcion__c='test desc';
        Impuesto.Impuesto__c=2;
        Impuesto.Name='IVA-Tarifa General 13%';
        Impuesto.porcentaje__c=3;
        insert Impuesto;
        
        Account acc= new Account();
        acc.Name='Test account';
        acc.Cedula__c='9876543210';
        acc.Tipo_de_Documento__c='02';
        acc.condicionPago__c=condicionPago.Id;
        acc.Impuesto__c=Impuesto.Id;
        insert acc;
        
        //wo.AccountId=acc.Id;
        
        WorkOrder tmp1 = [Select PriceBook2Id from WorkOrder Where Id = :wo.id];
        WorkOrderLineItem tmp2 = [Select PricebookEntry.pricebook2Id from WorkOrderLineItem Where Id = :woli.id];
        
        
        ProductConsumed pc = new ProductConsumed();
        pc.WorkorderId = wo.Id;
        pc.PriceBookEntryId = standardPBE.Id;
        pc.QuantityConsumed = 1;
        insert pc;
        ApexPages.StandardController controller = new ApexPages.StandardController(wo);
        ApexPages.currentPage().getParameters().put('WorkOrder_lkid', wo.Id);
        WorkorderLineItemController cntrl = new WorkorderLineItemController(controller);
        cntrl.saveWLI();
        //cntrl.getBodegas();
        WorkorderLineItemController.searchProducts('er', wo.Pricebook2Id);
        tipoCargo__c tipoCargo = [Select Id, tipoCargo__c From tipoCargo__c Where Work_Order_Line_Item__c =: woli.Id Limit 1];
        tipoCargo.tipoCargo__c = '2';
        update tipoCargo;
        wo.Etapa_de_flujo_de_trabajo__c='Orden Facturada';
        update wo;
        woli.Cantidad__c = 2;
        update woli;
        delete woli;
        Test.stopTest();
    }
    
    @isTest(seeAllData=false)
    public static void testWorkorderLineItemController2(){
        
        Test.startTest();
        ActividadComercial__c actividad = new ActividadComercial__c(Name = 'VENTA DE REPUESTOS NUEVOS PARA AUTOMOVIL');
        insert actividad;
        
        tiposDeTrabajo__c tiposDeTrabajo = new tiposDeTrabajo__c(Name = 'Mantenimiento');
        insert tiposDeTrabajo;
        
        //Insert product       
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

        /*PricebookEntry pd2 = new PricebookEntry();
        pd2.UnitPrice = 1;
        pd2.CurrencyIsoCode = 'CRC';
        pd2.Product2Id = prod.Id;
        pd2.Pricebook2Id = stdPriceBook;
        pd2.IsActive = true;
        lstPBE.add(pd2);
        insert lstPBE;
        */
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
        //pb.IsStandard=true;
        insert pb;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        WorkOrder wo = new WorkOrder();
        wo.subject ='title';
        wo.Pricebook2Id=standardPBE.Pricebook2Id;
        //wo.tipoDeGasto__c='Garantía';
        //wo.Etapa_de_flujo_de_trabajo__c='Aprobación de presupuesto';
        System.debug(wo.CurrencyIsoCode);
        wo.CurrencyIsoCode = 'USD';
        insert wo;
        
        //Esteban Segura Benavides 14-01-2022
        //WorkOrder wo2 = new WorkOrder();
        //wo2.subject ='title';
        //wo2.Pricebook2Id=standardPBE.Pricebook2Id;
        //wo2.tipoDeGasto__c='Garantía';
        ////wo.Etapa_de_flujo_de_trabajo__c='Aprobación de presupuesto';
        //System.debug(wo2.CurrencyIsoCode);
        //insert wo2;
        
        //WorkOrder wo3 = new WorkOrder();
        //wo3.subject ='title';
        //wo3.Pricebook2Id=standardPBE.Pricebook2Id;
        //wo3.tipoDeGasto__c='BCI';
        //wo.Etapa_de_flujo_de_trabajo__c='Aprobación de presupuesto';
        //insert wo3;
        
        //WorkOrder wo4 = new WorkOrder();
        //wo4.subject ='title';
        //wo4.Pricebook2Id=standardPBE.Pricebook2Id;
        //wo4.tipoDeGasto__c='Aseguradora';
        ////wo.Etapa_de_flujo_de_trabajo__c='Aprobación de presupuesto';
        //insert wo4;
        
        //insert standardPBE;
        
        CentroCosto__c cc = new CentroCosto__c();
        insert cc;
        
        CentroCosto__c cc2 = new CentroCosto__c();
        insert cc2;
        
        CentroCosto__c cc3 = new CentroCosto__c();
        insert cc3;
        
        CentroCosto__c cc4 = new CentroCosto__c();
        insert cc4;
        
        /*PricebookEntry standardPrice = new PricebookEntry();
        standardPrice.Pricebook2Id =  pricebookId;
        standardPrice.Product2Id = prod.Id;
        standardPrice.UnitPrice = 1;
        standardPrice.IsActive = true;
        standardPrice.UseStandardPrice = false;
        insert standardPrice ;*/
        
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.workOrderId = wo.Id;
        woli.description = 'abcd';
        woli.Quantity=2;
        woli.PricebookEntryId=standardPBE.Id;
        woli.centroCosto__c = cc.Id;
        insert woli;
        
        categoriaCliente__c cet = new categoriaCliente__c();
        cet.categoriaCliente__c = 'COM';
        insert cet;
        
        condicionPago__c condicionPago = new condicionPago__c();
        condicionPago.condicionPago__c='0';
        condicionPago.Descripcion__c='test desc';
        condicionPago.Name='test cp';
        insert condicionPago;

        Impuesto__c Impuesto = new Impuesto__c();
        Impuesto.codigoImpuesto__c='0108';
        Impuesto.descripcion__c='test desc';
        Impuesto.Impuesto__c=2;
        Impuesto.Name='IVA-Tarifa General 13%';
        Impuesto.porcentaje__c=3;
        insert Impuesto;
        
        Account acc= new Account();
        acc.Name='Test account';
        acc.Cedula__c='9876543210';
        acc.Tipo_de_Documento__c='02';
        acc.condicionPago__c=condicionPago.Id;
        acc.Impuesto__c=Impuesto.Id;
        insert acc;
        
        //update work Order:
        //

        //wo.Etapa_de_flujo_de_trabajo__c='Aprobación de presupuesto';
        wo.AccountId=acc.Id;
        //wo.Pricebook2Id=pricebookId;
        
        WorkOrder tmp1 = [Select PriceBook2Id from WorkOrder Where Id = :wo.id];
        WorkOrderLineItem tmp2 = [Select PricebookEntry.pricebook2Id from WorkOrderLineItem Where Id = :woli.id];
        system.debug('zzzz:'+tmp1.Pricebook2Id);
        system.debug('zz:'+tmp2.PricebookEntry.pricebook2Id);
        system.debug('dolar pricebook id:'+pb.Id);
        
        update wo;
        
        ProductConsumed pc = new ProductConsumed();
        pc.WorkorderId = wo.Id;
        pc.PriceBookEntryId = standardPBE.Id;
        pc.QuantityConsumed = 1;
        insert pc;
        ApexPages.StandardController controller = new ApexPages.StandardController(wo);
        ApexPages.currentPage().getParameters().put('WorkOrder_lkid', wo.Id);
        WorkorderLineItemController cntrl = new WorkorderLineItemController(controller);
        cntrl.saveWLI();
        //cntrl.getBodegas();
        WorkorderLineItemController.searchProducts('er', wo.Pricebook2Id);
        Test.stopTest();
    }
    
    @isTest(seeAllData=false)
    public static void testWorkorderLineItemController3(){
        
        Test.startTest();
        
        ActividadComercial__c actividad = new ActividadComercial__c(Name = 'VENTA DE REPUESTOS NUEVOS PARA AUTOMOVIL');
        insert actividad;
        
        tiposDeTrabajo__c tiposDeTrabajo = new tiposDeTrabajo__c(Name = 'Mantenimiento');
        insert tiposDeTrabajo;
        
        //Insert product        
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

        /*PricebookEntry pd2 = new PricebookEntry();
        pd2.UnitPrice = 1;
        pd2.CurrencyIsoCode = 'CRC';
        pd2.Product2Id = prod.Id;
        pd2.Pricebook2Id = stdPriceBook;
        pd2.IsActive = true;
        lstPBE.add(pd2);
        insert lstPBE;
        */
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
        //pb.IsStandard=true;
        insert pb;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        WorkOrder wo = new WorkOrder();
        wo.subject ='title';
        wo.Pricebook2Id=standardPBE.Pricebook2Id;
        wo.tipoDeGasto__c='BCI';
        wo.CurrencyIsoCode = 'USD';
        //wo.Etapa_de_flujo_de_trabajo__c='Aprobación de presupuesto';
        System.debug(wo.CurrencyIsoCode);
        insert wo;
        
        //Esteban Segura Benavides 14-01-2022
        //WorkOrder wo2 = new WorkOrder();
        //wo2.subject ='title';
        //wo2.Pricebook2Id=standardPBE.Pricebook2Id;
        //wo2.tipoDeGasto__c='Garantía';
        ////wo.Etapa_de_flujo_de_trabajo__c='Aprobación de presupuesto';
        //System.debug(wo2.CurrencyIsoCode);
        //insert wo2;
        
        //WorkOrder wo3 = new WorkOrder();
        //wo3.subject ='title';
        //wo3.Pricebook2Id=standardPBE.Pricebook2Id;
        //wo3.tipoDeGasto__c='BCI';
        //wo.Etapa_de_flujo_de_trabajo__c='Aprobación de presupuesto';
        //insert wo3;
        
        //WorkOrder wo4 = new WorkOrder();
        //wo4.subject ='title';
        //wo4.Pricebook2Id=standardPBE.Pricebook2Id;
        //wo4.tipoDeGasto__c='Aseguradora';
        ////wo.Etapa_de_flujo_de_trabajo__c='Aprobación de presupuesto';
        //insert wo4;
        
        //insert standardPBE;
        
        CentroCosto__c cc = new CentroCosto__c();
        insert cc;
        
        CentroCosto__c cc2 = new CentroCosto__c();
        insert cc2;
        
        CentroCosto__c cc3 = new CentroCosto__c();
        insert cc3;
        
        CentroCosto__c cc4 = new CentroCosto__c();
        insert cc4;
        
        /*PricebookEntry standardPrice = new PricebookEntry();
        standardPrice.Pricebook2Id =  pricebookId;
        standardPrice.Product2Id = prod.Id;
        standardPrice.UnitPrice = 1;
        standardPrice.IsActive = true;
        standardPrice.UseStandardPrice = false;
        insert standardPrice ;*/
        
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.workOrderId = wo.Id;
        woli.description = 'abcd';
        woli.Quantity=2;
        woli.PricebookEntryId=standardPBE.Id;
        woli.centroCosto__c = cc.Id;
        insert woli;
        
        //Esteban Segura Benavides
        //WorkOrderLineItem woli2 = new WorkOrderLineItem();
        //woli2.workOrderId = wo2.Id;
        //woli2.description = 'abcd';
        //woli2.Quantity=2;
        //woli2.PricebookEntryId=standardPBE.Id;
        //woli2.centroCosto__c = cc2.Id;
        //insert woli2;
        
        //WorkOrderLineItem woli3 = new WorkOrderLineItem();
        //woli3.workOrderId = wo3.Id;
        //woli3.description = 'abcd';
        //woli3.Quantity=2;
        //woli3.PricebookEntryId=standardPBE.Id;
        //woli3.centroCosto__c = cc3.Id;
        //insert woli3;
        
        //WorkOrderLineItem woli4 = new WorkOrderLineItem();
        //woli4.workOrderId = wo4.Id;
        //woli4.description = 'abcd';
        //woli4.Quantity=2;
        //woli4.PricebookEntryId=standardPBE.Id;
        //woli4.centroCosto__c = cc4.Id;
        //insert woli4;
        
        categoriaCliente__c cet = new categoriaCliente__c();
        cet.categoriaCliente__c = 'COM';
        insert cet;
        
        condicionPago__c condicionPago = new condicionPago__c();
        condicionPago.condicionPago__c='0';
        condicionPago.Descripcion__c='test desc';
        condicionPago.Name='test cp';
        insert condicionPago;

        Impuesto__c Impuesto = new Impuesto__c();
        Impuesto.codigoImpuesto__c='0108';
        Impuesto.descripcion__c='test desc';
        Impuesto.Impuesto__c=2;
        Impuesto.Name='IVA-Tarifa General 13%';
        Impuesto.porcentaje__c=3;
        insert Impuesto;
        
        Account acc= new Account();
        acc.Name='Test account';
        acc.Cedula__c='9876543210';
        acc.Tipo_de_Documento__c='02';
        acc.condicionPago__c=condicionPago.Id;
        acc.Impuesto__c=Impuesto.Id;
        insert acc;
        
        //update work Order:
        //

        //wo.Etapa_de_flujo_de_trabajo__c='Aprobación de presupuesto';
        wo.AccountId=acc.Id;
        //wo.Pricebook2Id=pricebookId;
        
        WorkOrder tmp1 = [Select PriceBook2Id from WorkOrder Where Id = :wo.id];
        WorkOrderLineItem tmp2 = [Select PricebookEntry.pricebook2Id from WorkOrderLineItem Where Id = :woli.id];
        system.debug('zzzz:'+tmp1.Pricebook2Id);
        system.debug('zz:'+tmp2.PricebookEntry.pricebook2Id);
        system.debug('dolar pricebook id:'+pb.Id);
        
        update wo;
        
        ProductConsumed pc = new ProductConsumed();
        pc.WorkorderId = wo.Id;
        pc.PriceBookEntryId = standardPBE.Id;
        pc.QuantityConsumed = 1;
        insert pc;
        ApexPages.StandardController controller = new ApexPages.StandardController(wo);
        ApexPages.currentPage().getParameters().put('WorkOrder_lkid', wo.Id);
        WorkorderLineItemController cntrl = new WorkorderLineItemController(controller);
        cntrl.saveWLI();
        cntrl.getBodegas();
        cntrl.setWliBodega();
        WorkorderLineItemController.searchProducts('er', wo.Pricebook2Id);
        Test.stopTest();
    }
}