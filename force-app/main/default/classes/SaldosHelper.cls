/**
 * @description       : 
 * @author            : David Evangelista david@incompany.cr
 * @group             : 
 * @last modified on  : 10-11-2022
 * @last modified by  : esteban@incompany.cr
**/
public with sharing class SaldosHelper {
    public static String getRequestJSON(enviodeSaldos__c saldo){
        SaldosRequest wrapperSaldo = new SaldosRequest(saldo);
        return wrapperSaldo.getJSONResponseSaldo();     
    }

    public static String getJSONAuthorization(String jsonStr)
    {
        AuthorizationJSON wrapAuthorization = AuthorizationJSON.parseAuthInfo(jsonStr);
        return wrapAuthorization.token;
    }

    public static List<enviodeSaldos__c> getSaldosListFromAltica(SaldosParser saldos)
    {
        Set<String> lstAccountIdentifications = new Set<String>();
        for(SaldosParser.Saldo actualSaldoParser: saldos.saldos)
        {
            lstAccountIdentifications.add(actualSaldoParser.numeroIdentificacion);
        }

        Map<String, enviodeSaldos__c> mapSaldos = new Map<String, enviodeSaldos__c>();
        List<Account> lstAccounts = [SELECT Id,Cedula__c FROM Account WHERE Cedula__c IN :lstAccountIdentifications];
        Map<String,Id> mapAccounts = new Map<String,Id>();
        for(Account tempAccount : lstAccounts)
        {
            mapAccounts.put(tempAccount.Cedula__c,tempAccount.Id);
        }

        for(SaldosParser.Saldo actualSaldoParser: saldos.saldos)
        {
            enviodeSaldos__c actualSaldo = new enviodeSaldos__c();
            actualSaldo.NumeroOperacion__c = actualSaldoParser.NumeroOperacion;
            actualSaldo.tipoIdentificacion__c = actualSaldoParser.tipoIdentificacion;
            actualSaldo.numeroIdentificacion__c = actualSaldoParser.numeroIdentificacion;
            actualSaldo.cuenta__c = mapAccounts.containsKey(actualSaldoParser.numeroIdentificacion)==true?mapAccounts.get(actualSaldoParser.numeroIdentificacion):null;
            actualSaldo.nombreCompleto__c = actualSaldoParser.nombreCompleto;
            actualSaldo.fechaCorteSaldo__c = actualSaldoParser.fechaCorteSaldo!=null?DateTime.valueOf(actualSaldoParser.fechaCorteSaldo):null;
            actualSaldo.tipoProducto__c = actualSaldoParser.tipoProducto!=null?Decimal.valueOf(actualSaldoParser.tipoProducto):null;
            actualSaldo.subProducto__c = actualSaldoParser.subProducto!=null?Decimal.valueOf(actualSaldoParser.subProducto):null;
            actualSaldo.moneda__c = actualSaldoParser.moneda;
            actualSaldo.monedaProducto__c = actualSaldoParser.monedaProducto;
            actualSaldo.montoSaldo__c = actualSaldoParser.montoSaldo!=null?Decimal.valueOf(actualSaldoParser.montoSaldo):null;
            actualSaldo.limiteAprobado__c = actualSaldoParser.limiteAprobado!=null?Decimal.valueOf(actualSaldoParser.limiteAprobado):null;
            actualSaldo.fechaApertura__c = actualSaldoParser.fechaApertura!=null?DateTime.valueOf(actualSaldoParser.fechaApertura):null;
            actualSaldo.montoApertura__c = actualSaldoParser.montoApertura!=null?Decimal.valueOf(actualSaldoParser.montoApertura):null;
            actualSaldo.cuotaAprobada__c = actualSaldoParser.cuotaAprobada!=''&&actualSaldoParser.cuotaAprobada!=null?Decimal.valueOf(actualSaldoParser.cuotaAprobada):null;
            actualSaldo.fechaCancelacion__c = actualSaldoParser.fechaCancelacion!=null?DateTime.valueOf(actualSaldoParser.fechaCancelacion):null;
            actualSaldo.sucursalCompra__c = actualSaldoParser.sucursalCompra!=null?Decimal.valueOf(actualSaldoParser.sucursalCompra):null;
            actualSaldo.sucursalCancelacion__c = actualSaldoParser.sucursalApertura!=null?Decimal.valueOf(actualSaldoParser.sucursalApertura):null;
            actualSaldo.sucursalApertura__c = actualSaldoParser.sucursalCancelacion!=null?Decimal.valueOf(actualSaldoParser.sucursalCancelacion):null;
            actualSaldo.fechaRegistro__c = actualSaldoParser.fechaRegistro!=null?DateTime.valueOf(actualSaldoParser.fechaRegistro):null;
            
            mapSaldos.put(actualSaldo.NumeroOperacion__c,actualSaldo);
        }

        return mapSaldos.values();
    }

    public static void upsertSaldos(List<enviodeSaldos__c> lstSaldos)
    {
        Schema.SObjectField externalID = enviodeSaldos__c.Fields.NumeroOperacion__c;
        List<Database.UpsertResult> upsertResults = Database.upsert(lstSaldos,externalID);

        List<Log__c> logs = new List<Log__c>();
        for(Database.UpsertResult result : upsertResults)
        {
            if(result.isSuccess() != true)
            {
                for(Database.Error err : result.getErrors()) {
                    Log__c log = new Log__c();
                    log.statusCode__c = String.valueOf(err.getStatusCode());
                    log.errorMessage2__c = err.getMessage();
                    String fields;
                    for(String field : err.getFields())
                    {
                        fields = field+'\n';
                    }
                    log.fieldError__c = fields;

                    logs.add(log);
                }       
            }
        }

        update logs;
    }

    private class AuthorizationJSON
    {
        public String token;
    }

    private static AuthorizationJSON parseAuthInfo(String json) {
        return(AuthorizationJSON) System.JSON.deserialize(json, AuthorizationJSON.class);
    }
}