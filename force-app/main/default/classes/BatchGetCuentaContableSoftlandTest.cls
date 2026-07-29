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
        ExampleCalloutMock mock = new ExampleCalloutMock();
        Test.setMock(HttpCalloutMock.class, mock);
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
        System.assert(mock.capturedEndpoints[0].containsIgnoreCase('compania=RMBAVARIAN'));
    }

    @isTest
    static void testBatchGetCuentaContableSoftlandRMOTOBAI() {
        Test.startTest();
        ExampleCalloutMock mock = new ExampleCalloutMock();
        Test.setMock(HttpCalloutMock.class, mock);
        System.enqueueJob(new BatchGetCuentaContableSoftland('RMOTOBAI'));
        Test.stopTest();

        List<CuentaContable__c> resultados = [
            SELECT Id, CuentaContable__c
            FROM CuentaContable__c
            WHERE CuentaContable__c = 'CTA001'
        ];

        System.assertEquals(1, resultados.size());
        System.assert(mock.capturedEndpoints[0].containsIgnoreCase('compania=RMOTOBAI'));
    }

    @isTest
    static void testBatchGetCuentaContableSoftlandRMPEKING() {
        Test.startTest();
        ExampleCalloutMock mock = new ExampleCalloutMock();
        Test.setMock(HttpCalloutMock.class, mock);
        System.enqueueJob(new BatchGetCuentaContableSoftland('RMPEKING'));
        Test.stopTest();

        List<CuentaContable__c> resultados = [
            SELECT Id, CuentaContable__c
            FROM CuentaContable__c
            WHERE CuentaContable__c = 'CTA001'
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
                res.setBody('{"Paging":{"TotalThisViewCount":1,"TotalRecordCount":1,"PageSize":1,"PageNo":1,"PageCount":1},"Data":[{"CuentaContable":"CTA001","descripcion":"Cuenta Test"}]}');
            }
            return res;
        }
    }
}