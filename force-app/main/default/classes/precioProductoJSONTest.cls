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
    
    @isTest
    public static void testprecioProductoJSONPeking() {
        // Precheck 2026-08-12: un payload de precio con empresa='RMPEKING' no tenia rama de
        // busqueda de Product2 (List<Product2> prod quedaba null) y precioProductoJSON.createProduct
        // lanzaba una NullPointerException no controlada en prod.size(). Esta prueba demuestra que
        // Pekin ahora sigue el mismo patron ya establecido para Otobai (CodigoProductoInterno__c)
        // y que los Pricebooks 'PEKING Local'/'PEKING Dólares' se resuelven via Empresa__c.
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
        cntrl.precio_empleado = '0';
        cntrl.empresa = 'RMPEKING';

        jsonStr = JSON.serialize(cntrl);
        String resultNotFound = precioProductoJSON.createProduct(jsonStr);
        System.assert(!resultNotFound.contains('"CODIGO":"500"'),
            'Un payload RMPEKING valido no debe producir un error 500 por NullPointerException.');

        Product2 p = new Product2(Name = 'test12345',
                                  Codigo_de_Producto__c = 'test12345', CodigoProductoInterno__c = 'test12345-RMPEKING');
        insert p;

        jsonStr = JSON.serialize(cntrl);
        String resultUpdated = precioProductoJSON.createProduct(jsonStr);
        System.assert(resultUpdated.contains('"CODIGO":"201"'),
            'Debe actualizar el producto y resolver los Pricebooks PEKING Local/Dólares via Empresa__c.');

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