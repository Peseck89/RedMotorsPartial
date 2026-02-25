/**
 * @description       : 
 * @author            : esteban@incompany.cr
 * @group             : 
 * @last modified on  : 04-11-2022
 * @last modified by  : esteban@incompany.cr
**/

public with sharing class MovimientosController {
    @future(callout=true)
    public static void processMovimientos()
    {
        //Desactivado Temporalmente Portalnet 
        /*
        if(Test.isRunningTest())
        {
            Map<String, String> mapHeaders = new Map<String,String>();
            mapHeaders.put('Content-Type', 'application/json');

            String jsonBody = MovimientosTestData.getMovimientosJSON();
            MovimientosHttpCalloutMock mock = new MovimientosHttpCalloutMock(200, 'OK', jsonBody, mapHeaders);
            Test.setMock(HttpCalloutMock.class, mock); 

        }
        HttpResponse response = MovimientosCallout.getMovimientoDataFromAltica();
        System.debug(response.getBody());
        MovimientoParser movimientosResponse = MovimientoParser.parse(response.getBody());
        List<Movimiento__c> lstMovimientos = MovimientosHelper.getMovimientosListFromAltica(movimientosResponse);
        MovimientosHelper.upsertMovimientos(lstMovimientos);
		*/
    }
}