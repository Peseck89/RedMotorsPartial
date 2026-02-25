@isTest
public class http_HelperTest {
    @isTest
    public static void testhttp_Helper() {
        Test.startTest();
        condicionPago__c condicionPago = new condicionPago__c();
        condicionPago.condicionPago__c='0';
        condicionPago.Descripcion__c='test desc';
        condicionPago.Name='test cp';
        insert condicionPago;
        
        Impuesto__c Impuesto = new Impuesto__c();
        Impuesto.codigoImpuesto__c='0108';
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
        Pricebook2 pb = new Pricebook2(Name='Dolar2', IsActive=true);
        insert pb;
        
        PricebookEntry standardPrice = new PricebookEntry();
        standardPrice.Pricebook2Id = pb.Id;
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
        ord.Pricebook2Id=pb.Id;
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
        
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        http_Helper.generateAccountJSON(acc, true);
        http_Helper.generateAccountJSON(acc, false);
        http_Helper.generateOrderJSON(new Opportunity(), 'qwer');
        Test.stopTest();
    }
    
    @isTest
    public static void testcls_OrderJSONResponse() {
        Test.startTest();
        ActividadComercial__c act = new ActividadComercial__c();
        act.Name = 'VENTA DE REPUESTOS NUEVOS PARA AUTOMOVIL';
        insert act;
        Pricebook2 pb = new Pricebook2(Name='Dolar2', IsActive=true);
        insert pb;
        
        condicionPago__c condicionPago = new condicionPago__c(condicionPago__c='0',Descripcion__c='test desc', Name='0');
        insert condicionPago;
        
        Impuesto__c Impuesto = new Impuesto__c(codigoImpuesto__c='0108',descripcion__c='test desc',Impuesto__c=2, Name='test imp', porcentaje__c=3);
        insert Impuesto;
        
        Account acc = new Account(Name='Test account', Cedula__c='9876543210', Tipo_de_Documento__c='02', condicionPago__c=condicionPago.Id, Impuesto__c=Impuesto.Id);
       	insert acc;
        
       	Contact co = new Contact(Firstname='Juan Diego',LastName='Espinoza S1', Email='jesp@abc.com', AccountId=acc.Id);
       	insert co;
        
       	Asset asset = new Asset(Name='BMW X6', ContactId=co.Id, AccountId=acc.Id);
       	insert asset;

        Id pricebookId = pb.Id;
        
        CentroCosto__c cc = new CentroCosto__c();
        insert cc;
        
        WorkOrder wo = new WorkOrder(subject ='title2', Pricebook2Id=pricebookId, tipoDeGasto__c='Cliente', AssetId=asset.Id,AccountId=acc.Id);
        insert wo;
		
        String jsonSTR='{ "code": "00", "detail": "Json procesado con exito", "tipoCargo": "", "Data": [ { "code": "00", "detail": "OSLU-0000005879", "tipoCargo": "1", "Data": [] }, { "code": "00", "detail": "PILU-0000000070", "tipoCargo": "2", "Data": [] } ] }';
        
        cls_OrderJSONResponse.createResponses(cls_OrderJSONResponse.parseOrderResponseJSON(jsonSTR),wo.id);
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