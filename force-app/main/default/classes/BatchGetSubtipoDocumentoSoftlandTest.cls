@isTest
public class BatchGetSubtipoDocumentoSoftlandTest {
    
    @isTest
    static void testBatchGetSubtipoDocumentoSoftland() {
        SubtipoDocumento__c sdExistente = new SubtipoDocumento__c(
            Name           = 'Registro Original',
            subtipo__c     = 'SUB001',
            descripcion__c = 'Registro Original'
        );
        insert sdExistente;

        Test.startTest();
        ExampleCalloutMock mock = new ExampleCalloutMock();
        Test.setMock(HttpCalloutMock.class, mock);
        System.enqueueJob(new BatchGetSubtipoDocumentoSoftland());
        Test.stopTest();

        List<SubtipoDocumento__c> resultados = [
            SELECT Id, Name, subtipo__c, descripcion__c
            FROM SubtipoDocumento__c
            WHERE subtipo__c = 'SUB001'
        ];

        System.assertEquals(1, resultados.size());
        System.assertEquals('Subtipo Test', resultados[0].Name);
        System.assertEquals('SUB001', resultados[0].subtipo__c);
        System.assertEquals('Subtipo Test', resultados[0].descripcion__c);
        System.assert(mock.capturedEndpoints[0].containsIgnoreCase('compania=RMBAVARIAN'));
    }

    @isTest
    static void testBatchGetSubtipoDocumentoSoftlandRMOTOBAI() {
        Test.startTest();
        ExampleCalloutMock mock = new ExampleCalloutMock();
        Test.setMock(HttpCalloutMock.class, mock);
        System.enqueueJob(new BatchGetSubtipoDocumentoSoftland('RMOTOBAI'));
        Test.stopTest();

        List<SubtipoDocumento__c> resultados = [
            SELECT Id, subtipo__c
            FROM SubtipoDocumento__c
            WHERE subtipo__c = 'SUB001'
        ];

        System.assertEquals(1, resultados.size());
        System.assert(mock.capturedEndpoints[0].containsIgnoreCase('compania=RMOTOBAI'));
    }

    @isTest
    static void testBatchGetSubtipoDocumentoSoftlandRMPEKING() {
        Test.startTest();
        ExampleCalloutMock mock = new ExampleCalloutMock();
        Test.setMock(HttpCalloutMock.class, mock);
        System.enqueueJob(new BatchGetSubtipoDocumentoSoftland('RMPEKING'));
        Test.stopTest();

        List<SubtipoDocumento__c> resultados = [
            SELECT Id, subtipo__c
            FROM SubtipoDocumento__c
            WHERE subtipo__c = 'SUB001'
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
                res.setBody('{"Paging":{"TotalThisViewCount":1,"TotalRecordCount":1,"PageSize":1,"PageNo":1,"PageCount":1},"Data":[{"subtipo":"SUB001","descripcion":"Subtipo Test"}]}');
            }
            return res;
        }
    }
}