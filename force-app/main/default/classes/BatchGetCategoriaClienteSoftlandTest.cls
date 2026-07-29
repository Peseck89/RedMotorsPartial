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
        ExampleCalloutMock mock = new ExampleCalloutMock();
        Test.setMock(HttpCalloutMock.class, mock);
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
        System.assert(mock.capturedEndpoints[0].containsIgnoreCase('compania=RMBAVARIAN'));
    }

    @isTest
    static void testBatchGetCategoriaClienteSoftlandRMOTOBAI() {
        Test.startTest();
        ExampleCalloutMock mock = new ExampleCalloutMock();
        Test.setMock(HttpCalloutMock.class, mock);
        System.enqueueJob(new BatchGetCategoriaClienteSoftland('RMOTOBAI'));
        Test.stopTest();

        List<CategoriaCliente__c> resultados = [
            SELECT Id, CategoriaCliente__c
            FROM CategoriaCliente__c
            WHERE CategoriaCliente__c = 'CC001'
        ];

        System.assertEquals(1, resultados.size());
        System.assert(mock.capturedEndpoints[0].containsIgnoreCase('compania=RMOTOBAI'));
    }

    @isTest
    static void testBatchGetCategoriaClienteSoftlandRMPEKING() {
        Test.startTest();
        ExampleCalloutMock mock = new ExampleCalloutMock();
        Test.setMock(HttpCalloutMock.class, mock);
        System.enqueueJob(new BatchGetCategoriaClienteSoftland('RMPEKING'));
        Test.stopTest();

        List<CategoriaCliente__c> resultados = [
            SELECT Id, CategoriaCliente__c
            FROM CategoriaCliente__c
            WHERE CategoriaCliente__c = 'CC001'
        ];

        System.assertEquals(1, resultados.size());
        System.assert(mock.capturedEndpoints[0].containsIgnoreCase('compania=RMPEKING'));
    }

    public class ExampleCalloutMock implements HttpCalloutMock {
        public List<String> capturedEndpoints = new List<String>();

        public HttpResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(200);

            String endpoint = req.getEndpoint();

            if (endpoint != null && endpoint.containsIgnoreCase('oauth/token')) {
                res.setBody('{"access_token":"token","token_type":"Bearer"}');
            } else {
                capturedEndpoints.add(endpoint);
                res.setBody('{"Paging":{"TotalThisViewCount":1,"TotalRecordCount":1,"PageSize":1,"PageNo":1,"PageCount":1},"Data":[{"categoriaCliente":"CC001","descripcion":"Registro Test"}]}');
            }
            return res;
        }
    }
}