/**
 * @description       : 
 * @author            : esteban@incompany.cr
 * @group             : 
 * @last modified on  : 02-11-2022
 * @last modified by  : esteban@incompany.cr
**/
@isTest
public class MovimientosCallout_Test {
    @isTest
    static void sendMovimientoDataOK200()
    {
        MovimientosTestData testData = new MovimientosTestData();
        Movimiento__c movimientoTest = testData.generateMovimiento(false);
        String actualResponseBody = '{"statusCode": 0}';
        Map<String, String> mapHeaders = new Map<String,String>();
        mapHeaders.put('Content-Type', 'application/json');
        // Set mock callout class 
        MovimientosHttpCalloutMock mock = new MovimientosHttpCalloutMock(200, 'OK', actualResponseBody, mapHeaders);
        Test.setMock(HttpCalloutMock.class, mock); 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        HttpResponse response = MovimientosCallout.sendMovimientoData(movimientoTest,'sad34324AFAFASF3242');
        
        // Verify that the response received contains fake values
        String contentType = response.getHeader('Content-Type');
        String actualValue = response.getBody();
        String expectedValue = actualResponseBody;
        
        System.assert(contentType == 'application/json');
        System.assertEquals(expectedValue, actualValue);
        System.assertEquals(200, response.getStatusCode());
    }

    @isTest
    static void sendMovimientoDataBadRequest400()
    {
        MovimientosTestData testData = new MovimientosTestData();
        Movimiento__c movimientoTest = testData.generateMovimiento(false);
        String actualResponseBody = '{"type": "string","title": "string","status": 0,"detail": "string","instance": "string","errors": {"property1":[],"property2": []},"property1": null,"property2": null}';
        Map<String, String> mapHeaders = new Map<String,String>();
        mapHeaders.put('Content-Type', 'application/json');
        // Set mock callout class 
        MovimientosHttpCalloutMock mock = new MovimientosHttpCalloutMock(400, 'Bad Request',actualResponseBody, mapHeaders);
        Test.setMock(HttpCalloutMock.class, mock); 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        HttpResponse response = MovimientosCallout.sendMovimientoData(movimientoTest,'sad34324AFAFASF3242');
        
        // Verify that the response received contains fake values
        String contentType = response.getHeader('Content-Type');
        String actualValue = response.getBody();
        String expectedValue = actualResponseBody;
        
        System.assert(contentType == 'application/json');
        System.assertEquals(expectedValue, actualValue);
        System.assertEquals(400, response.getStatusCode());
    }

    @isTest
    static void getMovimientoDataFromAlticaRequest200()
    {
        MovimientosTestData testData = new MovimientosTestData();
        
        Map<String, String> mapHeaders = new Map<String,String>();
        mapHeaders.put('Content-Type', 'application/json');
        // Set mock callout class 
        MovimientosHttpCalloutMock mock = new MovimientosHttpCalloutMock(200, 'Ok','', mapHeaders);
        Test.setMock(HttpCalloutMock.class, mock); 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        HttpResponse response = MovimientosCallout.getMovimientoDataFromAltica();
        
        //Verify that the response received contains fake values
        String contentType = response.getHeader('Content-Type');
        
        System.assert(contentType == 'application/json');
        System.assertEquals(200, response.getStatusCode());
    }
}