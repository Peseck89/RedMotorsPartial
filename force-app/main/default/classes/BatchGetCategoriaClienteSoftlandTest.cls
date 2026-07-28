@isTest
public class BatchGetCategoriaClienteSoftlandTest {
    
    @isTest
    static void testBatchGetCategoriaClienteSoftland() {
        CategoriaCliente__c ccExistente = new CategoriaCliente__c(
            Name                = 'Registro Test',
            CategoriaCliente__c = 'CC001',
            descripcion__c      = 'Registro Test'
        );
        insert ccExistente;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        System.enqueueJob(new BatchGetCategoriaClienteSoftland());
        Test.stopTest();
        
        List<CategoriaCliente__c> resultados = [
            SELECT Id, Name, CategoriaCliente__c, descripcion__c 
            FROM CategoriaCliente__c 
            WHERE CategoriaCliente__c = 'CC001'
        ];
        
        System.assertEquals(1, resultados.size());
        System.assertEquals('Registro Test', resultados[0].Name);
        System.assertEquals('CC001', resultados[0].CategoriaCliente__c);
        System.assertEquals('Registro Test', resultados[0].descripcion__c);
    }
    
    public class ExampleCalloutMock implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(200);
            
            String endpoint = req.getEndpoint();
            
            if (endpoint != null && endpoint.containsIgnoreCase('oauth/token')) {
                res.setBody('{"access_token":"token","token_type":"Bearer"}');
            } else {
                res.setBody('{"Paging":{"TotalThisViewCount":1,"TotalRecordCount":1,"PageSize":1,"PageNo":1,"PageCount":1},"Data":[{"categoriaCliente":"CC001","descripcion":"Registro Test"}]}');
            }
            return res;
        }
    }
}