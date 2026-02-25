@isTest
public class doCalloutCancelarPedidoSoftlandTest {
    @isTest
    public static void testdoCalloutCancelarPedidoSoftland() {
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
        
        HttpCalloutAseguradora bgv = new HttpCalloutAseguradora();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        doCalloutCancelarPedidoSoftland.sendCheckOrderSoftland(ord.Id);
        Test.stopTest();
    }
    
    public class ExampleCalloutMock implements HttpCalloutMock{
        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(200);
            res.setBody('{"detail":"Modificable","token_type":""}');
            return res;
        }
    }
}