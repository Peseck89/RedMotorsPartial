@isTest(SeeAllData=false)
public class test_clsClasses {
    
    @isTest
    public static void testMethod1(){
        //1
        cls_Client client = new cls_Client();
        client.activo='abc';
        client.alias='abc';
        client.canton='abc';
        
        //2
        cls_AuthorizationJSON.parseAutorizationResponse('{"foo":"bar"}');
        //3
        cls_AseguradoraJSON.parseAseguradoraResponse('{"foo":"bar"}');
        //4
        cls_Aseguradora Aseguradora = new cls_Aseguradora();
        //5
        cls_StatusOrder.parseStatusJSON('{"foo":"bar"}');
        //6
        cls_ProductSoftland  ProductSoftland = new cls_ProductSoftland();
        //7
        cls_Paging Paging = new cls_Paging();
        //8
        cls_OrderJSONResponse.parseOrderResponseJSON('{"foo":"bar"}');
        //9
        cls_OperationResult OperationResult = new cls_OperationResult();
        //10
        cls_InventoryJSON.parseInventoryResponse('{"foo":"bar"}');
        //11
        cls_ClientJSON.parseClientJSON('{"foo":"bar"}');
        
    }
    
    @isTest
    public static void productWSTest(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/product'; //Request URL
        req.httpMethod = 'POST';
        req.requestBody=blob.valueOf('{"foo":"bar"}');
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        productWS.createProduct();
        Test.stopTest();
    }
    
    @isTest
    public static void productWSTestNegative(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/product'; //Request URL
        req.httpMethod = 'POST';
        req.requestBody=blob.valueOf('abc');
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        productWS.createProduct();
        Test.stopTest();
    }
    
    @isTest
    public static void accountWSTest(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/account'; //Request URL
        req.httpMethod = 'POST';
        req.requestBody=blob.valueOf('{"foo":"bar"}');
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        accountWS.createAccount();
        Test.stopTest();
    }
    
    @isTest
    public static void accountWSTestNegative(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/account'; //Request URL
        req.httpMethod = 'POST';
        req.requestBody=blob.valueOf('abc');
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        accountWS.createAccount();
        Test.stopTest();
    }
    
    @isTest
    public static void precioProductoWSTest(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/precioProducto'; //Request URL
        req.httpMethod = 'POST';
        req.requestBody=blob.valueOf('{"foo":"bar"}');
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        precioProductoWS.createProduct();
        Test.stopTest();
    }
    
    @isTest
    public static void precioProductoWSTestNegative(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/precioProducto'; //Request URL
        req.httpMethod = 'POST';
        req.requestBody=blob.valueOf('abc');
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        precioProductoWS.createProduct();
        Test.stopTest();
    }
    
    
    @isTest
    public static void orderTriggerHandlerTest(){
        OrderTriggerHandler oth = new OrderTriggerHandler();
        
        condicionPago__c condicionPago = new condicionPago__c();
        condicionPago.condicionPago__c='test cp';
        condicionPago.Descripcion__c='test desc';
        condicionPago.Name='test cp';
        insert condicionPago;
        
        Impuesto__c Impuesto = new Impuesto__c();
        Impuesto.codigoImpuesto__c='test imp';
        Impuesto.descripcion__c='test desc';
        Impuesto.Impuesto__c=2;
        Impuesto.Name='test imp';
        Impuesto.porcentaje__c=3;
        insert Impuesto;
        
        Account acc= new Account();
        acc.Name='Test account';
        acc.Cedula__c='9876543210';
        acc.Tipo_de_Documento__c='02';
        acc.condicionPago__c=condicionPago.Id;
        acc.Impuesto__c=Impuesto.Id;
        insert acc;
        
        Product2 prod= new Product2();
        prod.IsActive=true;
        prod.Name='Test product';
        prod.ProductCode='00012';
        prod.Codigo_de_Producto__c='0012';
        insert prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        // Insert PricebookEntry
        
        PricebookEntry standardPrice = new PricebookEntry();
        standardPrice.Pricebook2Id = pricebookId;
        standardPrice.Product2Id = prod.Id;
        standardPrice.UnitPrice = 1;
        standardPrice.IsActive = true;
        standardPrice.UseStandardPrice = false;
        insert standardPrice ;
        
        
        
        
        Order ord = new Order();
        ord.AccountId=acc.Id;
        //ord.TotalAmount=500;
        ord.Status='Draft';
        ord.EffectiveDate=date.today();
        ord.Pricebook2Id=pricebookId;
        //ord.Contribuyente__c=acc.Id;
        //ord.Adelanto_recibido_y_confirmado__c=true;
        insert ord;
        
        CentroCosto__c cc = new CentroCosto__c();
        cc.descripcion__c='test desc';
        cc.Name='test cc';
        cc.centroCosto__c='test cc';
        insert cc;
        
        OrderItem i = new OrderItem();
        i.OrderId = ord.id;
        i.Quantity = 1;
        i.UnitPrice = 240;
        i.Product2id = prod.id;
        i.PricebookEntryId=standardPrice.id;
        i.Adelanto_requerido__c=240;
        i.Confirmaci_n_Adelanto_Recibido__c=true;
        i.centroCosto__c=cc.Id;
        i.totalItem__c=200;
        i.Impuesto__c=Impuesto.Id;
        insert i;
        
        Test.startTest();
        
        // arrange
        Boolean exceptionThrown = false;
        try {
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            
            cls_ClientJSON cls = new cls_ClientJSON();
            
            cls.Data=new List<cls_Client>();
            
            ord.Status='Aprobado';
            
            update ord;     
        } catch (Exception e) {
            exceptionThrown = true;
            
            // assert
            Boolean expectedExceptionThrown =  (e.getMessage().contains('Para poder aprobar a order debe ingresar los valores faltantes en la cuenta: condición de pago e Impuesto, porfavor verifique e intente de nuevo.')) ? true : false; 
        } 
       
        //oth.afterUpdate(); 
        //precioProductoWS.createProduct();
        Test.stopTest();
    }
    
    @isTest
    public static void orderTriggerHandlerTest1(){
        OrderTriggerHandler oth = new OrderTriggerHandler();
        
        condicionPago__c condicionPago = new condicionPago__c();
        condicionPago.condicionPago__c='test cp';
        condicionPago.Descripcion__c='test desc';
        condicionPago.Name='test cp';
        insert condicionPago;
        
        Impuesto__c Impuesto = new Impuesto__c();
        Impuesto.codigoImpuesto__c='test imp';
        Impuesto.descripcion__c='test desc';
        Impuesto.Impuesto__c=2;
        Impuesto.Name='test imp';
        Impuesto.porcentaje__c=3;
        insert Impuesto;
        
        Account acc= new Account();
        acc.Name='Test account';
        acc.Cedula__c='9876543210';
        acc.Tipo_de_Documento__c='02';
        acc.condicionPago__c=condicionPago.Id;
        acc.Impuesto__c=Impuesto.Id;
        insert acc;
        
        Product2 prod= new Product2();
        prod.IsActive=true;
        prod.Name='Test product';
        prod.ProductCode='00012';
        prod.Codigo_de_Producto__c='0012';
        insert prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        // Insert PricebookEntry
        
        PricebookEntry standardPrice = new PricebookEntry();
        standardPrice.Pricebook2Id = pricebookId;
        standardPrice.Product2Id = prod.Id;
        standardPrice.UnitPrice = 1;
        standardPrice.IsActive = true;
        standardPrice.UseStandardPrice = false;
        insert standardPrice ;
        
        
        
        
        Order ord = new Order();
        ord.AccountId=acc.Id;
        //ord.TotalAmount=500;
        ord.Status='Draft';
        ord.EffectiveDate=date.today();
        ord.Pricebook2Id=pricebookId;
        //ord.Contribuyente__c=acc.Id;
        //ord.Adelanto_recibido_y_confirmado__c=true;
        insert ord;
        
        CentroCosto__c cc = new CentroCosto__c();
        cc.descripcion__c='test desc';
        cc.Name='test cc';
        cc.centroCosto__c='test cc';
        insert cc;
        
        OrderItem i = new OrderItem();
        i.OrderId = ord.id;
        i.Quantity = 1;
        i.UnitPrice = 240;
        i.Product2id = prod.id;
        i.PricebookEntryId=standardPrice.id;
        i.Adelanto_requerido__c=240;
        i.Confirmaci_n_Adelanto_Recibido__c=true;
        i.centroCosto__c=cc.Id;
        i.totalItem__c=200;
        i.Impuesto__c=Impuesto.Id;
        insert i;
        
        Test.startTest();
        
        // arrange
        Boolean exceptionThrown = false;
        try {
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator1());
            
            cls_ClientJSON cls = new cls_ClientJSON();
            
            cls.Data=new List<cls_Client>();
            
            ord.Status='Aprobado';
            
            update ord;     
        } catch (Exception e) {
            exceptionThrown = true;
            
            // assert
            Boolean expectedExceptionThrown =  (e.getMessage().contains('Para poder aprobar a order debe ingresar los valores faltantes en la cuenta: condición de pago e Impuesto, porfavor verifique e intente de nuevo.')) ? true : false; 
        } 
        
        //oth.afterUpdate(); 
        //precioProductoWS.createProduct();
        Test.stopTest();
    }
    
    
    
    @isTest
    public static void workOrderTriggerTest(){
        
        Pricebook2 pb = new Pricebook2();
        pb.Name='Dolar';
        pb.IsActive=true;
        //pb.IsStandard=true;
        insert pb;
        
        Test.startTest();

        Id pricebookId = Test.getStandardPricebookId();
        
        CentroCosto__c cc = new CentroCosto__c();
        insert cc;
        
        WorkOrder wo = new WorkOrder();
        wo.subject ='title';
        wo.Pricebook2Id=pricebookId;
        wo.tipoDeGasto__c='Cliente';
        //wo.Etapa_de_flujo_de_trabajo__c='Aprobación de presupuesto';
        
        insert wo;
        WorkOrder tmp = [Select PriceBook2Id from WorkOrder Where Id = :wo.id];
        
        //Insert product        
        Product2 prod= new Product2();
        prod.IsActive=true;
        prod.Name='Test product';
        prod.ProductCode='00012';
        prod.Codigo_de_Producto__c='0012';
        insert prod;

        // Insert PricebookEntry

        //Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
        PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id =pricebookId, Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
        insert standardPBE;
        
        PricebookEntry standardPrice = new PricebookEntry();
        standardPrice.Pricebook2Id =  tmp.Pricebook2Id;
        standardPrice.Product2Id = prod.Id;
        standardPrice.UnitPrice = 1;
        standardPrice.IsActive = true;
        standardPrice.UseStandardPrice = false;
        //insert standardPrice ;
        
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.workOrderId = wo.Id;
        woli.description = 'abcd';
        woli.Quantity=2;
        woli.PricebookEntryId=standardPBE.Id;
        woli.centroCosto__c = cc.Id;
        insert woli;

        //insert account:
        
        condicionPago__c condicionPago = new condicionPago__c();
        condicionPago.condicionPago__c='test cp';
        condicionPago.Descripcion__c='test desc';
        condicionPago.Name='test cp';
        insert condicionPago;
        
        Impuesto__c Impuesto = new Impuesto__c();
        Impuesto.codigoImpuesto__c='test imp';
        Impuesto.descripcion__c='test desc';
        Impuesto.Impuesto__c=2;
        Impuesto.Name='test imp';
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

        wo.Etapa_de_flujo_de_trabajo__c='Aprobación de presupuesto';
        wo.AccountId=acc.Id;
        //wo.Pricebook2Id=pricebookId;
        
        WorkOrder tmp1 = [Select PriceBook2Id from WorkOrder Where Id = :wo.id];
        WorkOrderLineItem tmp2 = [Select PricebookEntry.pricebook2Id from WorkOrderLineItem Where Id = :woli.id];
        system.debug('zzzz:'+tmp1.Pricebook2Id);
        system.debug('zz:'+tmp2.PricebookEntry.pricebook2Id);
        system.debug('dolar pricebook id:'+pb.Id);
        
        
        update wo;
        
        
        Test.stopTest();
    }
    
    @isTest
    public static void HttpCalloutAseguradoraTest(){
        HttpCalloutAseguradora http = new HttpCalloutAseguradora();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        http.getAseguradoraCallout('test comp', 'test token', 'test token', 0);
    }
    
    @isTest
    public static void HttpCalloutCancelOrderTest(){
        HttpCalloutCancelOrder http = new HttpCalloutCancelOrder();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        http.getCancelOrderCallout('a1','a1','a1','a1');
        
    }
    
    @isTest
    public static void HttpCalloutGetStatusOrderTest(){
        HttpCalloutGetStatusOrder http = new HttpCalloutGetStatusOrder();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        http.getGetStatusOrderCallout('a1','a1','a1','a1');
        
    }
    
    @isTest
    public static void HttpCalloutInventoryTest(){
        HttpCalloutInventory http = new HttpCalloutInventory('test');
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        http.getInventoryCallout('a1','a1','a1',0); 
        
    }
    
}