/**
 * @description       : 
 * @author            : marcohernandezhp@gmail.com
 * @group             : Remotors
 * @last modified on  : 05-15-2023
 * @last modified by  : marcohernandezhp@gmail.com
**/
@IsTest
public with sharing class AnticipoTriggerHandlerTest {
    @TestSetup
    static void makeData(){
        TestDataFactory.createQuoteWithItems();
    }

    @IsTest
    static void testCreateAnticipo(){
        List<Opportunity> oppList = [SELECT Id FROM Opportunity LIMIT 1];        
        Test.setMock(HttpCalloutMock.class, new WSRelAntMock());
        Anticipo__c anticipo = TestDataFactory.createAnticipo(oppList[0],true);
        System.debug(anticipo);        
    }


    private class WSRelAntMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {
            Registrar_Anticipo_Controller.WSRelANTResult  wSRelANTResult = new Registrar_Anticipo_Controller.WSRelANTResult();

            Registrar_Anticipo_Controller.WSRelacionaAnticipoRespuesta wsValues = new Registrar_Anticipo_Controller.WSRelacionaAnticipoRespuesta();
            wsValues.code = '00';
            wsValues.description = 'test';

            wSRelANTResult.operationResult = wsValues;     

            String fullJson = JSON.serialize(wSRelANTResult);

            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
}