@isTest(seeAllData = true)
public class precioProductoJSONTest {
    @isTest
    public static void testprecioProductoJSONBavarian() {
        Account acc= new Account();
        acc.Name='Test account';
        acc.Cedula__c='9876543210';
        acc.Tipo_de_Documento__c='02';
        acc.codigoSoftland__c = '1234';
        
        insert acc;
        
        condicionPago__c cp = new condicionPago__c(condicionPago__c = 'test');
        insert cp;
        
        categoriaCliente__c cc = new categoriaCliente__c(categoriaCliente__c = 'test');
        insert cc;
        
        impuesto__c impuesto = new impuesto__c(codigoImpuesto__c = 'test');
        insert impuesto;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        
        String jsonStr = '';
        precioProductoJSON.productRequestJSON cntrl = new precioProductoJSON.productRequestJSON();
        cntrl.articulo = 'test12345';
        cntrl.precio_local = '1234';
        cntrl.precio_dolar = '1234';
        cntrl.costo_local = '1234';
        cntrl.costo_dolar = '1234';
        cntrl.empresa = 'RMBAVARIAN';
        
        jsonStr = JSON.serialize(cntrl);
        precioProductoJSON.createProduct(jsonStr);
        
        Product2 p = new Product2(Name = 'test12345',
                                  Codigo_de_Producto__c = 'test12345');
        insert p;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        // Insert PricebookEntry
        
        PricebookEntry standardPrice = new PricebookEntry();
        standardPrice.Pricebook2Id = pricebookId;
        standardPrice.Product2Id = p.Id;
        standardPrice.UnitPrice = 1;
        standardPrice.IsActive = true;
        standardPrice.UseStandardPrice = false;
        //insert standardPrice ;
        
        jsonStr = JSON.serialize(cntrl);
        precioProductoJSON.createProduct(jsonStr);
        
        precioProductoJSON.Method();
        
        Test.stopTest();
    }
    
    @isTest
    public static void testprecioProductoJSONOtobai() {
        Account acc= new Account();
        acc.Name='Test account';
        acc.Cedula__c='9876543210';
        acc.Tipo_de_Documento__c='02';
        acc.codigoSoftland__c = '1234';
        
        insert acc;
        
        condicionPago__c cp = new condicionPago__c(condicionPago__c = 'test');
        insert cp;
        
        categoriaCliente__c cc = new categoriaCliente__c(categoriaCliente__c = 'test');
        insert cc;
        
        impuesto__c impuesto = new impuesto__c(codigoImpuesto__c = 'test');
        insert impuesto;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        
        String jsonStr = '';
        precioProductoJSON.productRequestJSON cntrl = new precioProductoJSON.productRequestJSON();
        cntrl.articulo = 'test12345';
        cntrl.precio_local = '1234';
        cntrl.precio_dolar = '1234';
        cntrl.costo_local = '1234';
        cntrl.costo_dolar = '1234';
        cntrl.empresa = 'RMOTOBAI';
        
        jsonStr = JSON.serialize(cntrl);
        precioProductoJSON.createProduct(jsonStr);
        
        Product2 p = new Product2(Name = 'test12345',
                                  Codigo_de_Producto__c = 'test12345',CodigoProductoInterno__c = 'test12345-RMOTOBAI');
        insert p;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        // Insert PricebookEntry
        
        PricebookEntry standardPrice = new PricebookEntry();
        standardPrice.Pricebook2Id = pricebookId;
        standardPrice.Product2Id = p.Id;
        standardPrice.UnitPrice = 1;
        standardPrice.IsActive = true;
        standardPrice.UseStandardPrice = false;
        //insert standardPrice ;
        
        jsonStr = JSON.serialize(cntrl);
        System.debug(jsonStr);
        precioProductoJSON.createProduct(jsonStr);
        
        Test.stopTest();
    }
    
    public static void catchError()
    {
        Test.startTest();
        String requestBdy = '{'+
    '"articulo":"Test",'+
    '"precio_local":"1200",'+
    '"precio_dolar":"5000",'+
            '}';

        precioProductoJSON.createProduct(requestBdy);
        Test.stopTest();
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