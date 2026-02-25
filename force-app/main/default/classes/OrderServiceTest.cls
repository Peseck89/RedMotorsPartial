@isTest
public class OrderServiceTest {
	@testSetup
    static void setup()
    {
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
    
        PricebookEntry standardPrice = [select id from PricebookEntry limit 1];
        
        
        
        Case cs = new Case();
        insert cs;
        
        
        WorkOrder wo = new WorkOrder();
        wo.CaseId=cs.Id;
        wo.AccountId=a.Id;
        insert wo;
        // Insert Order
        
        Order o = new Order();
        o.Name = 'Test Order';
        o.Status = 'Draft';
        o.EffectiveDate = system.today();
        o.EndDate = system.today() + 4;
        o.AccountId = a.id;
        o.Contribuyente__c = a.id;
        o.Pricebook2Id =  pricebookId ;
        o.Work_Order__c = wo.Id;
        o.Case__c = cs.Id;
        o.CurrencyIsoCode = 'CRC';
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
    } 
    
    @isTest
    static void initSofltandProcessTest()
    {
        Order o = [SELECT Id FROM Order WHERE Name='Test Order'];
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account'];
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator1());
        Test.startTest();
        APIServiceLog apiLog = new APIServiceLog('requestId', APIServiceLogConstants.SOFTLAND_API_SERVICE_TYPE, APIServiceLogConstants.SOFTLAND_API_SERVICE_RELATED_OBJECT, 'relatedObjectId', APIServiceLogConstants.APILOG_WORKORDER_FIELD_REFERENCE);
        OrderService.initSofltandProcess(o.Id,acc.Id,'requestId');
        Test.stopTest();
    } 
    
    @isTest
    static void creaClienteJSONTest()
    {
        Order o = [SELECT Id FROM Order WHERE Name='Test Order'];
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account'];
        Test.setMock(HttpCalloutMock.class, new MockHttpResponeCrearCliente());
        Test.startTest();
        APIServiceLog apiLog = new APIServiceLog('requestId', APIServiceLogConstants.SOFTLAND_API_SERVICE_TYPE, APIServiceLogConstants.SOFTLAND_API_SERVICE_RELATED_OBJECT, 'relatedObjectId', APIServiceLogConstants.APILOG_WORKORDER_FIELD_REFERENCE);
        OrderService.initSofltandProcess(o.Id,acc.Id,'requestId');
        Test.stopTest();
    } 
    
    @isTest
    static void creaPedidoErrorJSONTest()
    {
        Order o = [SELECT Id FROM Order WHERE Name='Test Order'];
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account'];
        Test.setMock(HttpCalloutMock.class, new MockHttpResponeCrearPedidoConErrores());
        Test.startTest();
        APIServiceLog apiLog = new APIServiceLog('requestId', APIServiceLogConstants.SOFTLAND_API_SERVICE_TYPE, APIServiceLogConstants.SOFTLAND_API_SERVICE_RELATED_OBJECT, 'relatedObjectId', APIServiceLogConstants.APILOG_WORKORDER_FIELD_REFERENCE);
        OrderService.initSofltandProcess(o.Id,acc.Id,'requestId');
        Test.stopTest();
    } 
}