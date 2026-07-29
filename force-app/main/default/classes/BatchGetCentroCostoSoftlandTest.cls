@isTest
public class BatchGetCentroCostoSoftlandTest {
    
    @isTest
    static void testBatchGetCentroCostoSoftland() {
        CentroCosto__c ccExistente = new CentroCosto__c(
            Name             = 'Registro Original',
            centroCosto__c   = 'CC001',
            descripcion__c   = 'Registro Original'
        );
        insert ccExistente;

        Test.startTest();
        ExampleCalloutMock mock = new ExampleCalloutMock();
        Test.setMock(HttpCalloutMock.class, mock);
        System.enqueueJob(new BatchGetCentroCostoSoftland());
        Test.stopTest();

        List<CentroCosto__c> resultados = [
            SELECT Id, Name, centroCosto__c, descripcion__c
            FROM CentroCosto__c
            WHERE centroCosto__c = 'CC001'
        ];

        System.assertEquals(1, resultados.size());
        System.assertEquals('Centro Costo Test', resultados[0].Name);
        System.assertEquals('CC001', resultados[0].centroCosto__c);
        System.assertEquals('Centro Costo Test', resultados[0].descripcion__c);
        System.assert(mock.capturedEndpoints[0].containsIgnoreCase('compania=RMBAVARIAN'));
    }

    @isTest
    static void testBatchGetCentroCostoSoftlandRMOTOBAI() {
        Test.startTest();
        ExampleCalloutMock mock = new ExampleCalloutMock();
        Test.setMock(HttpCalloutMock.class, mock);
        System.enqueueJob(new BatchGetCentroCostoSoftland('RMOTOBAI'));
        Test.stopTest();

        List<CentroCosto__c> resultados = [
            SELECT Id, centroCosto__c
            FROM CentroCosto__c
            WHERE centroCosto__c = 'CC001'
        ];

        System.assertEquals(1, resultados.size());
        System.assert(mock.capturedEndpoints[0].containsIgnoreCase('compania=RMOTOBAI'));
    }

    @isTest
    static void testBatchGetCentroCostoSoftlandRMPEKING() {
        Test.startTest();
        ExampleCalloutMock mock = new ExampleCalloutMock();
        Test.setMock(HttpCalloutMock.class, mock);
        System.enqueueJob(new BatchGetCentroCostoSoftland('RMPEKING'));
        Test.stopTest();

        List<CentroCosto__c> resultados = [
            SELECT Id, centroCosto__c
            FROM CentroCosto__c
            WHERE centroCosto__c = 'CC001'
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
                res.setBody('{"Paging":{"TotalThisViewCount":1,"TotalRecordCount":1,"PageSize":1,"PageNo":1,"PageCount":1},"Data":[{"centroCosto":"CC001","descripcion":"Centro Costo Test"}]}');
            }
            return res;
        }
    }
}