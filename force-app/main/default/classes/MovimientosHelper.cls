/**
 * @description       : 
 * @author            : esteban@incompany.cr
 * @group             : 
 * @last modified on  : 10-11-2022
 * @last modified by  : esteban@incompany.cr
**/
public with sharing class MovimientosHelper {
    public static String getJSONResponseMovimiento(Movimiento__c actualMovimiento)
    {
        MovimientosRequest movimientoRequest = new MovimientosRequest(actualMovimiento);
        return movimientoRequest.getJSONResponseMovimiento();
    }

    public static String getJSONAuthorization(String jsonStr)
    {
        AuthorizationJSON wrapAuthorization = AuthorizationJSON.parseAuthInfo(jsonStr);
        return wrapAuthorization.token;
    }

    public static List<Movimiento__c> getMovimientosListFromAltica(MovimientoParser movimientos)
    {
        Set<String> lstAccountIdentifications = new Set<String>();
        for(MovimientoParser.Movimiento actualMovimientoParser: movimientos.movimientos)
        {
            lstAccountIdentifications.add(actualMovimientoParser.num_identificacion);
        }
        List<Movimiento__c> lstMovimientos = new List<Movimiento__c>();
        List<Account> lstAccounts = [SELECT Id,Cedula__c FROM Account WHERE Cedula__c IN :lstAccountIdentifications];
        Map<String,Id> mapAccounts = new Map<String,Id>();
        for(Account tempAccount : lstAccounts)
        {
            mapAccounts.put(tempAccount.Cedula__c,tempAccount.Id);
        }

        for(MovimientoParser.Movimiento actualMovimientoParser: movimientos.movimientos)
        {
            Movimiento__c actualMovimiento = new Movimiento__c();
            actualMovimiento.TIPOIDENTIFICACION__C = actualMovimientoParser.cod_moneda_producto!=null?Decimal.valueOf(actualMovimientoParser.cod_tipo_identificacion):null;
            actualMovimiento.NUMEROIDENTIFICACION__C = actualMovimientoParser.num_identificacion;
            actualMovimiento.cuenta__c = mapAccounts.containsKey(actualMovimientoParser.num_identificacion)==true?mapAccounts.get(actualMovimientoParser.num_identificacion):null;
            actualMovimiento.NOMBRECOMPLETO__C = actualMovimientoParser.nom_completo;
            actualMovimiento.TIPOPRODUCTO__C = actualMovimientoParser.cod_tipo_producto!=null?Decimal.valueOf(actualMovimientoParser.cod_tipo_producto):null;
            actualMovimiento.SUBPRODUCTO__C = actualMovimientoParser.cod_subproducto!=null?Decimal.valueOf(actualMovimientoParser.cod_subproducto):null;
            actualMovimiento.NUMEROREFERENCIA__C = actualMovimientoParser.num_referencia;
            actualMovimiento.FECHAMOVIMIENTO__C = DateTime.valueOf(actualMovimientoParser.fec_movimiento);
            actualMovimiento.TIPOMOVIMIENTO__C = actualMovimientoParser.cod_tipo_movimiento;
            actualMovimiento.OFICINA__C = actualMovimientoParser.cod_oficina!=null?Decimal.valueOf(actualMovimientoParser.cod_oficina):null;
            actualMovimiento.CANAL__C = actualMovimientoParser.cod_canal!=null?Decimal.valueOf(actualMovimientoParser.cod_canal):null;
            actualMovimiento.DESCRIPCIONCANAL__C = actualMovimientoParser.des_canal;
            actualMovimiento.MONEDA__C = actualMovimientoParser.cod_moneda;
            actualMovimiento.MONEDAPRODUCTO__C = actualMovimientoParser.cod_moneda_producto!=null?Decimal.valueOf(actualMovimientoParser.cod_moneda_producto):null;
            actualMovimiento.NATURALEZATRANSACCION__C = actualMovimientoParser.ind_naturaleza_transaccion;
            actualMovimiento.ORIGENTRANSACCION__C = actualMovimientoParser.ind_origen_transaccion;
            actualMovimiento.TIPOCAMBIO__C = actualMovimientoParser.mon_tipo_cambio!=null?Decimal.valueOf(actualMovimientoParser.mon_tipo_cambio):null;
            actualMovimiento.MONTODEBITOS__C = actualMovimientoParser.mon_debitos!=null?Decimal.valueOf(actualMovimientoParser.mon_debitos):null;
            actualMovimiento.MONTOCREDITOS__C = actualMovimientoParser.mon_creditos!=null?Decimal.valueOf(actualMovimientoParser.mon_creditos):null;
            actualMovimiento.USUARIOREGISTRO__C = actualMovimientoParser.cod_usuario_registo!=null?Decimal.valueOf(actualMovimientoParser.cod_usuario_registo):null;
            actualMovimiento.IDORIGINARIO__C = actualMovimientoParser.num_identificacion_originario;
            actualMovimiento.NOMBREORIGINARIO__C = actualMovimientoParser.des_nombre_originario;
            actualMovimiento.IDBENEFICIARIO__C = actualMovimientoParser.num_identificacion_beneficiario;
            actualMovimiento.NOMBREBENEFICIARIO__C = actualMovimientoParser.des_nombre_beneficiario;
            actualMovimiento.NUMEROCUENTAORIGEN__C = actualMovimientoParser.num_cuenta_origen;
            actualMovimiento.NUMEROCUENTADESTINO__C = actualMovimientoParser.num_cuenta_destino;
            actualMovimiento.PAISORIGEN__C = actualMovimientoParser.cod_pais_origen;
            actualMovimiento.PAISDESTINO__C = actualMovimientoParser.cod_pais_destino;
            actualMovimiento.BANCOORIGEN__C = actualMovimientoParser.cod_banco_origen;
            actualMovimiento.BANCODESTINO__C = actualMovimientoParser.cod_banco_destino;
            actualMovimiento.FECHAREGISTRO__C = DateTime.valueOf(actualMovimientoParser.fec_registro);
            actualMovimiento.idExterno__c = actualMovimientoParser.num_identificacion+'-'+actualMovimientoParser.num_referencia+'-'+actualMovimientoParser.fec_movimiento+'-'+actualMovimientoParser.mon_debitos;
            lstMovimientos.add(actualMovimiento);
        }

        return lstMovimientos;
    }

    public static void upsertMovimientos(List<Movimiento__c> lstMovimientos)
    {
        Schema.SObjectField externalID = Movimiento__c.Fields.idExterno__c;
        List<Database.UpsertResult> upsertResults = Database.upsert(lstMovimientos,externalID);

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