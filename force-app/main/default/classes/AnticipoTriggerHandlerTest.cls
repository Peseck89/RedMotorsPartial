@IsTest
public with sharing class AnticipoTriggerHandlerTest {

    @TestSetup
    static void makeData() {
        TestDataFactory.createQuoteWithItems();
    }

 
    @IsTest
    static void testCreateAnticipo() {
        List<Opportunity> oppList = [SELECT Id FROM Opportunity LIMIT 1];

        Test.setMock(HttpCalloutMock.class, new WSRelAntMock());

        Test.startTest();
        Anticipo__c anticipo = TestDataFactory.createAnticipo(oppList[0], true);
        Test.stopTest();

        // El Anticipo fue insertado correctamente
        System.assertNotEquals(null, anticipo.Id,
            'El Anticipo debe tener un Id tras el insert');

        // El anticipo existe en la base de datos
        List<Anticipo__c> anticiposEnBD = [SELECT Id, Oportunidad__c FROM Anticipo__c WHERE Id = :anticipo.Id];
        System.assertEquals(1, anticiposEnBD.size(),
            'Debe existir exactamente 1 Anticipo con el Id generado');

        // El lookup a Oportunidad es correcto
        System.assertEquals(oppList[0].Id, anticiposEnBD[0].Oportunidad__c,
            'El Anticipo debe estar relacionado con la Oportunidad correcta');
    }

    private class WSRelAntMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            Registrar_Anticipo_Controller.WSRelANTResult wSRelANTResult =
                new Registrar_Anticipo_Controller.WSRelANTResult();

            Registrar_Anticipo_Controller.WSRelacionaAnticipoRespuesta wsValues =
                new Registrar_Anticipo_Controller.WSRelacionaAnticipoRespuesta();
            wsValues.code        = '00';
            wsValues.description = 'test';

            wSRelANTResult.operationResult = wsValues;

            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(JSON.serialize(wSRelANTResult));
            res.setStatusCode(200);
            return res;
        }
    }
}