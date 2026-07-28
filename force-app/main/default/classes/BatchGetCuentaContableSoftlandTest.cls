@isTest
public class BatchGetCuentaContableSoftlandTest {
    
    @isTest
    static void testBatchGetCuentaContableSoftland() {
        CuentaContable__c ccExistente = new CuentaContable__c(
            Name              = 'Registro Original',
            CuentaContable__c = 'CTA001',
            descripcion__c    = 'Registro Original'
        );
        insert ccExistente;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        System.enqueueJob(new BatchGetCuentaContableSoftland());
        Test.stopTest();
        
        List<CuentaContable__c> resultados = [
            SELECT Id, Name, CuentaContable__c, descripcion__c 
            FROM CuentaContable__c 
            WHERE CuentaContable__c = 'CTA001'
        ];
        
        System.assertEquals(1, resultados.size());
        System.assertEquals('Cuenta Test', resultados[0].Name);
        System.assertEquals('CTA001', resultados[0].CuentaContable__c);
        System.assertEquals('Cuenta Test', resultados[0].descripcion__c);
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
                res.setBody('{"Paging":{"TotalThisViewCount":1,"TotalRecordCount":1,"PageSize":1,"PageNo":1,"PageCount":1},"Data":[{"CuentaContable":"CTA001","descripcion":"Cuenta Test"}]}');
            }
            return res;
        }
    }
}