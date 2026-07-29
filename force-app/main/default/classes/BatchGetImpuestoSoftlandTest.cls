@isTest
public class BatchGetImpuestoSoftlandTest {
    
    @isTest
    static void testBatchGetImpuestoSoftland() {
        Impuesto__c impExistente = new Impuesto__c(
            Name              = 'Impuesto Original',
            codigoImpuesto__c = 'IMP001',
            descripcion__c    = 'Impuesto Original',
            impuesto__c       = 13.0
        );
        insert impExistente;

        Test.startTest();
        ExampleCalloutMock mock = new ExampleCalloutMock();
        Test.setMock(HttpCalloutMock.class, mock);
        System.enqueueJob(new BatchGetImpuestoSoftland());
        Test.stopTest();

        List<Impuesto__c> resultados = [
            SELECT Id, Name, codigoImpuesto__c, descripcion__c, impuesto__c
            FROM Impuesto__c
            WHERE codigoImpuesto__c = 'IMP001'
        ];

        System.assertEquals(1, resultados.size());
        System.assertEquals('Impuesto Actualizado', resultados[0].Name);
        System.assertEquals('IMP001', resultados[0].codigoImpuesto__c);
        System.assertEquals('Impuesto Actualizado', resultados[0].descripcion__c);
        System.assertEquals(15.5, resultados[0].impuesto__c);
        System.assert(mock.capturedEndpoints[0].containsIgnoreCase('compania=RMBAVARIAN'));
    }

    @isTest
    static void testBatchGetImpuestoSoftlandRMOTOBAI() {
        Test.startTest();
        ExampleCalloutMock mock = new ExampleCalloutMock();
        Test.setMock(HttpCalloutMock.class, mock);
        System.enqueueJob(new BatchGetImpuestoSoftland('RMOTOBAI'));
        Test.stopTest();

        List<Impuesto__c> resultados = [
            SELECT Id, codigoImpuesto__c
            FROM Impuesto__c
            WHERE codigoImpuesto__c = 'IMP001'
        ];

        System.assertEquals(1, resultados.size());
        System.assert(mock.capturedEndpoints[0].containsIgnoreCase('compania=RMOTOBAI'));
    }

    @isTest
    static void testBatchGetImpuestoSoftlandRMPEKING() {
        Test.startTest();
        ExampleCalloutMock mock = new ExampleCalloutMock();
        Test.setMock(HttpCalloutMock.class, mock);
        System.enqueueJob(new BatchGetImpuestoSoftland('RMPEKING'));
        Test.stopTest();

        List<Impuesto__c> resultados = [
            SELECT Id, codigoImpuesto__c
            FROM Impuesto__c
            WHERE codigoImpuesto__c = 'IMP001'
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
                res.setBody('{"Paging":{"TotalThisViewCount":1,"TotalRecordCount":1,"PageSize":1,"PageNo":1,"PageCount":1},"Data":[{"codigoImpuesto":"IMP001","descripcion":"Impuesto Actualizado","impuesto":"15.5"}]}');
            }
            return res;
        }
    }
}