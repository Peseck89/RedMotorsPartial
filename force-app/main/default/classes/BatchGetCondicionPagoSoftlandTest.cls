@isTest
public class BatchGetCondicionPagoSoftlandTest {
    
    @isTest
    static void testBatchGetCondicionPagoSoftland() {
        condicionPago__c cpExistente = new condicionPago__c(
            Name             = 'Condicion Original',
            condicionPago__c = 'CP001',
            descripcion__c   = 'Condicion Original'
        );
        insert cpExistente;

        Test.startTest();
        ExampleCalloutMock mock = new ExampleCalloutMock();
        Test.setMock(HttpCalloutMock.class, mock);
        System.enqueueJob(new BatchGetCondicionPagoSoftland());
        Test.stopTest();

        List<condicionPago__c> resultados = [
            SELECT Id, Name, condicionPago__c, descripcion__c
            FROM condicionPago__c
            WHERE condicionPago__c = 'CP001'
        ];

        System.assertEquals(1, resultados.size());
        System.assertEquals('Condicion Test', resultados[0].Name);
        System.assertEquals('CP001', resultados[0].condicionPago__c);
        System.assertEquals('Condicion Test', resultados[0].descripcion__c);
        System.assert(mock.capturedEndpoints[0].containsIgnoreCase('compania=RMBAVARIAN'));
    }

    @isTest
    static void testBatchGetCondicionPagoSoftlandRMOTOBAI() {
        Test.startTest();
        ExampleCalloutMock mock = new ExampleCalloutMock();
        Test.setMock(HttpCalloutMock.class, mock);
        System.enqueueJob(new BatchGetCondicionPagoSoftland('RMOTOBAI'));
        Test.stopTest();

        List<condicionPago__c> resultados = [
            SELECT Id, condicionPago__c
            FROM condicionPago__c
            WHERE condicionPago__c = 'CP001'
        ];

        System.assertEquals(1, resultados.size());
        System.assert(mock.capturedEndpoints[0].containsIgnoreCase('compania=RMOTOBAI'));
    }

    @isTest
    static void testBatchGetCondicionPagoSoftlandRMPEKING() {
        Test.startTest();
        ExampleCalloutMock mock = new ExampleCalloutMock();
        Test.setMock(HttpCalloutMock.class, mock);
        System.enqueueJob(new BatchGetCondicionPagoSoftland('RMPEKING'));
        Test.stopTest();

        List<condicionPago__c> resultados = [
            SELECT Id, condicionPago__c
            FROM condicionPago__c
            WHERE condicionPago__c = 'CP001'
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
                res.setBody('{"Paging":{"TotalThisViewCount":1,"TotalRecordCount":1,"PageSize":1,"PageNo":1,"PageCount":1},"Data":[{"condicionPago":"CP001","descripcion":"Condicion Test"}]}');
            }
            return res;
        }
    }
}