@isTest
public class IteratorProduct2Test {
    @isTest
    public static void testIteratorProduct2() {
        condicionPago__c cp = new condicionPago__c(condicionPago__c = 'test');
        insert cp;
        
        Product2 product = new Product2(Name = 'test',
                                        Codigo_de_Producto__c = '234');
        insert product;
        
        List<Product2> products = new List<Product2>();
        products.add(product);
        products.add(product);
        products.add(product);
        products.add(product);
        products.add(product);
        products.add(product);
        products.add(product);
        products.add(product);
        
        IteratorProduct2 bgv = new IteratorProduct2(products);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        bgv.hasNext();
        bgv.next();
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