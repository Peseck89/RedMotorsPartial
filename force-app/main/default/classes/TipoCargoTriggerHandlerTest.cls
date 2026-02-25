@isTest
private class TipoCargoTriggerHandlerTest {
    
    @testSetup
    static void setup()
    {
        condicionPago__c cp = new condicionPago__c();
        cp.condicionPago__c = '0';
        insert cp;
        
        categoriaCliente__c cdc = new categoriaCliente__c();
        cdc.categoriaCliente__c = 'COM';
        insert cdc;
        
        Impuesto__c impuesto = new Impuesto__c(impuesto__c = 90,codigoImpuesto__c='0108');
        insert impuesto;
        
        CentroCosto__c cc = new CentroCosto__c();
        insert cc;
        
        Account a = new Account();
        a.Name = 'Test Account';
        a.Cedula__c = '1231231232';
        a.condicionPago__c = cp.Id;
        a.categoriaCliente__c = cdc.Id;
        a.impuesto__c = impuesto.Id;
        insert a;
        
        // Insert Product
        Product2 p = new Product2();
        p.Name = ' Test Product ';
        p.Description='Test Product Entry 1';
        p.productCode = 'ABCDF';
        p.isActive = true;
        p.Codigo_de_Producto__c = '123ABC';
        insert p;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        // Insert PricebookEntry
        PricebookEntry standardPrice;
        List<PricebookEntry> standardPrices = [SELECT Id,CurrencyIsoCode FROM PricebookEntry WHERE Product2Id = :p.Id AND Pricebook2Id = :pricebookId];
        if(standardPrices.size()>0)
        {
            
            standardPrice = standardPrices[0];
            System.debug(standardPrice.CurrencyIsoCode);
        } else {
        	standardPrice = new PricebookEntry();
            standardPrice.Pricebook2Id = pricebookId;
            standardPrice.Product2Id = p.Id;
            standardPrice.UnitPrice = 1;
            standardPrice.IsActive = true;
            standardPrice.UseStandardPrice = false; 
            insert standardPrice ;
        }
        
        
        WorkOrder wo = new WorkOrder();
        wo.subject ='title';
        wo.Pricebook2Id=pricebookId;
        wo.tipoDeGasto__c='Cliente';
        wo.CurrencyIsoCode = 'CRC';
        //wo.Etapa_de_flujo_de_trabajo__c='Aprobación de presupuesto';
        
        insert wo;
        
        Case cs = new Case();
        insert cs;
        
        // Insert Order
        
        Order o = new Order();
        o.Name = 'Test Order ';
        o.Status = 'Draft';
        o.EffectiveDate = system.today();
        o.EndDate = system.today() + 4;
        o.AccountId = a.id;
        o.Contribuyente__c = a.id;
        o.Pricebook2Id =  pricebookId ;
        o.Work_Order__c = wo.Id;
        o.CurrencyIsoCode = 'CRC';
        o.Case__c = cs.Id;
        
        insert o;
        
        
        // Insert Order Item
        
        OrderItem i = new OrderItem();
        i.OrderId = o.id;
        i.Quantity = 24;
        i.UnitPrice = 240;
        i.Product2id = p.id;
        i.PricebookEntryId=standardPrice.id;
        i.centroCosto__c = cc.Id;
        i.descuento__c = 23;
        i.totalItem__c = 2000;
        i.Impuesto__c = impuesto.Id;
        
        insert i;
        
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.workOrderId = wo.Id;
        woli.description = 'abcd';
        woli.Quantity=1;
        //woli.porcentajeTiposDeCargo__c  = 1;
        woli.PricebookEntryId=standardPrice.Id;
        woli.centroCosto__c = cc.Id;
        insert woli;
        
        TipoCargo__c tc = new TipoCargo__c(productoPedido__c = i.Id,
                                           porcentaje__c = 0,
                                           Work_Order_Line_Item__c = woli.Id,
                                           tipoCargo__c ='1');
        insert tc;
        tc.tipoCargo__c = '2';
        update tc;
    }
    @isTest
    public static void testTipoCargoTriggerHandler()
    {
        
        //System.assertEquals(0.05, [select porcentajeTiposDeCargo__c from WorkOrderLineItem limit 1].porcentajeTiposDeCargo__c);
        delete [select id from TipoCargo__c];
        //System.assertEquals(100.05, [select porcentajeTiposDeCargo__c from WorkOrderLineItem limit 1].porcentajeTiposDeCargo__c);
    }
    @isTest
    public static void testTipoCargoTest(){
        condicionPago__c cp = new condicionPago__c();
        cp.condicionPago__c = '0';
        insert cp;
        
        categoriaCliente__c cdc = new categoriaCliente__c();
        cdc.categoriaCliente__c = 'COM';
        insert cdc;
        
        Impuesto__c impuesto = new Impuesto__c(impuesto__c = 90,codigoImpuesto__c='0108');
        insert impuesto;
        
        CentroCosto__c cc = new CentroCosto__c();
        insert cc;
        
        Account a = new Account();
        a.Name = 'Test Account1';
        a.Cedula__c = '1231231231';
        a.condicionPago__c = cp.Id;
        a.categoriaCliente__c = cdc.Id;
        a.impuesto__c = impuesto.Id;
        insert a;
        
        // Insert Product
        Product2 p = new Product2();
        p.Name = ' Test Product2 ';
        p.Description='Test Product Entry 1';
        p.productCode = 'ABCDF';
        p.isActive = true;
        p.Codigo_de_Producto__c = '123ABD';
        insert p;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        // Insert PricebookEntry
        PricebookEntry standardPrice;
        List<PricebookEntry> standardPrices = [SELECT Id,CurrencyIsoCode FROM PricebookEntry WHERE Product2Id = :p.Id AND Pricebook2Id = :pricebookId];
        if(standardPrices.size()>0)
        {
            
            standardPrice = standardPrices[0];
            System.debug(standardPrice.CurrencyIsoCode);
        } else {
        	standardPrice = new PricebookEntry();
            standardPrice.Pricebook2Id = pricebookId;
            standardPrice.Product2Id = p.Id;
            standardPrice.UnitPrice = 1;
            standardPrice.IsActive = true;
            standardPrice.UseStandardPrice = false; 
            insert standardPrice ;
        }
        
        
        WorkOrder wo = new WorkOrder();
        wo.subject ='title2';
        wo.Pricebook2Id=pricebookId;
        wo.tipoDeGasto__c='Cliente';
        wo.CurrencyIsoCode = 'CRC';
        //wo.Etapa_de_flujo_de_trabajo__c='Aprobación de presupuesto';
        
        insert wo;
        
        Case cs = new Case();
        insert cs;
        
        // Insert Order
        
        Order o = new Order();
        o.Name = 'Test Order ';
        o.Status = 'Draft';
        o.EffectiveDate = system.today();
        o.EndDate = system.today() + 4;
        o.AccountId = a.id;
        o.Contribuyente__c = a.id;
        o.Pricebook2Id =  pricebookId ;
        o.Work_Order__c = wo.Id;
        o.CurrencyIsoCode = 'CRC';
        o.Case__c = cs.Id;
        
        insert o;
        
        
        // Insert Order Item
        
        OrderItem i = new OrderItem();
        i.OrderId = o.id;
        i.Quantity = 24;
        i.UnitPrice = 240;
        i.Product2id = p.id;
        i.PricebookEntryId=standardPrice.id;
        i.centroCosto__c = cc.Id;
        i.descuento__c = 23;
        i.totalItem__c = 2000;
        i.Impuesto__c = impuesto.Id;
        
        insert i;
        
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.workOrderId = wo.Id;
        woli.description = 'abcd';
        woli.Quantity=1;
        //woli.porcentajeTiposDeCargo__c  = 1;
        woli.PricebookEntryId=standardPrice.Id;
        woli.centroCosto__c = cc.Id;
        insert woli;
        
        TipoCargo__c tc = new TipoCargo__c(productoPedido__c = i.Id,
                                           porcentaje__c = 0,
                                           Work_Order_Line_Item__c = woli.Id,
                                           tipoCargo__c ='1');
        test.startTest();
        insert tc;
        tc.tipoCargo__c = '2';
        update tc;
        test.stopTest();
    }
}