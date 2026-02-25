/**
 * @description       : 
 * @author            : esteban@incompany.cr
 * @group             : 
 * @last modified on  : 04-11-2022
 * @last modified by  : esteban@incompany.cr
**/
@isTest
public class SaldosHelper_Test {
    @isTest
    static void getJSONResponseMovimientoTest()
    {
        SaldosTestData testData = new SaldosTestData();
        enviodeSaldos__c movimientoTest = testData.generateSaldo(false);
        String saldoJSON = SaldosHelper.getRequestJSON(movimientoTest);
        System.assert(saldoJSON!=null);
    }

    @isTest
    static void getJSONAuthorizationTest()
    {
        String expectedValue = '00D7h000000Gz1s';
        String authJSON = '{"token":"'+expectedValue+'"}';
        String actualValue = SaldosHelper.getJSONAuthorization(authJSON);
        System.assertEquals(expectedValue,actualValue);
    }

    @isTest
    static void getSaldosListFromAltica()
    {
        String jsonStr = SaldosTestData.getSaldosJSON();
        SaldosParser saldosResponse = SaldosParser.parse(jsonStr);
        List<enviodeSaldos__c> lstSaldos = SaldosHelper.getSaldosListFromAltica(saldosResponse);
        SaldosHelper.upsertSaldos(lstSaldos);
    }
}