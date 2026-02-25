/**
 * @description       : 
 * @author            : esteban@incompany.cr
 * @group             : 
 * @last modified on  : 04-11-2022
 * @last modified by  : esteban@incompany.cr
**/
@isTest
public class SaldosCallout_Test {
    @isTest
    static void sendSaldosDataOK200()
    {
        SaldosTestData testData = new SaldosTestData();
        enviodeSaldos__c saldoTest = testData.generateSaldo(false);
        String actualResponseBody = '{"statusCode": 0}';
        Map<String, String> mapHeaders = new Map<String,String>();
        mapHeaders.put('Content-Type', 'application/json');
        // Set mock callout class 
        SaldosHttpCalloutMock mock = new SaldosHttpCalloutMock(200, 'OK', actualResponseBody, mapHeaders);
        Test.setMock(HttpCalloutMock.class, mock); 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        HttpResponse response = SaldosCallout.postData('sad34324AFAFASF3242',saldoTest);
        
        // Verify that the response received contains fake values
        String contentType = response.getHeader('Content-Type');
        String actualValue = response.getBody();
        String expectedValue = actualResponseBody;
        
        System.assert(contentType == 'application/json');
        System.assertEquals(expectedValue, actualValue);
        System.assertEquals(200, response.getStatusCode());
    }

    @isTest
    static void sendSaldosDataBadRequest400()
    {
        SaldosTestData testData = new SaldosTestData();
        enviodeSaldos__c saldoTest = testData.generateSaldo(false);
        String actualResponseBody = '{"type": "string","title": "string","status": 0,"detail": "string","instance": "string","errors": {"property1":[],"property2": []},"property1": null,"property2": null}';
        Map<String, String> mapHeaders = new Map<String,String>();
        mapHeaders.put('Content-Type', 'application/json');
        // Set mock callout class 
        SaldosHttpCalloutMock mock = new SaldosHttpCalloutMock(400, 'Bad Request',actualResponseBody, mapHeaders);
        Test.setMock(HttpCalloutMock.class, mock); 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        HttpResponse response = SaldosCallout.postData('sad34324AFAFASF3242',saldoTest);
        
        // Verify that the response received contains fake values
        String contentType = response.getHeader('Content-Type');
        String actualValue = response.getBody();
        String expectedValue = actualResponseBody;
        
        System.assert(contentType == 'application/json');
        System.assertEquals(expectedValue, actualValue);
        System.assertEquals(400, response.getStatusCode());
    }

    @isTest
    static void sendSaldosDataCatch()
    {
        SaldosTestData testData = new SaldosTestData();
        enviodeSaldos__c saldoTest = null;
        String actualResponseBody = '{"type": "string","title": "string","status": 0,"detail": "string","instance": "string","errors": {"property1":[],"property2": []},"property1": null,"property2": null}';
        Map<String, String> mapHeaders = new Map<String,String>();
        mapHeaders.put('Content-Type', 'application/json');
        // Set mock callout class 
        SaldosHttpCalloutMock mock = new SaldosHttpCalloutMock(400, 'Bad Request',actualResponseBody, mapHeaders);
        Test.setMock(HttpCalloutMock.class, mock); 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        HttpResponse response = SaldosCallout.postData('sad34324AFAFASF3242',saldoTest);
        
        // Verify that the response received contains fake values
        System.assert(response==null);
    }

    @isTest
    static void getSaldosDataFromAlticaTest()
    {
        SaldosTestData testData = new SaldosTestData();
        
        Map<String, String> mapHeaders = new Map<String,String>();
        mapHeaders.put('Content-Type', 'application/json');
        // Set mock callout class 
        SaldosHttpCalloutMock mock = new SaldosHttpCalloutMock(200, 'Ok','', mapHeaders);
        Test.setMock(HttpCalloutMock.class, mock); 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        HttpResponse response = SaldosCallout.getSaldosDataFromAltica();
        
        //Verify that the response received contains fake values
        String contentType = response.getHeader('Content-Type');
        
        System.assert(contentType == 'application/json');
        System.assertEquals(200, response.getStatusCode());
    }
}