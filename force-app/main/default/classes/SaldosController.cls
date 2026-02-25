/**
 * @description       : 
 * @author            : esteban@incompany.cr
 * @group             : 
 * @last modified on  : 04-11-2022
 * @last modified by  : esteban@incompany.cr
**/
public with sharing class SaldosController {
    @future(callout=true)
    public static void processSaldos()
    {
        if(Test.isRunningTest())
        {
            Map<String, String> mapHeaders = new Map<String,String>();
            mapHeaders.put('Content-Type', 'application/json');

            String jsonBody = SaldosTestData.getSaldosJSON();
            SaldosHttpCalloutMock mock = new SaldosHttpCalloutMock(200, 'OK', jsonBody, mapHeaders);
            Test.setMock(HttpCalloutMock.class, mock); 
        }
        HttpResponse response = SaldosCallout.getSaldosDataFromAltica();
        System.debug(response.getBody());
        SaldosParser saldosResponse = SaldosParser.parse(response.getBody());
        List<enviodeSaldos__c> lstSaldos = SaldosHelper.getSaldosListFromAltica(saldosResponse);
        SaldosHelper.upsertSaldos(lstSaldos);
    }
}