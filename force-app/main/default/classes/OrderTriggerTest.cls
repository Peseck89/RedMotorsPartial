@isTest
public class OrderTriggerTest {
    @isTest
    public static void testOrderTrigger() {
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        
        condicionPago__c cp = new condicionPago__c(Name='CONTADO',condicionPago__c='0');
        insert cp; 
        
        categoriaCliente__c cdc = new categoriaCliente__c(categoriaCliente__c = 'COM');
        insert cdc;
        
        Impuesto__c impuesto = new Impuesto__c(impuesto__c = 90,codigoImpuesto__c = '0108');
        insert impuesto;
       
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
        p.productCode = 'ABC';
        p.isActive = true;
        p.Codigo_de_Producto__c = '123';
        insert p;
        
    
        Id pricebookId = Test.getStandardPricebookId();
        
        // Insert PricebookEntry
    
        PricebookEntry standardPrice = [select id from PricebookEntry limit 1];//new PricebookEntry();
        /*
        standardPrice.Pricebook2Id = pricebookId;
        standardPrice.Product2Id = p.Id;
        standardPrice.UnitPrice = 1;
        standardPrice.IsActive = true;
        standardPrice.UseStandardPrice = false;
        insert standardPrice ;
        */

        WorkOrder wo = new WorkOrder();
        wo.AccountId = a.id;
        wo.subject ='title';
        wo.Pricebook2Id=pricebookId;
        wo.tipoDeGasto__c='Cliente';
        WO.CurrencyIsoCode = 'CRC';
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
        o.Case__c = cs.Id;
        o.CurrencyIsoCode = 'CRC';
        Test.startTest();
        insert o;
        
        CentroCosto__c cc = new CentroCosto__c();
        insert cc;
        
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
        i.ImpuestoReal__c = 1000;
        insert i;
        
        TipoCargo__c tc = new TipoCargo__c(productoPedido__c = i.Id,
                                           porcentaje__c = 32,tipoCargo__c='1');
        insert tc;
        
        o.Status = 'Aprobado';
        update o;
        
        //OrderService.generateOrderJSON(o, '');
        //OrderService.generateOrderJSON2(o, '');
        //OrderService.generateOrderJSON3(o, '');
        //OrderService.generateOrderJSON4(o, '');
        
        Set<Id> orderIds = new Set<Id>();
        orderIds.add(o.Id);
        OrderService.getOrderIdsHavingUnavailableProducts(orderIds);
        //OrderService.getOrderIdsHavingUnavailableProducts2(orderIds);
        //OrderService.getOrderIdsHavingUnavailableProducts3(orderIds);
        //OrderService.getOrderIdsHavingUnavailableProducts4(orderIds);
        cls_DMLHelper.getOpportunity('');
        cls_DMLHelper.getOpportunityLineItem('');
        Test.stopTest();


    }
    
    public class ExampleCalloutMock implements HttpCalloutMock{
        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(200);
            String jsonStr = '{"Paging":{"TotalThisViewCount":1,"TotalRecordCount":1,"PageSize":1,"PageNo":1,"PageCount":1},"Data":[{"telefono2":null,"telefono1":null,"provincia":null,"pais":null,"otras_senas":null,"nombre":null,"moneda":null,"id":null,"distrito":null,"contacto":null,"condicionPago":"test","cliente":"df","cargo":null,"canton":null,"barrio":null,"alias":null}]}';
            //res.setBody('{"access_token":"","token_type":""}');
            res.setBody(jsonStr);
            return res;
        }
    }
}