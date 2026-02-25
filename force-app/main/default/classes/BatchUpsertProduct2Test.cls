@isTest
public class BatchUpsertProduct2Test {
    @isTest
    public static void testBatchUpsertProduct2() {
        condicionPago__c cp = new condicionPago__c(condicionPago__c = 'test');
        insert cp;
        
        //Pricebook2 pb = new Pricebook2(Name = 'Standard', IsStandard=true);
        //insert pb;
        
        Product2 product = new Product2(Name = 'Test',
                                        Codigo_de_Producto__c = 'test');
        insert product;
        
        List<Product2> pList = new List<Product2>();
        pList.add(product);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        BatchUpsertProduct2 bgv = new BatchUpsertProduct2('', '', 1, pList, null, 'getLocalListPaged');
        database.executebatch(bgv);
        bgv.execute(null, pList);
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