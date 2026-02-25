@isTest
public class cls_Test {
    @isTest
    public static void testCLS() {
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
        Aseguradora.cliente = '12';
        
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
        
        cls_DMLHelper.getAccount(acc.Id);
        cls_DMLHelper.getOpportunity('');
        cls_DMLHelper.getOpportunityLineItem('');
        cls_DMLHelper.getOrder(ord.Id);
        cls_DMLHelper.getOrderItem(ord.Id);
    }
    
    public class ExampleCalloutMock implements HttpCalloutMock{
        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(200);
            res.setBody('{"access_token":"","token_type":""}');
            return res;
        }
    }
}